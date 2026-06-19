## R-SPECIFIC: utility functions

#' Get the native integer size of the OpenFHE build
#'
#' Returns 64 or 128 depending on how OpenFHE was compiled.
#' @return integer
#' @export
get_native_int <- function() {
  openfhe_native_int()
}

#' Set the number of OpenMP threads OpenFHE may use
#'
#' OpenFHE parallelizes its core arithmetic with OpenMP and, by default,
#' uses every core the machine reports. `set_num_threads()` calls the
#' OpenMP runtime directly (`omp_set_num_threads`) to cap the threads used
#' by homomorphic operations run afterward in the current session. The
#' change takes effect immediately and on every platform, regardless of when
#' the package was loaded. It is a no-op when the package was built without
#' OpenMP.
#'
#' The package default is uncapped, so interactive users get full
#' parallelism. The package's own tests and vignettes call
#' `set_num_threads(2L)` to stay within CRAN's two-thread policy.
#'
#' @param n integer; the maximum number of threads (at least 1).
#' @return `NULL`, invisibly. Called for its side effect.
#' @seealso [get_num_threads()]
#' @examples
#' old <- get_num_threads()
#' set_num_threads(2L)
#' set_num_threads(old)
#' @export
set_num_threads <- function(n) {
  n <- as.integer(n)
  if (length(n) != 1L || is.na(n) || n < 1L) {
    cli_abort("{.arg n} must be a single integer of at least 1.")
  }
  openfhe_set_num_threads(n)
  invisible(NULL)
}

#' Report the number of OpenMP threads available to OpenFHE
#'
#' Returns `omp_get_max_threads()`: the maximum number of threads OpenFHE
#' will use for a parallel region under the current settings (see
#' [set_num_threads()]). Returns `1` when the package was built without
#' OpenMP.
#'
#' @return integer; the OpenMP thread limit.
#' @seealso [set_num_threads()]
#' @examples
#' get_num_threads()
#' @export
get_num_threads <- function() {
  openfhe_get_num_threads()
}
