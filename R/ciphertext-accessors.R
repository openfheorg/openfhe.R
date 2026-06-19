## OPENFHE PYTHON SOURCE: src/lib/bindings.cpp (Ciphertext accessors)
##
## S7 method registrations for the Plaintext
## accessor generics extended to the `Ciphertext` class, plus a
## new `get_crypto_context` generic and a `get_scaling_factor_real`
## generic for the Ciphertext / CryptoContext pair.
##
## Forward-looking naming pays off here: the Plaintext generics
## (get_level, set_level, get_slots, set_slots, get_noise_scale_deg,
## set_noise_scale_deg, get_scaling_factor, set_scaling_factor,
## get_scaling_factor_int, set_scaling_factor_int, get_encoding_type)
## were declared with dispatch = "x" exactly so that later work could
## add Ciphertext methods without renaming or duplicating. S7's
## first-arg-name rule means the method function's first arg must
## also be `x`.

# ── New generics ─────────────────────

#' Associated CryptoContext of a Ciphertext
#'
#' Returns the `CryptoContext` that was used to construct `ct`.
#' OpenFHE ciphertexts carry a back-pointer to their context so
#' that homomorphic operations can dispatch to the correct scheme
#' implementation without requiring the user to pass the context
#' explicitly.
#'
#' Naming note: `get_crypto_context` is distinct from
#' `get_crypto_parameters`. The former returns the
#' high-level `CryptoContext` S7 wrapper; the latter returns the
#' opaque `CryptoParameters` S7 wrapper.
#'
#' @param ct A `Ciphertext`.
#' @param ... Reserved for future method-specific arguments.
#' @return A `CryptoContext` S7 object.
#' @export
get_crypto_context <- new_generic("get_crypto_context", "ct")

method(get_crypto_context, Ciphertext) <- function(ct) {
  cc_xp <- Ciphertext__GetCryptoContext(get_ptr(ct))
  CryptoContext(ptr = cc_xp)
}

#' Real-valued CKKS scaling factor at a modulus-chain level
#'
#' Returns `cryptoParams->GetScalingFactorReal(level)` — the
#' double-valued scaling factor at the given `level` of the CKKS
#' modulus chain. Meaningful only for CKKS contexts; BFV/BGV
#' contexts return the default field value (effectively `1.0`).
#'
#' Used by `ckks_scaling_factor_bits()` (which takes `log2` of the
#' level-0 value to recover the bit size originally set via
#' `set_scaling_mod_size()`) and by the Stage 2 form of
#' `fhe_ckks_tolerance()`.
#'
#' @param cc A `CryptoContext`.
#' @param ... Method-specific arguments. The CryptoContext method
#'   accepts `level` (integer level in the RNS modulus chain,
#'   default `0L` — the top of the chain = the scaling factor at
#'   fresh encryption time).
#' @return Numeric scalar.
#' @export
get_scaling_factor_real <- new_generic("get_scaling_factor_real", "cc")

method(get_scaling_factor_real, CryptoContext) <- function(cc, level = 0L) {
  CryptoContext__GetScalingFactorReal(get_ptr(cc), as.integer(level))
}

#' CKKS scaling-mod-size in bits
#'
#' Reads the real-valued scaling factor at level 0 from `cc` via
#' [get_scaling_factor_real()] and returns its `log2` rounded to
#' the nearest integer. For a CKKS context constructed with
#' `set_scaling_mod_size(50L)` this returns `50L`.
#'
#' Used by the Stage 2 form of [fhe_ckks_tolerance()].
#'
#' @param cc A `CryptoContext` (should be CKKS — meaningful only
#'   for CKKS contexts).
#' @return Integer.
#' @export
ckks_scaling_factor_bits <- function(cc) {
  sfr <- get_scaling_factor_real(cc, level = 0L)
  as.integer(round(log2(sfr)))
}

# ── Ciphertext method extensions on existing generics ───

## Generics from R/plaintext-accessors.R (dispatch on "x"):

method(get_level, Ciphertext) <- function(x)
  Ciphertext__GetLevel(get_ptr(x))

method(set_level, Ciphertext) <- function(x, value) {
  Ciphertext__SetLevel(get_ptr(x), as.integer(value))
  invisible(x)
}

method(get_slots, Ciphertext) <- function(x)
  Ciphertext__GetSlots(get_ptr(x))

method(set_slots, Ciphertext) <- function(x, value) {
  Ciphertext__SetSlots(get_ptr(x), as.integer(value))
  invisible(x)
}

method(get_noise_scale_deg, Ciphertext) <- function(x)
  Ciphertext__GetNoiseScaleDeg(get_ptr(x))

method(set_noise_scale_deg, Ciphertext) <- function(x, value) {
  Ciphertext__SetNoiseScaleDeg(get_ptr(x), as.integer(value))
  invisible(x)
}

method(get_scaling_factor, Ciphertext) <- function(x)
  Ciphertext__GetScalingFactor(get_ptr(x))

method(set_scaling_factor, Ciphertext) <- function(x, value) {
  Ciphertext__SetScalingFactor(get_ptr(x), as.double(value))
  invisible(x)
}

method(get_scaling_factor_int, Ciphertext) <- function(x)
  Ciphertext__GetScalingFactorInt(get_ptr(x))

method(set_scaling_factor_int, Ciphertext) <- function(x, value) {
  Ciphertext__SetScalingFactorInt(get_ptr(x), as.integer(value))
  invisible(x)
}

method(get_encoding_type, Ciphertext) <- function(x)
  Ciphertext__GetEncodingType(get_ptr(x))

## Generics from R/keys.R (dispatch on "key"):

method(get_key_tag, Ciphertext) <- function(key)
  Ciphertext__GetKeyTag(get_ptr(key))

method(set_key_tag, Ciphertext) <- function(key, value) {
  Ciphertext__SetKeyTag(get_ptr(key), as.character(value))
  invisible(key)
}
