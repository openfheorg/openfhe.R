## OPENFHE PYTHON SOURCE: examples/pke/iterative-ckks-bootstrapping-composite-scaling.py
##
## @openfhe-python: iterative-ckks-bootstrapping-composite-scaling.py [FULL]
##
## Multiple iterations of CKKS bootstrapping with composite scaling to
## improve precision.
library(openfhe.R)

if (!tinytest::at_home() && Sys.getenv("CI") != "true") {
  exit_file("skipped on CRAN: heavy bootstrapping (runs on CI and at_home)")
}

## The precision number (or approximation error). The higher the
## precision, the less the error. As recommended in footnote 23 of
## Security Guidelines for Implementing Homomorphic Encryption
## (https://cic.iacr.org/p/1/4/26/pdf), precision bits are evaluated as
## the negative base 2 logarithm of the average L1 norm between results
## from standard (cleartext) calculation and those computed
## homomorphically.
calculate_approximation_error <- function(result, expected_result) {
  if (length(result) != length(expected_result)) {
    stop("Cannot compare vectors with different numbers of elements")
  }
  ## using the average
  acc_error <- sum(abs(result - expected_result))
  abs(log2(acc_error / length(result)))
}

set.seed(1)

# Step 1: Set CryptoContext
parameters <- CKKSParams()
secret_key_dist <- SecretKeyDist$UNIFORM_TERNARY
set_secret_key_dist(parameters, secret_key_dist)
set_security_level(parameters, SecurityLevel$HEStd_NotSet)
set_ring_dim(parameters, 2^7)

## All modes are supported for 64-bit CKKS bootstrapping.
## For this configuration, 3 words per level will be used
rescale_tech <- ScalingTechnique$COMPOSITESCALINGAUTO
dcrt_bits <- 61L
first_mod <- 66L
register_word_size <- 27L

set_scaling_mod_size(parameters, dcrt_bits)
set_scaling_technique(parameters, rescale_tech)
set_first_mod_size(parameters, first_mod)
set_register_word_size(parameters, register_word_size)

## The number of iterations to run bootstrapping; 1 or 2 are supported.
## Two iterations should give approximately double the precision of one.
num_iterations <- 2L

level_budget <- c(3L, 3L)
bsgs_dim <- c(0L, 0L)

levels_available_after_bootstrap <- 10L
## Each extra iteration on top of 1 requires an extra level to be
## consumed.
depth <- levels_available_after_bootstrap +
  get_bootstrap_depth(level_budget, secret_key_dist) + (num_iterations - 1L)
set_multiplicative_depth(parameters, depth)

## Generate crypto context.
cryptocontext <- gen_crypto_context(parameters)

## Enable features. FHE must be enabled to use bootstrapping.
enable_feature(cryptocontext, Feature$PKE)
enable_feature(cryptocontext, Feature$KEYSWITCH)
enable_feature(cryptocontext, Feature$LEVELEDSHE)
enable_feature(cryptocontext, Feature$ADVANCEDSHE)
enable_feature(cryptocontext, Feature$FHE)

ring_dim <- ring_dimension(cryptocontext)
expect_equal(ring_dim, 128L)

## Three primes make up a level of 61 bits on a 27-bit register.
composite_degree <- get_composite_degree(cryptocontext)
expect_equal(composite_degree, 3L)

# Step 2: Precomputations for bootstrapping
## We use a full packing.
num_slots <- get_cyclotomic_order(cryptocontext) %/% 4L
expect_equal(num_slots, ring_dim %/% 2L)
eval_bootstrap_setup(cryptocontext, level_budget, bsgs_dim, num_slots)

# Step 3: Key Generation
key_pair <- key_gen(cryptocontext)
eval_mult_key_gen(cryptocontext, key_pair@secret)
## Generate bootstrapping keys.
eval_bootstrap_key_gen(cryptocontext, key_pair@secret, num_slots)

# Step 4: Encoding and encryption of inputs
## Generate random input
x <- runif(num_slots, 0, 1)

## We start with a depleted ciphertext that has used up all of its levels.
ptxt <- make_ckks_packed_plaintext(cryptocontext, x, 1L,
                                   composite_degree * (depth - 1L), NULL,
                                   num_slots)
set_length(ptxt, num_slots)
expect_equal(get_real_packed_value(ptxt), x)

## Encrypt the encoded vectors
ciph <- encrypt(key_pair@public, ptxt, cc = cryptocontext)

# Step 5: Measure the precision of a single bootstrapping operation.
ciphertext_after <- eval_bootstrap(ciph)

result <- decrypt(ciphertext_after, key_pair@secret, cc = cryptocontext)
set_length(result, num_slots)
precision_one_iteration <- floor(calculate_approximation_error(
  get_complex_packed_value(result), get_complex_packed_value(ptxt)))
## Bootstrapping precision after 1 iteration
expect_true(precision_one_iteration >= 19)

## Set precision equal to empirically measured value after many test
## runs.
precision <- 19L

# Step 6: Run bootstrapping with multiple iterations.
ciphertext_two_iterations <- eval_bootstrap(ciph, num_iterations, precision)

result_two_iterations <- decrypt(ciphertext_two_iterations, key_pair@secret,
                                 cc = cryptocontext)
set_length(result, num_slots)
actual_result <- get_complex_packed_value(result_two_iterations)
expect_equal(length(actual_result), num_slots)

## Output after two iterations of bootstrapping
expect_equal(Re(actual_result), x, tolerance = 1e-8)
precision_multiple_iterations <-
  calculate_approximation_error(actual_result, get_complex_packed_value(ptxt))

## Bootstrapping precision after 2 iterations. It should be
## approximately double the original precision.
expect_true(precision_multiple_iterations > 33)
## Number of levels remaining after 2 bootstrappings
expect_equal(depth - get_level(ciphertext_two_iterations) %/% composite_degree -
               (get_noise_scale_deg(ciphertext_two_iterations) - 1L),
             levels_available_after_bootstrap)

clear_fhe_state()
