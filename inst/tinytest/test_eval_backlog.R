## OPENFHE PYTHON SOURCE: src/lib/bindings.cpp (evaluation methods bound at OpenFHE 1.6.1)
##
## @openfhe-python: src/lib/bindings.cpp [FULL: EvalAddMany, EvalAddManyInPlace, EvalMultMany, EvalMerge, EvalLinearWSum, EvalLinearWSumMutable, EvalInnerProduct, EvalSumRows, EvalSumCols, EvalSumRowsKeyGen, EvalSumColsKeyGen, EvalAtIndex, ReKeyGen, ReEncrypt, MakeStringPlaintext, EvalSquareInPlace, RescaleInPlace, RelinearizeInPlace, EvalAddMutableInPlace, EvalSubMutableInPlace, EvalMultMutableInPlace, EvalAddInPlaceNoCheck, EvalMultNoCheck, EvalMultNoRelinNoCheck, ComposedEvalMult, EvalMultKeysGen]
##
## Every method is checked against the cleartext value, and every
## optional argument is perturbed.
library(openfhe.R)

tol <- 1e-6

# ══ BFV: exact arithmetic ════════════════════════════════
cb <- fhe_context("BFV", plaintext_modulus = 65537, multiplicative_depth = 3,
                  max_relin_sk_deg = 3L,
                  features = c(Feature$ADVANCEDSHE, Feature$PRE))
kb <- key_gen(cb, eval_mult = TRUE)
encb <- function(v) encrypt(kb@public, make_packed_plaintext(cb, v), cc = cb)
decb <- function(ct, n = 6L, sk = kb@secret) {
  pt <- decrypt(ct, sk, cc = cb)
  set_length(pt, n)
  as.integer(get_packed_value(pt))
}
a <- 1:6
b <- c(2L, 0L, 1L, 3L, 1L, 2L)
d <- c(1L, 1L, 2L, 1L, 3L, 1L)

# ── eval_add_many / eval_add_many_in_place / eval_mult_many ──
expect_identical(decb(eval_add_many(list(encb(a), encb(b), encb(d)))), a + b + d)
expect_identical(decb(eval_add_many(list(encb(a)))), a)
expect_identical(decb(eval_mult_many(list(encb(a), encb(b), encb(d), encb(b)))),
                 a * b * d * b)

cts <- list(encb(a), encb(b), encb(d))
total <- eval_add_many_in_place(cts)
expect_identical(decb(total), a + b + d)
## The given ciphertexts hold the intermediate results: the first one
## the total.
expect_identical(decb(cts[[1]]), a + b + d)

expect_error(eval_add_many(list()), "non-empty list")
expect_error(eval_add_many(encb(a)), "non-empty list")
expect_error(eval_mult_many(list(encb(a), kb@public)), "non-empty list")

# ── eval_at_index ────────────────────────────────────────
eval_at_index_key_gen(cb, kb@secret, c(1L, -1L, -2L))
ct_a <- encb(a)
expect_identical(decb(eval_at_index(ct_a, 1L)), c(a[-1], 0L))
expect_identical(decb(eval_at_index(ct_a, -1L)), c(0L, a[-6]))
expect_identical(decb(eval_at_index(ct_a, 1L)), decb(eval_rotate(ct_a, 1L)))
## No key was generated for index 3.
expect_error(eval_at_index(ct_a, 3L))

# ── eval_merge ───────────────────────────────────────────
firsts <- c(7L, 8L, 9L)
merged <- eval_merge(lapply(firsts, function(v) encb(c(v, 0L, 0L, 0L))))
expect_identical(decb(merged), c(firsts, 0L, 0L, 0L))

# ── eval_inner_product: (ct, ct) and (ct, pt) ────────────
eval_sum_key_gen(cb, kb@secret)
n_slots <- 8L
expect_identical(decb(eval_inner_product(encb(a), encb(b), n_slots), 1L),
                 sum(a * b))
expect_identical(
  decb(eval_inner_product(encb(a), make_packed_plaintext(cb, d), n_slots), 1L),
  sum(a * d))
## batch_size bounds the slots that are summed.
expect_identical(decb(eval_inner_product(encb(a), encb(b), 2L), 1L),
                 sum((a * b)[1:2]))
expect_error(eval_inner_product(encb(a), 3, 8L), "Ciphertext.*Plaintext")

# ── In place: square, relinearize ────────────────────────
ct <- encb(a)
r <- eval_square_in_place(ct)
expect_identical(r, ct)
expect_identical(decb(ct), a * a)

ct3 <- eval_mult_no_relin(encb(a), encb(b))
r <- relinearize_in_place(ct3)
expect_identical(r, ct3)
expect_identical(decb(ct3), a * b)

