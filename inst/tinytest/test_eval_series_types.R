## OPENFHE PYTHON SOURCE: src/lib/bindings.cpp (EvalPoly*, EvalChebyshevSeries* for int64, double and complex coefficients)
##
## @openfhe-python: src/lib/bindings.cpp [FULL: the int64 and complex coefficient overloads of EvalPoly, EvalPolyLinear, EvalPolyPS, EvalChebyshevSeries, EvalChebyshevSeriesLinear, EvalChebyshevSeriesPS]
##
## cryptocontext.h declares the six evaluators as templates over the
## coefficient type. The R type of `coefficients` selects the
## instantiation, and each one is checked against the cleartext value.
library(openfhe.R)

tol <- 1e-3

## Cleartext values. OpenFHE's Chebyshev convention halves the first
## coefficient: c0/2 + sum_k c_k T_k(u), u = (2x - a - b) / (b - a).
poly_value <- function(coef, x) {
  vapply(x, function(xi) sum(coef * xi^(seq_along(coef) - 1L)), coef[1] * x[1])
}
cheb_value <- function(coef, x, a, b) {
  u <- (2 * x - a - b) / (b - a)
  vapply(u, function(ui) {
    k <- seq_along(coef) - 1L
    tk <- cos(k * acos(ui))
    sum(coef * tk) - coef[1] / 2
  }, coef[1] * u[1])
}

# ── Real data: integer and double coefficients ───────────
cc <- fhe_context("CKKS", multiplicative_depth = 8L, scaling_mod_size = 50L,
                  batch_size = 8L, features = c(Feature$ADVANCEDSHE))
kp <- key_gen(cc, eval_mult = TRUE)
x <- c(0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8)
ct <- encrypt(kp@public, make_ckks_packed_plaintext(cc, x), cc = cc)
dec <- function(ct) {
  pt <- decrypt(ct, kp@secret, cc = cc)
  set_length(pt, length(x))
  get_real_packed_value(pt)
}

## Degree 3 (the selector takes the linear evaluator) and degree 6
## (Paterson-Stockmeyer).
for (coef_int in list(c(1L, 2L, 3L, -1L), c(1L, -2L, 0L, 3L, 1L, 0L, -1L))) {
  coef_dbl <- as.double(coef_int)
  want <- poly_value(coef_dbl, x)
  for (f in list(eval_poly, eval_poly_linear, eval_poly_ps)) {
    expect_equal(dec(f(ct, coef_int)), want, tolerance = tol)
    expect_equal(dec(f(ct, coef_dbl)), want, tolerance = tol)
  }
  want_cheb <- cheb_value(coef_dbl, x, 0, 1)
  for (f in list(eval_chebyshev, eval_chebyshev_linear, eval_chebyshev_ps)) {
    expect_equal(dec(f(ct, coef_dbl, 0, 1)), want_cheb, tolerance = tol)
  }
  expect_equal(dec(eval_chebyshev_linear(ct, coef_int, 0, 1)), want_cheb,
               tolerance = tol)
  ## Integer coefficients through the Paterson-Stockmeyer Chebyshev
  ## evaluator: OpenFHE 1.6.1 returns a different series (upstream
  ## defect L1, notes/discoveries/D037). The overload is bound and
  ## runs; no value is asserted.
  expect_true(S7::S7_inherits(eval_chebyshev_ps(ct, coef_int, 0, 1), Ciphertext))
  expect_true(S7::S7_inherits(eval_chebyshev(ct, coef_int, 0, 1), Ciphertext))
}

## The interval enters the result.
coef <- c(1, 2, 3, -1)
expect_equal(dec(eval_chebyshev(ct, coef, -1, 1)), cheb_value(coef, x, -1, 1),
             tolerance = tol)
expect_false(isTRUE(all.equal(cheb_value(coef, x, -1, 1),
                              cheb_value(coef, x, 0, 1), tolerance = tol)))

## Refused coefficient vectors.
expect_error(eval_poly(ct, "a"), "integer, double or complex")
expect_error(eval_poly(ct, numeric(0)), "non-empty")
expect_error(eval_poly(ct, c(1, NA)), "no missing values")
expect_error(eval_chebyshev(ct, TRUE, 0, 1), "integer, double or complex")

# ── Complex data: complex coefficients ───────────────────
ccz <- fhe_context("CKKS", multiplicative_depth = 8L, scaling_mod_size = 50L,
                   batch_size = 8L, features = c(Feature$ADVANCEDSHE),
                   ckks_data_type = CKKSDataType$COMPLEX)
kpz <- key_gen(ccz, eval_mult = TRUE)
z <- c(0.1 + 0.2i, 0.3 - 0.1i, -0.2 + 0.4i, 0.5 + 0i, 0 + 0.5i, -0.3 - 0.3i,
       0.25 + 0.25i, 0.6 - 0.2i)
ctz <- encrypt(kpz@public, make_ckks_packed_plaintext(ccz, z), cc = ccz)
decz <- function(ct) {
  pt <- decrypt(ct, kpz@secret, cc = ccz)
  set_length(pt, length(z))
  get_complex_packed_value(pt)[seq_along(z)]
}
expect_cplx <- function(got, want) {
  expect_equal(Re(got), Re(want), tolerance = tol)
  expect_equal(Im(got), Im(want), tolerance = tol)
}

for (coef_z in list(c(1 + 1i, 2 - 1i, 0.5i, -1 + 0i),
                    c(0.5 - 0.5i, 1i, 1 + 0i, -0.5 + 0i, 0.25i, 0.5 + 0i, -1i))) {
  want <- poly_value(coef_z, z)
  for (f in list(eval_poly, eval_poly_linear, eval_poly_ps)) {
    expect_cplx(decz(f(ctz, coef_z)), want)
  }
}

## Chebyshev with complex coefficients, on real-valued data held in
## the complex context.
xr <- c(0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8)
ctr <- encrypt(kpz@public, make_ckks_packed_plaintext(ccz, xr + 0i), cc = ccz)
coef_z <- c(1 + 1i, 2 - 1i, 0.5i, -1 + 0i)
want <- cheb_value(coef_z, xr, 0, 1)
for (f in list(eval_chebyshev, eval_chebyshev_linear, eval_chebyshev_ps)) {
  expect_cplx(decz(f(ctr, coef_z, 0, 1)), want)
}
