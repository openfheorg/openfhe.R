## OPENFHE PYTHON SOURCE: src/lib/pke/fbt.cpp (CKKS functional bootstrapping)
##
## R wrappers for src/pke_fbt.cpp.

## Look-up-table coefficients. The R type selects the C++ overload:
## integer -> int64_t (Boolean case), double or complex ->
## std::complex<double> (general case).
.lut_coefficients <- function(coeffs, arg = rlang::caller_arg(coeffs),
                              call = rlang::caller_env()) {
  ok <- (is.numeric(coeffs) || is.complex(coeffs)) && !is.object(coeffs) &&
    length(coeffs) > 0L && !anyNA(coeffs)
  if (!ok) {
    cli_abort("{.arg {arg}} must be a non-empty integer, double or complex vector with no missing values.",
              call = call)
  }
  coeffs
}

# ── Coefficients and depth ──────────────────────────────

#' Trigonometric Hermite interpolation of a look-up table
#'
#' Computes the coefficients of the trigonometric Hermite interpolation
#' of a function on the integers modulo `p`. They are the `coeffs`
#' argument of [eval_fbt()] and its relatives in the general case.
#'
#' @param func A function of one whole number in `0, ..., p - 1`
#'   returning one whole number: the look-up table.
#' @param p Integer; the input plaintext modulus.
#' @param order Integer; the order of the interpolation (1, 2 or 3).
#' @param scale Numeric; the coefficients are divided by it. A scale
#'   that brings their magnitude near one is recommended; it is undone
#'   by the `post_scaling` argument of [eval_fbt()].
#' @return A complex vector.
#' @examples
#' get_hermite_trig_coefficients(function(x) x %% 4, p = 8L, order = 1L,
#'                               scale = 1)
#' @export
get_hermite_trig_coefficients <- function(func, p, order, scale) {
  if (!is.function(func)) {
    cli_abort("{.arg func} must be a function.")
  }
  GetHermiteTrigCoefficients__(func, as.integer(p), as.integer(order),
                               as.double(scale))
}

#' Multiplicative depth of functional bootstrapping
#'
#' `get_fbt_depth()` gives the depth [eval_fbt()] consumes for a
#' look-up table, and `get_fefbt_depth()` the depth
#' [eval_fe_func_bootstrap()] consumes for a Fourier series. Add the
#' levels wanted after bootstrapping to get the `multiplicative_depth`
#' of the context.
#'
#' @param level_budget Integer vector of length 2; the levels spent on
#'   the coefficients-to-slots and slots-to-coefficients transforms.
#' @param coefficients The coefficients of the look-up table (as for
#'   [eval_fbt()]) or of the Fourier series.
#' @param p_input The input plaintext modulus: a string of decimal
#'   digits, or a whole number of at most 2^53.
#' @param order Integer; the order of the Hermite interpolation.
#' @param skd Secret key distribution, an element of [SecretKeyDist].
#' @param first_mod_size Integer; size of the first modulus in bits
#'   (read only for `SecretKeyDist$SPARSE_ENCAPSULATED`). Default
#'   `60L`.
#' @return An integer.
#' @export
get_fbt_depth <- function(level_budget, coefficients, p_input, order, skd,
                          first_mod_size = 60L) {
  GetFBTDepth__(as.integer(level_budget), .lut_coefficients(coefficients),
                wide_integer(p_input), as.integer(order), as.integer(skd),
                as.integer(first_mod_size))
}

#' @rdname get_fbt_depth
#' @export
get_fefbt_depth <- function(level_budget, coefficients,
                            skd = SecretKeyDist$SPARSE_TERNARY,
                            first_mod_size = 60L) {
  GetFEFBTDepth__(as.integer(level_budget), .lut_coefficients(coefficients),
                  as.integer(skd), as.integer(first_mod_size))
}

# ── Functional bootstrapping of a look-up table ─────────

