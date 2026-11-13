// OPENFHE PYTHON SOURCE: src/lib/bindings.cpp (EvalPoly / EvalPolyLinear / EvalPolyPS / EvalChebyshevSeries / EvalChebyshevSeriesLinear / EvalChebyshevSeriesPS / EvalPowers / EvalChebyPolys / EvalPolyWithPrecomp / EvalChebyshevSeriesWithPrecomp / EvalBootstrapPrecompute / EvalBootstrapStCFirst)
//
// The six series evaluators. cryptocontext.h declares each as a template
// over the coefficient type, and openfhe-python instantiates each for
// int64_t, double and std::complex<double>. One registered function
// covers the eighteen instantiations: `which` selects the evaluator and
// the R type of `coefficients` selects the coefficient type.
//
//   which: 0 EvalPoly            3 EvalChebyshevSeries
//          1 EvalPolyLinear      4 EvalChebyshevSeriesLinear
//          2 EvalPolyPS          5 EvalChebyshevSeriesPS
//
//   coefficients: integer -> int64_t, double -> double,
//                 complex -> std::complex<double>
//
// EvalPoly and EvalChebyshevSeries use OpenFHE's own selector (linear
// below degree 5, Paterson-Stockmeyer from there); the Linear and PS
// forms force the algorithm. `a` and `b` are read by the Chebyshev forms
// only.
#include "openfhe_cpp11.h"
#include "openfhe_helpers.h"

#include <complex>
#include <vector>

using namespace cpp11;

namespace {

template <typename T>
Ciphertext<DCRTPoly> eval_series(int which, ConstCiphertext<DCRTPoly>& ct,
                                 const std::vector<T>& coeffs, double a,
                                 double b) {
  auto cc = ct->GetCryptoContext();
  switch (which) {
    case 0: return cc->EvalPoly(ct, coeffs);
    case 1: return cc->EvalPolyLinear(ct, coeffs);
    case 2: return cc->EvalPolyPS(ct, coeffs);
    case 3: return cc->EvalChebyshevSeries(ct, coeffs, a, b);
    case 4: return cc->EvalChebyshevSeriesLinear(ct, coeffs, a, b);
    case 5: return cc->EvalChebyshevSeriesPS(ct, coeffs, a, b);
  }
  cpp11::stop("unknown series evaluator code %d", which);
}

using SeriesPowersSP = std::shared_ptr<seriesPowers<DCRTPoly>>;

// Call fn with the coefficient vector in the C++ type its R type
// selects.
template <typename Fn>
auto with_coefficients(SEXP coefficients, Fn&& fn) {
  const R_xlen_t n = Rf_xlength(coefficients);
  switch (TYPEOF(coefficients)) {
    case INTSXP: {
      std::vector<int64_t> v(n);
      const int* p = INTEGER(coefficients);
      for (R_xlen_t i = 0; i < n; ++i) v[i] = static_cast<int64_t>(p[i]);
      return fn(v);
    }
    case REALSXP: {
      const double* p = ::REAL(coefficients);
      std::vector<double> v(p, p + n);
      return fn(v);
    }
    case CPLXSXP: {
      std::vector<std::complex<double>> v(n);
      const Rcomplex* p = ::COMPLEX(coefficients);
      for (R_xlen_t i = 0; i < n; ++i)
        v[i] = std::complex<double>(p[i].r, p[i].i);
      return fn(v);
    }
  }
  cpp11::stop("`coefficients` must be an integer, double or complex vector");
}

}  // namespace

// ── Precomputed powers ──────────────────────────────────
//
// EvalPowers / EvalChebyPolys compute the powers (or Chebyshev
// polynomials) of a ciphertext once; EvalPolyWithPrecomp /
// EvalChebyshevSeriesWithPrecomp evaluate any number of series of the
// same degree from them. `chebyshev` selects the pair.

[[cpp11::register]]
SEXP EvalSeriesPowers__(SEXP ct_xp, bool chebyshev, SEXP coefficients,
                        double a, double b) {
  xptr<Ciphertext<DCRTPoly>> ct(ct_xp);
  return catch_openfhe("CryptoContext::Eval{Powers,ChebyPolys}", [&]() {
    auto cc = (*ct)->GetCryptoContext();
    ConstCiphertext<DCRTPoly> cct = *ct;
    SeriesPowersSP res = with_coefficients(coefficients, [&](const auto& v) {
      return chebyshev ? cc->EvalChebyPolys(cct, v, a, b)
                       : cc->EvalPowers(cct, v);
    });
    if (!res) cpp11::stop("the library returned no powers");
    return xptr<SeriesPowersSP>(new SeriesPowersSP(res));
  });
}

