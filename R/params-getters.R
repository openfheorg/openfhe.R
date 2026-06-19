## OPENFHE PYTHON SOURCE: src/lib/bindings.cpp (bind_parameters getters)
##
## S7 generic + per-scheme method surface for all 33
## `CCParams<T>::Get*` methods declared in the common-base Params
## class. Every generic dispatches on the param class (BFVParams,
## BGVParams, CKKSParams) and routes to the matching
## `<Scheme>Params__Get<Name>` cpp11 binding in
## `src/pke_ccparams_getters.cpp`.
##
## Getter surface is uniform across schemes: the
## derived-class CCParams<T> specializations override setters (not
## getters) with DISABLED_FOR_XXX throwing bodies, so no getter
## throws on any scheme. If a parameter is disabled upstream for a
## particular scheme, its getter on that scheme returns the default
## value of the underlying field (typically 0 for uint32_t, 0.0 for
## double, or the enum's zero sentinel) rather than a throw.
##
## Four getters carry full documentation: get_ring_dim,
## get_plaintext_modulus, get_digit_size, get_composite_degree.
## The other 29 carry a minimal doc block.

#' CCParams getters (all schemes)
#'
#' Retrieve a parameter from a `BFVParams`, `BGVParams`, or
#' `CKKSParams` object. Each getter wraps the corresponding upstream
#' `CCParams<T>::Get*` method and returns its value unchanged.
#'
#' Several parameters are "disabled" on specific schemes (their
#' setters throw at runtime). For a disabled
#' scheme/parameter combination the getter returns the default value
#' of the underlying field (typically `0L` for `uint32_t`, `0` for
#' `double`, or the enum's zero sentinel) rather than throwing. This
#' is benign — the field was never set so its default is all the
#' information available — but it means e.g. calling
#' `get_plaintext_modulus(params)` on a `CKKSParams` object returns
#' `0` rather than a meaningful modulus.
#'
#' @section Return-type note:
#' `get_statistical_security` and `get_num_adversarial_queries`
#' return `double` rather than `integer`. This matches an
#' inconsistency in the upstream Params base class: the
#' corresponding setters take `uint32_t` but the getters return
#' `double`. The underlying field is a `double` — R binds per the
#' header, not per the setter signature.
#'
#' `get_plaintext_modulus` returns an R `integer` on 32-bit-safe
#' values; for moduli that exceed the 32-bit signed integer range
#' the return value is a `numeric` (double) carrying a losslessly
#' rounded 53-bit integer.
#'
#' @param params A `BFVParams`, `BGVParams`, or `CKKSParams`.
#' @param ... Reserved for future method-specific arguments (currently
#'   unused — all getters take only `params`).
#' @return The underlying parameter value. Types vary per getter.
#' @name ccparams_getters
NULL

# ── Exercised getters (full doc) ────────────────────────

#' @describeIn ccparams_getters Ring dimension `n` of the lattice
#'   the scheme operates over. For RLWE schemes this is the
#'   cyclotomic ring's degree `n = phi(m)` (Euler's totient of the
#'   cyclotomic order) and must be a power of two. The ring
#'   dimension is the load-bearing cryptographic parameter —
#'   security level and multiplicative depth together pin the
#'   minimum `n`, and most runtime costs scale as `O(n log n)`
#'   per homomorphic operation.
#' @export
get_ring_dim <- new_generic("get_ring_dim", "params")

#' @describeIn ccparams_getters Plaintext modulus `t` for the BFV
#'   and BGV plaintext spaces. BFV/BGV plaintexts are elements of
#'   `Z_t[x]/Phi_m(x)` and every homomorphic operation is performed
#'   modulo `t`. On a `CKKSParams` object this returns the default
#'   field value (`0`) because CKKS does not use a plaintext
#'   modulus.
#' @export
get_plaintext_modulus <- new_generic("get_plaintext_modulus", "params")

#' @describeIn ccparams_getters Digit size `r` for BV key-switching:
#'   the base-`2^r` digit decomposition of the ciphertext during a
#'   key-switch. Larger values decrease the number of digit
#'   multiplications at the cost of larger per-digit noise.
#' @export
get_digit_size <- new_generic("get_digit_size", "params")

#' @describeIn ccparams_getters Composite-scaling degree for the
#'   CKKS `COMPOSITESCALINGAUTO`/`COMPOSITESCALINGMANUAL` scaling
#'   techniques. Only meaningful when
#'   `scaling_technique = ScalingTechnique$COMPOSITESCALING*`;
#'   `0` under the default FLEXIBLEAUTO path.
#' @export
get_composite_degree <- new_generic("get_composite_degree", "params")

