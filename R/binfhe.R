## OPENFHE PYTHON SOURCE: src/lib/binfhe_bindings.cpp

#' BinFHE context (Binary FHE)
#' @param ptr External pointer (internal use)
#' @return An S7 object of class `BinFHEContext`, inheriting from
#'   [OpenFHEObject], whose `ptr` property holds an external pointer to
#'   the C++ boolean-circuit context. It is the BinFHE counterpart of
#'   [CryptoContext] and is deliberately a different class, so a
#'   [CryptoContext] cannot be passed where a BinFHE context belongs or
#'   the other way round. Obtain one from [bin_fhe_context()] rather
#'   than by calling this constructor directly.
#' @export
BinFHEContext <- new_class("BinFHEContext",
  parent = OpenFHEObject,
  package = "openfhe.R"
)

#' LWE Ciphertext (Binary FHE)
#' @param ptr External pointer (internal use)
#' @return An S7 object of class `LWECiphertext`, inheriting from
#'   [OpenFHEObject], whose `ptr` property holds an external pointer to
#'   the C++ LWE ciphertext. This is the encrypted-bit type the boolean-
#'   circuit (BinFHE) schemes operate on; obtain one from [bin_encrypt()]
#'   or from a gate evaluation rather than by calling this constructor
#'   directly.
#' @export
LWECiphertext <- new_class("LWECiphertext",
  parent = OpenFHEObject,
  package = "openfhe.R"
)

## get_length generic: R/plaintext-accessors.R (dispatch on `x`). For an
## LWE ciphertext it is the dimension of the ciphertext vector.
method(get_length, LWECiphertext) <- function(x) LWECiphertext__GetLength(get_ptr(x))

#' LWE Private Key (Binary FHE)
#' @param ptr External pointer (internal use)
#' @return An S7 object of class `LWEPrivateKey`, inheriting from
#'   [OpenFHEObject], whose `ptr` property holds an external pointer to
#'   the C++ LWE secret key. It both encrypts and decrypts in the
#'   boolean-circuit (BinFHE) schemes; obtain one from [bin_key_gen()]
#'   rather than by calling this constructor directly.
#' @export
LWEPrivateKey <- new_class("LWEPrivateKey",
  parent = OpenFHEObject,
  package = "openfhe.R"
)

## The BinFHEParamSet / BinFHEMethod /
## BinGate enum list definitions that used to live in this file
## were stale duplicates of the authoritative lists in
## `R/enums.R` — the Collate order loaded enums.R first and then
## overwrote the full 44-value BinFHEParamSet / 4-value
## BinFHEMethod / 14-value BinGate with truncated 13 / 3 / 13
## value copies. This was fixed here by deleting the
## duplicates. The authoritative lists live in
## `R/enums.R` and are re-exported through the package
## namespace without needing a binfhe.R-specific declaration.

