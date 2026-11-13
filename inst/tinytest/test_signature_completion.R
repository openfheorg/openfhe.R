## OPENFHE PYTHON SOURCE: src/lib/bindings.cpp, src/lib/binfhe_bindings.cpp (arguments and defaults completed for OpenFHE 1.6.1)
##
## @openfhe-python: src/lib/bindings.cpp [FULL: Compress and LevelReduce defaults and null key, GetBootstrapDepth three-argument form, MultipartyKeyGen secret-key-vector form, FindAutomorphismIndex with a negative index]
## @openfhe-python: src/lib/binfhe_bindings.cpp [FULL: EvalBinGate extended, EvalFloor default, LWECiphertext.GetLength]
##
## Each optional argument is perturbed and the output is required to
## move the way the C++ header says.
library(openfhe.R)

# ── Defaults are the header defaults ─────────────────────
expect_identical(formals(eval_floor)$roundbits, 0L)
expect_identical(formals(eval_bin_gate)$extended, FALSE)
expect_null(formals(get_bootstrap_depth)$approx_mod_depth)

# ── CKKS: compress, level_reduce ─────────────────────────
## FIXEDMANUAL: under the automatic scaling techniques LevelReduce
## leaves the ciphertext as it is.
cc <- fhe_context("CKKS", multiplicative_depth = 4L, scaling_mod_size = 50L,
                  batch_size = 8L,
                  scaling_technique = ScalingTechnique$FIXEDMANUAL)
kp <- key_gen(cc, eval_mult = TRUE)
x <- c(0.25, 0.5, 0.75, 1, 2, 3, 4, 5)
enc <- function() encrypt(kp@public, make_ckks_packed_plaintext(cc, x), cc = cc)
dec <- function(ct) {
  pt <- decrypt(ct, kp@secret, cc = cc)
  set_length(pt, length(x))
  get_real_packed_value(pt)
}
ct <- enc()
expect_identical(get_level(ct), 0L)

## compress(): towers_left defaults to 1, and each tower kept is one
## level fewer dropped.
c_default <- compress(ct)
c_one <- compress(ct, towers_left = 1L)
c_two <- compress(ct, towers_left = 2L)
expect_identical(get_level(c_default), get_level(c_one))
expect_identical(get_level(c_two), get_level(c_one) - 1L)
expect_equal(dec(c_two), x, tolerance = 1e-3)

## level_reduce() with the null key the RNS schemes expect.
lr1 <- level_reduce(ct, NULL)
lr2 <- level_reduce(ct, NULL, 2L)
expect_identical(get_level(lr1), 1L)
expect_identical(get_level(lr2), 2L)
expect_identical(get_level(ct), 0L)
expect_equal(dec(lr2), x, tolerance = 1e-6)

ct_ip <- enc()
r <- level_reduce_in_place(ct_ip, NULL, 2L)
expect_identical(r, ct_ip)
expect_identical(get_level(ct_ip), 2L)

## A handle of the wrong class is still refused.
expect_error(level_reduce(ct, kp@public), "EvalKey")

# ── get_bootstrap_depth(): two- and three-argument forms ─
lb <- c(4L, 4L)
d_uniform <- get_bootstrap_depth(lb, SecretKeyDist$UNIFORM_TERNARY)
d_sparse <- get_bootstrap_depth(lb, SecretKeyDist$SPARSE_TERNARY)
expect_true(d_uniform > d_sparse)
expect_identical(get_bootstrap_depth(lb), d_uniform)
## The supplied modular-reduction depth enters the result one for one.
d8 <- get_bootstrap_depth(lb, SecretKeyDist$UNIFORM_TERNARY, 8L)
d9 <- get_bootstrap_depth(lb, SecretKeyDist$UNIFORM_TERNARY, 9L)
expect_identical(d9 - d8, 1L)
expect_true(get_bootstrap_depth(lb, SecretKeyDist$SPARSE_TERNARY, 8L) < d8)

# ── find_automorphism_index(): signed rotation offsets ───
i_pos <- find_automorphism_index(cc, 1L)
i_neg <- find_automorphism_index(cc, -1L)
expect_true(i_pos != i_neg)
expect_identical(find_automorphism_indices(cc, c(-1L, 1L)), c(i_neg, i_pos))

# ── multiparty_key_gen(): secret-key-vector form ─────────
ccm <- fhe_context("BFV", plaintext_modulus = 65537, multiplicative_depth = 2,
                   features = c(Feature$MULTIPARTY))
kp1 <- key_gen(ccm)
kp2 <- multiparty_key_gen(ccm, kp1@public)
## The key pair of the summed secrets decrypts what the joint public
## key (the last party's) encrypted.
joint <- multiparty_key_gen(ccm, list(kp1@secret, kp2@secret))
expect_true(S7::S7_inherits(joint, KeyPair))
v <- c(1L, 2L, 3L, 4L, 5L, 6L, 7L, 8L)
ctm <- encrypt(kp2@public, make_packed_plaintext(ccm, v), cc = ccm)
ptm <- decrypt(ctm, joint@secret, cc = ccm)
set_length(ptm, length(v))
expect_identical(as.integer(get_packed_value(ptm)), v)
## One share alone does not.
pt1 <- decrypt(ctm, kp1@secret, cc = ccm)
set_length(pt1, length(v))
expect_false(identical(as.integer(get_packed_value(pt1)), v))

expect_error(multiparty_key_gen(ccm, list(kp1@secret, kp1@public)), "PrivateKey")
expect_error(multiparty_key_gen(ccm, list(kp1@secret), fresh = TRUE), "do not apply")
expect_error(multiparty_key_gen(ccm, list()), "empty")

# ── BinFHE: eval_bin_gate(extended = ) ───────────────────
ctx <- bin_fhe_context(BinFHEParamSet$TOY)
sk <- bin_key_gen(ctx)
bin_bt_key_gen(ctx, sk)
a <- bin_encrypt(ctx, sk, 1L)
b <- bin_encrypt(ctx, sk, 1L)
g <- eval_bin_gate(ctx, BinGate$AND, a, b)
g_ext <- eval_bin_gate(ctx, BinGate$AND, a, b, extended = TRUE)
expect_identical(bin_decrypt(ctx, sk, g), 1L)
## The extended result stays in the large dimension N.
expect_identical(get_length(g), get_length(a))
expect_true(get_length(g_ext) > get_length(g))

## Vector form.
c3 <- lapply(c(1L, 1L, 0L), function(m) bin_encrypt(ctx, sk, m))
m3 <- eval_bin_gate(ctx, BinGate$MAJORITY, c3)
m3_ext <- eval_bin_gate(ctx, BinGate$MAJORITY, c3, extended = TRUE)
expect_identical(bin_decrypt(ctx, sk, m3), 1L)
expect_true(get_length(m3_ext) > get_length(m3))