#' CKKS functional bootstrapping of a look-up table
#'
#' Functional bootstrapping refreshes a ciphertext and applies a
#' look-up table to the encrypted integers in the same step. The input
#' is an RLWE ciphertext converted to CKKS with
#' [schemelet_convert_rlwe_to_ckks()], and the output goes back with
#' [schemelet_convert_ckks_to_rlwe()].
#'
#' `eval_fbt_setup()` prepares the context; call
#' [eval_bootstrap_key_gen()] and [eval_mult_key_gen()] after it.
#' `eval_fbt()` applies the table. `eval_fbt_no_decoding()` stops
#' before the return to coefficient encoding, leaving a slot-packed
#' CKKS ciphertext on which leveled operations can be done;
#' `eval_hom_decoding()` then finishes.
#'
#' The R type of `coeffs` selects the form of the table, as the Python
#' type does in openfhe-python. An integer vector is the optimized
#' Boolean case (input modulus 2, order 1), with the two coefficients
#' `c(f(1), f(0) - f(1))`; build it with `as.integer()`. A double or
#' complex vector is the general case, with the coefficients from
#' [get_hermite_trig_coefficients()].
#'
#' @param cc A CKKS `CryptoContext` with `Feature$FHE` enabled.
#' @param coeffs The coefficients of the look-up table; see Details.
#' @param num_slots Integer; number of CKKS slots.
#' @param p_in,p_out Input and output plaintext moduli.
#' @param big_q The modulus of the RLWE ciphertext converted to CKKS.
#' @param pub_key The `PublicKey`.
#' @param dim1 Integer vector of length 2; baby-step dimensions of the
#'   two linear transforms (`0` for the library's choice).
#' @param level_budget Integer vector of length 2; level budgets of the
#'   two linear transforms.
#' @param lvls_after_boot Integer; levels available after
#'   bootstrapping. Default `0L`.
#' @param depth_leveled_computation Integer; levels of the computation
#'   done between `eval_fbt_no_decoding()` (or
#'   [eval_mvb_no_decoding()]) and `eval_hom_decoding()`. Default `0L`.
#' @param order Integer; order of the Hermite interpolation. Default
#'   `1L`.
#' @param ct A `Ciphertext`.
#' @param digit_bit_size Integer; number of bits of the input modulus.
#' @param initial_scaling The modulus the input is scaled by, usually
#'   `get_modulus()` of the element parameters from
#'   [schemelet_get_element_params()].
#' @param post_scaling The scale applied to the coefficients (the
#'   `scale` of [get_hermite_trig_coefficients()]), undone here.
#' @param level_to_reduce Integer; levels to drop before decoding.
#'   Default `0L`.
#' @details `p_in`, `p_out`, `big_q`, `initial_scaling` and
#'   `post_scaling` are strings of decimal digits, or whole numbers of
#'   at most 2^53.
#' @return `eval_fbt_setup()`: `cc`, invisibly. The others: a
#'   `Ciphertext`.
#' @seealso [eval_mvb_precompute()] to apply several tables to one
#'   input; [get_fbt_depth()].
#' @export
eval_fbt_setup <- function(cc, coeffs, num_slots, p_in, p_out, big_q, pub_key,
                           dim1, level_budget, lvls_after_boot = 0L,
                           depth_leveled_computation = 0L, order = 1L) {
  EvalFBTSetup__(get_ptr(cc), .lut_coefficients(coeffs), as.integer(num_slots),
                 wide_integer(p_in), wide_integer(p_out), wide_integer(big_q),
                 get_ptr(pub_key), as.integer(dim1), as.integer(level_budget),
                 as.integer(lvls_after_boot),
                 as.integer(depth_leveled_computation), as.integer(order))
  invisible(cc)
}

