## OPENFHE PYTHON SOURCE: src/lib/bindings.cpp (bind_parameters: Set*, __str__)
##
## The CCParams setters as functions callable after construction, and
## the stream form of a parameter object. The constructors
## (R/params.R) keep their arguments; these setters are the R
## counterparts of openfhe-python's `params.SetX(value)` calls.
##
## All 33 setters are defined for all three parameter classes, as in
## the C++ header and in openfhe-python. A setter that a scheme
## disables raises OpenFHE's own error (D13 Decision 3).

## Field codes, in the order of `enum ParamField` in
## src/pke_ccparams_set.cpp. inst/tinytest/test_params_set.R checks
## each code against its getter.
.CCPARAMS_FIELD <- c(
  plaintext_modulus = 0L, digit_size = 1L, standard_deviation = 2L,
  secret_key_dist = 3L, max_relin_sk_deg = 4L, pre_mode = 5L,
  multiparty_mode = 6L, execution_mode = 7L, decryption_noise_mode = 8L,
  noise_estimate = 9L, desired_precision = 10L, statistical_security = 11L,
  num_adversarial_queries = 12L, threshold_num_of_parties = 13L,
  key_switch_technique = 14L, scaling_technique = 15L, batch_size = 16L,
  first_mod_size = 17L, num_large_digits = 18L, multiplicative_depth = 19L,
  scaling_mod_size = 20L, security_level = 21L, ring_dim = 22L,
  eval_add_count = 23L, key_switch_count = 24L, encryption_technique = 25L,
  multiplication_technique = 26L, pre_num_hops = 27L,
  interactive_boot_compression_level = 28L, composite_degree = 29L,
  register_word_size = 30L, ckks_data_type = 31L
)

## How each field's value crosses to C++: "count" (a non-negative whole
## number below 2^31), "enum" (an enum member), "real", or "wide" (the
## plaintext modulus, D14 section 1).
.CCPARAMS_KIND <- c(
  plaintext_modulus = "wide", digit_size = "count",
  standard_deviation = "real", secret_key_dist = "enum",
  max_relin_sk_deg = "count", pre_mode = "enum", multiparty_mode = "enum",
  execution_mode = "enum", decryption_noise_mode = "enum",
  noise_estimate = "real", desired_precision = "real",
  statistical_security = "count", num_adversarial_queries = "count",
  threshold_num_of_parties = "count", key_switch_technique = "enum",
  scaling_technique = "enum", batch_size = "count", first_mod_size = "count",
  num_large_digits = "count", multiplicative_depth = "count",
  scaling_mod_size = "count", security_level = "enum", ring_dim = "count",
  eval_add_count = "count", key_switch_count = "count",
  encryption_technique = "enum", multiplication_technique = "enum",
  pre_num_hops = "count", interactive_boot_compression_level = "enum",
  composite_degree = "count", register_word_size = "count",
  ckks_data_type = "enum"
)

.ccparams_value <- function(value, kind, call = rlang::caller_env()) {
  scalar <- length(value) == 1L && !is.object(value) && !is.na(value)
  switch(kind,
    wide = wide_integer(value, arg = "value", call = call),
    real = {
      if (!scalar || !is.numeric(value)) {
        cli_abort("{.arg value} must be a single number.", call = call)
      }
      as.double(value)
    },
    {
      if (!scalar || !is.numeric(value) || value != trunc(value) ||
          value < 0 || value > .Machine$integer.max) {
        cli_abort("{.arg value} must be a single non-negative whole number.",
                  call = call)
      }
      as.integer(value)
    }
  )
}

## The method body shared by the three parameter classes for one field.
.ccparams_setter <- function(field) {
  code <- .CCPARAMS_FIELD[[field]]
  kind <- .CCPARAMS_KIND[[field]]
  function(params, value) {
    CCParams__Set(get_ptr(params), code, .ccparams_value(value, kind))
    invisible(params)
  }
}

## The same, for a generic whose dispatch argument is named `x`
## (set_ckks_data_type, defined for Plaintext first).
.ccparams_setter_x <- function(field) {
  code <- .CCPARAMS_FIELD[[field]]
  kind <- .CCPARAMS_KIND[[field]]
  function(x, value) {
    CCParams__Set(get_ptr(x), code, .ccparams_value(value, kind))
    invisible(x)
  }
}

#' Set a parameter on a parameter object
#'
#' Change one parameter of a `BFVParams`, `BGVParams`, or `CKKSParams`
#' object after it has been constructed. Each function wraps the
#' `CCParams<T>::Set*` method of the same name. The parameter
#' constructors take the same parameters as arguments; these functions
#' are for code that builds a parameter object step by step, as the
#' OpenFHE examples do.
#'
#' Every setter is defined for all three parameter classes, as in the
#' C++ library. A parameter that a scheme does not use is refused by
#' OpenFHE, and its error is raised: for example
#' `set_plaintext_modulus()` on a `CKKSParams` object.
#'
#' Parameters whose values are members of an enumeration take the
#' member, for example `set_security_level(p, SecurityLevel$HEStd_128_classic)`.
#'
#' @param params A `BFVParams`, `BGVParams`, or `CKKSParams` object.
#' @param ... Method-specific arguments: `value`, the new value of the
#'   parameter.
#' @return `params`, invisibly. The object is modified in place.
#' @seealso [ccparams_getters] for the matching `get_*` functions;
#'   [BFVParams()], [BGVParams()], [CKKSParams()].
#' @examples
#' p <- CKKSParams()
#' set_multiplicative_depth(p, 2L)
#' set_scaling_mod_size(p, 50L)
#' set_batch_size(p, 8L)
#' get_multiplicative_depth(p)
#' @name ccparams_setters
NULL

