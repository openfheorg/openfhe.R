## OPENFHE PYTHON SOURCE: src/lib/binfhe_bindings.cpp (public-key encryption, key and parameter accessors, bootstrapping key management, LWE object accessors, serialization)
##
## R wrappers for src/binfhe_keys.cpp.

# ── Classes ─────────────────────────────────────────────

#' LWE public key (Binary FHE)
#'
#' The public key of the LWE scheme of a BinFHE context, from
#' [bin_key_gen_pair()] or [bin_pub_key_gen()]. [bin_encrypt()]
#' accepts it in place of the secret key.
#'
#' @param ptr External pointer (internal use)
#' @return An S7 object of class `LWEPublicKey`, inheriting from
#'   [OpenFHEObject].
#' @export
LWEPublicKey <- new_class("LWEPublicKey",
  parent = OpenFHEObject,
  package = "openfhe.R"
)

#' LWE switching key (Binary FHE)
#'
#' A key that switches an LWE ciphertext of modulus `Q` and dimension
#' `N` to one of modulus `q` and dimension `n`, from
#' [bin_key_switch_gen()] or [get_switch_key()]. It is an opaque
#' handle, as in openfhe-python.
#'
#' @param ptr External pointer (internal use)
#' @return An S7 object of class `LWESwitchingKey`, inheriting from
#'   [OpenFHEObject].
#' @export
LWESwitchingKey <- new_class("LWESwitchingKey",
  parent = OpenFHEObject,
  package = "openfhe.R"
)

#' Bootstrapping key (Binary FHE)
#'
#' The refreshing key, switching key and public key that
#' [bin_bt_key_gen()] generates, as one object, from [get_bt_key()].
#' It is an opaque handle, as in openfhe-python: write it to a file
#' with [fhe_serialize()] and load it into a context with
#' [bin_bt_key_load()].
#'
#' @param ptr External pointer (internal use)
#' @return An S7 object of class `RingGSWBTKey`, inheriting from
#'   [OpenFHEObject].
#' @export
RingGSWBTKey <- new_class("RingGSWBTKey",
  parent = OpenFHEObject,
  package = "openfhe.R"
)

#' LWE key pair (Binary FHE)
#'
#' The public key and the matching secret key from
#' [bin_key_gen_pair()]. [is_good()] is `TRUE` when both are present.
#'
#' @param public An [LWEPublicKey].
#' @param secret An [LWEPrivateKey].
#' @return An S7 object of class `LWEKeyPair` with properties `public`
#'   and `secret`.
#' @export
LWEKeyPair <- new_class("LWEKeyPair",
  package = "openfhe.R",
  properties = list(
    public = class_any,
    secret = class_any
  )
)

method(is_good, LWEKeyPair) <- function(kp) {
  S7::S7_inherits(kp@public, LWEPublicKey) && ptr_is_valid(kp@public) &&
    S7::S7_inherits(kp@secret, LWEPrivateKey) && ptr_is_valid(kp@secret)
}

method(print, LWEPublicKey) <- function(x, ...) {
  cli::cli_text("{.cls LWEPublicKey} [{if (ptr_is_valid(x)) 'active' else 'null'}]")
  invisible(x)
}

method(print, LWESwitchingKey) <- function(x, ...) {
  cli::cli_text("{.cls LWESwitchingKey} [{if (ptr_is_valid(x)) 'active' else 'null'}]")
  invisible(x)
}

method(print, RingGSWBTKey) <- function(x, ...) {
  cli::cli_text("{.cls RingGSWBTKey} [{if (ptr_is_valid(x)) 'active' else 'null'}]")
  invisible(x)
}

method(print, LWEKeyPair) <- function(x, ...) {
  cli::cli_text("{.cls LWEKeyPair} [{if (is_good(x)) 'good' else 'incomplete'}]")
  invisible(x)
}

# ── Key generation ──────────────────────────────────────

