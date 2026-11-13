## OPENFHE PYTHON SOURCE: src/lib/bindings.cpp (EvalPowers, EvalChebyPolys, EvalPolyWithPrecomp, EvalChebyshevSeriesWithPrecomp, EvalBootstrapPrecompute, EvalBootstrapStCFirst), src/lib/pke/fbt.cpp (SeriesPowers)
##
## @openfhe-python: src/lib/bindings.cpp [FULL: EvalPowers, EvalChebyPolys, EvalPolyWithPrecomp, EvalChebyshevSeriesWithPrecomp, EvalBootstrapPrecompute, EvalBootstrapStCFirst]
library(openfhe.R)

## Skipped on CRAN: check time against the Windows budget (D022). Runs
## on GitHub Actions (which sets CI=true) and at home.
if (!at_home() && Sys.getenv("CI") != "true")
  exit_file("skipped on CRAN: check time (runs on CI and at_home)")

cc <- fhe_context("CKKS", multiplicative_depth = 6L, scaling_mod_size = 50L,
                  batch_size = 8L, features = Feature$ADVANCEDSHE)
keys <- key_gen(cc, eval_mult = TRUE)
x <- c(0.25, 0.5, 0.75, 1.0, -0.5, 0.1, -0.9, 0)
ct <- encrypt(keys@public, make_ckks_packed_plaintext(cc, x), cc = cc)
dec <- function(ct) {
  pt <- decrypt(ct, keys@secret, cc = cc)
  set_length(pt, length(x))
  get_real_packed_value(pt)
}
horner <- function(co, x) {
  vapply(x, function(u) sum(co * u^(seq_along(co) - 1L)), numeric(1))
}
cheb <- function(co, u) {
  k <- seq_along(co) - 1L
  vapply(u, function(z) sum(co * cos(k * acos(z))) - co[1] / 2, numeric(1))
}
tol <- 1e-6

# ══ EvalPowers / EvalPolyWithPrecomp ═════════════════════
## Paterson-Stockmeyer range (degree 7).
p <- c(1, 0.5, -0.25, 0.1, 0, 0.3, -0.2, 0.05)
q <- c(-0.5, 0, 0.75, 0, 0.2, 0, 0, 1)
pw <- eval_powers(ct, p)
expect_true(S7::S7_inherits(pw, SeriesPowers))
expect_equal(openfhe.R:::xptr_type(pw@ptr), "openfhe.R::SeriesPowers")
expect_equal(dec(eval_poly_with_precomp(pw, p)), horner(p, x), tolerance = tol)
## The same powers serve another polynomial of the same degree, and
## are left unchanged: p evaluates as before afterwards.
expect_equal(dec(eval_poly_with_precomp(pw, q)), horner(q, x), tolerance = tol)
expect_equal(dec(eval_poly_with_precomp(pw, p)), horner(p, x), tolerance = tol)
## It agrees with the one-step evaluator.
expect_equal(dec(eval_poly_with_precomp(pw, q)), dec(eval_poly(ct, q)),
             tolerance = tol)

## Linear range (degree 3).
p3 <- c(0.5, 1, -1, 2)
q3 <- c(-1, 0.25, 3, -0.5)
pw3 <- eval_powers(ct, p3)
expect_equal(dec(eval_poly_with_precomp(pw3, p3)), horner(p3, x), tolerance = tol)
expect_equal(dec(eval_poly_with_precomp(pw3, q3)), horner(q3, x), tolerance = tol)

## Integer coefficients are evaluated as integers.
pi7 <- c(1L, 2L, 0L, -1L, 0L, 1L, 0L, 1L)
expect_equal(dec(eval_poly_with_precomp(eval_powers(ct, pi7), pi7)),
             horner(pi7, x), tolerance = tol)

expect_true(any(grepl("SeriesPowers", capture.output(print(pw), type = "message"))) ||
            any(grepl("SeriesPowers", capture.output(print(pw)))))

