## OPENFHE PYTHON SOURCE: src/lib/bindings.cpp (ElementParams wrapper)

#' Element Parameters (opaque)
#'
#' Wraps `std::shared_ptr<typename DCRTPoly::Params>` on the C++ side.
#' Used by the `params` argument of CKKS plaintext factories and
#' returned by `get_element_params()`. This class ships as
#' scaffolding only: no constructor surface other than
#' wrapping an existing external pointer.
#'
#' @param ptr External pointer (internal use)
#' @export
ElementParams <- new_class("ElementParams",
  parent = OpenFHEObject,
  package = "openfhe.R"
)

method(print, ElementParams) <- function(x, ...) {
  cli::cli_text("{.cls ElementParams} [{if (ptr_is_valid(x)) 'active' else 'null'}]")
  invisible(x)
}