#' Create a Binary FHE context
#'
#' @param paramset A BinFHEParamSet value (default: STD128)
#' @param method A BinFHEMethod value (default: GINX)
#' @param arb_func If TRUE, build a context that supports
#'   arbitrary-function bootstrapping (EvalSign, EvalFunc). Supplying
#'   any of `arb_func`, `log_q`, `n`, or `time_optimization`, even at
#'   its default value, selects the C++ overload that derives the
#'   parameters from them instead of reading the table for `paramset`;
#'   the two give different contexts for the same `paramset`.
#' @param log_q log2 of the large ciphertext modulus Q used by
#'   functional bootstrapping (default 11; use 17 for the eval-sign
#'   example).
#' @param n Ring dimension override (0 lets OpenFHE pick).
#' @param time_optimization Enable the GINX time-optimization variant.
#' @return A [BinFHEContext] object.
#' @section Memory:
#' The bootstrapping keys that [bin_bt_key_gen()] stores in a context
#' can occupy several gigabytes (about 5.8 GB for `STD128` with
#' `arb_func = TRUE` and `log_q = 12`). R's garbage collector does not
#' see this memory, so removing a context with `rm()` does not release
#' it until a collection happens to run.
#'
#' * Build one context and reuse it. The keys depend only on the
#'   parameters and the secret key.
#' * When a context is no longer needed, call [bin_clear_bt_keys()].
#'   The keys are released at once.
#' * To release the rest of the context, remove it and call [gc()].
#' @export
bin_fhe_context <- function(paramset = BinFHEParamSet$STD128,
                            method = BinFHEMethod$GINX,
                            arb_func = FALSE,
                            log_q = 11L,
                            n = 0L,
                            time_optimization = FALSE) {
  ctx_xp <- BinFHEContext__new()
  ## C++ has two overloads: (set, method) reads the parameter table, and
  ## (set, arbFunc, logQ, N, method, timeOptimization) derives the
  ## parameters. Supplying any of the four extra arguments, at its
  ## default value or not, selects the second, as it does in C++ and
  ## Python: (STD128, arbFunc = false) has n = 1305, (STD128) has n = 554.
  use_arb <- !missing(arb_func) || !missing(log_q) || !missing(n) ||
    !missing(time_optimization)
  if (use_arb) {
    BinFHEContext__GenerateBinFHEContextArbFunc(
      ctx_xp,
      as.integer(paramset),
      isTRUE(arb_func),
      as.integer(log_q),
      as.integer(n),
      as.integer(method),
      isTRUE(time_optimization))
  } else {
    BinFHEContext__GenerateBinFHEContext(ctx_xp, as.integer(paramset), as.integer(method))
  }
  ## >>> S7-FAST-NEW (RConsortium/S7#723): original
  ## BinFHEContext(ptr = ctx_xp)
  ## <<< S7-FAST-NEW
  .fast_new(BinFHEContext, ctx_xp)
}

#' Maximum supported plaintext space for functional bootstrapping
#'
#' @param ctx A BinFHE context built with `arb_func = TRUE`
#' @return A numeric scalar (q / (2 * beta))
#' @export
get_max_plaintext_space <- function(ctx) {
  BinFHEContext__GetMaxPlaintextSpace(ctx@ptr)
}

#' Generate BinFHE secret key
#'
#' @param ctx A BinFHE context
#' @return An LWEPrivateKey
#' @export
bin_key_gen <- function(ctx) {
  sk_xp <- BinFHEContext__KeyGen(ctx@ptr)
  ## >>> S7-FAST-NEW (RConsortium/S7#723): original
  ## LWEPrivateKey(ptr = sk_xp)
  ## <<< S7-FAST-NEW
  .fast_new(LWEPrivateKey, sk_xp)
}

#' Generate BinFHE bootstrapping keys
#'
#' @param ctx A BinFHE context
#' @param sk An LWEPrivateKey
#' @param keygen_mode Integer from [KeygenMode]; controls
#'   whether the bootstrapping keys are generated under
#'   symmetric-key encryption (`KeygenMode$SYM_ENCRYPT`, the
#'   default and the C++ default per
#'   `binfhe-constants.h` line 133) or public-key encryption
#'   (`KeygenMode$PUB_ENCRYPT`), matching the
#'   `BTKeyGen(sk, keygenMode, internal32)` method in
#'   `binfhecontext.h`.
#' @param internal32 Logical. If `TRUE` (the default, and the C++
#'   default), keys whose moduli fit are generated directly in the
#'   library's 32-bit internal form; a key that does not qualify is
#'   generated in the 64-bit form. If `FALSE`, all keys are generated
#'   in the 64-bit form.
#' @return Invisibly, the `ctx` BinFHE context that was passed in. Called for
#'   its side effect: the bootstrapping and key-switching keys are
#'   generated and stored inside the C++ context, after which
#'   [eval_bin_gate()] and the other gate evaluations can be used.
#' @section Memory:
#' The bootstrapping keys can occupy several gigabytes (about 5.8 GB
#' for `STD128` with `arb_func = TRUE` and `log_q = 12`). R's garbage
#' collector does not see this memory, so removing a context with
#' `rm()` does not release it until a collection happens to run.
#'
#' * Build one context and reuse it. The keys depend only on the
#'   parameters and the secret key.
#' * When a context is no longer needed, call [bin_clear_bt_keys()].
#'   The keys are released at once.
#' * To release the rest of the context, remove it and call [gc()].
#' @export
bin_bt_key_gen <- function(ctx, sk,
                           keygen_mode = KeygenMode$SYM_ENCRYPT,
                           internal32 = TRUE) {
  BinFHEContext__BTKeyGen(ctx@ptr, sk@ptr, as.integer(keygen_mode),
                          isTRUE(internal32))
  invisible(ctx)
}

