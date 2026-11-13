## OPENFHE PYTHON SOURCE: src/lib/bindings.cpp (SchSwchParams; scheme switching between CKKS and FHEW)
##
## R wrappers for src/pke_scheme_switching.cpp.

# ── SchSwchParams ───────────────────────────────────────

#' Parameters of scheme switching
#'
#' The parameter object [eval_ckks_to_fhew_setup()] and
#' [eval_scheme_switching_setup()] take. `SchSwchParams()` makes one
#' with the library defaults; the `set_` functions on this page change
#' one field each and return the object invisibly, so a parameter
#' object is built step by step as in the OpenFHE examples.
#'
#' The three fields `initial_ckks_modulus`, `ring_dimension`,
#' `scaling_mod_size` and `batch_size` describe the CKKS context. The
#' setup functions fill them from the context, so they are not set by
#' hand in ordinary use; [set_params_from_ckks_cryptocontext()] does
#' the same on request.
#'
#' The `get_` functions return the fields. The library refuses to read
#' a parameter object whose CKKS fields have not been filled, so they
#' work after a setup function or
#' [set_params_from_ckks_cryptocontext()] has been given the object;
#' `format()` and `print()` show every field at any time.
#'
#' | Field | Meaning | Default |
#' |---|---|---|
#' | `security_level_ckks` | Security level of the CKKS context, an element of [SecurityLevel] | `HEStd_128_classic` |
#' | `security_level_fhew` | Parameter set of the FHEW context, an element of [BinFHEParamSet] | `STD128` |
#' | `arbitrary_function_evaluation` | Whether the FHEW context is for arbitrary function evaluation | `FALSE` |
#' | `use_dynamic_mode_fhew` | Whether the FHEW context uses dynamic gadget bases | `FALSE` |
#' | `compute_argmin` | Whether the argmin is computed with the minimum (or argmax with the maximum) | `FALSE` |
#' | `one_hot_encoding` | Whether the argmin is returned one-hot encoded | `TRUE` |
#' | `use_alt_argmin` | Whether the alternative argmin method is used | `FALSE` |
#' | `num_slots_ckks` | Number of CKKS slots to switch | `0` |
#' | `num_values` | Number of values to switch | `0` |
#' | `ctxt_mod_size_fhew_large_prec` | Bits of the large-precision FHEW ciphertext modulus | `25` |
#' | `ctxt_mod_size_fhew_intermed_swch` | Bits of the intermediate modulus of the switch | `27` |
#' | `b_step_ltr_ckks_to_fhew` | Baby-step of the linear transform from CKKS to FHEW | `0` |
#' | `b_step_ltr_fhew_to_ckks` | Baby-step of the linear transform from FHEW to CKKS | `0` |
#' | `level_ltr_ckks_to_fhew` | Level of the linear transform from CKKS to FHEW | `1` |
#' | `level_ltr_fhew_to_ckks` | Level of the linear transform from FHEW to CKKS | `0` |
#'
#' @param ptr External pointer (internal use). `NULL` (default) makes
#'   a new parameter object.
#' @param params A `SchSwchParams` object.
#' @param value The new value of the field: a logical for the five
#'   flags, an enum member for the two security levels, a string of
#'   decimal digits (or a whole number of at most 2^53) for
#'   `initial_ckks_modulus`, and a non-negative whole number
#'   otherwise.
#' @return `SchSwchParams()`: an S7 object of class `SchSwchParams`,
#'   inheriting from [OpenFHEObject]. The `set_` functions: `params`,
#'   invisibly. The `get_` functions: the value of the field, a string
#'   of decimal digits for `initial_ckks_modulus`.
#' @examples
#' params <- SchSwchParams()
#' set_security_level_ckks(params, SecurityLevel$HEStd_NotSet)
#' set_security_level_fhew(params, BinFHEParamSet$TOY)
#' set_num_slots_ckks(params, 16L)
#' params
#' @name SchSwchParams
#' @export
SchSwchParams <- new_class("SchSwchParams",
  parent = OpenFHEObject,
  package = "openfhe.R",
  constructor = function(ptr = NULL) {
    if (is.null(ptr)) ptr <- SchSwchParams__new()
    new_object(S7_object(), ptr = ptr)
  }
)

