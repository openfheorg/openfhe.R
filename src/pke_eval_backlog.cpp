// OPENFHE PYTHON SOURCE: src/lib/bindings.cpp (evaluation methods bound at OpenFHE 1.6.1)
//
// CryptoContext evaluation methods that openfhe-python 1.6.1.0 exposes
// and the package did not bind through 1.5.1.2:
//
//   vectors of ciphertexts   EvalAddMany, EvalAddManyInPlace, EvalMultMany,
//                            EvalMerge, EvalLinearWSum, EvalLinearWSumMutable
//   sums and inner products  EvalInnerProduct (ct, ct) and (ct, pt),
//                            EvalSumRows, EvalSumCols, EvalSumRowsKeyGen,
//                            EvalSumColsKeyGen
//   rotation                 EvalAtIndex
//   proxy re-encryption      ReKeyGen, ReEncrypt
//   plaintext                MakeStringPlaintext
//   in place                 EvalSquareInPlace, RescaleInPlace,
//                            RelinearizeInPlace, Eval{Add,Sub,Mult}MutableInPlace
//   unchecked                EvalAddInPlaceNoCheck, EvalMultNoCheck,
//                            EvalMultNoRelinNoCheck
//   other                    ComposedEvalMult, EvalMultKeysGen
//
// A method of a ciphertext takes its context from the ciphertext, as the
// rest of the package does. A method that takes a vector of ciphertexts
// takes it from the first one.
#include "openfhe_cpp11.h"
#include "openfhe_helpers.h"
#include "wide_integers.h"

#include <complex>
#include <map>
#include <memory>
#include <string>
#include <vector>

using namespace cpp11;

namespace {

using CT = Ciphertext<DCRTPoly>;
using EvalKeyMapSP = std::shared_ptr<std::map<uint32_t, EvalKey<DCRTPoly>>>;

SEXP wrap_ct(const CT& ct) { return xptr<CT>(new CT(ct)); }

// A list of Ciphertext handles as a vector. Each element is type-checked.
std::vector<CT> ct_vector(const list& cts) {
  if (cts.size() == 0) cpp11::stop("the list of ciphertexts is empty");
  std::vector<CT> v;
  v.reserve(cts.size());
  for (R_xlen_t i = 0; i < cts.size(); ++i) {
    SEXP xp = cts[i];
    xptr<CT> ct(xp);
    v.push_back(*ct);
  }
  return v;
}

// After a call that may replace the slots of the vector it was given,
// make each R handle refer to what its slot now holds.
void write_back(const list& cts, const std::vector<CT>& v) {
  for (R_xlen_t i = 0; i < cts.size(); ++i) {
    SEXP xp = cts[i];
    xptr<CT> ct(xp);
    *ct = v[static_cast<size_t>(i)];
  }
}

// Constants of a weighted sum, by R type: integer -> int64_t,
// double -> double, complex -> std::complex<double>.
template <typename Fn>
auto with_constants(SEXP constants, Fn&& fn) {
  const R_xlen_t n = Rf_xlength(constants);
  switch (TYPEOF(constants)) {
    case INTSXP: {
      std::vector<int64_t> v(n);
      const int* p = INTEGER(constants);
      for (R_xlen_t i = 0; i < n; ++i) v[i] = static_cast<int64_t>(p[i]);
      return fn(v);
    }
    case REALSXP: {
      const double* p = ::REAL(constants);
      std::vector<double> v(p, p + n);
      return fn(v);
    }
    case CPLXSXP: {
      std::vector<std::complex<double>> v(n);
      const Rcomplex* p = ::COMPLEX(constants);
      for (R_xlen_t i = 0; i < n; ++i) v[i] = std::complex<double>(p[i].r, p[i].i);
      return fn(v);
    }
  }
  cpp11::stop("`constants` must be an integer, double or complex vector");
}

}  // namespace

// ── Vectors of ciphertexts ──────────────────────────────

[[cpp11::register]]
SEXP EvalAddMany__(list cts) {
  auto v = ct_vector(cts);
  return catch_openfhe("CryptoContext::EvalAddMany", [&]() {
    return wrap_ct(v[0]->GetCryptoContext()->EvalAddMany(v));
  });
}

