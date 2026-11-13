## OPENFHE PYTHON SOURCE: src/lib/bindings.cpp (key switching, key registry and module-level helpers bound at OpenFHE 1.6.1)
##
## @openfhe-python: src/lib/bindings.cpp [FULL: KeySwitchGen, KeySwitch, KeySwitchInPlace, KeySwitchExt, KeySwitchDownFirstElement, SparseKeyGen, MultiMultEvalKey, ClearEvalSumKeys, GetAllContexts, EnablePrecomputeCRTTablesAfterDeserializaton, DisablePrecomputeCRTTablesAfterDeserializaton, EvalChebyshevFunctionPtxt, GetMultiplicativeDepthByCoeffVector]
library(openfhe.R)

clear_eval_mult_keys()
clear_eval_automorphism_keys()

# ══ Key switching (BFV) ══════════════════════════════════
cc <- fhe_context("BFV", plaintext_modulus = 65537, multiplicative_depth = 2)
alice <- key_gen(cc)
bob <- key_gen(cc)
v <- c(1L, 2L, 3L, 4L, 5L, 6L)
enc <- function(k) encrypt(k@public, make_packed_plaintext(cc, v), cc = cc)
dec <- function(ct, k) {
  pt <- decrypt(ct, k@secret, cc = cc)
  set_length(pt, length(v))
  as.integer(get_packed_value(pt))
}

swk <- key_switch_gen(cc, alice@secret, bob@secret)
expect_true(S7::S7_inherits(swk, EvalKey))

ct <- enc(alice)
switched <- key_switch(ct, swk)
expect_identical(dec(switched, bob), v)
## The original is still Alice's, and Alice cannot open the switched
## one.
expect_identical(dec(ct, alice), v)
expect_false(identical(dec(switched, alice), v))

ct2 <- enc(alice)
r <- key_switch_in_place(ct2, swk)
expect_identical(r, ct2)
expect_identical(dec(ct2, bob), v)

expect_error(key_switch(ct, bob@public), "EvalKey")
expect_error(key_switch_gen(cc, alice@public, bob@secret), "PrivateKey")

# ══ Steps of hybrid key switching (CKKS) ═════════════════
ck <- fhe_context("CKKS", multiplicative_depth = 2L, scaling_mod_size = 50L,
                  batch_size = 8L)
kk <- key_gen(ck, eval_mult = TRUE)
x <- c(0.5, 1.5, 2.5, 3.5)
ctk <- encrypt(kk@public, make_ckks_packed_plaintext(ck, x), cc = ck)
deck <- function(ct) {
  pt <- decrypt(ct, kk@secret, cc = ck)
  set_length(pt, length(x))
  get_real_packed_value(pt)
}

## Up to the extended basis P*Q with the first element carried along,
## and back down: the ciphertext decrypts as before.
ext <- key_switch_ext(ctk, TRUE)
expect_true(S7::S7_inherits(ext, Ciphertext))
expect_identical(number_ciphertext_elements(ext), 2L)
expect_equal(deck(key_switch_down(ext)), x, tolerance = 1e-6)

## With add_first = FALSE the first element is left at zero. Brought
## back down and given the original first element, the ciphertext
## decrypts as before; so add_first decides exactly that element.
down <- key_switch_down(key_switch_ext(ctk, FALSE))
set_elements(down, list(get_elements(ctk)[[1L]], get_elements(down)[[2L]]))
expect_equal(deck(down), x, tolerance = 1e-6)

## key_switch_down_first_element() is the first element of
## key_switch_down(): with the original second element it decrypts as
## before.
first <- key_switch_down_first_element(ext)
expect_true(S7::S7_inherits(first, DCRTPoly))
rebuilt <- set_elements(clone_empty(ctk), list(first, get_elements(ctk)[[2L]]))
expect_equal(deck(rebuilt), x, tolerance = 1e-6)

# ══ Threshold multiplication key: MultiMultEvalKey ═══════
ccm <- fhe_context("BFV", plaintext_modulus = 65537, multiplicative_depth = 2,
                   features = c(Feature$MULTIPARTY))
kp1 <- key_gen(ccm)
kp2 <- multiparty_key_gen(ccm, kp1@public)
tag2 <- get_key_tag(kp2@public)

## The two-party joint relinearization key of the threshold-fhe
## example: each party's key-switching share, their sum, each party's
## product with its secret share, and the sum of those.
ek1 <- key_switch_gen(ccm, kp1@secret, kp1@secret)
ek2 <- multi_key_switch_gen(ccm, kp2@secret, kp2@secret, ek1)
ek_ab <- multi_add_eval_keys(ccm, ek1, ek2, tag2)
mult_a <- multi_mult_eval_key(ccm, kp1@secret, ek_ab, tag2)
mult_b <- multi_mult_eval_key(ccm, kp2@secret, ek_ab, tag2)
expect_true(S7::S7_inherits(mult_a, EvalKey))
expect_identical(get_key_tag(mult_a), tag2)
joint_mult <- multi_add_eval_mult_keys(ccm, mult_a, mult_b, tag2)
insert_eval_mult_key(list(joint_mult))