# ══ EvalChebyPolys / EvalChebyshevSeriesWithPrecomp ══════
c7 <- c(0.4, -0.3, 0.2, 0.1, -0.05, 0.25, 0, 0.15)
d7 <- c(-1, 0.5, 0, 0.3, 0.2, 0, -0.1, 0.05)
cp <- eval_cheby_polys(ct, c7, -1, 1)
expect_true(S7::S7_inherits(cp, SeriesPowers))
expect_equal(dec(eval_chebyshev_series_with_precomp(cp, c7)), cheb(c7, x),
             tolerance = tol)
expect_equal(dec(eval_chebyshev_series_with_precomp(cp, d7)), cheb(d7, x),
             tolerance = tol)
expect_equal(dec(eval_chebyshev_series_with_precomp(cp, d7)),
             dec(eval_chebyshev(ct, d7, -1, 1)), tolerance = tol)

## a and b enter the precomputation: on [-2, 2] the series is
## evaluated at x / 2.
cp2 <- eval_cheby_polys(ct, c7, -2, 2)
expect_equal(dec(eval_chebyshev_series_with_precomp(cp2, c7)), cheb(c7, x / 2),
             tolerance = tol)

## Linear range (degree 3).
c3 <- c(0.5, 0.25, -0.5, 0.125)
cp3 <- eval_cheby_polys(ct, c3, -1, 1)
expect_equal(dec(eval_chebyshev_series_with_precomp(cp3, c3)), cheb(c3, x),
             tolerance = tol)

# ══ Argument checks ══════════════════════════════════════
expect_error(eval_powers(ct, numeric(0)), "non-empty")
expect_error(eval_powers(ct, "a"), "non-empty")
expect_error(eval_poly_with_precomp(ct, p), "SeriesPowers")
expect_error(eval_chebyshev_series_with_precomp(pw, c(1, NA)), "missing")
expect_error(eval_powers(keys@public, p), "Ciphertext")

# ══ EvalBootstrapPrecompute ══════════════════════════════
level_budget <- c(3L, 3L)
depth <- get_bootstrap_depth(level_budget, SecretKeyDist$UNIFORM_TERNARY)
new_boot_context <- function(first_mod_size) {
  fhe_context("CKKS",
    multiplicative_depth = depth + 2L,
    scaling_mod_size = 59L,
    first_mod_size = first_mod_size,
    ring_dim = 4096L,
    security_level = SecurityLevel$HEStd_NotSet,
    scaling_technique = ScalingTechnique$FLEXIBLEAUTO,
    features = c(Feature$ADVANCEDSHE, Feature$FHE))
}
slots <- 8L
y <- c(0.25, 0.5, 0.75, 1.0)
boot_value <- function(cb, kb, f) {
  ctb <- encrypt(kb@public, make_ckks_packed_plaintext(cb, y, slots = slots),
                 cc = cb)
  pt <- decrypt(f(ctb), kb@secret, cc = cb)
  set_length(pt, length(y))
  get_real_packed_value(pt)
}

cb <- new_boot_context(60L)
kb <- key_gen(cb, eval_mult = TRUE)
## Setup without the plaintexts, which are then computed separately.
## (Bootstrapping without them is not probed: at OpenFHE 1.6.1 the
## library dereferences a null pointer there; notes/upstream-defects.md
## L2.)
eval_bootstrap_setup(cb, level_budget, slots = slots, precompute = FALSE)
eval_bootstrap_key_gen(cb, kb@secret, slots)
expect_identical(eval_bootstrap_precompute(cb, slots), cb)
expect_equal(boot_value(cb, kb, eval_bootstrap), y, tolerance = 0.01)

# ══ EvalBootstrapStCFirst ════════════════════════════════
## (The call on a context with a regular setup is not probed: at
## OpenFHE 1.6.1 the library throws inside a parallel region there,
## which ends the process; notes/upstream-defects.md L3.)
cs <- new_boot_context(59L)
ks <- key_gen(cs, eval_mult = TRUE)
eval_bootstrap_setup(cs, level_budget, slots = slots, bt_slots_encoding = TRUE)
eval_bootstrap_key_gen(cs, ks@secret, slots)
expect_equal(boot_value(cs, ks, eval_bootstrap_stc_first), y, tolerance = 0.01)
## After such a setup eval_bootstrap() is the same computation.
expect_equal(boot_value(cs, ks, eval_bootstrap), y, tolerance = 0.01)