[[cpp11::register]]
SEXP EvalSeriesWithPrecomp__(SEXP powers_xp, bool chebyshev,
                             SEXP coefficients) {
  xptr<SeriesPowersSP> powers(powers_xp);
  return catch_openfhe(
      "CryptoContext::Eval{Poly,ChebyshevSeries}WithPrecomp", [&]() {
    const SeriesPowersSP& p = *powers;
    if (!p || p->powersRe.empty() || !p->powersRe[0])
      cpp11::stop("the SeriesPowers object holds no powers");
    auto cc = p->powersRe[0]->GetCryptoContext();
    Ciphertext<DCRTPoly> res = with_coefficients(coefficients, [&](const auto& v) {
      return chebyshev ? cc->EvalChebyshevSeriesWithPrecomp(p, v)
                       : cc->EvalPolyWithPrecomp(p, v);
    });
    return xptr<Ciphertext<DCRTPoly>>(new Ciphertext<DCRTPoly>(res));
  });
}

// Baby-step degree k, giant-step count m, and the number of
// ciphertexts held, for print().
[[cpp11::register]]
integers SeriesPowers__info(SEXP powers_xp) {
  xptr<SeriesPowersSP> powers(powers_xp);
  const SeriesPowersSP& p = *powers;
  writable::integers out(5);
  if (!p) cpp11::stop("null SeriesPowers handle");
  out[0] = static_cast<int>(p->k);
  out[1] = static_cast<int>(p->m);
  out[2] = static_cast<int>(p->powersRe.size());
  out[3] = static_cast<int>(p->powers2Re.size());
  out[4] = static_cast<int>(p->powersIm.size());
  return out;
}

// ── Bootstrapping: precomputation and the StC-first variant ──

[[cpp11::register]]
void EvalBootstrapPrecompute__(SEXP cc_xp, int slots) {
  xptr<CryptoContext<DCRTPoly>> cc(cc_xp);
  catch_openfhe("CryptoContext::EvalBootstrapPrecompute", [&]() {
    (*cc)->EvalBootstrapPrecompute(static_cast<uint32_t>(slots));
    return true;
  });
}

[[cpp11::register]]
SEXP EvalBootstrapStCFirst__(SEXP ct_xp, int num_iterations, int precision) {
  xptr<Ciphertext<DCRTPoly>> ct(ct_xp);
  return catch_openfhe("CryptoContext::EvalBootstrapStCFirst", [&]() {
    auto cc = (*ct)->GetCryptoContext();
    ConstCiphertext<DCRTPoly> cct = *ct;
    auto res = cc->EvalBootstrapStCFirst(
        cct, static_cast<uint32_t>(num_iterations),
        static_cast<uint32_t>(precision));
    return xptr<Ciphertext<DCRTPoly>>(new Ciphertext<DCRTPoly>(res));
  });
}

[[cpp11::register]]
SEXP EvalSeries__(SEXP ct_xp, int which, SEXP coefficients, double a,
                  double b) {
  xptr<Ciphertext<DCRTPoly>> ct(ct_xp);
  const R_xlen_t n = Rf_xlength(coefficients);
  return catch_openfhe("CryptoContext::Eval{Poly,ChebyshevSeries}", [&]() {
    Ciphertext<DCRTPoly> result;
    switch (TYPEOF(coefficients)) {
      case INTSXP: {
        std::vector<int64_t> v(n);
        const int* p = INTEGER(coefficients);
        for (R_xlen_t i = 0; i < n; ++i) v[i] = static_cast<int64_t>(p[i]);
        result = eval_series<int64_t>(which, *ct, v, a, b);
        break;
      }
      case REALSXP: {
        // ::REAL and ::COMPLEX: lbcrypto::CKKSDataType has members of
        // the same names.
        const double* p = ::REAL(coefficients);
        std::vector<double> v(p, p + n);
        result = eval_series<double>(which, *ct, v, a, b);
        break;
      }
      case CPLXSXP: {
        std::vector<std::complex<double>> v(n);
        const Rcomplex* p = ::COMPLEX(coefficients);
        for (R_xlen_t i = 0; i < n; ++i)
          v[i] = std::complex<double>(p[i].r, p[i].i);
        result = eval_series<std::complex<double>>(which, *ct, v, a, b);
        break;
      }
      default:
        cpp11::stop("`coefficients` must be an integer, double or complex vector");
    }
    return xptr<Ciphertext<DCRTPoly>>(new Ciphertext<DCRTPoly>(result));
  });
}
