## @openfhe-python: src/lib/bindings.cpp (CryptoContext Get*) [PARTIAL]
##
## CryptoContext getter fleet. Covers both direct
## getters and lambda-routed (via GetCryptoParameters()) getters
## across BFV, BGV, and CKKS contexts.
library(openfhe.R)

# ── BFV context ─────────────────────────────────────────
cc_bfv <- fhe_context(
  "BFV",
  plaintext_modulus        = 65537L,
  multiplicative_depth     = 2L,
  security_level           = SecurityLevel$HEStd_128_classic,
  batch_size               = 8L
)

## Direct getters
expect_true(S7::S7_inherits(get_crypto_parameters(cc_bfv), CryptoParameters))
expect_true(S7::S7_inherits(get_element_params(cc_bfv), ElementParams))
expect_true(S7::S7_inherits(get_encoding_params(cc_bfv), EncodingParams))
expect_equal(get_key_gen_level(cc_bfv), 0L)
expect_true(get_cyclotomic_order(cc_bfv) > 0L)
expect_equal(get_cyclotomic_order(cc_bfv), 2L * ring_dimension(cc_bfv))

## Setter round-trip for key_gen_level
set_key_gen_level(cc_bfv, 1L)
expect_equal(get_key_gen_level(cc_bfv), 1L)
set_key_gen_level(cc_bfv, 0L)  # restore

## Lambda-routed getters
expect_equal(get_plaintext_modulus(cc_bfv), 65537L)
expect_equal(get_multiplicative_depth(cc_bfv), 2L)
expect_true(get_batch_size(cc_bfv) > 0L)
## Scheme-parameter getters that use the RNS cast. Per discovery
## D014, CryptoParametersBFVRNS disables GetNoiseEstimate and
## GetPRENumHops via DISABLED_FOR_BFVRNS_PARAMS throw overrides;
## calling them on a BFV context raises a cli-routed error
## (OpenFHE error in CryptoContext::GetFoo: ... not available for
## BFVRNS). The non-disabled ones return values silently.
expect_silent(get_scaling_technique(cc_bfv))
expect_silent(get_digit_size(cc_bfv))
expect_error(get_noise_estimate(cc_bfv), pattern = "not available for BFVRNS")
expect_silent(get_eval_add_count(cc_bfv))
expect_silent(get_key_switch_count(cc_bfv))
expect_error(get_pre_num_hops(cc_bfv), pattern = "not available for BFVRNS")
expect_silent(get_register_word_size(cc_bfv))
expect_silent(get_composite_degree(cc_bfv))
expect_silent(get_key_switch_technique(cc_bfv))
expect_silent(get_ckks_data_type(cc_bfv))

# ── BGV context ─────────────────────────────────────────
cc_bgv <- fhe_context(
  "BGV",
  plaintext_modulus    = 65537L,
  multiplicative_depth = 2L
)
expect_equal(get_plaintext_modulus(cc_bgv), 65537L)
expect_equal(get_multiplicative_depth(cc_bgv), 2L)
expect_silent(get_scaling_technique(cc_bgv))
## BGVRNS disables GetNoiseEstimate (D014).
expect_error(get_noise_estimate(cc_bgv), pattern = "not available for BGVRNS")
expect_true(S7::S7_inherits(get_crypto_parameters(cc_bgv), CryptoParameters))

# ── CKKS context ────────────────────────────────────────
cc_ckks <- fhe_context(
  "CKKS",
  multiplicative_depth = 4L,
  scaling_mod_size     = 50L,
  batch_size           = 8L,
  scaling_technique    = ScalingTechnique$FIXEDMANUAL
)
expect_equal(get_multiplicative_depth(cc_ckks), 4L)
expect_equal(get_scaling_technique(cc_ckks), ScalingTechnique$FIXEDMANUAL)
expect_true(S7::S7_inherits(get_element_params(cc_ckks), ElementParams))
expect_true(S7::S7_inherits(get_encoding_params(cc_ckks), EncodingParams))
expect_true(openfhe.R:::ptr_is_valid(get_element_params(cc_ckks)))
expect_true(openfhe.R:::ptr_is_valid(get_encoding_params(cc_ckks)))
expect_equal(get_ckks_data_type(cc_ckks), CKKSDataType$REAL)
## CKKSRNS disables GetEvalAddCount, GetKeySwitchCount, GetPRENumHops (D014).
expect_error(get_eval_add_count(cc_ckks),  pattern = "not available for CKKSRNS")
expect_error(get_key_switch_count(cc_ckks), pattern = "not available for CKKSRNS")
expect_error(get_pre_num_hops(cc_ckks),     pattern = "not available for CKKSRNS")

# ── Shared-generic dispatch correctness ─────────────────
## The same `get_multiplicative_depth` generic dispatches to
## both CCParams and CryptoContext. Verify both
## dispatch to their respective C++ methods.
p_bfv <- BFVParams(plaintext_modulus = 65537L, multiplicative_depth = 3L)
expect_equal(get_multiplicative_depth(p_bfv),  3L)  # CCParams method
expect_equal(get_multiplicative_depth(cc_bfv), 2L)  # CryptoContext method (from fhe_context default)

## Same for get_scaling_technique — CCParams and
## CryptoContext share the same generic.
expect_equal(get_scaling_technique(cc_ckks), ScalingTechnique$FIXEDMANUAL)

# ── get_element_params(cc) returns a usable ElementParams ──
## This is the first R-side way to obtain a non-null ElementParams
## (class scaffolded earlier; the constructor path lands here).
## The returned object's ptr must be valid.
ep <- get_element_params(cc_ckks)
expect_true(openfhe.R:::ptr_is_valid(ep))
expect_silent(print(ep))