// The library uses the vector for its intermediate results; the handles
// are updated to match, and the sum is returned.
[[cpp11::register]]
SEXP EvalAddManyInPlace__(list cts) {
  auto v = ct_vector(cts);
  return catch_openfhe("CryptoContext::EvalAddManyInPlace", [&]() {
    auto result = v[0]->GetCryptoContext()->EvalAddManyInPlace(v);
    write_back(cts, v);
    return wrap_ct(result);
  });
}

[[cpp11::register]]
SEXP EvalMultMany__(list cts) {
  auto v = ct_vector(cts);
  return catch_openfhe("CryptoContext::EvalMultMany", [&]() {
    return wrap_ct(v[0]->GetCryptoContext()->EvalMultMany(v));
  });
}

[[cpp11::register]]
SEXP EvalMerge__(list cts) {
  auto v = ct_vector(cts);
  return catch_openfhe("CryptoContext::EvalMerge", [&]() {
    return wrap_ct(v[0]->GetCryptoContext()->EvalMerge(v));
  });
}

[[cpp11::register]]
SEXP EvalLinearWSum__(list cts, SEXP constants) {
  auto v = ct_vector(cts);
  return catch_openfhe("CryptoContext::EvalLinearWSum", [&]() {
    std::vector<ReadOnlyCiphertext<DCRTPoly>> ro(v.begin(), v.end());
    auto cc = v[0]->GetCryptoContext();
    return with_constants(constants, [&](const auto& c) {
      return wrap_ct(cc->EvalLinearWSum(ro, c));
    });
  });
}

[[cpp11::register]]
SEXP EvalLinearWSumMutable__(SEXP constants, list cts) {
  auto v = ct_vector(cts);
  return catch_openfhe("CryptoContext::EvalLinearWSumMutable", [&]() {
    auto cc = v[0]->GetCryptoContext();
    SEXP out = with_constants(constants, [&](const auto& c) {
      return wrap_ct(cc->EvalLinearWSumMutable(c, v));
    });
    write_back(cts, v);
    return out;
  });
}

// ── Sums and inner products ─────────────────────────────

[[cpp11::register]]
SEXP EvalInnerProduct__ct_ct(SEXP ct1_xp, SEXP ct2_xp, int batch_size) {
  xptr<CT> ct1(ct1_xp);
  xptr<CT> ct2(ct2_xp);
  return catch_openfhe("CryptoContext::EvalInnerProduct(ct, ct)", [&]() {
    return wrap_ct((*ct1)->GetCryptoContext()->EvalInnerProduct(
        *ct1, *ct2, static_cast<uint32_t>(batch_size)));
  });
}

[[cpp11::register]]
SEXP EvalInnerProduct__ct_pt(SEXP ct_xp, SEXP pt_xp, int batch_size) {
  xptr<CT> ct(ct_xp);
  xptr<Plaintext> pt(pt_xp);
  return catch_openfhe("CryptoContext::EvalInnerProduct(ct, pt)", [&]() {
    ConstPlaintext p = *pt;
    return wrap_ct((*ct)->GetCryptoContext()->EvalInnerProduct(
        *ct, p, static_cast<uint32_t>(batch_size)));
  });
}

[[cpp11::register]]
SEXP EvalSumRowsKeyGen__(SEXP cc_xp, SEXP sk_xp, SEXP pk_xp, int row_size,
                         int subring_dim) {
  xptr<CryptoContext<DCRTPoly>> cc(cc_xp);
  xptr<PrivateKey<DCRTPoly>> sk(sk_xp);
  return catch_openfhe("CryptoContext::EvalSumRowsKeyGen", [&]() {
    EvalKeyMapSP m;
    if (Rf_isNull(pk_xp)) {
      m = (*cc)->EvalSumRowsKeyGen(*sk, static_cast<uint32_t>(row_size),
                                   static_cast<uint32_t>(subring_dim));
    } else {
      xptr<PublicKey<DCRTPoly>> pk(pk_xp);
      m = (*cc)->EvalSumRowsKeyGen(*sk, *pk, static_cast<uint32_t>(row_size),
                                   static_cast<uint32_t>(subring_dim));
    }
    return xptr<EvalKeyMapSP>(new EvalKeyMapSP(m));
  });
}

