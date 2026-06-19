## OPENFHE PYTHON SOURCE: src/lib/bindings.cpp (Encrypt/Decrypt)

#' Encrypt a plaintext
#'
#' `encrypt` dispatches on both the key type and the plaintext.
#' The `(PublicKey, Plaintext)` method performs public-key
#' encryption and is the canonical path used by every vignette.
#' The `(PrivateKey, Plaintext)` method
#' performs symmetric / secret-key encryption using the private
#' key directly; it is useful in protocols that want the secret
#' key to serve as both encryption and decryption key (e.g.
#' one-party tests, single-user benchmarks).
#'
#' @param key A `PublicKey` or `PrivateKey`.
#' @param pt A `Plaintext`.
#' @param ... Additional arguments (`cc = CryptoContext` is
#'   required).
#' @return A `Ciphertext`.
#' @export
encrypt <- new_generic("encrypt", dispatch_args = c("key", "pt"))

#' Decrypt a ciphertext
#' @param ct A Ciphertext
#' @param key A PrivateKey
#' @param ... Additional arguments (cc = CryptoContext)
#' @return A Plaintext
#' @export
decrypt <- new_generic("decrypt", dispatch_args = c("ct", "key"))

# encrypt(PublicKey, Plaintext) -> Ciphertext
method(encrypt, list(PublicKey, Plaintext)) <- function(key, pt, cc = NULL) {
  if (is.null(cc)) {
    cli_abort("CryptoContext {.arg cc} is required for encryption")
  }
  ct_xp <- CryptoContext__Encrypt_PublicKey(get_ptr(cc), get_ptr(key), get_ptr(pt))
  Ciphertext(ptr = ct_xp)
}

# encrypt(PrivateKey, Plaintext) -> Ciphertext
method(encrypt, list(PrivateKey, Plaintext)) <- function(key, pt, cc = NULL) {
  if (is.null(cc)) {
    cli_abort("CryptoContext {.arg cc} is required for encryption")
  }
  ct_xp <- CryptoContext__Encrypt_PrivateKey(get_ptr(cc), get_ptr(key), get_ptr(pt))
  Ciphertext(ptr = ct_xp)
}

method(decrypt, list(Ciphertext, PrivateKey)) <- function(ct, key, cc = NULL) {
  if (is.null(cc)) {
    cli_abort("CryptoContext {.arg cc} is required for decryption")
  }
  pt_xp <- CryptoContext__Decrypt(get_ptr(cc), get_ptr(key), get_ptr(ct))
  Plaintext(ptr = pt_xp)
}

#' Make a packed integer plaintext
#'
#' Encode an integer vector as a BFV / BGV packed plaintext. The
#' result is an unencrypted `Plaintext` object that can then be
#' passed to `encrypt()`.
#'
#' @param cc A `CryptoContext`.
#' @param values An integer vector to pack. Length must not exceed
#'   `batch_size` set at context creation.
#' @param noise_scale_deg Integer degree of the initial scaling
#'   factor applied to the encoded plaintext. Defaults to `1L`;
#'   only meaningful under `FIXEDMANUAL` scaling (under
#'   `FLEXIBLEAUTO` the scheme overrides this value). Every current
#'   vignette leaves it at the default.
#' @param level Integer target level in the RNS modulus chain.
#'   Defaults to `0L`, meaning "fresh level, matching a
#'   just-encrypted ciphertext". Set to match the level of a
#'   ciphertext the plaintext will interact with if the ciphertext
#'   has already been rescaled.
#' @return A `Plaintext`.
#' @export
make_packed_plaintext <- function(cc, values,
                                  noise_scale_deg = 1L,
                                  level = 0L) {
  pt_xp <- CryptoContext__MakePackedPlaintext(
    get_ptr(cc),
    as.integer(values),
    as.integer(noise_scale_deg),
    as.integer(level)
  )
  Plaintext(ptr = pt_xp)
}

#' Make a coefficient-packed integer plaintext
#'
#' Encode an integer vector as a coefficient-packed plaintext.
#' Coefficient packing places each input value in a separate
#' polynomial coefficient and is the alternative to the SIMD
#' batched packing produced by `make_packed_plaintext()`. Used by
#' the integer-modulus Ring-LWE vignettes where per-coefficient
#' access is needed.
#'
#' @param cc A `CryptoContext` (BFV or BGV).
#' @param values An integer vector whose length must not exceed
#'   the ring dimension of `cc`.
#' @param noise_scale_deg See the [make_packed_plaintext()] entry.
#' @param level See the [make_packed_plaintext()] entry.
#' @return A `Plaintext`.
#' @export
make_coef_packed_plaintext <- function(cc, values,
                                       noise_scale_deg = 1L,
                                       level = 0L) {
  pt_xp <- CryptoContext__MakeCoefPackedPlaintext(
    get_ptr(cc),
    as.integer(values),
    as.integer(noise_scale_deg),
    as.integer(level)
  )
  Plaintext(ptr = pt_xp)
}
