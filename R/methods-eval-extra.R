## OPENFHE PYTHON SOURCE: src/lib/bindings.cpp (Eval* arg completion)
##
## The Eval* argument-completion
## surface. 16 new S7 generics covering:
##   - In-place family (4 generics, 8 cpp11 bindings):
##     eval_add_in_place, eval_sub_in_place, eval_mult_in_place,
##     eval_negate_in_place
##   - Mutable family (4):
##     eval_add_mutable, eval_sub_mutable, eval_mult_mutable,
##     eval_square_mutable
##   - No-relin + relinearize (3):
##     eval_mult_no_relin, relinearize, eval_mult_and_relinearize
##   - Mod/level reduce + compress (5):
##     mod_reduce, mod_reduce_in_place, level_reduce,
##     level_reduce_in_place, compress

# ── In-place family ─────────────────────────────────────

## One scalar operand of an in-place operation: a single real or
## complex number. Returns TRUE for complex. `also` names the other
## operand types the caller accepts, for the error message.
.arith_scalar_is_complex <- function(s, arg, also = "") {
  if (length(s) == 1L && !is.object(s) && !is.na(s)) {
    if (is.complex(s)) return(TRUE)
    if (is.numeric(s)) return(FALSE)
  }
  cli_abort("{.arg {arg}} must be {also}a single real or complex number.",
            call = rlang::caller_env(2L))
}

## In-place operation of a ciphertext with a scalar, in either order.
.arith_in_place_scalar <- function(op, ct, s, scalar_first, arg, also = "") {
  if (.arith_scalar_is_complex(s, arg, also)) {
    EvalArithInPlace__complex(op, ct@ptr, Re(s), Im(s), scalar_first)
  } else {
    EvalArithInPlace__real(op, ct@ptr, as.double(s), scalar_first)
  }
  invisible(ct)
}

## Second operand of an in-place operation whose first operand is a
## plaintext or a scalar: it must be the ciphertext.
.arith_need_ciphertext <- function(y) {
  if (!S7::S7_inherits(y, Ciphertext)) {
    cli_abort("{.arg y} must be a {.cls Ciphertext} when {.arg x} is not one.",
              call = rlang::caller_env())
  }
}

#' Homomorphic addition in place
#'
#' Stores the sum of the two operands in the ciphertext operand,
#' without allocating a new `Ciphertext`. One operand is a
#' `Ciphertext`; the other is a `Ciphertext`, a `Plaintext`, or a
#' single real or complex number (CKKS). The operands may be given in
#' either order, as in the C++ library. When both are ciphertexts
#' the first one receives the result.
#'
#' @param x A `Ciphertext`, a `Plaintext`, or a single real or complex
#'   number.
#' @param ... Method-specific arguments: `y`, the other operand.
#' @return The modified `Ciphertext`, invisibly.
#' @export
eval_add_in_place <- new_generic("eval_add_in_place", "x")

method(eval_add_in_place, Ciphertext) <- function(x, y) {
  if (S7::S7_inherits(y, Ciphertext)) {
    EvalAddInPlace__ct_ct(x@ptr, y@ptr)
  } else if (S7::S7_inherits(y, Plaintext)) {
    EvalAddInPlace__ct_pt(x@ptr, y@ptr)
  } else {
    .arith_in_place_scalar(.ARITH_ADD, x, y, FALSE, "y",
                           "a Ciphertext, a Plaintext, or ")
  }
  invisible(x)
}

method(eval_add_in_place, Plaintext) <- function(x, y) {
  .arith_need_ciphertext(y)
  EvalArithInPlace__pt_ct(.ARITH_ADD, x@ptr, y@ptr)
  invisible(y)
}

method(eval_add_in_place, S7::class_numeric | S7::class_complex) <- function(x, y) {
  .arith_need_ciphertext(y)
  .arith_in_place_scalar(.ARITH_ADD, y, x, TRUE, "x")
}

