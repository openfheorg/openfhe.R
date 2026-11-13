## OPENFHE PYTHON SOURCE: src/lib/bindings.cpp (key switching, key registry and module-level helpers bound at OpenFHE 1.6.1)
##
## R wrappers for src/pke_keyswitch.cpp.

# ── Key switching ───────────────────────────────────────

#' Switch a ciphertext from one secret key to another
#'
#' `key_switch_gen()` makes the key that switches ciphertexts under
#' `old_private_key` to ciphertexts under `new_private_key`.
#' `key_switch()` applies it and returns the switched ciphertext;
#' `key_switch_in_place()` switches the ciphertext it is given.
#'
#' @param cc A `CryptoContext`.
#' @param old_private_key,new_private_key `PrivateKey` objects.
#' @param ct A `Ciphertext`.
#' @param eval_key The `EvalKey` from `key_switch_gen()`.
#' @return `key_switch_gen()`: an `EvalKey`. `key_switch()`: a
#'   `Ciphertext`. `key_switch_in_place()`: `ct`, invisibly.
#' @seealso [re_key_gen()] for the form that needs only the public key
#'   of the receiving party.
#' @export
key_switch_gen <- function(cc, old_private_key, new_private_key) {
  ## >>> S7-FAST-NEW (RConsortium/S7#723): original
  ## EvalKey(ptr = KeySwitchGen__(get_ptr(cc), get_ptr(old_private_key),
  ##                              get_ptr(new_private_key)))
  ## <<< S7-FAST-NEW
  .fast_new(EvalKey, KeySwitchGen__(get_ptr(cc), get_ptr(old_private_key),
                                    get_ptr(new_private_key)))
}

#' @rdname key_switch_gen
#' @export
key_switch <- function(ct, eval_key) {
  ## >>> S7-FAST-NEW (RConsortium/S7#723): original
  ## Ciphertext(ptr = KeySwitch__(get_ptr(ct), get_ptr(eval_key)))
  ## <<< S7-FAST-NEW
  .fast_new(Ciphertext, KeySwitch__(get_ptr(ct), get_ptr(eval_key)))
}

#' @rdname key_switch_gen
#' @export
key_switch_in_place <- function(ct, eval_key) {
  KeySwitchInPlace__(get_ptr(ct), get_ptr(eval_key))
  invisible(ct)
}

#' Steps of hybrid key switching
#'
#' Hybrid key switching works in an extended basis `P*Q` and comes
#' back to `Q` at the end. These functions expose two of its steps,
#' for code that hoists or defers them (CKKS). `key_switch_ext()`
#' takes a ciphertext to the extended basis, multiplying its elements
#' by `P`; with `add_first = FALSE` the first element of the result is
#' left at zero. `key_switch_down_first_element()` brings only the
#' first element back to `Q` and returns it as a ring element.
#' [key_switch_down()] brings a whole ciphertext back.
#'
#' @param ct A `Ciphertext`.
#' @param add_first Logical.
#' @return `key_switch_ext()`: a `Ciphertext` in the extended basis.
#'   `key_switch_down_first_element()`: a [DCRTPoly].
#' @export
key_switch_ext <- function(ct, add_first) {
  ## >>> S7-FAST-NEW (RConsortium/S7#723): original
  ## Ciphertext(ptr = KeySwitchExt__(get_ptr(ct), isTRUE(add_first)))
  ## <<< S7-FAST-NEW
  .fast_new(Ciphertext, KeySwitchExt__(get_ptr(ct), isTRUE(add_first)))
}

#' @rdname key_switch_ext
#' @export
key_switch_down_first_element <- function(ct) {
  ## >>> S7-FAST-NEW (RConsortium/S7#723): original
  ## DCRTPoly(ptr = KeySwitchDownFirstElement__(get_ptr(ct)))
  ## <<< S7-FAST-NEW
  .fast_new(DCRTPoly, KeySwitchDownFirstElement__(get_ptr(ct)))
}

# ── Key generation ──────────────────────────────────────

#' Generate a sparse key pair
#'
#' Calls the C++ `SparseKeyGen()`, which the OpenFHE header describes
#' as a key pair "with special structure and without full entropy" for
#' uses such as ring reduction, and as not supported by any scheme at
#' present. Use [key_gen()] for ordinary keys.
#'
#' @param cc A `CryptoContext`.
#' @return A `KeyPair`.
#' @export
sparse_key_gen <- function(cc) {
  kp <- SparseKeyGen__(get_ptr(cc))
  ## >>> S7-FAST-NEW (RConsortium/S7#723): original
  ## KeyPair(public = PublicKey(ptr = kp$public),
  ## <<< S7-FAST-NEW
  KeyPair(public = .fast_new(PublicKey, kp$public),
          ## >>> S7-FAST-NEW (RConsortium/S7#723): original
          ## secret = PrivateKey(ptr = kp$secret))
          ## <<< S7-FAST-NEW
          secret = .fast_new(PrivateKey, kp$secret))
}

