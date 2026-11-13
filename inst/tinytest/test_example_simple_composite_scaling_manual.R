## OPENFHE PYTHON SOURCE: examples/pke/simple-composite-scaling-manual.py
##
## @openfhe-python: simple-composite-scaling-manual.py [FULL]
##
## Simple examples for CKKS in the COMPOSITESCALINGMANUAL mode, with
## the register word size and composite degree set explicitly. The
## example's command-line overrides are not ported; the test runs at
## the default parameters.
library(openfhe.R)

tol <- 1e-8

# Step 1: Setup CryptoContext

# A. Specify main parameters
# A1) Multiplicative depth: the maximum possible depth of a given
# multiplication, but not the total number of multiplications
# supported by the scheme.
mult_depth <- 2L

# A2) Bit-length of scaling factor.
first_mod_size <- 96L
scale_mod_size <- 95L

# A3) Number of plaintext slots used in the ciphertext.
batch_size <- 8L

# The word size in bits of the target hardware architecture.
register_word_size <- 27L

# COMPOSITESCALINGMANUAL works internally the same way as
# COMPOSITESCALINGAUTO. The only difference is that it allows the
# composite degree value d to be set manually without any
# restrictions, to explore combinations of register word size,
# scaling modulus size and composite degree. There is no guarantee
# that a given combination will work.
scal_tech <- ScalingTechnique$COMPOSITESCALINGMANUAL

# Desired and manually-set composite degree d in [2,3,4].
composite_degree <- 4L

# A4) Desired security level based on FHE standards.
parameters <- CKKSParams()
set_multiplicative_depth(parameters, mult_depth)
set_first_mod_size(parameters, first_mod_size)
set_scaling_mod_size(parameters, scale_mod_size)
set_batch_size(parameters, batch_size)
set_security_level(parameters, SecurityLevel$HEStd_NotSet)
set_ring_dim(parameters, bitwShiftL(1L, 12L))

set_scaling_technique(parameters, scal_tech)
set_register_word_size(parameters, register_word_size)
set_composite_degree(parameters, composite_degree)

cc <- gen_crypto_context(parameters)
## Composite degree, and the prime modulus size that follows from it
expect_equal(get_composite_degree(cc), composite_degree)
expect_equal(scale_mod_size / get_composite_degree(cc), 23.75)

# Enable the features that you wish to use
enable_feature(cc, Feature$PKE)
enable_feature(cc, Feature$KEYSWITCH)
enable_feature(cc, Feature$LEVELEDSHE)
expect_equal(ring_dimension(cc), 4096L)

# B. Step 2: Key Generation
# B1) Generate encryption keys.
keys <- key_gen(cc)

# B2) Generate the relinearization key
eval_mult_key_gen(cc, keys@secret)

# B3) Generate the rotation keys
eval_rotate_key_gen(cc, keys@secret, c(1L, -2L))

# Step 3: Encoding and encryption of inputs

# Inputs
x1 <- c(0.25, 0.5, 0.75, 1.0, 2.0, 3.0, 4.0, 5.0)
x2 <- c(5.0, 4.0, 3.0, 2.0, 1.0, 0.75, 0.5, 0.25)

# Encoding as plaintexts
ptxt1 <- make_ckks_packed_plaintext(cc, x1)
ptxt2 <- make_ckks_packed_plaintext(cc, x2)

expect_equal(get_real_packed_value(ptxt1)[seq_len(batch_size)], x1,
             tolerance = tol)
expect_equal(get_real_packed_value(ptxt2)[seq_len(batch_size)], x2,
             tolerance = tol)

# Encrypt the encoded vectors
c1 <- encrypt(keys@public, ptxt1, cc = cc)
c2 <- encrypt(keys@public, ptxt2, cc = cc)

# Step 4: Evaluation

# Homomorphic addition
c_add <- eval_add(c1, c2)

# Homomorphic subtraction
c_sub <- eval_sub(c1, c2)

# Homomorphic scalar multiplication
c_scalar <- eval_mult(c1, 4.0)

# Homomorphic multiplication
c_mul <- eval_mult(c1, c2)

# Homomorphic rotations
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

# Decrypt the result of addition
result <- decrypt_result(c_add)
expect_equal(get_real_packed_value(result), x1 + x2, tolerance = tol)
## Estimated precision in bits
expect_true(get_log_precision(result) > 20)

# Decrypt the result of subtraction
result <- decrypt_result(c_sub)
expect_equal(get_real_packed_value(result), x1 - x2, tolerance = tol)

# Decrypt the result of scalar multiplication
result <- decrypt_result(c_scalar)
expect_equal(get_real_packed_value(result), 4 * x1, tolerance = tol)

# Decrypt the result of multiplication
result <- decrypt_result(c_mul)
expect_equal(get_real_packed_value(result), x1 * x2, tolerance = tol)

# Decrypt the result of rotations
## The eight values fill the eight slots, so the rotations are cyclic:
## to the left by 1 and to the right by 2.
result <- decrypt_result(c_rot1)
expect_equal(get_real_packed_value(result), x1[c(2:8, 1L)], tolerance = tol)

result <- decrypt_result(c_rot2)
expect_equal(get_real_packed_value(result), x1[c(7:8, 1:6)], tolerance = tol)

# Testing EvalSub ciphertext - double
c_sub_double <- eval_sub(c1, 0.5)
## c1 noise degree and scaling factor: a fresh ciphertext has degree 1
## and a scaling factor that is the product of composite_degree
## primes, within a bit of 2^scale_mod_size.
expect_equal(get_noise_scale_deg(c1), 1L)
expect_true(abs(log2(get_scaling_factor(c1)) - scale_mod_size) < 1)

# Testing EvalAdd ciphertext + negative double
c_add_neg_double <- eval_add(c1, -0.5)

# Decrypt the result of subtraction
result <- decrypt_result(c_sub_double)
expect_equal(get_real_packed_value(result), x1 - 0.5, tolerance = tol)

# Decrypt the result of addition
result <- decrypt_result(c_add_neg_double)
expect_equal(get_real_packed_value(result), x1 + (-0.5), tolerance = tol)
