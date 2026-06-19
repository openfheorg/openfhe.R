## OPENFHE PYTHON SOURCE: src/lib/bindings.cpp (CKKS-specific operations)

#' Evaluate a polynomial on a ciphertext
#'
#' Evaluates p(x) = c0 + c1*x + c2*x^2 + ... on encrypted x.
#' Uses OpenFHE's default algorithm selector, which routes to
#' `eval_poly_linear()` for degree < 5 and `eval_poly_ps()`
#' (Paterson-Stockmeyer) for higher degrees. Call the variants
#' directly to force one algorithm or the other — Linear is
#' shallower for low-degree polynomials; PS has fewer
#' multiplications for high-degree polynomials.
#'
#' @param ct A Ciphertext
#' @param coefficients Numeric vector of polynomial coefficients
#' @return A Ciphertext
#' @seealso [eval_poly_linear()], [eval_poly_ps()]
#' @export
eval_poly <- function(ct, coefficients) {
  Ciphertext(ptr = EvalPoly(ct@ptr, as.double(coefficients)))
}

#' Evaluate a polynomial via the linear evaluator
#'
#' Forces the "linear" Horner-style polynomial evaluator
#' regardless of degree. Shallower circuit depth than the
#' Paterson-Stockmeyer variant but uses more multiplications
#' at high degree. Cheaper for degree < 5; fall over to
#' [eval_poly_ps()] above that.
#'
#' @param ct A Ciphertext
#' @param coefficients Numeric vector of polynomial coefficients
#' @return A Ciphertext
#' @seealso [eval_poly()], [eval_poly_ps()]
#' @export
eval_poly_linear <- function(ct, coefficients) {
  Ciphertext(ptr = EvalPolyLinear__(ct@ptr, as.double(coefficients)))
}

#' Evaluate a polynomial via the Paterson-Stockmeyer method
#'
#' Forces the Paterson-Stockmeyer polynomial evaluator
#' regardless of degree. Efficient for high-degree polynomials
#' (fewer multiplications at the cost of more additions and a
#' deeper circuit); for degree < 5 prefer [eval_poly_linear()].
#'
#' @param ct A Ciphertext
#' @param coefficients Numeric vector of polynomial coefficients
#' @return A Ciphertext
#' @seealso [eval_poly()], [eval_poly_linear()]
#' @export
eval_poly_ps <- function(ct, coefficients) {
  Ciphertext(ptr = EvalPolyPS__(ct@ptr, as.double(coefficients)))
}

#' Evaluate a Chebyshev series on a ciphertext
#'
#' Uses OpenFHE's default algorithm selector, which routes to
#' `eval_chebyshev_linear()` for degree < 5 and
#' `eval_chebyshev_ps()` (Paterson-Stockmeyer) for higher
#' degrees. Call the variants directly to force one algorithm
#' or the other.
#'
#' @param ct A Ciphertext
#' @param coefficients Numeric vector of Chebyshev coefficients
#' @param a Lower bound of the approximation interval
#' @param b Upper bound of the approximation interval
#' @return A Ciphertext
#' @seealso [eval_chebyshev_coefficients()] and
#'   [eval_chebyshev_function()] for constructing the coefficient
#'   vector from a user-supplied function;
#'   [eval_chebyshev_linear()] / [eval_chebyshev_ps()] for
#'   forcing the algorithm.
#' @export
eval_chebyshev <- function(ct, coefficients, a, b) {
  Ciphertext(ptr = EvalChebyshevSeries(ct@ptr, as.double(coefficients), a, b))
}

#' Evaluate a Chebyshev series via the linear evaluator
#'
#' Forces the "linear" Chebyshev evaluator regardless of degree.
#' Shallower circuit depth than Paterson-Stockmeyer but uses
#' more multiplications at high degree.
#'
#' @param ct A Ciphertext
#' @param coefficients Numeric vector of Chebyshev coefficients
#' @param a Lower bound of the approximation interval
#' @param b Upper bound of the approximation interval
#' @return A Ciphertext
#' @seealso [eval_chebyshev()], [eval_chebyshev_ps()]
#' @export
eval_chebyshev_linear <- function(ct, coefficients, a, b) {
  Ciphertext(ptr = EvalChebyshevSeriesLinear__(
    ct@ptr, as.double(coefficients), a, b))
}

