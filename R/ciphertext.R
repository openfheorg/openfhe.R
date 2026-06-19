## OPENFHE PYTHON SOURCE: src/lib/bindings.cpp (Ciphertext class)

#' Ciphertext class
#'
#' Wraps an encrypted OpenFHE ciphertext. Supports arithmetic operators
#' `+`, `-`, `*` which dispatch to homomorphic operations.
#' @param ptr External pointer (internal use)
#' @export
Ciphertext <- new_class("Ciphertext",
  parent = OpenFHEObject,
  package = "openfhe.R"
)

method(print, Ciphertext) <- function(x, ...) {
  valid <- ptr_is_valid(x)
  cli::cli_text("{.cls Ciphertext} [{if (valid) 'active' else 'null'}]")
  invisible(x)
}