#' @rdname eval_fbt_setup
#' @export
eval_fbt <- function(ct, coeffs, digit_bit_size, initial_scaling, post_scaling,
                     level_to_reduce = 0L, order = 1L) {
  ## >>> S7-FAST-NEW (RConsortium/S7#723): original
  ## Ciphertext(ptr = EvalFBT__(get_ptr(ct), .lut_coefficients(coeffs),
  ##                            as.integer(digit_bit_size),
  ##                            wide_integer(initial_scaling),
  ##                            wide_integer(post_scaling),
  ##                            as.integer(level_to_reduce), as.integer(order)))
  ## <<< S7-FAST-NEW
  .fast_new(Ciphertext, EvalFBT__(get_ptr(ct), .lut_coefficients(coeffs),
                                  as.integer(digit_bit_size),
                                  wide_integer(initial_scaling),
                                  wide_integer(post_scaling),
                                  as.integer(level_to_reduce), as.integer(order)))
}

#' @rdname eval_fbt_setup
#' @export
eval_fbt_no_decoding <- function(ct, coeffs, digit_bit_size, initial_scaling,
                                 order = 1L) {
  ## >>> S7-FAST-NEW (RConsortium/S7#723): original
  ## Ciphertext(ptr = EvalFBTNoDecoding__(get_ptr(ct), .lut_coefficients(coeffs),
  ##                                      as.integer(digit_bit_size),
  ##                                      wide_integer(initial_scaling),
  ##                                      as.integer(order)))
  ## <<< S7-FAST-NEW
  .fast_new(Ciphertext, EvalFBTNoDecoding__(get_ptr(ct), .lut_coefficients(coeffs),
                                            as.integer(digit_bit_size),
                                            wide_integer(initial_scaling),
                                            as.integer(order)))
}

#' @rdname eval_fbt_setup
#' @export
eval_hom_decoding <- function(ct, post_scaling, level_to_reduce = 0L) {
  ## >>> S7-FAST-NEW (RConsortium/S7#723): original
  ## Ciphertext(ptr = EvalHomDecoding__(get_ptr(ct), wide_integer(post_scaling),
  ##                                    as.integer(level_to_reduce)))
  ## <<< S7-FAST-NEW
  .fast_new(Ciphertext, EvalHomDecoding__(get_ptr(ct), wide_integer(post_scaling),
                                          as.integer(level_to_reduce)))
}

# ── Multi-value bootstrapping ───────────────────────────

#' Several look-up tables on one input (multi-value bootstrapping)
#'
#' `eval_mvb_precompute()` does the part of functional bootstrapping
#' that does not depend on the table: it computes the complex
#' exponential of the input and its powers. `eval_mvb()` and
#' `eval_mvb_no_decoding()` then apply a table to that precomputation,
#' as [eval_fbt()] and [eval_fbt_no_decoding()] do to a ciphertext.
#' Every table applied to one precomputation must have the input
#' modulus and order of the coefficients the precomputation was made
#' with.
#'
#' @param ct A `Ciphertext`.
#' @param ciphertexts A [SeriesPowers] object from
#'   `eval_mvb_precompute()`.
#' @inheritParams eval_fbt_setup
#' @return `eval_mvb_precompute()`: a [SeriesPowers] object. The
#'   others: a `Ciphertext`.
#' @seealso [eval_fbt_setup()], [eval_hom_decoding()]
#' @export
eval_mvb_precompute <- function(ct, coeffs, digit_bit_size, initial_scaling,
                                order = 1L) {
  ## >>> S7-FAST-NEW (RConsortium/S7#723): original
  ## SeriesPowers(ptr = EvalMVBPrecompute__(get_ptr(ct), .lut_coefficients(coeffs),
  ##                                        as.integer(digit_bit_size),
  ##                                        wide_integer(initial_scaling),
  ##                                        as.integer(order)))
  ## <<< S7-FAST-NEW
  .fast_new(SeriesPowers, EvalMVBPrecompute__(get_ptr(ct), .lut_coefficients(coeffs),
                                              as.integer(digit_bit_size),
                                              wide_integer(initial_scaling),
                                              as.integer(order)))
}

