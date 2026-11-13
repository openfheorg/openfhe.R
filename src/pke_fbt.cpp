// OPENFHE PYTHON SOURCE: src/lib/pke/fbt.cpp (CKKS functional bootstrapping: GetFBTDepth, GetFEFBTDepth, EvalFBTSetup, EvalFBT, EvalFBTNoDecoding, EvalHomDecoding, EvalMVBPrecompute, EvalMVB, EvalMVBNoDecoding, EvalHermiteTrigSeries, EvalFEFuncBootstrapSetup, EvalFEFuncBootstrap, EvalFEFuncBootstrapPrecompute, EvalFEFuncBootstrapWithPrecomp, GetHermiteTrigCoefficients)
//
// cryptocontext.h declares the look-up-table evaluators as templates
// over the coefficient type, and openfhe-python instantiates each for
// int64_t (the optimized Boolean case) and std::complex<double> (the
// general case). The R type of the coefficient vector selects the
// instantiation:
//
//   integer          -> int64_t
//   double, complex  -> std::complex<double>
//
// Moduli and the initial scaling are BigInteger values and cross as
// strings of decimal digits; the post-scaling is a uint64_t and crosses
// the same way (wide_integers.h).
#include "openfhe_cpp11.h"
#include "openfhe_helpers.h"
#include "wide_integers.h"

#include <complex>
#include <functional>
#include <memory>
#include <string>
#include <vector>

#include "math/hermite.h"
#include "scheme/ckksrns/ckksrns-fhe.h"

using namespace cpp11;
using namespace openfhe_r;

namespace {

using CC = CryptoContext<DCRTPoly>;
using SeriesPowersSP = std::shared_ptr<seriesPowers<DCRTPoly>>;
using cvec = std::vector<std::complex<double>>;

cvec complex_vector(SEXP x, const char* arg) {
  const R_xlen_t n = Rf_xlength(x);
  cvec v(n);
  switch (TYPEOF(x)) {
    case INTSXP: {
      const int* p = INTEGER(x);
      for (R_xlen_t i = 0; i < n; ++i) v[i] = static_cast<double>(p[i]);
      return v;
    }
    case REALSXP: {
      const double* p = ::REAL(x);
      for (R_xlen_t i = 0; i < n; ++i) v[i] = p[i];
      return v;
    }
    case CPLXSXP: {
      const Rcomplex* p = ::COMPLEX(x);
      for (R_xlen_t i = 0; i < n; ++i)
        v[i] = std::complex<double>(p[i].r, p[i].i);
      return v;
    }
  }
  cpp11::stop("`%s` must be a numeric or complex vector", arg);
}

// Call fn with the look-up-table coefficients as int64_t (R integer) or
// std::complex<double> (R double or complex).
template <typename Fn>
auto with_lut_coefficients(SEXP coeffs, Fn&& fn) {
  if (TYPEOF(coeffs) == INTSXP) {
    const R_xlen_t n = Rf_xlength(coeffs);
    std::vector<int64_t> v(n);
    const int* p = INTEGER(coeffs);
    for (R_xlen_t i = 0; i < n; ++i) v[i] = static_cast<int64_t>(p[i]);
    return fn(v);
  }
  return fn(complex_vector(coeffs, "coeffs"));
}

std::vector<uint32_t> u32_vector(const integers& x) {
  std::vector<uint32_t> v;
  v.reserve(x.size());
  for (R_xlen_t i = 0; i < x.size(); ++i)
    v.push_back(static_cast<uint32_t>(x[i]));
  return v;
}

// The context of a precomputation: that of the first ciphertext it
// holds.
CC series_powers_context(const SeriesPowersSP& p) {
  if (!p) cpp11::stop("null SeriesPowers handle");
  for (const auto* vec : {&p->powersRe, &p->powers2Re, &p->powersIm, &p->powers2Im})
    for (const auto& ct : *vec)
      if (ct) return ct->GetCryptoContext();
  if (p->power2km1Re) return p->power2km1Re->GetCryptoContext();
  if (p->power2km1Im) return p->power2km1Im->GetCryptoContext();
  cpp11::stop("the SeriesPowers object holds no ciphertext");
}

SEXP ct_out(const Ciphertext<DCRTPoly>& ct) {
  return xptr<Ciphertext<DCRTPoly>>(new Ciphertext<DCRTPoly>(ct));
}

SEXP powers_out(const SeriesPowersSP& p) {
  if (!p) cpp11::stop("the library returned no precomputation");
  return xptr<SeriesPowersSP>(new SeriesPowersSP(p));
}

}  // namespace

