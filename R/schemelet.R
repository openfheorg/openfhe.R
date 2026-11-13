## OPENFHE PYTHON SOURCE: src/lib/pke/fbt.cpp (PolyVector, SchemeletRLWEMP)
##
## R wrappers for src/pke_schemelet.cpp. The static methods of the C++
## class SchemeletRLWEMP are the functions prefixed `schemelet_`.

# ── PolyVector ──────────────────────────────────────────

#' An RLWE ciphertext
#'
#' The pair `{b, a}` of polynomials over one large modulus that the
#' `schemelet_` functions produce and consume. The class is an opaque
#' handle, as in openfhe-python. `PolyVector()` makes an empty one.
#'
#' `length()` gives the number of polynomials. `clone()` returns a
#' copy. `switch_modulus()` changes the modulus of every polynomial in
#' place, keeping the residues, and `x - y` subtracts two ciphertexts
#' element by element.
#'
#' [schemelet_mod_switch()] and `switch_modulus()` change the object
#' they are given. Assigning a `PolyVector` to another name does not
#' copy it; use `clone()` for a copy that later changes do not reach.
#'
#' @param ptr External pointer (internal use). `NULL` (default) makes
#'   an empty vector.
#' @param x A `PolyVector`.
#' @param modulus The new modulus: a string of decimal digits, or a
#'   whole number of at most 2^53.
#' @return `PolyVector()`: an S7 object of class `PolyVector`,
#'   inheriting from [OpenFHEObject]. `switch_modulus()`: `x`,
#'   invisibly.
#' @seealso [schemelet_encrypt_coeff()]
#' @export
PolyVector <- new_class("PolyVector",
  parent = OpenFHEObject,
  package = "openfhe.R",
  constructor = function(ptr = NULL) {
    if (is.null(ptr)) ptr <- PolyVector__new()
    new_object(S7_object(), ptr = ptr)
  }
)

method(print, PolyVector) <- function(x, ...) {
  if (ptr_is_valid(x)) {
    cli::cli_text("{.cls PolyVector} [active] of length {PolyVector__length(x@ptr)}")
  } else {
    cli::cli_text("{.cls PolyVector} [null]")
  }
  invisible(x)
}

method(length, PolyVector) <- function(x) PolyVector__length(get_ptr(x))

method(clone, PolyVector) <- function(x)
  ## >>> S7-FAST-NEW (RConsortium/S7#723): original
  ## PolyVector(ptr = PolyVector__clone(get_ptr(x)))
  ## <<< S7-FAST-NEW
  .fast_new(PolyVector, PolyVector__clone(get_ptr(x)))

method(`-`, list(PolyVector, PolyVector)) <- function(e1, e2)
  ## >>> S7-FAST-NEW (RConsortium/S7#723): original
  ## PolyVector(ptr = PolyVector__sub(get_ptr(e1), get_ptr(e2)))
  ## <<< S7-FAST-NEW
  .fast_new(PolyVector, PolyVector__sub(get_ptr(e1), get_ptr(e2)))

#' @rdname PolyVector
#' @export
switch_modulus <- function(x, modulus) {
  PolyVector__SwitchModulus(get_ptr(x), wide_integer(modulus))
  invisible(x)
}

# ── SchemeletRLWEMP ─────────────────────────────────────

## int64 messages cross the boundary as doubles.
.schemelet_message <- function(input, call = rlang::caller_env()) {
  ok <- is.numeric(input) && !is.object(input) && !anyNA(input) &&
    all(input == trunc(input)) && all(abs(input) <= 2^53)
  if (!ok) {
    cli_abort("{.arg input} must be a vector of whole numbers of magnitude at most 2^53.",
              call = call)
  }
  as.double(input)
}

