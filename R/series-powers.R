## OPENFHE PYTHON SOURCE: src/lib/bindings.cpp (EvalPowers / EvalChebyPolys / EvalPolyWithPrecomp / EvalChebyshevSeriesWithPrecomp / EvalBootstrapPrecompute / EvalBootstrapStCFirst), src/lib/pke/fbt.cpp (SeriesPowers)
##
## R wrappers for the precomputation half of src/pke_ckks_eval_poly.cpp.

#' Precomputed powers of a ciphertext
#'
#' The powers, or the Chebyshev polynomials, of one ciphertext, as
#' [eval_powers()] and [eval_cheby_polys()] compute them. The class is
#' an opaque handle, as in openfhe-python: it is passed to
#' [eval_poly_with_precomp()] or
#' [eval_chebyshev_series_with_precomp()], which leave it unchanged.
#'
#' @param ptr External pointer (internal use)
#' @return An S7 object of class `SeriesPowers`, inheriting from
#'   [OpenFHEObject].
#' @export
SeriesPowers <- new_class("SeriesPowers",
  parent = OpenFHEObject,
  package = "openfhe.R"
)

method(print, SeriesPowers) <- function(x, ...) {
  if (!ptr_is_valid(x)) {
    cli::cli_text("{.cls SeriesPowers} [null]")
    return(invisible(x))
  }
  info <- SeriesPowers__info(x@ptr)
  cli::cli_text("{.cls SeriesPowers} [active] k = {info[1]}, m = {info[2]}")
  invisible(x)
}

.check_series_coefficients <- function(coefficients, call = rlang::caller_env()) {
  ok <- (is.numeric(coefficients) || is.complex(coefficients)) &&
    !is.object(coefficients) && length(coefficients) > 0L &&
    !anyNA(coefficients)
  if (!ok) {
    cli_abort(
      "{.arg coefficients} must be a non-empty integer, double or complex vector with no missing values.",
      call = call)
  }
}

#' Evaluate several series on one ciphertext
#'
#' Evaluating a polynomial or a Chebyshev series on a ciphertext
#' spends most of its time computing the powers (or the Chebyshev
#' polynomials) of the ciphertext. These functions separate the two
#' steps, so that several series can be evaluated on the same
#' ciphertext for the cost of one set of powers (CKKS only).
#'
#' `eval_powers()` computes the powers that [eval_poly()] would compute
#' for `coefficients`, and `eval_poly_with_precomp()` evaluates a
#' polynomial from them. `eval_cheby_polys()` and
#' `eval_chebyshev_series_with_precomp()` are the same pair for
#' [eval_chebyshev()].
#'
#' The precomputation depends on `coefficients` only through the
#' degree (the length of the vector), so it can be reused for any
#' series of that degree. Below degree 5 only the powers with a nonzero
#' coefficient are computed, so there the nonzero terms must match as
#' well.
#'
#' @param ct A `Ciphertext`.
#' @param coefficients Integer, double or complex vector of
#'   coefficients, constant term first, as for [eval_poly()] and
#'   [eval_chebyshev()]. Pass whole-number Chebyshev coefficients as
#'   doubles; see [eval_chebyshev()].
#' @param a,b Numeric; the interval of the Chebyshev approximation.
#' @param powers A [SeriesPowers] object from `eval_powers()`.
#' @param polys A [SeriesPowers] object from `eval_cheby_polys()`.
#' @return `eval_powers()` and `eval_cheby_polys()`: a [SeriesPowers]
#'   object. The other two: a `Ciphertext`.
#' @examples
#' cc <- fhe_context("CKKS", multiplicative_depth = 4L, scaling_mod_size = 50L,
#'                   batch_size = 8L, features = Feature$ADVANCEDSHE)
#' keys <- key_gen(cc, eval_mult = TRUE)
#' ct <- encrypt(keys@public, make_ckks_packed_plaintext(cc, c(0.5, 1, 2)), cc = cc)
#' p <- c(1, 0, 2, 0, 0, 1)
#' q <- c(0, 1, 0, 3, 0, -1)
#' powers <- eval_powers(ct, p)
#' ct_p <- eval_poly_with_precomp(powers, p)
#' ct_q <- eval_poly_with_precomp(powers, q)
#' @export
eval_powers <- function(ct, coefficients) {
  .check_series_coefficients(coefficients)
  ## >>> S7-FAST-NEW (RConsortium/S7#723): original
  ## SeriesPowers(ptr = EvalSeriesPowers__(get_ptr(ct), FALSE, coefficients, 0, 0))
  ## <<< S7-FAST-NEW
  .fast_new(SeriesPowers, EvalSeriesPowers__(get_ptr(ct), FALSE, coefficients, 0, 0))
}

