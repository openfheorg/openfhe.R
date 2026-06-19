## OPENFHE PYTHON SOURCE: src/lib/bindings.cpp (Plaintext class accessors)
##
## S7 generic + Plaintext method surface for the
## PlaintextImpl Get*/Set*/IsEncoded/LowBound/HighBound methods.
##
## 26 new cpp11 bindings + 1 R-side helper (plaintext_params_hash).
## Every generic is defined on a bare dispatch variable (`x`) so
## that future Ciphertext accessor work can add methods
## to the same generic without having to rename or duplicate.
##
## Seven accessors carry full semantic roxygen:
## get_noise_scale_deg, get_length, get_level,
## get_scaling_factor, get_log_precision, get_formatted_values,
## set_ckks_data_type. The other 19 carry a minimal doc block.
##
## Four of these plus the R-side helper map to these C++ methods:
##   get_noise_scale_deg  -> Plaintext__GetNoiseScaleDeg
##   get_level            -> Plaintext__GetLevel
##   get_slots            -> Plaintext__GetSlots
##   plaintext_params_hash -> pure-R helper that concatenates the
##                           identifying fields into a deterministic
##                           string

#' Plaintext accessors
#'
#' Retrieve or set fields on a `Plaintext` object. Each accessor
#' wraps the corresponding upstream `PlaintextImpl::Get*`/`Set*`
#' method and returns its value unchanged.
#'
#' Several base-class accessors are declared `virtual` and throw
#' `OPENFHE_THROW` in the base implementation (e.g. `get_string_value`
#' on a non-string plaintext, `get_log_precision` on a non-CKKS
#' plaintext). Calling an accessor on the wrong kind of plaintext
#' therefore raises an R error via `cli::cli_abort`, not a silent
#' wrong value.
#'
#' @param x A `Plaintext`.
#' @param ... Reserved for future method-specific arguments.
#'   Setters accept a `value` argument here; `get_formatted_values`
#'   accepts a `precision` integer.
#' @return The underlying field value. Types vary per accessor.
#' @name plaintext_accessors
NULL

# ── Exercised getters (full semantic roxygen) ──────────

#' @describeIn plaintext_accessors Integer noise-scale-degree of a
#'   CKKS plaintext. After construction the degree is the value
#'   passed to `make_ckks_packed_plaintext(..., noise_scale_deg)`
#'   under `FIXEDMANUAL` scaling; under `FLEXIBLEAUTO` the scheme
#'   overrides the user-supplied value at context-generation
#'   time. Incremented by each multiplication before a rescale.
#' @export
get_noise_scale_deg <- new_generic("get_noise_scale_deg", "x")

#' @describeIn plaintext_accessors Integer effective length of a
#'   packed plaintext — the number of slots that hold user-supplied
#'   values. Defaults to the full batch size at construction;
#'   `set_length()` can shorten it for display or decryption
#'   purposes.
#' @export
get_length <- new_generic("get_length", "x")

#' @describeIn plaintext_accessors Integer level of the plaintext
#'   in the RNS modulus chain. `0` for a fresh plaintext;
#'   incremented by each `rescale()` the plaintext survives. For
#'   CKKS-packed plaintexts the level must match the ciphertext
#'   level at every homomorphic operation, or the evaluator rejects
#'   the pair.
#' @export
get_level <- new_generic("get_level", "x")

#' @describeIn plaintext_accessors Numeric scaling factor for
#'   CKKS-based plaintexts — the multiplier the real vector is
#'   scaled by before encoding. Equals `2^scaling_mod_size` for a
#'   freshly-encoded plaintext under FLEXIBLEAUTO; halves after
#'   each rescale. For BFV/BGV plaintexts this is returned as a
#'   default value (no rescaling applies).
#' @export
get_scaling_factor <- new_generic("get_scaling_factor", "x")

#' @describeIn plaintext_accessors Numeric log2 of the precision
#'   lost during CKKS encoding. Only meaningful for CKKS plaintexts;
#'   throws via `OPENFHE_THROW` for BFV/BGV and is surfaced as an
#'   R error by `cli::cli_abort`.
#' @export
get_log_precision <- new_generic("get_log_precision", "x")

#' @describeIn plaintext_accessors String-format the plaintext's
#'   encoded values with `precision` decimal digits. Implemented
#'   on the concrete plaintext subclass (packed, CKKS, string,
#'   coefficient); throws on plaintexts whose subclass does not
#'   override.
#' @export
get_formatted_values <- new_generic("get_formatted_values", "x")

#' @describeIn plaintext_accessors Set the CKKS data type to
#'   `CKKSDataType$REAL` or `CKKSDataType$COMPLEX`. Only meaningful
#'   for CKKS plaintexts. Most R vignettes use the default `REAL`
#'   type; set to `COMPLEX` only when you are constructing a CKKS
#'   plaintext from a complex vector.
#' @export
set_ckks_data_type <- new_generic("set_ckks_data_type", "x")

