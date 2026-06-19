// OPENFHE PYTHON SOURCE: src/lib/bindings.cpp (CKKS complex plaintext + automorphism)
//
// Six new cpp11
// bindings covering the CKKS complex plaintext round-trip
// and the automorphism surface.
//
//   CKKS complex plaintext (2):
//     MakeCKKSPackedPlaintext__complex
//       — cryptocontext.h line 1175 overload; takes
//         std::vector<std::complex<double>>
//     Plaintext__GetCKKSPackedValue
//       — plaintext.h line 370; returns
//         const std::vector<std::complex<double>>&
//
//   Automorphism (4):
//     FindAutomorphismIndex       (cryptocontext.h line 2273)
//     FindAutomorphismIndices     (cryptocontext.h line 2286)
//     EvalAutomorphismKeyGen      (cryptocontext.h line 2231)
//     EvalAutomorphism            (cryptocontext.h line 2249)
//
// Complex wire format note: cpp11 v0.4.x does not ship a
// `cpp11::complex_doubles` wrapper (only doubles / integers /
// logicals / strings / raws are covered). R has native
// complex support via CPLXSXP and the Rcomplex struct (two
// doubles: .r and .i). The bindings here take raw SEXPs at
// the cpp11 boundary and use R's C API (`COMPLEX(x)`,
// `Rf_allocVector(CPLXSXP, n)`) to marshal between Rcomplex
// and std::complex<double>. Not pretty, but it avoids the
// altrep path and keeps the R side idiomatic — R users pass
// and receive native complex vectors.
//
// EvalKeyMap typedef: the automorphism key-gen returns a
// shared_ptr<map<uint32_t, EvalKey<DCRTPoly>>> that is
// wire-compatible with the `EvalKeyMapSP` typedef.
// Redeclared file-locally (the same reuse pattern used elsewhere)
// so the external_pointer payload interops cleanly with
// `get_eval_automorphism_key_map` and friends.

#include "openfhe_cpp11.h"
#include "openfhe_helpers.h"
#include <complex>
#include <map>
#include <memory>
#include <vector>

using namespace cpp11;

using EvalKeyMapT  = std::map<uint32_t, EvalKey<DCRTPoly>>;
using EvalKeyMapSP = std::shared_ptr<EvalKeyMapT>;

// ── CKKS complex plaintext: make ────────────────────────

[[cpp11::register]]
SEXP MakeCKKSPackedPlaintext__complex(SEXP cc_xp, SEXP values_complex,
                                      int noise_scale_deg, int level,
                                      int slots) {
  external_pointer<CryptoContext<DCRTPoly>> cc(cc_xp);
  if (TYPEOF(values_complex) != CPLXSXP) {
    cpp11::stop("values must be a complex vector");
  }
  return catch_openfhe("CryptoContext::MakeCKKSPackedPlaintext(complex)", [&]() {
    const R_xlen_t n = Rf_xlength(values_complex);
    Rcomplex* data = ::COMPLEX(values_complex);
    std::vector<std::complex<double>> vec;
    vec.reserve(n);
    for (R_xlen_t i = 0; i < n; ++i) {
      vec.emplace_back(data[i].r, data[i].i);
    }
    auto pt = (*cc)->MakeCKKSPackedPlaintext(
      vec,
      static_cast<size_t>(noise_scale_deg),
      static_cast<uint32_t>(level),
      nullptr,
      static_cast<uint32_t>(slots));
    return external_pointer<Plaintext>(new Plaintext(pt));
  });
}

// ── CKKS complex plaintext: read ────────────────────────

