## OPENFHE PYTHON SOURCE: examples/pke/ckks-release-memory.py
##
## @openfhe-python: ckks-release-memory.py [PARTIAL: Linux-only RSS reporting omitted]
##
## eval_bootstrap_setup() caches precomputed data in the CKKS scheme.
## The example compares clear_bootstrap_precom() with releasing all
## contexts while keeping the local CryptoContext handle alive. Only the
## setup is run, never a bootstrapping, so the file runs everywhere.
library(openfhe.R)

build_bootstrap_context <- function() {
  parameters <- CKKSParams()
  ## SPARSE_ENCAPSULATED is recommended for CKKS bootstrapping.
  ## UNIFORM_TERNARY, used here, is the distribution of the homomorphic
  ## encryption security guidelines.
  sk_dist <- SecretKeyDist$UNIFORM_TERNARY
  set_secret_key_dist(parameters, sk_dist)
  set_security_level(parameters, SecurityLevel$HEStd_NotSet)
  set_ring_dim(parameters, 2^12)

  if (get_native_int() == 128L) {
    set_scaling_mod_size(parameters, 78L)
    set_first_mod_size(parameters, 89L)
    set_scaling_technique(parameters, ScalingTechnique$FIXEDAUTO)
  } else {
    set_scaling_mod_size(parameters, 59L)
    set_first_mod_size(parameters, 60L)
    set_scaling_technique(parameters, ScalingTechnique$FLEXIBLEAUTO)
  }

  level_budget <- c(4L, 4L)
  depth <- 10L + get_bootstrap_depth(level_budget, sk_dist)
  set_multiplicative_depth(parameters, depth)

  cc <- gen_crypto_context(parameters)
  enable_feature(cc, Feature$PKE)
  enable_feature(cc, Feature$KEYSWITCH)
  enable_feature(cc, Feature$LEVELEDSHE)
  enable_feature(cc, Feature$ADVANCEDSHE)
  enable_feature(cc, Feature$FHE)
  cc
}

cc <- build_bootstrap_context()
ring_dim <- ring_dimension(cc)
num_slots <- ring_dim %/% 2L

expect_equal(ring_dim, 4096L)

## Set up, then clear the precomputed data.
expect_silent(eval_bootstrap_setup(cc, c(4L, 4L), c(0L, 0L), num_slots))
expect_silent(clear_bootstrap_precom(cc))

## The setup can be repeated on the same context after clearing; then
## clear again and release all contexts.
expect_silent(eval_bootstrap_setup(cc, c(4L, 4L), c(0L, 0L), num_slots))
expect_silent(clear_bootstrap_precom(cc))
expect_silent(clear_fhe_state("contexts"))

## The local handle outlives the release.
expect_equal(ring_dimension(cc), ring_dim)

clear_fhe_state()