#' Keys of the LWE scheme of a BinFHE context
#'
#' `bin_key_gen_pair()` generates a public key and its secret key.
#' `bin_pub_key_gen()` generates a public key for an existing secret
#' key. `bin_key_gen_n()` generates a secret key of the large
#' dimension `N`, and `bin_key_switch_gen()` the key that switches
#' ciphertexts under it (modulus `Q`, dimension `N`) to ciphertexts
#' under `sk` (modulus `q`, dimension `n`).
#'
#' @param ctx A `BinFHEContext`.
#' @param sk An `LWEPrivateKey` of dimension `n`, from [bin_key_gen()].
#' @param sk_n An `LWEPrivateKey` of dimension `N`, from
#'   `bin_key_gen_n()`.
#' @return `bin_key_gen_pair()`: an [LWEKeyPair].
#'   `bin_pub_key_gen()`: an [LWEPublicKey]. `bin_key_gen_n()`: an
#'   `LWEPrivateKey`. `bin_key_switch_gen()`: an [LWESwitchingKey].
#' @seealso [bin_key_gen()], [bin_encrypt()], [switch_ct_to_qn()]
#' @examples
#' ctx <- bin_fhe_context(BinFHEParamSet$TOY)
#' kp <- bin_key_gen_pair(ctx)
#' ## Under the public key of the pair, in dimension N; no bootstrapping
#' ## keys are needed for this form.
#' ct <- bin_encrypt(ctx, kp@public, 1L, BinFHEOutput$LARGE_DIM)
#' bin_decrypt(ctx, kp@secret, ct)
#' @export
bin_key_gen_pair <- function(ctx) {
  kp <- BinFHEContext__KeyGenPair(get_ptr(ctx))
  ## >>> S7-FAST-NEW (RConsortium/S7#723): original
  ## LWEKeyPair(public = LWEPublicKey(ptr = kp$public),
  ## <<< S7-FAST-NEW
  LWEKeyPair(public = .fast_new(LWEPublicKey, kp$public),
             ## >>> S7-FAST-NEW (RConsortium/S7#723): original
             ## secret = LWEPrivateKey(ptr = kp$secret))
             ## <<< S7-FAST-NEW
             secret = .fast_new(LWEPrivateKey, kp$secret))
}

#' @rdname bin_key_gen_pair
#' @export
bin_pub_key_gen <- function(ctx, sk) {
  ## >>> S7-FAST-NEW (RConsortium/S7#723): original
  ## LWEPublicKey(ptr = BinFHEContext__PubKeyGen(get_ptr(ctx), get_ptr(sk)))
  ## <<< S7-FAST-NEW
  .fast_new(LWEPublicKey, BinFHEContext__PubKeyGen(get_ptr(ctx), get_ptr(sk)))
}

#' @rdname bin_key_gen_pair
#' @export
bin_key_gen_n <- function(ctx) {
  ## >>> S7-FAST-NEW (RConsortium/S7#723): original
  ## LWEPrivateKey(ptr = BinFHEContext__KeyGenN(get_ptr(ctx)))
  ## <<< S7-FAST-NEW
  .fast_new(LWEPrivateKey, BinFHEContext__KeyGenN(get_ptr(ctx)))
}

#' @rdname bin_key_gen_pair
#' @export
bin_key_switch_gen <- function(ctx, sk, sk_n) {
  ## >>> S7-FAST-NEW (RConsortium/S7#723): original
  ## LWESwitchingKey(ptr = BinFHEContext__KeySwitchGen(get_ptr(ctx), get_ptr(sk),
  ##                                                   get_ptr(sk_n)))
  ## <<< S7-FAST-NEW
  .fast_new(LWESwitchingKey, BinFHEContext__KeySwitchGen(get_ptr(ctx), get_ptr(sk),
                                                         get_ptr(sk_n)))
}

#' Switch a public-key ciphertext to the small modulus and dimension
#'
#' A ciphertext encrypted under a public key has modulus `Q` and
#' dimension `N`. `switch_ct_to_qn()` converts it to modulus `q` and
#' dimension `n`, the form the gates take.
#'
#' @param ctx A `BinFHEContext`.
#' @param ksk An [LWESwitchingKey], from [get_switch_key()] or
#'   [bin_key_switch_gen()].
#' @param ct An `LWECiphertext` of modulus `Q` and dimension `N`.
#' @return An `LWECiphertext`.
#' @export
switch_ct_to_qn <- function(ctx, ksk, ct) {
  ## >>> S7-FAST-NEW (RConsortium/S7#723): original
  ## LWECiphertext(ptr = BinFHEContext__SwitchCTtoqn(get_ptr(ctx), get_ptr(ksk),
  ##                                                 get_ptr(ct)))
  ## <<< S7-FAST-NEW
  .fast_new(LWECiphertext, BinFHEContext__SwitchCTtoqn(get_ptr(ctx), get_ptr(ksk),
                                                       get_ptr(ct)))
}

