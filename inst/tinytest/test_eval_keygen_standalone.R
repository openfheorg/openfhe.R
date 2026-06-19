## OPENFHE PYTHON SOURCE: src/lib/bindings.cpp (EvalMultKeyGen, EvalRotateKeyGen, EvalAtIndexKeyGen)
##
## Standalone-wrapper coverage for the three
## key-generation methods that the gap-matrix
## (notes/blocks/E-bindings-rewrite/gap-matrix.md rows 236, 368,
## 369) that originally landed only as folded helpers
## inside `key_gen(cc, eval_mult, rotations)`. The folded form
## creates a *new* keypair as a side effect; that is the wrong
## semantics for any threshold or multi-party flow that already
## holds a secret-key share. This file pins the standalone
## entry points so a future fold cannot silently re-introduce
## the gap.

library(openfhe.R)

## @openfhe-python: src/lib/bindings.cpp [FULL: standalone wrappers for EvalMultKeyGen / EvalRotateKeyGen / EvalAtIndexKeyGen]

cc <- fhe_context(scheme = "CKKS",
                  multiplicative_depth = 2L,
                  scaling_mod_size = 45L,
                  batch_size = 8L)

kp <- key_gen(cc)        # plain KeyGen, no folded eval-mult / rotations

# ── eval_mult_key_gen ──────────────────────────────────

## After the standalone call, ciphertext × ciphertext
## multiplication should succeed. Without it, EvalMult would
## throw because the relinearization key is missing.
eval_mult_key_gen(cc, kp@secret)

x <- c(1.5, 2.5, 3.5, 4.5, 5.5, 6.5, 7.5, 8.5)
pt_x <- make_ckks_packed_plaintext(cc, x)
ct_x <- encrypt(kp@public, pt_x, cc = cc)
## Use the explicit generic rather than the Ops `*` so the test
## is robust against Ops-dispatch state from earlier test files
## in the same run.
ct_xx <- eval_mult(ct_x, ct_x)
pt_out <- decrypt(ct_xx, kp@secret, cc = cc)
set_length(pt_out, 8L)
expect_equal(get_real_packed_value(pt_out)[1:8], x * x, tolerance = 1e-3)

# ── eval_rotate_key_gen ────────────────────────────────

eval_rotate_key_gen(cc, kp@secret, c(1L, 3L))

ct_rot1 <- eval_rotate(ct_x, 1L)
pt_rot1 <- decrypt(ct_rot1, kp@secret, cc = cc)
set_length(pt_rot1, 8L)
expected_1 <- x[((seq_len(8L) - 1L + 1L) %% 8L) + 1L]
expect_equal(get_real_packed_value(pt_rot1)[1:8], expected_1, tolerance = 1e-3)

ct_rot3 <- eval_rotate(ct_x, 3L)
pt_rot3 <- decrypt(ct_rot3, kp@secret, cc = cc)
set_length(pt_rot3, 8L)
expected_3 <- x[((seq_len(8L) - 1L + 3L) %% 8L) + 1L]
expect_equal(get_real_packed_value(pt_rot3)[1:8], expected_3, tolerance = 1e-3)

# ── eval_at_index_key_gen (functionally identical to eval_rotate_key_gen) ──

## Use a fresh context + keypair so we can confirm the at-index
## path independently registers rotation keys.
cc2 <- fhe_context(scheme = "CKKS",
                   multiplicative_depth = 2L,
                   scaling_mod_size = 45L,
                   batch_size = 8L)
kp2 <- key_gen(cc2)
eval_at_index_key_gen(cc2, kp2@secret, c(2L))

pt2 <- make_ckks_packed_plaintext(cc2, x)
ct2 <- encrypt(kp2@public, pt2, cc = cc2)
ct2_rot2 <- eval_rotate(ct2, 2L)
pt2_rot2 <- decrypt(ct2_rot2, kp2@secret, cc = cc2)
set_length(pt2_rot2, 8L)
expected_2 <- x[((seq_len(8L) - 1L + 2L) %% 8L) + 1L]
expect_equal(get_real_packed_value(pt2_rot2)[1:8], expected_2, tolerance = 1e-3)

# ── Surface assertions: the wrappers are exported with the right shape ──

expect_true(exists("eval_mult_key_gen", mode = "function"))
expect_identical(names(formals(eval_mult_key_gen)), c("cc", "sk"))

expect_true(exists("eval_rotate_key_gen", mode = "function"))
expect_identical(names(formals(eval_rotate_key_gen)),
                 c("cc", "sk", "index_list"))

expect_true(exists("eval_at_index_key_gen", mode = "function"))
expect_identical(names(formals(eval_at_index_key_gen)),
                 c("cc", "sk", "index_list"))
