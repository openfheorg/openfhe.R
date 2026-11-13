## OPENFHE PYTHON SOURCE: src/lib/pke/serialization.cpp

## Object kinds and key registries, as numbered in
## src/pke_serialization_memory.cpp.
.SER_KIND <- c(CryptoContext = 0L, PublicKey = 1L, PrivateKey = 2L,
               Ciphertext = 3L, EvalKey = 4L, EvalKeyMap = 5L,
               EvalKeyVector = 6L)
.SER_REGISTRY <- c(mult = 0L, automorphism = 1L, sum = 2L)

## The format of serialized data held in memory: a raw vector is
## binary, a character string JSON. `format`, when given, must agree.
ser_data_is_binary <- function(data, format, call = rlang::caller_env()) {
  if (is.raw(data)) {
    binary <- TRUE
  } else if (is.character(data) && length(data) == 1L && !is.na(data)) {
    binary <- FALSE
  } else {
    cli_abort("{.arg data} must be a raw vector or a single string.", call = call)
  }
  if (!is.null(format) && (format == "binary") != binary) {
    cli_abort(c("{.arg data} and {.arg format} disagree.",
                i = "A raw vector is binary data; a string is JSON."),
              call = call)
  }
  binary
}

#' Serialize an OpenFHE object
#'
#' Writes an object to a file, or, with `filename = NULL`, returns its
#' serialized form: a raw vector for the binary format and a character
#' string for JSON.
#'
#' @param x A `CryptoContext`, `PublicKey`, `PrivateKey`, `Ciphertext`,
#'   `EvalKey` or `EvalKeyMap`, or a list of `EvalKey` objects (in
#'   memory only). For Binary FHE, a `BinFHEContext`, `LWECiphertext`,
#'   `LWEPrivateKey`, `LWEPublicKey` or `RingGSWBTKey` (to a file
#'   only).
#' @param ... Method arguments: `filename`, a path, or `NULL` (default)
#'   to serialize in memory; `format`, `"binary"` (default) or
#'   `"json"`.
#' @return With a file name, `TRUE` invisibly. Otherwise a raw vector
#'   (`format = "binary"`) or a character string (`format = "json"`).
#' @seealso [fhe_deserialize()], [fhe_deserialize_string()]
#' @examples
#' cc <- fhe_context("BFV", plaintext_modulus = 65537, multiplicative_depth = 1)
#' keys <- key_gen(cc)
#' bytes <- fhe_serialize(keys@public)
#' pk <- fhe_deserialize_string(bytes, "PublicKey")
#' @export
fhe_serialize <- new_generic("fhe_serialize", "x")

method(fhe_serialize, CryptoContext) <- function(x, filename = NULL, format = "binary") {
  if (is.null(filename)) {
    return(SerializeMem__(x@ptr, .SER_KIND[["CryptoContext"]], format == "binary"))
  }
  ok <- Serialize__CryptoContext(x@ptr, filename, format == "binary")
  if (!ok) cli_abort("Failed to serialize {.cls CryptoContext} to {.path {filename}}")
  invisible(ok)
}

method(fhe_serialize, PublicKey) <- function(x, filename = NULL, format = "binary") {
  if (is.null(filename)) {
    return(SerializeMem__(x@ptr, .SER_KIND[["PublicKey"]], format == "binary"))
  }
  ok <- Serialize__PublicKey(x@ptr, filename, format == "binary")
  if (!ok) cli_abort("Failed to serialize {.cls PublicKey} to {.path {filename}}")
  invisible(ok)
}

method(fhe_serialize, PrivateKey) <- function(x, filename = NULL, format = "binary") {
  if (is.null(filename)) {
    return(SerializeMem__(x@ptr, .SER_KIND[["PrivateKey"]], format == "binary"))
  }
  ok <- Serialize__PrivateKey(x@ptr, filename, format == "binary")
  if (!ok) cli_abort("Failed to serialize {.cls PrivateKey} to {.path {filename}}")
  invisible(ok)
}

method(fhe_serialize, Ciphertext) <- function(x, filename = NULL, format = "binary") {
  if (is.null(filename)) {
    return(SerializeMem__(x@ptr, .SER_KIND[["Ciphertext"]], format == "binary"))
  }
  ok <- Serialize__Ciphertext(x@ptr, filename, format == "binary")
  if (!ok) cli_abort("Failed to serialize {.cls Ciphertext} to {.path {filename}}")
  invisible(ok)
}