# ── Additional getters ────────────────────────────

#' @describeIn plaintext_accessors integer
#'   encoding type (see `PlaintextEncodings` for the enum values).
#' @export
get_encoding_type <- new_generic("get_encoding_type", "x")

#' @describeIn plaintext_accessors BGV integer
#'   scaling factor. Returned as a double carrying a losslessly
#'   rounded 53-bit integer.
#' @export
get_scaling_factor_int <- new_generic("get_scaling_factor_int", "x")

#' @describeIn plaintext_accessors scheme
#'   identifier (see `SchemeId` enum).
#' @export
get_scheme_id <- new_generic("get_scheme_id", "x")

#' @describeIn plaintext_accessors logical
#'   "has the plaintext been encoded yet?" The factory methods
#'   typically encode plaintexts eagerly, so this is `TRUE` for
#'   fresh plaintexts. Returns `FALSE` only for plaintexts
#'   constructed in a two-step uninitialised form.
#' @export
is_encoded <- new_generic("is_encoded", "x")

## get_ckks_data_type is NOT re-declared here. The generic is
## defined in params-getters.R for the CCParams class
## family; here we extend it with a Plaintext method further
## down in this file. Re-declaring the generic would overwrite
## the CCParams methods and break test_params_getters_9104.R.

#' @describeIn plaintext_accessors integer
#'   lower bound that can be encoded with the current plaintext
#'   modulus: `-floor(t / 2)`.
#' @export
low_bound <- new_generic("low_bound", "x")

#' @describeIn plaintext_accessors integer
#'   upper bound that can be encoded with the current plaintext
#'   modulus: `floor(t / 2)`.
#' @export
high_bound <- new_generic("high_bound", "x")

#' @describeIn plaintext_accessors integer CKKS
#'   slot count. For `Plaintext` dispatch this is the `GetSlots()`
#'   value set at construction.
#' @export
get_slots <- new_generic("get_slots", "x")

#' @describeIn plaintext_accessors numeric
#'   log2 of the error estimate. Only meaningful for CKKS
#'   plaintexts; throws for BFV/BGV.
#' @export
get_log_error <- new_generic("get_log_error", "x")

#' @describeIn plaintext_accessors integer
#'   vector of the underlying coef-packed encoding. Throws for
#'   plaintexts whose subclass is not coef-packed.
#' @export
get_coef_packed_value <- new_generic("get_coef_packed_value", "x")

#' @describeIn plaintext_accessors string value
#'   of a string-encoded plaintext. Throws for plaintexts whose
#'   subclass is not string-encoded.
#' @export
get_string_value <- new_generic("get_string_value", "x")

#' @describeIn plaintext_accessors integer ring
#'   dimension of the underlying `Element`. This is the plaintext's
#'   view of the lattice ring dimension; typically matches the
#'   crypto context's ring dimension.
#' @export
get_element_ring_dimension <- new_generic("get_element_ring_dimension", "x")

# ── Additional setters ────────────────────────────

#' @describeIn plaintext_accessors set the CKKS
#'   plaintext scaling factor.
#' @export
set_scaling_factor <- new_generic("set_scaling_factor", "x")

#' @describeIn plaintext_accessors set the BGV
#'   plaintext integer scaling factor.
#' @export
set_scaling_factor_int <- new_generic("set_scaling_factor_int", "x")

#' @describeIn plaintext_accessors set the
#'   plaintext noise scale degree. Most users should not call this
#'   directly — the factory methods and the evaluator manage
#'   `noise_scale_deg` automatically.
#' @export
set_noise_scale_deg <- new_generic("set_noise_scale_deg", "x")

#' @describeIn plaintext_accessors set the
#'   plaintext level. As with `set_noise_scale_deg`, most users
#'   should not call this directly.
#' @export
set_level <- new_generic("set_level", "x")

#' @describeIn plaintext_accessors set the CKKS
#'   slot count. As with `set_length`, this is typically managed
#'   by the factory methods.
#' @export
set_slots <- new_generic("set_slots", "x")

#' @describeIn plaintext_accessors set the
#'   string value of a string-encoded plaintext. Throws for
#'   plaintexts whose subclass is not string-encoded.
#' @export
set_string_value <- new_generic("set_string_value", "x")

#' @describeIn plaintext_accessors set the
#'   integer-vector value of an integer-encoded plaintext. Throws
#'   for plaintexts whose subclass does not support an integer
#'   vector.
#' @export
set_int_vector_value <- new_generic("set_int_vector_value", "x")

# ── Method registrations on the Plaintext class ────────