#' Evaluate a floor (rounding) function on an LWE ciphertext
#'
#' Performs the LWE equivalent of `floor(ct / 2^roundbits)` via
#' functional bootstrapping. Used as a primitive in arbitrary-
#' function evaluation pipelines where the bit-level rounding
#' operation is needed separately from `eval_func()`'s LUT
#' path.
#'
#' Binding-level note: the underlying
#' `BinFHEContext__EvalFloor` cpp11 binding has been present
#' since the earliest BinFHE work; the R wrapper was added
#' later to close the latent gap (cpp11-only entry with no R
#' path).
#'
#' @param ctx A BinFHEContext
#' @param ct An LWECiphertext
#' @param roundbits Integer; the number of low-order bits to
#'   round off. Default `0L`, the C++ header default.
#' @return A new LWECiphertext holding the rounded value.
#' @seealso [eval_func()], [eval_sign()]
#' @export
eval_floor <- function(ctx, ct, roundbits = 0L) {
  ## >>> S7-FAST-NEW (RConsortium/S7#723): original
  ## LWECiphertext(ptr = BinFHEContext__EvalFloor(
  ##   ctx@ptr, ct@ptr, as.integer(roundbits)))
  ## <<< S7-FAST-NEW
  .fast_new(LWECiphertext, BinFHEContext__EvalFloor(
    ctx@ptr, ct@ptr, as.integer(roundbits)))
}

#' Encrypt a value for Binary FHE
#'
#' @param ctx A BinFHE context
#' @param sk An LWEPrivateKey, or an [LWEPublicKey] to encrypt under
#'   the public key.
#' @param message Integer (0 or 1 for Boolean; larger for integer FHE)
#' @param output An element of [BinFHEOutput] (default:
#'   `BinFHEOutput$BOOTSTRAPPED`). Use
#'   `BinFHEOutput$LARGE_DIM` together with `mod` for the
#'   functional-bootstrapping path. With a public key the default is
#'   `BinFHEOutput$SMALL_DIM`, as in openfhe-python, which needs the
#'   switching key that [bin_bt_key_gen()] generates.
#' @param p Plaintext modulus (default: 4)
#' @param mod Optional large ciphertext modulus Q for the LARGE_DIM
#'   path. NULL (default) selects the standard small-modulus encrypt.
#'   A whole number of at most 2^53, or a string of decimal digits for
#'   a larger value.
#' @return An LWECiphertext
#' @export
bin_encrypt <- function(ctx, sk, message, output = BinFHEOutput$BOOTSTRAPPED,
                        p = 4L, mod = NULL) {
  if (S7::S7_inherits(sk, LWEPublicKey)) {
    ## The public-key overload, whose C++ default output is SMALL_DIM.
    if (missing(output)) output <- BinFHEOutput$SMALL_DIM
    ## >>> S7-FAST-NEW (RConsortium/S7#723): original
    ## return(LWECiphertext(ptr = BinFHEContext__EncryptPK(
    ##   get_ptr(ctx), get_ptr(sk), as.numeric(message), as.integer(output),
    ##   wide_integer(p), if (is.null(mod)) "0" else wide_integer(mod))))
    ## <<< S7-FAST-NEW
    return(.fast_new(LWECiphertext, BinFHEContext__EncryptPK(
      get_ptr(ctx), get_ptr(sk), as.numeric(message), as.integer(output),
      wide_integer(p), if (is.null(mod)) "0" else wide_integer(mod))))
  }
  if (is.null(mod)) {
    ct_xp <- BinFHEContext__Encrypt(ctx@ptr, sk@ptr,
      as.integer(message), as.integer(output), as.integer(p))
  } else {
    ct_xp <- BinFHEContext__EncryptWithMod(ctx@ptr, sk@ptr,
      as.numeric(message), as.integer(output), wide_integer(p),
      wide_integer(mod))
  }
  ## >>> S7-FAST-NEW (RConsortium/S7#723): original
  ## LWECiphertext(ptr = ct_xp)
  ## <<< S7-FAST-NEW
  .fast_new(LWECiphertext, ct_xp)
}