# ── Additional getters (minimal doc) ───────────────

#' @describeIn ccparams_getters integer scheme
#'   identifier (see `SchemeId` for the enum values).
#' @export
get_scheme <- new_generic("get_scheme", "params")

#' @describeIn ccparams_getters standard deviation
#'   of the Gaussian error distribution.
#' @export
get_standard_deviation <- new_generic("get_standard_deviation", "params")

#' @describeIn ccparams_getters secret-key
#'   distribution (see `SecretKeyDist`).
#' @export
get_secret_key_dist <- new_generic("get_secret_key_dist", "params")

#' @describeIn ccparams_getters maximum
#'   relinearization secret-key degree.
#' @export
get_max_relin_sk_deg <- new_generic("get_max_relin_sk_deg", "params")

#' @describeIn ccparams_getters proxy
#'   re-encryption mode (see `PREMode`).
#' @export
get_pre_mode <- new_generic("get_pre_mode", "params")

#' @describeIn ccparams_getters multiparty mode
#'   (see `MultipartyMode`).
#' @export
get_multiparty_mode <- new_generic("get_multiparty_mode", "params")

#' @describeIn ccparams_getters execution mode
#'   (see `ExecutionMode`).
#' @export
get_execution_mode <- new_generic("get_execution_mode", "params")

#' @describeIn ccparams_getters decryption noise
#'   mode (see `DecryptionNoiseMode`).
#' @export
get_decryption_noise_mode <- new_generic("get_decryption_noise_mode", "params")

#' @describeIn ccparams_getters noise-flooding
#'   noise estimate (double).
#' @export
get_noise_estimate <- new_generic("get_noise_estimate", "params")

#' @describeIn ccparams_getters noise-flooding
#'   target precision (double, bits).
#' @export
get_desired_precision <- new_generic("get_desired_precision", "params")

#' @describeIn ccparams_getters statistical
#'   security parameter. Return type is `double` per header
#'   inconsistency; see the Return-type note.
#' @export
get_statistical_security <- new_generic("get_statistical_security", "params")

#' @describeIn ccparams_getters upper bound on
#'   adversarial queries. Return type is `double` per header
#'   inconsistency; see the Return-type note.
#' @export
get_num_adversarial_queries <- new_generic("get_num_adversarial_queries", "params")

#' @describeIn ccparams_getters threshold-FHE
#'   party count.
#' @export
get_threshold_num_of_parties <- new_generic("get_threshold_num_of_parties", "params")

#' @describeIn ccparams_getters key-switching
#'   technique (see `KeySwitchTechnique`).
#' @export
get_key_switch_technique <- new_generic("get_key_switch_technique", "params")

#' @describeIn ccparams_getters scaling technique
#'   (see `ScalingTechnique`).
#' @export
get_scaling_technique <- new_generic("get_scaling_technique", "params")

#' @describeIn ccparams_getters SIMD batch size.
#' @export
get_batch_size <- new_generic("get_batch_size", "params")

#' @describeIn ccparams_getters bit size of the
#'   first (largest) prime in the CKKS modulus chain.
#' @export
get_first_mod_size <- new_generic("get_first_mod_size", "params")

#' @describeIn ccparams_getters number of large
#'   digits for HYBRID key switching.
#' @export
get_num_large_digits <- new_generic("get_num_large_digits", "params")

#' @describeIn ccparams_getters configured
#'   multiplicative depth. Note: this is the depth the context was
#'   constructed to support, not the current depth budget after
#'   operations.
#' @export
get_multiplicative_depth <- new_generic("get_multiplicative_depth", "params")

#' @describeIn ccparams_getters bit size of each
#'   CKKS scaling modulus.
#' @export
get_scaling_mod_size <- new_generic("get_scaling_mod_size", "params")

#' @describeIn ccparams_getters target security
#'   level (see `SecurityLevel`).
#' @export
get_security_level <- new_generic("get_security_level", "params")

#' @describeIn ccparams_getters BFV/BGV
#'   noise-flooding hint: maximum additions between multiplications.
#' @export
get_eval_add_count <- new_generic("get_eval_add_count", "params")

#' @describeIn ccparams_getters BFV/BGV
#'   noise-flooding hint: maximum key-switch count.
#' @export
get_key_switch_count <- new_generic("get_key_switch_count", "params")

#' @describeIn ccparams_getters BFV encryption
#'   technique (see `EncryptionTechnique`).
#' @export
get_encryption_technique <- new_generic("get_encryption_technique", "params")

