## OPENFHE PYTHON SOURCE: src/lib/binfhe_bindings.cpp

#' LWE Ciphertext (Binary FHE)
#' @param ptr External pointer (internal use)
#' @export
LWECiphertext <- new_class("LWECiphertext",
  parent = OpenFHEObject,
  package = "openfhe.R"
)

#' LWE Private Key (Binary FHE)
#' @param ptr External pointer (internal use)
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
#'   arbitrary-function bootstrapping (EvalSign, EvalFunc). Selecting
#'   any of `arb_func`, `log_q`, `n`, or `time_optimization` activates
#'   the extended overload.
#' @param log_q log2 of the large ciphertext modulus Q used by
#'   functional bootstrapping (default 11; use 17 for the eval-sign
#'   example).
#' @param n Ring dimension override (0 lets OpenFHE pick).
#' @param time_optimization Enable the GINX time-optimization variant.
#' @return A BinFHEContext (stored as OpenFHEObject)
#' @export
bin_fhe_context <- function(paramset = BinFHEParamSet$STD128,
                            method = BinFHEMethod$GINX,
                            arb_func = FALSE,
                            log_q = 11L,
                            n = 0L,
                            time_optimization = FALSE) {
  ctx_xp <- BinFHEContext__new()
  use_arb <- isTRUE(arb_func) || !identical(as.integer(log_q), 11L) ||
    !identical(as.integer(n), 0L) || isTRUE(time_optimization)
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
  OpenFHEObject(ptr = ctx_xp)
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
  LWEPrivateKey(ptr = sk_xp)
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
#'   `BTKeyGen(sk, keyGenMode)` overload at
#'   `binfhecontext.h` line 273.
#' @export
bin_bt_key_gen <- function(ctx, sk,
                           keygen_mode = KeygenMode$SYM_ENCRYPT) {
  BinFHEContext__BTKeyGen(ctx@ptr, sk@ptr, as.integer(keygen_mode))
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
#'   round off.
#' @return A new LWECiphertext holding the rounded value.
#' @seealso [eval_func()], [eval_sign()]
#' @export
eval_floor <- function(ctx, ct, roundbits) {
  LWECiphertext(ptr = BinFHEContext__EvalFloor(
    ctx@ptr, ct@ptr, as.integer(roundbits)))
}

#' Encrypt a value for Binary FHE
#'
#' @param ctx A BinFHE context
#' @param sk An LWEPrivateKey
#' @param message Integer (0 or 1 for Boolean; larger for integer FHE)
#' @param output BINFHE_OUTPUT (default: 2 = BOOTSTRAPPED). Use
#'   `BinFHEOutput$LARGE_DIM` together with `mod` for the
#'   functional-bootstrapping path.
#' @param p Plaintext modulus (default: 4)
#' @param mod Optional large ciphertext modulus Q for the LARGE_DIM
#'   path. NULL (default) selects the standard small-modulus encrypt.
#' @return An LWECiphertext
#' @export
bin_encrypt <- function(ctx, sk, message, output = 2L, p = 4L, mod = NULL) {
  if (is.null(mod)) {
    ct_xp <- BinFHEContext__Encrypt(ctx@ptr, sk@ptr,
      as.integer(message), as.integer(output), as.integer(p))
  } else {
    ct_xp <- BinFHEContext__EncryptWithMod(ctx@ptr, sk@ptr,
      as.numeric(message), as.integer(output), as.numeric(p), as.numeric(mod))
  }
  LWECiphertext(ptr = ct_xp)
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
  LWECiphertext(ptr = BinFHEContext__EvalFunc(ctx@ptr, ct@ptr, as.numeric(lut)))
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
  LWECiphertext(ptr = BinFHEContext__EvalSign(ctx@ptr, ct@ptr, isTRUE(scheme_switch)))
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
#' @return An `LWECiphertext`
#' @export
eval_bin_gate <- function(ctx, gate, ct1, ct2 = NULL) {
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
    LWECiphertext(ptr = BinFHEContext__EvalBinGate__vec(
      ctx@ptr, as.integer(gate), ct_ptrs))
  } else {
    ## 2-input form — backward compatible with the original
    ## positional call `eval_bin_gate(ctx, gate, ct1, ct2)`.
    LWECiphertext(ptr = BinFHEContext__EvalBinGate(ctx@ptr,
      as.integer(gate), ct1@ptr, ct2@ptr))
  }
}

#' Evaluate NOT on an encrypted value
#'
#' @param ctx A BinFHE context
#' @param ct An LWECiphertext
#' @return An LWECiphertext
#' @export
eval_not <- function(ctx, ct) {
  LWECiphertext(ptr = BinFHEContext__EvalNOT(ctx@ptr, ct@ptr))
}

method(print, LWECiphertext) <- function(x, ...) {
  cli::cli_text("{.cls LWECiphertext} [{if (ptr_is_valid(x)) 'active' else 'null'}]")
  invisible(x)
}

method(print, LWEPrivateKey) <- function(x, ...) {
  cli::cli_text("{.cls LWEPrivateKey} [{if (ptr_is_valid(x)) 'active' else 'null'}]")
  invisible(x)
}
