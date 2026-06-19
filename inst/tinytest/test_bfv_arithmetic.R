## Phase 2: BFV arithmetic tests
## @openfhe-python: simple-integers.py [FULL]
library(openfhe.R)

# ── Setup ────────────────────────────────────────────────
cc <- fhe_context("BFV", plaintext_modulus = 65537, multiplicative_depth = 2)
keys <- key_gen(cc, eval_mult = TRUE, rotations = c(1L, 2L, -1L, -2L))

x <- c(1L, 2L, 3L, 4L, 5L, 6L, 7L, 8L)
y <- c(10L, 20L, 30L, 40L, 50L, 60L, 70L, 80L)

pt_x <- make_packed_plaintext(cc, x)
pt_y <- make_packed_plaintext(cc, y)
ct_x <- encrypt(keys@public, pt_x, cc = cc)
ct_y <- encrypt(keys@public, pt_y, cc = cc)

get_result <- function(ct, n = 8L) {
  res <- decrypt(ct, keys@secret, cc = cc)
  set_length(res, n)
  get_packed_value(res)[1:n]
}

p <- 65537L

# ── ct + ct ──────────────────────────────────────────────
expect_identical(get_result(ct_x + ct_y), (x + y) %% p)

# ── ct - ct ──────────────────────────────────────────────
expect_identical(get_result(ct_y - ct_x), (y - x) %% p)

# ── ct * ct ──────────────────────────────────────────────
expect_identical(get_result(ct_x * ct_x), (x * x) %% p)

# ── ct + scalar ──────────────────────────────────────────
expect_identical(get_result(ct_x + 100L), (x + 100L) %% p)

# ── scalar + ct (commutativity) ──────────────────────────
expect_identical(get_result(100L + ct_x), (x + 100L) %% p)

# ── ct * scalar ──────────────────────────────────────────
expect_identical(get_result(ct_x * 3L), (x * 3L) %% p)

# ── scalar * ct ──────────────────────────────────────────
expect_identical(get_result(3L * ct_x), (x * 3L) %% p)

# ── unary negate ─────────────────────────────────────────
# OpenFHE returns signed values; -x mod p maps to -(x) in signed representation
expect_identical(get_result(-ct_x), -x)

# ── commutativity: ct_x + ct_y == ct_y + ct_x ───────────
expect_identical(get_result(ct_x + ct_y), get_result(ct_y + ct_x))

# ── selftest still passes ───────────────────────────────
expect_true(openfhe.R:::selftest_bfv())