#' @describeIn ccparams_getters BFV multiplication
#'   technique (see `MultiplicationTechnique`).
#' @export
get_multiplication_technique <- new_generic("get_multiplication_technique", "params")

#' @describeIn ccparams_getters PRE hop count.
#' @export
get_pre_num_hops <- new_generic("get_pre_num_hops", "params")

#' @describeIn ccparams_getters CKKS interactive
#'   bootstrap compression level (see `CompressionLevel`).
#' @export
get_interactive_boot_compression_level <-
  new_generic("get_interactive_boot_compression_level", "params")

#' @describeIn ccparams_getters register word size
#'   for multi-precision arithmetic.
#' @export
get_register_word_size <- new_generic("get_register_word_size", "params")

#' @describeIn ccparams_getters CKKS data type
#'   (see `CKKSDataType`).
#' @export
get_ckks_data_type <- new_generic("get_ckks_data_type", "params")

# ── Method registrations (99 total: 33 generics x 3 schemes) ──────

method(get_scheme, BFVParams)  <- function(params) BFVParams__GetScheme(get_ptr(params))
method(get_scheme, BGVParams)  <- function(params) BGVParams__GetScheme(get_ptr(params))
method(get_scheme, CKKSParams) <- function(params) CKKSParams__GetScheme(get_ptr(params))

method(get_plaintext_modulus, BFVParams)  <- function(params) BFVParams__GetPlaintextModulus(get_ptr(params))
method(get_plaintext_modulus, BGVParams)  <- function(params) BGVParams__GetPlaintextModulus(get_ptr(params))
method(get_plaintext_modulus, CKKSParams) <- function(params) CKKSParams__GetPlaintextModulus(get_ptr(params))

method(get_digit_size, BFVParams)  <- function(params) BFVParams__GetDigitSize(get_ptr(params))
method(get_digit_size, BGVParams)  <- function(params) BGVParams__GetDigitSize(get_ptr(params))
method(get_digit_size, CKKSParams) <- function(params) CKKSParams__GetDigitSize(get_ptr(params))

method(get_standard_deviation, BFVParams)  <- function(params) BFVParams__GetStandardDeviation(get_ptr(params))
method(get_standard_deviation, BGVParams)  <- function(params) BGVParams__GetStandardDeviation(get_ptr(params))
method(get_standard_deviation, CKKSParams) <- function(params) CKKSParams__GetStandardDeviation(get_ptr(params))

method(get_secret_key_dist, BFVParams)  <- function(params) BFVParams__GetSecretKeyDist(get_ptr(params))
method(get_secret_key_dist, BGVParams)  <- function(params) BGVParams__GetSecretKeyDist(get_ptr(params))
method(get_secret_key_dist, CKKSParams) <- function(params) CKKSParams__GetSecretKeyDist(get_ptr(params))

method(get_max_relin_sk_deg, BFVParams)  <- function(params) BFVParams__GetMaxRelinSkDeg(get_ptr(params))
method(get_max_relin_sk_deg, BGVParams)  <- function(params) BGVParams__GetMaxRelinSkDeg(get_ptr(params))
method(get_max_relin_sk_deg, CKKSParams) <- function(params) CKKSParams__GetMaxRelinSkDeg(get_ptr(params))

method(get_pre_mode, BFVParams)  <- function(params) BFVParams__GetPREMode(get_ptr(params))
method(get_pre_mode, BGVParams)  <- function(params) BGVParams__GetPREMode(get_ptr(params))
method(get_pre_mode, CKKSParams) <- function(params) CKKSParams__GetPREMode(get_ptr(params))

method(get_multiparty_mode, BFVParams)  <- function(params) BFVParams__GetMultipartyMode(get_ptr(params))
method(get_multiparty_mode, BGVParams)  <- function(params) BGVParams__GetMultipartyMode(get_ptr(params))
method(get_multiparty_mode, CKKSParams) <- function(params) CKKSParams__GetMultipartyMode(get_ptr(params))

method(get_execution_mode, BFVParams)  <- function(params) BFVParams__GetExecutionMode(get_ptr(params))
method(get_execution_mode, BGVParams)  <- function(params) BGVParams__GetExecutionMode(get_ptr(params))
method(get_execution_mode, CKKSParams) <- function(params) CKKSParams__GetExecutionMode(get_ptr(params))