#' RLWE encryption under a CKKS secret key
#'
#' The RLWE schemelet of OpenFHE (`SchemeletRLWEMP`): integers modulo
#' `p` are encrypted as the coefficients of an RLWE ciphertext over one
#' large modulus `q`, under the secret key of a CKKS context. It is the
#' input and output format of CKKS functional bootstrapping; see
#' [eval_fbt()].
#'
#' `schemelet_get_element_params()` returns the element parameters of
#' the key's context with `level` levels removed. Its modulus is the
#' one `schemelet_encrypt_coeff()` samples its encryption of zero
#' over.
#'
#' `schemelet_encrypt_coeff()` encrypts `input` and returns the RLWE
#' ciphertext modulo `q`. `schemelet_decrypt_coeff()` decrypts one,
#' returning values in `(-p/2, p/2]`.
#'
#' `schemelet_mod_switch()` switches a ciphertext from modulus `q2` to
#' modulus `q1` in place, scaling by `q1/q2` with rounding.
#'
#' `schemelet_get_q_prime()` returns the product
#' `q_0 * q_1 * ... * q_lvls` of the first `lvls + 1` RNS moduli of the
#' key's parameters.
#'
#' @param private_key A `PrivateKey` of a CKKS context.
#' @param level Integer; number of levels to remove. Default `0L`.
#' @param input For `schemelet_encrypt_coeff()`, a vector of whole
#'   numbers, each reduced modulo `p` as a signed value. For
#'   `schemelet_decrypt_coeff()` and `schemelet_mod_switch()`, a
#'   [PolyVector].
#' @param q,p,q1,q2 Moduli: strings of decimal digits, or whole numbers
#'   of at most 2^53. `q` is the ciphertext modulus and `p` the
#'   plaintext modulus.
#' @param element_params An `ElementParams` object from
#'   `schemelet_get_element_params()`.
#' @param bit_reverse Logical; encode the input in bit-reversed order
#'   (and undo it at decryption). Default `FALSE`.
#' @param num_slots Integer; the number of slots used in the CKKS
#'   computation, which sets the stride between message coefficients.
#' @param length Integer; number of values to return, `0L` (default)
#'   for `num_slots`.
#' @param pub_key A `PublicKey` of a CKKS context.
#' @param lvls Integer; number of moduli after `q_0` to include.
#' @return `schemelet_get_element_params()`: an `ElementParams`
#'   object. `schemelet_encrypt_coeff()`: a [PolyVector].
#'   `schemelet_decrypt_coeff()`: a numeric vector.
#'   `schemelet_mod_switch()`: `input`, invisibly.
#'   `schemelet_get_q_prime()`: a string of decimal digits.
#' @seealso [schemelet_convert_rlwe_to_ckks()]
#' @examples
#' cc <- fhe_context("CKKS", multiplicative_depth = 2L, scaling_mod_size = 50L,
#'                   batch_size = 8L)
#' keys <- key_gen(cc)
#' ep <- schemelet_get_element_params(keys@secret)
#' q <- "1152921504606846976"   # 2^60
#' ct <- schemelet_encrypt_coeff(c(1, 2, 3, 4, 5, 6, 7, 0), q, 16,
#'                               keys@secret, ep)
#' schemelet_decrypt_coeff(ct, q, 16, keys@secret, ep, num_slots = 8L)
#' @export
schemelet_get_element_params <- function(private_key, level = 0L) {
  ## >>> S7-FAST-NEW (RConsortium/S7#723): original
  ## ElementParams(ptr = Schemelet__GetElementParams(get_ptr(private_key),
  ##                                                 as.integer(level)))
  ## <<< S7-FAST-NEW
  .fast_new(ElementParams, Schemelet__GetElementParams(get_ptr(private_key),
                                                       as.integer(level)))
}

#' @rdname schemelet_get_element_params
#' @export
schemelet_encrypt_coeff <- function(input, q, p, private_key, element_params,
                                    bit_reverse = FALSE) {
  ## >>> S7-FAST-NEW (RConsortium/S7#723): original
  ## PolyVector(ptr = Schemelet__EncryptCoeff(
  ##   .schemelet_message(input), wide_integer(q), wide_integer(p),
  ##   get_ptr(private_key), get_ptr(element_params), isTRUE(bit_reverse)))
  ## <<< S7-FAST-NEW
  .fast_new(PolyVector, Schemelet__EncryptCoeff(
    .schemelet_message(input), wide_integer(q), wide_integer(p),
    get_ptr(private_key), get_ptr(element_params), isTRUE(bit_reverse)))
}