#' @rdname eval_mvb_precompute
#' @export
eval_mvb <- function(ciphertexts, coeffs, digit_bit_size, post_scaling,
                     level_to_reduce = 0L, order = 1L) {
  ## >>> S7-FAST-NEW (RConsortium/S7#723): original
  ## Ciphertext(ptr = EvalMVB__(get_ptr(ciphertexts), .lut_coefficients(coeffs),
  ##                            as.integer(digit_bit_size),
  ##                            wide_integer(post_scaling),
  ##                            as.integer(level_to_reduce), as.integer(order)))
  ## <<< S7-FAST-NEW
  .fast_new(Ciphertext, EvalMVB__(get_ptr(ciphertexts), .lut_coefficients(coeffs),
                                  as.integer(digit_bit_size),
                                  wide_integer(post_scaling),
                                  as.integer(level_to_reduce), as.integer(order)))
}

#' @rdname eval_mvb_precompute
#' @export
eval_mvb_no_decoding <- function(ciphertexts, coeffs, digit_bit_size,
                                 order = 1L) {
  ## >>> S7-FAST-NEW (RConsortium/S7#723): original
  ## Ciphertext(ptr = EvalMVBNoDecoding__(get_ptr(ciphertexts),
  ##                                      .lut_coefficients(coeffs),
  ##                                      as.integer(digit_bit_size),
  ##                                      as.integer(order)))
  ## <<< S7-FAST-NEW
  .fast_new(Ciphertext, EvalMVBNoDecoding__(get_ptr(ciphertexts),
                                            .lut_coefficients(coeffs),
                                            as.integer(digit_bit_size),
                                            as.integer(order)))
}

# ── Hermite trigonometric series ────────────────────────

#' Evaluate a trigonometric Hermite series on a ciphertext
#'
#' The series evaluation inside functional bootstrapping. It
#' approximates `exp(i * pi / 2 * x)` by the Chebyshev series
#' `coefficients_cheb` on `[a, b]`, squares it twice to get
#' `exp(2 * pi * i * x)`, evaluates the polynomial with coefficients
#' `coefficients_herm` in that exponential, and returns twice the real
#' part: `2 * Re(sum_j h_j exp(2 * pi * i * j * x))` (CKKS only).
#'
#' The exponential is kept in the bootstrapping precomputation of the
#' context for the slot count of `ct`, in one of two places, so the
#' context must have been set up for bootstrapping
#' ([eval_fbt_setup()], [eval_bootstrap_setup()] or
#' [eval_fe_func_bootstrap_setup()]) and must hold the conjugation key
#' ([eval_bootstrap_key_gen()]).
#'
#' @param ct A `Ciphertext`.
#' @param coefficients_cheb Numeric or complex vector; Chebyshev
#'   coefficients of `exp(i * pi / 2 * x)` on `[a, b]`.
#' @param a,b Numeric; the interval of the Chebyshev approximation.
#' @param coefficients_herm The coefficients of the Hermite series in
#'   powers of the exponential, divided by 2: an integer vector, or a
#'   double or complex vector.
#' @param precomp Integer. `0L` (default) or `1L`: compute the
#'   exponential and keep it in the first or the second place. `2L`:
#'   reuse the first one kept. Any other value: reuse the second.
#' @return A `Ciphertext`.
#' @export
eval_hermite_trig_series <- function(ct, coefficients_cheb, a, b,
                                     coefficients_herm, precomp = 0L) {
  ## >>> S7-FAST-NEW (RConsortium/S7#723): original
  ## Ciphertext(ptr = EvalHermiteTrigSeries__(
  ##   get_ptr(ct), .lut_coefficients(coefficients_cheb), as.double(a),
  ##   as.double(b), .lut_coefficients(coefficients_herm), as.integer(precomp)))
  ## <<< S7-FAST-NEW
  .fast_new(Ciphertext, EvalHermiteTrigSeries__(
    get_ptr(ct), .lut_coefficients(coefficients_cheb), as.double(a),
    as.double(b), .lut_coefficients(coefficients_herm), as.integer(precomp)))
}