// ── Depth ───────────────────────────────────────────────

[[cpp11::register]]
int GetFBTDepth__(integers level_budget, SEXP coefficients, std::string p_input,
                  int order, int skd, int first_mod_size) {
  return catch_openfhe("FHECKKSRNS::GetFBTDepth", [&]() {
    auto lb = u32_vector(level_budget);
    auto pin = wide_from_r<BigInteger>(p_input, "p_input");
    uint32_t d = with_lut_coefficients(coefficients, [&](const auto& v) {
      return FHECKKSRNS::GetFBTDepth(lb, v, pin, static_cast<size_t>(order),
                                     static_cast<SecretKeyDist>(skd),
                                     static_cast<uint32_t>(first_mod_size));
    });
    return static_cast<int>(d);
  });
}

[[cpp11::register]]
int GetFEFBTDepth__(integers level_budget, SEXP coefficients, int skd,
                    int first_mod_size) {
  return catch_openfhe("FHECKKSRNS::GetFEFBTDepth", [&]() {
    return static_cast<int>(FHECKKSRNS::GetFEFBTDepth(
        u32_vector(level_budget), complex_vector(coefficients, "coefficients"),
        static_cast<SecretKeyDist>(skd), static_cast<uint32_t>(first_mod_size)));
  });
}

// ── Functional bootstrapping of a look-up table ─────────

[[cpp11::register]]
void EvalFBTSetup__(SEXP cc_xp, SEXP coeffs, int num_slots, std::string p_in,
                    std::string p_out, std::string big_q, SEXP pk_xp,
                    integers dim1, integers level_budget, int lvls_after_boot,
                    int depth_leveled_computation, int order) {
  xptr<CC> cc(cc_xp);
  xptr<PublicKey<DCRTPoly>> pk(pk_xp);
  catch_openfhe("CryptoContext::EvalFBTSetup", [&]() {
    auto pin = wide_from_r<BigInteger>(p_in, "p_in");
    auto pout = wide_from_r<BigInteger>(p_out, "p_out");
    auto bq = wide_from_r<BigInteger>(big_q, "big_q");
    with_lut_coefficients(coeffs, [&](const auto& v) {
      (*cc)->EvalFBTSetup(v, static_cast<uint32_t>(num_slots), pin, pout, bq,
                          *pk, u32_vector(dim1), u32_vector(level_budget),
                          static_cast<uint32_t>(lvls_after_boot),
                          static_cast<uint32_t>(depth_leveled_computation),
                          static_cast<size_t>(order));
      return true;
    });
    return true;
  });
}

[[cpp11::register]]
SEXP EvalFBT__(SEXP ct_xp, SEXP coeffs, int digit_bit_size,
               std::string initial_scaling, std::string post_scaling,
               int level_to_reduce, int order) {
  xptr<Ciphertext<DCRTPoly>> ct(ct_xp);
  return catch_openfhe("CryptoContext::EvalFBT", [&]() {
    auto cc = (*ct)->GetCryptoContext();
    ConstCiphertext<DCRTPoly> cct = *ct;
    auto is = wide_from_r<BigInteger>(initial_scaling, "initial_scaling");
    uint64_t ps = uint64_from_r(post_scaling, "post_scaling");
    Ciphertext<DCRTPoly> res = with_lut_coefficients(coeffs, [&](const auto& v) {
      return cc->EvalFBT(cct, v, static_cast<uint32_t>(digit_bit_size), is, ps,
                         static_cast<uint32_t>(level_to_reduce),
                         static_cast<size_t>(order));
    });
    return ct_out(res);
  });
}

