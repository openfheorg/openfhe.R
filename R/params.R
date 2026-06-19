## OPENFHE PYTHON SOURCE: src/lib/bindings.cpp (CCParams class)
##
## Per discovery D013, each CCParams<T> specialization disables a
## subset of the common Params-base setters via DISABLED_FOR_<SCHEME>
## throwing overrides. The R constructors below expose **only** the
## enabled subset per scheme:
##
##   BFV  → 19 arguments (13 disabled upstream, not exposed)
##   BGV  → 22 arguments (10 disabled upstream, not exposed)
##   CKKS → 24 arguments ( 8 disabled upstream, not exposed)
##
## Setters whose upstream audit count from openfhe-python examples is
## zero carry a `parity-deferred:` marker in their @param body per
## design.md §4. They are fully cpp11-bound, so promoting them to a
## documented surface later is a roxygen-only change.

# ── BFV Parameters ──────────────────────────────────────

#' BFV Parameters
#'
#' Constructor for the BFV scheme's `CCParams` surface. Every argument
#' maps 1:1 to an upstream `CCParams<CryptoContextBFVRNS>::Set*` method
#' whose override is *not* disabled in the BFV specialization. The 13
#' setters that BFV explicitly disables (`SetScalingTechnique`,
#' `SetFirstModSize`, `SetPRENumHops`, `SetExecutionMode`, …) are not
#' exposed here; see discovery D013.
#'
#' @param plaintext_modulus Integer modulus `t` for the BFV plaintext
#'   space. BFV plaintexts are elements of `Z_t[x]/Phi_m(x)` and every
#'   homomorphic operation is performed modulo `t`. Must be a prime
#'   (or a composite supporting NTT in the batching case) and must be
#'   at least large enough that the end-to-end computation does not
#'   wrap modulo `t`. Typical values: `65537` (the smallest
#'   batching-friendly prime) for small-integer arithmetic, `786433`
#'   or larger when the operands or intermediate sums are larger.
#'   There is no scheme-level default — the user must supply one.
#' @param multiplicative_depth Integer depth of the multiplication
#'   circuit the context must support. BFV and BGV grow ciphertext
#'   noise with each multiplication, and the ring modulus `q` is sized
#'   by OpenFHE to survive exactly `multiplicative_depth` successive
#'   multiplications plus an `EvalAdd` chain between them. Set to the
#'   exact depth of your circuit; setting it too small causes
#'   correctness failure at decrypt, setting it too large inflates
#'   ring dimension and slows every operation. Couples tightly to
#'   `security_level` (together they pin `ring_dim`).
#' @param scaling_mod_size Integer bit-size of each intermediate
#'   scaling modulus in the RNS decomposition of `q`. Default leaves
#'   OpenFHE to choose from its internal tables (typically 60 bits).
#'   Override only when you know your depth budget needs a tighter
#'   value; the upstream simple-integers example uses the default.
#' @param batch_size Integer number of SIMD-batched plaintext slots.
#'   Default is `ring_dim / 2` under the full-packing convention.
#'   Set to a smaller power of two when your input vector is short
#'   and rotation cost dominates the circuit (the inner-product
#'   idiom). Must divide `ring_dim / 2`. Couples to `ring_dim`.
#' @param security_level One of `SecurityLevel$HEStd_128_classic`
#'   (default when unset), `HEStd_192_classic`, `HEStd_256_classic`,
#'   and their `_quantum` counterparts. Fixes the target hardness
#'   assumption and, together with `multiplicative_depth`, determines
#'   the minimum ring dimension via the upstream lattice-parameters
#'   tables in `core/lattice/stdlatticeparms.h`.
#' @param secret_key_dist One of `SecretKeyDist$GAUSSIAN`,
#'   `UNIFORM_TERNARY` (default under classic lattice parameters), or
#'   `SPARSE_TERNARY`. Controls the coefficient distribution of the
#'   secret key. Change only for research scenarios that demand a
#'   specific distribution; every production vignette uses the
#'   default.
#' @param key_switch_technique One of `KeySwitchTechnique$BV` (default
#'   for BFV) or `HYBRID`. `BV` produces smaller evaluation keys and
#'   is the simpler option; `HYBRID` is relevant only when you are
#'   also setting `num_large_digits` and benchmarking rotation cost.
#' @param ring_dim Integer power-of-two lattice ring dimension. Default
#'   (`NULL`) asks OpenFHE to compute the minimum ring dimension that
#'   satisfies `security_level` at the chosen `multiplicative_depth`.
#'   Override only to force a larger value than the auto-selection,
#'   typically to reserve headroom for later parameter sweeps.
#' @param digit_size Integer `r` for BV key-switching: the base-`2^r`
#'   digit decomposition of the ciphertext during a key-switch.
#'   Default `0L` selects the upstream default. Larger values
#'   decrease the number of digit multiplications at the cost of
#'   larger per-digit noise.
#' @param num_large_digits Integer number of digit groupings in
#'   HYBRID key switching. Only meaningful when
#'   `key_switch_technique = KeySwitchTechnique$HYBRID`; ignored
#'   otherwise. Default `0L` lets OpenFHE pick.
#' @param standard_deviation Numeric standard deviation of the
#'   Gaussian error distribution used during key generation and
#'   encryption. Default (`NULL`) uses the upstream default
#'   `3.19`. Override only in research scenarios.
#' @param multiparty_mode One of
#'   `MultipartyMode$FIXED_NOISE_MULTIPARTY` or
#'   `NOISE_FLOODING_MULTIPARTY`. Selects between threshold-FHE with
#'   fixed noise (no flooding) and noise-flooding-protected
#'   threshold-FHE. Both cox-threshold and CVXR-consensus-ADMM
#'   vignettes rely on threshold paths; leave at upstream default
#'   unless you are intentionally tuning the leakage/performance
#'   trade-off.
#' @param threshold_num_of_parties Integer count of parties in an
#'   n-of-n threshold protocol. Ignored in non-threshold contexts.
#'   The cox-threshold vignette uses 2; the threshold-fhe-5p
#'   Python example uses 5.
#' @param multiplication_technique One of
#'   `MultiplicationTechnique$BEHZ`, `HPS`, `HPSPOVERQ`,
#'   `HPSPOVERQLEVELED`. BFV-specific choice of how the plaintext
#'   modulus interacts with the ciphertext modulus during multiply.
#'   Default upstream is `HPSPOVERQLEVELED`; override only if you
#'   are benchmarking multiplication-path variants.
#' @param max_relin_sk_deg `parity-deferred:` maximum degree of the
#'   secret key that can be relinearized. Upstream default is 2.
#'   No current vignette or Python example exercises this; the
#'   cpp11 binding is in place so a later release can promote it
#'   without a recompile.
#' @param pre_mode `parity-deferred:` proxy re-encryption mode
#'   (`PREMode$NOT_SET`, `INDCPA`, `FIXED_NOISE_HRA`,
#'   `NOISE_FLOODING_HRA`). Only meaningful if the `PRE` feature is
#'   enabled on the context. No current vignette uses PRE.
#' @param eval_add_count `parity-deferred:` upstream noise-budget
#'   hint: maximum additions between multiplications. Used only by
#'   the noise-flooding path. Default 0.
#' @param key_switch_count `parity-deferred:` upstream noise-budget
#'   hint: maximum key-switch count. Default 0.
#' @param encryption_technique `parity-deferred:` BFV-specific
#'   encryption variant (`EncryptionTechnique$STANDARD` or
#'   `EXTENDED`). Default STANDARD.
#' @return A `BFVParams` S7 object.
#' @export
BFVParams <- new_class("BFVParams",
  parent = OpenFHEObject,
  package = "openfhe.R",
  constructor = function(plaintext_modulus       = NULL,
                         multiplicative_depth    = NULL,
                         scaling_mod_size        = NULL,
                         batch_size              = NULL,
                         security_level          = NULL,
                         secret_key_dist         = NULL,
                         key_switch_technique    = NULL,
                         ring_dim                = NULL,
                         digit_size              = NULL,
                         num_large_digits        = NULL,
                         standard_deviation      = NULL,
                         multiparty_mode         = NULL,
                         threshold_num_of_parties = NULL,
                         multiplication_technique = NULL,
                         max_relin_sk_deg        = NULL,
                         pre_mode                = NULL,
                         eval_add_count          = NULL,
                         key_switch_count        = NULL,
                         encryption_technique    = NULL) {
    xp <- BFVParams__new()
    if (!is.null(plaintext_modulus))
      BFVParams__SetPlaintextModulus(xp, as.integer(plaintext_modulus))
    if (!is.null(multiplicative_depth))
      BFVParams__SetMultiplicativeDepth(xp, as.integer(multiplicative_depth))
    if (!is.null(scaling_mod_size))
      BFVParams__SetScalingModSize(xp, as.integer(scaling_mod_size))
    if (!is.null(batch_size))
      BFVParams__SetBatchSize(xp, as.integer(batch_size))
    if (!is.null(security_level))
      BFVParams__SetSecurityLevel(xp, as.integer(security_level))
    if (!is.null(secret_key_dist))
      BFVParams__SetSecretKeyDist(xp, as.integer(secret_key_dist))
    if (!is.null(key_switch_technique))
      BFVParams__SetKeySwitchTechnique(xp, as.integer(key_switch_technique))
    if (!is.null(ring_dim))
      BFVParams__SetRingDim(xp, as.integer(ring_dim))
    if (!is.null(digit_size))
      BFVParams__SetDigitSize(xp, as.integer(digit_size))
    if (!is.null(num_large_digits))
      BFVParams__SetNumLargeDigits(xp, as.integer(num_large_digits))
    if (!is.null(standard_deviation))
      BFVParams__SetStandardDeviation(xp, as.double(standard_deviation))
    if (!is.null(multiparty_mode))
      BFVParams__SetMultipartyMode(xp, as.integer(multiparty_mode))
    if (!is.null(threshold_num_of_parties))
      BFVParams__SetThresholdNumOfParties(xp, as.integer(threshold_num_of_parties))
    if (!is.null(multiplication_technique))
      BFVParams__SetMultiplicationTechnique(xp, as.integer(multiplication_technique))
    if (!is.null(max_relin_sk_deg))
      BFVParams__SetMaxRelinSkDeg(xp, as.integer(max_relin_sk_deg))
    if (!is.null(pre_mode))
      BFVParams__SetPREMode(xp, as.integer(pre_mode))
    if (!is.null(eval_add_count))
      BFVParams__SetEvalAddCount(xp, as.integer(eval_add_count))
    if (!is.null(key_switch_count))
      BFVParams__SetKeySwitchCount(xp, as.integer(key_switch_count))
    if (!is.null(encryption_technique))
      BFVParams__SetEncryptionTechnique(xp, as.integer(encryption_technique))
    new_object(S7_object(), ptr = xp)
  }
)

