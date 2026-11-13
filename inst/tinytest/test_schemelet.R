## OPENFHE PYTHON SOURCE: src/lib/pke/fbt.cpp (PolyVector, SchemeletRLWEMP, GetHermiteTrigCoefficients)
##
## @openfhe-python: src/lib/pke/fbt.cpp [FULL: PolyVector.__init__, PolyVector.__len__, PolyVector.__sub__, PolyVector.Clone, PolyVector.SwitchModulus, SchemeletRLWEMP.GetElementParams, SchemeletRLWEMP.EncryptCoeff, SchemeletRLWEMP.DecryptCoeff, SchemeletRLWEMP.ModSwitch, SchemeletRLWEMP.GetQPrime, GetHermiteTrigCoefficients]
##
## The conversions to and from CKKS and the functional bootstrapping
## functions are exercised in test_example_functional_bootstrapping.R.
library(openfhe.R)

cc <- fhe_context("CKKS", multiplicative_depth = 3L, scaling_mod_size = 50L,
                  first_mod_size = 55L, batch_size = 8L, ring_dim = 2048L,
                  security_level = SecurityLevel$HEStd_NotSet)
keys <- key_gen(cc)
q60 <- "1152921504606846976"   # 2^60
q40 <- 2^40
p <- 16
x <- c(1, 2, 3, 7, 8, 9, 15, 0)
## DecryptCoeff returns values in (-p/2, p/2].
centered <- function(v) ifelse(v > p / 2, v - p, v)

# ══ Element parameters ═══════════════════════════════════
ep <- schemelet_get_element_params(keys@secret)
expect_true(S7::S7_inherits(ep, ElementParams))
## The context's scaling technique is the default FLEXIBLEAUTOEXT, with
## one tower more than the depth asks for; level 0 leaves that tower
## out, so the modulus is the product of the first four.
expect_identical(get_modulus(ep), schemelet_get_q_prime(keys@public, 3L))
expect_identical(ring_dimension(ep), 2048L)
## Removing a level removes a tower: a smaller modulus.
ep1 <- schemelet_get_element_params(keys@secret, 1L)
expect_true(nchar(get_modulus(ep1)) < nchar(get_modulus(ep)))
expect_error(schemelet_get_element_params(keys@public), "PrivateKey")

# ══ Encrypt / decrypt ════════════════════════════════════
ct <- schemelet_encrypt_coeff(x, q60, p, keys@secret, ep)
expect_true(S7::S7_inherits(ct, PolyVector))
expect_equal(openfhe.R:::xptr_type(ct@ptr), "openfhe.R::PolyVector")
expect_identical(length(ct), 2L)
expect_equal(schemelet_decrypt_coeff(ct, q60, p, keys@secret, ep, 8L),
             centered(x))
## length shortens the result.
expect_equal(schemelet_decrypt_coeff(ct, q60, p, keys@secret, ep, 8L, 3L),
             centered(x)[1:3])
## Another key does not decrypt it.
other <- key_gen(cc)
expect_false(isTRUE(all.equal(
  schemelet_decrypt_coeff(ct, q60, p, other@secret, ep, 8L), centered(x))))
## bit_reverse at both ends cancels; at one end only it permutes.
ct_br <- schemelet_encrypt_coeff(x, q60, p, keys@secret, ep, TRUE)
expect_equal(schemelet_decrypt_coeff(ct_br, q60, p, keys@secret, ep, 8L,
                                     bit_reverse = TRUE), centered(x))
perm <- schemelet_decrypt_coeff(ct_br, q60, p, keys@secret, ep, 8L)
expect_false(isTRUE(all.equal(perm, centered(x))))
expect_equal(sort(perm), sort(centered(x)))
## The input is reduced modulo p.
ct_w <- schemelet_encrypt_coeff(x + p, q60, p, keys@secret, ep)
expect_equal(schemelet_decrypt_coeff(ct_w, q60, p, keys@secret, ep, 8L),
             centered(x))

# ══ ModSwitch (in place) ═════════════════════════════════
ct2 <- clone(ct)
r <- schemelet_mod_switch(ct2, q40, q60)
expect_identical(r, ct2)
expect_equal(schemelet_decrypt_coeff(ct2, q40, p, keys@secret, ep, 8L),
             centered(x))
## The clone was switched, the original was not.
expect_equal(schemelet_decrypt_coeff(ct, q60, p, keys@secret, ep, 8L),
             centered(x))

# ══ Subtraction ══════════════════════════════════════════
y <- c(1, 1, 1, 1, 2, 2, 2, 0)
cty <- schemelet_encrypt_coeff(y, q60, p, keys@secret, ep)
d <- ct - cty
expect_true(S7::S7_inherits(d, PolyVector))
expect_equal(schemelet_decrypt_coeff(d, q60, p, keys@secret, ep, 8L),
             centered((x - y) %% p))
