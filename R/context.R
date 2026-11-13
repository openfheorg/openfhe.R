## OPENFHE PYTHON SOURCE: src/lib/bindings.cpp (CryptoContext class)

#' Crypto Context
#' @param ptr External pointer (internal use)
#' @return An S7 object of class `CryptoContext`, inheriting from
#'   [OpenFHEObject], whose `ptr` property holds an external pointer to
#'   the C++ crypto context. The context owns the scheme parameters and
#'   the registry of evaluation keys, and is the first argument to most
#'   operations. Obtain one from [fhe_context()] rather than by calling
#'   this constructor directly.
#' @export
CryptoContext <- new_class("CryptoContext",
  parent = OpenFHEObject,
  package = "openfhe.R"
)

#' Create a fully homomorphic encryption context
#'
#' High-level constructor that creates a `CryptoContext` with sensible
#' defaults. `PKE`, `KEYSWITCH`, and `LEVELEDSHE` features are enabled
#' automatically.
#'
#' All scheme-specific `CCParams` setter arguments are accepted via
#' `...` and forwarded to the appropriate per-scheme constructor
#' (`BFVParams()`, `BGVParams()`, or `CKKSParams()`). See those
#' functions' argument lists for the valid per-scheme setter surface
#' — each scheme accepts only the setters that are *not* disabled in
#' its upstream `CCParams<T>` specialization.
#' Passing an invalid scheme-specific argument produces an R-level
#' "unused argument" error at the underlying `*Params()` call site.
#'
#' @param scheme Character: "BFV", "BGV", or "CKKS".
#' @param ... Scheme-specific `CCParams` setter arguments. Forwarded
#'   to `BFVParams()`, `BGVParams()`, or `CKKSParams()`. Example:
#'   `fhe_context("BFV", plaintext_modulus = 65537,
#'   multiplicative_depth = 2)` or `fhe_context("CKKS",
#'   multiplicative_depth = 4, scaling_mod_size = 50,
#'   scaling_technique = ScalingTechnique$FLEXIBLEAUTO)`.
#' @param features Additional `Feature` values to enable on the
#'   context beyond the default `PKE|KEYSWITCH|LEVELEDSHE` triple.
#' @return A `CryptoContext` object.
#' @seealso [BFVParams()], [BGVParams()], [CKKSParams()]
#' @examples
#' ## An exact context over the integers modulo 65537 (BFV). The ring
#' ## dimension is chosen for you from the security level.
#' bfv <- fhe_context("BFV", plaintext_modulus = 65537L,
#'                    multiplicative_depth = 2L)
#' ring_dimension(bfv)
#'
#' ## An approximate context over the reals (CKKS), which is what the
#' ## statistical applications use.
#' ckks <- fhe_context("CKKS", multiplicative_depth = 2L,
#'                     scaling_mod_size = 50L, batch_size = 8L)
#' ring_dimension(ckks)
#' @export
fhe_context <- function(scheme = c("BFV", "BGV", "CKKS"), ..., features = NULL) {
  scheme <- match.arg(scheme)

  if (scheme == "BFV") {
    params <- BFVParams(...)
    cc_xp <- GenCryptoContext__BFV(get_ptr(params))
  } else if (scheme == "BGV") {
    params <- BGVParams(...)
    cc_xp <- GenCryptoContext__BGV(get_ptr(params))
  } else if (scheme == "CKKS") {
    params <- CKKSParams(...)
    cc_xp <- GenCryptoContext__CKKS(get_ptr(params))
  } else {
    cli_abort("Scheme {.val {scheme}} not yet implemented")
  }

  ## >>> S7-FAST-NEW (RConsortium/S7#723): original
  ## cc <- CryptoContext(ptr = cc_xp)
  ## <<< S7-FAST-NEW
  cc <- .fast_new(CryptoContext, cc_xp)

  CryptoContext__Enable(cc_xp, Feature$PKE)
  CryptoContext__Enable(cc_xp, Feature$KEYSWITCH)
  CryptoContext__Enable(cc_xp, Feature$LEVELEDSHE)

  if (!is.null(features)) {
    for (f in features) {
      CryptoContext__Enable(cc_xp, f)
    }
  }

  cc
}