method(get_decryption_noise_mode, BFVParams)  <- function(params) BFVParams__GetDecryptionNoiseMode(get_ptr(params))
method(get_decryption_noise_mode, BGVParams)  <- function(params) BGVParams__GetDecryptionNoiseMode(get_ptr(params))
method(get_decryption_noise_mode, CKKSParams) <- function(params) CKKSParams__GetDecryptionNoiseMode(get_ptr(params))

method(get_noise_estimate, BFVParams)  <- function(params) BFVParams__GetNoiseEstimate(get_ptr(params))
method(get_noise_estimate, BGVParams)  <- function(params) BGVParams__GetNoiseEstimate(get_ptr(params))
method(get_noise_estimate, CKKSParams) <- function(params) CKKSParams__GetNoiseEstimate(get_ptr(params))

method(get_desired_precision, BFVParams)  <- function(params) BFVParams__GetDesiredPrecision(get_ptr(params))
method(get_desired_precision, BGVParams)  <- function(params) BGVParams__GetDesiredPrecision(get_ptr(params))
method(get_desired_precision, CKKSParams) <- function(params) CKKSParams__GetDesiredPrecision(get_ptr(params))

method(get_statistical_security, BFVParams)  <- function(params) BFVParams__GetStatisticalSecurity(get_ptr(params))
method(get_statistical_security, BGVParams)  <- function(params) BGVParams__GetStatisticalSecurity(get_ptr(params))
method(get_statistical_security, CKKSParams) <- function(params) CKKSParams__GetStatisticalSecurity(get_ptr(params))

method(get_num_adversarial_queries, BFVParams)  <- function(params) BFVParams__GetNumAdversarialQueries(get_ptr(params))
method(get_num_adversarial_queries, BGVParams)  <- function(params) BGVParams__GetNumAdversarialQueries(get_ptr(params))
method(get_num_adversarial_queries, CKKSParams) <- function(params) CKKSParams__GetNumAdversarialQueries(get_ptr(params))

method(get_threshold_num_of_parties, BFVParams)  <- function(params) BFVParams__GetThresholdNumOfParties(get_ptr(params))
method(get_threshold_num_of_parties, BGVParams)  <- function(params) BGVParams__GetThresholdNumOfParties(get_ptr(params))
method(get_threshold_num_of_parties, CKKSParams) <- function(params) CKKSParams__GetThresholdNumOfParties(get_ptr(params))

method(get_key_switch_technique, BFVParams)  <- function(params) BFVParams__GetKeySwitchTechnique(get_ptr(params))
method(get_key_switch_technique, BGVParams)  <- function(params) BGVParams__GetKeySwitchTechnique(get_ptr(params))
method(get_key_switch_technique, CKKSParams) <- function(params) CKKSParams__GetKeySwitchTechnique(get_ptr(params))

method(get_scaling_technique, BFVParams)  <- function(params) BFVParams__GetScalingTechnique(get_ptr(params))
method(get_scaling_technique, BGVParams)  <- function(params) BGVParams__GetScalingTechnique(get_ptr(params))
method(get_scaling_technique, CKKSParams) <- function(params) CKKSParams__GetScalingTechnique(get_ptr(params))

method(get_batch_size, BFVParams)  <- function(params) BFVParams__GetBatchSize(get_ptr(params))
method(get_batch_size, BGVParams)  <- function(params) BGVParams__GetBatchSize(get_ptr(params))
method(get_batch_size, CKKSParams) <- function(params) CKKSParams__GetBatchSize(get_ptr(params))

method(get_first_mod_size, BFVParams)  <- function(params) BFVParams__GetFirstModSize(get_ptr(params))
method(get_first_mod_size, BGVParams)  <- function(params) BGVParams__GetFirstModSize(get_ptr(params))
method(get_first_mod_size, CKKSParams) <- function(params) CKKSParams__GetFirstModSize(get_ptr(params))

method(get_num_large_digits, BFVParams)  <- function(params) BFVParams__GetNumLargeDigits(get_ptr(params))
method(get_num_large_digits, BGVParams)  <- function(params) BGVParams__GetNumLargeDigits(get_ptr(params))
method(get_num_large_digits, CKKSParams) <- function(params) CKKSParams__GetNumLargeDigits(get_ptr(params))

method(get_multiplicative_depth, BFVParams)  <- function(params) BFVParams__GetMultiplicativeDepth(get_ptr(params))
method(get_multiplicative_depth, BGVParams)  <- function(params) BGVParams__GetMultiplicativeDepth(get_ptr(params))
method(get_multiplicative_depth, CKKSParams) <- function(params) CKKSParams__GetMultiplicativeDepth(get_ptr(params))