method(format, SchSwchParams) <- function(x, ...) SchSwchParams__str(get_ptr(x))

method(print, SchSwchParams) <- function(x, ...) {
  cat("<SchSwchParams>\n", SchSwchParams__str(get_ptr(x)), "\n", sep = "")
  invisible(x)
}

## Field codes, in the order of `enum SchSwchField` in
## src/pke_scheme_switching.cpp.
.SCHSWCH_FIELD <- c(
  security_level_ckks = 0L, security_level_fhew = 1L,
  arbitrary_function_evaluation = 2L, use_dynamic_mode_fhew = 3L,
  compute_argmin = 4L, one_hot_encoding = 5L, use_alt_argmin = 6L,
  num_slots_ckks = 7L, num_values = 8L, ctxt_mod_size_fhew_large_prec = 9L,
  ctxt_mod_size_fhew_intermed_swch = 10L, b_step_ltr_ckks_to_fhew = 11L,
  b_step_ltr_fhew_to_ckks = 12L, level_ltr_ckks_to_fhew = 13L,
  level_ltr_fhew_to_ckks = 14L, ring_dimension = 15L, scaling_mod_size = 16L,
  batch_size = 17L
)

.SCHSWCH_FLAGS <- c("arbitrary_function_evaluation", "use_dynamic_mode_fhew",
                    "compute_argmin", "one_hot_encoding", "use_alt_argmin")

.schswch_set <- function(params, field, value, call = rlang::caller_env()) {
  if (field %in% .SCHSWCH_FLAGS) {
    if (!is.logical(value) || length(value) != 1L || is.na(value)) {
      cli_abort("{.arg value} must be `TRUE` or `FALSE`.", call = call)
    }
  } else if (!is.numeric(value) || is.object(value) || length(value) != 1L ||
             is.na(value) || value != trunc(value) || value < 0 ||
             value > .Machine$integer.max) {
    cli_abort("{.arg value} must be a single non-negative whole number.",
              call = call)
  }
  SchSwchParams__Set(get_ptr(params), .SCHSWCH_FIELD[[field]], as.integer(value))
  invisible(params)
}

.schswch_get <- function(params, field) {
  v <- SchSwchParams__Get(get_ptr(params), .SCHSWCH_FIELD[[field]])
  if (field %in% .SCHSWCH_FLAGS) as.logical(v) else v
}

#' @rdname SchSwchParams
#' @export
set_security_level_ckks <- function(params, value)
  .schswch_set(params, "security_level_ckks", value)
#' @rdname SchSwchParams
#' @export
set_security_level_fhew <- function(params, value)
  .schswch_set(params, "security_level_fhew", value)
#' @rdname SchSwchParams
#' @export
set_arbitrary_function_evaluation <- function(params, value)
  .schswch_set(params, "arbitrary_function_evaluation", value)
#' @rdname SchSwchParams
#' @export
set_use_dynamic_mode_fhew <- function(params, value)
  .schswch_set(params, "use_dynamic_mode_fhew", value)
#' @rdname SchSwchParams
#' @export
set_compute_argmin <- function(params, value)
  .schswch_set(params, "compute_argmin", value)
#' @rdname SchSwchParams
#' @export
set_one_hot_encoding <- function(params, value)
  .schswch_set(params, "one_hot_encoding", value)
#' @rdname SchSwchParams
#' @export
set_use_alt_argmin <- function(params, value)
  .schswch_set(params, "use_alt_argmin", value)
