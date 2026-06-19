## R-SPECIFIC: CKKS tolerance helper
##
## Per-test CKKS tolerance computed from circuit parameters, not a
## fixed default. tinytest's `expect_equal` defaults to
## `sqrt(.Machine$double.eps)` (~1.5e-8), orders of magnitude tighter
## than CKKS precision at depth >= 6, so a default-tolerance
## comparison would flake.
##
## The helper provides a **Stage 2** form: the
## tolerance helper is an S7 generic dispatched on its first argument.
## Two methods:
##   - `class_numeric`: the Stage 1 form — parameters passed as
##     direct arguments. Existing fixture authors who computed the
##     parameters by hand keep working.
##   - `Ciphertext`: the Stage 2 form — metadata is read live from the
##     ciphertext via get_crypto_context(ct) + the CryptoContext
##     getter fleet + the ckks_scaling_factor_bits(cc) helper.
##     Fixture authors who have a ciphertext in hand just pass it
##     directly and skip the manual parameter recall.

#' Per-test CKKS precision tolerance
#'
#' Computes a tolerance value suitable for comparing the cleartext
#' result of a CKKS circuit against a decrypted ciphertext. The
#' value is a function of the scheme's scaling factor, the
#' circuit's multiplicative depth at the point of decryption, and
#' the `ScalingTechnique`-specific precision loss per level.
#'
#' Two dispatch forms:
#'
#' - **Stage 1 (numeric)**: pass parameters as direct arguments.
#'   Useful when the ciphertext isn't yet constructed — e.g. when
#'   you need a tolerance before calling `encrypt()`.
#' - **Stage 2 (Ciphertext)**: pass a `Ciphertext` directly. The
#'   helper reads the associated `CryptoContext` via
#'   [get_crypto_context()], pulls the multiplicative depth (from
#'   context) minus the ciphertext's current level, computes the
#'   scaling factor bits via [ckks_scaling_factor_bits()], and
#'   looks up the scaling technique. This form is preferred at
#'   test sites where a ciphertext exists.
#'
#' @param x For the numeric method: integer multiplicative depth
#'   at the point of decryption. For the Ciphertext method: a
#'   `Ciphertext` object whose associated context supplies all
#'   parameters.
#' @param ... Method-specific arguments. The numeric method
#'   accepts `scaling_factor_bits` (integer bit size of the
#'   scaling modulus, typical values 50/59/78), `scaling_technique`
#'   (a character string like `"FLEXIBLEAUTO"` or an integer from
#'   the `ScalingTechnique` enum), and `k` (conservative
#'   multiplicative factor, default 8). The Ciphertext method
#'   accepts only `k`.
#' @return Numeric scalar — the tolerance value to use as
#'   `tolerance` in `tinytest::expect_equal()` or as `atol` in a
#'   manual diff.
#' @examples
#' # Stage 1 — pass parameters directly:
#' tol1 <- fhe_ckks_tolerance(4L, 50L, "FLEXIBLEAUTO")
#'
#' # Stage 2 — pass a ciphertext (requires a live CKKS context):
#' # cc <- fhe_context("CKKS", multiplicative_depth = 4L, scaling_mod_size = 50L)
#' # kp <- key_gen(cc, eval_mult = TRUE)
#' # pt <- make_ckks_packed_plaintext(cc, c(0.1, 0.2, 0.3, 0.4))
#' # ct <- encrypt(kp@public, pt, cc)
#' # tol2 <- fhe_ckks_tolerance(ct)
#' @export
fhe_ckks_tolerance <- new_generic("fhe_ckks_tolerance", "x")

# ── Stage 1: numeric method ────────────────────────────

