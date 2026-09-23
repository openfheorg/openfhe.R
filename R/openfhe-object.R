## R-SPECIFIC: base S7 class for all OpenFHE objects wrapping C++ pointers

#' Base class for OpenFHE objects
#'
#' All OpenFHE objects (CryptoContext, Ciphertext, Plaintext, Keys, etc.)
#' inherit from this class. It holds an external pointer to a C++ shared_ptr.
#' @param ptr External pointer to C++ object (internal use)
#' @return An S7 object of class `OpenFHEObject`, the base class every object
#'   in this package inherits from. It has a single property, `ptr`,
#'   holding an external pointer to the underlying C++ `shared_ptr`.
#'   Constructing one directly is of no use; the class exists so that
#'   methods can dispatch on the common parent and so that the pointer is
#'   managed in one place.
#' @export
OpenFHEObject <- new_class("OpenFHEObject",
  package = "openfhe.R",
  ## Abstract for two reasons. Nothing should hold a bare handle: every
  ## pointer the C++ layer creates belongs to a concrete class. And S7
  ## only re-runs a parent's validator on the finished child object when
  ## the parent is abstract; a concrete parent is validated once, empty,
  ## before the child's properties exist, which would let the tag check
  ## below miss Ciphertext(ptr = <plaintext pointer>).
  abstract = TRUE,
  properties = list(
    ptr = new_property(class_any, default = NULL)
  ),
  validator = function(self) {
    if (is.null(self@ptr)) return(NULL)
    if (!inherits(self@ptr, "externalptr")) {
      return("@ptr must be an external pointer or NULL")
    }
    ## Every pointer the C++ layer hands out carries a tag naming the
    ## S7 class it belongs to (src/openfhe_cpp11.h). A subclass whose
    ## pointer carries someone else's tag is a wrong-type handle, for
    ## example Ciphertext(ptr = pt@ptr); refuse it here, at
    ## construction, rather than let the first C++ call see it. The base
    ## class itself is exempt because it is what a not-yet-classed
    ## handle is wrapped in.
    cls <- class(self)[1]
    if (cls != "openfhe.R::OpenFHEObject" && ptr_is_valid(self)) {
      tag <- xptr_type(self@ptr)
      if (nzchar(tag) && tag != cls) {
        return(sprintf("@ptr holds a <%s> handle, not a <%s>", tag, cls))
      }
    }
    NULL
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
