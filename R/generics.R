## R-SPECIFIC: S7 generic definitions for all openfhe.R operations

#' Homomorphic addition
#' @param x,y Ciphertext, Plaintext, or numeric values
#' @param ... Method-specific arguments
#' @return A Ciphertext
#' @export
eval_add <- new_generic("eval_add", dispatch_args = c("x", "y"))

#' Homomorphic subtraction
#' @param x,y Ciphertext, Plaintext, or numeric values
#' @param ... Method-specific arguments
#' @return A Ciphertext
#' @export
eval_sub <- new_generic("eval_sub", dispatch_args = c("x", "y"))

#' Homomorphic multiplication
#' @param x,y Ciphertext, Plaintext, or numeric values
#' @param ... Method-specific arguments
#' @return A Ciphertext
#' @export
eval_mult <- new_generic("eval_mult", dispatch_args = c("x", "y"))

#' Homomorphic negation
#' @param x A Ciphertext
#' @param ... Method-specific arguments
#' @return A Ciphertext
#' @export
eval_negate <- new_generic("eval_negate", "x")

#' Homomorphic squaring
#' @param x A Ciphertext
#' @param ... Method-specific arguments
#' @return A Ciphertext
#' @export
eval_square <- new_generic("eval_square", "x")