# ── Evaluation ──────────────────────────────────────────

#' Bootstrap an LWE ciphertext
#'
#' Refreshes a ciphertext without applying a gate.
#'
#' @param ctx A `BinFHEContext` with bootstrapping keys.
#' @param ct An `LWECiphertext`.
#' @param extended Logical; if `TRUE` the result is returned before
#'   key switching (modulus `Q`, dimension `N`). Default `FALSE`.
#' @return An `LWECiphertext`.
#' @seealso [eval_bin_gate()]
#' @export
bin_bootstrap <- function(ctx, ct, extended = FALSE) {
  ## >>> S7-FAST-NEW (RConsortium/S7#723): original
  ## LWECiphertext(ptr = BinFHEContext__Bootstrap(get_ptr(ctx), get_ptr(ct),
  ##                                              isTRUE(extended)))
  ## <<< S7-FAST-NEW
  .fast_new(LWECiphertext, BinFHEContext__Bootstrap(get_ptr(ctx), get_ptr(ct),
                                                    isTRUE(extended)))
}

#' A constant as an LWE ciphertext
#'
#' Returns a ciphertext of the Boolean `value` that needs no key: a
#' trivial encryption, for use as a constant input of a gate.
#'
#' @param ctx A `BinFHEContext`.
#' @param value Logical.
#' @return An `LWECiphertext`.
#' @export
eval_constant <- function(ctx, value) {
  ## >>> S7-FAST-NEW (RConsortium/S7#723): original
  ## LWECiphertext(ptr = BinFHEContext__EvalConstant(get_ptr(ctx), isTRUE(value)))
  ## <<< S7-FAST-NEW
  .fast_new(LWECiphertext, BinFHEContext__EvalConstant(get_ptr(ctx), isTRUE(value)))
}

#' Decompose a large-precision ciphertext into digits
#'
#' Splits a ciphertext of large modulus into ciphertexts of its
#' digits, each of the small modulus of the context (a context built
#' with `arb_func = TRUE`).
#'
#' @param ctx A `BinFHEContext`.
#' @param ct An `LWECiphertext`.
#' @return A list of `LWECiphertext` objects, least significant digit
#'   first.
#' @seealso [eval_sign()], [eval_floor()]
#' @export
eval_decomp <- function(ctx, ct) {
  lapply(BinFHEContext__EvalDecomp(get_ptr(ctx), get_ptr(ct)),
         ## >>> S7-FAST-NEW (RConsortium/S7#723): original
         ## function(p) LWECiphertext(ptr = p))
         ## <<< S7-FAST-NEW
         function(p) .fast_new(LWECiphertext, p))
}

# ── Bootstrapping keys ──────────────────────────────────

#' The bootstrapping keys of a BinFHE context
#'
#' `get_bt_key()` returns the keys [bin_bt_key_gen()] generated, as one
#' [RingGSWBTKey]; `bin_bt_key_load()` puts such an object into a
#' context, and `bin_clear_bt_keys()` removes the keys of a context.
#' Together with [fhe_serialize()] and [fhe_deserialize()] they move
#' bootstrapping keys between sessions.
#'
#' A context for large-precision evaluation keeps one key per gadget
#' base. `get_bt_key_map()` returns them, and
#' `bin_bt_key_map_load_single_element()` loads one.
#'
#' `get_switch_key()` returns the switching key among the
#' bootstrapping keys, and [get_public_key()] the public key.
#'
#' `has_internal32_refresh_key()` and `has_internal32_switch_key()`
#' say whether the refreshing and the switching key are held in the
#' library's 32-bit internal form.
#'
#' @param ctx A `BinFHEContext`.
#' @param key A [RingGSWBTKey].
#' @param internal32 Logical; if `TRUE` (default) keys whose moduli fit
#'   are converted to the 32-bit internal form on loading.
#' @param base_g Integer; the gadget base the key is for.
#' @return `get_bt_key()`: a [RingGSWBTKey]. `get_bt_key_map()`: a
#'   list of them, named by gadget base. `get_switch_key()`: an
#'   [LWESwitchingKey], or `NULL` if the context holds none in the
#'   64-bit form. The `has_` functions: a logical. The others: `ctx`,
#'   invisibly.
#' @export
get_bt_key <- function(ctx) {
  ## >>> S7-FAST-NEW (RConsortium/S7#723): original
  ## RingGSWBTKey(ptr = BinFHEContext__GetBTKey(get_ptr(ctx)))
  ## <<< S7-FAST-NEW
  .fast_new(RingGSWBTKey, BinFHEContext__GetBTKey(get_ptr(ctx)))
}

