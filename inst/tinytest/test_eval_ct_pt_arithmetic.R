## OPENFHE PYTHON SOURCE: src/lib/bindings.cpp (EvalMult/EvalSub ct×pt overloads)
##
## Ciphertext × plaintext multiplication and
## ciphertext - plaintext subtraction were missing from the
## openfhe-R cpp11 surface despite being present in both the
## C++ header (cryptocontext.h lines 2089, 2101 for EvalMult
## ct×pt) and openfhe-python (bindings.cpp lines 337, 341).
## Only `EvalAdd__ct_pt` was bound (out-of-place), with sub/mult
## limited to scalar/integer overloads at the cpp11 layer.
##
## The diagonal-encoded matrix-vector multiply pattern used in
## the homomorpheR threshold-similarity vignette needs ct × pt
## directly — encoding the diagonals as ciphertexts would
## require a fresh encryption per diagonal per query and would
## need ciphertext × ciphertext relinearization, both of which
## are wasteful when the diagonals are public-form
## plaintext-encoded site-private matrix entries. This test
## pins the new ct × pt and ct - pt out-of-place bindings.

library(openfhe.R)

## @openfhe-python: src/lib/bindings.cpp [FULL: EvalMult ct×pt + EvalSub ct×pt out-of-place]

cc <- fhe_context(scheme = "CKKS",
                  multiplicative_depth = 2L,
                  scaling_mod_size = 45L,
                  batch_size = 8L)
kp <- key_gen(cc, eval_mult = TRUE)

x <- c(1.5, 2.5, 3.5, 4.5, 5.5, 6.5, 7.5, 8.5)
y <- c(0.5, 1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0)

ct_x <- encrypt(kp@public, make_ckks_packed_plaintext(cc, x), cc = cc)
pt_y <- make_ckks_packed_plaintext(cc, y)

# ── eval_mult(ct, pt) ──────────────────────────────────

ct_xy <- eval_mult(ct_x, pt_y)
out_ct_pt <- decrypt(ct_xy, kp@secret, cc = cc)
set_length(out_ct_pt, 8L)
expect_equal(get_real_packed_value(out_ct_pt)[1:8], x * y, tolerance = 1e-3)

# ── eval_mult(pt, ct) — commutative reverse dispatch ──

ct_yx <- eval_mult(pt_y, ct_x)
out_pt_ct <- decrypt(ct_yx, kp@secret, cc = cc)
set_length(out_pt_ct, 8L)
expect_equal(get_real_packed_value(out_pt_ct)[1:8], x * y, tolerance = 1e-3)

# ── eval_sub(ct, pt) ──────────────────────────────────

ct_xmy <- eval_sub(ct_x, pt_y)
out_sub <- decrypt(ct_xmy, kp@secret, cc = cc)
set_length(out_sub, 8L)
expect_equal(get_real_packed_value(out_sub)[1:8], x - y, tolerance = 1e-3)

# ── Surface assertions ────────────────────────────────

expect_true(exists("EvalMult__ct_pt", mode = "function",
                   envir = asNamespace("openfhe.R")))
expect_true(exists("EvalSub__ct_pt", mode = "function",
                   envir = asNamespace("openfhe.R")))