#' @rdname eval_powers
#' @export
eval_poly_with_precomp <- function(powers, coefficients) {
  .check_series_coefficients(coefficients)
  ## >>> S7-FAST-NEW (RConsortium/S7#723): original
  ## Ciphertext(ptr = EvalSeriesWithPrecomp__(get_ptr(powers), FALSE, coefficients))
  ## <<< S7-FAST-NEW
  .fast_new(Ciphertext, EvalSeriesWithPrecomp__(get_ptr(powers), FALSE, coefficients))
}

#' @rdname eval_powers
#' @export
eval_cheby_polys <- function(ct, coefficients, a, b) {
  .check_series_coefficients(coefficients)
  ## >>> S7-FAST-NEW (RConsortium/S7#723): original
  ## SeriesPowers(ptr = EvalSeriesPowers__(get_ptr(ct), TRUE, coefficients,
  ##                                       as.double(a), as.double(b)))
  ## <<< S7-FAST-NEW
  .fast_new(SeriesPowers, EvalSeriesPowers__(get_ptr(ct), TRUE, coefficients,
                                             as.double(a), as.double(b)))
}

#' @rdname eval_powers
#' @export
eval_chebyshev_series_with_precomp <- function(polys, coefficients) {
  .check_series_coefficients(coefficients)
  ## >>> S7-FAST-NEW (RConsortium/S7#723): original
  ## Ciphertext(ptr = EvalSeriesWithPrecomp__(get_ptr(polys), TRUE, coefficients))
  ## <<< S7-FAST-NEW
  .fast_new(Ciphertext, EvalSeriesWithPrecomp__(get_ptr(polys), TRUE, coefficients))
}

#' Precompute the plaintexts of CKKS bootstrapping
#'
#' Computes and stores the encoding and decoding plaintexts that
#' bootstrapping uses. [eval_bootstrap_setup()] does this itself unless
#' it is called with `precompute = FALSE`; this function does it
#' afterwards.
#'
#' After a setup with `precompute = FALSE`, call this function before
#' [eval_bootstrap()]. At OpenFHE 1.6.1 the library does not check
#' that the plaintexts exist, and bootstrapping without them ends the
#' R session.
#'
#' @param cc A `CryptoContext`.
#' @param slots Integer; the number of slots to be bootstrapped.
#'   Default `0L`.
#' @return `cc`, invisibly.
#' @seealso [eval_bootstrap_setup()], [clear_bootstrap_precom()]
#' @export
eval_bootstrap_precompute <- function(cc, slots = 0L) {
  EvalBootstrapPrecompute__(get_ptr(cc), as.integer(slots))
  invisible(cc)
}

#' CKKS bootstrapping with slots-to-coefficients first
#'
#' The slots-encoding variant of CKKS bootstrapping: the
#' slots-to-coefficients transform comes first, then the modulus raise,
#' the coefficients-to-slots transform and the approximate modular
#' reduction. It needs [eval_bootstrap_setup()] to have been called
#' with `bt_slots_encoding = TRUE`; after such a setup
#' [eval_bootstrap()] calls this variant itself.
#'
#' Do not call it on a context with a regular setup. At OpenFHE 1.6.1
#' the library does not check the kind of setup, and the error it then
#' raises ends the R session.
#'
#' @param ct A `Ciphertext`.
#' @param num_iterations Integer; number of iterations. Default `1L`.
#' @param precision Integer; precision of the initial bootstrapping,
#'   `0L` (default) for the library's choice.
#' @return A refreshed `Ciphertext`.
#' @seealso [eval_bootstrap()]
#' @export
eval_bootstrap_stc_first <- function(ct, num_iterations = 1L, precision = 0L) {
  ## >>> S7-FAST-NEW (RConsortium/S7#723): original
  ## Ciphertext(ptr = EvalBootstrapStCFirst__(get_ptr(ct),
  ##                                          as.integer(num_iterations),
  ##                                          as.integer(precision)))
  ## <<< S7-FAST-NEW
  .fast_new(Ciphertext, EvalBootstrapStCFirst__(get_ptr(ct),
                                                as.integer(num_iterations),
                                                as.integer(precision)))
}
