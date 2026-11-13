## OPENFHE PYTHON SOURCE: src/lib/bindings.cpp (EvalAdd/EvalSub/EvalMult overloads)
##
## @openfhe-python: src/lib/bindings.cpp [FULL: operand-order and complex-scalar overloads of EvalAdd, EvalSub, EvalMult and their InPlace and Mutable forms]
##
## Every overload is checked against the value the operand order
## predicts. Subtraction is the perturbation: x - y and y - x differ,
## so a binding that drops the order fails.
library(openfhe.R)

tol <- 1e-6

# ── CKKS, real data ──────────────────────────────────────
cc <- fhe_context("CKKS", multiplicative_depth = 2L, scaling_mod_size = 50L,
                  batch_size = 8L)
kp <- key_gen(cc, eval_mult = TRUE)
x <- c(1.5, 2.5, 3.5, 4.5, 5.5, 6.5, 7.5, 8.5)
y <- c(0.5, 1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0)
enc <- function(v) encrypt(kp@public, make_ckks_packed_plaintext(cc, v), cc = cc)
dec <- function(ct) {
  pt <- decrypt(ct, kp@secret, cc = cc)
  set_length(pt, length(x))
  get_real_packed_value(pt)
}
pt_y <- make_ckks_packed_plaintext(cc, y)
ct_x <- enc(x)

## Plaintext first.
expect_equal(dec(eval_add(pt_y, ct_x)), y + x, tolerance = tol)
expect_equal(dec(eval_sub(pt_y, ct_x)), y - x, tolerance = tol)
expect_equal(dec(eval_sub(ct_x, pt_y)), x - y, tolerance = tol)
expect_equal(dec(eval_mult(pt_y, ct_x)), y * x, tolerance = tol)

## Scalar first.
expect_equal(dec(eval_add(2, ct_x)), 2 + x, tolerance = tol)
expect_equal(dec(eval_sub(2, ct_x)), 2 - x, tolerance = tol)
expect_equal(dec(eval_sub(ct_x, 2)), x - 2, tolerance = tol)
expect_equal(dec(eval_mult(2, ct_x)), 2 * x, tolerance = tol)
## The operators reach the same methods.
expect_equal(dec(2 - ct_x), 2 - x, tolerance = tol)

## In place, ciphertext first.
ct <- enc(x); r <- eval_add_in_place(ct, 2)
expect_identical(r, ct)
expect_equal(dec(ct), x + 2, tolerance = tol)
ct <- enc(x); eval_sub_in_place(ct, 2)
expect_equal(dec(ct), x - 2, tolerance = tol)
ct <- enc(x); eval_mult_in_place(ct, 2)
expect_equal(dec(ct), x * 2, tolerance = tol)
ct <- enc(x); eval_mult_in_place(ct, 3L)
expect_equal(dec(ct), x * 3, tolerance = tol)

## In place, scalar first: the ciphertext is modified and returned.
ct <- enc(x); r <- eval_add_in_place(2, ct)
expect_identical(r, ct)
expect_equal(dec(ct), 2 + x, tolerance = tol)
ct <- enc(x); eval_sub_in_place(2, ct)
expect_equal(dec(ct), 2 - x, tolerance = tol)
ct <- enc(x); eval_mult_in_place(2, ct)
expect_equal(dec(ct), 2 * x, tolerance = tol)

## In place, plaintext first.
ct <- enc(x); r <- eval_add_in_place(pt_y, ct)
expect_identical(r, ct)
expect_equal(dec(ct), y + x, tolerance = tol)
ct <- enc(x); eval_sub_in_place(pt_y, ct)
expect_equal(dec(ct), y - x, tolerance = tol)
ct <- enc(x); eval_sub_in_place(ct, pt_y)
expect_equal(dec(ct), x - y, tolerance = tol)

## Mutable, with a plaintext in either position.
expect_equal(dec(eval_add_mutable(enc(x), pt_y)), x + y, tolerance = tol)
expect_equal(dec(eval_add_mutable(pt_y, enc(x))), y + x, tolerance = tol)
expect_equal(dec(eval_sub_mutable(enc(x), pt_y)), x - y, tolerance = tol)
expect_equal(dec(eval_sub_mutable(pt_y, enc(x))), y - x, tolerance = tol)
expect_equal(dec(eval_mult_mutable(enc(x), pt_y)), x * y, tolerance = tol)
expect_equal(dec(eval_mult_mutable(pt_y, enc(x))), y * x, tolerance = tol)
expect_equal(dec(eval_sub_mutable(enc(x), enc(y))), x - y, tolerance = tol)