method(get_noise_scale_deg, Plaintext) <- function(x) Plaintext__GetNoiseScaleDeg(get_ptr(x))
method(get_length, Plaintext)          <- function(x) Plaintext__GetLength(get_ptr(x))
method(get_level, Plaintext)           <- function(x) Plaintext__GetLevel(get_ptr(x))
method(get_scaling_factor, Plaintext)  <- function(x) Plaintext__GetScalingFactor(get_ptr(x))
method(get_log_precision, Plaintext)   <- function(x) Plaintext__GetLogPrecision(get_ptr(x))
method(get_formatted_values, Plaintext) <- function(x, precision = 2L)
  Plaintext__GetFormattedValues(get_ptr(x), as.integer(precision))
method(set_ckks_data_type, Plaintext)  <- function(x, value) {
  Plaintext__SetCKKSDataType(get_ptr(x), as.integer(value))
  invisible(x)
}

method(get_encoding_type, Plaintext)       <- function(x) Plaintext__GetEncodingType(get_ptr(x))
method(get_scaling_factor_int, Plaintext)  <- function(x) Plaintext__GetScalingFactorInt(get_ptr(x))
method(get_scheme_id, Plaintext)           <- function(x) Plaintext__GetSchemeID(get_ptr(x))
method(is_encoded, Plaintext)              <- function(x) Plaintext__IsEncoded(get_ptr(x))
## get_ckks_data_type generic was defined in params-getters.R
## with dispatch = "params", so the Plaintext method must use `params`
## as its first arg name. S7 enforces this signature match.
method(get_ckks_data_type, Plaintext) <- function(params)
  Plaintext__GetCKKSDataType(get_ptr(params))
method(low_bound, Plaintext)               <- function(x) Plaintext__LowBound(get_ptr(x))
method(high_bound, Plaintext)              <- function(x) Plaintext__HighBound(get_ptr(x))
method(get_slots, Plaintext)               <- function(x) Plaintext__GetSlots(get_ptr(x))
method(get_log_error, Plaintext)           <- function(x) Plaintext__GetLogError(get_ptr(x))
method(get_coef_packed_value, Plaintext)   <- function(x) Plaintext__GetCoefPackedValue(get_ptr(x))
method(get_string_value, Plaintext)        <- function(x) Plaintext__GetStringValue(get_ptr(x))
method(get_element_ring_dimension, Plaintext) <- function(x)
  Plaintext__GetElementRingDimension(get_ptr(x))

method(set_scaling_factor, Plaintext) <- function(x, value) {
  Plaintext__SetScalingFactor(get_ptr(x), as.double(value))
  invisible(x)
}
method(set_scaling_factor_int, Plaintext) <- function(x, value) {
  Plaintext__SetScalingFactorInt(get_ptr(x), as.integer(value))
  invisible(x)
}
method(set_noise_scale_deg, Plaintext) <- function(x, value) {
  Plaintext__SetNoiseScaleDeg(get_ptr(x), as.integer(value))
  invisible(x)
}
method(set_level, Plaintext) <- function(x, value) {
  Plaintext__SetLevel(get_ptr(x), as.integer(value))
  invisible(x)
}
method(set_slots, Plaintext) <- function(x, value) {
  Plaintext__SetSlots(get_ptr(x), as.integer(value))
  invisible(x)
}
method(set_string_value, Plaintext) <- function(x, value) {
  Plaintext__SetStringValue(get_ptr(x), as.character(value))
  invisible(x)
}
method(set_int_vector_value, Plaintext) <- function(x, value) {
  Plaintext__SetIntVectorValue(get_ptr(x), as.integer(value))
  invisible(x)
}

# ── CryptoContext method registrations for shared generics ─

## get_scheme_id is declared above (as an S7 generic with dispatch
## on `x`) for Plaintext; the CryptoContext method is registered
## here rather than in context.R because Collate loads context.R
## BEFORE plaintext-accessors.R, so the generic does not exist at
## context.R load time. Registering here also keeps all
## get_scheme_id method bodies in one file.
method(get_scheme_id, CryptoContext) <- function(x) {
  CryptoContext__GetSchemeId(get_ptr(x))
}

# ── plaintext_params_hash: R-side helper ───────

#' Deterministic hash of a plaintext's identifying parameters
#'
#' Combines the plaintext's encoding type, scaling factor, noise
#' scale degree, level, and slot count into a deterministic string
#' representation. Two plaintexts with identical parameters produce
#' identical strings; any parameter change produces a different
#' string.
#'
#' Not a cryptographic hash — equality comparison is the only
#' guarantee. The returned string's format is implementation
#' detail and may change without notice.
#'
#' @param x A `Plaintext`.
#' @return Character scalar.
#' @export
plaintext_params_hash <- function(x) {
  sprintf("enc=%d|sf=%s|noise=%d|level=%d|slots=%d",
          get_encoding_type(x),
          format(get_scaling_factor(x), digits = 17),
          get_noise_scale_deg(x),
          get_level(x),
          get_slots(x))
}