#' @rdname get_bt_key
#' @export
get_bt_key_map <- function(ctx) {
  lapply(BinFHEContext__GetBTKeyMap(get_ptr(ctx)),
         ## >>> S7-FAST-NEW (RConsortium/S7#723): original
         ## function(p) RingGSWBTKey(ptr = p))
         ## <<< S7-FAST-NEW
         function(p) .fast_new(RingGSWBTKey, p))
}

#' @rdname get_bt_key
#' @export
bin_bt_key_load <- function(ctx, key, internal32 = TRUE) {
  BinFHEContext__BTKeyLoad(get_ptr(ctx), get_ptr(key), isTRUE(internal32))
  invisible(ctx)
}

#' @rdname get_bt_key
#' @export
bin_bt_key_map_load_single_element <- function(ctx, base_g, key) {
  BinFHEContext__BTKeyMapLoadSingleElement(get_ptr(ctx), as.integer(base_g),
                                           get_ptr(key))
  invisible(ctx)
}

#' @rdname get_bt_key
#' @export
bin_clear_bt_keys <- function(ctx) {
  BinFHEContext__ClearBTKeys(get_ptr(ctx))
  invisible(ctx)
}

#' @rdname get_bt_key
#' @export
get_switch_key <- function(ctx) {
  p <- BinFHEContext__GetSwitchKey(get_ptr(ctx))
  ## >>> S7-FAST-NEW (RConsortium/S7#723): original
  ## if (is.null(p)) NULL else LWESwitchingKey(ptr = p)
  ## <<< S7-FAST-NEW
  if (is.null(p)) NULL else .fast_new(LWESwitchingKey, p)
}

#' The public key an object holds
#'
#' For a `BinFHEContext`, the LWE public key among its bootstrapping
#' keys, present after [bin_bt_key_gen()] with
#' `KeygenMode$PUB_ENCRYPT`. For a `SchemeSwitchingDataDeserializer`,
#' the CKKS public key it has read.
#'
#' @param x A `BinFHEContext` or a
#'   [SchemeSwitchingDataDeserializer].
#' @param ... Not used.
#' @return An [LWEPublicKey] or a `PublicKey`, or `NULL` if the object
#'   holds none.
#' @seealso [get_bt_key()]
#' @export
get_public_key <- new_generic("get_public_key", "x")

method(get_public_key, BinFHEContext) <- function(x) {
  p <- BinFHEContext__GetPublicKey(get_ptr(x))
  ## >>> S7-FAST-NEW (RConsortium/S7#723): original
  ## if (is.null(p)) NULL else LWEPublicKey(ptr = p)
  ## <<< S7-FAST-NEW
  if (is.null(p)) NULL else .fast_new(LWEPublicKey, p)
}

#' @rdname get_bt_key
#' @export
has_internal32_refresh_key <- function(ctx) {
  BinFHEContext__HasInternal32Key(get_ptr(ctx), TRUE)
}

#' @rdname get_bt_key
#' @export
has_internal32_switch_key <- function(ctx) {
  BinFHEContext__HasInternal32Key(get_ptr(ctx), FALSE)
}

# ── Parameters ──────────────────────────────────────────

