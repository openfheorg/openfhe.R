// OPENFHE PYTHON SOURCE: src/lib/bindings.cpp (key switching, key registry and module-level helpers bound at OpenFHE 1.6.1)
//
//   key switching     KeySwitchGen, KeySwitch, KeySwitchInPlace,
//                     KeySwitchExt, KeySwitchDownFirstElement
//   key generation    SparseKeyGen, MultiMultEvalKey
//   registries        ClearEvalSumKeys, GetAllContexts
//   globals           EnablePrecomputeCRTTablesAfterDeserializaton,
//                     DisablePrecomputeCRTTablesAfterDeserializaton
//                     (the spelling is upstream's)
//   cleartext math    EvalChebyshevFunctionPtxt,
//                     GetMultiplicativeDepthByCoeffVector
#include "openfhe_cpp11.h"
#include "openfhe_helpers.h"

#include <functional>
#include <string>
#include <vector>

#include "math/chebyshev.h"
#include "scheme/ckksrns/ckksrns-utils.h"

using namespace cpp11;

namespace {
using CT = Ciphertext<DCRTPoly>;
SEXP wrap_ct(const CT& ct) { return xptr<CT>(new CT(ct)); }
SEXP wrap_ek(const EvalKey<DCRTPoly>& ek) {
  return xptr<EvalKey<DCRTPoly>>(new EvalKey<DCRTPoly>(ek));
}
}  // namespace

// ── Key switching ───────────────────────────────────────

[[cpp11::register]]
SEXP KeySwitchGen__(SEXP cc_xp, SEXP old_sk_xp, SEXP new_sk_xp) {
  xptr<CryptoContext<DCRTPoly>> cc(cc_xp);
  xptr<PrivateKey<DCRTPoly>> old_sk(old_sk_xp);
  xptr<PrivateKey<DCRTPoly>> new_sk(new_sk_xp);
  return catch_openfhe("CryptoContext::KeySwitchGen", [&]() {
    return wrap_ek((*cc)->KeySwitchGen(*old_sk, *new_sk));
  });
}

[[cpp11::register]]
SEXP KeySwitch__(SEXP ct_xp, SEXP ek_xp) {
  xptr<CT> ct(ct_xp);
  xptr<EvalKey<DCRTPoly>> ek(ek_xp);
  return catch_openfhe("CryptoContext::KeySwitch", [&]() {
    return wrap_ct((*ct)->GetCryptoContext()->KeySwitch(*ct, *ek));
  });
}

[[cpp11::register]]
void KeySwitchInPlace__(SEXP ct_xp, SEXP ek_xp) {
  xptr<CT> ct(ct_xp);
  xptr<EvalKey<DCRTPoly>> ek(ek_xp);
  catch_openfhe("CryptoContext::KeySwitchInPlace", [&]() {
    (*ct)->GetCryptoContext()->KeySwitchInPlace(*ct, *ek);
  });
}

[[cpp11::register]]
SEXP KeySwitchExt__(SEXP ct_xp, bool add_first) {
  xptr<CT> ct(ct_xp);
  return catch_openfhe("CryptoContext::KeySwitchExt", [&]() {
    return wrap_ct((*ct)->GetCryptoContext()->KeySwitchExt(*ct, add_first));
  });
}

[[cpp11::register]]
SEXP KeySwitchDownFirstElement__(SEXP ct_xp) {
  xptr<CT> ct(ct_xp);
  return catch_openfhe("CryptoContext::KeySwitchDownFirstElement", [&]() {
    DCRTPoly e = (*ct)->GetCryptoContext()->KeySwitchDownFirstElement(*ct);
    return xptr<DCRTPoly>(new DCRTPoly(std::move(e)));
  });
}

// ── Key generation ──────────────────────────────────────

// The header marks SparseKeyGen "not supported by any crypto scheme
// currently"; it is bound because openfhe-python binds it.
[[cpp11::register]]
list SparseKeyGen__(SEXP cc_xp) {
  xptr<CryptoContext<DCRTPoly>> cc(cc_xp);
  return catch_openfhe("CryptoContext::SparseKeyGen", [&]() {
    auto kp = (*cc)->SparseKeyGen();
    writable::list result(2);
    result[0] = xptr<PublicKey<DCRTPoly>>(new PublicKey<DCRTPoly>(kp.publicKey));
    result[1] = xptr<PrivateKey<DCRTPoly>>(new PrivateKey<DCRTPoly>(kp.secretKey));
    result.attr("names") = writable::strings({"public", "secret"});
    return result;
  });
}

