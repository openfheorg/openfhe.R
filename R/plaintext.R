## OPENFHE PYTHON SOURCE: src/lib/bindings.cpp (Plaintext class)

#' Plaintext
#' @param ptr External pointer (internal use)
#' @export
Plaintext <- new_class("Plaintext",
  parent = OpenFHEObject,
  package = "openfhe.R"
)

#' Get packed integer values from a plaintext
#' @param pt A Plaintext
#' @return Integer vector
#' @export
get_packed_value <- function(pt) {
  Plaintext__GetPackedValue(get_ptr(pt))
}

#' Set the effective length of a plaintext
#' @param pt A Plaintext
#' @param len Integer length
#' @export
set_length <- function(pt, len) {
  Plaintext__SetLength(get_ptr(pt), as.integer(len))
  invisible(pt)
}

#' Make a CKKS packed plaintext from real numbers
#'
#' Encode a real-valued numeric vector as a CKKS packed plaintext.
#' The result is an unencrypted `Plaintext` object that can then
#' be passed to `encrypt()`.
#'
#' @param cc A `CryptoContext` built with `scheme = "CKKS"`.
#' @param values A numeric vector to pack. Length must not exceed
#'   `slots` (or `batch_size / 2` when `slots` is left at `0L`).
#' @param noise_scale_deg Integer degree of the initial scaling
#'   factor applied to the encoded plaintext, expressed as a power
#'   of the scheme's scaling factor. Defaults to `1L`, meaning
#'   "scale by the base scaling factor once", which is the value
#'   every current vignette implicitly uses. Setting
#'   `noise_scale_deg = 2L` encodes at scaling factor squared,
#'   which is occasionally useful when the plaintext is about to
#'   be subtracted from a ciphertext that has already been
#'   rescaled once and the two noise levels must agree. Under
#'   `FLEXIBLEAUTO` scaling the scheme's auto-rescale logic
#'   overrides this argument at context-generation time — see
#'   discovery D011 — so this parameter is only meaningful under
#'   `FIXEDMANUAL`. Couples tightly to `level`: a plaintext at
#'   `(noise_scale_deg = k, level = L)` may only interact with
#'   ciphertexts at the same `(k, L)`.
#' @param level Integer target encryption level of the encoded
#'   plaintext. Defaults to `0L`, meaning "encode at the fresh
#'   level, matching a just-encrypted ciphertext". When performing
#'   an operation between an encoded plaintext and a ciphertext
#'   that has already been rescaled `L` times, the plaintext must
#'   be encoded at `level = L` so the two sit at the same level of
#'   the modulus chain; otherwise the evaluator will silently
#'   mismatch or error depending on the scheme variant. The
#'   canonical case for setting this is encoding a constant vector
#'   for use inside a deep CKKS circuit, not for fresh-input
#'   computation. Couples to `noise_scale_deg` and to the
#'   multiplicative depth of the crypto context, which bounds the
#'   maximum valid `level`.
#' @param params Advanced. An `ElementParams` object to encode
#'   against, or `NULL` to use the `cryptocontext`'s own parameters
#'   at the chosen `level`. Defaults to `NULL`, which is the only
#'   value any current vignette or test uses. There is no R-side
#'   way to construct a fresh `ElementParams` (only to wrap one
#'   returned by `get_element_params(cc)`), so in practice the
#'   argument is accepted for surface parity with openfhe-python
#'   but is normally left at its default.
#' @param slots Integer number of CKKS slots to pack into.
#'   Defaults to `0L`, which is the upstream sentinel for "use the
#'   `batch_size` set on the context's params". Setting `slots` to
#'   a smaller power of two produces a plaintext that leaves the
#'   upper half of the packing register zero, which the evaluator
#'   exploits to reduce rotation cost in algorithms like
#'   `eval_sum`. The value must be a power of two and must not
#'   exceed `batch_size`. The natural time to set this is when
#'   you have a short input vector and rotations dominate the
#'   circuit cost, as in the CKKS-inner-product idiom; the natural
#'   time to leave it at `0L` is when you are encoding a
#'   full-width vector.
#' @return A `Plaintext`.
#' @export
make_ckks_packed_plaintext <- function(cc, values,
                                       noise_scale_deg = 1L,
                                       level = 0L,
                                       params = NULL,
                                       slots = 0L) {
  ## S3 dispatch on is.complex(values).
  ## When values is a complex vector, routes to the C++
  ## `std::vector<std::complex<double>>` overload at
  ## cryptocontext.h line 1175; otherwise the double
  ## path. The two C++ overloads produce semantically equivalent
  ## plaintexts (the double overload internally converts to
  ## complex before calling the same internal helper), so the
  ## R-side behavioral contract is unchanged for existing
  ## double callers.
  if (is.complex(values)) {
    ## The complex overload currently does not accept the
    ## `params` argument at the R layer — pass NULL internally.
    ## The params surface is an advanced knob that the existing
    ## double path supports; complex callers that need it can
    ## reach for the underlying cpp11 binding directly.
    if (!is.null(params)) {
      cli::cli_abort(c(
        "The {.arg params} argument is not yet supported on the complex path.",
        "i" = "Reach the underlying cpp11 binding directly, or file an issue if you need this combination."
      ))
    }
    pt_xp <- MakeCKKSPackedPlaintext__complex(
      get_ptr(cc),
      values,
      as.integer(noise_scale_deg),
      as.integer(level),
      as.integer(slots)
    )
  } else {
    params_xp <- if (is.null(params)) NULL else get_ptr(params)
    pt_xp <- CryptoContext__MakeCKKSPackedPlaintext(
      get_ptr(cc),
      as.double(values),
      as.integer(noise_scale_deg),
      as.integer(level),
      params_xp,
      as.integer(slots)
    )
  }
  Plaintext(ptr = pt_xp)
}

#' Get real values from a CKKS plaintext
#'
#' @param pt A Plaintext
#' @return Numeric vector
#' @seealso [get_complex_packed_value()] for the complex-view
#'   accessor on the same underlying plaintext (each slot
#'   internally carries a complex pair — this function
#'   returns only the real parts).
#' @export
get_real_packed_value <- function(pt) {
  Plaintext__GetRealPackedValue(get_ptr(pt))
}

#' Get complex values from a CKKS plaintext
#'
#' Reads the CKKS plaintext's internal slot vector as complex
#' numbers. Every CKKS plaintext slot carries a
#' `std::complex<double>` internally; when a plaintext was
#' constructed from a real-valued vector via
#' [make_ckks_packed_plaintext()], the imaginary parts are
#' all zero (up to CKKS encoding noise). When a plaintext
#' was constructed from a complex vector (the is-complex
#' dispatch path), both real and imaginary parts carry
#' information.
#'
#' @param pt A `Plaintext`.
#' @return A native R `complex` vector.
#' @seealso [get_real_packed_value()] for the real-only view,
#'   [make_ckks_packed_plaintext()] for the matching
#'   constructor.
#' @export
get_complex_packed_value <- function(pt) {
  Plaintext__GetCKKSPackedValue(get_ptr(pt))
}

method(print, Plaintext) <- function(x, ...) {
  if (ptr_is_valid(x)) {
    cli::cli_text("{.cls Plaintext}: {Plaintext__ToString(get_ptr(x))}")
  } else {
    cli::cli_text("{.cls Plaintext} [null]")
  }
  invisible(x)
}
