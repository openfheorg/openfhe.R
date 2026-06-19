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

#' Homomorphic addition in place
#'
#' Modifies the first argument in place to hold the result of
#' adding the second argument. Avoids allocating a new Ciphertext,
#' which matters in tight loops or when ciphertext memory
#' footprint is a concern.
#'
#' @param x A `Ciphertext` (modified in place).
#' @param ... Method-specific arguments: `y` — a `Ciphertext`,
#'   `Plaintext`, or numeric scalar to add into `x`.
#' @return `x` invisibly.
#' @export
eval_add_in_place <- new_generic("eval_add_in_place", "x")

method(eval_add_in_place, Ciphertext) <- function(x, y) {
  if (S7::S7_inherits(y, Ciphertext)) {
    EvalAddInPlace__ct_ct(x@ptr, y@ptr)
  } else if (S7::S7_inherits(y, Plaintext)) {
    EvalAddInPlace__ct_pt(x@ptr, y@ptr)
  } else if (is.numeric(y) && length(y) == 1L) {
    EvalAddInPlace__ct_scalar(x@ptr, as.double(y))
  } else {
    cli::cli_abort(
      "{.arg y} must be a Ciphertext, Plaintext, or numeric scalar.")
  }
  invisible(x)
}

#' Homomorphic subtraction in place
#'
#' Modifies the first argument in place to hold the result of
#' subtracting the second argument.
#'
#' @param x A `Ciphertext` (modified in place).
#' @param ... Method-specific arguments: `y` — a `Ciphertext`,
#'   `Plaintext`, or numeric scalar to subtract from `x`.
#' @return `x` invisibly.
#' @export
eval_sub_in_place <- new_generic("eval_sub_in_place", "x")

method(eval_sub_in_place, Ciphertext) <- function(x, y) {
  if (S7::S7_inherits(y, Ciphertext)) {
    EvalSubInPlace__ct_ct(x@ptr, y@ptr)
  } else if (S7::S7_inherits(y, Plaintext)) {
    EvalSubInPlace__ct_pt(x@ptr, y@ptr)
  } else if (is.numeric(y) && length(y) == 1L) {
    EvalSubInPlace__ct_scalar(x@ptr, as.double(y))
  } else {
    cli::cli_abort(
      "{.arg y} must be a Ciphertext, Plaintext, or numeric scalar.")
  }
  invisible(x)
}

#' Homomorphic multiplication in place
#'
#' Modifies the first argument in place to hold the result of
#' multiplying by a numeric scalar. `CryptoContextImpl` only
#' declares `EvalMultInPlace` scalar overloads in the v1.5.1.0
#' header surface — the ct/ct and ct/pt variants that
#' upstream-defects P1 refers to live on `SchemeBase` and are not
#' exposed on `CryptoContextImpl`, so R's `eval_mult_in_place`
#' supports only the scalar case. The ct/ct multiplication
#' continues to work via the non-in-place [eval_mult()] generic.
#'
#' @param x A `Ciphertext` (modified in place).
#' @param ... Method-specific arguments: `y` — a numeric scalar
#'   to multiply `x` by.
#' @return `x` invisibly.
#' @export
eval_mult_in_place <- new_generic("eval_mult_in_place", "x")

