## OPENFHE PYTHON SOURCE: src/lib/bindings.cpp (CryptoParameters wrapper)

#' Crypto Parameters (opaque)
#'
#' Wraps `std::shared_ptr<CryptoParametersBase<DCRTPoly>>` on the
#' C++ side. Returned by `get_crypto_parameters(cc)` and used as
#' an opaque token for RNS-level parameter accessors such as
#' `get_scaling_factor_real`, `get_key_switch_technique`, etc.
#' This class ships as scaffolding only: the S7 class definition
#' is in place so that the getter wiring can treat it as already
#' defined, but there is no constructor path from R.
#'
#' @param ptr External pointer (internal use)
#' @export
CryptoParameters <- new_class("CryptoParameters",
  parent = OpenFHEObject,
  package = "openfhe.R"
)

method(print, CryptoParameters) <- function(x, ...) {
  cli::cli_text("{.cls CryptoParameters} [{if (ptr_is_valid(x)) 'active' else 'null'}]")
  invisible(x)
}
