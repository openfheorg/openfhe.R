## OPENFHE PYTHON SOURCE: src/lib/bindings.cpp (Ciphertext class)

#' Ciphertext class
#'
#' Wraps an encrypted OpenFHE ciphertext. Supports arithmetic operators
#' `+`, `-`, `*` which dispatch to homomorphic operations.
#' @param ptr External pointer (internal use)
#' @return An S7 object of class `Ciphertext`, inheriting from [OpenFHEObject],
#'   whose `ptr` property holds an external pointer to the C++
#'   ciphertext. Ciphertexts are produced by [encrypt()] and by the
#'   `eval_*()` family rather than by calling this constructor directly,
#'   and they carry the encrypted vector together with the level and
#'   scaling-factor bookkeeping the scheme needs.
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
