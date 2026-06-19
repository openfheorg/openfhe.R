## @openfhe-python: function-evaluation.py [FULL]
##
## Mirrors the two sub-examples of function-evaluation.py:
##   1. eval_logistic_example — cc.EvalLogistic on [-4, 4] at degree 16
##   2. eval_function_example — cc.EvalChebyshevFunction(sqrt, ...) on [0, 10] at degree 50
##
## The Chebyshev-function helper in R is a thin composition of
## eval_chebyshev_coefficients() (a direct port of the upstream
## EvalChebyshevCoefficients routine) and the existing
## eval_chebyshev() wrapper for EvalChebyshevSeries, matching the
## upstream C++ CryptoContextImpl::EvalChebyshevFunction.

library(openfhe.R)

tol <- 0.05

## ── eval_logistic_example ──────────────────────────────────────
cc_log <- fhe_context("CKKS",
  multiplicative_depth = 6L,
  scaling_mod_size = 59L,
  first_mod_size = 60L,
  ring_dim = 1024L,
  security_level = SecurityLevel$HEStd_NotSet,
  features = c(Feature$ADVANCEDSHE)
)
keys_log <- key_gen(cc_log, eval_mult = TRUE)

input_log <- c(-4, -3, -2, -1, 0, 1, 2, 3, 4)
pt_log <- make_ckks_packed_plaintext(cc_log, input_log)
ct_log <- encrypt(keys_log@public, pt_log, cc = cc_log)

ct_logistic <- eval_logistic(ct_log, a = -4, b = 4, degree = 16L)
res_logistic <- decrypt(ct_logistic, keys_log@secret, cc = cc_log)
set_length(res_logistic, length(input_log))

expected_logistic <- 1 / (1 + exp(-input_log))
expect_equal(get_real_packed_value(res_logistic)[seq_along(input_log)],
             expected_logistic,
             tolerance = tol)

## ── eval_function_example: sqrt on [0, 10] ────────────────────
cc_fun <- fhe_context("CKKS",
  multiplicative_depth = 7L,
  scaling_mod_size = 50L,
  first_mod_size = 60L,
  ring_dim = 1024L,
  security_level = SecurityLevel$HEStd_NotSet,
  features = c(Feature$ADVANCEDSHE)
)
keys_fun <- key_gen(cc_fun, eval_mult = TRUE)

input_fun <- c(1, 2, 3, 4, 5, 6, 7, 8, 9)
pt_fun <- make_ckks_packed_plaintext(cc_fun, input_fun)
ct_fun <- encrypt(keys_fun@public, pt_fun, cc = cc_fun)

ct_sqrt <- eval_chebyshev_function(ct_fun, sqrt,
                                   a = 0, b = 10, degree = 50L)
res_sqrt <- decrypt(ct_sqrt, keys_fun@secret, cc = cc_fun)
set_length(res_sqrt, length(input_fun))

expected_sqrt <- sqrt(input_fun)
expect_equal(get_real_packed_value(res_sqrt)[seq_along(input_fun)],
             expected_sqrt,
             tolerance = tol)

## ── eval_chebyshev_coefficients sanity checks ─────────────────
## The coefficient vector must have length degree + 1 and the
## zeroth coefficient must not be halved (that is the convention
## EvalChebyshevSeries expects on input).
coeffs <- eval_chebyshev_coefficients(sqrt, a = 0, b = 10, degree = 50L)
expect_equal(length(coeffs), 51L)

## Cleartext reconstruction mirrors EvalChebyshevFunctionPtxt in
## openfhe-development/src/core/lib/math/chebyshev.cpp: the first
## coefficient is halved inside the reconstruction, the remaining
## Chebyshev polynomials are evaluated via the three-term
## recurrence T_{j+1}(x) = 2 x T_j(x) - T_{j-1}(x) on the mapped
## argument x = (2 t - a - b) / (b - a).
cleartext_chebyshev_series <- function(t, coeffs, a, b) {
  cs <- coeffs
  cs[1] <- cs[1] / 2
  scale_  <- 2 / (b - a)
  offset_ <- -(a + b) * scale_ / 2
  y  <- t * scale_ + offset_
  y2 <- 2 * y
  result <- cs[1] + cs[2] * y
  t_prev <- rep.int(1, length(y))
  t_curr <- y
  for (j in seq.int(3L, length(cs))) {
    t_next <- y2 * t_curr - t_prev
    t_prev <- t_curr
    t_curr <- t_next
    result <- result + cs[j] * t_next
  }
  result
}
expect_equal(cleartext_chebyshev_series(input_fun, coeffs, 0, 10),
             expected_sqrt,
             tolerance = 0.01)

## A second sanity check with a different function to confirm the
## coefficient routine is not accidentally specialized to sqrt.
coeffs_log <- eval_chebyshev_coefficients(
  function(x) 1 / (1 + exp(-x)),
  a = -4, b = 4, degree = 16L)
expect_equal(length(coeffs_log), 17L)
expect_equal(cleartext_chebyshev_series(input_log, coeffs_log, -4, 4),
             expected_logistic,
             tolerance = tol)