#' Parameters of a BinFHE context
#'
#' The LWE parameters of a context. OpenFHE names them by letter case,
#' which R function names do not carry: `get_n()` is the lattice
#' dimension `n` and `get_big_n()` the ring dimension `N`; `get_q()` is
#' the small ciphertext modulus `q` and `get_big_q()` the large modulus
#' `Q` (the C++ `Getn()`, `GetN()`, `Getq()` and `GetQ()`).
#' `get_beta()` is the bound `beta` in the plaintext space
#' `q / (2 * beta)`.
#'
#' @param ctx A `BinFHEContext`.
#' @return `get_n()` and `get_big_n()`: an integer. The others: a
#'   number, or a string of decimal digits if the value is above 2^53.
#' @seealso [get_max_plaintext_space()]
#' @examples
#' ctx <- bin_fhe_context(BinFHEParamSet$TOY)
#' c(n = get_n(ctx), N = get_big_n(ctx), q = get_q(ctx), Q = get_big_q(ctx))
#' @export
get_n <- function(ctx) BinFHEContext__GetParam(get_ptr(ctx), 0L)

#' @rdname get_n
#' @export
get_big_n <- function(ctx) BinFHEContext__GetParam(get_ptr(ctx), 1L)

#' @rdname get_n
#' @export
get_q <- function(ctx) BinFHEContext__GetParam(get_ptr(ctx), 2L)

#' @rdname get_n
#' @export
get_big_q <- function(ctx) BinFHEContext__GetParam(get_ptr(ctx), 3L)

#' @rdname get_n
#' @export
get_beta <- function(ctx) BinFHEContext__GetParam(get_ptr(ctx), 4L)

method(serialized_object_name, BinFHEContext) <- function(x)
  BinFHEContext__SerializedObjectName(get_ptr(x))
method(serialized_version, BinFHEContext) <- function(x) {
  get_ptr(x)
  BinFHEContext__SerializedVersion()
}

# ── LWE objects ─────────────────────────────────────────

.LWE_KIND <- c(LWECiphertext = 0L, LWEPrivateKey = 1L, LWEPublicKey = 2L)

method(get_length, LWEPrivateKey) <- function(x)
  LWE__GetLength(get_ptr(x), .LWE_KIND[["LWEPrivateKey"]])
method(get_length, LWEPublicKey) <- function(x)
  LWE__GetLength(get_ptr(x), .LWE_KIND[["LWEPublicKey"]])

method(get_modulus, LWECiphertext) <- function(x)
  LWE__GetModulus(get_ptr(x), .LWE_KIND[["LWECiphertext"]])
method(get_modulus, LWEPrivateKey) <- function(x)
  LWE__GetModulus(get_ptr(x), .LWE_KIND[["LWEPrivateKey"]])
method(get_modulus, LWEPublicKey) <- function(x)
  LWE__GetModulus(get_ptr(x), .LWE_KIND[["LWEPublicKey"]])

## Equality of the C++ objects (operator== of the Impl classes): the
## same contents, whether or not the two handles are the same object.
method(`==`, list(LWECiphertext, LWECiphertext)) <- function(e1, e2)
  LWE__equal(get_ptr(e1), get_ptr(e2), .LWE_KIND[["LWECiphertext"]])
method(`!=`, list(LWECiphertext, LWECiphertext)) <- function(e1, e2)
  !LWE__equal(get_ptr(e1), get_ptr(e2), .LWE_KIND[["LWECiphertext"]])
method(`==`, list(LWEPrivateKey, LWEPrivateKey)) <- function(e1, e2)
  LWE__equal(get_ptr(e1), get_ptr(e2), .LWE_KIND[["LWEPrivateKey"]])
method(`!=`, list(LWEPrivateKey, LWEPrivateKey)) <- function(e1, e2)
  !LWE__equal(get_ptr(e1), get_ptr(e2), .LWE_KIND[["LWEPrivateKey"]])
method(`==`, list(LWEPublicKey, LWEPublicKey)) <- function(e1, e2)
  LWE__equal(get_ptr(e1), get_ptr(e2), .LWE_KIND[["LWEPublicKey"]])
method(`!=`, list(LWEPublicKey, LWEPublicKey)) <- function(e1, e2)
  !LWE__equal(get_ptr(e1), get_ptr(e2), .LWE_KIND[["LWEPublicKey"]])