[[cpp11::register]]
SEXP EvalFBTNoDecoding__(SEXP ct_xp, SEXP coeffs, int digit_bit_size,
                         std::string initial_scaling, int order) {
  xptr<Ciphertext<DCRTPoly>> ct(ct_xp);
  return catch_openfhe("CryptoContext::EvalFBTNoDecoding", [&]() {
    auto cc = (*ct)->GetCryptoContext();
    ConstCiphertext<DCRTPoly> cct = *ct;
    auto is = wide_from_r<BigInteger>(initial_scaling, "initial_scaling");
    Ciphertext<DCRTPoly> res = with_lut_coefficients(coeffs, [&](const auto& v) {
      return cc->EvalFBTNoDecoding(cct, v, static_cast<uint32_t>(digit_bit_size),
                                   is, static_cast<size_t>(order));
    });
    return ct_out(res);
  });
}

[[cpp11::register]]
SEXP EvalHomDecoding__(SEXP ct_xp, std::string post_scaling, int level_to_reduce) {
  xptr<Ciphertext<DCRTPoly>> ct(ct_xp);
  return catch_openfhe("CryptoContext::EvalHomDecoding", [&]() {
    auto cc = (*ct)->GetCryptoContext();
    ConstCiphertext<DCRTPoly> cct = *ct;
    return ct_out(cc->EvalHomDecoding(cct, uint64_from_r(post_scaling, "post_scaling"),
                                      static_cast<uint32_t>(level_to_reduce)));
  });
}

// ── Multi-value bootstrapping ───────────────────────────

[[cpp11::register]]
SEXP EvalMVBPrecompute__(SEXP ct_xp, SEXP coeffs, int digit_bit_size,
                         std::string initial_scaling, int order) {
  xptr<Ciphertext<DCRTPoly>> ct(ct_xp);
  return catch_openfhe("CryptoContext::EvalMVBPrecompute", [&]() {
    auto cc = (*ct)->GetCryptoContext();
    ConstCiphertext<DCRTPoly> cct = *ct;
    auto is = wide_from_r<BigInteger>(initial_scaling, "initial_scaling");
    SeriesPowersSP res = with_lut_coefficients(coeffs, [&](const auto& v) {
      return cc->EvalMVBPrecompute(cct, v, static_cast<uint32_t>(digit_bit_size),
                                   is, static_cast<size_t>(order));
    });
    return powers_out(res);
  });
}

[[cpp11::register]]
SEXP EvalMVB__(SEXP powers_xp, SEXP coeffs, int digit_bit_size,
               std::string post_scaling, int level_to_reduce, int order) {
  xptr<SeriesPowersSP> powers(powers_xp);
  return catch_openfhe("CryptoContext::EvalMVB", [&]() {
    auto cc = series_powers_context(*powers);
    uint64_t ps = uint64_from_r(post_scaling, "post_scaling");
    Ciphertext<DCRTPoly> res = with_lut_coefficients(coeffs, [&](const auto& v) {
      return cc->EvalMVB(*powers, v, static_cast<uint32_t>(digit_bit_size), ps,
                         static_cast<uint32_t>(level_to_reduce),
                         static_cast<size_t>(order));
    });
    return ct_out(res);
  });
}

[[cpp11::register]]
SEXP EvalMVBNoDecoding__(SEXP powers_xp, SEXP coeffs, int digit_bit_size,
                         int order) {
  xptr<SeriesPowersSP> powers(powers_xp);
  return catch_openfhe("CryptoContext::EvalMVBNoDecoding", [&]() {
    auto cc = series_powers_context(*powers);
    Ciphertext<DCRTPoly> res = with_lut_coefficients(coeffs, [&](const auto& v) {
      return cc->EvalMVBNoDecoding(*powers, v,
                                   static_cast<uint32_t>(digit_bit_size),
                                   static_cast<size_t>(order));
    });
    return ct_out(res);
  });
}

// ── Hermite trigonometric series ────────────────────────

