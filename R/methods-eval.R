## OPENFHE PYTHON SOURCE: src/lib/bindings.cpp (EvalAdd/Sub/Mult/Negate/Rotate/Sum)
## S7 method registrations for arithmetic generics

# ── eval_add ─────────────────────────────────────────────
method(eval_add, list(Ciphertext, Ciphertext)) <- function(x, y) {
  Ciphertext(ptr = EvalAdd__ct_ct(x@ptr, y@ptr))
}

method(eval_add, list(Ciphertext, Plaintext)) <- function(x, y) {
  Ciphertext(ptr = EvalAdd__ct_pt(x@ptr, y@ptr))
}

method(eval_add, list(Ciphertext, S7::class_double)) <- function(x, y) {
  Ciphertext(ptr = EvalAdd__ct_scalar(x@ptr, y))
}

method(eval_add, list(S7::class_double, Ciphertext)) <- function(x, y) {
  Ciphertext(ptr = EvalAdd__ct_scalar(y@ptr, x))
}

method(eval_add, list(Ciphertext, S7::class_integer)) <- function(x, y) {
  Ciphertext(ptr = EvalAdd__ct_int(x@ptr, y))
}

method(eval_add, list(S7::class_integer, Ciphertext)) <- function(x, y) {
  Ciphertext(ptr = EvalAdd__ct_int(y@ptr, x))
}

# ── eval_sub ─────────────────────────────────────────────
method(eval_sub, list(Ciphertext, Ciphertext)) <- function(x, y) {
  Ciphertext(ptr = EvalSub__ct_ct(x@ptr, y@ptr))
}

method(eval_sub, list(Ciphertext, Plaintext)) <- function(x, y) {
  Ciphertext(ptr = EvalSub__ct_pt(x@ptr, y@ptr))
}

method(eval_sub, list(Ciphertext, S7::class_double)) <- function(x, y) {
  Ciphertext(ptr = EvalSub__ct_scalar(x@ptr, y))
}

method(eval_sub, list(S7::class_double, Ciphertext)) <- function(x, y) {
  Ciphertext(ptr = EvalNegate(EvalSub__ct_scalar(y@ptr, x)))
}

method(eval_sub, list(Ciphertext, S7::class_integer)) <- function(x, y) {
  Ciphertext(ptr = EvalSub__ct_int(x@ptr, y))
}

method(eval_sub, list(S7::class_integer, Ciphertext)) <- function(x, y) {
  Ciphertext(ptr = EvalNegate(EvalSub__ct_int(y@ptr, x)))
}

# ── eval_mult ────────────────────────────────────────────
method(eval_mult, list(Ciphertext, Ciphertext)) <- function(x, y) {
  Ciphertext(ptr = EvalMult__ct_ct(x@ptr, y@ptr))
}

method(eval_mult, list(Ciphertext, Plaintext)) <- function(x, y) {
  Ciphertext(ptr = EvalMult__ct_pt(x@ptr, y@ptr))
}

method(eval_mult, list(Plaintext, Ciphertext)) <- function(x, y) {
  Ciphertext(ptr = EvalMult__ct_pt(y@ptr, x@ptr))
}

method(eval_mult, list(Ciphertext, S7::class_double)) <- function(x, y) {
  Ciphertext(ptr = EvalMult__ct_scalar(x@ptr, y))
}

method(eval_mult, list(S7::class_double, Ciphertext)) <- function(x, y) {
  Ciphertext(ptr = EvalMult__ct_scalar(y@ptr, x))
}

method(eval_mult, list(Ciphertext, S7::class_integer)) <- function(x, y) {
  Ciphertext(ptr = EvalMult__ct_int(x@ptr, y))
}

method(eval_mult, list(S7::class_integer, Ciphertext)) <- function(x, y) {
  Ciphertext(ptr = EvalMult__ct_int(y@ptr, x))
}

# ── eval_negate ──────────────────────────────────────────
method(eval_negate, Ciphertext) <- function(x) {
  Ciphertext(ptr = EvalNegate(x@ptr))
}

# ── eval_square ──────────────────────────────────────────
method(eval_square, Ciphertext) <- function(x) {
  Ciphertext(ptr = EvalSquare(x@ptr))
}

#' Rotate ciphertext slots
#' @param ct A Ciphertext
#' @param ... Method-specific arguments (index)
#' @return A Ciphertext
#' @export
eval_rotate <- new_generic("eval_rotate", "ct")

method(eval_rotate, Ciphertext) <- function(ct, index) {
  Ciphertext(ptr = EvalRotate(ct@ptr, as.integer(index)))
}

#' Sum all slots in a ciphertext
#' @param ct A Ciphertext
#' @param ... Method-specific arguments (batch_size)
#' @return A Ciphertext
#' @export
eval_sum <- new_generic("eval_sum", "ct")

method(eval_sum, Ciphertext) <- function(ct, batch_size) {
  Ciphertext(ptr = EvalSum(ct@ptr, as.integer(batch_size)))
}

#' Rescale a CKKS ciphertext (alias for ModReduce)
#'
#' Reduces the modulus chain by one level. Required after `eval_mult`
#' under `FIXEDMANUAL` scaling; automatic under `FIXEDAUTO` /
#' `FLEXIBLEAUTO`.
#'
#' @param ct A Ciphertext
#' @param ... Reserved for future method-specific arguments
#' @return A Ciphertext at one lower level
#' @export
rescale <- new_generic("rescale", "ct")

method(rescale, Ciphertext) <- function(ct) {
  Ciphertext(ptr = Rescale(ct@ptr))
}

