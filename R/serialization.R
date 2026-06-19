## OPENFHE PYTHON SOURCE: src/lib/pke/serialization.cpp

#' Serialize an OpenFHE object to file
#'
#' @param x An OpenFHE object (CryptoContext, PublicKey, PrivateKey, Ciphertext)
#' @param ... Method-specific arguments (filename, format)
#' @return TRUE on success (invisibly)
#' @export
fhe_serialize <- new_generic("fhe_serialize", "x")

method(fhe_serialize, CryptoContext) <- function(x, filename, format = "binary") {
  ok <- Serialize__CryptoContext(x@ptr, filename, format == "binary")
  if (!ok) cli_abort("Failed to serialize {.cls CryptoContext} to {.path {filename}}")
  invisible(ok)
}

method(fhe_serialize, PublicKey) <- function(x, filename, format = "binary") {
  ok <- Serialize__PublicKey(x@ptr, filename, format == "binary")
  if (!ok) cli_abort("Failed to serialize {.cls PublicKey} to {.path {filename}}")
  invisible(ok)
}

method(fhe_serialize, PrivateKey) <- function(x, filename, format = "binary") {
  ok <- Serialize__PrivateKey(x@ptr, filename, format == "binary")
  if (!ok) cli_abort("Failed to serialize {.cls PrivateKey} to {.path {filename}}")
  invisible(ok)
}

method(fhe_serialize, Ciphertext) <- function(x, filename, format = "binary") {
  ok <- Serialize__Ciphertext(x@ptr, filename, format == "binary")
  if (!ok) cli_abort("Failed to serialize {.cls Ciphertext} to {.path {filename}}")
  invisible(ok)
}

#' Deserialize an OpenFHE object from file
#'
#' @param filename Path to serialized file
#' @param type One of "CryptoContext", "PublicKey", "PrivateKey", "Ciphertext"
#' @param format "binary" (default) or "json"
#' @return The deserialized object
#' @export
fhe_deserialize <- function(filename, type = c("CryptoContext", "PublicKey",
                                                "PrivateKey", "Ciphertext"),
                            format = "binary") {
  type <- match.arg(type)
  binary <- format == "binary"
  switch(type,
    CryptoContext = CryptoContext(ptr = Deserialize__CryptoContext(filename, binary)),
    PublicKey     = PublicKey(ptr = Deserialize__PublicKey(filename, binary)),
    PrivateKey    = PrivateKey(ptr = Deserialize__PrivateKey(filename, binary)),
    Ciphertext    = Ciphertext(ptr = Deserialize__Ciphertext(filename, binary))
  )
}

#' Serialize evaluation keys to file
#'
#' @param filename Path to output file
#' @param type "mult" or "automorphism"
#' @param format "binary" (default) or "json"
#' @param key_tag Key tag (default: "")
#' @return TRUE on success (invisibly)
#' @export
serialize_eval_keys <- function(filename,
                                type = c("mult", "automorphism", "sum"),
                                format = "binary", key_tag = "") {
  ## "sum" added as a third serialization
  ## type. On the C++ side `SerializeEvalSumKey` delegates to
  ## `SerializeEvalAutomorphismKey` (cryptocontext-ser.h line 730),
  ## so the bytes on disk are identical between a `type = "sum"`
  ## and a `type = "automorphism"` write. Both entry points are
  ## exposed so fixture authors can match whichever OpenFHE doc
  ## they are reading. openfhe-python does not bind the sum-key
  ## entry point (Python users reach for the automorphism form
  ## directly); logged in notes/upstream-defects.md R-only
  ## surface section.
  type <- match.arg(type)
  binary <- format == "binary"
  ok <- switch(type,
    mult = Serialize__EvalMultKey(filename, binary, key_tag),
    automorphism = Serialize__EvalAutomorphismKey(filename, binary, key_tag),
    sum = Serialize__EvalSumKey(filename, binary, key_tag)
  )
  if (!ok) cli_abort("Failed to serialize {type} eval keys")
  invisible(ok)
}

#' Deserialize evaluation keys from file
#'
#' @param filename Path to serialized file
#' @param type "mult", "automorphism", or "sum"
#' @param format "binary" (default) or "json"
#' @return TRUE on success (invisibly)
#' @export
deserialize_eval_keys <- function(filename,
                                  type = c("mult", "automorphism", "sum"),
                                  format = "binary") {
  ## "sum" added as a third type per the sum-key
  ## companion at Serialize__EvalSumKey. As on the write side,
  ## `type = "sum"` and `type = "automorphism"` read the same
  ## backing storage on the C++ side — reading a file that was
  ## written with type = "automorphism" via type = "sum" works
  ## (and vice versa).
  type <- match.arg(type)
  binary <- format == "binary"
  ok <- switch(type,
    mult = Deserialize__EvalMultKey(filename, binary),
    automorphism = Deserialize__EvalAutomorphismKey(filename, binary),
    sum = Deserialize__EvalSumKey(filename, binary)
  )
  if (!ok) cli_abort("Failed to deserialize {type} eval keys")
  invisible(ok)
}

