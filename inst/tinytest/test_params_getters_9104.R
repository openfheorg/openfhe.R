## @openfhe-python: src/lib/bindings.cpp (bind_parameters Get*) [PARTIAL]
##
## CCParams getter surface across BFV/BGV/CKKS.
##
## Coverage strategy:
##   (a) Set a value via the setter, read it back via the
##       getter, assert equality — one round trip per exercised
##       getter per scheme.
##   (b) Call every getter on each scheme and confirm it does not
##       throw (no D013 carve-out for getters — discovery D013 says
##       getters are not disabled on any derived class).
##   (c) Verify SchemeId enum integer values round trip through
##       get_scheme for all three schemes.
##   (d) Confirm disabled-upstream parameters return sensible
##       defaults when their getter is called on a scheme whose
##       setter is disabled (e.g. get_plaintext_modulus on CKKS
##       returns 0, not a throw).
library(openfhe.R)

# ── Round-trip checks (set via setter, read via getter) ────

## BFV: set every exercised setter, then read each back via its getter.
p_bfv <- BFVParams(
  plaintext_modulus        = 65537L,
  multiplicative_depth     = 3L,
  security_level           = SecurityLevel$HEStd_128_classic,
  secret_key_dist          = SecretKeyDist$UNIFORM_TERNARY,
  batch_size               = 16L,
  ring_dim                 = 32768L,
  digit_size               = 2L,
  num_large_digits         = 3L,
  standard_deviation       = 3.19,
  multiparty_mode          = MultipartyMode$FIXED_NOISE_MULTIPARTY,
  threshold_num_of_parties = 2L,
  multiplication_technique = MultiplicationTechnique$HPS,
  key_switch_technique     = KeySwitchTechnique$BV
)
expect_equal(get_plaintext_modulus(p_bfv),     65537L)
expect_equal(get_multiplicative_depth(p_bfv),  3L)
expect_equal(get_security_level(p_bfv),        SecurityLevel$HEStd_128_classic)
expect_equal(get_secret_key_dist(p_bfv),       SecretKeyDist$UNIFORM_TERNARY)
expect_equal(get_batch_size(p_bfv),            16L)
expect_equal(get_ring_dim(p_bfv),              32768L)
expect_equal(get_digit_size(p_bfv),            2L)
expect_equal(get_num_large_digits(p_bfv),      3L)
expect_equal(get_standard_deviation(p_bfv),    3.19, tolerance = 1e-6)
expect_equal(get_multiparty_mode(p_bfv),       MultipartyMode$FIXED_NOISE_MULTIPARTY)
expect_equal(get_threshold_num_of_parties(p_bfv), 2L)
expect_equal(get_multiplication_technique(p_bfv), MultiplicationTechnique$HPS)
expect_equal(get_key_switch_technique(p_bfv),  KeySwitchTechnique$BV)

## BGV: round-trip the BGV-specific enum-valued setters.
p_bgv <- BGVParams(
  plaintext_modulus    = 786433L,
  multiplicative_depth = 2L,
  scaling_technique    = ScalingTechnique$FLEXIBLEAUTO,
  first_mod_size       = 60L,
  scaling_mod_size     = 58L,
  batch_size           = 8L,
  pre_num_hops         = 2L
)
expect_equal(get_plaintext_modulus(p_bgv),    786433L)
expect_equal(get_multiplicative_depth(p_bgv), 2L)
expect_equal(get_scaling_technique(p_bgv),    ScalingTechnique$FLEXIBLEAUTO)
expect_equal(get_first_mod_size(p_bgv),       60L)
expect_equal(get_scaling_mod_size(p_bgv),     58L)
expect_equal(get_batch_size(p_bgv),           8L)
expect_equal(get_pre_num_hops(p_bgv),         2L)

## CKKS: round-trip the CKKS-specific enum-valued setters.
p_ckks <- CKKSParams(
  multiplicative_depth = 4L,
  scaling_mod_size     = 50L,
  first_mod_size       = 60L,
  scaling_technique    = ScalingTechnique$FLEXIBLEAUTO,
  batch_size           = 8L,
  ring_dim             = 16384L,
  ckks_data_type       = CKKSDataType$REAL,
  interactive_boot_compression_level = CompressionLevel$COMPACT,
  execution_mode       = ExecutionMode$EXEC_EVALUATION,
  decryption_noise_mode = DecryptionNoiseMode$FIXED_NOISE_DECRYPT,
  noise_estimate       = 0.0,
  desired_precision    = 25.0,
  statistical_security = 30L,
  num_adversarial_queries = 1L,
  composite_degree     = 0L,
  register_word_size   = 32L
)
expect_equal(get_multiplicative_depth(p_ckks), 4L)
expect_equal(get_scaling_mod_size(p_ckks),     50L)
expect_equal(get_first_mod_size(p_ckks),       60L)
expect_equal(get_scaling_technique(p_ckks),    ScalingTechnique$FLEXIBLEAUTO)
expect_equal(get_batch_size(p_ckks),           8L)
expect_equal(get_ring_dim(p_ckks),             16384L)
expect_equal(get_ckks_data_type(p_ckks),       CKKSDataType$REAL)
expect_equal(get_interactive_boot_compression_level(p_ckks),
             CompressionLevel$COMPACT)
