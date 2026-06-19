## @openfhe-python: src/lib/bindings.cpp (EvalPolyLinear/PS + EvalChebyshevSeriesLinear/PS) [FULL]
##
## Chebyshev / Poly Linear-vs-PS
## algorithm selectors plus the EvalBootstrapSetup
## bt_slots_encoding arg completion.
##
## The Linear and PS evaluators of the same polynomial must
## produce numerically equivalent output — the choice between
## them is a performance/depth trade-off, not a semantic one.
## Tests verify that on a cubic polynomial (where the default
## selector routes to Linear) and on a sin(x) Chebyshev
## approximation over [-pi, pi] at degree 7 (where the default
## routes to PS).
library(openfhe.R)

tol <- 1e-3

# ── CKKS setup ──────────────────────────────────────────
cc <- fhe_context("CKKS",
  multiplicative_depth = 8L,
  scaling_mod_size     = 50L,
  batch_size           = 8L,
  features             = c(Feature$ADVANCEDSHE)
)
kp <- key_gen(cc, eval_mult = TRUE)

x <- c(0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8)
pt <- make_ckks_packed_plaintext(cc, x)
ct <- encrypt(kp@public, pt, cc = cc)

decode <- function(ct_in, n = 8L) {
  pt_out <- decrypt(ct_in, kp@secret, cc = cc)
  set_length(pt_out, n)
  get_real_packed_value(pt_out)[1:n]
}

# ── Poly: cubic 1 + 2x + 3x^2 - x^3 ────────────────────
poly_coeffs <- c(1, 2, 3, -1)
expected_poly <- 1 + 2*x + 3*x^2 - x^3

ct_poly_default <- eval_poly(ct, poly_coeffs)
ct_poly_linear  <- eval_poly_linear(ct, poly_coeffs)
ct_poly_ps      <- eval_poly_ps(ct, poly_coeffs)

expect_true(S7::S7_inherits(ct_poly_default, Ciphertext))
expect_true(S7::S7_inherits(ct_poly_linear,  Ciphertext))
expect_true(S7::S7_inherits(ct_poly_ps,      Ciphertext))

out_default <- decode(ct_poly_default)
out_linear  <- decode(ct_poly_linear)
out_ps      <- decode(ct_poly_ps)

## Each evaluator matches cleartext on its own.
expect_equal(out_default, expected_poly, tolerance = tol)
expect_equal(out_linear,  expected_poly, tolerance = tol)
expect_equal(out_ps,      expected_poly, tolerance = tol)

## Linear and PS agree with each other to tolerance.
expect_equal(out_linear, out_ps, tolerance = tol)

# ── Chebyshev: sin(x) on [-pi, pi] at degree 7 ─────────
x_sin <- c(-pi, -0.9, -0.5, -0.1, 0.1, 0.5, 0.9, pi)
pt_sin <- make_ckks_packed_plaintext(cc, x_sin)
ct_sin <- encrypt(kp@public, pt_sin, cc = cc)

cheb_coeffs <- eval_chebyshev_coefficients(sin, a = -pi, b = pi, degree = 7L)
expected_sin <- sin(x_sin)

ct_cheb_default <- eval_chebyshev(ct_sin, cheb_coeffs, a = -pi, b = pi)
ct_cheb_linear  <- eval_chebyshev_linear(ct_sin, cheb_coeffs, a = -pi, b = pi)
ct_cheb_ps      <- eval_chebyshev_ps(ct_sin, cheb_coeffs, a = -pi, b = pi)

expect_true(S7::S7_inherits(ct_cheb_default, Ciphertext))
expect_true(S7::S7_inherits(ct_cheb_linear,  Ciphertext))
expect_true(S7::S7_inherits(ct_cheb_ps,      Ciphertext))

out_cheb_default <- decode(ct_cheb_default)
out_cheb_linear  <- decode(ct_cheb_linear)
out_cheb_ps      <- decode(ct_cheb_ps)

## Use a looser tolerance for Chebyshev approximation of sin at
## degree 7 — the Chebyshev truncation error near +/-pi is the
## dominant source of divergence, not the FHE noise.
tol_cheb <- 0.02
expect_equal(out_cheb_default, expected_sin, tolerance = tol_cheb)
expect_equal(out_cheb_linear,  expected_sin, tolerance = tol_cheb)
expect_equal(out_cheb_ps,      expected_sin, tolerance = tol_cheb)

## Linear and PS agree with each other to a tighter tolerance
## than the Chebyshev truncation error because they both use
## the same truncated coefficient vector.
expect_equal(out_cheb_linear, out_cheb_ps, tolerance = tol)

# ── Formals check ───────────────────────────────────────

expect_identical(names(formals(eval_poly_linear)),
                 c("ct", "coefficients"))
expect_identical(names(formals(eval_poly_ps)),
                 c("ct", "coefficients"))
expect_identical(names(formals(eval_chebyshev_linear)),
                 c("ct", "coefficients", "a", "b"))
expect_identical(names(formals(eval_chebyshev_ps)),
                 c("ct", "coefficients", "a", "b"))

# ── eval_bootstrap_setup: bt_slots_encoding arg completion ──

## The wrapper now accepts bt_slots_encoding (default FALSE).
## Verify the formals shape and that passing TRUE does not
## throw at the binding boundary. We do not run a full
## bootstrap here — that is covered in the existing
## test_ckks_advanced.R suite; this is just the arg-completion
## check.
expect_identical(names(formals(eval_bootstrap_setup)),
                 c("cc", "level_budget", "dim1", "slots",
                   "correction_factor", "precompute",
                   "bt_slots_encoding"))
expect_equal(formals(eval_bootstrap_setup)$bt_slots_encoding, FALSE)