method(eval_mult_in_place, Ciphertext) <- function(x, y) {
  if (!is.numeric(y) || length(y) != 1L) {
    cli::cli_abort(
      "{.arg y} must be a numeric scalar (ct/ct in-place multiplication is not available in the upstream header).")
  }
  EvalMultInPlace__ct_scalar(x@ptr, as.double(y))
  invisible(x)
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
#' @param x A `Ciphertext` (may be modified internally).
#' @param ... Method-specific arguments: `y` — a `Ciphertext`
#'   (may be modified internally).
#' @return A new `Ciphertext` holding `x + y`.
#' @export
eval_add_mutable <- new_generic("eval_add_mutable", "x")

method(eval_add_mutable, Ciphertext) <- function(x, y) {
  Ciphertext(ptr = EvalAddMutable__ct_ct(x@ptr, y@ptr))
}

#' Homomorphic subtract, mutable variant
#'
#' @param x A `Ciphertext` (may be modified internally).
#' @param ... Method-specific arguments: `y` — a `Ciphertext`
#'   (may be modified internally).
#' @return A new `Ciphertext` holding `x - y`.
#' @export
eval_sub_mutable <- new_generic("eval_sub_mutable", "x")

method(eval_sub_mutable, Ciphertext) <- function(x, y) {
  Ciphertext(ptr = EvalSubMutable__ct_ct(x@ptr, y@ptr))
}

#' Homomorphic multiply, mutable variant
#'
#' @param x A `Ciphertext` (may be modified internally).
#' @param ... Method-specific arguments: `y` — a `Ciphertext`
#'   (may be modified internally).
#' @return A new `Ciphertext` holding `x * y`.
#' @export
eval_mult_mutable <- new_generic("eval_mult_mutable", "x")

method(eval_mult_mutable, Ciphertext) <- function(x, y) {
  Ciphertext(ptr = EvalMultMutable__ct_ct(x@ptr, y@ptr))
}

#' Homomorphic square, mutable variant
#'
#' @param x A `Ciphertext` (may be modified internally).
#' @param ... Reserved for future method-specific arguments.
#' @return A new `Ciphertext` holding `x * x`.
#' @export
eval_square_mutable <- new_generic("eval_square_mutable", "x")

method(eval_square_mutable, Ciphertext) <- function(x) {
  Ciphertext(ptr = EvalSquareMutable__ct(x@ptr))
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
  Ciphertext(ptr = EvalMultNoRelin__ct_ct(x@ptr, y@ptr))
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
  Ciphertext(ptr = Relinearize__ct(x@ptr))
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
  Ciphertext(ptr = EvalMultAndRelinearize__ct_ct(x@ptr, y@ptr))
}

# ── Mod/level reduce + compress ─────────────────────────

#' Reduce the modulus chain by one level
#'
#' Synonym for [rescale()]. Both names dispatch to the same C++
#' operation (`CryptoContextImpl::Rescale` delegates to
#' `ModReduce` internally); the R binding keeps both so fixture
#' and vignette authors can use whichever name matches the
#' OpenFHE documentation they're following.
#'
#' @param x A `Ciphertext`.
#' @param ... Reserved for future method-specific arguments.
#' @return A `Ciphertext` at one lower level.
#' @seealso [rescale()], [mod_reduce_in_place()]
#' @export
mod_reduce <- new_generic("mod_reduce", "x")

method(mod_reduce, Ciphertext) <- function(x) {
  Ciphertext(ptr = ModReduce__ct(x@ptr))
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
#' An evaluation key is required — supply it from
#' `key_gen(cc, eval_mult = TRUE)`.
#'
#' @param x A `Ciphertext`.
#' @param ... Method-specific arguments: `eval_key` (an `EvalKey`
#'   from `key_gen`), `levels` (integer, default `1L`).
#' @return A `Ciphertext` at `x$level + levels`.
#' @export
level_reduce <- new_generic("level_reduce", "x")

method(level_reduce, Ciphertext) <- function(x, eval_key, levels = 1L) {
  Ciphertext(ptr = LevelReduce__ct(x@ptr, eval_key@ptr, as.integer(levels)))
}

#' Reduce the modulus chain by multiple levels, in place
#'
#' @param x A `Ciphertext` (modified in place).
#' @param ... Method-specific arguments: `eval_key` (an `EvalKey`),
#'   `levels` (integer, default `1L`).
#' @return `x` invisibly.
#' @export
level_reduce_in_place <- new_generic("level_reduce_in_place", "x")

method(level_reduce_in_place, Ciphertext) <- function(x, eval_key, levels = 1L) {
  LevelReduceInPlace__ct(x@ptr, eval_key@ptr, as.integer(levels))
  invisible(x)
}

#' Compress a ciphertext to fewer towers
#'
#' Truncates the ciphertext's RNS modulus representation to
#' `towers_left` towers and sets its noise-scale-degree to
#' `noise_scale_deg`. Used by the interactive multi-party
#' bootstrapping protocol to shrink a ciphertext before sending
#' it across the network (see `notes/blocks/E-bindings-rewrite/
#' gap-matrix.md` §21 for the bootstrap-side context).
#'
#' @param x A `Ciphertext`.
#' @param ... Method-specific arguments: `towers_left` (integer,
#'   target tower count), `noise_scale_deg` (integer, default
#'   `1L`).
#' @return A compressed `Ciphertext`.
#' @export
compress <- new_generic("compress", "x")

method(compress, Ciphertext) <- function(x, towers_left, noise_scale_deg = 1L) {
  Ciphertext(ptr = Compress__ct(x@ptr,
                                 as.integer(towers_left),
                                 as.integer(noise_scale_deg)))
}
