## R-SPECIFIC: base S7 class for all OpenFHE objects wrapping C++ pointers

#' Base class for OpenFHE objects
#'
#' All OpenFHE objects (CryptoContext, Ciphertext, Plaintext, Keys, etc.)
#' inherit from this class. It holds an external pointer to a C++ shared_ptr.
#' @param ptr External pointer to C++ object (internal use)
#' @export
OpenFHEObject <- new_class("OpenFHEObject",
  package = "openfhe.R",
  properties = list(
    ptr = new_property(class_any, default = NULL)
  ),
  validator = function(self) {
    if (!is.null(self@ptr) && !inherits(self@ptr, "externalptr")) {
      "@ptr must be an external pointer or NULL"
    }
  }
)

#' Check if an external pointer is valid (non-NULL)
#' @param x An OpenFHEObject
#' @return logical
#' @importFrom methods new
#' @keywords internal
ptr_is_valid <- function(x) {
  !is.null(x@ptr) && !identical(x@ptr, new("externalptr"))
}

#' Extract pointer with validation
#' @param x An OpenFHEObject
#' @return The external pointer
#' @keywords internal
get_ptr <- function(x) {
  if (!ptr_is_valid(x)) {
    cli_abort("Invalid {.cls {class(x)[1]}} object: null pointer")
  }
  x@ptr
}