#' @rdname SchSwchParams
#' @export
set_num_slots_ckks <- function(params, value)
  .schswch_set(params, "num_slots_ckks", value)
#' @rdname SchSwchParams
#' @export
set_num_values <- function(params, value)
  .schswch_set(params, "num_values", value)
#' @rdname SchSwchParams
#' @export
set_ctxt_mod_size_fhew_large_prec <- function(params, value)
  .schswch_set(params, "ctxt_mod_size_fhew_large_prec", value)
#' @rdname SchSwchParams
#' @export
set_ctxt_mod_size_fhew_intermed_swch <- function(params, value)
  .schswch_set(params, "ctxt_mod_size_fhew_intermed_swch", value)
#' @rdname SchSwchParams
#' @export
set_b_step_ltr_ckks_to_fhew <- function(params, value)
  .schswch_set(params, "b_step_ltr_ckks_to_fhew", value)
#' @rdname SchSwchParams
#' @export
set_b_step_ltr_fhew_to_ckks <- function(params, value)
  .schswch_set(params, "b_step_ltr_fhew_to_ckks", value)
#' @rdname SchSwchParams
#' @export
set_level_ltr_ckks_to_fhew <- function(params, value)
  .schswch_set(params, "level_ltr_ckks_to_fhew", value)
#' @rdname SchSwchParams
#' @export
set_level_ltr_fhew_to_ckks <- function(params, value)
  .schswch_set(params, "level_ltr_fhew_to_ckks", value)
#' @rdname SchSwchParams
#' @export
set_ring_dimension <- function(params, value)
  .schswch_set(params, "ring_dimension", value)
#' @rdname SchSwchParams
#' @export
set_initial_ckks_modulus <- function(params, value) {
  SchSwchParams__SetInitialCKKSModulus(get_ptr(params), wide_integer(value))
  invisible(params)
}

#' @rdname SchSwchParams
#' @export
set_params_from_ckks_cryptocontext_called <- function(params) {
  SchSwchParams__SetParamsFromCKKSCryptocontextCalled(get_ptr(params))
  invisible(params)
}

## The two fields whose setters and getters are generics of the CCParams
## classes (R/params-setters.R, R/params-getters.R).
method(set_scaling_mod_size, SchSwchParams) <- function(params, value)
  .schswch_set(params, "scaling_mod_size", value)
method(set_batch_size, SchSwchParams) <- function(params, value)
  .schswch_set(params, "batch_size", value)
method(get_scaling_mod_size, SchSwchParams) <- function(params)
  .schswch_get(params, "scaling_mod_size")
method(get_batch_size, SchSwchParams) <- function(params)
  .schswch_get(params, "batch_size")

#' @rdname SchSwchParams
#' @export
get_security_level_ckks <- function(params)
  .schswch_get(params, "security_level_ckks")
#' @rdname SchSwchParams
#' @export
get_security_level_fhew <- function(params)
  .schswch_get(params, "security_level_fhew")
#' @rdname SchSwchParams
#' @export
get_arbitrary_function_evaluation <- function(params)
  .schswch_get(params, "arbitrary_function_evaluation")
#' @rdname SchSwchParams
#' @export
get_use_dynamic_mode_fhew <- function(params)
  .schswch_get(params, "use_dynamic_mode_fhew")
#' @rdname SchSwchParams
#' @export
get_compute_argmin <- function(params) .schswch_get(params, "compute_argmin")
#' @rdname SchSwchParams
#' @export
get_one_hot_encoding <- function(params) .schswch_get(params, "one_hot_encoding")
#' @rdname SchSwchParams
#' @export
get_use_alt_argmin <- function(params) .schswch_get(params, "use_alt_argmin")
#' @rdname SchSwchParams
#' @export
get_num_slots_ckks <- function(params) .schswch_get(params, "num_slots_ckks")
#' @rdname SchSwchParams
#' @export
get_num_values <- function(params) .schswch_get(params, "num_values")
#' @rdname SchSwchParams
#' @export
get_ctxt_mod_size_fhew_large_prec <- function(params)
  .schswch_get(params, "ctxt_mod_size_fhew_large_prec")