#' Clear cached evaluation keys and contexts
#'
#' @param what Character vector: subset of "mult_keys", "automorphism_keys", "contexts"
#' @export
clear_fhe_state <- function(what = c("mult_keys", "automorphism_keys", "contexts")) {
  what <- match.arg(what, several.ok = TRUE)
  if ("mult_keys" %in% what) ClearEvalMultKeys()
  if ("automorphism_keys" %in% what) ClearEvalAutomorphismKeys()
  if ("contexts" %in% what) ReleaseAllContexts()
  invisible(NULL)
}

#' Execute code with automatic cleanup of FHE state
#'
#' Clears eval keys and releases contexts on exit (even on error).
#'
#' @param expr Expression to evaluate
#' @return Result of expr
#' @export
with_fhe_context <- function(expr) {
  on.exit(clear_fhe_state(), add = TRUE)
  force(expr)
}

# ── key-tag-scoped management ──

#' Insert an EvalMult key vector into the cc registry
#'
#' Adds a vector of `EvalKey` objects to the CryptoContext's
#' internal EvalMult-key map under `key_tag`. Silently replaces
#' any existing matching keys. If `key_tag` is the empty string
#' (`""`, the default), the tag is retrieved from the eval-key
#' vector itself (each `EvalKey` carries its own tag).
#'
#' Used in checkpoint/resume workflows: after
#' `fhe_deserialize_eval_keys()` or [multi_add_eval_mult_keys()]
#' produces a combined eval-mult key vector, this function
#' registers it into the cc's internal storage so that
#' subsequent `eval_mult()` calls on ciphertexts encrypted
#' under the associated party's key can consume it.
#'
#' @param eval_keys A list of `EvalKey` objects (from
#'   [multi_key_switch_gen()], [multi_add_eval_mult_keys()], or
#'   from a deserialization).
#' @param key_tag Character; the tag to register the vector
#'   under. Default `""` (auto-detect from the first eval key
#'   in the vector).
#' @return `NULL`, invisibly.
#' @seealso [insert_eval_sum_key()], [insert_eval_automorphism_key()]
#' @export
insert_eval_mult_key <- function(eval_keys, key_tag = "") {
  if (!is.list(eval_keys)) {
    cli::cli_abort("{.arg eval_keys} must be a list of {.cls EvalKey} objects.")
  }
  ek_ptrs <- lapply(eval_keys, get_ptr)
  CryptoContext__InsertEvalMultKey(ek_ptrs, as.character(key_tag))
  invisible(NULL)
}

#' Clear the EvalMult key cache
#'
#' Clears the `CryptoContextImpl` internal EvalMult key map.
#' With `key_tag = NULL` (the default), clears the entire
#' cache — equivalent to the no-arg `ClearEvalMultKeys()` form
#' used by [clear_fhe_state()]. With a non-NULL `key_tag`,
#' clears only the entries registered under that tag,
#' preserving everything else. Useful in checkpoint workflows
#' where a single party's keys need to be evicted without
#' wiping the whole registry.
#'
#' @param key_tag `NULL` (default) to clear everything, or a
#'   character scalar to clear only one tag's entries.
#' @return `NULL`, invisibly.
#' @seealso [clear_fhe_state()], [clear_eval_automorphism_keys()]
#' @export
clear_eval_mult_keys <- function(key_tag = NULL) {
  if (is.null(key_tag)) {
    ClearEvalMultKeys()
  } else {
    CryptoContext__ClearEvalMultKeys__tag(as.character(key_tag))
  }
  invisible(NULL)
}

#' Clear the EvalAutomorphism key cache
#'
#' Companion to [clear_eval_mult_keys()] for the
#' EvalAutomorphism key map (used by rotation and sum
#' operations). `key_tag = NULL` clears everything (same as
#' [clear_fhe_state()]'s `"automorphism_keys"` branch); a
#' character scalar clears only that tag's entries.
#'
#' @param key_tag `NULL` (default) to clear everything, or a
#'   character scalar to clear only one tag's entries.
#' @return `NULL`, invisibly.
#' @seealso [clear_fhe_state()], [clear_eval_mult_keys()]
#' @export
clear_eval_automorphism_keys <- function(key_tag = NULL) {
  if (is.null(key_tag)) {
    ClearEvalAutomorphismKeys()
  } else {
    CryptoContext__ClearEvalAutomorphismKeys__tag(as.character(key_tag))
  }
  invisible(NULL)
}