# ── BGV Parameters ──────────────────────────────────────

#' BGV Parameters
#'
#' Constructor for the BGV scheme's `CCParams` surface. Every argument
#' maps 1:1 to an enabled `CCParams<CryptoContextBGVRNS>::Set*` method.
#' The 10 BGV-disabled setters (`SetEncryptionTechnique`,
#' `SetMultiplicationTechnique`, `SetExecutionMode`, …) are not
#' exposed; see discovery D013.
#'
#' @param plaintext_modulus Integer modulus `t` for the BGV plaintext
#'   space. See the BFV entry for full semantics; BGV shares the
#'   same `Z_t`-valued plaintext model.
#' @param multiplicative_depth Integer multiplicative depth; sizes
#'   the ring modulus `q`. See the BFV entry for the full coupling.
#' @param scaling_mod_size Integer bit-size per scaling modulus in
#'   the modulus chain.
#' @param scaling_technique One of `ScalingTechnique$FIXEDMANUAL`,
#'   `FIXEDAUTO`, `FLEXIBLEAUTO` (upstream default), `FLEXIBLEAUTOEXT`.
#'   Selects whether the scheme rescales automatically between
#'   multiplications (`*AUTO*`) or leaves it to the caller
#'   (`FIXEDMANUAL`). Every vignette uses an auto mode; pick
#'   `FIXEDMANUAL` only if you need deterministic control over
#'   rescale insertion.
#' @param batch_size Integer SIMD slot count; see the BFV entry.
#' @param first_mod_size Integer bit size of the first (largest)
#'   prime in the modulus chain. Default leaves OpenFHE to pick.
#'   Override only when tuning the noise budget at the top of the
#'   chain.
#' @param security_level See the BFV entry.
#' @param secret_key_dist See the BFV entry.
#' @param key_switch_technique See the BFV entry. BGV accepts both
#'   `BV` and `HYBRID`.
#' @param ring_dim See the BFV entry.
#' @param digit_size See the BFV entry.
#' @param num_large_digits See the BFV entry.
#' @param standard_deviation See the BFV entry.
#' @param multiparty_mode See the BFV entry.
#' @param threshold_num_of_parties See the BFV entry.
#' @param max_relin_sk_deg `parity-deferred:` see the BFV entry.
#' @param pre_mode `parity-deferred:` see the BFV entry.
#' @param statistical_security `parity-deferred:` statistical security
#'   parameter (bits), used by the noise-flooding decryption path.
#' @param num_adversarial_queries `parity-deferred:` upper bound on
#'   the number of adversarial queries the noise-flooding path must
#'   survive.
#' @param eval_add_count `parity-deferred:` see the BFV entry.
#' @param key_switch_count `parity-deferred:` see the BFV entry.
#' @param pre_num_hops `parity-deferred:` maximum number of hops for
#'   proxy re-encryption in BGV. Only meaningful if the PRE feature
#'   is enabled.
#' @return A `BGVParams` S7 object.
#' @export
BGVParams <- new_class("BGVParams",
  parent = OpenFHEObject,
  package = "openfhe.R",
  constructor = function(plaintext_modulus        = NULL,
                         multiplicative_depth     = NULL,
                         scaling_mod_size         = NULL,
                         scaling_technique        = NULL,
                         batch_size               = NULL,
                         first_mod_size           = NULL,
                         security_level           = NULL,
                         secret_key_dist          = NULL,
                         key_switch_technique     = NULL,
                         ring_dim                 = NULL,
                         digit_size               = NULL,
                         num_large_digits         = NULL,
                         standard_deviation       = NULL,
                         multiparty_mode          = NULL,
                         threshold_num_of_parties = NULL,
                         max_relin_sk_deg         = NULL,
                         pre_mode                 = NULL,
                         statistical_security     = NULL,
                         num_adversarial_queries  = NULL,
                         eval_add_count           = NULL,
                         key_switch_count         = NULL,
                         pre_num_hops             = NULL) {
    xp <- BGVParams__new()
    if (!is.null(plaintext_modulus))
      BGVParams__SetPlaintextModulus(xp, as.integer(plaintext_modulus))
    if (!is.null(multiplicative_depth))
      BGVParams__SetMultiplicativeDepth(xp, as.integer(multiplicative_depth))
    if (!is.null(scaling_mod_size))
      BGVParams__SetScalingModSize(xp, as.integer(scaling_mod_size))
    if (!is.null(scaling_technique))
      BGVParams__SetScalingTechnique(xp, as.integer(scaling_technique))
    if (!is.null(batch_size))
      BGVParams__SetBatchSize(xp, as.integer(batch_size))
    if (!is.null(first_mod_size))
      BGVParams__SetFirstModSize(xp, as.integer(first_mod_size))
    if (!is.null(security_level))
      BGVParams__SetSecurityLevel(xp, as.integer(security_level))
    if (!is.null(secret_key_dist))
      BGVParams__SetSecretKeyDist(xp, as.integer(secret_key_dist))
    if (!is.null(key_switch_technique))
      BGVParams__SetKeySwitchTechnique(xp, as.integer(key_switch_technique))
    if (!is.null(ring_dim))
      BGVParams__SetRingDim(xp, as.integer(ring_dim))
    if (!is.null(digit_size))
      BGVParams__SetDigitSize(xp, as.integer(digit_size))
    if (!is.null(num_large_digits))
      BGVParams__SetNumLargeDigits(xp, as.integer(num_large_digits))
    if (!is.null(standard_deviation))
      BGVParams__SetStandardDeviation(xp, as.double(standard_deviation))
    if (!is.null(multiparty_mode))
      BGVParams__SetMultipartyMode(xp, as.integer(multiparty_mode))
    if (!is.null(threshold_num_of_parties))
      BGVParams__SetThresholdNumOfParties(xp, as.integer(threshold_num_of_parties))
    if (!is.null(max_relin_sk_deg))
      BGVParams__SetMaxRelinSkDeg(xp, as.integer(max_relin_sk_deg))
    if (!is.null(pre_mode))
      BGVParams__SetPREMode(xp, as.integer(pre_mode))
    if (!is.null(statistical_security))
      BGVParams__SetStatisticalSecurity(xp, as.integer(statistical_security))
    if (!is.null(num_adversarial_queries))
      BGVParams__SetNumAdversarialQueries(xp, as.integer(num_adversarial_queries))
    if (!is.null(eval_add_count))
      BGVParams__SetEvalAddCount(xp, as.integer(eval_add_count))
    if (!is.null(key_switch_count))
      BGVParams__SetKeySwitchCount(xp, as.integer(key_switch_count))
    if (!is.null(pre_num_hops))
      BGVParams__SetPRENumHops(xp, as.integer(pre_num_hops))
    new_object(S7_object(), ptr = xp)
  }
)