# ── Unchecked forms ──────────────────────────────────────
ct <- encb(a)
r <- eval_add_in_place_no_check(ct, encb(b))
expect_identical(r, ct)
expect_identical(decb(ct), a + b)

expect_identical(decb(eval_mult_no_check(encb(a), 3)), 3L * a)
expect_identical(decb(eval_mult_no_check(encb(a), "5")), 5L * a)
expect_error(eval_mult_no_check(encb(a), -1), "non-negative whole number")
## eval_mult_no_relin_no_check() is the bare tensor product of the
## ciphertext elements; it is checked in the CKKS section below. BFV
## multiplication has a scaling step that it does not perform.

# ── eval_mult_keys_gen: keys for higher powers of the secret ──
## A product of three ciphertexts without relinearization has four
## elements and needs the key for the cube of the secret key. A second
## key pair on the same context has only the key for the square.
triple <- function(k) {
  e <- function(v) encrypt(k@public, make_packed_plaintext(cb, v), cc = cb)
  eval_mult_no_relin(eval_mult_no_relin(e(a), e(b)), e(d))
}
k2 <- key_gen(cb)
eval_mult_key_gen(cb, k2@secret)
expect_error(relinearize(triple(k2)), "maxRelinSkDeg")
k3 <- key_gen(cb)
eval_mult_keys_gen(cb, k3@secret)
expect_identical(decb(relinearize(triple(k3)), sk = k3@secret), a * b * d)

# ── Proxy re-encryption ──────────────────────────────────
alice <- kb
bob <- key_gen(cb)
ct_alice <- encb(a)
rk <- re_key_gen(cb, alice@secret, bob@public)
expect_true(S7::S7_inherits(rk, EvalKey))
ct_bob <- re_encrypt(ct_alice, rk)
expect_identical(decb(ct_bob, sk = bob@secret), a)
## Bob's key does not open Alice's ciphertext.
expect_false(identical(decb(ct_alice, sk = bob@secret), a))
## With the public key of the current holder supplied.
ct_bob2 <- re_encrypt(ct_alice, rk, public_key = alice@public)
expect_identical(decb(ct_bob2, sk = bob@secret), a)
expect_error(re_encrypt(ct_alice, bob@public), "EvalKey")

# ── make_string_plaintext ────────────────────────────────
cs <- fhe_context("BFV", plaintext_modulus = 256, multiplicative_depth = 1)
ks <- key_gen(cs)
msg <- "Hello, OpenFHE"
pt_s <- make_string_plaintext(cs, msg)
expect_identical(get_string_value(pt_s), msg)
dec_s <- decrypt(encrypt(ks@public, pt_s, cc = cs), ks@secret, cc = cs)
expect_identical(get_string_value(dec_s), msg)
## A different string gives a different plaintext.
expect_identical(get_string_value(make_string_plaintext(cs, "abc")), "abc")
expect_error(make_string_plaintext(cs, c("a", "b")), "single character string")
expect_error(make_string_plaintext(cs, 1), "single character string")

# ══ CKKS ═════════════════════════════════════════════════
cc <- fhe_context("CKKS", multiplicative_depth = 3L, scaling_mod_size = 50L,
                  batch_size = 16L,
                  scaling_technique = ScalingTechnique$FIXEDMANUAL,
                  features = c(Feature$ADVANCEDSHE))
kp <- key_gen(cc, eval_mult = TRUE)
x <- c(0.5, 1, 1.5, 2, 2.5, 3, 3.5, 4)
y <- c(1, -1, 0.5, 0.25, 2, -2, 1, 0)
z <- c(0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8)
enc <- function(v) encrypt(kp@public, make_ckks_packed_plaintext(cc, v), cc = cc)
dec <- function(ct, n = length(x)) {
  pt <- decrypt(ct, kp@secret, cc = cc)
  set_length(pt, n)
  get_real_packed_value(pt)
}

# ── eval_linear_wsum / eval_linear_wsum_mutable ──────────
w <- c(0.5, 2, -1)
expect_equal(dec(eval_linear_wsum(list(enc(x), enc(y), enc(z)), w)),
             w[1] * x + w[2] * y + w[3] * z, tolerance = tol)
wi <- c(2L, -1L, 3L)
expect_equal(dec(eval_linear_wsum(list(enc(x), enc(y), enc(z)), wi)),
             wi[1] * x + wi[2] * y + wi[3] * z, tolerance = tol)
## The constants come first in the mutable form, as in C++.
expect_equal(dec(eval_linear_wsum_mutable(w, list(enc(x), enc(y), enc(z)))),
             w[1] * x + w[2] * y + w[3] * z, tolerance = tol)
