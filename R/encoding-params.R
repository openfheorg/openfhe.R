## OPENFHE PYTHON SOURCE: src/lib/bindings.cpp (EncodingParams wrapper)

#' Encoding Parameters (opaque)
#'
#' Wraps `std::shared_ptr<EncodingParamsImpl>` on the C++ side.
#' Returned by `get_encoding_params(cc)` and by
#' `Plaintext::GetEncodingParams()` once the corresponding
#' Plaintext accessor lands. This class ships as scaffolding
#' only: the S7 class definition is in place so that the getter
#' wiring can treat it as already defined, but there is no
#' constructor path from R.
#'
#' @param ptr External pointer (internal use)
#' @export
EncodingParams <- new_class("EncodingParams",
  parent = OpenFHEObject,
  package = "openfhe.R"
)

method(print, EncodingParams) <- function(x, ...) {
  cli::cli_text("{.cls EncodingParams} [{if (ptr_is_valid(x)) 'active' else 'null'}]")
  invisible(x)
}