# ── Functional bootstrapping of a Fourier series ────────

#' CKKS functional bootstrapping of a Fourier series
#'
#' Refreshes a ciphertext and evaluates on its values the function
#' whose Fourier coefficients are `coefficients`, in the same step
#' (CKKS with `CKKSDataType$COMPLEX`).
#'
#' `eval_fe_func_bootstrap_setup()` prepares the context; call
#' [eval_bootstrap_key_gen()] after it. `eval_fe_func_bootstrap()`
#' does the whole evaluation. `eval_fe_func_bootstrap_precompute()`
#' and `eval_fe_func_bootstrap_with_precomp()` split it, so that
#' several series of the same length can be evaluated on one input.
#'
#' The setup shares the bootstrapping precomputation of the context
#' for `slots` with [eval_bootstrap_setup()] and [eval_fbt_setup()]: a
#' context holds one of the three per slot count.
#'
#' @param cc A CKKS `CryptoContext` with `Feature$FHE` enabled.
#' @param level_budget Integer vector of length 2. Default `c(5L, 4L)`.
#' @param dim1 Integer vector of length 2. Default `c(0L, 0L)`.
#' @param slots Integer; number of slots, `0L` (default) for full
#'   packing.
#' @param ct A `Ciphertext`.
#' @param coefficients Numeric or complex vector of Fourier
#'   coefficients.
#' @param powers A [SeriesPowers] object from
#'   `eval_fe_func_bootstrap_precompute()`.
#' @return `eval_fe_func_bootstrap_setup()`: `cc`, invisibly.
#'   `eval_fe_func_bootstrap_precompute()`: a [SeriesPowers] object.
#'   The others: a `Ciphertext`.
#' @seealso [get_fefbt_depth()]
#' @export
eval_fe_func_bootstrap_setup <- function(cc, level_budget = c(5L, 4L),
                                         dim1 = c(0L, 0L), slots = 0L) {
  EvalFEFuncBootstrapSetup__(get_ptr(cc), as.integer(level_budget),
                             as.integer(dim1), as.integer(slots))
  invisible(cc)
}

#' @rdname eval_fe_func_bootstrap_setup
#' @export
eval_fe_func_bootstrap <- function(ct, coefficients) {
  ## >>> S7-FAST-NEW (RConsortium/S7#723): original
  ## Ciphertext(ptr = EvalFEFuncBootstrap__(get_ptr(ct),
  ##                                        .lut_coefficients(coefficients)))
  ## <<< S7-FAST-NEW
  .fast_new(Ciphertext, EvalFEFuncBootstrap__(get_ptr(ct),
                                              .lut_coefficients(coefficients)))
}

#' @rdname eval_fe_func_bootstrap_setup
#' @export
eval_fe_func_bootstrap_precompute <- function(ct, coefficients) {
  ## >>> S7-FAST-NEW (RConsortium/S7#723): original
  ## SeriesPowers(ptr = EvalFEFuncBootstrapPrecompute__(
  ##   get_ptr(ct), .lut_coefficients(coefficients)))
  ## <<< S7-FAST-NEW
  .fast_new(SeriesPowers, EvalFEFuncBootstrapPrecompute__(
    get_ptr(ct), .lut_coefficients(coefficients)))
}

#' @rdname eval_fe_func_bootstrap_setup
#' @export
eval_fe_func_bootstrap_with_precomp <- function(powers, coefficients) {
  ## >>> S7-FAST-NEW (RConsortium/S7#723): original
  ## Ciphertext(ptr = EvalFEFuncBootstrapWithPrecomp__(
  ##   get_ptr(powers), .lut_coefficients(coefficients)))
  ## <<< S7-FAST-NEW
  .fast_new(Ciphertext, EvalFEFuncBootstrapWithPrecomp__(
    get_ptr(powers), .lut_coefficients(coefficients)))
}