#' @rdname SchSwchParams
#' @export
get_ctxt_mod_size_fhew_intermed_swch <- function(params)
  .schswch_get(params, "ctxt_mod_size_fhew_intermed_swch")
#' @rdname SchSwchParams
#' @export
get_b_step_ltr_ckks_to_fhew <- function(params)
  .schswch_get(params, "b_step_ltr_ckks_to_fhew")
#' @rdname SchSwchParams
#' @export
get_b_step_ltr_fhew_to_ckks <- function(params)
  .schswch_get(params, "b_step_ltr_fhew_to_ckks")
#' @rdname SchSwchParams
#' @export
get_level_ltr_ckks_to_fhew <- function(params)
  .schswch_get(params, "level_ltr_ckks_to_fhew")
#' @rdname SchSwchParams
#' @export
get_level_ltr_fhew_to_ckks <- function(params)
  .schswch_get(params, "level_ltr_fhew_to_ckks")
#' @rdname SchSwchParams
#' @export
get_ring_dimension <- function(params) .schswch_get(params, "ring_dimension")
#' @rdname SchSwchParams
#' @export
get_initial_ckks_modulus <- function(params)
  SchSwchParams__GetInitialCKKSModulus(get_ptr(params))

# ── Context accessors ───────────────────────────────────

#' Fill scheme-switching parameters from a CKKS context
#'
#' Copies the first modulus, the ring dimension, the scaling modulus
#' size and the batch size of `cc` into `params`, and marks `params`
#' as filled. [eval_ckks_to_fhew_setup()] and
#' [eval_scheme_switching_setup()] do this themselves.
#'
#' @param cc A CKKS `CryptoContext`.
#' @param params A [SchSwchParams] object; changed in place.
#' @return `params`, invisibly.
#' @export
set_params_from_ckks_cryptocontext <- function(cc, params) {
  SetParamsFromCKKSCryptocontext__(get_ptr(cc), get_ptr(params))
  invisible(params)
}

#' The FHEW side of a scheme-switching context
#'
#' `get_bin_cc_for_scheme_switch()` returns the FHEW context that a
#' scheme-switching setup created inside the CKKS context `cc`, and
#' `set_bin_cc_for_scheme_switch()` puts one there.
#' `get_swk_fc()` and `set_swk_fc()` read and write the switching key
#' from FHEW to CKKS, which is a CKKS ciphertext. The setters are for
#' restoring a context in another session.
#'
#' @param cc A CKKS `CryptoContext`.
#' @param bin_fhe_context A `BinFHEContext`.
#' @param switching_key A `Ciphertext`.
#' @return `get_bin_cc_for_scheme_switch()`: a `BinFHEContext`, or
#'   `NULL` if `cc` holds none. `get_swk_fc()`: a `Ciphertext`, or
#'   `NULL` if `cc` holds none. The setters: `cc`, invisibly.
#' @export
get_bin_cc_for_scheme_switch <- function(cc) {
  p <- GetBinCCForSchemeSwitch__(get_ptr(cc))
  ## >>> S7-FAST-NEW (RConsortium/S7#723): original
  ## if (is.null(p)) NULL else BinFHEContext(ptr = p)
  ## <<< S7-FAST-NEW
  if (is.null(p)) NULL else .fast_new(BinFHEContext, p)
}

#' @rdname get_bin_cc_for_scheme_switch
#' @export
set_bin_cc_for_scheme_switch <- function(cc, bin_fhe_context) {
  SetBinCCForSchemeSwitch__(get_ptr(cc), get_ptr(bin_fhe_context))
  invisible(cc)
}