#' Homomorphic subtraction in place
#'
#' Stores `x - y` in the ciphertext operand. One operand is a
#' `Ciphertext`; the other is a `Ciphertext`, a `Plaintext`, or a
#' single real or complex number (CKKS). The operands may be given in
#' either order, and the result is always `x - y`: with
#' `eval_sub_in_place(2, ct)` the ciphertext becomes `2 - ct`.
#'
#' @param x A `Ciphertext`, a `Plaintext`, or a single real or complex
#'   number.
#' @param ... Method-specific arguments: `y`, the other operand.
#' @return The modified `Ciphertext`, invisibly.
#' @export
eval_sub_in_place <- new_generic("eval_sub_in_place", "x")

method(eval_sub_in_place, Ciphertext) <- function(x, y) {
  if (S7::S7_inherits(y, Ciphertext)) {
    EvalSubInPlace__ct_ct(x@ptr, y@ptr)
  } else if (S7::S7_inherits(y, Plaintext)) {
    EvalSubInPlace__ct_pt(x@ptr, y@ptr)
  } else {
    .arith_in_place_scalar(.ARITH_SUB, x, y, FALSE, "y",
                           "a Ciphertext, a Plaintext, or ")
  }
  invisible(x)
}

method(eval_sub_in_place, Plaintext) <- function(x, y) {
  .arith_need_ciphertext(y)
  EvalArithInPlace__pt_ct(.ARITH_SUB, x@ptr, y@ptr)
  invisible(y)
}

method(eval_sub_in_place, S7::class_numeric | S7::class_complex) <- function(x, y) {
  .arith_need_ciphertext(y)
  .arith_in_place_scalar(.ARITH_SUB, y, x, TRUE, "x")
}

#' Homomorphic multiplication by a number, in place
#'
#' Multiplies a ciphertext by a single real or complex number (CKKS)
#' and stores the result in the ciphertext. The operands may be given
#' in either order. OpenFHE declares no in-place product of two
#' ciphertexts or of a ciphertext and a plaintext on the
#' `CryptoContext`; use [eval_mult()] for those.
#'
#' @param x A `Ciphertext`, or a single real or complex number.
#' @param ... Method-specific arguments: `y`, the other operand.
#' @return The modified `Ciphertext`, invisibly.
#' @export
eval_mult_in_place <- new_generic("eval_mult_in_place", "x")

method(eval_mult_in_place, Ciphertext) <- function(x, y) {
  .arith_in_place_scalar(.ARITH_MULT, x, y, FALSE, "y")
}

method(eval_mult_in_place, S7::class_numeric | S7::class_complex) <- function(x, y) {
  .arith_need_ciphertext(y)
  .arith_in_place_scalar(.ARITH_MULT, y, x, TRUE, "x")
}

#' Homomorphic negation in place
#'
#' @param x A `Ciphertext` (modified in place).
#' @param ... Reserved for future method-specific arguments.
#' @return `x` invisibly.
#' @export
eval_negate_in_place <- new_generic("eval_negate_in_place", "x")

method(eval_negate_in_place, Ciphertext) <- function(x) {
  EvalNegateInPlace__ct(x@ptr)
  invisible(x)
}

# ── Mutable family ──────────────────────────────────────

#' Homomorphic add, mutable variant
#'
#' The Mutable* family exists so that operations that can safely
#' mutate their inputs during evaluation (e.g. a temporary
#' intermediate in a longer circuit) can do so without forcing a
#' defensive copy. Semantically equivalent to the non-Mutable
#' counterpart from the user's perspective; the difference is
#' performance under specific workloads.
#'
#' @param x A `Ciphertext` or a `Plaintext` (may be modified
#'   internally).
#' @param ... Method-specific arguments: `y`, a `Ciphertext` or a
#'   `Plaintext` (may be modified internally). At least one of `x`
#'   and `y` is a `Ciphertext`.
#' @return A new `Ciphertext` holding `x + y`.
#' @export
eval_add_mutable <- new_generic("eval_add_mutable", "x")