#' Generate a lookup table for an arbitrary plaintext function
#'
#' Computes `f(0:(p-1), p)` and returns it as a numeric vector
#' suitable for `eval_func()`. This is the R-side analogue of
#' OpenFHE's `GenerateLUTviaFunction` — we don't bind the C++
#' helper because its signature takes a raw function pointer that
#' can't capture an R closure, and R is natively vectorised so a
#' pure-R helper is both simpler and faster than wiring an R
#' callback through cpp11.
#'
#' @param f A function `function(m, p)` that returns the table
#'   entry for input `m` under plaintext modulus `p`. Vectorised
#'   functions are supported.
#' @param p The plaintext modulus (typically `get_max_plaintext_space(ctx)`)
#' @return A length-`p` numeric vector of LUT entries
#' @export
generate_lut_via_function <- function(f, p) {
  p <- as.integer(p)
  if (length(p) != 1L || is.na(p) || p <= 0L) {
    cli::cli_abort("{.arg p} must be a positive scalar integer.")
  }
  vals <- f(seq.int(0L, p - 1L), p)
  if (length(vals) != p) {
    cli::cli_abort("{.arg f} must return one value per input; got {length(vals)} for p = {p}.")
  }
  as.numeric(vals)
}

#' Evaluate an arbitrary function on an encrypted value
#'
#' Functional bootstrapping with a precomputed lookup table. The
#' context must have been created with `arb_func = TRUE`.
#'
#' @param ctx A BinFHE context built with `arb_func = TRUE`
#' @param ct An LWECiphertext encrypted with `output = BinFHEOutput$LARGE_DIM`
#' @param lut A numeric vector of length `p` (the plaintext modulus)
#'   typically produced by `generate_lut_via_function()`
#' @return An LWECiphertext encrypting `lut[plaintext(ct) + 1]`
#' @export
eval_func <- function(ctx, ct, lut) {
  ## >>> S7-FAST-NEW (RConsortium/S7#723): original
  ## LWECiphertext(ptr = BinFHEContext__EvalFunc(ctx@ptr, ct@ptr, as.numeric(lut)))
  ## <<< S7-FAST-NEW
  .fast_new(LWECiphertext, BinFHEContext__EvalFunc(ctx@ptr, ct@ptr, as.numeric(lut)))
}

#' Evaluate sign on an encrypted value (functional bootstrapping)
#'
#' Extracts the most-significant bit of an LWE ciphertext encrypted
#' under the large modulus Q. The context must have been created with
#' `arb_func = TRUE`.
#'
#' @param ctx A BinFHE context built with `arb_func = TRUE`
#' @param ct An LWECiphertext encrypted via `bin_encrypt(..., mod = Q)`
#' @param scheme_switch Logical; when `TRUE`, the output
#'   ciphertext is encoded compatibly with the CKKS<->FHEW
#'   scheme-switching pipeline (the `schemeSwitch` flag at
#'   `binfhecontext.h` line 367). Default `FALSE` for the
#'   standalone FHEW path. Per the upstream header
#'   description, this is the "flag that indicates if it
#'   should be compatible to scheme switching".
#' @return An LWECiphertext encrypting 0 if the input was negative
#'   (i.e. lay in the upper half of [0, Q)), 1 otherwise
#' @export
eval_sign <- function(ctx, ct, scheme_switch = FALSE) {
  ## >>> S7-FAST-NEW (RConsortium/S7#723): original
  ## LWECiphertext(ptr = BinFHEContext__EvalSign(ctx@ptr, ct@ptr, isTRUE(scheme_switch)))
  ## <<< S7-FAST-NEW
  .fast_new(LWECiphertext, BinFHEContext__EvalSign(ctx@ptr, ct@ptr, isTRUE(scheme_switch)))
}