method(fhe_serialize, EvalKey) <- function(x, filename = NULL, format = "binary") {
  if (is.null(filename)) {
    return(SerializeMem__(x@ptr, .SER_KIND[["EvalKey"]], format == "binary"))
  }
  ok <- SerializeFile__(x@ptr, .SER_KIND[["EvalKey"]], filename, format == "binary")
  if (!ok) cli_abort("Failed to serialize {.cls EvalKey} to {.path {filename}}")
  invisible(ok)
}

method(fhe_serialize, EvalKeyMap) <- function(x, filename = NULL, format = "binary") {
  if (is.null(filename)) {
    return(SerializeMem__(x@ptr, .SER_KIND[["EvalKeyMap"]], format == "binary"))
  }
  ok <- SerializeFile__(x@ptr, .SER_KIND[["EvalKeyMap"]], filename, format == "binary")
  if (!ok) cli_abort("Failed to serialize {.cls EvalKeyMap} to {.path {filename}}")
  invisible(ok)
}

method(fhe_serialize, class_list) <- function(x, filename = NULL, format = "binary") {
  if (!all(vapply(x, function(k) S7::S7_inherits(k, EvalKey), logical(1)))) {
    cli_abort("A list given to {.fn fhe_serialize} must hold {.cls EvalKey} objects.")
  }
  if (!is.null(filename)) {
    cli_abort("A list of {.cls EvalKey} objects is serialized in memory only.")
  }
  SerializeMem__EvalKeyVector(lapply(x, get_ptr), format == "binary")
}

#' Deserialize an OpenFHE object from file
#'
#' @param filename Path to serialized file
#' @param type One of `"CryptoContext"`, `"PublicKey"`, `"PrivateKey"`,
#'   `"Ciphertext"`, `"EvalKey"`, `"EvalKeyMap"`, or, for Binary FHE,
#'   `"BinFHEContext"`, `"LWECiphertext"`, `"LWEPrivateKey"`,
#'   `"LWEPublicKey"`, `"RingGSWBTKey"`.
#' @param format "binary" (default) or "json"
#' @return The deserialized object
#' @seealso [fhe_deserialize_string()] for data held in memory.
#' @export
fhe_deserialize <- function(filename, type = c("CryptoContext", "PublicKey",
                                                "PrivateKey", "Ciphertext",
                                                "EvalKey", "EvalKeyMap",
                                                "BinFHEContext", "LWECiphertext",
                                                "LWEPrivateKey", "LWEPublicKey",
                                                "RingGSWBTKey"),
                            format = "binary") {
  type <- match.arg(type)
  binary <- format == "binary"
  if (type %in% names(.BINFHE_SER_KIND)) {
    return(.binfhe_deserialize(filename, type, binary))
  }
  switch(type,
    ## >>> S7-FAST-NEW (RConsortium/S7#723): original
    ## CryptoContext = CryptoContext(ptr = Deserialize__CryptoContext(filename, binary)),
    ## <<< S7-FAST-NEW
    CryptoContext = .fast_new(CryptoContext, Deserialize__CryptoContext(filename, binary)),
    ## >>> S7-FAST-NEW (RConsortium/S7#723): original
    ## PublicKey     = PublicKey(ptr = Deserialize__PublicKey(filename, binary)),
    ## <<< S7-FAST-NEW
    PublicKey     = .fast_new(PublicKey, Deserialize__PublicKey(filename, binary)),
    ## >>> S7-FAST-NEW (RConsortium/S7#723): original
    ## PrivateKey    = PrivateKey(ptr = Deserialize__PrivateKey(filename, binary)),
    ## <<< S7-FAST-NEW
    PrivateKey    = .fast_new(PrivateKey, Deserialize__PrivateKey(filename, binary)),
    ## >>> S7-FAST-NEW (RConsortium/S7#723): original
    ## Ciphertext    = Ciphertext(ptr = Deserialize__Ciphertext(filename, binary)),
    ## <<< S7-FAST-NEW
    Ciphertext    = .fast_new(Ciphertext, Deserialize__Ciphertext(filename, binary)),
    ## >>> S7-FAST-NEW (RConsortium/S7#723): original
    ## EvalKey       = EvalKey(ptr = DeserializeFile__(filename, .SER_KIND[["EvalKey"]], binary)),
    ## <<< S7-FAST-NEW
    EvalKey       = .fast_new(EvalKey, DeserializeFile__(filename, .SER_KIND[["EvalKey"]], binary)),
    ## >>> S7-FAST-NEW (RConsortium/S7#723): original
    ## EvalKeyMap    = EvalKeyMap(ptr = DeserializeFile__(filename, .SER_KIND[["EvalKeyMap"]], binary))
    ## <<< S7-FAST-NEW
    EvalKeyMap    = .fast_new(EvalKeyMap, DeserializeFile__(filename, .SER_KIND[["EvalKeyMap"]], binary))
  )
}

