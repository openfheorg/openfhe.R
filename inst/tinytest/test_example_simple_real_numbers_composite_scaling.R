## OPENFHE PYTHON SOURCE: examples/pke/simple-real-numbers-composite-scaling.py
##
## @openfhe-python: simple-real-numbers-composite-scaling.py [FULL]
##
## Simple operations on real numbers in CKKS in the
## COMPOSITESCALINGAUTO mode, where the library chooses the composite
## degree from the scaling modulus size and the register word size.
## The example's command-line overrides are not ported; the test runs
## at the default parameters.
library(openfhe.R)

tol <- 1e-8

# Defaults (same as C++)
mult_depth <- 2L
first_mod_size <- 90L
scale_mod_size <- 73L
batch_size <- 8L
register_word_size <- 32L

# Step 1: Setup CryptoContext (CKKS)
parameters <- CKKSParams()
set_multiplicative_depth(parameters, mult_depth)
set_first_mod_size(parameters, first_mod_size)
set_scaling_mod_size(parameters, scale_mod_size)
set_batch_size(parameters, batch_size)
set_security_level(parameters, SecurityLevel$HEStd_NotSet)
set_ring_dim(parameters, bitwShiftL(1L, 12L))

set_scaling_technique(parameters, ScalingTechnique$COMPOSITESCALINGAUTO)
set_register_word_size(parameters, register_word_size)

cc <- gen_crypto_context(parameters)

# Enable features
enable_feature(cc, Feature$PKE)
enable_feature(cc, Feature$KEYSWITCH)
enable_feature(cc, Feature$LEVELEDSHE)

expect_equal(ring_dimension(cc), 4096L)

# Step 2: Key Generation
keys <- key_gen(cc)
eval_mult_key_gen(cc, keys@secret)
eval_rotate_key_gen(cc, keys@secret, c(1L, -2L))

# Step 3: Encoding and encryption of inputs
x1 <- c(0.25, 0.5, 0.75, 1.0, 2.0, 3.0, 4.0, 5.0)
x2 <- c(5.0, 4.0, 3.0, 2.0, 1.0, 0.75, 0.5, 0.25)

ptxt1 <- make_ckks_packed_plaintext(cc, x1)
ptxt2 <- make_ckks_packed_plaintext(cc, x2)

expect_equal(get_real_packed_value(ptxt1)[seq_len(batch_size)], x1,
             tolerance = tol)
expect_equal(get_real_packed_value(ptxt2)[seq_len(batch_size)], x2,
             tolerance = tol)

c1 <- encrypt(keys@public, ptxt1, cc = cc)
c2 <- encrypt(keys@public, ptxt2, cc = cc)

# Step 4: Evaluation
c_add <- eval_add(c1, c2)
c_sub <- eval_sub(c1, c2)
c_scalar <- eval_mult(c1, 4.0)
c_mul <- eval_mult(c1, c2)
c_rot1 <- eval_rotate(c1, 1L)
c_rot2 <- eval_rotate(c1, -2L)

# Step 5: Decryption and output
decrypt_result <- function(ct) {
  result <- decrypt(ct, keys@secret, cc = cc)
  set_length(result, batch_size)
  result
}

result <- decrypt_result(c1)
expect_equal(get_real_packed_value(result), x1, tolerance = tol)
## Estimated precision in bits
expect_true(get_log_precision(result) > 20)

result <- decrypt_result(c_add)
expect_equal(get_real_packed_value(result), x1 + x2, tolerance = tol)
## Estimated precision in bits
expect_true(get_log_precision(result) > 20)

result <- decrypt_result(c_sub)
expect_equal(get_real_packed_value(result), x1 - x2, tolerance = tol)

result <- decrypt_result(c_scalar)
expect_equal(get_real_packed_value(result), 4 * x1, tolerance = tol)

result <- decrypt_result(c_mul)
expect_equal(get_real_packed_value(result), x1 * x2, tolerance = tol)

## The eight values fill the eight slots, so the rotations are cyclic:
## to the left by 1 and to the right by 2.
result <- decrypt_result(c_rot1)
expect_equal(get_real_packed_value(result), x1[c(2:8, 1L)], tolerance = tol)

result <- decrypt_result(c_rot2)
expect_equal(get_real_packed_value(result), x1[c(7:8, 1:6)], tolerance = tol)

# Testing EvalSub ciphertext - double
c_sub_double <- eval_sub(c1, 0.5)
## c1 noise degree and scaling factor: a fresh ciphertext has degree 1
## and a scaling factor that is a product of primes, within a bit of
## 2^scale_mod_size.
expect_equal(get_noise_scale_deg(c1), 1L)
expect_true(abs(log2(get_scaling_factor(c1)) - scale_mod_size) < 1)

# Testing EvalAdd ciphertext + negative double
c_add_neg_double <- eval_add(c1, -0.5)

result <- decrypt_result(c_sub_double)
expect_equal(get_real_packed_value(result), x1 - 0.5, tolerance = tol)

result <- decrypt_result(c_add_neg_double)
expect_equal(get_real_packed_value(result), x1 + (-0.5), tolerance = tol)