expect_error(eval_linear_wsum(list(enc(x), enc(y)), w), "3 elements")
expect_error(eval_linear_wsum(list(enc(x)), "a"), "integer, double or complex")

# ── In place: rescale; mutable in place; composed mult ───
p <- eval_mult(enc(x), enc(y))
lvl <- get_level(p)
r <- rescale_in_place(p)
expect_identical(r, p)
expect_identical(get_level(p), lvl + 1L)
expect_equal(dec(p), x * y, tolerance = tol)

c1 <- enc(x); r <- eval_add_mutable_in_place(c1, enc(y))
expect_identical(r, c1)
expect_equal(dec(c1), x + y, tolerance = tol)
c1 <- enc(x); eval_sub_mutable_in_place(c1, enc(y))
expect_equal(dec(c1), x - y, tolerance = tol)
c1 <- enc(x); eval_mult_mutable_in_place(c1, enc(y))
expect_equal(dec(c1), x * y, tolerance = tol)

## The unchecked product of two fresh ciphertexts (same level, same
## scale), relinearized, is the product.
expect_equal(dec(relinearize(eval_mult_no_relin_no_check(enc(x), enc(y)))),
             x * y, tolerance = tol)

## ComposedEvalMult multiplies and drops one level.
cm <- composed_eval_mult(enc(x), enc(y))
expect_identical(get_level(cm), 1L)
expect_equal(dec(cm), x * y, tolerance = tol)

# ── eval_sum_rows / eval_sum_cols ────────────────────────
## A 4 x 4 matrix packed row by row into the 16 slots.
m <- matrix(as.double(1:16), 4, 4, byrow = TRUE)
ct_m <- enc(as.double(t(m)))
## The subring of dimension 64 has the 16 slots the matrix fills.
rows_keys <- eval_sum_rows_key_gen(cc, kp@secret, row_size = 4L,
                                   subring_dim = 64L)
cols_keys <- eval_sum_cols_key_gen(cc, kp@secret)
expect_true(S7::S7_inherits(rows_keys, EvalKeyMap))
expect_true(S7::S7_inherits(cols_keys, EvalKeyMap))

## Summing the rows leaves the column totals in every row.
sr <- dec(eval_sum_rows(ct_m, 4L, rows_keys, subring_dim = 64L), 16L)
expect_equal(sr, rep(colSums(m), 4L), tolerance = tol)
## Summing the columns leaves each row total across its row.
sc <- dec(eval_sum_cols(ct_m, 4L, cols_keys), 16L)
expect_equal(sc, rep(rowSums(m), each = 4L), tolerance = tol)

## subring_dim enters the result: half the subring sums half the rows.
rows_keys_32 <- eval_sum_rows_key_gen(cc, kp@secret, row_size = 4L,
                                      subring_dim = 32L)
sr32 <- dec(eval_sum_rows(ct_m, 4L, rows_keys_32, subring_dim = 32L), 16L)
expect_false(isTRUE(all.equal(sr32, sr, tolerance = tol)))
## The form that takes the public key gives the same sums.
rows_keys_pk <- eval_sum_rows_key_gen(cc, kp@secret, kp@public, row_size = 4L,
                                      subring_dim = 64L)
expect_equal(dec(eval_sum_rows(ct_m, 4L, rows_keys_pk, subring_dim = 64L), 16L),
             sr, tolerance = tol)
expect_error(eval_sum_rows(ct_m, 4L, kp@public), "EvalKeyMap")

# ══ CKKS, complex data: complex weights ══════════════════
ccz <- fhe_context("CKKS", multiplicative_depth = 2L, scaling_mod_size = 50L,
                   batch_size = 8L, ckks_data_type = CKKSDataType$COMPLEX,
                   features = c(Feature$ADVANCEDSHE))
kpz <- key_gen(ccz, eval_mult = TRUE)
z1 <-c(1 + 2i, 3 - 1i, 0.5i, -1 + 0i, 2 + 2i, 0 - 1i, 0.25 + 0i, 1 + 1i)
z2 <- c(0.5 + 0i, 1i, -1 - 1i, 2 + 0i, 0 + 0i, 1 - 2i, 3 + 0i, -0.5i)
encz <- function(v) encrypt(kpz@public, make_ckks_packed_plaintext(ccz, v), cc = ccz)
wz <- c(1 - 1i, 0.5 + 2i)
got <- {
  pt <- decrypt(eval_linear_wsum(list(encz(z1), encz(z2)), wz), kpz@secret, cc = ccz)
  set_length(pt, length(z1))
  get_complex_packed_value(pt)[seq_along(z1)]
}
want <- wz[1] * z1 + wz[2] * z2
expect_equal(Re(got), Re(want), tolerance = tol)
expect_equal(Im(got), Im(want), tolerance = tol)