[[cpp11::register]]
SEXP EvalHermiteTrigSeries__(SEXP ct_xp, SEXP coefficients_cheb, double a,
                             double b, SEXP coefficients_herm, int precomp) {
  xptr<Ciphertext<DCRTPoly>> ct(ct_xp);
  return catch_openfhe("CryptoContext::EvalHermiteTrigSeries", [&]() {
    auto cc = (*ct)->GetCryptoContext();
    ConstCiphertext<DCRTPoly> cct = *ct;
    cvec cheb = complex_vector(coefficients_cheb, "coefficients_cheb");
    Ciphertext<DCRTPoly> res =
        with_lut_coefficients(coefficients_herm, [&](const auto& v) {
          return cc->EvalHermiteTrigSeries(cct, cheb, a, b, v,
                                           static_cast<size_t>(precomp));
        });
    return ct_out(res);
  });
}

// ── Functional bootstrapping of a Fourier series (FE) ───

[[cpp11::register]]
void EvalFEFuncBootstrapSetup__(SEXP cc_xp, integers level_budget, integers dim1,
                                int slots) {
  xptr<CC> cc(cc_xp);
  catch_openfhe("CryptoContext::EvalFEFuncBootstrapSetup", [&]() {
    (*cc)->EvalFEFuncBootstrapSetup(u32_vector(level_budget), u32_vector(dim1),
                                    static_cast<uint32_t>(slots));
    return true;
  });
}

[[cpp11::register]]
SEXP EvalFEFuncBootstrap__(SEXP ct_xp, SEXP coefficients) {
  xptr<Ciphertext<DCRTPoly>> ct(ct_xp);
  return catch_openfhe("CryptoContext::EvalFEFuncBootstrap", [&]() {
    auto cc = (*ct)->GetCryptoContext();
    ConstCiphertext<DCRTPoly> cct = *ct;
    return ct_out(cc->EvalFEFuncBootstrap(
        cct, complex_vector(coefficients, "coefficients")));
  });
}

[[cpp11::register]]
SEXP EvalFEFuncBootstrapPrecompute__(SEXP ct_xp, SEXP coefficients) {
  xptr<Ciphertext<DCRTPoly>> ct(ct_xp);
  return catch_openfhe("CryptoContext::EvalFEFuncBootstrapPrecompute", [&]() {
    auto cc = (*ct)->GetCryptoContext();
    ConstCiphertext<DCRTPoly> cct = *ct;
    return powers_out(cc->EvalFEFuncBootstrapPrecompute(
        cct, complex_vector(coefficients, "coefficients")));
  });
}

[[cpp11::register]]
SEXP EvalFEFuncBootstrapWithPrecomp__(SEXP powers_xp, SEXP coefficients) {
  xptr<SeriesPowersSP> powers(powers_xp);
  return catch_openfhe("CryptoContext::EvalFEFuncBootstrapWithPrecomp", [&]() {
    auto cc = series_powers_context(*powers);
    return ct_out(cc->EvalFEFuncBootstrapWithPrecomp(
        *powers, complex_vector(coefficients, "coefficients")));
  });
}

// ── Hermite coefficients of a look-up table ─────────────
//
// OpenFHE calls `func` in plain serial loops (core/lib/math/hermite.cpp),
// so the R function runs on the calling thread. An R error inside it
// comes back as cpp11's unwind exception, which catch_openfhe passes on
// untouched.
[[cpp11::register]]
SEXP GetHermiteTrigCoefficients__(cpp11::function func, int p, int order,
                                  double scale) {
  return catch_openfhe("GetHermiteTrigCoefficients", [&]() -> SEXP {
    std::function<int64_t(int64_t)> f = [&func](int64_t v) -> int64_t {
      return static_cast<int64_t>(
          std::llround(cpp11::as_cpp<double>(func(static_cast<double>(v)))));
    };
    cvec y = GetHermiteTrigCoefficients(f, static_cast<uint32_t>(p),
                                        static_cast<size_t>(order), scale);
    cpp11::sexp out(Rf_allocVector(CPLXSXP, static_cast<R_xlen_t>(y.size())));
    Rcomplex* q = ::COMPLEX(out);
    for (size_t i = 0; i < y.size(); ++i) {
      q[i].r = y[i].real();
      q[i].i = y[i].imag();
    }
    return out;
  });
}