#' Evaluate a Chebyshev series via the Paterson-Stockmeyer method
#'
#' Forces the Paterson-Stockmeyer Chebyshev evaluator regardless
#' of degree. Efficient for high-degree polynomials.
#'
#' @param ct A Ciphertext
#' @param coefficients Numeric vector of Chebyshev coefficients
#' @param a Lower bound of the approximation interval
#' @param b Upper bound of the approximation interval
#' @return A Ciphertext
#' @seealso [eval_chebyshev()], [eval_chebyshev_linear()]
#' @export
eval_chebyshev_ps <- function(ct, coefficients, a, b) {
  Ciphertext(ptr = EvalChebyshevSeriesPS__(
    ct@ptr, as.double(coefficients), a, b))
}

#' Chebyshev coefficients for a real-valued function
#'
#' Computes the Chebyshev (first-kind) coefficients that approximate
#' a univariate function `func` on the interval \eqn{[a, b]} using the
#' discrete orthogonality formula at `degree + 1` Chebyshev nodes.
#' This is a direct port of the upstream routine
#' `EvalChebyshevCoefficients()` in
#' `core/lib/math/chebyshev.cpp` of openfhe-development, and the
#' returned vector is in exactly the form that
#' [eval_chebyshev()] (and the upstream `EvalChebyshevSeries`)
#' expect — the zeroth coefficient is not halved.
#'
#' @param func An R function taking a single numeric argument and
#'   returning a numeric scalar.
#' @param a Lower bound of the approximation interval.
#' @param b Upper bound of the approximation interval.
#' @param degree Chebyshev polynomial degree (must be >= 1).
#' @return Numeric vector of length `degree + 1`.
#' @seealso [eval_chebyshev()], [eval_chebyshev_function()].
#' @export
eval_chebyshev_coefficients <- function(func, a, b, degree) {
  if (!is.function(func)) {
    cli::cli_abort("{.arg func} must be a function.")
  }
  degree <- as.integer(degree)
  if (length(degree) != 1L || is.na(degree) || degree < 1L) {
    cli::cli_abort("{.arg degree} must be a positive integer.")
  }
  coeff_total <- degree + 1L
  b_minus_a <- 0.5 * (b - a)
  b_plus_a  <- 0.5 * (b + a)
  pi_by_deg <- pi / coeff_total

  ## Evaluate func at the Chebyshev nodes mapped into [a, b].
  idx_vec <- seq.int(0L, coeff_total - 1L)
  nodes <- cos(pi_by_deg * (idx_vec + 0.5)) * b_minus_a + b_plus_a
  function_points <- vapply(nodes,
                            function(xi) as.numeric(func(xi)),
                            numeric(1))

  ## Discrete orthogonality inner products. Mirrors the double
  ## loop in the upstream C++ routine; the outer index i runs over
  ## coefficients and the inner sum over the sample points.
  j_half <- idx_vec + 0.5
  coefficients <- vapply(idx_vec, function(i) {
    sum(function_points * cos(pi_by_deg * i * j_half))
  }, numeric(1))
  coefficients * (2 / coeff_total)
}

#' Evaluate a user-supplied function on a CKKS ciphertext via Chebyshev approximation
#'
#' Computes the Chebyshev coefficients for `func` on `[a, b]` via
#' [eval_chebyshev_coefficients()] and applies the resulting series
#' to `ct` via [eval_chebyshev()]. This mirrors the upstream
#' `CryptoContext::EvalChebyshevFunction` helper, which is a thin
#' wrapper around `EvalChebyshevCoefficients` followed by
#' `EvalChebyshevSeries` on the C++ side.
#'
#' @param ct A Ciphertext holding CKKS-encoded real values in
#'   `[a, b]`.
#' @param func An R function taking a single numeric argument and
#'   returning a numeric scalar. It is evaluated on cleartext
#'   Chebyshev nodes inside `[a, b]` to produce the approximating
#'   coefficients.
#' @param a Lower bound of the approximation interval.
#' @param b Upper bound of the approximation interval.
#' @param degree Chebyshev polynomial degree (must be >= 1).
#' @return A Ciphertext holding the elementwise approximation of
#'   `func` applied to the plaintext slots of `ct`.
#' @seealso [eval_chebyshev()], [eval_chebyshev_coefficients()],
#'   [eval_logistic()], [eval_sin()], [eval_cos()],
#'   [eval_divide()].
#' @export
eval_chebyshev_function <- function(ct, func, a, b, degree) {
  coefficients <- eval_chebyshev_coefficients(func, a, b, degree)
  eval_chebyshev(ct, coefficients, a, b)
}

