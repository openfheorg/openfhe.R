## OPENFHE PYTHON SOURCE: examples/pke/iterative-ckks-bootstrapping.py
##
## @openfhe-python: iterative-ckks-bootstrapping.py [FULL]
##
## Two iterations of CKKS bootstrapping to improve its precision, in the
## default order (ModRaise first) and slots-to-coefficients first.
library(openfhe.R)

if (!tinytest::at_home() && Sys.getenv("CI") != "true") {
  exit_file("skipped on CRAN: heavy bootstrapping (runs on CI and at_home)")
}

calculate_approximation_error <- function(result, expected_result) {
  if (length(result) != length(expected_result)) {
    stop("Cannot compare vectors with different numbers of elements")
  }
  ## using the infinity norm; error is abs of the difference of real parts
  max_error <- max(abs(Re(result) - Re(expected_result)))
  ## return absolute value of log base 2 of the error
  abs(log2(max_error))
}

## The parameters the two functions of the example share.
bootstrap_parameters <- function(secret_key_dist) {
  parameters <- CKKSParams()
  set_secret_key_dist(parameters, secret_key_dist)
  set_security_level(parameters, SecurityLevel$HEStd_NotSet)
  set_ring_dim(parameters, 2^12)

  if (get_native_int() == 128L) {
    rescale_tech <- ScalingTechnique$FIXEDAUTO
    dcrt_bits <- 78L
    first_mod <- 89L
  } else {
    rescale_tech <- ScalingTechnique$FLEXIBLEAUTO
    dcrt_bits <- 59L
    first_mod <- 60L
  }
  set_scaling_mod_size(parameters, dcrt_bits)
  set_scaling_technique(parameters, rescale_tech)
  set_first_mod_size(parameters, first_mod)
  parameters
}

## Enable features. FHE must be enabled to use bootstrapping.
enable_bootstrap_features <- function(cryptocontext) {
  enable_feature(cryptocontext, Feature$PKE)
  enable_feature(cryptocontext, Feature$KEYSWITCH)
  enable_feature(cryptocontext, Feature$LEVELEDSHE)
  enable_feature(cryptocontext, Feature$ADVANCEDSHE)
  enable_feature(cryptocontext, Feature$FHE)
}

set.seed(1)

# ══ iterative_bootstrap_example ══════════════════════════
# Step 1: Set CryptoContext
secret_key_dist <- SecretKeyDist$UNIFORM_TERNARY
parameters <- bootstrap_parameters(secret_key_dist)

## The number of iterations to run bootstrapping; 1 or 2 are supported.
## Two iterations should give approximately double the precision of one.
num_iterations <- 2L

level_budget <- c(3L, 3L)
bsgs_dim <- c(0L, 0L)

levels_available_after_bootstrap <- 10L
## Each iteration on top of the first consumes one more level.
depth <- levels_available_after_bootstrap +
  get_bootstrap_depth(level_budget, secret_key_dist) + (num_iterations - 1L)
set_multiplicative_depth(parameters, depth)

cryptocontext <- gen_crypto_context(parameters)
enable_bootstrap_features(cryptocontext)

expect_equal(ring_dimension(cryptocontext), 4096L)

# Step 2: Precomputations for bootstrapping
## We use a sparse packing
num_slots <- 8L
eval_bootstrap_setup(cryptocontext, level_budget, bsgs_dim, num_slots)

# Step 3: Key generation
key_pair <- key_gen(cryptocontext)
eval_mult_key_gen(cryptocontext, key_pair@secret)
## Generate bootstrapping keys.
eval_bootstrap_key_gen(cryptocontext, key_pair@secret, num_slots)

# Step 4: Encoding and encryption of inputs
## Generate random input
x <- runif(num_slots, 0, 1)

## We start with a depleted ciphertext that has used up all of its levels.
ptxt <- make_ckks_packed_plaintext(cryptocontext, x, 1L, depth - 1L, NULL,
                                   num_slots)
set_length(ptxt, num_slots)
expect_equal(get_real_packed_value(ptxt), x)

## Encrypt the encoded vectors
ciph <- encrypt(key_pair@public, ptxt, cc = cryptocontext)

# Step 5: Measure the precision of a single bootstrapping operation.
ciphertext_after <- eval_bootstrap(ciph)

result <- decrypt(ciphertext_after, key_pair@secret, cc = cryptocontext)
set_length(result, num_slots)
precision <- floor(calculate_approximation_error(
  get_complex_packed_value(result), get_complex_packed_value(ptxt)))
## Bootstrapping precision after 1 iteration
expect_true(precision >= 17)

## Set the precision equal to empirically measured value after many
## test runs.
precision <- 17L

# Step 6: Run bootstrapping with multiple iterations
ciphertext_two_iterations <- eval_bootstrap(ciph, num_iterations, precision)

result_two_iterations <- decrypt(ciphertext_two_iterations, key_pair@secret,
                                 cc = cryptocontext)
set_length(result_two_iterations, num_slots)
actual_result <- get_complex_packed_value(result_two_iterations)

## Output after two iterations of bootstrapping
expect_equal(Re(actual_result), x, tolerance = 1e-8)
precision_multiple_iterations <-
  calculate_approximation_error(actual_result, get_complex_packed_value(ptxt))

## Bootstrapping precision after 2 iterations: approximately double that
## of one iteration.
expect_true(precision_multiple_iterations > 30)
## Number of levels remaining after 2 bootstrappings
expect_equal(depth - get_level(ciphertext_two_iterations),
             levels_available_after_bootstrap + 1L)