method(fhe_ckks_tolerance, class_numeric) <- function(x,
                                                      scaling_factor_bits,
                                                      scaling_technique,
                                                      k = 8) {
  if (length(x) != 1L || x < 0) {
    cli::cli_abort(
      "{.arg x} (multiplicative depth) must be a non-negative scalar, not {.val {x}}.")
  }
  if (!is.numeric(scaling_factor_bits) || length(scaling_factor_bits) != 1L ||
      scaling_factor_bits <= 0) {
    cli::cli_abort(
      "{.arg scaling_factor_bits} must be a positive integer of length 1, not {.val {scaling_factor_bits}}.")
  }
  if (length(scaling_technique) != 1L) {
    cli::cli_abort(
      "{.arg scaling_technique} must be a single character string or integer enum value.")
  }
  if (!is.numeric(k) || length(k) != 1L || k <= 0) {
    cli::cli_abort("{.arg k} must be a positive numeric scalar, not {.val {k}}.")
  }

  ## Normalize scaling_technique to its character-name form so the
  ## precision-loss lookup table works. Accept both a character
  ## string (Stage 1 fixture-author form) and an integer enum value
  ## (Stage 2 dispatch from the Ciphertext method, which gets the
  ## integer via get_scaling_technique()).
  if (is.numeric(scaling_technique)) {
    scaling_technique <- scaling_technique_name(as.integer(scaling_technique))
  }
  if (!is.character(scaling_technique)) {
    cli::cli_abort(
      "{.arg scaling_technique} must be a character string or integer enum value.")
  }

  precision_loss <- ckks_precision_loss_per_level(scaling_technique)
  k * 2^(-as.numeric(scaling_factor_bits) +
          as.numeric(x) * precision_loss)
}

# ── Stage 2: Ciphertext method ─────────────────────────

method(fhe_ckks_tolerance, Ciphertext) <- function(x, k = 8) {
  cc <- get_crypto_context(x)
  ## Remaining multiplicative budget = configured depth minus the
  ## ciphertext's current level. A freshly-encrypted ciphertext
  ## at level 0 has `get_multiplicative_depth(cc)` remaining.
  remaining_depth <- get_multiplicative_depth(cc) - get_level(x)
  sf_bits <- ckks_scaling_factor_bits(cc)
  tech_int <- get_scaling_technique(cc)
  fhe_ckks_tolerance(remaining_depth,
                     scaling_factor_bits = sf_bits,
                     scaling_technique   = tech_int,
                     k                   = k)
}

# ── Helpers ────────────────────────────────────────────

## Reverse-lookup: convert a ScalingTechnique integer back to its
## character-name key so the precision-loss switch table resolves.
## Unexported.
##
## @noRd
scaling_technique_name <- function(tech_int) {
  nms <- names(ScalingTechnique)
  match_nm <- nms[vapply(nms, function(nm) ScalingTechnique[[nm]] == tech_int,
                         logical(1L))]
  if (length(match_nm) == 0L) {
    cli::cli_abort(
      "Unknown scaling technique integer: {.val {tech_int}}.")
  }
  match_nm[1L]
}

## Per-level precision loss, in bits, by ScalingTechnique. The
## values are conservative approximations from the OpenFHE paper
## and from reading `pke/schemerns/rns-cryptoparameters.cpp`. They
## are NOT tightened until validated against a known circuit at
## test-authoring time. A loose tolerance that passes is strictly
## better than a tight tolerance that flakes and gets silently
## muted.
##
## Unexported. Consumed by the numeric method body above and by
## the Ciphertext method via the numeric path.
##
## @noRd
ckks_precision_loss_per_level <- function(scaling_technique) {
  ## TODO: derive these from `pke/constants-defs.h`
  ## ScalingTechnique enum documentation + `rns-cryptoparameters.cpp`
  ## rescale logic. The current values are placeholders that produce
  ## conservative tolerances.
  loss <- switch(
    scaling_technique,
    FIXEDMANUAL            = 0.0,  # explicit rescale; no auto-rescale drift
    FIXEDAUTO              = 0.5,  # automatic rescale, fixed scaling factor
    FLEXIBLEAUTO           = 1.0,  # scaling factor drifts to accommodate depth
    FLEXIBLEAUTOEXT        = 1.0,  # same model + extra rescale, ~constant offset folded into k
    COMPOSITESCALINGAUTO   = 1.0,  # TODO — no validated loss model
    COMPOSITESCALINGMANUAL = 0.0,  # explicit rescale; conservative match to FIXEDMANUAL
    NORESCALE              = 0.0,  # no rescale, no per-level loss
    INVALID_RS_TECHNIQUE   = 0.0,  # sentinel — should not appear in practice
    NULL
  )
  if (is.null(loss)) {
    cli::cli_abort(c(
      "Unknown {.arg scaling_technique}: {.val {scaling_technique}}.",
      "i" = "Must be one of: FIXEDMANUAL, FIXEDAUTO, FLEXIBLEAUTO, FLEXIBLEAUTOEXT, COMPOSITESCALINGAUTO, COMPOSITESCALINGMANUAL, NORESCALE."
    ))
  }
  loss
}