#' Evaluate sine on a ciphertext (Chebyshev approximation)
#'
#' @param ct A Ciphertext
#' @param a Lower bound of the approximation interval
#' @param b Upper bound of the approximation interval
#' @param degree Chebyshev polynomial degree
#' @return A Ciphertext
#' @export
eval_sin <- function(ct, a, b, degree) {
  Ciphertext(ptr = EvalSin_(ct@ptr, a, b, as.integer(degree)))
}

#' Evaluate cosine on a ciphertext
#' @inheritParams eval_sin
#' @export
eval_cos <- function(ct, a, b, degree) {
  Ciphertext(ptr = EvalCos_(ct@ptr, a, b, as.integer(degree)))
}

#' Evaluate logistic function on a ciphertext
#' @inheritParams eval_sin
#' @export
eval_logistic <- function(ct, a, b, degree) {
  Ciphertext(ptr = EvalLogistic_(ct@ptr, a, b, as.integer(degree)))
}

#' Evaluate division approximation on a ciphertext
#' @inheritParams eval_sin
#' @export
eval_divide <- function(ct, a, b, degree) {
  Ciphertext(ptr = EvalDivide_(ct@ptr, a, b, as.integer(degree)))
}

#' Set up CKKS bootstrapping
#'
#' @param cc A CryptoContext
#' @param level_budget Integer vector of length 2 (default: c(5, 4))
#' @param dim1 Integer vector of length 2 (default: c(0, 0))
#' @param slots Number of slots (default: 0 = automatic)
#' @param correction_factor Correction factor (default: 0)
#' @param precompute Precompute rotation keys (default: TRUE)
#' @param bt_slots_encoding Logical; controls whether the
#'   bootstrap precomputes with slot-count encoding (the
#'   `BTSlotsEncoding` tail argument on cryptocontext.h line
#'   3513). Default `FALSE` matching the C++ default.
#' @export
eval_bootstrap_setup <- function(cc, level_budget = c(5L, 4L),
                                  dim1 = c(0L, 0L), slots = 0L,
                                  correction_factor = 0L,
                                  precompute = TRUE,
                                  bt_slots_encoding = FALSE) {
  CryptoContext__EvalBootstrapSetup(get_ptr(cc),
    as.integer(level_budget), as.integer(dim1),
    as.integer(slots), as.integer(correction_factor), precompute,
    as.logical(bt_slots_encoding))
  invisible(cc)
}

#' Generate bootstrapping keys
#'
#' @param cc A CryptoContext
#' @param sk A PrivateKey
#' @param slots Number of slots
#' @export
eval_bootstrap_key_gen <- function(cc, sk, slots) {
  CryptoContext__EvalBootstrapKeyGen(get_ptr(cc), get_ptr(sk), as.integer(slots))
  invisible(cc)
}

#' Perform CKKS bootstrapping
#'
#' Refreshes the ciphertext to allow further computation.
#' @param ct A Ciphertext
#' @param num_iterations Number of bootstrap iterations (default: 1)
#' @param precision Target precision (default: 0 = automatic)
#' @return A refreshed Ciphertext
#' @export
eval_bootstrap <- function(ct, num_iterations = 1L, precision = 0L) {
  Ciphertext(ptr = CryptoContext__EvalBootstrap(ct@ptr,
    as.integer(num_iterations), as.integer(precision)))
}

#' Get the required multiplicative depth for CKKS bootstrapping
#'
#' @param level_budget Integer vector of length 2
#' @param secret_key_dist Secret key distribution (default: UNIFORM_TERNARY = 1)
#' @return Integer: required depth
#' @export
get_bootstrap_depth <- function(level_budget, secret_key_dist = 1L) {
  FHECKKSRNS__GetBootstrapDepth(as.integer(level_budget), as.integer(secret_key_dist))
}

# SecretKeyDist is defined in enums.R (from C++ headers)
