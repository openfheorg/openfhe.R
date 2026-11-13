## OPENFHE PYTHON SOURCE: examples/pke/simple-ckks-bootstrapping-composite-scaling.py
##
## @openfhe-python: simple-ckks-bootstrapping-composite-scaling.py [FULL]
##
## CKKS bootstrapping with composite scaling: each level of the modulus
## chain is a product of primes that fit the register word size. Run in
## the default order (ModRaise first) and slots-to-coefficients first.
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

x <- c(0.25, 0.5, 0.75, 1.0, 2.0, 3.0, 4.0, 5.0)
encoded_length <- length(x)

dcrt_bits <- 98L
first_mod <- 100L
register_word_size <- 64L

## The parameters the two functions of the example share.
composite_parameters <- function(secret_key_dist) {
  parameters <- CKKSParams()
  set_secret_key_dist(parameters, secret_key_dist)

  rescale_tech <- ScalingTechnique$COMPOSITESCALINGAUTO
  set_scaling_mod_size(parameters, dcrt_bits)
  set_scaling_technique(parameters, rescale_tech)
  set_first_mod_size(parameters, first_mod)

  set_security_level(parameters, SecurityLevel$HEStd_NotSet)
  set_ring_dim(parameters, 2^12)

  set_register_word_size(parameters, register_word_size)
  parameters
}

enable_bootstrap_features <- function(cryptocontext) {
  enable_feature(cryptocontext, Feature$PKE)
  enable_feature(cryptocontext, Feature$KEYSWITCH)
  enable_feature(cryptocontext, Feature$LEVELEDSHE)
  enable_feature(cryptocontext, Feature$ADVANCEDSHE)
  enable_feature(cryptocontext, Feature$FHE)
}

# ══ simple_bootstrap_example ═════════════════════════════
## SPARSE_ENCAPSULATED is recommended for CKKS bootstrapping.
## UNIFORM_TERNARY, used here, is the distribution of the homomorphic
## encryption security guidelines.
secret_key_dist <- SecretKeyDist$UNIFORM_TERNARY
parameters <- composite_parameters(secret_key_dist)

level_budget <- c(4L, 4L)
levels_available_after_bootstrap <- 10L
depth <- levels_available_after_bootstrap +
  get_bootstrap_depth(level_budget, secret_key_dist)
expect_equal(depth, 32L)

set_multiplicative_depth(parameters, depth)

cryptocontext <- gen_crypto_context(parameters)
enable_bootstrap_features(cryptocontext)

ring_dim <- ring_dimension(cryptocontext)
expect_equal(ring_dim, 4096L)
## This is the maximum number of slots that can be used for full packing.
num_slots <- ring_dim %/% 2L

eval_bootstrap_setup(cryptocontext, level_budget)

key_pair <- key_gen(cryptocontext)
eval_mult_key_gen(cryptocontext, key_pair@secret)
eval_bootstrap_key_gen(cryptocontext, key_pair@secret, num_slots)

## Two primes of 49 bits make up a level of 98 bits on a 64-bit register.
composite_degree <- get_composite_degree(cryptocontext)
expect_equal(composite_degree, 2L)

ptxt <- make_ckks_packed_plaintext(cryptocontext, x, 1L,
                                   composite_degree * (depth - 1L))
set_length(ptxt, encoded_length)
expect_equal(get_real_packed_value(ptxt), x)

ciph <- encrypt(key_pair@public, ptxt, cc = cryptocontext)

## Initial number of levels remaining
expect_equal(depth - get_level(ciph) %/% composite_degree, 1L)

## Perform the bootstrapping operation. The goal is to increase the
## number of levels remaining for HE computation.
ciphertext_after <- eval_bootstrap(ciph, 1L)

## Number of levels remaining after bootstrapping
expect_equal(depth - get_level(ciphertext_after) %/% composite_degree -
               (get_noise_scale_deg(ciphertext_after) - 1L),
             levels_available_after_bootstrap)

## Scaling factor after bootstrapping: that of a level, to the noise
## scale degree.
expect_equal(log2(get_scaling_factor(ciphertext_after)),
             get_noise_scale_deg(ciphertext_after) * dcrt_bits, tolerance = 1e-3)

result <- decrypt(ciphertext_after, key_pair@secret, cc = cryptocontext)
set_length(result, encoded_length)
## Output after bootstrapping
expect_equal(get_real_packed_value(result), x, tolerance = 1e-5)

actual_result <- get_complex_packed_value(result)
precision <- calculate_approximation_error(actual_result,
                                           get_complex_packed_value(ptxt))
## Estimated precision
expect_true(precision > 20)

# ══ simple_bootstrap_stc_first_example ═══════════════════
parameters <- composite_parameters(secret_key_dist)

level_budget <- c(4L, 4L)

## Note that the number of levels available after bootstrapping in the
## next bootstrapping call will be levels_available_after_bootstrap - 1
## because an additional level is used for scaling the ciphertext before
## next bootstrapping (in 64-bit CKKS bootstrapping)
levels_available_after_bootstrap <- 10L + level_budget[2]
depth <- levels_available_after_bootstrap +
  get_bootstrap_depth(c(level_budget[1], 0L), secret_key_dist)
expect_equal(depth, 32L)

set_multiplicative_depth(parameters, depth)

cryptocontext <- gen_crypto_context(parameters)
enable_bootstrap_features(cryptocontext)

ring_dim <- ring_dimension(cryptocontext)
expect_equal(ring_dim, 4096L)
num_slots <- ring_dim %/% 2L

eval_bootstrap_setup(cryptocontext, level_budget, c(0L, 0L), num_slots, 0L,
                     TRUE, TRUE)

key_pair <- key_gen(cryptocontext)
eval_mult_key_gen(cryptocontext, key_pair@secret)
eval_bootstrap_key_gen(cryptocontext, key_pair@secret, num_slots)

composite_degree <- get_composite_degree(cryptocontext)
expect_equal(composite_degree, 2L)

## We start with a depleted ciphertext that has used up all of its levels.
ptxt <- make_ckks_packed_plaintext(
  cryptocontext, x, 1L, composite_degree * (depth - 1L - level_budget[2]))
set_length(ptxt, encoded_length)
expect_equal(get_real_packed_value(ptxt), x)

ciph <- encrypt(key_pair@public, ptxt, cc = cryptocontext)

## Initial number of levels remaining
expect_equal(depth - get_level(ciph) %/% composite_degree, level_budget[2] + 1L)

ciphertext_after <- eval_bootstrap(ciph)

## Number of levels remaining after bootstrapping
expect_equal(depth - get_level(ciphertext_after) %/% composite_degree -
               (get_noise_scale_deg(ciphertext_after) - 1L),
             levels_available_after_bootstrap)

## Scaling factor after bootstrapping
expect_equal(log2(get_scaling_factor(ciphertext_after)),
             get_noise_scale_deg(ciphertext_after) * dcrt_bits, tolerance = 1e-3)

result <- decrypt(ciphertext_after, key_pair@secret, cc = cryptocontext)
set_length(result, encoded_length)
## Output after bootstrapping
expect_equal(get_real_packed_value(result), x, tolerance = 1e-4)

actual_result <- get_complex_packed_value(result)
precision <- calculate_approximation_error(actual_result,
                                           get_complex_packed_value(ptxt))
## Estimated precision
expect_true(precision > 14)

clear_fhe_state()