## A product under the joint key decrypts under the joint secret.
a <- c(1L, 2L, 3L, 4L)
b <- c(5L, 6L, 7L, 8L)
encm <- function(z) encrypt(kp2@public, make_packed_plaintext(ccm, z), cc = ccm)
prod <- eval_mult(encm(a), encm(b))
joint <- multiparty_key_gen(ccm, list(kp1@secret, kp2@secret))
ptm <- decrypt(prod, joint@secret, cc = ccm)
set_length(ptm, length(a))
expect_identical(as.integer(get_packed_value(ptm)), a * b)

## key_tag enters the result.
expect_identical(get_key_tag(multi_mult_eval_key(ccm, kp1@secret, ek_ab, "other")),
                 "other")

# ══ SparseKeyGen ═════════════════════════════════════════
## Bound as openfhe-python binds it. The header says no scheme
## supports it at present; whatever the library does with it is
## passed on.
sparse <- tryCatch(sparse_key_gen(cc), error = function(e) e)
expect_true(S7::S7_inherits(sparse, KeyPair) || inherits(sparse, "error"))

# ══ Registries ═══════════════════════════════════════════
## Summation keys.
cs <- fhe_context("BFV", plaintext_modulus = 65537, multiplicative_depth = 1,
                  features = c(Feature$ADVANCEDSHE))
ks <- key_gen(cs)
tag <- get_key_tag(ks@secret)
eval_sum_key_gen(cs, ks@secret)
expect_true(tag %in% names(get_all_eval_sum_keys()))
clear_eval_sum_keys(tag)
expect_false(tag %in% names(get_all_eval_sum_keys()))
eval_sum_key_gen(cs, ks@secret)
clear_eval_sum_keys()
expect_identical(length(get_all_eval_sum_keys()), 0L)

## Contexts.
all_cc <- get_all_contexts()
## Three distinct parameter sets were used above (two of the four
## fhe_context() calls asked for the same one).
expect_true(is.list(all_cc) && length(all_cc) >= 3L)
expect_true(all(vapply(all_cc, function(z) S7::S7_inherits(z, CryptoContext),
                       logical(1))))
n_before <- length(all_cc)
extra <- fhe_context("BFV", plaintext_modulus = 786433, multiplicative_depth = 4)
expect_identical(length(get_all_contexts()), n_before + 1L)
## The same parameters again are the same registered context.
again <- fhe_context("BFV", plaintext_modulus = 786433, multiplicative_depth = 4)
expect_identical(length(get_all_contexts()), n_before + 1L)

# ══ Globals ══════════════════════════════════════════════
get_flag <- openfhe.R:::PrecomputeCRTTablesAfterDeserializaton__get
initial <- get_flag()
disable_precompute_crt_tables_after_deserializaton()
expect_false(get_flag())
enable_precompute_crt_tables_after_deserializaton()
expect_true(get_flag())
if (!initial) disable_precompute_crt_tables_after_deserializaton()

# ══ Cleartext math ═══════════════════════════════════════
pts <- c(-0.9, -0.5, 0, 0.3, 0.8)
approx8 <- eval_chebyshev_function_ptxt(exp, pts, -1, 1, 8L)
expect_equal(approx8, exp(pts), tolerance = 1e-6)
## A lower degree is a worse approximation.
approx2 <- eval_chebyshev_function_ptxt(exp, pts, -1, 1, 2L)
expect_true(max(abs(approx2 - exp(pts))) > max(abs(approx8 - exp(pts))))
## The interval enters the result.
expect_equal(eval_chebyshev_function_ptxt(function(t) t^2, c(1, 2, 3), 0, 4, 4L),
             c(1, 4, 9), tolerance = 1e-8)
## It agrees with the coefficients the package computes itself:
## c0 / 2 + sum_k c_k T_k(u).
co <- eval_chebyshev_coefficients(exp, a = -1, b = 1, degree = 8L)
by_hand <- vapply(pts, function(u) {
  k <- seq_along(co) - 1L
  sum(co * cos(k * acos(u))) - co[1] / 2
}, numeric(1))
expect_equal(approx8, by_hand, tolerance = 1e-10)
## An error in the R function comes back as that error.
expect_error(eval_chebyshev_function_ptxt(function(t) stop("boom"), pts, -1, 1, 4L),
             "boom")
expect_error(eval_chebyshev_function_ptxt("exp", pts, -1, 1, 4L), "must be a function")
expect_error(eval_chebyshev_function_ptxt(exp, pts, -1, 1, 0L))

## Depth of a Paterson-Stockmeyer evaluation: grows with the degree,
## and normalization saves one level.
d5 <- get_multiplicative_depth_by_coeff_vector(numeric(6))
d27 <- get_multiplicative_depth_by_coeff_vector(numeric(28))
expect_true(is.integer(d5) && d27 > d5)
expect_identical(get_multiplicative_depth_by_coeff_vector(numeric(28), TRUE),
                 d27 - 1L)
expect_identical(get_multiplicative_depth_by_coeff_vector(complex(28)), d27)
expect_error(get_multiplicative_depth_by_coeff_vector(numeric(0)))
expect_error(get_multiplicative_depth_by_coeff_vector("a"), "numeric or complex")