expect_error(ct - PolyVector(), "sizes do not match")

# ══ SwitchModulus (in place) ═════════════════════════════
## Unlike schemelet_mod_switch(), it keeps the residues and does not
## rescale, so the result no longer decrypts modulo 2^60. The object
## is changed in place; the ciphertext it was cloned from is not.
ct3 <- clone(ct)
r <- switch_modulus(ct3, q40)
expect_identical(r, ct3)
expect_false(isTRUE(all.equal(
  schemelet_decrypt_coeff(ct3, q60, p, keys@secret, ep, 8L), centered(x))))
expect_equal(schemelet_decrypt_coeff(ct, q60, p, keys@secret, ep, 8L),
             centered(x))

# ══ An empty vector ══════════════════════════════════════
empty <- PolyVector()
expect_identical(length(empty), 0L)
expect_identical(length(clone(empty)), 0L)
expect_error(schemelet_decrypt_coeff(empty, q60, p, keys@secret, ep, 8L),
             "two RLWE polynomials")
expect_error(schemelet_mod_switch(empty, q40, q60), "two RLWE polynomials")
expect_error(schemelet_convert_rlwe_to_ckks(cc, empty, keys@public, q60, 8L),
             "two RLWE polynomials")

# ══ GetQPrime ════════════════════════════════════════════
q0 <- schemelet_get_q_prime(keys@public, 0L)
expect_identical(q0, get_modulus_ckks(cc))
q1 <- schemelet_get_q_prime(keys@public, 1L)
expect_true(is.character(q1) && nchar(q1) > nchar(q0))
## All five towers: the modulus of the context.
expect_identical(schemelet_get_q_prime(keys@public, 4L), get_modulus(cc))

# ══ Argument checks ══════════════════════════════════════
expect_error(schemelet_encrypt_coeff(c(1.5, 2), q60, p, keys@secret, ep),
             "whole numbers")
expect_error(schemelet_encrypt_coeff(x, -1, p, keys@secret, ep))
expect_error(schemelet_encrypt_coeff(x, q60, p, keys@secret, cc), "ElementParams")
expect_error(schemelet_decrypt_coeff(keys@public, q60, p, keys@secret, ep, 8L),
             "PolyVector")
expect_error(schemelet_convert_ckks_to_rlwe(ct, q60), "Ciphertext")

# ══ Hermite coefficients ═════════════════════════════════
## Order 1 is the discrete Fourier transform of the table divided by
## the modulus and the scale: the series reproduces the table at the
## integers.
pp <- 8L
f <- function(v) (3 * v + 1) %% pp
co <- get_hermite_trig_coefficients(f, pp, 1L, 1)
expect_true(is.complex(co))
tab <- vapply(0:(pp - 1L), f, numeric(1))
co2 <- get_hermite_trig_coefficients(f, pp, 1L, 2)
expect_equal(co2, co / 2)
## The function is called with whole numbers in 0, ..., p - 1.
seen <- numeric(0)
invisible(get_hermite_trig_coefficients(function(v) { seen <<- c(seen, v); 0 },
                                        pp, 1L, 1))
expect_true(all(seen %in% 0:(pp - 1L)) && all(0:(pp - 1L) %in% seen))
## A different table gives different coefficients; a higher order more
## of them.
expect_false(isTRUE(all.equal(
  get_hermite_trig_coefficients(function(v) v %% 2, pp, 1L, 1), co)))
expect_true(length(get_hermite_trig_coefficients(f, pp, 2L, 1)) > length(co))
expect_error(get_hermite_trig_coefficients(function(v) stop("boom"), pp, 1L, 1),
             "boom")
expect_error(get_hermite_trig_coefficients("f", pp, 1L, 1), "must be a function")

# ══ Depth helpers ════════════════════════════════════════
skd <- SecretKeyDist$SPARSE_ENCAPSULATED
d_bool <- get_fbt_depth(c(3L, 3L), c(0L, 1L), 2, 1L, skd)
d_gen <- get_fbt_depth(c(3L, 3L), co, pp, 1L, skd)
expect_true(is.integer(d_bool) && d_gen > d_bool)
## The level budgets enter the depth.
expect_identical(get_fbt_depth(c(2L, 2L), c(0L, 1L), 2, 1L, skd), d_bool - 2L)
## A double vector is the general form, not the Boolean one.
expect_true(get_fbt_depth(c(3L, 3L), c(0, 1), 2, 1L, skd) != d_bool ||
            get_fbt_depth(c(3L, 3L), c(0, 1), 2, 2L, skd) != d_bool)
d_fe <- get_fefbt_depth(c(3L, 2L), complex(30), skd)
expect_true(is.integer(d_fe) && d_fe > 5L)
expect_true(get_fefbt_depth(c(3L, 2L), complex(45), skd) >= d_fe)
expect_error(get_fbt_depth(c(3L, 3L), "a", 2, 1L, skd), "non-empty")