#' Precomputed digit decomposition for hoisted rotations
#'
#' Returned by `eval_fast_rotation_precompute()` and consumed by
#' `eval_fast_rotation()`. Hoisting amortizes the per-rotation
#' decomposition over many rotations of the same source ciphertext.
#'
#' @param ptr External pointer (internal use)
#' @export
FastRotationPrecomputation <- new_class("FastRotationPrecomputation",
  parent = OpenFHEObject,
  package = "openfhe.R"
)

method(print, FastRotationPrecomputation) <- function(x, ...) {
  cli::cli_text("{.cls FastRotationPrecomputation} [{if (ptr_is_valid(x)) 'active' else 'null'}]")
  invisible(x)
}

#' Precompute digit decomposition for hoisted fast rotations
#'
#' Computes the digit decomposition of a ciphertext once so that
#' multiple `eval_fast_rotation()` calls against the same ciphertext
#' avoid redoing it. The cyclotomic order `m` (typically `2 * N`,
#' where `N` is the ring dimension) is required by `eval_fast_rotation()`.
#'
#' @param ct A Ciphertext
#' @param ... Reserved for future method-specific arguments
#' @return A FastRotationPrecomputation
#' @export
eval_fast_rotation_precompute <- new_generic("eval_fast_rotation_precompute", "ct")

method(eval_fast_rotation_precompute, Ciphertext) <- function(ct) {
  FastRotationPrecomputation(ptr = EvalFastRotationPrecompute(ct@ptr))
}

#' Hoisted slot rotation using precomputed digits
#'
#' @param ct A Ciphertext
#' @param ... Method-specific arguments: `index` (rotation amount,
#'   positive = left, negative = right), `m` (cyclotomic order,
#'   typically `2 * ring_dimension(ctx)`), `precomp` (a
#'   FastRotationPrecomputation from `eval_fast_rotation_precompute()`)
#' @return A Ciphertext
#' @export
eval_fast_rotation <- new_generic("eval_fast_rotation", "ct")

method(eval_fast_rotation, Ciphertext) <- function(ct, index, m = NULL, precomp) {
  ## `m` is optional. When NULL, route
  ## to the 3-arg header convenience overload (cryptocontext.h
  ## line 2395) that internally sets `m = GetRingDimension() * 2`.
  ## When supplied, route to the 4-arg form (header line 2362)
  ## that takes `m` explicitly. Closes design.md §11 open
  ## question #1: the Python 3-arg binding is NOT an upstream
  ## defect — the C++ header declares both overloads.
  if (is.null(m)) {
    Ciphertext(ptr = EvalFastRotation__3arg(ct@ptr, as.integer(index),
                                            precomp@ptr))
  } else {
    Ciphertext(ptr = EvalFastRotation(ct@ptr, as.integer(index),
                                      as.numeric(m), precomp@ptr))
  }
}

#' Extended hoisted slot rotation
#'
#' Applies a rotation using precomputed digit decomposition
#' like [eval_fast_rotation()], but with the extension that the
#' first digit of the decomposition can be folded into the
#' output before the rotation is applied (controlled by
#' `add_first`). Used inside the CKKS bootstrap fast-rotation
#' inner loop per `openfhe-development`'s
#' `scheme/base-scheme.cpp`. The eval-key map is pulled from
#' the `CryptoContext` internal registry via the ciphertext's
#' key tag, so there is no `EvalKeyMap` argument at the R
#' boundary — the automorphism keys must already be resident
#' on the cc (call `key_gen(cc, rotations = ...)` to populate
#' them, then reuse the `ct` here).
#'
#' @param ct A `Ciphertext`.
#' @param ... Method-specific arguments: `index` (rotation
#'   amount, positive = left, negative = right), `precomp`
#'   (a `FastRotationPrecomputation` from
#'   [eval_fast_rotation_precompute()]), `add_first` (logical,
#'   default `FALSE`).
#' @return A `Ciphertext`.
#' @seealso [eval_fast_rotation()]
#' @export
eval_fast_rotation_ext <- new_generic("eval_fast_rotation_ext", "ct")

method(eval_fast_rotation_ext, Ciphertext) <- function(ct, index, precomp,
                                                       add_first = FALSE) {
  Ciphertext(ptr = EvalFastRotationExt__(ct@ptr, as.integer(index),
                                         precomp@ptr,
                                         as.logical(add_first)))
}

#' Get the CKKS bootstrap correction factor
#'
#' Reads the current correction factor the scheme uses during
#' the bootstrap `EvalModReduceInternal` step. Companion of
#' [set_ckks_boot_correction_factor()]. Changes here affect
#' all subsequent bootstrap operations on this `CryptoContext`
#' until another call to [set_ckks_boot_correction_factor()].
#'
#' @param cc A `CryptoContext`.
#' @return Integer; the current correction factor.
#' @seealso [set_ckks_boot_correction_factor()], [eval_bootstrap_setup()]
#' @export
get_ckks_boot_correction_factor <- function(cc) {
  CryptoContext__GetCKKSBootCorrectionFactor(get_ptr(cc))
}

#' Set the CKKS bootstrap correction factor
#'
#' Sets the scheme-level correction factor used by subsequent
#' bootstraps. Normally this is set via the `correction_factor`
#' argument to [eval_bootstrap_setup()] at bootstrap setup
#' time; this pair exists for post-setup programmatic control.
#'
#' @param cc A `CryptoContext`.
#' @param cf Integer; the new correction factor.
#' @return The `cc`, invisibly.
#' @seealso [get_ckks_boot_correction_factor()]
#' @export
set_ckks_boot_correction_factor <- function(cc, cf) {
  CryptoContext__SetCKKSBootCorrectionFactor(get_ptr(cc), as.integer(cf))
  invisible(cc)
}
