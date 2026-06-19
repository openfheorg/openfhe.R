## Phase 4: CKKS real-number arithmetic tests
## @openfhe-python: simple-real-numbers.py [FULL]
library(openfhe.R)

# ── Setup ────────────────────────────────────────────────
cc <- fhe_context("CKKS",
  multiplicative_depth = 1L,
  scaling_mod_size = 50L,
  batch_size = 8L
)
keys <- key_gen(cc, eval_mult = TRUE, rotations = c(1L, -2L))

x <- c(0.25, 0.5, 0.75, 1.0, 2.0, 3.0, 4.0, 5.0)
y <- c(5.0, 4.0, 3.0, 2.0, 1.0, 0.75, 0.5, 0.25)

pt_x <- make_ckks_packed_plaintext(cc, x)
pt_y <- make_ckks_packed_plaintext(cc, y)
ct_x <- encrypt(keys@public, pt_x, cc = cc)
ct_y <- encrypt(keys@public, pt_y, cc = cc)

tol <- 1e-6  # CKKS tolerance

get_result <- function(ct, n = 8L) {
  res <- decrypt(ct, keys@secret, cc = cc)
  set_length(res, n)
  get_real_packed_value(res)[1:n]
}

# ── CKKS encrypt/decrypt round-trip ──────────────────────
expect_equal(get_result(ct_x), x, tolerance = tol)

# ── ct + ct ──────────────────────────────────────────────
expect_equal(get_result(ct_x + ct_y), x + y, tolerance = tol)

# ── ct - ct ──────────────────────────────────────────────
expect_equal(get_result(ct_x - ct_y), x - y, tolerance = tol)

# ── ct * ct (element-wise) ───────────────────────────────
expect_equal(get_result(ct_x * ct_y), x * y, tolerance = tol)

# ── ct + scalar ──────────────────────────────────────────
expect_equal(get_result(ct_x + 10.0), x + 10.0, tolerance = tol)

# ── scalar + ct ──────────────────────────────────────────
expect_equal(get_result(10.0 + ct_x), x + 10.0, tolerance = tol)

# ── ct * scalar ──────────────────────────────────────────
expect_equal(get_result(ct_x * 4.0), x * 4.0, tolerance = tol)

# ── scalar * ct ──────────────────────────────────────────
expect_equal(get_result(4.0 * ct_x), x * 4.0, tolerance = tol)

# ── unary negate ─────────────────────────────────────────
expect_equal(get_result(-ct_x), -x, tolerance = tol)

# ── commutativity ────────────────────────────────────────
expect_equal(get_result(ct_x + ct_y), get_result(ct_y + ct_x), tolerance = tol)