#' Generate a CryptoContext from a parameter object
#'
#' The counterpart of OpenFHE's `GenCryptoContext(parameters)`. It
#' returns the context with no feature enabled; call
#' [enable_feature()] for each feature the computation needs, as the
#' OpenFHE examples do. [fhe_context()] does both steps in one call
#' and enables the three features most computations use.
#'
#' @param params A `BFVParams`, `BGVParams`, or `CKKSParams` object.
#' @return A `CryptoContext` with no feature enabled.
#' @seealso [fhe_context()], [enable_feature()], [ccparams_setters]
#' @examples
#' p <- BFVParams()
#' set_plaintext_modulus(p, 65537)
#' set_multiplicative_depth(p, 2L)
#' cc <- gen_crypto_context(p)
#' enable_feature(cc, Feature$PKE)
#' enable_feature(cc, Feature$KEYSWITCH)
#' enable_feature(cc, Feature$LEVELEDSHE)
#' ring_dimension(cc)
#' @export
gen_crypto_context <- function(params) {
  cc_xp <- if (S7::S7_inherits(params, BFVParams)) {
    GenCryptoContext__BFV(get_ptr(params))
  } else if (S7::S7_inherits(params, BGVParams)) {
    GenCryptoContext__BGV(get_ptr(params))
  } else if (S7::S7_inherits(params, CKKSParams)) {
    GenCryptoContext__CKKS(get_ptr(params))
  } else {
    cli_abort("{.arg params} must be a {.cls BFVParams}, {.cls BGVParams}, or {.cls CKKSParams} object.")
  }
  ## >>> S7-FAST-NEW (RConsortium/S7#723): original
  ## CryptoContext(ptr = cc_xp)
  ## <<< S7-FAST-NEW
  .fast_new(CryptoContext, cc_xp)
}

#' Enable a feature on a CryptoContext
#'
#' Accepts either a single `PKESchemeFeature` enum value or a
#' `uint32_t` bitwise-OR mask of `PKESchemeFeature` values (for
#' matching the C++ `Enable(uint32_t)` overload). The two paths
#' dispatch on the value itself: a mask is detected by being
#' strictly larger than the largest single-feature value
#' (`Feature$SCHEMESWITCH = 0x80 = 128`) or by having more than one
#' bit set.
#'
#' @param cc A `CryptoContext`.
#' @param ... `feature`: a `Feature` value (single) or an integer
#'   mask (e.g. `Feature$PKE + Feature$KEYSWITCH + Feature$LEVELEDSHE`,
#'   i.e. `11L`).
#' @return `cc` invisibly.
#' @export
enable_feature <- new_generic("enable_feature", "cc")

method(enable_feature, CryptoContext) <- function(cc, feature) {
  feature_int <- as.integer(feature)
  ## Single-feature values are powers of two up to 0x80. A mask
  ## has more than one bit set; dispatch to the mask overload.
  is_mask <- length(feature_int) > 1L ||
             bitwAnd(feature_int, feature_int - 1L) != 0L
  if (is_mask) {
    combined <- if (length(feature_int) > 1L) Reduce(bitwOr, feature_int) else feature_int
    CryptoContext__Enable_Mask(get_ptr(cc), as.integer(combined))
  } else {
    CryptoContext__Enable(get_ptr(cc), feature_int)
  }
  invisible(cc)
}

## get_scheme_id CryptoContext method is registered in
## plaintext-accessors.R because Collate loads context.R before
## plaintext-accessors.R (where the generic is declared), and
## method registrations can only happen after the generic exists.

#' Clear OpenFHE static maps and vectors
#'
#' Releases memory held in the upstream static eval-key maps and
#' related global caches. Useful in long-running R sessions where
#' repeated context construction accumulates static state. The
#' call is idempotent; calling it when no static state is held is
#' a no-op.
#'
#' @return `invisible(NULL)`.
#' @export
clear_static_maps_and_vectors <- function() {
  CryptoContext__ClearStaticMapsAndVectors()
  invisible(NULL)
}

#' Ring dimension of a CryptoContext
#'
#' Returns N, the cyclotomic ring dimension. The cyclotomic order
#' M used by `eval_fast_rotation()` is `2 * N`.
#'
#' @param cc A CryptoContext
#' @param ... Reserved for future method-specific arguments
#' @return Integer ring dimension
#' @export
ring_dimension <- new_generic("ring_dimension", "cc")

method(ring_dimension, CryptoContext) <- function(cc) {
  CryptoContext__GetRingDimension(get_ptr(cc))
}

method(print, CryptoContext) <- function(x, ...) {
  if (ptr_is_valid(x)) {
    rd <- CryptoContext__GetRingDimension(get_ptr(x))
    cli::cli_text("{.cls CryptoContext} [ring_dim={rd}]")
  } else {
    cli::cli_text("{.cls CryptoContext} [null]")
  }
  invisible(x)
}