#' @rdname get_bin_cc_for_scheme_switch
#' @export
get_swk_fc <- function(cc) {
  p <- GetSwkFC__(get_ptr(cc))
  ## >>> S7-FAST-NEW (RConsortium/S7#723): original
  ## if (is.null(p)) NULL else Ciphertext(ptr = p)
  ## <<< S7-FAST-NEW
  if (is.null(p)) NULL else .fast_new(Ciphertext, p)
}

#' @rdname get_bin_cc_for_scheme_switch
#' @export
set_swk_fc <- function(cc, switching_key) {
  SetSwkFC__(get_ptr(cc), get_ptr(switching_key))
  invisible(cc)
}

.check_key_pair <- function(key_pair, call = rlang::caller_env()) {
  if (!S7::S7_inherits(key_pair, KeyPair)) {
    cli_abort("{.arg key_pair} must be a {.cls KeyPair}.", call = call)
  }
}

# ── CKKS -> FHEW ────────────────────────────────────────

#' Switch a CKKS ciphertext to FHEW ciphertexts
#'
#' Scheme switching takes the values in the slots of a CKKS ciphertext
#' to one FHEW (LWE) ciphertext each, on which Boolean gates, the sign
#' and look-up tables can be evaluated (CKKS with real data and
#' `Feature$SCHEMESWITCH`).
#'
#' `eval_ckks_to_fhew_setup()` creates the FHEW context inside `cc`
#' (read it with [get_bin_cc_for_scheme_switch()]) and returns its
#' secret key. `eval_ckks_to_fhew_key_gen()` generates the keys of the
#' switch. `eval_ckks_to_fhew_precompute()` fixes the scale the values
#' are multiplied by before the switch, normally one over the FHEW
#' plaintext modulus. `eval_ckks_to_fhew()` does the switch.
#'
#' @param cc A CKKS `CryptoContext`.
#' @param schswchparams A [SchSwchParams] object. The setup fills its
#'   CKKS fields from `cc`.
#' @param key_pair The `KeyPair` of the CKKS context.
#' @param lwesk The `LWEPrivateKey` of the FHEW context.
#' @param scale Numeric; the scale. Default `1`.
#' @param ct A `Ciphertext`.
#' @param num_ctxts Integer; the number of slots to switch, `0L`
#'   (default) for all.
#' @return `eval_ckks_to_fhew_setup()`: an `LWEPrivateKey`.
#'   `eval_ckks_to_fhew()`: a list of `LWECiphertext` objects. The
#'   others: `cc`, invisibly.
#' @seealso [eval_fhew_to_ckks()] for the other direction;
#'   [eval_scheme_switching_setup()] for both at once.
#' @export
eval_ckks_to_fhew_setup <- function(cc, schswchparams) {
  ## >>> S7-FAST-NEW (RConsortium/S7#723): original
  ## LWEPrivateKey(ptr = SchemeSwitchSetup__(get_ptr(cc), get_ptr(schswchparams),
  ##                                         FALSE))
  ## <<< S7-FAST-NEW
  .fast_new(LWEPrivateKey, SchemeSwitchSetup__(get_ptr(cc), get_ptr(schswchparams),
                                               FALSE))
}

#' @rdname eval_ckks_to_fhew_setup
#' @export
eval_ckks_to_fhew_key_gen <- function(cc, key_pair, lwesk) {
  .check_key_pair(key_pair)
  EvalCkksToFhewKeyGen__(get_ptr(cc), get_ptr(key_pair@public),
                         get_ptr(key_pair@secret), get_ptr(lwesk))
  invisible(cc)
}

#' @rdname eval_ckks_to_fhew_setup
#' @export
eval_ckks_to_fhew_precompute <- function(cc, scale = 1) {
  EvalCKKStoFHEWPrecompute__(get_ptr(cc), as.double(scale))
  invisible(cc)
}