method(get_scaling_mod_size, BFVParams)  <- function(params) BFVParams__GetScalingModSize(get_ptr(params))
method(get_scaling_mod_size, BGVParams)  <- function(params) BGVParams__GetScalingModSize(get_ptr(params))
method(get_scaling_mod_size, CKKSParams) <- function(params) CKKSParams__GetScalingModSize(get_ptr(params))

method(get_security_level, BFVParams)  <- function(params) BFVParams__GetSecurityLevel(get_ptr(params))
method(get_security_level, BGVParams)  <- function(params) BGVParams__GetSecurityLevel(get_ptr(params))
method(get_security_level, CKKSParams) <- function(params) CKKSParams__GetSecurityLevel(get_ptr(params))

method(get_ring_dim, BFVParams)  <- function(params) BFVParams__GetRingDim(get_ptr(params))
method(get_ring_dim, BGVParams)  <- function(params) BGVParams__GetRingDim(get_ptr(params))
method(get_ring_dim, CKKSParams) <- function(params) CKKSParams__GetRingDim(get_ptr(params))

method(get_eval_add_count, BFVParams)  <- function(params) BFVParams__GetEvalAddCount(get_ptr(params))
method(get_eval_add_count, BGVParams)  <- function(params) BGVParams__GetEvalAddCount(get_ptr(params))
method(get_eval_add_count, CKKSParams) <- function(params) CKKSParams__GetEvalAddCount(get_ptr(params))

method(get_key_switch_count, BFVParams)  <- function(params) BFVParams__GetKeySwitchCount(get_ptr(params))
method(get_key_switch_count, BGVParams)  <- function(params) BGVParams__GetKeySwitchCount(get_ptr(params))
method(get_key_switch_count, CKKSParams) <- function(params) CKKSParams__GetKeySwitchCount(get_ptr(params))

method(get_encryption_technique, BFVParams)  <- function(params) BFVParams__GetEncryptionTechnique(get_ptr(params))
method(get_encryption_technique, BGVParams)  <- function(params) BGVParams__GetEncryptionTechnique(get_ptr(params))
method(get_encryption_technique, CKKSParams) <- function(params) CKKSParams__GetEncryptionTechnique(get_ptr(params))

method(get_multiplication_technique, BFVParams)  <- function(params) BFVParams__GetMultiplicationTechnique(get_ptr(params))
method(get_multiplication_technique, BGVParams)  <- function(params) BGVParams__GetMultiplicationTechnique(get_ptr(params))
method(get_multiplication_technique, CKKSParams) <- function(params) CKKSParams__GetMultiplicationTechnique(get_ptr(params))

method(get_pre_num_hops, BFVParams)  <- function(params) BFVParams__GetPRENumHops(get_ptr(params))
method(get_pre_num_hops, BGVParams)  <- function(params) BGVParams__GetPRENumHops(get_ptr(params))
method(get_pre_num_hops, CKKSParams) <- function(params) CKKSParams__GetPRENumHops(get_ptr(params))

method(get_interactive_boot_compression_level, BFVParams)  <- function(params) BFVParams__GetInteractiveBootCompressionLevel(get_ptr(params))
method(get_interactive_boot_compression_level, BGVParams)  <- function(params) BGVParams__GetInteractiveBootCompressionLevel(get_ptr(params))
method(get_interactive_boot_compression_level, CKKSParams) <- function(params) CKKSParams__GetInteractiveBootCompressionLevel(get_ptr(params))

method(get_composite_degree, BFVParams)  <- function(params) BFVParams__GetCompositeDegree(get_ptr(params))
method(get_composite_degree, BGVParams)  <- function(params) BGVParams__GetCompositeDegree(get_ptr(params))
method(get_composite_degree, CKKSParams) <- function(params) CKKSParams__GetCompositeDegree(get_ptr(params))

method(get_register_word_size, BFVParams)  <- function(params) BFVParams__GetRegisterWordSize(get_ptr(params))
method(get_register_word_size, BGVParams)  <- function(params) BGVParams__GetRegisterWordSize(get_ptr(params))
method(get_register_word_size, CKKSParams) <- function(params) CKKSParams__GetRegisterWordSize(get_ptr(params))

method(get_ckks_data_type, BFVParams)  <- function(params) BFVParams__GetCKKSDataType(get_ptr(params))
method(get_ckks_data_type, BGVParams)  <- function(params) BGVParams__GetCKKSDataType(get_ptr(params))
method(get_ckks_data_type, CKKSParams) <- function(params) CKKSParams__GetCKKSDataType(get_ptr(params))
