## R-SPECIFIC: package-level documentation and imports
#' @import S7
#' @importFrom cli cli_abort cli_warn cli_inform
## cli_abort(), cli_warn(), and cli_inform() delegate to rlang at run
## time, and cli lists rlang only in Suggests, so a package that uses
## them must declare rlang itself or every error path fails with "there
## is no package called 'rlang'" on a machine without it (D033). The
## import below is what makes the dependency real to R CMD check.
#' @importFrom rlang abort
#' @useDynLib openfhe.R, .registration = TRUE
"_PACKAGE"
