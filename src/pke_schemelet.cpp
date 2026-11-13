// OPENFHE PYTHON SOURCE: src/lib/pke/fbt.cpp (PolyVector, SchemeletRLWEMP)
//
// The RLWE schemelet of schemelet/rlwe-mp.h: an RLWE ciphertext {b, a}
// of two polynomials over one large modulus, under the secret key of a
// CKKS context, with conversions to and from CKKS ciphertexts. It is
// the input and output format of CKKS functional bootstrapping.
//
// PolyVector is the std::vector<Poly> those functions exchange, an
// opaque handle as in openfhe-python. The handle owns the vector;
// ModSwitch and SwitchModulus change it in place.
//
// Moduli are BigInteger values and cross the boundary as strings of
// decimal digits (wide_integers.h). Messages are int64_t values and
// cross as R doubles; the R wrapper checks they are whole numbers of
// magnitude at most 2^53.
#include "openfhe_cpp11.h"
#include "openfhe_helpers.h"
#include "wide_integers.h"

#include <cmath>
#include <memory>
#include <string>
#include <vector>

#include "schemelet/rlwe-mp.h"

using namespace cpp11;
using namespace openfhe_r;

namespace {

using PolyVec = std::vector<Poly>;
using ElementParamsSP = std::shared_ptr<DCRTPoly::Params>;

// The C++ functions index input[0] and input[1] without a check.
void need_pair(const PolyVec& v, const char* arg) {
  if (v.size() < 2)
    cpp11::stop("`%s` must hold the two RLWE polynomials {b, a}", arg);
}

SEXP poly_vec(PolyVec&& v) {
  return xptr<PolyVec>(new PolyVec(std::move(v)));
}

}  // namespace

// ── PolyVector ──────────────────────────────────────────

[[cpp11::register]]
SEXP PolyVector__new() {
  return xptr<PolyVec>(new PolyVec());
}

[[cpp11::register]]
int PolyVector__length(SEXP xp) {
  xptr<PolyVec> v(xp);
  return static_cast<int>(v->size());
}

[[cpp11::register]]
SEXP PolyVector__clone(SEXP xp) {
  xptr<PolyVec> v(xp);
  return xptr<PolyVec>(new PolyVec(*v));
}

// Switches every polynomial to `modulus`, in place.
[[cpp11::register]]
void PolyVector__SwitchModulus(SEXP xp, std::string modulus) {
  xptr<PolyVec> v(xp);
  catch_openfhe("Poly::SwitchModulus", [&]() {
    auto mod = wide_from_r<BigInteger>(modulus, "modulus");
    for (auto& poly : *v) poly.SwitchModulus(mod, 1, 0, 0);
    return true;
  });
}

[[cpp11::register]]
SEXP PolyVector__sub(SEXP a_xp, SEXP b_xp) {
  xptr<PolyVec> a(a_xp);
  xptr<PolyVec> b(b_xp);
  if (a->size() != b->size()) cpp11::stop("PolyVector sizes do not match");
  return catch_openfhe("Poly::operator-", [&]() {
    PolyVec result(*a);
    for (size_t i = 0; i < result.size(); ++i) result[i] = result[i] - (*b)[i];
    return poly_vec(std::move(result));
  });
}

// ── SchemeletRLWEMP ─────────────────────────────────────

[[cpp11::register]]
SEXP Schemelet__GetElementParams(SEXP sk_xp, int level) {
  xptr<PrivateKey<DCRTPoly>> sk(sk_xp);
  return catch_openfhe("SchemeletRLWEMP::GetElementParams", [&]() {
    if (!*sk) cpp11::stop("null private key");
    ElementParamsSP ep =
        SchemeletRLWEMP::GetElementParams(*sk, static_cast<uint32_t>(level));
    return xptr<ElementParamsSP>(new ElementParamsSP(ep));
  });
}

[[cpp11::register]]
SEXP Schemelet__EncryptCoeff(doubles input, std::string q, std::string p,
                             SEXP sk_xp, SEXP ep_xp, bool bit_reverse) {
  xptr<PrivateKey<DCRTPoly>> sk(sk_xp);
  xptr<ElementParamsSP> ep(ep_xp);
  return catch_openfhe("SchemeletRLWEMP::EncryptCoeff", [&]() {
    if (!*sk) cpp11::stop("null private key");
    if (!*ep) cpp11::stop("null element parameters");
    std::vector<int64_t> in(input.size());
    for (R_xlen_t i = 0; i < input.size(); ++i)
      in[i] = static_cast<int64_t>(std::llround(input[i]));
    return poly_vec(SchemeletRLWEMP::EncryptCoeff(
        in, wide_from_r<BigInteger>(q, "q"), wide_from_r<BigInteger>(p, "p"),
        *sk, *ep, bit_reverse));
  });
}

