// OPENFHE PYTHON SOURCE: src/lib/bindings.cpp (EvalPolyLinear / EvalPolyPS / EvalChebyshevSeriesLinear / EvalChebyshevSeriesPS)
//
// Chebyshev and Poly Linear-vs-PS
// selector variants. The existing EvalPoly / EvalChebyshevSeries
// bindings (pke_bindings.cpp ~lines 570 / 583) route to the
// scheme's default algorithm selector — "linear under degree 5,
// Paterson-Stockmeyer above". R users gain direct
// control over which algorithm runs: the Linear variant is
// cheaper on low-degree polynomials (smaller circuit depth), the
// PS variant is cheaper on high-degree polynomials (fewer
// multiplications via the Paterson-Stockmeyer scheme). The
// default form stays name-stable as `eval_poly` / `eval_chebyshev`
// so existing code (including the CKKS transcendental vignettes)
// continues to work unchanged.
//
// 4 new cpp11 bindings:
//   EvalPolyLinear__                (cryptocontext.h line 2754)
//   EvalPolyPS__                    (cryptocontext.h line 2769)
//   EvalChebyshevSeriesLinear__     (cryptocontext.h line 2837)
//   EvalChebyshevSeriesPS__         (cryptocontext.h line 2855)
//
// All four take the same argument shape as their default-selector
// siblings:
//   EvalPoly*:       (ciphertext, coefficients)
//   EvalChebyshev*:  (ciphertext, coefficients, a, b)
// and return a Ciphertext. Wrapped in catch_openfhe per §5.

#include "openfhe_cpp11.h"
#include "openfhe_helpers.h"
#include <vector>

using namespace cpp11;

// Helper: convert cpp11::doubles to std::vector<double>.
// Used by all four bindings to marshal the coefficient vector.
static std::vector<double> doubles_to_vec(doubles coeffs) {
  std::vector<double> out;
  out.reserve(coeffs.size());
  for (R_xlen_t i = 0; i < coeffs.size(); ++i) {
    out.push_back(coeffs[i]);
  }
  return out;
}

// ── Poly family ─────────────────────────────────────────

[[cpp11::register]]
SEXP EvalPolyLinear__(SEXP ct_xp, doubles coefficients) {
  external_pointer<Ciphertext<DCRTPoly>> ct(ct_xp);
  return catch_openfhe("CryptoContext::EvalPolyLinear", [&]() {
    auto cc = (*ct)->GetCryptoContext();
    auto result = cc->EvalPolyLinear(*ct, doubles_to_vec(coefficients));
    return external_pointer<Ciphertext<DCRTPoly>>(
      new Ciphertext<DCRTPoly>(result));
  });
}

[[cpp11::register]]
SEXP EvalPolyPS__(SEXP ct_xp, doubles coefficients) {
  external_pointer<Ciphertext<DCRTPoly>> ct(ct_xp);
  return catch_openfhe("CryptoContext::EvalPolyPS", [&]() {
    auto cc = (*ct)->GetCryptoContext();
    auto result = cc->EvalPolyPS(*ct, doubles_to_vec(coefficients));
    return external_pointer<Ciphertext<DCRTPoly>>(
      new Ciphertext<DCRTPoly>(result));
  });
}

// ── Chebyshev family ────────────────────────────────────

[[cpp11::register]]
SEXP EvalChebyshevSeriesLinear__(SEXP ct_xp, doubles coefficients,
                                 double a, double b) {
  external_pointer<Ciphertext<DCRTPoly>> ct(ct_xp);
  return catch_openfhe("CryptoContext::EvalChebyshevSeriesLinear", [&]() {
    auto cc = (*ct)->GetCryptoContext();
    auto result = cc->EvalChebyshevSeriesLinear(*ct, doubles_to_vec(coefficients),
                                                a, b);
    return external_pointer<Ciphertext<DCRTPoly>>(
      new Ciphertext<DCRTPoly>(result));
  });
}

[[cpp11::register]]
SEXP EvalChebyshevSeriesPS__(SEXP ct_xp, doubles coefficients,
                             double a, double b) {
  external_pointer<Ciphertext<DCRTPoly>> ct(ct_xp);
  return catch_openfhe("CryptoContext::EvalChebyshevSeriesPS", [&]() {
    auto cc = (*ct)->GetCryptoContext();
    auto result = cc->EvalChebyshevSeriesPS(*ct, doubles_to_vec(coefficients),
                                            a, b);
    return external_pointer<Ciphertext<DCRTPoly>>(
      new Ciphertext<DCRTPoly>(result));
  });
}