## Refused operands.
expect_error(eval_add_in_place(2, 3), "Ciphertext")
expect_error(eval_sub_in_place(pt_y, pt_y), "Ciphertext")
expect_error(eval_mult_in_place(ct_x, c(1, 2)), "single real or complex number")
expect_error(eval_mult_in_place(ct_x, "a"), "single real or complex number")
## (cli wraps long messages, so the patterns stay short.)
expect_error(eval_add_in_place(ct_x, NA_real_), "a Ciphertext, a Plaintext, or a single real")
expect_error(eval_add_mutable(pt_y, pt_y), "Ciphertext")
expect_error(eval_mult_mutable(ct_x, 2), "Ciphertext")

# ── CKKS, complex data ───────────────────────────────────
ccz <- fhe_context("CKKS", multiplicative_depth = 2L, scaling_mod_size = 50L,
                   batch_size = 8L, ckks_data_type = CKKSDataType$COMPLEX)
kpz <- key_gen(ccz, eval_mult = TRUE)
z <- c(1 + 2i, 3 + 4i, -1 - 1i, 0.5 + 0.5i, 0 + 1i, 1 + 0i, -2 + 0.5i,
       0.25 - 0.75i)
s <- 0.5 - 1.5i
encz <- function(v) encrypt(kpz@public, make_ckks_packed_plaintext(ccz, v), cc = ccz)
decz <- function(ct) {
  pt <- decrypt(ct, kpz@secret, cc = ccz)
  set_length(pt, length(z))
  get_complex_packed_value(pt)[seq_along(z)]
}
expect_cplx <- function(got, want) {
  expect_equal(Re(got), Re(want), tolerance = tol)
  expect_equal(Im(got), Im(want), tolerance = tol)
}
ct_z <- encz(z)

expect_cplx(decz(eval_add(ct_z, s)), z + s)
expect_cplx(decz(eval_add(s, ct_z)), s + z)
expect_cplx(decz(eval_sub(ct_z, s)), z - s)
expect_cplx(decz(eval_sub(s, ct_z)), s - z)
expect_cplx(decz(eval_mult(ct_z, s)), z * s)
expect_cplx(decz(eval_mult(s, ct_z)), s * z)
expect_cplx(decz(s * ct_z), s * z)

ct <- encz(z); eval_add_in_place(ct, s)
expect_cplx(decz(ct), z + s)
ct <- encz(z); eval_add_in_place(s, ct)
expect_cplx(decz(ct), s + z)
ct <- encz(z); eval_sub_in_place(ct, s)
expect_cplx(decz(ct), z - s)
ct <- encz(z); eval_sub_in_place(s, ct)
expect_cplx(decz(ct), s - z)
ct <- encz(z); eval_mult_in_place(ct, s)
expect_cplx(decz(ct), z * s)
ct <- encz(z); eval_mult_in_place(s, ct)
expect_cplx(decz(ct), s * z)

# ── BFV: plaintext-first forms are exact ─────────────────
ccb <- fhe_context("BFV", plaintext_modulus = 65537, multiplicative_depth = 2)
kpb <- key_gen(ccb, eval_mult = TRUE)
a <- c(1L, 2L, 3L, 4L)
b <- c(10L, 20L, 30L, 40L)
pt_b <- make_packed_plaintext(ccb, b)
encb <- function(v) encrypt(kpb@public, make_packed_plaintext(ccb, v), cc = ccb)
decb <- function(ct) {
  pt <- decrypt(ct, kpb@secret, cc = ccb)
  set_length(pt, length(a))
  as.integer(get_packed_value(pt))
}
expect_identical(decb(eval_add(pt_b, encb(a))), b + a)
expect_identical(decb(eval_sub(pt_b, encb(a))), b - a)
expect_identical(decb(eval_mult(pt_b, encb(a))), b * a)
ct <- encb(a); eval_sub_in_place(pt_b, ct)
expect_identical(decb(ct), b - a)
## OpenFHE declines the Mutable plaintext forms in BFV; its message
## reaches R.
expect_error(eval_sub_mutable(pt_b, encb(a)), "not supported in the BFV scheme")