## Shared body of the Mutable family: (ct, ct), (ct, pt), (pt, ct).
.arith_mutable <- function(op, ct_ct, x, y) {
  x_ct <- S7::S7_inherits(x, Ciphertext)
  if (x_ct && S7::S7_inherits(y, Ciphertext)) {
    ## >>> S7-FAST-NEW (RConsortium/S7#723): original
    ## Ciphertext(ptr = ct_ct(x@ptr, y@ptr))
    ## <<< S7-FAST-NEW
    .fast_new(Ciphertext, ct_ct(x@ptr, y@ptr))
  } else if (x_ct && S7::S7_inherits(y, Plaintext)) {
    ## >>> S7-FAST-NEW (RConsortium/S7#723): original
    ## Ciphertext(ptr = EvalArithMutable__pt(op, x@ptr, y@ptr, FALSE))
    ## <<< S7-FAST-NEW
    .fast_new(Ciphertext, EvalArithMutable__pt(op, x@ptr, y@ptr, FALSE))
  } else if (!x_ct && S7::S7_inherits(y, Ciphertext)) {
    ## >>> S7-FAST-NEW (RConsortium/S7#723): original
    ## Ciphertext(ptr = EvalArithMutable__pt(op, y@ptr, x@ptr, TRUE))
    ## <<< S7-FAST-NEW
    .fast_new(Ciphertext, EvalArithMutable__pt(op, y@ptr, x@ptr, TRUE))
  } else {
    cli_abort(
      "{.arg x} and {.arg y} must be two ciphertexts, or a {.cls Ciphertext} and a {.cls Plaintext}.",
      call = rlang::caller_env())
  }
}

method(eval_add_mutable, Ciphertext | Plaintext) <- function(x, y) {
  .arith_mutable(.ARITH_ADD, EvalAddMutable__ct_ct, x, y)
}

#' Homomorphic subtract, mutable variant
#'
#' @param x A `Ciphertext` or a `Plaintext` (may be modified
#'   internally).
#' @param ... Method-specific arguments: `y`, a `Ciphertext` or a
#'   `Plaintext` (may be modified internally). At least one of `x`
#'   and `y` is a `Ciphertext`.
#' @return A new `Ciphertext` holding `x - y`.
#' @export
eval_sub_mutable <- new_generic("eval_sub_mutable", "x")

method(eval_sub_mutable, Ciphertext | Plaintext) <- function(x, y) {
  .arith_mutable(.ARITH_SUB, EvalSubMutable__ct_ct, x, y)
}

#' Homomorphic multiply, mutable variant
#'
#' @param x A `Ciphertext` or a `Plaintext` (may be modified
#'   internally).
#' @param ... Method-specific arguments: `y`, a `Ciphertext` or a
#'   `Plaintext` (may be modified internally). At least one of `x`
#'   and `y` is a `Ciphertext`.
#' @return A new `Ciphertext` holding `x * y`.
#' @export
eval_mult_mutable <- new_generic("eval_mult_mutable", "x")

method(eval_mult_mutable, Ciphertext | Plaintext) <- function(x, y) {
  .arith_mutable(.ARITH_MULT, EvalMultMutable__ct_ct, x, y)
}

#' Homomorphic square, mutable variant
#'
#' @param x A `Ciphertext` (may be modified internally).
#' @param ... Reserved for future method-specific arguments.
#' @return A new `Ciphertext` holding `x * x`.
#' @export
eval_square_mutable <- new_generic("eval_square_mutable", "x")

method(eval_square_mutable, Ciphertext) <- function(x) {
  ## >>> S7-FAST-NEW (RConsortium/S7#723): original
  ## Ciphertext(ptr = EvalSquareMutable__ct(x@ptr))
  ## <<< S7-FAST-NEW
  .fast_new(Ciphertext, EvalSquareMutable__ct(x@ptr))
}

# ── No-relin + relinearize ──────────────────────────────

