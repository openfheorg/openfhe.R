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
#' uses every hardware thread the machine reports. `set_num_threads()`
#' sets the cap through OpenFHE's own thread controls, which every
#' parallel region in the library consults when it starts, so the change
#' takes effect immediately, on every platform, and regardless of which
#' thread the work runs on. It is a no-op when the package was built
#' without OpenMP.
#'
#' Requests above the number of threads available when the library was
#' loaded (the hardware count, or `OMP_NUM_THREADS` if that was set
#' before R started) are reduced to that number. The value in effect is
#' returned, so a reduced request is visible to the caller;
#' [get_num_threads()] reports the same value later.
#'
#' The package default is uncapped, so interactive users get full
#' parallelism. Under `R CMD check`, which sets `_R_CHECK_LIMIT_CORES_`,
#' the package caps itself at two threads when it is loaded, in line with
#' CRAN's two-thread policy. This also covers packages that depend on
#' 'openfhe.R', which therefore need no thread handling of their own.
#'
#' @param n integer; the requested maximum number of threads (at least 1).
#' @return integer; the cap now in effect, invisibly.
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
  invisible(openfhe_set_num_threads(n))
}

#' Report the number of OpenMP threads available to OpenFHE
#'
#' Returns the cap OpenFHE currently applies to its parallel regions: the
#' number of hardware threads at load, or the value most recently passed
#' to [set_num_threads()]. Returns `1` when the package was built without
#' OpenMP.
#'
#' @return integer; the current thread cap.
#' @seealso [set_num_threads()]
#' @examples
#' get_num_threads()
#' @export
get_num_threads <- function() {
  openfhe_get_num_threads()
}