[[cpp11::register]]
SEXP MultiMultEvalKey__(SEXP cc_xp, SEXP sk_xp, SEXP ek_xp, std::string key_tag) {
  xptr<CryptoContext<DCRTPoly>> cc(cc_xp);
  xptr<PrivateKey<DCRTPoly>> sk(sk_xp);
  xptr<EvalKey<DCRTPoly>> ek(ek_xp);
  return catch_openfhe("CryptoContext::MultiMultEvalKey", [&]() {
    return wrap_ek((*cc)->MultiMultEvalKey(*sk, *ek, key_tag));
  });
}

// ── Registries ──────────────────────────────────────────

[[cpp11::register]]
void ClearEvalSumKeys__() {
  CryptoContextImpl<DCRTPoly>::ClearEvalSumKeys();
}

[[cpp11::register]]
void ClearEvalSumKeys__tag(std::string key_tag) {
  catch_openfhe("CryptoContext::ClearEvalSumKeys(keyTag)", [&]() {
    CryptoContextImpl<DCRTPoly>::ClearEvalSumKeys(key_tag);
  });
}

[[cpp11::register]]
list GetAllContexts__() {
  const auto& all = CryptoContextFactory<DCRTPoly>::GetAllContexts();
  writable::list out(static_cast<R_xlen_t>(all.size()));
  for (size_t i = 0; i < all.size(); ++i) {
    out[static_cast<R_xlen_t>(i)] =
        xptr<CryptoContext<DCRTPoly>>(new CryptoContext<DCRTPoly>(all[i]));
  }
  return out;
}

// ── Globals ─────────────────────────────────────────────

[[cpp11::register]]
void PrecomputeCRTTablesAfterDeserializaton__set(bool enable) {
  if (enable) {
    EnablePrecomputeCRTTablesAfterDeserializaton();
  } else {
    DisablePrecomputeCRTTablesAfterDeserializaton();
  }
}

[[cpp11::register]]
bool PrecomputeCRTTablesAfterDeserializaton__get() {
  return PrecomputeCRTTablesAfterDeserializaton();
}

// ── Cleartext math ──────────────────────────────────────

// The cleartext counterpart of EvalChebyshevFunction. OpenFHE calls
// `func` once per Chebyshev node, in a plain serial loop
// (core/lib/math/chebyshev.cpp), so the R function runs on the calling
// thread. An R error inside it comes back as cpp11's unwind exception,
// which catch_openfhe passes on untouched.
[[cpp11::register]]
cpp11::doubles EvalChebyshevFunctionPtxt__(cpp11::function func,
                                           cpp11::doubles ptxt, double a,
                                           double b, int degree) {
  // Copied by index, not with ptxt.begin()/ptxt.end(): each cpp11
  // const_iterator holds a 4096-element buffer, and with two of them in
  // this frame gcc 13 and 14 on arm64, given -fstack-protector-strong and
  // -fstack-clash-protection (the Ubuntu default), emit code from which
  // no exception can leave the function, so every error ended the R
  // process (notes/discoveries/D042).
  const R_xlen_t n = ptxt.size();
  std::vector<double> x(static_cast<size_t>(n));
  for (R_xlen_t i = 0; i < n; ++i) x[static_cast<size_t>(i)] = ptxt[i];
  return catch_openfhe("EvalChebyshevFunctionPtxt", [&]() {
    std::function<double(double)> f = [&func](double v) -> double {
      return cpp11::as_cpp<double>(func(v));
    };
    std::vector<double> y =
        EvalChebyshevFunctionPtxt(f, x, a, b, static_cast<size_t>(degree));
    return writable::doubles(y.begin(), y.end());
  });
}

// Depends only on the number of coefficients.
[[cpp11::register]]
int GetMultiplicativeDepthByCoeffVector__(int n_coefficients, bool is_normalized) {
  return catch_openfhe("GetMultiplicativeDepthByCoeffVector", [&]() {
    std::vector<double> v(static_cast<size_t>(n_coefficients));
    return static_cast<int>(GetMultiplicativeDepthByCoeffVector(v, is_normalized));
  });
}