#' Homomorphic multiplication without relinearization
#'
#' Returns the raw product of two ciphertexts as a higher-degree
#' ciphertext (the result has `n1 + n2 - 1` polynomial components
#' where the inputs had `n1` and `n2`). The standard `eval_mult()`
#' automatically relinearizes the result back to 2 components;
#' this variant skips the relinearization step so that multiple
#' multiplications can be chained at higher polynomial degree
#' before a single `relinearize()` call at the end. Used by the
#' `EvalMultAndRelinearize` fused variant and by
#' `EvalPolyWithPrecomp` for noise-optimal polynomial evaluation.
#'
#' @param x A `Ciphertext`.
#' @param ... Method-specific arguments: `y` — a `Ciphertext` to
#'   multiply `x` by without relinearization.
#' @return A `Ciphertext` at higher polynomial degree.
#' @export
eval_mult_no_relin <- new_generic("eval_mult_no_relin", "x")

method(eval_mult_no_relin, Ciphertext) <- function(x, y) {
  ## >>> S7-FAST-NEW (RConsortium/S7#723): original
  ## Ciphertext(ptr = EvalMultNoRelin__ct_ct(x@ptr, y@ptr))
  ## <<< S7-FAST-NEW
  .fast_new(Ciphertext, EvalMultNoRelin__ct_ct(x@ptr, y@ptr))
}

#' Relinearize a higher-degree ciphertext
#'
#' Reduces a ciphertext to 2 polynomial components. Needed after a
#' sequence of `eval_mult_no_relin()` calls to restore a
#' decryptable form. A relinearization key must have been
#' generated via `key_gen(cc, eval_mult = TRUE)` before calling
#' this.
#'
#' @param x A `Ciphertext` (may have more than 2 components).
#' @param ... Reserved for future method-specific arguments.
#' @return A `Ciphertext` with exactly 2 components.
#' @export
relinearize <- new_generic("relinearize", "x")

method(relinearize, Ciphertext) <- function(x) {
  ## >>> S7-FAST-NEW (RConsortium/S7#723): original
  ## Ciphertext(ptr = Relinearize__ct(x@ptr))
  ## <<< S7-FAST-NEW
  .fast_new(Ciphertext, Relinearize__ct(x@ptr))
}

#' Fused multiply-and-relinearize
#'
#' Equivalent to `relinearize(eval_mult_no_relin(x, y))` but
#' slightly more efficient in OpenFHE's implementation. Use this
#' at the end of a multiplication chain.
#'
#' @param x A `Ciphertext`.
#' @param ... Method-specific arguments: `y` — a `Ciphertext` to
#'   multiply `x` by in a fused multiply-and-relinearize step.
#' @return A relinearized `Ciphertext`.
#' @export
eval_mult_and_relinearize <- new_generic("eval_mult_and_relinearize", "x")

method(eval_mult_and_relinearize, Ciphertext) <- function(x, y) {
  ## >>> S7-FAST-NEW (RConsortium/S7#723): original
  ## Ciphertext(ptr = EvalMultAndRelinearize__ct_ct(x@ptr, y@ptr))
  ## <<< S7-FAST-NEW
  .fast_new(Ciphertext, EvalMultAndRelinearize__ct_ct(x@ptr, y@ptr))
}

# ── Mod/level reduce + compress ─────────────────────────

#' Reduce the modulus chain by one level
#'
#' Synonym for [rescale()]. Both names dispatch to the same C++
#' operation (`CryptoContextImpl::Rescale` delegates to
#' `ModReduce` internally); the R binding keeps both so callers
#' can use whichever name matches the OpenFHE documentation
#' they're following.
#'
#' @param x A `Ciphertext`.
#' @param ... Reserved for future method-specific arguments.
#' @return A `Ciphertext` at one lower level.
#' @seealso [rescale()], [mod_reduce_in_place()]
#' @export
mod_reduce <- new_generic("mod_reduce", "x")

