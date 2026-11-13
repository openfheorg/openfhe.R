## OPENFHE PYTHON SOURCE: examples/pke/advanced-ckks-bootstrapping.py
##
## @openfhe-python: advanced-ckks-bootstrapping.py [FULL]
##
## CKKS bootstrapping with sparse packing.
library(openfhe.R)

if (!tinytest::at_home() && Sys.getenv("CI") != "true") {
  exit_file("skipped on CRAN: heavy bootstrapping (runs on CI and at_home)")
}

bootstrap_example <- function(num_slots) {
  # Step 1: Set CryptoContext
  parameters <- CKKSParams()

  ## A1) Secret key distribution. SPARSE_ENCAPSULATED is recommended for
  ## CKKS bootstrapping; UNIFORM_TERNARY, used here, is the distribution
  ## of the homomorphic encryption security guidelines.
  secret_key_dist <- SecretKeyDist$UNIFORM_TERNARY
  set_secret_key_dist(parameters, secret_key_dist)

  ## A2) Desired security level. "NotSet" lets the example run with a
  ## small ring dimension; not for production.
  set_security_level(parameters, SecurityLevel$HEStd_NotSet)
  set_ring_dim(parameters, 2^12)

  ## A3) Key switching parameters. HYBRID with a digit size of 3 is the
  ## default.
  set_num_large_digits(parameters, 3L)
  set_key_switch_technique(parameters, KeySwitchTechnique$HYBRID)

  ## A4) Scaling parameters.
  if (get_native_int() == 128L) {
    ## Only FIXEDMANUAL and FIXEDAUTO are supported for 128-bit CKKS
    ## bootstrapping.
    rescale_tech <- ScalingTechnique$FIXEDAUTO
    dcrt_bits <- 78L
    first_mod <- 89L
  } else {
    ## All modes are supported for 64-bit CKKS bootstrapping.
    rescale_tech <- ScalingTechnique$FLEXIBLEAUTO
    dcrt_bits <- 59L
    first_mod <- 60L
  }
  set_scaling_mod_size(parameters, dcrt_bits)
  set_scaling_technique(parameters, rescale_tech)
  set_first_mod_size(parameters, first_mod)

  ## A4) Bootstrapping parameters. The budget of levels consumed in
  ## encoding and decoding, respectively.
  level_budget <- c(3L, 3L)
  ## The giant step of the baby-step-giant-step algorithm in the linear
  ## transforms; c(0, 0) lets OpenFHE choose.
  bsgs_dim <- c(0L, 0L)

  ## A5) Multiplicative depth: the levels that bootstrapping itself
  ## consumes, plus the levels wanted after it.
  levels_available_after_bootstrap <- 10L
  depth <- levels_available_after_bootstrap +
    get_bootstrap_depth(level_budget, secret_key_dist)
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
  expect_equal(ring_dim, 4096L)

  # Step 2: Precomputations for bootstrapping
  eval_bootstrap_setup(cryptocontext, level_budget, bsgs_dim, num_slots)

  # Step 3: Key Generation
  key_pair <- key_gen(cryptocontext)
  eval_mult_key_gen(cryptocontext, key_pair@secret)
  ## Generate bootstrapping keys.
  eval_bootstrap_key_gen(cryptocontext, key_pair@secret, num_slots)

  # Step 4: Encoding and encryption of inputs
  ## Generate random input
  x <- runif(num_slots, 0, 1)

  ## The number of slots is given to gain performance. We start with a
  ## depleted ciphertext that has used up all of its levels.
  ptxt <- make_ckks_packed_plaintext(cryptocontext, x, 1L, depth - 1L, NULL,
                                     num_slots)
  set_length(ptxt, num_slots)
  expect_equal(get_real_packed_value(ptxt), x)

  ## Encrypt the encoded vectors
  ciph <- encrypt(key_pair@public, ptxt, cc = cryptocontext)

  ## Initial number of levels remaining
  expect_equal(depth - get_level(ciph), 1L)

  # Step 5: Perform the bootstrapping operation. The goal is to increase
  # the number of levels remaining for HE computation.
  ciphertext_after <- eval_bootstrap(ciph)

  ## Number of levels remaining after bootstrapping. The example prints
  ## depth - level; a ciphertext whose noise scale degree is 2 still owes
  ## one rescaling, which leaves the levels asked for.
  levels_remaining <- depth - get_level(ciphertext_after)
  expect_equal(levels_remaining - (get_noise_scale_deg(ciphertext_after) - 1L),
               levels_available_after_bootstrap)
  expect_true(levels_remaining > 1L)

  # Step 7: Decryption and output
  result <- decrypt(ciphertext_after, key_pair@secret, cc = cryptocontext)
  set_length(result, num_slots)
  ## Output after bootstrapping
  expect_equal(get_real_packed_value(result), x, tolerance = 1e-4)
}

## The example runs with 8 slots and ring dimension 4096 to illustrate
## bootstrapping with a sparse plaintext.
set.seed(1)
bootstrap_example(8L)

clear_fhe_state()
