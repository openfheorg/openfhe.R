## OPENFHE PYTHON SOURCE: src/lib/bindings.cpp (Key classes)

#' Public Key
#' @param ptr External pointer (internal use)
#' @return An S7 object of class `PublicKey`, inheriting from [OpenFHEObject],
#'   whose `ptr` property holds an external pointer to the C++ public
#'   key. This is the key [encrypt()] takes; obtain one as the `public`
#'   element of the [KeyPair] returned by [key_gen()] rather than by
#'   calling this constructor directly.
#' @export
PublicKey <- new_class("PublicKey",
  parent = OpenFHEObject,
  package = "openfhe.R"
)

#' Private Key
#' @param ptr External pointer (internal use)
#' @return An S7 object of class `PrivateKey`, inheriting from [OpenFHEObject],
#'   whose `ptr` property holds an external pointer to the C++ secret
#'   key. This is the key [decrypt()] takes; obtain one as the `secret`
#'   element of the [KeyPair] returned by [key_gen()] rather than by
#'   calling this constructor directly.
#' @export
PrivateKey <- new_class("PrivateKey",
  parent = OpenFHEObject,
  package = "openfhe.R"
)

#' Key Pair
#'
#' Contains a public key and a secret (private) key.
#' @param public A PublicKey
#' @param secret A PrivateKey
#' @return An S7 object of class `KeyPair` with two properties, `public` (a
#'   [PublicKey]) and `secret` (a [PrivateKey]), which are the two halves
#'   of one freshly generated key. Obtain one from [key_gen()] rather
#'   than by calling this constructor directly.
#' @export
KeyPair <- new_class("KeyPair",
  package = "openfhe.R",
  properties = list(
    public = class_any,
    secret = class_any
  )
)

#' Generate key pair
#' @param cc A CryptoContext
#' @param ... Method-specific arguments (eval_mult, rotations)
#' @return A KeyPair
#' @examples
#' cc <- fhe_context("CKKS", multiplicative_depth = 2L,
#'                   scaling_mod_size = 50L, batch_size = 8L)
#'
#' ## Encryption keys only:
#' kp <- key_gen(cc)
#' kp
#'
#' ## Also generate the relinearization key homomorphic multiplication
#' ## needs and the rotation keys for shifts by one slot either way.
#' ## These are stored inside the context, not in the returned pair.
#' kp <- key_gen(cc, eval_mult = TRUE, rotations = c(1L, -1L))
#' kp@public
#' kp@secret
#' @export
key_gen <- new_generic("key_gen", "cc")

method(key_gen, CryptoContext) <- function(cc, eval_mult = FALSE, rotations = NULL) {
  cc_ptr <- get_ptr(cc)
  kp_list <- CryptoContext__KeyGen(cc_ptr)

  pk <- PublicKey(ptr = kp_list$public)
  sk <- PrivateKey(ptr = kp_list$secret)

  if (eval_mult) {
    CryptoContext__EvalMultKeyGen(cc_ptr, kp_list$secret)
  }

  if (!is.null(rotations)) {
    CryptoContext__EvalRotateKeyGen(cc_ptr, kp_list$secret, as.integer(rotations))
  }

  KeyPair(public = pk, secret = sk)
}

method(print, KeyPair) <- function(x, ...) {
  cli::cli_text("{.cls KeyPair} [public + secret]")
  invisible(x)
}

method(print, PublicKey) <- function(x, ...) {
  cli::cli_text("{.cls PublicKey} [{if (ptr_is_valid(x)) 'active' else 'null'}]")
  invisible(x)
}

method(print, PrivateKey) <- function(x, ...) {
  cli::cli_text("{.cls PrivateKey} [{if (ptr_is_valid(x)) 'active' else 'null'}]")
  invisible(x)
}

# ── Key-tag accessors ─────────────────────

#' Key tag accessors
#'
#' Every `PublicKey` / `PrivateKey` carries a string "key tag"
#' identifying which key pair it belongs to. The tag is set at
#' key-generation time by OpenFHE and can be inspected or
#' overwritten via these accessors. In threshold / multiparty
#' protocols the tag is used to associate a key with the party
#' that owns it; in single-user protocols it is typically left
#' at its default.
#'
#' @param key A `PublicKey` or `PrivateKey`.
#' @param ... Reserved for future method-specific arguments.
#'   `set_key_tag` accepts a `value` argument here.
#' @return `get_key_tag`: character scalar. `set_key_tag`: the
#'   key invisibly.
#' @name key_tag
NULL

#' @rdname key_tag
#' @export
get_key_tag <- new_generic("get_key_tag", "key")

#' @rdname key_tag
#' @export
set_key_tag <- new_generic("set_key_tag", "key")

method(get_key_tag, PublicKey)  <- function(key) PublicKey__GetKeyTag(get_ptr(key))
method(get_key_tag, PrivateKey) <- function(key) PrivateKey__GetKeyTag(get_ptr(key))

method(set_key_tag, PublicKey) <- function(key, value) {
  PublicKey__SetKeyTag(get_ptr(key), as.character(value))
  invisible(key)
}
method(set_key_tag, PrivateKey) <- function(key, value) {
  PrivateKey__SetKeyTag(get_ptr(key), as.character(value))
  invisible(key)
}

#' Is a KeyPair valid?
#'
#' Returns `TRUE` when both the public and secret keys of a
#' `KeyPair` are non-null external pointers. The C++
#' `KeyPair::good()` predicate performs the same check on the
#' C++ side; because R's `KeyPair` is a pure-R aggregate that
#' wraps an already-constructed `PublicKey` and `PrivateKey`,
#' the R-level check is equivalent.
#'
#' @param kp A `KeyPair`.
#' @param ... Reserved for future method-specific arguments
#'   (currently unused).
#' @return `TRUE` or `FALSE`.
#' @export
is_good <- new_generic("is_good", "kp")

method(is_good, KeyPair) <- function(kp) {
  ptr_is_valid(kp@public) && ptr_is_valid(kp@secret)
}