# ══ iterative_bootstrap_stc_example ══════════════════════
# Step 1: Set CryptoContext
parameters <- bootstrap_parameters(secret_key_dist)

num_iterations <- 2L

level_budget <- c(3L, 3L)
bsgs_dim <- c(0L, 0L)

levels_available_after_bootstrap <- 10L + level_budget[2]
depth <- levels_available_after_bootstrap +
  get_bootstrap_depth(level_budget, secret_key_dist, approx_mod_depth = 9L)
set_multiplicative_depth(parameters, depth)

cryptocontext <- gen_crypto_context(parameters)
enable_bootstrap_features(cryptocontext)

expect_equal(ring_dimension(cryptocontext), 4096L)

# Step 2: Precomputations for bootstrapping
## We use a sparse packing
num_slots <- 8L
eval_bootstrap_setup(cryptocontext, level_budget, bsgs_dim, num_slots, 0L,
                     TRUE, TRUE)

# Step 3: Key generation
key_pair <- key_gen(cryptocontext)
eval_mult_key_gen(cryptocontext, key_pair@secret)
## Generate bootstrapping keys.
eval_bootstrap_key_gen(cryptocontext, key_pair@secret, num_slots)

# Step 4: Encoding and encryption of inputs
## Generate random input
x <- runif(num_slots, 0, 2)

## We start with a depleted ciphertext that has used up all of its levels.
ptxt <- make_ckks_packed_plaintext(cryptocontext, x, 1L,
                                   depth - 1L - level_budget[2], NULL, num_slots)
set_length(ptxt, num_slots)
expect_equal(get_real_packed_value(ptxt), x)

## Encrypt the encoded vectors
ciph <- encrypt(key_pair@public, ptxt, cc = cryptocontext)

# Step 5: Measure the precision of a single bootstrapping operation.
ciphertext_after <- eval_bootstrap(ciph)

result <- decrypt(ciphertext_after, key_pair@secret, cc = cryptocontext)
set_length(result, num_slots)
precision <- floor(calculate_approximation_error(
  get_complex_packed_value(result), get_complex_packed_value(ptxt)))
## Bootstrapping precision after 1 iteration
expect_true(precision >= 17)
precision_one_iteration <- precision

## Set the precision equal to empirically measured value after many
## test runs.
precision <- precision - 5

# Step 6: Run bootstrapping with multiple iterations
ciphertext_two_iterations <- eval_bootstrap(ciph, num_iterations, precision)

result_two_iterations <- decrypt(ciphertext_two_iterations, key_pair@secret,
                                 cc = cryptocontext)
set_length(result_two_iterations, num_slots)
actual_result <- get_complex_packed_value(result_two_iterations)

## Output after two iterations of bootstrapping
expect_equal(Re(actual_result), x, tolerance = 1e-5)
precision_multiple_iterations <-
  calculate_approximation_error(actual_result, get_complex_packed_value(ptxt))

## Bootstrapping precision after 2 iterations
expect_true(precision_multiple_iterations >= precision_one_iteration)
## Number of levels remaining after 2 bootstrappings. (The example
## misplaces a parenthesis in this first print; the count is the one of
## its second print, below.)
levels_remaining <- depth - get_level(ciphertext_two_iterations) -
  (get_noise_scale_deg(ciphertext_two_iterations) - 1L)
expect_equal(levels_remaining, 15L)

## With slots-to-coefficients first and 2 iterations, scaling down the
## default correction factor may give a higher final precision. This is
## most pronounced for sparse packing.
default_correction_factor <- get_ckks_boot_correction_factor(cryptocontext)
set_ckks_boot_correction_factor(cryptocontext, default_correction_factor - 5L)
## Correction factor used
expect_equal(get_ckks_boot_correction_factor(cryptocontext),
             default_correction_factor - 5L)

ciphertext_after <- eval_bootstrap(ciph)
result <- decrypt(ciphertext_after, key_pair@secret, cc = cryptocontext)
set_length(result, num_slots)
precision <- floor(calculate_approximation_error(
  get_complex_packed_value(result), get_complex_packed_value(ptxt)))
## Bootstrapping precision after 1 iteration: lower than with the
## default correction factor.
expect_true(precision >= 8)
expect_true(precision < precision_one_iteration)

## Set precision equal to empirically measured value after many test
## runs. One could add a buffer to reduce this value as below.
precision <- precision - 5

ciphertext_two_iterations <- eval_bootstrap(ciph, num_iterations, precision)
result_two_iterations <- decrypt(ciphertext_two_iterations, key_pair@secret,
                                 cc = cryptocontext)
actual_result <- get_complex_packed_value(result_two_iterations)
expect_equal(length(actual_result), num_slots)

## Output after two iterations of bootstrapping
expect_equal(Re(actual_result), x, tolerance = 1e-7)
precision_multiple_iterations_scaled <-
  calculate_approximation_error(actual_result, get_complex_packed_value(ptxt))

## Bootstrapping precision after 2 iterations: well above that of one
## iteration with the default correction factor.
expect_true(precision_multiple_iterations_scaled > precision_one_iteration + 3)
## Number of levels remaining after 2 bootstrappings
expect_equal(depth - get_level(ciphertext_two_iterations) -
               (get_noise_scale_deg(ciphertext_two_iterations) - 1L),
             15L)

clear_fhe_state()
