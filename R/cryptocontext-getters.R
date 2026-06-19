## OPENFHE PYTHON SOURCE: src/lib/bindings.cpp (CryptoContext Get*)
##
## R-side exposure of the CryptoContext getter fleet.
##
## Split across 7 new generics and ~13 method extensions on
## existing generics. The new generics are declared
## below with dispatch variable `cc`. The extensions attach
## method(existing_generic, CryptoContext) to the CCParams generics,
## which were declared with dispatch variable `params`; S7
## enforces that the method's first argument name matches the
## generic's dispatch variable, so those methods take a parameter
## named `params` even though the value is a CryptoContext. Same
## cosmetic wart already accepted for
## get_ckks_data_type's CryptoContext method.

# ── New generics ─────────────────────

#' Crypto parameters of a CryptoContext
#'
#' Returns the `CryptoParameters` S7 object carrying the opaque
#' `std::shared_ptr<CryptoParametersBase<DCRTPoly>>` at the C++
#' level. Useful for introspection; most R users will prefer to
#' call the individual lambda-routed getters (e.g.
#' `get_scaling_technique(cc)`, `get_batch_size(cc)`) directly
#' instead of going through the CryptoParameters object.
#'
#' @param cc A `CryptoContext`.
#' @param ... Reserved for future method-specific arguments.
#' @return A `CryptoParameters` S7 object.
#' @export
get_crypto_parameters <- new_generic("get_crypto_parameters", "cc")

#' Element parameters of a CryptoContext
#'
#' Returns the `ElementParams` S7 object wrapping
#' `std::shared_ptr<typename DCRTPoly::Params>`. This is the
#' object that can be passed as the `params` argument to
#' `make_ckks_packed_plaintext()` to build a plaintext against a
#' specific parameter set rather than the context default.
#'
#' This is the first R-side way to obtain a non-default
#' `ElementParams` (the class itself has existed as a scaffold
#' but had no constructor path until now).
#'
#' @param cc A `CryptoContext`.
#' @param ... Reserved for future method-specific arguments.
#' @return An `ElementParams` S7 object.
#' @export
get_element_params <- new_generic("get_element_params", "cc")

#' Encoding parameters of a CryptoContext
#'
#' Returns the `EncodingParams` S7 object wrapping
#' `std::shared_ptr<EncodingParamsImpl>`. Holds the plaintext
#' modulus, batch size, and other encoding-level parameters.
#'
#' @param cc A `CryptoContext`.
#' @param ... Reserved for future method-specific arguments.
#' @return An `EncodingParams` S7 object.
#' @export
get_encoding_params <- new_generic("get_encoding_params", "cc")

#' Key-generation level of a CryptoContext
#'
#' Integer level at which subsequent `key_gen()` calls will
#' generate keys. Defaults to `0L`. Useful when generating keys
#' at a non-fresh level for deep circuit protocols.
#'
#' @param cc A `CryptoContext`.
#' @param ... Reserved for future method-specific arguments.
#' @return Integer.
#' @export
get_key_gen_level <- new_generic("get_key_gen_level", "cc")

#' Set the key-generation level of a CryptoContext
#'
#' @param cc A `CryptoContext`.
#' @param ... Method-specific arguments; the `level` integer is
#'   passed here.
#' @return `cc` invisibly.
#' @export
set_key_gen_level <- new_generic("set_key_gen_level", "cc")

#' Cyclotomic order of a CryptoContext
#'
#' Integer `m` such that the underlying polynomial ring is
#' `Z[x]/(x^n + 1)` with `n = m/2` (the ring dimension). Always
#' `2 * ring_dimension(cc)` for power-of-two cyclotomics.
#'
#' @param cc A `CryptoContext`.
#' @param ... Reserved for future method-specific arguments.
#' @return Integer.
#' @export
get_cyclotomic_order <- new_generic("get_cyclotomic_order", "cc")

# ── Method registrations on the new generics ────────────

method(get_crypto_parameters, CryptoContext) <- function(cc) {
  CryptoParameters(ptr = CryptoContext__GetCryptoParameters(get_ptr(cc)))
}

method(get_element_params, CryptoContext) <- function(cc) {
  ElementParams(ptr = CryptoContext__GetElementParams(get_ptr(cc)))
}

method(get_encoding_params, CryptoContext) <- function(cc) {
  EncodingParams(ptr = CryptoContext__GetEncodingParams(get_ptr(cc)))
}

method(get_key_gen_level, CryptoContext) <- function(cc) {
  CryptoContext__GetKeyGenLevel(get_ptr(cc))
}

method(set_key_gen_level, CryptoContext) <- function(cc, level) {
  CryptoContext__SetKeyGenLevel(get_ptr(cc), as.integer(level))
  invisible(cc)
}

method(get_cyclotomic_order, CryptoContext) <- function(cc) {
  CryptoContext__GetCyclotomicOrder(get_ptr(cc))
}

# ── Method extensions on existing generics ───
#
# Every existing CCParams getter extends to CryptoContext
# via a lambda-routed cpp11 binding that goes through
# cc->GetCryptoParameters()->Get*() on the C++ side. The first arg
# name is `params` to match the CCParams generic's dispatch variable
# (see file header comment).

method(get_plaintext_modulus, CryptoContext) <- function(params)
  CryptoContext__GetPlaintextModulus(get_ptr(params))

method(get_batch_size, CryptoContext) <- function(params)
  CryptoContext__GetBatchSize(get_ptr(params))

method(get_scaling_technique, CryptoContext) <- function(params)
  CryptoContext__GetScalingTechnique(get_ptr(params))

method(get_digit_size, CryptoContext) <- function(params)
  CryptoContext__GetDigitSize(get_ptr(params))

method(get_noise_estimate, CryptoContext) <- function(params)
  CryptoContext__GetNoiseEstimate(get_ptr(params))

method(get_multiplicative_depth, CryptoContext) <- function(params)
  CryptoContext__GetMultiplicativeDepth(get_ptr(params))

method(get_eval_add_count, CryptoContext) <- function(params)
  CryptoContext__GetEvalAddCount(get_ptr(params))

method(get_key_switch_count, CryptoContext) <- function(params)
  CryptoContext__GetKeySwitchCount(get_ptr(params))

method(get_pre_num_hops, CryptoContext) <- function(params)
  CryptoContext__GetPRENumHops(get_ptr(params))

method(get_register_word_size, CryptoContext) <- function(params)
  CryptoContext__GetRegisterWordSize(get_ptr(params))

method(get_composite_degree, CryptoContext) <- function(params)
  CryptoContext__GetCompositeDegree(get_ptr(params))

method(get_key_switch_technique, CryptoContext) <- function(params)
  CryptoContext__GetKeySwitchTechnique(get_ptr(params))

## get_ckks_data_type already has a Plaintext method and
## BFVParams/BGVParams/CKKSParams methods. Here it gets
## a CryptoContext method too. All four dispatch to the same R
## wrapper shape.
method(get_ckks_data_type, CryptoContext) <- function(params)
  CryptoContext__GetCKKSDataType(get_ptr(params))