[[cpp11::register]]
doubles Schemelet__DecryptCoeff(SEXP input_xp, std::string q, std::string p,
                                SEXP sk_xp, SEXP ep_xp, int num_slots,
                                int length, bool bit_reverse) {
  xptr<PolyVec> input(input_xp);
  xptr<PrivateKey<DCRTPoly>> sk(sk_xp);
  xptr<ElementParamsSP> ep(ep_xp);
  need_pair(*input, "input");
  return catch_openfhe("SchemeletRLWEMP::DecryptCoeff", [&]() {
    if (!*sk) cpp11::stop("null private key");
    if (!*ep) cpp11::stop("null element parameters");
    std::vector<int64_t> out = SchemeletRLWEMP::DecryptCoeff(
        *input, wide_from_r<BigInteger>(q, "q"), wide_from_r<BigInteger>(p, "p"),
        *sk, *ep, static_cast<uint32_t>(num_slots),
        static_cast<uint32_t>(length), bit_reverse);
    writable::doubles res(static_cast<R_xlen_t>(out.size()));
    const int64_t lim = INT64_C(1) << 53;
    for (size_t i = 0; i < out.size(); ++i) {
      if (out[i] > lim || out[i] < -lim)
        cpp11::stop("a decrypted value exceeds 2^53 and cannot be returned as an R number");
      res[static_cast<R_xlen_t>(i)] = static_cast<double>(out[i]);
    }
    return doubles(res);
  });
}

// From modulus q2 to modulus q1, in place.
[[cpp11::register]]
void Schemelet__ModSwitch(SEXP input_xp, std::string q1, std::string q2) {
  xptr<PolyVec> input(input_xp);
  need_pair(*input, "input");
  catch_openfhe("SchemeletRLWEMP::ModSwitch", [&]() {
    SchemeletRLWEMP::ModSwitch(*input, wide_from_r<BigInteger>(q1, "q1"),
                               wide_from_r<BigInteger>(q2, "q2"));
    return true;
  });
}

[[cpp11::register]]
SEXP Schemelet__ConvertRLWEToCKKS(SEXP cc_xp, SEXP coeffs_xp, SEXP pk_xp,
                                  std::string big_q, int slots, int level) {
  xptr<CryptoContext<DCRTPoly>> cc(cc_xp);
  xptr<PolyVec> coeffs(coeffs_xp);
  xptr<PublicKey<DCRTPoly>> pk(pk_xp);
  need_pair(*coeffs, "coeffs");
  return catch_openfhe("SchemeletRLWEMP::ConvertRLWEToCKKS", [&]() {
    if (!*cc) cpp11::stop("null crypto context");
    if (!*pk) cpp11::stop("null public key");
    auto ct = SchemeletRLWEMP::ConvertRLWEToCKKS(
        **cc, *coeffs, *pk, wide_from_r<BigInteger>(big_q, "big_q"),
        static_cast<uint32_t>(slots), static_cast<uint32_t>(level));
    return xptr<Ciphertext<DCRTPoly>>(new Ciphertext<DCRTPoly>(ct));
  });
}

[[cpp11::register]]
SEXP Schemelet__ConvertCKKSToRLWE(SEXP ct_xp, std::string q) {
  xptr<Ciphertext<DCRTPoly>> ct(ct_xp);
  return catch_openfhe("SchemeletRLWEMP::ConvertCKKSToRLWE", [&]() {
    if (!*ct) cpp11::stop("null ciphertext");
    ConstCiphertext<DCRTPoly> cct = *ct;
    return poly_vec(SchemeletRLWEMP::ConvertCKKSToRLWE(
        cct, wide_from_r<BigInteger>(q, "q")));
  });
}

[[cpp11::register]]
std::string Schemelet__GetQPrime(SEXP pk_xp, int lvls) {
  xptr<PublicKey<DCRTPoly>> pk(pk_xp);
  return catch_openfhe("SchemeletRLWEMP::GetQPrime", [&]() {
    if (!*pk) cpp11::stop("null public key");
    return wide_to_r(
        SchemeletRLWEMP::GetQPrime(*pk, static_cast<uint32_t>(lvls)));
  });
}
