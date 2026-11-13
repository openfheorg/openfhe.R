## OPENFHE PYTHON SOURCE: src/lib/pke/fbt.cpp (functional bootstrapping calls the examples do not make)
##
## @openfhe-python: src/lib/pke/fbt.cpp [FULL: EvalFBTNoDecoding, EvalHomDecoding, EvalMVBPrecompute, EvalMVB and EvalMVBNoDecoding with integer coefficients, EvalHermiteTrigSeries]
##
## The rest of the functional bootstrapping surface is exercised by
## test_example_functional_bootstrapping.R and
## test_example_fe_functional_bootstrapping.R.
library(openfhe.R)

# ══ A Boolean look-up table (integer coefficients) ═══════
## The first parameter set of functional-bootstrapping-ckks.py.
q_init <- "1152921504606846976"   # 2^60
q <- 2^33
lut <- function(v) (v %% 2 - 1) %% 2
coeff <- as.integer(c(lut(1), lut(0) - lut(1)))
x <- c(1, 0, 0, 1, 0, 1, 0, 1)
skd <- SecretKeyDist$SPARSE_ENCAPSULATED
lvlb <- c(3L, 3L)
depth <- get_fbt_depth(lvlb, coeff, 2, 1L, skd)
cc <- fhe_context("CKKS",
  secret_key_dist = skd,
  security_level = SecurityLevel$HEStd_NotSet,
  scaling_mod_size = 33L,
  scaling_technique = ScalingTechnique$FLEXIBLEAUTO,
  first_mod_size = 33L,
  num_large_digits = 3L,
  batch_size = 8L,
  ring_dim = 4096L,
  multiplicative_depth = depth,
  features = c(Feature$ADVANCEDSHE, Feature$FHE))
keys <- key_gen(cc)
expect_identical(eval_fbt_setup(cc, coeff, 8L, 2, 2, q, keys@public, c(0L, 0L),
                                lvlb), cc)
eval_bootstrap_key_gen(cc, keys@secret, 8L)
eval_mult_key_gen(cc, keys@secret)

ep <- schemelet_get_element_params(keys@secret, depth)
new_input <- function() {
  ct <- schemelet_encrypt_coeff(x, q_init, 2, keys@secret, ep)
  schemelet_mod_switch(ct, q, q_init)
  schemelet_convert_rlwe_to_ckks(cc, ct, keys@public, q, 8L, depth)
}
dec <- function(ct) {
  polys <- schemelet_convert_ckks_to_rlwe(ct, q)
  schemelet_decrypt_coeff(polys, q, 2, keys@secret, ep, 8L, 8L)
}
exact <- vapply(x, lut, numeric(1))
same <- function(got) max(abs(exact - got) %% 2) == 0

## The round trip RLWE -> CKKS gives a CKKS ciphertext.
ctxt <- new_input()
expect_true(S7::S7_inherits(ctxt, Ciphertext))
expect_identical(number_ciphertext_elements(ctxt), 2L)

## EvalFBT is EvalFBTNoDecoding followed by EvalHomDecoding.
expect_true(same(dec(eval_fbt(ctxt, coeff, 1L, get_modulus(ep), 1))))
nd <- eval_fbt_no_decoding(new_input(), coeff, 1L, get_modulus(ep))
expect_true(S7::S7_inherits(nd, Ciphertext))
expect_true(same(dec(eval_hom_decoding(nd, 1))))

## The same in two steps through the precomputed exponential.
powers <- eval_mvb_precompute(new_input(), coeff, 1L, get_modulus(ep))
expect_true(S7::S7_inherits(powers, SeriesPowers))
expect_true(same(dec(eval_mvb(powers, coeff, 1L, 1))))
expect_true(same(dec(eval_hom_decoding(eval_mvb_no_decoding(powers, coeff, 1L), 1))))
## Another table on the same precomputation: the identity.
ident <- as.integer(c(1, 0 - 1))
got <- dec(eval_mvb(powers, ident, 1L, 1))
expect_true(max(abs(x - got) %% 2) == 0)

