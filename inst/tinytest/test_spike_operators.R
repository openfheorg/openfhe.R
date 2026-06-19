## Phase 0 spike: S7 operator dispatch validation
## Verifies that +, -, * and unary - dispatch correctly on Ciphertext objects
## before any C++ bindings are wired up.

library(openfhe.R)

# ── Stub methods for the spike ─────────────────────────
# These will be replaced by real C++ dispatched methods in Phase 1.
# For now they just confirm dispatch reaches the right place.

S7::method(eval_add, list(Ciphertext, Ciphertext)) <- function(x, y) {
  "add_ct_ct"
}

S7::method(eval_add, list(Ciphertext, S7::class_double)) <- function(x, y) {
  paste0("add_ct_scalar:", y)
}

S7::method(eval_add, list(S7::class_double, Ciphertext)) <- function(x, y) {
  paste0("add_scalar_ct:", x)
}

S7::method(eval_sub, list(Ciphertext, Ciphertext)) <- function(x, y) {
  "sub_ct_ct"
}

S7::method(eval_mult, list(Ciphertext, Ciphertext)) <- function(x, y) {
  "mult_ct_ct"
}

S7::method(eval_mult, list(Ciphertext, S7::class_double)) <- function(x, y) {
  paste0("mult_ct_scalar:", y)
}

S7::method(eval_mult, list(S7::class_double, Ciphertext)) <- function(x, y) {
  paste0("mult_scalar_ct:", x)
}

S7::method(eval_negate, Ciphertext) <- function(x) {
  "negate_ct"
}

# ── Tests ──────────────────────────────────────────────

ct1 <- Ciphertext()
ct2 <- Ciphertext()

# Binary operators dispatch through S3 Ops handler → S7 generics
expect_equal(ct1 + ct2, "add_ct_ct")
expect_equal(ct1 - ct2, "sub_ct_ct")
expect_equal(ct1 * ct2, "mult_ct_ct")

# Scalar dispatch (double + Ciphertext, Ciphertext + double)
expect_equal(ct1 + 3.0, "add_ct_scalar:3")
expect_equal(3.0 + ct1, "add_scalar_ct:3")
expect_equal(ct1 * 2.5, "mult_ct_scalar:2.5")
expect_equal(2.5 * ct1, "mult_scalar_ct:2.5")

# Unary negate (the CVXR-discovered pitfall)
expect_equal(-ct1, "negate_ct")

# Unary plus is identity
expect_true(S7::S7_inherits(+ct1, Ciphertext))

# print works
expect_silent(print(ct1))

# get_native_int returns 64 or 128
ni <- get_native_int()
expect_true(ni %in% c(64L, 128L))