#' @rdname eval_ckks_to_fhew_setup
#' @export
eval_ckks_to_fhew <- function(ct, num_ctxts = 0L) {
  lapply(EvalCKKStoFHEW__(get_ptr(ct), as.integer(num_ctxts)),
         ## >>> S7-FAST-NEW (RConsortium/S7#723): original
         ## function(p) LWECiphertext(ptr = p))
         ## <<< S7-FAST-NEW
         function(p) .fast_new(LWECiphertext, p))
}

# ── FHEW -> CKKS ────────────────────────────────────────

#' Switch FHEW ciphertexts to a CKKS ciphertext
#'
#' Packs the messages of a list of FHEW (LWE) ciphertexts into the
#' slots of one CKKS ciphertext (CKKS with real data and
#' `Feature$SCHEMESWITCH`).
#'
#' `eval_fhew_to_ckks_setup()` records the FHEW context `cc_lwe` in the
#' CKKS context, and `eval_fhew_to_ckks_key_gen()` generates the keys
#' of the switch.
#'
#' The messages are taken modulo `p`; `pmin` and `pmax` give the range
#' they lie in, which sets the interval of the Chebyshev approximation
#' the switch evaluates. The defaults are for bits.
#'
#' @param cc A CKKS `CryptoContext`.
#' @param cc_lwe The `BinFHEContext` the ciphertexts come from.
#' @param num_slots_ckks,num_slots Integer; number of CKKS slots, `0L`
#'   (default) for the library's choice.
#' @param log_q Integer; bits of the FHEW ciphertext modulus. Default
#'   `25L`.
#' @param key_pair The `KeyPair` of the CKKS context.
#' @param lwesk The `LWEPrivateKey` of the FHEW context.
#' @param num_ctxts Integer; number of ciphertexts to switch, `0L`
#'   (default) for all.
#' @param dim1 Integer; baby-step dimension of the linear transform,
#'   `0L` (default) for the library's choice.
#' @param l Integer; level of the linear transform (the C++ argument
#'   `L`). Default `0L`.
#' @param lwe_ciphertexts A list of `LWECiphertext` objects.
#' @param p Integer; plaintext modulus of the FHEW ciphertexts.
#'   Default `4L`.
#' @param pmin,pmax Numeric; the range of the messages. Defaults `0`
#'   and `2`.
#' @return `eval_fhew_to_ckks()`: a `Ciphertext`. The others: `cc`,
#'   invisibly.
#' @seealso [eval_ckks_to_fhew()]
#' @export
eval_fhew_to_ckks_setup <- function(cc, cc_lwe, num_slots_ckks = 0L,
                                    log_q = 25L) {
  EvalFHEWtoCKKSSetup__(get_ptr(cc), get_ptr(cc_lwe), as.integer(num_slots_ckks),
                        as.integer(log_q))
  invisible(cc)
}

#' @rdname eval_fhew_to_ckks_setup
#' @export
eval_fhew_to_ckks_key_gen <- function(cc, key_pair, lwesk, num_slots = 0L,
                                      num_ctxts = 0L, dim1 = 0L, l = 0L) {
  .check_key_pair(key_pair)
  EvalFhewToCkksKeyGen__(get_ptr(cc), get_ptr(key_pair@public),
                         get_ptr(key_pair@secret), get_ptr(lwesk),
                         as.integer(num_slots), as.integer(num_ctxts),
                         as.integer(dim1), as.integer(l))
  invisible(cc)
}