[[cpp11::register]]
SEXP EvalSumColsKeyGen__(SEXP cc_xp, SEXP sk_xp) {
  xptr<CryptoContext<DCRTPoly>> cc(cc_xp);
  xptr<PrivateKey<DCRTPoly>> sk(sk_xp);
  return catch_openfhe("CryptoContext::EvalSumColsKeyGen", [&]() {
    EvalKeyMapSP m = (*cc)->EvalSumColsKeyGen(*sk);
    return xptr<EvalKeyMapSP>(new EvalKeyMapSP(m));
  });
}

[[cpp11::register]]
SEXP EvalSumRows__(SEXP ct_xp, int num_rows, SEXP map_xp, int subring_dim) {
  xptr<CT> ct(ct_xp);
  xptr<EvalKeyMapSP> m(map_xp);
  return catch_openfhe("CryptoContext::EvalSumRows", [&]() {
    if (!*m) OPENFHE_THROW("the evaluation key map is empty");
    return wrap_ct((*ct)->GetCryptoContext()->EvalSumRows(
        *ct, static_cast<uint32_t>(num_rows), **m,
        static_cast<uint32_t>(subring_dim)));
  });
}

[[cpp11::register]]
SEXP EvalSumCols__(SEXP ct_xp, int num_cols, SEXP map_xp) {
  xptr<CT> ct(ct_xp);
  xptr<EvalKeyMapSP> m(map_xp);
  return catch_openfhe("CryptoContext::EvalSumCols", [&]() {
    if (!*m) OPENFHE_THROW("the evaluation key map is empty");
    return wrap_ct((*ct)->GetCryptoContext()->EvalSumCols(
        *ct, static_cast<uint32_t>(num_cols), **m));
  });
}

// ── Rotation ────────────────────────────────────────────

[[cpp11::register]]
SEXP EvalAtIndex__(SEXP ct_xp, int index) {
  xptr<CT> ct(ct_xp);
  return catch_openfhe("CryptoContext::EvalAtIndex", [&]() {
    return wrap_ct((*ct)->GetCryptoContext()->EvalAtIndex(
        *ct, static_cast<int32_t>(index)));
  });
}

// ── Proxy re-encryption ─────────────────────────────────

[[cpp11::register]]
SEXP ReKeyGen__(SEXP cc_xp, SEXP old_sk_xp, SEXP new_pk_xp) {
  xptr<CryptoContext<DCRTPoly>> cc(cc_xp);
  xptr<PrivateKey<DCRTPoly>> sk(old_sk_xp);
  xptr<PublicKey<DCRTPoly>> pk(new_pk_xp);
  return catch_openfhe("CryptoContext::ReKeyGen", [&]() {
    auto ek = (*cc)->ReKeyGen(*sk, *pk);
    return xptr<EvalKey<DCRTPoly>>(new EvalKey<DCRTPoly>(ek));
  });
}

[[cpp11::register]]
SEXP ReEncrypt__(SEXP ct_xp, SEXP ek_xp, SEXP pk_xp) {
  xptr<CT> ct(ct_xp);
  xptr<EvalKey<DCRTPoly>> ek(ek_xp);
  return catch_openfhe("CryptoContext::ReEncrypt", [&]() {
    PublicKey<DCRTPoly> pk = nullptr;  // header default
    if (!Rf_isNull(pk_xp)) {
      xptr<PublicKey<DCRTPoly>> p(pk_xp);
      pk = *p;
    }
    return wrap_ct((*ct)->GetCryptoContext()->ReEncrypt(*ct, *ek, pk));
  });
}

// ── Plaintext ───────────────────────────────────────────

[[cpp11::register]]
SEXP MakeStringPlaintext__(SEXP cc_xp, std::string str) {
  xptr<CryptoContext<DCRTPoly>> cc(cc_xp);
  return catch_openfhe("CryptoContext::MakeStringPlaintext", [&]() {
    Plaintext pt = (*cc)->MakeStringPlaintext(str);
    return xptr<Plaintext>(new Plaintext(pt));
  });
}