#' @describeIn ccparams_setters plaintext modulus (BFV, BGV). A whole
#'   number of at most 2^53, or a string of decimal digits.
#' @export
set_plaintext_modulus <- new_generic("set_plaintext_modulus", "params")

#' @describeIn ccparams_setters digit size for BV key switching.
#' @export
set_digit_size <- new_generic("set_digit_size", "params")

#' @describeIn ccparams_setters standard deviation of the error
#'   distribution.
#' @export
set_standard_deviation <- new_generic("set_standard_deviation", "params")

#' @describeIn ccparams_setters secret-key distribution, a member of
#'   [SecretKeyDist].
#' @export
set_secret_key_dist <- new_generic("set_secret_key_dist", "params")

#' @describeIn ccparams_setters maximum degree of the secret key for
#'   which relinearization keys are generated.
#' @export
set_max_relin_sk_deg <- new_generic("set_max_relin_sk_deg", "params")

#' @describeIn ccparams_setters proxy re-encryption mode, a member of
#'   [PREMode].
#' @export
set_pre_mode <- new_generic("set_pre_mode", "params")

#' @describeIn ccparams_setters multiparty mode, a member of
#'   [MultipartyMode].
#' @export
set_multiparty_mode <- new_generic("set_multiparty_mode", "params")

#' @describeIn ccparams_setters execution mode (CKKS), a member of
#'   [ExecutionMode].
#' @export
set_execution_mode <- new_generic("set_execution_mode", "params")

#' @describeIn ccparams_setters decryption noise mode (CKKS), a member
#'   of [DecryptionNoiseMode].
#' @export
set_decryption_noise_mode <- new_generic("set_decryption_noise_mode", "params")

#' @describeIn ccparams_setters noise estimate for noise flooding
#'   (CKKS).
#' @export
set_noise_estimate <- new_generic("set_noise_estimate", "params")

#' @describeIn ccparams_setters desired precision for noise flooding
#'   (CKKS).
#' @export
set_desired_precision <- new_generic("set_desired_precision", "params")

#' @describeIn ccparams_setters statistical security, in bits, for
#'   noise flooding.
#' @export
set_statistical_security <- new_generic("set_statistical_security", "params")

#' @describeIn ccparams_setters bound on the number of adversarial
#'   queries, for noise flooding.
#' @export
set_num_adversarial_queries <- new_generic("set_num_adversarial_queries", "params")

#' @describeIn ccparams_setters number of parties in threshold FHE.
#' @export
set_threshold_num_of_parties <- new_generic("set_threshold_num_of_parties", "params")

#' @describeIn ccparams_setters key-switching technique, a member of
#'   [KeySwitchTechnique].
#' @export
set_key_switch_technique <- new_generic("set_key_switch_technique", "params")

#' @describeIn ccparams_setters scaling technique, a member of
#'   [ScalingTechnique].
#' @export
set_scaling_technique <- new_generic("set_scaling_technique", "params")

#' @describeIn ccparams_setters batch size (number of plaintext slots).
#' @export
set_batch_size <- new_generic("set_batch_size", "params")

#' @describeIn ccparams_setters bit size of the first modulus.
#' @export
set_first_mod_size <- new_generic("set_first_mod_size", "params")

#' @describeIn ccparams_setters number of large digits for hybrid key
#'   switching.
#' @export
set_num_large_digits <- new_generic("set_num_large_digits", "params")

#' @describeIn ccparams_setters multiplicative depth.
#' @export
set_multiplicative_depth <- new_generic("set_multiplicative_depth", "params")

#' @describeIn ccparams_setters bit size of the scaling moduli.
#' @export
set_scaling_mod_size <- new_generic("set_scaling_mod_size", "params")

#' @describeIn ccparams_setters security level, a member of
#'   [SecurityLevel].
#' @export
set_security_level <- new_generic("set_security_level", "params")

#' @describeIn ccparams_setters ring dimension.
#' @export
set_ring_dim <- new_generic("set_ring_dim", "params")

#' @describeIn ccparams_setters number of additions per level (BFV,
#'   BGV).
#' @export
set_eval_add_count <- new_generic("set_eval_add_count", "params")

#' @describeIn ccparams_setters number of key switches per level (BFV,
#'   BGV).
#' @export
set_key_switch_count <- new_generic("set_key_switch_count", "params")

#' @describeIn ccparams_setters encryption technique (BFV), a member of
#'   [EncryptionTechnique].
#' @export
set_encryption_technique <- new_generic("set_encryption_technique", "params")