#' @rdname schemelet_get_element_params
#' @export
schemelet_decrypt_coeff <- function(input, q, p, private_key, element_params,
                                    num_slots, length = 0L,
                                    bit_reverse = FALSE) {
  Schemelet__DecryptCoeff(
    get_ptr(input), wide_integer(q), wide_integer(p), get_ptr(private_key),
    get_ptr(element_params), as.integer(num_slots), as.integer(length),
    isTRUE(bit_reverse))
}

#' @rdname schemelet_get_element_params
#' @export
schemelet_mod_switch <- function(input, q1, q2) {
  Schemelet__ModSwitch(get_ptr(input), wide_integer(q1), wide_integer(q2))
  invisible(input)
}

#' @rdname schemelet_get_element_params
#' @export
schemelet_get_q_prime <- function(pub_key, lvls) {
  Schemelet__GetQPrime(get_ptr(pub_key), as.integer(lvls))
}

#' Convert between RLWE and CKKS ciphertexts
#'
#' `schemelet_convert_rlwe_to_ckks()` embeds an RLWE ciphertext modulo
#' `big_q` into a CKKS ciphertext with `slots` slots at `level`, so
#' that [eval_fbt()] can process it. `schemelet_convert_ckks_to_rlwe()`
#' extracts an RLWE ciphertext modulo `q` from a CKKS ciphertext. Both
#' ciphertexts are under the same secret key.
#'
#' @param cc A CKKS `CryptoContext`.
#' @param coeffs A [PolyVector]; the RLWE ciphertext.
#' @param pub_key The `PublicKey`, used for an encryption of zero that
#'   supplies the metadata of the CKKS ciphertext.
#' @param big_q The modulus of the RLWE ciphertext: a string of decimal
#'   digits, or a whole number of at most 2^53.
#' @param slots Integer; number of slots of the CKKS ciphertext.
#' @param level Integer; level of the CKKS ciphertext. Default `0L`.
#' @param ctxt A CKKS `Ciphertext` with two elements.
#' @param q The modulus of the RLWE ciphertext to produce, as for
#'   `big_q`.
#' @return `schemelet_convert_rlwe_to_ckks()`: a `Ciphertext`.
#'   `schemelet_convert_ckks_to_rlwe()`: a [PolyVector].
#' @seealso [schemelet_encrypt_coeff()], [eval_fbt()]
#' @export
schemelet_convert_rlwe_to_ckks <- function(cc, coeffs, pub_key, big_q, slots,
                                           level = 0L) {
  ## >>> S7-FAST-NEW (RConsortium/S7#723): original
  ## Ciphertext(ptr = Schemelet__ConvertRLWEToCKKS(
  ##   get_ptr(cc), get_ptr(coeffs), get_ptr(pub_key), wide_integer(big_q),
  ##   as.integer(slots), as.integer(level)))
  ## <<< S7-FAST-NEW
  .fast_new(Ciphertext, Schemelet__ConvertRLWEToCKKS(
    get_ptr(cc), get_ptr(coeffs), get_ptr(pub_key), wide_integer(big_q),
    as.integer(slots), as.integer(level)))
}

#' @rdname schemelet_convert_rlwe_to_ckks
#' @export
schemelet_convert_ckks_to_rlwe <- function(ctxt, q) {
  ## >>> S7-FAST-NEW (RConsortium/S7#723): original
  ## PolyVector(ptr = Schemelet__ConvertCKKSToRLWE(get_ptr(ctxt), wide_integer(q)))
  ## <<< S7-FAST-NEW
  .fast_new(PolyVector, Schemelet__ConvertCKKSToRLWE(get_ptr(ctxt), wide_integer(q)))
}