method(mod_reduce, Ciphertext) <- function(x) {
  ## >>> S7-FAST-NEW (RConsortium/S7#723): original
  ## Ciphertext(ptr = ModReduce__ct(x@ptr))
  ## <<< S7-FAST-NEW
  .fast_new(Ciphertext, ModReduce__ct(x@ptr))
}

#' Reduce the modulus chain by one level, in place
#'
#' @param x A `Ciphertext` (modified in place).
#' @param ... Reserved for future method-specific arguments.
#' @return `x` invisibly.
#' @export
mod_reduce_in_place <- new_generic("mod_reduce_in_place", "x")

method(mod_reduce_in_place, Ciphertext) <- function(x) {
  ModReduceInPlace__ct(x@ptr)
  invisible(x)
}

#' Reduce the modulus chain by multiple levels
#'
#' Drops `levels` levels from `x`'s modulus chain in a single
#' operation. Useful when `x` is at a deeper level than the
#' ciphertext it will interact with next; level-reducing brings
#' them onto the same rung of the chain.
#'
#' The C++ signature takes an evaluation key, which the RNS schemes
#' do not use. Pass `NULL`, as the OpenFHE examples pass a null key,
#' or an `EvalKey`.
#'
#' @param x A `Ciphertext`.
#' @param ... Method-specific arguments: `eval_key` (an `EvalKey`, or
#'   `NULL` for no key), `levels` (integer, default `1L`).
#' @return A `Ciphertext` at `x$level + levels`.
#' @export
level_reduce <- new_generic("level_reduce", "x")

## An EvalKey handle, or NULL for the C++ null key.
.eval_key_or_null <- function(eval_key) {
  if (is.null(eval_key)) NULL else get_ptr(eval_key)
}

method(level_reduce, Ciphertext) <- function(x, eval_key, levels = 1L) {
  ## >>> S7-FAST-NEW (RConsortium/S7#723): original
  ## Ciphertext(ptr = LevelReduce__ct(x@ptr, .eval_key_or_null(eval_key),
  ##                                  as.integer(levels)))
  ## <<< S7-FAST-NEW
  .fast_new(Ciphertext, LevelReduce__ct(x@ptr, .eval_key_or_null(eval_key),
                                        as.integer(levels)))
}

#' Reduce the modulus chain by multiple levels, in place
#'
#' @param x A `Ciphertext` (modified in place).
#' @param ... Method-specific arguments: `eval_key` (an `EvalKey`, or
#'   `NULL` for no key), `levels` (integer, default `1L`).
#' @return `x` invisibly.
#' @export
level_reduce_in_place <- new_generic("level_reduce_in_place", "x")

method(level_reduce_in_place, Ciphertext) <- function(x, eval_key, levels = 1L) {
  LevelReduceInPlace__ct(x@ptr, .eval_key_or_null(eval_key),
                         as.integer(levels))
  invisible(x)
}

#' Compress a ciphertext to fewer towers
#'
#' Truncates the ciphertext's RNS modulus representation to
#' `towers_left` towers and sets its noise-scale-degree to
#' `noise_scale_deg`. Used by the interactive multi-party
#' bootstrapping protocol to shrink a ciphertext before sending
#' it across the network.
#'
#' @param x A `Ciphertext`.
#' @param ... Method-specific arguments: `towers_left` (integer,
#'   target tower count, default `1L`), `noise_scale_deg` (integer,
#'   default `1L`).
#' @return A compressed `Ciphertext`.
#' @export
compress <- new_generic("compress", "x")

method(compress, Ciphertext) <- function(x, towers_left = 1L, noise_scale_deg = 1L) {
  ## >>> S7-FAST-NEW (RConsortium/S7#723): original
  ## Ciphertext(ptr = Compress__ct(x@ptr,
  ##                                as.integer(towers_left),
  ##                                as.integer(noise_scale_deg)))
  ## <<< S7-FAST-NEW
  .fast_new(Ciphertext, Compress__ct(x@ptr,
                                      as.integer(towers_left),
                                      as.integer(noise_scale_deg)))
}
