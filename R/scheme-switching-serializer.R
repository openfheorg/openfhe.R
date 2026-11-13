## OPENFHE PYTHON SOURCE: src/lib/pke/fbt.cpp (SchemeSwitchingDataSerializer, SchemeSwitchingDataDeserializer)
##
## R wrappers for src/pke_schswch_serializer.cpp.

#' Write and read the data of a scheme-switching computation
#'
#' A scheme-switching computation needs a CKKS context with its public
#' key and evaluation keys, the FHEW context inside it with its
#' bootstrapping keys, the switching key from FHEW to CKKS, and the
#' ciphertext to work on. `SchemeSwitchingDataSerializer` writes all of
#' it to a directory, and `SchemeSwitchingDataDeserializer` reads it
#' back in another session, so that one party can set the computation
#' up and another can run it.
#'
#' The writer is made from the context, the public key and the
#' ciphertext. `set_data_directory()` names the directory, which must
#' exist, and `serialize_scheme_switching_data()` writes the files
#' (binary format, fixed file names). The multiplication and
#' automorphism keys written are all those in the key registries.
#'
#' The reader is made empty. After `set_data_directory()`,
#' `deserialize_scheme_switching_data()` reads the files, registers the
#' evaluation keys, and puts the FHEW context and the switching key
#' into the CKKS context. [get_crypto_context()], [get_public_key()]
#' and `get_raw_ciphertext()` then return the three objects.
#'
#' The C++ classes default the directory to `demoData` under the
#' working directory. The R functions do not: reading or writing before
#' `set_data_directory()` is an error.
#'
#' @param crypto_context A CKKS `CryptoContext` on which scheme
#'   switching has been set up and its keys generated
#'   ([eval_scheme_switching_setup()],
#'   [eval_scheme_switching_key_gen()]).
#' @param public_key The `PublicKey` of the context.
#' @param raw_ciphertext The `Ciphertext` to write.
#' @param ptr External pointer (internal use).
#' @param x A `SchemeSwitchingDataSerializer` or
#'   `SchemeSwitchingDataDeserializer`.
#' @param dir Character string; the directory.
#' @return The constructors: an S7 object of the class, inheriting from
#'   [OpenFHEObject]. `get_raw_ciphertext()`: a `Ciphertext`, or `NULL`
#'   before the data has been read. The others: `x`, invisibly.
#' @export
SchemeSwitchingDataSerializer <- new_class("SchemeSwitchingDataSerializer",
  parent = OpenFHEObject,
  package = "openfhe.R",
  constructor = function(crypto_context = NULL, public_key = NULL,
                         raw_ciphertext = NULL, ptr = NULL) {
    if (is.null(ptr)) {
      if (is.null(crypto_context) || is.null(public_key) ||
          is.null(raw_ciphertext)) {
        cli_abort("{.arg crypto_context}, {.arg public_key} and {.arg raw_ciphertext} are all required.")
      }
      ptr <- SchSwchSerializer__new(get_ptr(crypto_context), get_ptr(public_key),
                                    get_ptr(raw_ciphertext))
    }
    new_object(S7_object(), ptr = ptr)
  }
)

#' @rdname SchemeSwitchingDataSerializer
#' @export
SchemeSwitchingDataDeserializer <- new_class("SchemeSwitchingDataDeserializer",
  parent = OpenFHEObject,
  package = "openfhe.R",
  constructor = function(ptr = NULL) {
    if (is.null(ptr)) ptr <- SchSwchDeserializer__new()
    new_object(S7_object(), ptr = ptr)
  }
)

method(print, SchemeSwitchingDataSerializer) <- function(x, ...) {
  cli::cli_text("{.cls SchemeSwitchingDataSerializer} [{if (ptr_is_valid(x)) 'active' else 'null'}]")
  invisible(x)
}

method(print, SchemeSwitchingDataDeserializer) <- function(x, ...) {
  cli::cli_text("{.cls SchemeSwitchingDataDeserializer} [{if (ptr_is_valid(x)) 'active' else 'null'}]")
  invisible(x)
}

#' @rdname SchemeSwitchingDataSerializer
#' @export
set_data_directory <- function(x, dir) {
  if (!is.character(dir) || length(dir) != 1L || is.na(dir) || !nzchar(dir)) {
    cli_abort("{.arg dir} must be a single non-empty string.")
  }
  if (S7::S7_inherits(x, SchemeSwitchingDataSerializer)) {
    SchSwchSerializer__SetDataDirectory(get_ptr(x), dir)
  } else if (S7::S7_inherits(x, SchemeSwitchingDataDeserializer)) {
    SchSwchDeserializer__SetDataDirectory(get_ptr(x), dir)
  } else {
    cli_abort("{.arg x} must be a {.cls SchemeSwitchingDataSerializer} or a {.cls SchemeSwitchingDataDeserializer}.")
  }
  invisible(x)
}

#' @rdname SchemeSwitchingDataSerializer
#' @export
serialize_scheme_switching_data <- function(x) {
  SchSwchSerializer__Serialize(get_ptr(x))
  invisible(x)
}

#' @rdname SchemeSwitchingDataSerializer
#' @export
deserialize_scheme_switching_data <- function(x) {
  SchSwchDeserializer__Deserialize(get_ptr(x))
  invisible(x)
}

#' @rdname SchemeSwitchingDataSerializer
#' @export
get_raw_ciphertext <- function(x) {
  p <- SchSwchDeserializer__get(get_ptr(x), 2L)
  ## >>> S7-FAST-NEW (RConsortium/S7#723): original
  ## if (is.null(p)) NULL else Ciphertext(ptr = p)
  ## <<< S7-FAST-NEW
  if (is.null(p)) NULL else .fast_new(Ciphertext, p)
}

## get_crypto_context generic: R/ciphertext-accessors.R (dispatch on
## `ct`); get_public_key generic: R/binfhe-keys.R (dispatch on `x`).
method(get_crypto_context, SchemeSwitchingDataDeserializer) <- function(ct) {
  p <- SchSwchDeserializer__get(get_ptr(ct), 0L)
  ## >>> S7-FAST-NEW (RConsortium/S7#723): original
  ## if (is.null(p)) NULL else CryptoContext(ptr = p)
  ## <<< S7-FAST-NEW
  if (is.null(p)) NULL else .fast_new(CryptoContext, p)
}

method(get_public_key, SchemeSwitchingDataDeserializer) <- function(x) {
  p <- SchSwchDeserializer__get(get_ptr(x), 1L)
  ## >>> S7-FAST-NEW (RConsortium/S7#723): original
  ## if (is.null(p)) NULL else PublicKey(ptr = p)
  ## <<< S7-FAST-NEW
  if (is.null(p)) NULL else .fast_new(PublicKey, p)
}