## Argument checks.
expect_error(eval_fbt(ctxt, character(0), 1L, get_modulus(ep), 1), "non-empty")
expect_error(eval_fbt(ctxt, coeff, 1L, -1, 1))
expect_error(eval_fbt(ctxt, coeff, 1L, get_modulus(ep), 1.5))
expect_error(eval_mvb(ctxt, coeff, 1L, 1), "SeriesPowers")
expect_error(eval_mvb_precompute(powers, coeff, 1L, get_modulus(ep)), "Ciphertext")
expect_error(eval_fbt_setup(cc, coeff, 8L, 2, 2, q, keys@secret, c(0L, 0L), lvlb),
             "PublicKey")

# ══ EvalHermiteTrigSeries ════════════════════════════════
## Chebyshev coefficients of f on [a, b], in OpenFHE's convention
## c0 / 2 + sum_k c_k T_k.
cheb_coef <- function(f, a, b, degree) {
  n <- degree + 1L
  theta <- pi * (seq_len(n) - 0.5) / n
  y <- f((b - a) / 2 * cos(theta) + (a + b) / 2)
  vapply(0:degree, function(k) 2 / n * sum(y * cos(k * theta)), complex(1))
}

ch <- fhe_context("CKKS",
  multiplicative_depth = 12L, scaling_mod_size = 50L, first_mod_size = 55L,
  ring_dim = 4096L, batch_size = 8L,
  security_level = SecurityLevel$HEStd_NotSet,
  scaling_technique = ScalingTechnique$FLEXIBLEAUTO,
  features = c(Feature$ADVANCEDSHE, Feature$FHE))
kh <- key_gen(ch, eval_mult = TRUE)
## The series keeps its exponential in the bootstrapping record of the
## context, and takes a real part with the conjugation key. The
## plaintexts of bootstrapping itself are not needed (and this context
## is too shallow for them; notes/upstream-defects.md L4).
eval_bootstrap_setup(ch, c(1L, 1L), slots = 8L, precompute = FALSE)
eval_bootstrap_key_gen(ch, kh@secret, 8L)

u <- c(0, 0.125, 0.25, 0.375, 0.5, -0.25, 0.75, -0.5)
cu <- encrypt(kh@public, make_ckks_packed_plaintext(ch, u, slots = 8L), cc = ch)
dech <- function(ct) {
  pt <- decrypt(ct, kh@secret, cc = ch)
  set_length(pt, length(u))
  get_real_packed_value(pt)
}
cheb <- cheb_coef(function(v) exp(1i * pi / 2 * v), -1, 1, 15L)
E <- exp(2i * pi * u)

## 2 * Re(h_0 + h_1 E), complex coefficients.
h <- c(0.5, 0.25 + 0.1i)
expect_equal(dech(eval_hermite_trig_series(cu, cheb, -1, 1, h)),
             2 * Re(h[1] + h[2] * E), tolerance = 1e-5)
## precomp = 2 reuses the exponential kept by the call above.
expect_equal(dech(eval_hermite_trig_series(cu, cheb, -1, 1, c(1, 0, 0.5), 2L)),
             2 * Re(1 + 0.5 * E^2), tolerance = 1e-5)
## Integer coefficients.
expect_equal(dech(eval_hermite_trig_series(cu, cheb, -1, 1, c(1L, 2L))),
             2 * Re(1 + 2 * E), tolerance = 1e-5)
## The second place: computed with precomp = 1, reused with 3.
expect_equal(dech(eval_hermite_trig_series(cu, cheb, -1, 1, c(0, 1), 1L)),
             2 * Re(E), tolerance = 1e-5)
expect_equal(dech(eval_hermite_trig_series(cu, cheb, -1, 1, c(0.5, 0, 1), 3L)),
             2 * Re(0.5 + E^2), tolerance = 1e-5)
## The interval enters: on [-2, 2] the same Chebyshev coefficients
## describe exp(i * pi / 4 * x), so the series is evaluated at x / 2.
expect_equal(dech(eval_hermite_trig_series(cu, cheb, -2, 2, c(0, 1))),
             2 * Re(exp(1i * pi * u)), tolerance = 1e-5)

expect_error(eval_hermite_trig_series(cu, "a", -1, 1, h), "non-empty")
expect_error(eval_hermite_trig_series(kh@public, cheb, -1, 1, h), "Ciphertext")