expect_equal(get_execution_mode(p_ckks),       ExecutionMode$EXEC_EVALUATION)
expect_equal(get_decryption_noise_mode(p_ckks),
             DecryptionNoiseMode$FIXED_NOISE_DECRYPT)
expect_equal(get_noise_estimate(p_ckks),    0.0)
expect_equal(get_desired_precision(p_ckks), 25.0)
## GetStatisticalSecurity / GetNumAdversarialQueries return double per
## the upstream header (the field is double, the setter signature
## takes uint32_t — that is a genuine upstream header inconsistency
## documented in pke_ccparams_getters.cpp).
expect_equal(get_statistical_security(p_ckks),    30.0)
expect_equal(get_num_adversarial_queries(p_ckks), 1.0)
expect_equal(get_composite_degree(p_ckks),        0L)
expect_equal(get_register_word_size(p_ckks),      32L)

# ── SchemeId enum values via get_scheme ─────────────────
## The raw SCHEME enum in scheme-id.h is INVALID=0, CKKSRNS=1,
## BFVRNS=2, BGVRNS=3. A freshly-constructed CCParams<T> is
## initialised with the matching scheme tag.
expect_equal(get_scheme(BFVParams()),  SchemeId$BFVRNS_SCHEME)
expect_equal(get_scheme(BGVParams()),  SchemeId$BGVRNS_SCHEME)
expect_equal(get_scheme(CKKSParams()), SchemeId$CKKSRNS_SCHEME)
expect_equal(length(SchemeId), 4L)

# ── No getter throws on any scheme (D013 for getters = no disables) ──
## Spot-check: every getter returns without throwing on each of the
## three param classes, even for parameters whose setter is disabled
## upstream for that scheme.
for (params_factory in list(BFVParams, BGVParams, CKKSParams)) {
  p <- params_factory()
  expect_silent(get_scheme(p))
  expect_silent(get_plaintext_modulus(p))
  expect_silent(get_digit_size(p))
  expect_silent(get_standard_deviation(p))
  expect_silent(get_secret_key_dist(p))
  expect_silent(get_max_relin_sk_deg(p))
  expect_silent(get_pre_mode(p))
  expect_silent(get_multiparty_mode(p))
  expect_silent(get_execution_mode(p))
  expect_silent(get_decryption_noise_mode(p))
  expect_silent(get_noise_estimate(p))
  expect_silent(get_desired_precision(p))
  expect_silent(get_statistical_security(p))
  expect_silent(get_num_adversarial_queries(p))
  expect_silent(get_threshold_num_of_parties(p))
  expect_silent(get_key_switch_technique(p))
  expect_silent(get_scaling_technique(p))
  expect_silent(get_batch_size(p))
  expect_silent(get_first_mod_size(p))
  expect_silent(get_num_large_digits(p))
  expect_silent(get_multiplicative_depth(p))
  expect_silent(get_scaling_mod_size(p))
  expect_silent(get_security_level(p))
  expect_silent(get_ring_dim(p))
  expect_silent(get_eval_add_count(p))
  expect_silent(get_key_switch_count(p))
  expect_silent(get_encryption_technique(p))
  expect_silent(get_multiplication_technique(p))
  expect_silent(get_pre_num_hops(p))
  expect_silent(get_interactive_boot_compression_level(p))
  expect_silent(get_composite_degree(p))
  expect_silent(get_register_word_size(p))
  expect_silent(get_ckks_data_type(p))
}

# ── Disabled-upstream getters return defaults, not errors ──
## D013 note: CKKS disables SetPlaintextModulus upstream. Calling
## get_plaintext_modulus on a default-constructed CKKSParams should
## return 0 (the default field value), not throw.
expect_equal(get_plaintext_modulus(CKKSParams()), 0L)

## BFV disables SetScalingTechnique. Calling get_scaling_technique
## on a default-constructed BFVParams should return the default
## enum value without throwing.
expect_silent(get_scaling_technique(BFVParams()))

## CKKS disables SetEvalAddCount / SetKeySwitchCount. Getters return
## the default 0.
expect_equal(get_eval_add_count(CKKSParams()),   0L)
expect_equal(get_key_switch_count(CKKSParams()), 0L)