#' @rdname eval_fhew_to_ckks_setup
#' @export
eval_fhew_to_ckks <- function(cc, lwe_ciphertexts, num_ctxts = 0L,
                              num_slots = 0L, p = 4L, pmin = 0, pmax = 2,
                              dim1 = 0L) {
  if (!is.list(lwe_ciphertexts)) {
    cli_abort("{.arg lwe_ciphertexts} must be a list of {.cls LWECiphertext} objects.")
  }
  ## >>> S7-FAST-NEW (RConsortium/S7#723): original
  ## Ciphertext(ptr = EvalFHEWtoCKKS__(
  ##   get_ptr(cc), lapply(lwe_ciphertexts, get_ptr), as.integer(num_ctxts),
  ##   as.integer(num_slots), as.integer(p), as.double(pmin), as.double(pmax),
  ##   as.integer(dim1)))
  ## <<< S7-FAST-NEW
  .fast_new(Ciphertext, EvalFHEWtoCKKS__(
    get_ptr(cc), lapply(lwe_ciphertexts, get_ptr), as.integer(num_ctxts),
    as.integer(num_slots), as.integer(p), as.double(pmin), as.double(pmax),
    as.integer(dim1)))
}

# ── Both directions ─────────────────────────────────────

#' Comparison, minimum and maximum through scheme switching
#'
#' With switching set up in both directions, a comparison is done by
#' switching CKKS values to FHEW, evaluating the sign there, and
#' switching the result back (CKKS with real data and
#' `Feature$SCHEMESWITCH`).
#'
#' `eval_scheme_switching_setup()` creates the FHEW context inside `cc`
#' and returns its secret key; `eval_scheme_switching_key_gen()`
#' generates the keys for both directions.
#' `eval_compare_switch_precompute()` fixes the FHEW plaintext modulus
#' and the scale of the comparison.
#'
#' `eval_compare_scheme_switching()` returns a ciphertext whose slots
#' hold 1 where `ct1 < ct2` and 0 elsewhere.
#' `eval_min_scheme_switching()` and `eval_max_scheme_switching()`
#' return the minimum or maximum of the first `num_values` slots (a
#' power of two) and its index; set up the context with
#' `set_compute_argmin(params, TRUE)` for them. The index is one-hot
#' encoded over `num_values` slots unless the parameters say
#' otherwise (`set_one_hot_encoding()`). The slots after the first of
#' the value, and after the index, hold no meaningful data. The `_alt`
#' forms use more FHEW operations, for higher precision at a higher
#' cost (`set_use_alt_argmin(params, TRUE)`).
#'
#' @param cc A CKKS `CryptoContext`.
#' @param schswchparams A [SchSwchParams] object. The setup fills its
#'   CKKS fields from `cc`.
#' @param key_pair The `KeyPair` of the CKKS context.
#' @param lwesk The `LWEPrivateKey` of the FHEW context.
#' @param p_lwe Integer; the FHEW plaintext modulus, `0L` (default) for
#'   the library's choice.
#' @param scale_sign Numeric; the scale applied before the sign is
#'   taken. Default `1`.
#' @param unit Logical; whether the input messages are normalized to
#'   the unit circle. Default `FALSE`.
#' @param ct1,ct2,ct `Ciphertext` objects.
#' @param num_ctxts Integer; number of values to compare, `0L`
#'   (default) for all.
#' @param num_slots Integer; number of CKKS slots, `0L` (default) for
#'   the library's choice.
#' @param public_key The `PublicKey` of the CKKS context.
#' @param num_values Integer; number of values to take the minimum or
#'   maximum of, `0L` (default) for all.
#' @return `eval_scheme_switching_setup()`: an `LWEPrivateKey`.
#'   `eval_compare_scheme_switching()`: a `Ciphertext`. The minimum
#'   and maximum functions: a list of two `Ciphertext` objects, the
#'   value and its index. The others: `cc`, invisibly.
#' @seealso [eval_ckks_to_fhew()], [eval_fhew_to_ckks()]
#' @export
eval_scheme_switching_setup <- function(cc, schswchparams) {
  ## >>> S7-FAST-NEW (RConsortium/S7#723): original
  ## LWEPrivateKey(ptr = SchemeSwitchSetup__(get_ptr(cc), get_ptr(schswchparams),
  ##                                         TRUE))
  ## <<< S7-FAST-NEW
  .fast_new(LWEPrivateKey, SchemeSwitchSetup__(get_ptr(cc), get_ptr(schswchparams),
                                               TRUE))
}

