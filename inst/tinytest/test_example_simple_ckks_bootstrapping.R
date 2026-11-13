## OPENFHE PYTHON SOURCE: examples/pke/simple-ckks-bootstrapping.py
##
## @openfhe-python: simple-ckks-bootstrapping.py [FULL]
##
## CKKS bootstrapping with full packing, in its two orders: the default
## one (ModRaise first), and slots-to-coefficients first.
library(openfhe.R)

if (!tinytest::at_home() && Sys.getenv("CI") != "true") {
  exit_file("skipped on CRAN: heavy bootstrapping (runs on CI and at_home)")
}

x <- c(0.25, 0.5, 0.75, 1.0, 2.0, 3.0, 4.0, 5.0)
encoded_length <- length(x)

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

enable_bootstrap_features <- function(cryptocontext) {
  enable_feature(cryptocontext, Feature$PKE)
  enable_feature(cryptocontext, Feature$KEYSWITCH)
  enable_feature(cryptocontext, Feature$LEVELEDSHE)
  enable_feature(cryptocontext, Feature$ADVANCEDSHE)
  enable_feature(cryptocontext, Feature$FHE)
}

# ══ simple_bootstrap_example ═════════════════════════════
secret_key_dist <- SecretKeyDist$UNIFORM_TERNARY
parameters <- bootstrap_parameters(secret_key_dist)

level_budget <- c(4L, 4L)
levels_available_after_bootstrap <- 10L
depth <- levels_available_after_bootstrap +
  get_bootstrap_depth(level_budget, secret_key_dist)
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

key_indices <-
  get_existing_eval_automorphism_key_indices(get_key_tag(key_pair@secret))
## Number of bootstrapping automorphism keys
expect_equal(length(key_indices), 34L)

ptxt <- make_ckks_packed_plaintext(cryptocontext, x, 1L, depth - 1L)
set_length(ptxt, encoded_length)
expect_equal(get_real_packed_value(ptxt), x)

ciph <- encrypt(key_pair@public, ptxt, cc = cryptocontext)
## Initial number of levels remaining
expect_equal(depth - get_level(ciph), 1L)

ciphertext_after <- eval_bootstrap(ciph)
## Number of levels remaining after bootstrapping
expect_equal(depth - get_level(ciphertext_after) -
               (get_noise_scale_deg(ciphertext_after) - 1L),
             levels_available_after_bootstrap)

result <- decrypt(ciphertext_after, key_pair@secret, cc = cryptocontext)
set_length(result, encoded_length)
## Output after bootstrapping
expect_equal(get_real_packed_value(result), x, tolerance = 1e-4)

# ══ simple_bootstrap_stc_example ═════════════════════════
parameters <- bootstrap_parameters(secret_key_dist)

level_budget <- c(4L, 4L)
levels_available_after_bootstrap <- 10L + level_budget[2]
depth <- levels_available_after_bootstrap +
  get_bootstrap_depth(c(level_budget[1], 0L), secret_key_dist)
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

ptxt <- make_ckks_packed_plaintext(cryptocontext, x, 1L,
                                   depth - 1L - level_budget[2], NULL, num_slots)
set_length(ptxt, encoded_length)
expect_equal(get_real_packed_value(ptxt), x)

ciph <- encrypt(key_pair@public, ptxt, cc = cryptocontext)
## Initial number of levels remaining: the levels that the
## slots-to-coefficients step consumes, and one more.
expect_equal(depth - get_level(ciph), level_budget[2] + 1L)

ciphertext_after <- eval_bootstrap(ciph)
## Number of levels remaining after bootstrapping
expect_equal(depth - get_level(ciphertext_after) -
               (get_noise_scale_deg(ciphertext_after) - 1L),
             levels_available_after_bootstrap)

result <- decrypt(ciphertext_after, key_pair@secret, cc = cryptocontext)
set_length(result, encoded_length)
## Output after bootstrapping
expect_equal(get_real_packed_value(result), x, tolerance = 1e-4)

clear_fhe_state()
