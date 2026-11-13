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
#' @param coefficients Vector of polynomial coefficients, constant
#'   term first. An integer, double or complex vector; OpenFHE
#'   evaluates each type with its own arithmetic (integer
#'   coefficients as exact 64-bit integers, complex coefficients for
#'   a context with `CKKSDataType$COMPLEX`).
#' @return A Ciphertext
#' @seealso [eval_poly_linear()], [eval_poly_ps()]
#' @export
eval_poly <- function(ct, coefficients) {
  .eval_series(.SERIES_POLY, ct, coefficients)
}

## Evaluator codes shared with src/pke_ckks_eval_poly.cpp.
.SERIES_POLY        <- 0L
.SERIES_POLY_LINEAR <- 1L
.SERIES_POLY_PS     <- 2L
.SERIES_CHEB        <- 3L
.SERIES_CHEB_LINEAR <- 4L
.SERIES_CHEB_PS     <- 5L

## Shared body of the six series evaluators. The coefficient vector
## goes through with its own type: integer, double or complex.
.eval_series <- function(which, ct, coefficients, a = 0, b = 0) {
  ok <- (is.numeric(coefficients) || is.complex(coefficients)) &&
    !is.object(coefficients) && length(coefficients) > 0L &&
    !anyNA(coefficients)
  if (!ok) {
    cli_abort(
      "{.arg coefficients} must be a non-empty integer, double or complex vector with no missing values.",
      call = rlang::caller_env())
  }
  ## >>> S7-FAST-NEW (RConsortium/S7#723): original
  ## Ciphertext(ptr = EvalSeries__(get_ptr(ct), which, coefficients,
  ##                               as.double(a), as.double(b)))
  ## <<< S7-FAST-NEW
  .fast_new(Ciphertext, EvalSeries__(get_ptr(ct), which, coefficients,
                                     as.double(a), as.double(b)))
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
#' @param coefficients Integer, double or complex vector of polynomial
#'   coefficients, as for [eval_poly()]
#' @return A Ciphertext
#' @seealso [eval_poly()], [eval_poly_ps()]
#' @export
eval_poly_linear <- function(ct, coefficients) {
  .eval_series(.SERIES_POLY_LINEAR, ct, coefficients)
}

#' Evaluate a polynomial via the Paterson-Stockmeyer method
#'
#' Forces the Paterson-Stockmeyer polynomial evaluator
#' regardless of degree. Efficient for high-degree polynomials
#' (fewer multiplications at the cost of more additions and a
#' deeper circuit); for degree < 5 prefer [eval_poly_linear()].
#'
#' @param ct A Ciphertext
#' @param coefficients Integer, double or complex vector of polynomial
#'   coefficients, as for [eval_poly()]
#' @return A Ciphertext
#' @seealso [eval_poly()], [eval_poly_linear()]
#' @export
eval_poly_ps <- function(ct, coefficients) {
  .eval_series(.SERIES_POLY_PS, ct, coefficients)
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
#' @param coefficients Integer, double or complex vector of Chebyshev
#'   coefficients. Each type is evaluated with its own arithmetic, as
#'   for [eval_poly()]. Pass whole-number coefficients as doubles
#'   (`c(1, 2, 3)`, not `c(1L, 2L, 3L)`): at OpenFHE 1.6.1 the
#'   Paterson-Stockmeyer evaluator, which this function uses from
#'   degree 5, returns wrong values for integer coefficients.
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
  .eval_series(.SERIES_CHEB, ct, coefficients, a, b)
}

#' Evaluate a Chebyshev series via the linear evaluator
#'
#' Forces the "linear" Chebyshev evaluator regardless of degree.
#' Shallower circuit depth than Paterson-Stockmeyer but uses
#' more multiplications at high degree.
#'
#' @param ct A Ciphertext
#' @param coefficients Integer, double or complex vector of Chebyshev
#'   coefficients, as for [eval_chebyshev()]
#' @param a Lower bound of the approximation interval
#' @param b Upper bound of the approximation interval
#' @return A Ciphertext
#' @seealso [eval_chebyshev()], [eval_chebyshev_ps()]
#' @export
eval_chebyshev_linear <- function(ct, coefficients, a, b) {
  .eval_series(.SERIES_CHEB_LINEAR, ct, coefficients, a, b)
}

#' Evaluate a Chebyshev series via the Paterson-Stockmeyer method
#'
#' Forces the Paterson-Stockmeyer Chebyshev evaluator regardless
#' of degree. Efficient for high-degree polynomials.
#'
#' @param ct A Ciphertext
#' @param coefficients Integer, double or complex vector of Chebyshev
#'   coefficients, as for [eval_chebyshev()]. Pass whole-number
#'   coefficients as doubles: at OpenFHE 1.6.1 this evaluator returns
#'   wrong values for integer coefficients.
#' @param a Lower bound of the approximation interval
#' @param b Upper bound of the approximation interval
#' @return A Ciphertext
#' @seealso [eval_chebyshev()], [eval_chebyshev_linear()]
#' @export
eval_chebyshev_ps <- function(ct, coefficients, a, b) {
  .eval_series(.SERIES_CHEB_PS, ct, coefficients, a, b)
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
  ## >>> S7-FAST-NEW (RConsortium/S7#723): original
  ## Ciphertext(ptr = EvalSin_(ct@ptr, a, b, as.integer(degree)))
  ## <<< S7-FAST-NEW
  .fast_new(Ciphertext, EvalSin_(ct@ptr, a, b, as.integer(degree)))
}

#' Evaluate cosine on a ciphertext
#' @inheritParams eval_sin
#' @return A [Ciphertext] holding the encrypted, slot-wise cosine of `ct`,
#'   approximated by a Chebyshev polynomial of the given `degree` on the
#'   interval `[a, b]`. Accuracy degrades outside that interval, and the
#'   result sits `ceiling(log2(degree)) + 1` levels below `ct`.
#' @export
eval_cos <- function(ct, a, b, degree) {
  ## >>> S7-FAST-NEW (RConsortium/S7#723): original
  ## Ciphertext(ptr = EvalCos_(ct@ptr, a, b, as.integer(degree)))
  ## <<< S7-FAST-NEW
  .fast_new(Ciphertext, EvalCos_(ct@ptr, a, b, as.integer(degree)))
}

#' Evaluate logistic function on a ciphertext
#' @inheritParams eval_sin
#' @return A [Ciphertext] holding the encrypted, slot-wise logistic function `1
#'   / (1 + exp(-x))` of `ct`, approximated by a Chebyshev polynomial of
#'   the given `degree` on the interval `[a, b]`. Accuracy degrades
#'   outside that interval, and the result sits `ceiling(log2(degree)) +
#'   1` levels below `ct`.
#' @export
eval_logistic <- function(ct, a, b, degree) {
  ## >>> S7-FAST-NEW (RConsortium/S7#723): original
  ## Ciphertext(ptr = EvalLogistic_(ct@ptr, a, b, as.integer(degree)))
  ## <<< S7-FAST-NEW
  .fast_new(Ciphertext, EvalLogistic_(ct@ptr, a, b, as.integer(degree)))
}

#' Evaluate division approximation on a ciphertext
#' @inheritParams eval_sin
#' @return A [Ciphertext] holding the encrypted, slot-wise reciprocal of `ct`,
#'   approximated by a Chebyshev polynomial of the given `degree` on the
#'   interval `[a, b]`. The interval must exclude zero, accuracy degrades
#'   outside it, and the result sits `ceiling(log2(degree)) + 1` levels
#'   below `ct`.
#' @export
eval_divide <- function(ct, a, b, degree) {
  ## >>> S7-FAST-NEW (RConsortium/S7#723): original
  ## Ciphertext(ptr = EvalDivide_(ct@ptr, a, b, as.integer(degree)))
  ## <<< S7-FAST-NEW
  .fast_new(Ciphertext, EvalDivide_(ct@ptr, a, b, as.integer(degree)))
}

#' Set up CKKS bootstrapping
#'
#' The multiplicative depth of `cc` must be at least
#' [get_bootstrap_depth()] for `level_budget`. At OpenFHE 1.6.1 the
#' library does not check this, and a setup with `precompute = TRUE`
#' on a shallower context ends the R session.
#'
#' @param cc A CryptoContext
#' @param level_budget Integer vector of length 2 (default: c(5, 4))
#' @param dim1 Integer vector of length 2 (default: c(0, 0))
#' @param slots Number of slots (default: 0 = automatic)
#' @param correction_factor Correction factor (default: 0)
#' @param precompute Logical; compute the encoding and decoding
#'   plaintexts of bootstrapping now (default: TRUE). With `FALSE`,
#'   call [eval_bootstrap_precompute()] before [eval_bootstrap()].
#' @param bt_slots_encoding Logical; controls whether the
#'   bootstrap precomputes with slot-count encoding (the
#'   `BTSlotsEncoding` tail argument on cryptocontext.h line
#'   3513). Default `FALSE` matching the C++ default.
#' @return Invisibly, the `cc` crypto context that was passed in. Called for
#'   its side effect: the linear transforms bootstrapping needs are
#'   precomputed and cached inside the C++ context. Call it before
#'   [eval_bootstrap_key_gen()].
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
#' @return Invisibly, the `cc` crypto context that was passed in. Called for
#'   its side effect: the rotation and evaluation keys bootstrapping
#'   needs are generated from `sk` and stored inside the C++ context,
#'   after which [eval_bootstrap()] can be called.
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
  ## >>> S7-FAST-NEW (RConsortium/S7#723): original
  ## Ciphertext(ptr = CryptoContext__EvalBootstrap(ct@ptr,
  ##   as.integer(num_iterations), as.integer(precision)))
  ## <<< S7-FAST-NEW
  .fast_new(Ciphertext, CryptoContext__EvalBootstrap(ct@ptr,
    as.integer(num_iterations), as.integer(precision)))
}

#' Get the required multiplicative depth for CKKS bootstrapping
#'
#' @param level_budget Integer vector of length 2
#' @param secret_key_dist Secret key distribution, an element of
#'   [SecretKeyDist] (default: `SecretKeyDist$UNIFORM_TERNARY`)
#' @param approx_mod_depth Optional integer: the depth of the Chebyshev
#'   interpolation of the approximate modular reduction. When given,
#'   the three-argument C++ form is called, which OpenFHE keeps for
#'   backward compatibility. `NULL` (default) calls the two-argument
#'   form, which derives that depth from `secret_key_dist`.
#' @return Integer: required depth
#' @export
get_bootstrap_depth <- function(level_budget,
                                secret_key_dist = SecretKeyDist$UNIFORM_TERNARY,
                                approx_mod_depth = NULL) {
  if (is.null(approx_mod_depth)) {
    FHECKKSRNS__GetBootstrapDepth(as.integer(level_budget),
                                  as.integer(secret_key_dist))
  } else {
    FHECKKSRNS__GetBootstrapDepth__approx(as.integer(approx_mod_depth),
                                          as.integer(level_budget),
                                          as.integer(secret_key_dist))
  }
}

# SecretKeyDist is defined in enums.R (from C++ headers)