# ── CKKS Parameters ─────────────────────────────────────

#' CKKS Parameters
#'
#' Constructor for the CKKS scheme's `CCParams` surface. Every
#' argument maps 1:1 to an enabled
#' `CCParams<CryptoContextCKKSRNS>::Set*` method. The 8 CKKS-disabled
#' setters (`SetPlaintextModulus`, `SetEvalAddCount`,
#' `SetKeySwitchCount`, `SetEncryptionTechnique`,
#' `SetMultiplicationTechnique`, `SetPRENumHops`, `SetMultipartyMode`,
#' `SetThresholdNumOfParties`) are not exposed; see discovery D013.
#' CKKS is a fixed-point scheme over the complex numbers and has no
#' plaintext modulus; `threshold_num_of_parties` is currently
#' CKKS-disabled upstream even though the scheme supports threshold
#' variants via a separate code path.
#'
#' @param multiplicative_depth See the BFV entry.
#' @param scaling_mod_size Integer bit-size of the CKKS rescaling
#'   factor (typically 50 or 59 bits). Together with
#'   `multiplicative_depth` this pins the modulus chain and therefore
#'   the precision budget available at the bottom of the circuit.
#'   Upstream default varies by scaling technique; when in doubt use
#'   the value the matching Python example uses.
#' @param scaling_technique See the BGV entry. CKKS additionally
#'   supports `NORESCALE` (debug-only) and the
#'   `COMPOSITESCALING*` modes.
#' @param batch_size See the BFV entry.
#' @param first_mod_size See the BGV entry.
#' @param security_level See the BFV entry.
#' @param secret_key_dist See the BFV entry.
#' @param key_switch_technique See the BFV entry. CKKS typically
#'   benefits from `HYBRID`.
#' @param ring_dim See the BFV entry.
#' @param digit_size See the BFV entry.
#' @param num_large_digits See the BFV entry.
#' @param interactive_boot_compression_level One of
#'   `CompressionLevel$COMPACT` (2) or `SLACK` (3). Controls the
#'   compression level to which the input ciphertext is brought
#'   before interactive multi-party bootstrapping. `COMPACT` is more
#'   efficient but assumes a stronger security model; `SLACK` is
#'   less efficient with weaker assumptions. Used by the `tckks-
#'   interactive-mp-bootstrapping*` Python examples.
#' @param standard_deviation See the BFV entry.
#' @param register_word_size Integer word size (in bits) for the
#'   register-based multi-precision arithmetic path. Default leaves
#'   it to upstream. Used by the simple-real-numbers-composite-
#'   scaling Python example.
#' @param ckks_data_type One of `CKKSDataType$REAL` (default) or
#'   `COMPLEX`. Selects whether CKKS plaintexts are modeled as
#'   real vectors or complex vectors. All current R vignettes use
#'   `REAL`.
#' @param max_relin_sk_deg `parity-deferred:` see the BFV entry.
#' @param pre_mode `parity-deferred:` see the BFV entry.
#' @param execution_mode `parity-deferred:` one of
#'   `ExecutionMode$EXEC_EVALUATION` (default) or
#'   `EXEC_NOISE_ESTIMATION`. The noise-estimation mode is only
#'   used by the adversarial-query noise-flooding path.
#' @param decryption_noise_mode `parity-deferred:` one of
#'   `DecryptionNoiseMode$FIXED_NOISE_DECRYPT` (default) or
#'   `NOISE_FLOODING_DECRYPT`.
#' @param noise_estimate `parity-deferred:` numeric noise estimate
#'   used by the noise-flooding path. Paired with `execution_mode =
#'   EXEC_NOISE_ESTIMATION`.
#' @param desired_precision `parity-deferred:` numeric target
#'   precision (in bits) for the noise-flooding path.
#' @param statistical_security `parity-deferred:` see the BGV entry.
#' @param num_adversarial_queries `parity-deferred:` see the BGV
#'   entry.
#' @param composite_degree `parity-deferred:` composite scaling
#'   degree for the `COMPOSITESCALING*` scaling techniques. Upstream
#'   default 0 means single-prime scaling.
#' @return A `CKKSParams` S7 object.
#' @export
CKKSParams <- new_class("CKKSParams",
  parent = OpenFHEObject,
  package = "openfhe.R",
  constructor = function(multiplicative_depth              = NULL,
                         scaling_mod_size                  = NULL,
                         scaling_technique                 = NULL,
                         batch_size                        = NULL,
                         first_mod_size                    = NULL,
                         security_level                    = NULL,
                         secret_key_dist                   = NULL,
                         key_switch_technique              = NULL,
                         ring_dim                          = NULL,
                         digit_size                        = NULL,
                         num_large_digits                  = NULL,
                         interactive_boot_compression_level = NULL,
                         standard_deviation                = NULL,
                         register_word_size                = NULL,
                         ckks_data_type                    = NULL,
                         max_relin_sk_deg                  = NULL,
                         pre_mode                          = NULL,
                         execution_mode                    = NULL,
                         decryption_noise_mode             = NULL,
                         noise_estimate                    = NULL,
                         desired_precision                 = NULL,
                         statistical_security              = NULL,
                         num_adversarial_queries           = NULL,
                         composite_degree                  = NULL) {
    xp <- CKKSParams__new()
    if (!is.null(multiplicative_depth))
      CKKSParams__SetMultiplicativeDepth(xp, as.integer(multiplicative_depth))
    if (!is.null(scaling_mod_size))
      CKKSParams__SetScalingModSize(xp, as.integer(scaling_mod_size))
    if (!is.null(scaling_technique))
      CKKSParams__SetScalingTechnique(xp, as.integer(scaling_technique))
    if (!is.null(batch_size))
      CKKSParams__SetBatchSize(xp, as.integer(batch_size))
    if (!is.null(first_mod_size))
      CKKSParams__SetFirstModSize(xp, as.integer(first_mod_size))
    if (!is.null(security_level))
      CKKSParams__SetSecurityLevel(xp, as.integer(security_level))
    if (!is.null(secret_key_dist))
      CKKSParams__SetSecretKeyDist(xp, as.integer(secret_key_dist))
    if (!is.null(key_switch_technique))
      CKKSParams__SetKeySwitchTechnique(xp, as.integer(key_switch_technique))
    if (!is.null(ring_dim))
      CKKSParams__SetRingDim(xp, as.integer(ring_dim))
    if (!is.null(digit_size))
      CKKSParams__SetDigitSize(xp, as.integer(digit_size))
    if (!is.null(num_large_digits))
      CKKSParams__SetNumLargeDigits(xp, as.integer(num_large_digits))
    if (!is.null(interactive_boot_compression_level))
      CKKSParams__SetInteractiveBootCompressionLevel(
        xp, as.integer(interactive_boot_compression_level))
    if (!is.null(standard_deviation))
      CKKSParams__SetStandardDeviation(xp, as.double(standard_deviation))
    if (!is.null(register_word_size))
      CKKSParams__SetRegisterWordSize(xp, as.integer(register_word_size))
    if (!is.null(ckks_data_type))
      CKKSParams__SetCKKSDataType(xp, as.integer(ckks_data_type))
    if (!is.null(max_relin_sk_deg))
      CKKSParams__SetMaxRelinSkDeg(xp, as.integer(max_relin_sk_deg))
    if (!is.null(pre_mode))
      CKKSParams__SetPREMode(xp, as.integer(pre_mode))
    if (!is.null(execution_mode))
      CKKSParams__SetExecutionMode(xp, as.integer(execution_mode))
    if (!is.null(decryption_noise_mode))
      CKKSParams__SetDecryptionNoiseMode(xp, as.integer(decryption_noise_mode))
    if (!is.null(noise_estimate))
      CKKSParams__SetNoiseEstimate(xp, as.double(noise_estimate))
    if (!is.null(desired_precision))
      CKKSParams__SetDesiredPrecision(xp, as.double(desired_precision))
    if (!is.null(statistical_security))
      CKKSParams__SetStatisticalSecurity(xp, as.integer(statistical_security))
    if (!is.null(num_adversarial_queries))
      CKKSParams__SetNumAdversarialQueries(xp, as.integer(num_adversarial_queries))
    if (!is.null(composite_degree))
      CKKSParams__SetCompositeDegree(xp, as.integer(composite_degree))
    new_object(S7_object(), ptr = xp)
  }
)

# ── Print methods ───────────────────────────────────────

method(print, BFVParams) <- function(x, ...) {
  cli::cli_text("{.cls BFVParams} [{if (ptr_is_valid(x)) 'configured' else 'null'}]")
  invisible(x)
}

method(print, BGVParams) <- function(x, ...) {
  cli::cli_text("{.cls BGVParams} [{if (ptr_is_valid(x)) 'configured' else 'null'}]")
  invisible(x)
}

method(print, CKKSParams) <- function(x, ...) {
  cli::cli_text("{.cls CKKSParams} [{if (ptr_is_valid(x)) 'configured' else 'null'}]")
  invisible(x)
}