[[cpp11::register]]
SEXP Plaintext__GetCKKSPackedValue(SEXP pt_xp) {
  external_pointer<Plaintext> pt(pt_xp);
  return catch_openfhe("Plaintext::GetCKKSPackedValue", [&]() {
    const auto& vec = (*pt)->GetCKKSPackedValue();
    const R_xlen_t n = static_cast<R_xlen_t>(vec.size());
    SEXP result = PROTECT(Rf_allocVector(CPLXSXP, n));
    Rcomplex* data = ::COMPLEX(result);
    for (R_xlen_t i = 0; i < n; ++i) {
      data[i].r = vec[i].real();
      data[i].i = vec[i].imag();
    }
    UNPROTECT(1);
    return cpp11::as_sexp(result);
  });
}

// ── Automorphism surface ────────────────────────────────

[[cpp11::register]]
int CryptoContext__FindAutomorphismIndex(SEXP cc_xp, int idx) {
  external_pointer<CryptoContext<DCRTPoly>> cc(cc_xp);
  return catch_openfhe("CryptoContext::FindAutomorphismIndex", [&]() {
    uint32_t result = (*cc)->FindAutomorphismIndex(static_cast<uint32_t>(idx));
    return static_cast<int>(result);
  });
}

[[cpp11::register]]
integers CryptoContext__FindAutomorphismIndices(SEXP cc_xp,
                                                integers idx_list) {
  external_pointer<CryptoContext<DCRTPoly>> cc(cc_xp);
  return catch_openfhe("CryptoContext::FindAutomorphismIndices", [&]() {
    std::vector<uint32_t> indices;
    indices.reserve(idx_list.size());
    for (R_xlen_t i = 0; i < idx_list.size(); ++i) {
      indices.push_back(static_cast<uint32_t>(idx_list[i]));
    }
    auto result = (*cc)->FindAutomorphismIndices(indices);
    writable::integers out(result.size());
    for (size_t i = 0; i < result.size(); ++i) {
      out[i] = static_cast<int>(result[i]);
    }
    return out;
  });
}

// EvalAutomorphismKeyGen returns shared_ptr<map<uint32_t, EvalKey>>
// and also inserts the map into the cc-internal registry under
// the private key's tag (cryptocontext.h line 2237). The R
// wrapper returns a handle (EvalKeyMap wire format) so the
// caller can optionally pass it to EvalAutomorphism directly
// without going through the registry.
[[cpp11::register]]
SEXP CryptoContext__EvalAutomorphismKeyGen(SEXP cc_xp, SEXP sk_xp,
                                           integers idx_list) {
  external_pointer<CryptoContext<DCRTPoly>> cc(cc_xp);
  external_pointer<PrivateKey<DCRTPoly>> sk(sk_xp);
  return catch_openfhe("CryptoContext::EvalAutomorphismKeyGen", [&]() {
    std::vector<uint32_t> indices;
    indices.reserve(idx_list.size());
    for (R_xlen_t i = 0; i < idx_list.size(); ++i) {
      indices.push_back(static_cast<uint32_t>(idx_list[i]));
    }
    EvalKeyMapSP sp = (*cc)->EvalAutomorphismKeyGen(*sk, indices);
    return external_pointer<EvalKeyMapSP>(new EvalKeyMapSP(sp));
  });
}

// EvalAutomorphism takes `const std::map<uint32_t, EvalKey>&` —
// a raw reference to the map, not a shared_ptr. Dereference the
// EvalKeyMapSP twice to get the map value.
[[cpp11::register]]
SEXP EvalAutomorphism__(SEXP ct_xp, int idx, SEXP map_xp) {
  external_pointer<Ciphertext<DCRTPoly>> ct(ct_xp);
  external_pointer<EvalKeyMapSP> map_sp(map_xp);
  return catch_openfhe("CryptoContext::EvalAutomorphism", [&]() {
    auto cc = (*ct)->GetCryptoContext();
    auto result = cc->EvalAutomorphism(*ct,
                                       static_cast<uint32_t>(idx),
                                       **map_sp);
    return external_pointer<Ciphertext<DCRTPoly>>(
      new Ciphertext<DCRTPoly>(result));
  });
}