#' Decrypt a Binary FHE ciphertext
#'
#' @param ctx A BinFHE context
#' @param sk An LWEPrivateKey
#' @param ct An LWECiphertext
#' @param p Plaintext modulus (default: 4)
#' @return Integer value
#' @export
bin_decrypt <- function(ctx, sk, ct, p = 4L) {
  BinFHEContext__Decrypt(ctx@ptr, sk@ptr, ct@ptr, as.integer(p))
}

#' Evaluate a binary gate on encrypted values
#'
#' @param ctx A BinFHE context
#' @param gate A [BinGate] value. Two-input gates: `OR`, `AND`,
#'   `NOR`, `NAND`, `XOR`, `XNOR`, `XOR_FAST`, `XNOR_FAST`. Three
#'   or more input gates (vector form): `MAJORITY`, `AND3`, `OR3`,
#'   `AND4`, `OR4`, `CMUX`.
#' @param ct1 An `LWECiphertext`, OR a list of `LWECiphertext`
#'   objects for the 3+-input vector form. When a list is
#'   supplied, `ct2` must be left at its default (`NULL`).
#' @param ct2 An `LWECiphertext` for the 2-input form, or
#'   `NULL` (the default) when `ct1` is a list. The vector
#'   dispatch follows `binfhecontext.h` line 322.
#' @param extended Logical; if `TRUE` the result is left in the
#'   extended ring dimension `N` rather than switched back to `n`.
#'   Default `FALSE`, the C++ header default.
#' @return An `LWECiphertext`
#' @export
eval_bin_gate <- function(ctx, gate, ct1, ct2 = NULL, extended = FALSE) {
  extended <- isTRUE(extended)
  if (is.null(ct2)) {
    ## Vector form: `ct1` is a list of LWECiphertext S7 wrappers.
    ## Dispatch to the vector-form cpp11 binding.
    if (!is.list(ct1)) {
      cli::cli_abort(c(
        "{.arg ct1} must be either an {.cls LWECiphertext} or a list of {.cls LWECiphertext} objects.",
        "i" = "Pass {.arg ct2} to select the 2-input form, or a list as {.arg ct1} for the 3+-input gates (MAJORITY / AND3 / OR3 / AND4 / OR4 / CMUX)."
      ))
    }
    ct_ptrs <- lapply(ct1, get_ptr)
    ## >>> S7-FAST-NEW (RConsortium/S7#723): original
    ## LWECiphertext(ptr = BinFHEContext__EvalBinGate__vec(
    ##   ctx@ptr, as.integer(gate), ct_ptrs, extended))
    ## <<< S7-FAST-NEW
    .fast_new(LWECiphertext, BinFHEContext__EvalBinGate__vec(
      ctx@ptr, as.integer(gate), ct_ptrs, extended))
  } else {
    ## 2-input form — backward compatible with the original
    ## positional call `eval_bin_gate(ctx, gate, ct1, ct2)`.
    ## >>> S7-FAST-NEW (RConsortium/S7#723): original
    ## LWECiphertext(ptr = BinFHEContext__EvalBinGate(ctx@ptr,
    ##   as.integer(gate), ct1@ptr, ct2@ptr, extended))
    ## <<< S7-FAST-NEW
    .fast_new(LWECiphertext, BinFHEContext__EvalBinGate(ctx@ptr,
      as.integer(gate), ct1@ptr, ct2@ptr, extended))
  }
}

#' Evaluate NOT on an encrypted value
#'
#' @param ctx A BinFHE context
#' @param ct An LWECiphertext
#' @return An LWECiphertext
#' @export
eval_not <- function(ctx, ct) {
  ## >>> S7-FAST-NEW (RConsortium/S7#723): original
  ## LWECiphertext(ptr = BinFHEContext__EvalNOT(ctx@ptr, ct@ptr))
  ## <<< S7-FAST-NEW
  .fast_new(LWECiphertext, BinFHEContext__EvalNOT(ctx@ptr, ct@ptr))
}

method(print, LWECiphertext) <- function(x, ...) {
  cli::cli_text("{.cls LWECiphertext} [{if (ptr_is_valid(x)) 'active' else 'null'}]")
  invisible(x)
}

method(print, LWEPrivateKey) <- function(x, ...) {
  cli::cli_text("{.cls LWEPrivateKey} [{if (ptr_is_valid(x)) 'active' else 'null'}]")
  invisible(x)
}