#' Moduli of an LWE ciphertext
#'
#' [get_modulus()] of an `LWECiphertext` is its ciphertext modulus, and
#' `get_pt_modulus()` its plaintext modulus. `set_modulus()` and
#' `set_pt_modulus()` change the values recorded in the ciphertext, in
#' place; they do not rescale it.
#'
#' [get_modulus()] and [get_length()] also work on an `LWEPrivateKey`
#' and an `LWEPublicKey`, and `==` and `!=` compare two LWE
#' ciphertexts, two secret keys or two public keys by content.
#'
#' @param ct An `LWECiphertext`.
#' @param modulus,plaintext_modulus The new value: a whole number of
#'   at most 2^53, or a string of decimal digits.
#' @return `get_pt_modulus()`: a number, or a string of decimal digits
#'   if the value is above 2^53. The setters: `ct`, invisibly.
#' @export
get_pt_modulus <- function(ct) {
  LWECiphertext__GetptModulus(get_ptr(ct))
}

#' @rdname get_pt_modulus
#' @export
set_modulus <- function(ct, modulus) {
  LWECiphertext__SetModulus(get_ptr(ct), wide_integer(modulus))
  invisible(ct)
}

#' @rdname get_pt_modulus
#' @export
set_pt_modulus <- function(ct, plaintext_modulus) {
  LWECiphertext__SetptModulus(get_ptr(ct), wide_integer(plaintext_modulus))
  invisible(ct)
}

# ── Files ───────────────────────────────────────────────

.BINFHE_SER_KIND <- c(BinFHEContext = 0L, LWECiphertext = 1L, LWEPrivateKey = 2L,
                      LWEPublicKey = 3L, RingGSWBTKey = 4L)

## Shared body of the fhe_serialize() methods of the BinFHE classes,
## which openfhe-python serializes to files only.
.binfhe_serialize <- function(x, type, filename, format) {
  if (is.null(filename)) {
    cli_abort("A {.cls {type}} is serialized to a file; give {.arg filename}.",
              call = NULL)
  }
  ok <- BinFHE__SerializeToFile(get_ptr(x), .BINFHE_SER_KIND[[type]], filename,
                                format == "binary")
  if (!ok) cli_abort("Failed to serialize {.cls {type}} to {.path {filename}}",
                     call = NULL)
  invisible(ok)
}

method(fhe_serialize, BinFHEContext) <- function(x, filename = NULL, format = "binary")
  .binfhe_serialize(x, "BinFHEContext", filename, format)
method(fhe_serialize, LWECiphertext) <- function(x, filename = NULL, format = "binary")
  .binfhe_serialize(x, "LWECiphertext", filename, format)
method(fhe_serialize, LWEPrivateKey) <- function(x, filename = NULL, format = "binary")
  .binfhe_serialize(x, "LWEPrivateKey", filename, format)
method(fhe_serialize, LWEPublicKey) <- function(x, filename = NULL, format = "binary")
  .binfhe_serialize(x, "LWEPublicKey", filename, format)
method(fhe_serialize, RingGSWBTKey) <- function(x, filename = NULL, format = "binary")
  .binfhe_serialize(x, "RingGSWBTKey", filename, format)

.binfhe_deserialize <- function(filename, type, binary) {
  p <- BinFHE__DeserializeFromFile(filename, .BINFHE_SER_KIND[[type]], binary)
  switch(type,
    ## >>> S7-FAST-NEW (RConsortium/S7#723): original
    ## BinFHEContext = BinFHEContext(ptr = p),
    ## <<< S7-FAST-NEW
    BinFHEContext = .fast_new(BinFHEContext, p),
    ## >>> S7-FAST-NEW (RConsortium/S7#723): original
    ## LWECiphertext = LWECiphertext(ptr = p),
    ## <<< S7-FAST-NEW
    LWECiphertext = .fast_new(LWECiphertext, p),
    ## >>> S7-FAST-NEW (RConsortium/S7#723): original
    ## LWEPrivateKey = LWEPrivateKey(ptr = p),
    ## <<< S7-FAST-NEW
    LWEPrivateKey = .fast_new(LWEPrivateKey, p),
    ## >>> S7-FAST-NEW (RConsortium/S7#723): original
    ## LWEPublicKey  = LWEPublicKey(ptr = p),
    ## <<< S7-FAST-NEW
    LWEPublicKey  = .fast_new(LWEPublicKey, p),
    ## >>> S7-FAST-NEW (RConsortium/S7#723): original
    ## RingGSWBTKey  = RingGSWBTKey(ptr = p)
    ## <<< S7-FAST-NEW
    RingGSWBTKey  = .fast_new(RingGSWBTKey, p)
  )
}