#' Deserialize an OpenFHE object held in memory
#'
#' The inverse of [fhe_serialize()] with `filename = NULL`.
#'
#' @param data A raw vector (binary format) or a character string
#'   (JSON), as [fhe_serialize()] returns.
#' @param type One of `"CryptoContext"`, `"PublicKey"`, `"PrivateKey"`,
#'   `"Ciphertext"`, `"EvalKey"`, `"EvalKeyMap"`, or `"EvalKeyVector"`
#'   for a serialized list of `EvalKey` objects.
#' @param format `NULL` (default) to take the format from `data`, or
#'   `"binary"` or `"json"`, which must then agree with `data`.
#' @return The deserialized object; for `"EvalKeyVector"` a list of
#'   `EvalKey` objects.
#' @export
fhe_deserialize_string <- function(data,
                                   type = c("CryptoContext", "PublicKey",
                                            "PrivateKey", "Ciphertext",
                                            "EvalKey", "EvalKeyMap",
                                            "EvalKeyVector"),
                                   format = NULL) {
  type <- match.arg(type)
  binary <- ser_data_is_binary(data, format)
  res <- DeserializeMem__(data, .SER_KIND[[type]], binary)
  switch(type,
    ## >>> S7-FAST-NEW (RConsortium/S7#723): original
    ## CryptoContext = CryptoContext(ptr = res),
    ## <<< S7-FAST-NEW
    CryptoContext = .fast_new(CryptoContext, res),
    ## >>> S7-FAST-NEW (RConsortium/S7#723): original
    ## PublicKey     = PublicKey(ptr = res),
    ## <<< S7-FAST-NEW
    PublicKey     = .fast_new(PublicKey, res),
    ## >>> S7-FAST-NEW (RConsortium/S7#723): original
    ## PrivateKey    = PrivateKey(ptr = res),
    ## <<< S7-FAST-NEW
    PrivateKey    = .fast_new(PrivateKey, res),
    ## >>> S7-FAST-NEW (RConsortium/S7#723): original
    ## Ciphertext    = Ciphertext(ptr = res),
    ## <<< S7-FAST-NEW
    Ciphertext    = .fast_new(Ciphertext, res),
    ## >>> S7-FAST-NEW (RConsortium/S7#723): original
    ## EvalKey       = EvalKey(ptr = res),
    ## <<< S7-FAST-NEW
    EvalKey       = .fast_new(EvalKey, res),
    ## >>> S7-FAST-NEW (RConsortium/S7#723): original
    ## EvalKeyMap    = EvalKeyMap(ptr = res),
    ## <<< S7-FAST-NEW
    EvalKeyMap    = .fast_new(EvalKeyMap, res),
    ## >>> S7-FAST-NEW (RConsortium/S7#723): original
    ## EvalKeyVector = lapply(res, function(p) EvalKey(ptr = p))
    ## <<< S7-FAST-NEW
    EvalKeyVector = lapply(res, function(p) .fast_new(EvalKey, p))
  )
}