#' @describeIn ccparams_setters multiplication technique (BFV), a
#'   member of [MultiplicationTechnique].
#' @export
set_multiplication_technique <- new_generic("set_multiplication_technique", "params")

#' @describeIn ccparams_setters number of proxy re-encryption hops
#'   (BGV).
#' @export
set_pre_num_hops <- new_generic("set_pre_num_hops", "params")

#' @describeIn ccparams_setters compression level for interactive
#'   bootstrapping (CKKS), a member of [CompressionLevel].
#' @export
set_interactive_boot_compression_level <-
  new_generic("set_interactive_boot_compression_level", "params")

#' @describeIn ccparams_setters composite degree for composite scaling
#'   (CKKS).
#' @export
set_composite_degree <- new_generic("set_composite_degree", "params")

#' @describeIn ccparams_setters register word size for composite
#'   scaling (CKKS).
#' @export
set_register_word_size <- new_generic("set_register_word_size", "params")

## Methods. One loop per generic at top level, so that `method<-`
## assigns to the generic's own binding.
.CCPARAMS_CLASSES <- list(BFVParams, BGVParams, CKKSParams)

for (.cls in .CCPARAMS_CLASSES) {
  method(set_plaintext_modulus, .cls) <- .ccparams_setter("plaintext_modulus")
  method(set_digit_size, .cls) <- .ccparams_setter("digit_size")
  method(set_standard_deviation, .cls) <- .ccparams_setter("standard_deviation")
  method(set_secret_key_dist, .cls) <- .ccparams_setter("secret_key_dist")
  method(set_max_relin_sk_deg, .cls) <- .ccparams_setter("max_relin_sk_deg")
  method(set_pre_mode, .cls) <- .ccparams_setter("pre_mode")
  method(set_multiparty_mode, .cls) <- .ccparams_setter("multiparty_mode")
  method(set_execution_mode, .cls) <- .ccparams_setter("execution_mode")
  method(set_decryption_noise_mode, .cls) <- .ccparams_setter("decryption_noise_mode")
  method(set_noise_estimate, .cls) <- .ccparams_setter("noise_estimate")
  method(set_desired_precision, .cls) <- .ccparams_setter("desired_precision")
  method(set_statistical_security, .cls) <- .ccparams_setter("statistical_security")
  method(set_num_adversarial_queries, .cls) <- .ccparams_setter("num_adversarial_queries")
  method(set_threshold_num_of_parties, .cls) <- .ccparams_setter("threshold_num_of_parties")
  method(set_key_switch_technique, .cls) <- .ccparams_setter("key_switch_technique")
  method(set_scaling_technique, .cls) <- .ccparams_setter("scaling_technique")
  method(set_batch_size, .cls) <- .ccparams_setter("batch_size")
  method(set_first_mod_size, .cls) <- .ccparams_setter("first_mod_size")
  method(set_num_large_digits, .cls) <- .ccparams_setter("num_large_digits")
  method(set_multiplicative_depth, .cls) <- .ccparams_setter("multiplicative_depth")
  method(set_scaling_mod_size, .cls) <- .ccparams_setter("scaling_mod_size")
  method(set_security_level, .cls) <- .ccparams_setter("security_level")
  method(set_ring_dim, .cls) <- .ccparams_setter("ring_dim")
  method(set_eval_add_count, .cls) <- .ccparams_setter("eval_add_count")
  method(set_key_switch_count, .cls) <- .ccparams_setter("key_switch_count")
  method(set_encryption_technique, .cls) <- .ccparams_setter("encryption_technique")
  method(set_multiplication_technique, .cls) <- .ccparams_setter("multiplication_technique")
  method(set_pre_num_hops, .cls) <- .ccparams_setter("pre_num_hops")
  method(set_interactive_boot_compression_level, .cls) <-
    .ccparams_setter("interactive_boot_compression_level")
  method(set_composite_degree, .cls) <- .ccparams_setter("composite_degree")
  method(set_register_word_size, .cls) <- .ccparams_setter("register_word_size")
  ## set_ckks_data_type() is the generic of R/plaintext-accessors.R,
  ## which dispatches on `x`.
  method(set_ckks_data_type, .cls) <- .ccparams_setter_x("ckks_data_type")
}

## ── Stream form: Python's __str__ ───────────────────────────────

## format() returns what OpenFHE's operator<< writes for the parameter
## object, which is what openfhe-python returns from str(params).
## print() shows the class and then that text.
.ccparams_format <- function(x, ...) {
  if (!ptr_is_valid(x)) return("<null>")
  CCParams__ToString(get_ptr(x))
}
.ccparams_print <- function(x, ...) {
  cli::cli_text("{.cls {sub('^openfhe.R::', '', class(x)[1L])}} [{if (ptr_is_valid(x)) 'configured' else 'null'}]")
  if (ptr_is_valid(x)) cli::cli_verbatim(format(x))
  invisible(x)
}
for (.cls in .CCPARAMS_CLASSES) {
  method(format, .cls) <- .ccparams_format
  method(print, .cls) <- .ccparams_print
}
rm(.cls)