// ── In place ────────────────────────────────────────────

//   which: 0 EvalSquareInPlace, 1 RescaleInPlace, 2 RelinearizeInPlace
[[cpp11::register]]
void EvalUnaryInPlace__(SEXP ct_xp, int which) {
  xptr<CT> ct(ct_xp);
  catch_openfhe("CryptoContext::{EvalSquare,Rescale,Relinearize}InPlace", [&]() {
    auto cc = (*ct)->GetCryptoContext();
    switch (which) {
      case 0: cc->EvalSquareInPlace(*ct); return;
      case 1: cc->RescaleInPlace(*ct); return;
      case 2: cc->RelinearizeInPlace(*ct); return;
    }
    cpp11::stop("unknown in-place operation code %d", which);
  });
}

//   op: 0 add, 1 sub, 2 mult. Both ciphertexts may be changed; the
//   result is left in the first.
[[cpp11::register]]
void EvalMutableInPlace__(int op, SEXP ct1_xp, SEXP ct2_xp) {
  xptr<CT> ct1(ct1_xp);
  xptr<CT> ct2(ct2_xp);
  catch_openfhe("CryptoContext::Eval{Add,Sub,Mult}MutableInPlace", [&]() {
    auto cc = (*ct1)->GetCryptoContext();
    switch (op) {
      case 0: cc->EvalAddMutableInPlace(*ct1, *ct2); return;
      case 1: cc->EvalSubMutableInPlace(*ct1, *ct2); return;
      case 2: cc->EvalMultMutableInPlace(*ct1, *ct2); return;
    }
    cpp11::stop("unknown arithmetic operation code %d", op);
  });
}

// ── Unchecked forms ─────────────────────────────────────
// These skip the library's compatibility checks on their operands.

[[cpp11::register]]
void EvalAddInPlaceNoCheck__(SEXP ct1_xp, SEXP ct2_xp) {
  xptr<CT> ct1(ct1_xp);
  xptr<CT> ct2(ct2_xp);
  catch_openfhe("CryptoContext::EvalAddInPlaceNoCheck", [&]() {
    (*ct1)->GetCryptoContext()->EvalAddInPlaceNoCheck(*ct1, *ct2);
  });
}

// The scalar is a NativeInteger: a decimal string (wide_integers.h).
[[cpp11::register]]
SEXP EvalMultNoCheck__(SEXP ct_xp, std::string scalar) {
  xptr<CT> ct(ct_xp);
  return catch_openfhe("CryptoContext::EvalMultNoCheck", [&]() {
    return wrap_ct((*ct)->GetCryptoContext()->EvalMultNoCheck(
        *ct, openfhe_r::wide_from_r<NativeInteger>(scalar, "scalar")));
  });
}

[[cpp11::register]]
SEXP EvalMultNoRelinNoCheck__(SEXP ct1_xp, SEXP ct2_xp) {
  xptr<CT> ct1(ct1_xp);
  xptr<CT> ct2(ct2_xp);
  return catch_openfhe("CryptoContext::EvalMultNoRelinNoCheck", [&]() {
    return wrap_ct((*ct1)->GetCryptoContext()->EvalMultNoRelinNoCheck(*ct1, *ct2));
  });
}

// ── Other ───────────────────────────────────────────────

[[cpp11::register]]
SEXP ComposedEvalMult__(SEXP ct1_xp, SEXP ct2_xp) {
  xptr<CT> ct1(ct1_xp);
  xptr<CT> ct2(ct2_xp);
  return catch_openfhe("CryptoContext::ComposedEvalMult", [&]() {
    return wrap_ct((*ct1)->GetCryptoContext()->ComposedEvalMult(*ct1, *ct2));
  });
}

[[cpp11::register]]
void EvalMultKeysGen__(SEXP cc_xp, SEXP sk_xp) {
  xptr<CryptoContext<DCRTPoly>> cc(cc_xp);
  xptr<PrivateKey<DCRTPoly>> sk(sk_xp);
  catch_openfhe("CryptoContext::EvalMultKeysGen", [&]() {
    (*cc)->EvalMultKeysGen(*sk);
  });
}