#' A party's share of the joint multiplication key (threshold FHE)
#'
#' In the threshold protocol each party multiplies the combined
#' key-switching key by its own secret share; the results are then
#' added with [multi_add_eval_mult_keys()] to give the joint
#' relinearization key.
#'
#' @param cc A `CryptoContext`.
#' @param sk The party's `PrivateKey` (its secret share).
#' @param eval_key The combined `EvalKey` from [multi_add_eval_keys()].
#' @param key_tag Character string; the tag for the result, `""`
#'   (default) to keep the library's choice.
#' @return An `EvalKey`.
#' @export
multi_mult_eval_key <- function(cc, sk, eval_key, key_tag = "") {
  ## >>> S7-FAST-NEW (RConsortium/S7#723): original
  ## EvalKey(ptr = MultiMultEvalKey__(get_ptr(cc), get_ptr(sk), get_ptr(eval_key),
  ##                                  as.character(key_tag)))
  ## <<< S7-FAST-NEW
  .fast_new(EvalKey, MultiMultEvalKey__(get_ptr(cc), get_ptr(sk), get_ptr(eval_key),
                                        as.character(key_tag)))
}

# ── Registries ──────────────────────────────────────────

#' Remove summation keys from the registry
#'
#' Removes the keys that [eval_sum_key_gen()] registered: all of them,
#' or those under one key tag.
#'
#' @param key_tag Character string, or `NULL` (default) for all keys.
#' @return `NULL`, invisibly.
#' @seealso [clear_eval_mult_keys()], [clear_eval_automorphism_keys()]
#' @export
clear_eval_sum_keys <- function(key_tag = NULL) {
  if (is.null(key_tag)) {
    ClearEvalSumKeys__()
  } else {
    ClearEvalSumKeys__tag(as.character(key_tag))
  }
  invisible(NULL)
}

#' All contexts the library currently holds
#'
#' OpenFHE keeps every context it has generated in a registry, and
#' returns the registered one when asked for parameters it has seen.
#' This function lists the registry.
#'
#' @return A list of `CryptoContext` objects.
#' @seealso [clear_fhe_state()], which can empty the registry.
#' @export
get_all_contexts <- function() {
  ## >>> S7-FAST-NEW (RConsortium/S7#723): original
  ## lapply(GetAllContexts__(), function(p) CryptoContext(ptr = p))
  ## <<< S7-FAST-NEW
  lapply(GetAllContexts__(), function(p) .fast_new(CryptoContext, p))
}

# ── Globals ─────────────────────────────────────────────

#' Precompute CRT tables when a context is deserialized
#'
#' By default OpenFHE precomputes its CRT tables when it deserializes
#' a context. `disable_precompute_crt_tables_after_deserializaton()`
#' turns that off, which makes deserialization faster for a context
#' that will only be inspected, and
#' `enable_precompute_crt_tables_after_deserializaton()` turns it back
#' on. The setting is global.
#'
#' The function names keep the spelling of the C++ functions they
#' call.
#'
#' @return `NULL`, invisibly.
#' @export
enable_precompute_crt_tables_after_deserializaton <- function() {
  PrecomputeCRTTablesAfterDeserializaton__set(TRUE)
  invisible(NULL)
}

#' @rdname enable_precompute_crt_tables_after_deserializaton
#' @export
disable_precompute_crt_tables_after_deserializaton <- function() {
  PrecomputeCRTTablesAfterDeserializaton__set(FALSE)
  invisible(NULL)
}

# ── Cleartext math ──────────────────────────────────────

#' Chebyshev approximation of a function, in the clear
#'
#' The cleartext counterpart of [eval_chebyshev_function()]: it
#' evaluates the degree-`degree` Chebyshev approximation of `func` on
#' `[a, b]` at the points `ptxt`, with the arithmetic OpenFHE uses on
#' ciphertexts. Comparing its result with `func(ptxt)` gives the
#' approximation error of a degree before any encrypted computation
#' is run.
#'
#' @param func A function of one number returning one number.
#' @param ptxt Numeric vector of points in `[a, b]`.
#' @param a,b Numeric; the interval.
#' @param degree Integer; the degree of the approximation, at least 1.
#' @return A numeric vector the length of `ptxt`.
#' @examples
#' x <- seq(-1, 1, by = 0.5)
#' eval_chebyshev_function_ptxt(exp, x, -1, 1, 8L) - exp(x)
#' @export
eval_chebyshev_function_ptxt <- function(func, ptxt, a, b, degree) {
  if (!is.function(func)) {
    cli_abort("{.arg func} must be a function.")
  }
  EvalChebyshevFunctionPtxt__(func, as.double(ptxt), as.double(a),
                              as.double(b), as.integer(degree))
}

#' Multiplicative depth of a polynomial evaluation
#'
#' The depth the Paterson-Stockmeyer evaluation of a polynomial or
#' Chebyshev series with the given coefficient vector consumes. It
#' depends only on the number of coefficients.
#'
#' @param vec The coefficient vector (numeric or complex).
#' @param is_normalized Logical; `TRUE` if the coefficients are
#'   normalized, which saves one level. Default `FALSE`.
#' @return An integer.
#' @seealso [eval_poly()], [eval_chebyshev()]
#' @export
get_multiplicative_depth_by_coeff_vector <- function(vec, is_normalized = FALSE) {
  if (!(is.numeric(vec) || is.complex(vec))) {
    cli_abort("{.arg vec} must be a numeric or complex vector.")
  }
  GetMultiplicativeDepthByCoeffVector__(length(vec), isTRUE(is_normalized))
}