#' Serialize evaluation keys from the key registry
#'
#' Writes the registered multiplication, automorphism or summation
#' keys to a file, or, with `filename = NULL`, returns them serialized
#' in memory. The keys are those under `key_tag`, or, when `cc` is
#' given, those of that context.
#'
#' @param filename Path to the output file, or `NULL` (default) to
#'   serialize in memory.
#' @param type `"mult"`, `"automorphism"` or `"sum"`.
#' @param format "binary" (default) or "json"
#' @param key_tag Key tag; `""` (default) for the keys of every tag.
#' @param cc A `CryptoContext`, or `NULL` (default). When given,
#'   `key_tag` is not used.
#' @return With a file name, `TRUE` invisibly. Otherwise a raw vector
#'   (`format = "binary"`) or a character string (`format = "json"`).
#' @seealso [deserialize_eval_keys()], [deserialize_eval_keys_string()]
#' @export
serialize_eval_keys <- function(filename = NULL,
                                type = c("mult", "automorphism", "sum"),
                                format = "binary", key_tag = "", cc = NULL) {
  ## On the C++ side `SerializeEvalSumKey` delegates to
  ## `SerializeEvalAutomorphismKey`, so `type = "sum"` and
  ## `type = "automorphism"` produce the same bytes. Both entry points
  ## are exposed so callers can match whichever OpenFHE doc they are
  ## reading.
  type <- match.arg(type)
  binary <- format == "binary"
  if (is.null(filename) || !is.null(cc)) {
    res <- SerializeEvalKeys__(.SER_REGISTRY[[type]], filename, binary,
                               as.character(key_tag),
                               if (is.null(cc)) NULL else get_ptr(cc))
    if (is.null(filename)) return(res)
    ok <- res
  } else {
    ok <- switch(type,
      mult = Serialize__EvalMultKey(filename, binary, key_tag),
      automorphism = Serialize__EvalAutomorphismKey(filename, binary, key_tag),
      sum = Serialize__EvalSumKey(filename, binary, key_tag)
    )
  }
  if (!ok) cli_abort("Failed to serialize {type} eval keys")
  invisible(ok)
}

#' Deserialize evaluation keys held in memory
#'
#' Registers the keys in `data`, as [serialize_eval_keys()] with
#' `filename = NULL` returns them.
#'
#' @param data A raw vector (binary format) or a character string
#'   (JSON).
#' @param type `"mult"`, `"automorphism"` or `"sum"`.
#' @param format `NULL` (default) to take the format from `data`, or
#'   `"binary"` or `"json"`, which must then agree with `data`.
#' @return `TRUE`, invisibly.
#' @export
deserialize_eval_keys_string <- function(data,
                                         type = c("mult", "automorphism", "sum"),
                                         format = NULL) {
  type <- match.arg(type)
  binary <- ser_data_is_binary(data, format)
  ok <- DeserializeEvalKeysMem__(data, .SER_REGISTRY[[type]], binary)
  if (!ok) cli_abort("Failed to deserialize {type} eval keys")
  invisible(ok)
}

#' Serialize the keys CKKS bootstrapping uses
#'
#' `serialize_eval_bootstrap_key()` writes to a file the automorphism
#' keys that bootstrapping with `slots` slots uses, out of those
#' registered for `cc` under `key_tag`.
#' `deserialize_eval_bootstrap_key()` reads such a file into the
#' registry: with `cc` and `slots`, the keys that bootstrapping setup
#' asks for; without `cc`, the keys with the automorphism indices in
#' `index_list`.
#'
#' @param filename Path to the file.
#' @param cc A `CryptoContext` on which [eval_bootstrap_setup()] has
#'   been called. For `deserialize_eval_bootstrap_key()`, `NULL` to
#'   select keys by `index_list`.
#' @param key_tag Character string; the key tag.
#' @param slots Integer; the number of slots.
#' @param index_list Integer vector of automorphism indices; used when
#'   `cc` is `NULL`.
#' @param format "binary" (default) or "json"
#' @return `TRUE` on success, `FALSE` otherwise.
#' @export
serialize_eval_bootstrap_key <- function(filename, cc, key_tag, slots,
                                         format = "binary") {
  SerializeEvalBootstrapKey__(filename, format == "binary", get_ptr(cc),
                              as.character(key_tag), as.integer(slots))
}

#' @rdname serialize_eval_bootstrap_key
#' @export
deserialize_eval_bootstrap_key <- function(filename, cc = NULL, key_tag,
                                           slots = NULL, index_list = NULL,
                                           format = "binary") {
  if (is.null(cc)) {
    if (is.null(index_list)) {
      cli_abort("Give {.arg cc} and {.arg slots}, or {.arg index_list}.")
    }
    return(DeserializeEvalBootstrapKey__(filename, format == "binary", NULL,
                                         as.character(key_tag), 0L,
                                         as.integer(index_list)))
  }
  if (is.null(slots)) {
    cli_abort("{.arg slots} is required with {.arg cc}.")
  }
  DeserializeEvalBootstrapKey__(filename, format == "binary", get_ptr(cc),
                                as.character(key_tag), as.integer(slots),
                                integer())
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
#' @return No return value, called for side effects. Depending on `what`, it
#'   drops the process-wide caches of relinearization keys and of
#'   automorphism (rotation) keys, and releases the registry of crypto
#'   contexts, freeing the memory they hold.
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