#' @rdname eval_scheme_switching_setup
#' @export
eval_scheme_switching_key_gen <- function(cc, key_pair, lwesk) {
  .check_key_pair(key_pair)
  EvalSchemeSwitchingKeyGen__(get_ptr(cc), get_ptr(key_pair@public),
                              get_ptr(key_pair@secret), get_ptr(lwesk))
  invisible(cc)
}

#' @rdname eval_scheme_switching_setup
#' @export
eval_compare_switch_precompute <- function(cc, p_lwe = 0L, scale_sign = 1,
                                           unit = FALSE) {
  EvalCompareSwitchPrecompute__(get_ptr(cc), as.integer(p_lwe),
                                as.double(scale_sign), isTRUE(unit))
  invisible(cc)
}

#' @rdname eval_scheme_switching_setup
#' @export
eval_compare_scheme_switching <- function(ct1, ct2, num_ctxts = 0L,
                                          num_slots = 0L, p_lwe = 0L,
                                          scale_sign = 1, unit = FALSE) {
  ## >>> S7-FAST-NEW (RConsortium/S7#723): original
  ## Ciphertext(ptr = EvalCompareSchemeSwitching__(
  ##   get_ptr(ct1), get_ptr(ct2), as.integer(num_ctxts), as.integer(num_slots),
  ##   as.integer(p_lwe), as.double(scale_sign), isTRUE(unit)))
  ## <<< S7-FAST-NEW
  .fast_new(Ciphertext, EvalCompareSchemeSwitching__(
    get_ptr(ct1), get_ptr(ct2), as.integer(num_ctxts), as.integer(num_slots),
    as.integer(p_lwe), as.double(scale_sign), isTRUE(unit)))
}

.eval_min_max_scheme_switching <- function(which, ct, public_key, num_values,
                                           num_slots, p_lwe, scale_sign) {
  lapply(EvalMinMaxSchemeSwitching__(
    get_ptr(ct), get_ptr(public_key), which, as.integer(num_values),
    as.integer(num_slots), as.integer(p_lwe), as.double(scale_sign)),
    ## >>> S7-FAST-NEW (RConsortium/S7#723): original
    ## function(p) Ciphertext(ptr = p))
    ## <<< S7-FAST-NEW
    function(p) .fast_new(Ciphertext, p))
}

#' @rdname eval_scheme_switching_setup
#' @export
eval_min_scheme_switching <- function(ct, public_key, num_values = 0L,
                                      num_slots = 0L, p_lwe = 0L,
                                      scale_sign = 1) {
  .eval_min_max_scheme_switching(0L, ct, public_key, num_values, num_slots,
                                 p_lwe, scale_sign)
}

#' @rdname eval_scheme_switching_setup
#' @export
eval_min_scheme_switching_alt <- function(ct, public_key, num_values = 0L,
                                          num_slots = 0L, p_lwe = 0L,
                                          scale_sign = 1) {
  .eval_min_max_scheme_switching(1L, ct, public_key, num_values, num_slots,
                                 p_lwe, scale_sign)
}

#' @rdname eval_scheme_switching_setup
#' @export
eval_max_scheme_switching <- function(ct, public_key, num_values = 0L,
                                      num_slots = 0L, p_lwe = 0L,
                                      scale_sign = 1) {
  .eval_min_max_scheme_switching(2L, ct, public_key, num_values, num_slots,
                                 p_lwe, scale_sign)
}

#' @rdname eval_scheme_switching_setup
#' @export
eval_max_scheme_switching_alt <- function(ct, public_key, num_values = 0L,
                                          num_slots = 0L, p_lwe = 0L,
                                          scale_sign = 1) {
  .eval_min_max_scheme_switching(3L, ct, public_key, num_values, num_slots,
                                 p_lwe, scale_sign)
}
