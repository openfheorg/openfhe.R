## OPENFHE PYTHON SOURCE: tests/test_binfhe_api_coverage.py
##
## R port of the upstream openfhe-python BinFHE API-coverage tests. Each
## section names the Python test it ports. Where the R surface differs
## by design (notes/decisions/D14_binding_conventions.md) the section
## says how.
library(openfhe.R)

cc <- bin_fhe_context(BinFHEParamSet$TOY, BinFHEMethod$GINX)

## @openfhe-python: tests/test_binfhe_api_coverage.py::test_spreadsheet_add_apis_are_exposed [FULL]
expected <- list(
  BinFHEContext = c("HasInternal32RefreshKey", "HasInternal32SwitchKey",
                    "KeySwitchGen", "PubKeyGen", "SwitchCTtoqn"),
  LWECiphertext = c("GetptModulus", "SetModulus", "SetptModulus"),
  LWEPrivateKey = "GetModulus",
  LWEPublicKey = "GetModulus")
map_file <- system.file("scripts", "parity", "parity_map.tsv",
                        package = "openfhe.R")
if (nzchar(map_file)) {
  pm <- utils::read.delim(map_file, stringsAsFactors = FALSE, quote = "")
  exports <- getNamespaceExports("openfhe.R")
  missing <- character()
  for (cls in names(expected)) for (nm in expected[[cls]]) {
    row <- pm[pm$py_class == cls & pm$py_name == nm, , drop = FALSE]
    ok <- nrow(row) == 1L && row$status == "MAPPED" &&
      row$r_target %in% exports
    if (!ok) missing <- c(missing, paste(cls, nm, sep = "."))
  }
  expect_identical(missing, character())
}

## @openfhe-python: tests/test_binfhe_api_coverage.py::test_lwe_public_key_cannot_be_default_constructed [FULL]
## @openfhe-python: tests/test_binfhe_api_coverage.py::test_private_key_cannot_be_default_constructed [FULL]
## Python refuses to construct an empty key, because an empty but
## non-null key passes the C++ null check. R's no-argument constructor
## makes a null handle, never an empty C++ object (D14 section 6), and
## every function refuses a null handle.
expect_error(bin_encrypt(cc, LWEPublicKey(), 1L))
expect_error(bin_encrypt(cc, LWEPrivateKey(), 1L))
expect_error(bin_pub_key_gen(cc, LWEPrivateKey()))
expect_error(bin_bt_key_gen(cc, LWEPrivateKey()))
expect_error(bin_key_switch_gen(cc, LWEPrivateKey(), LWEPrivateKey()))
expect_error(get_length(LWEPrivateKey()))

## @openfhe-python: tests/test_binfhe_api_coverage.py::test_generate_lut_via_function_recovers_from_callback_errors [FULL]
## R evaluates the function in R (D14 section 7), so there is no
## callback state in C++ to corrupt; the error is the function's own.
p <- get_max_plaintext_space(cc)
bad <- function(m, q) stop("callback failure")
expect_error(generate_lut_via_function(bad, p), "callback failure")
lut <- generate_lut_via_function(function(m, q) (m * 3) %% q, p)
expect_equal(length(lut), p)

## @openfhe-python: tests/test_binfhe_api_coverage.py::test_generate_lut_via_function_supports_nested_calls [FULL]
nested <- NULL
outer_fn <- function(m, q) {
  if (is.null(nested)) {
    nested <<- generate_lut_via_function(function(mi, qi) (mi + 1) %% qi, p)
  }
  (m * 3) %% q
}
expect_identical(generate_lut_via_function(outer_fn, p),
                 generate_lut_via_function(function(m, q) (m * 3) %% q, p))
expect_identical(nested,
                 generate_lut_via_function(function(m, q) (m + 1) %% q, p))

## @openfhe-python: tests/test_binfhe_api_coverage.py::test_new_binfhe_bindings_round_trip [FULL]
## `get_modulus()` is a decimal string on every class and `get_big_q()`
## a number (D14 section 9).
expect_false(has_internal32_refresh_key(cc))
expect_false(has_internal32_switch_key(cc))

sk <- bin_key_gen(cc)
sk_n <- bin_key_gen_n(cc)
public_key <- bin_pub_key_gen(cc, sk_n)

expect_true(is.character(get_modulus(sk)) && grepl("^[0-9]+$", get_modulus(sk)))
big_q <- format(get_big_q(cc), scientific = FALSE)
expect_identical(get_modulus(sk_n), big_q)
expect_identical(get_modulus(public_key), big_q)

switching_key <- bin_key_switch_gen(cc, sk, sk_n)
expect_true(S7::S7_inherits(switching_key, LWESwitchingKey))

large_ct <- bin_encrypt(cc, sk_n, 1L, BinFHEOutput$LARGE_DIM, 4L, get_big_q(cc))
switched_ct <- switch_ct_to_qn(cc, switching_key, large_ct)
expect_equal(bin_decrypt(cc, sk, switched_ct), 1)

ct <- bin_encrypt(cc, sk, 1L, BinFHEOutput$FRESH, 4L)
expect_equal(get_pt_modulus(ct), 4)
set_pt_modulus(ct, 8L)
expect_equal(get_pt_modulus(ct), 8)

modulus <- get_modulus(ct)
doubled <- format(2 * as.numeric(modulus), scientific = FALSE)
set_modulus(ct, doubled)
expect_identical(get_modulus(ct), doubled)
set_modulus(ct, modulus)
expect_identical(get_modulus(ct), modulus)

## @openfhe-python: tests/test_binfhe_api_coverage.py::test_generated_private_keys_are_unaffected [FULL]
expect_true(get_length(bin_key_gen(cc)) > 0)
expect_true(get_length(bin_key_gen_n(cc)) > 0)
expect_true(get_length(bin_key_gen_pair(cc)@secret) > 0)

## @openfhe-python: tests/test_binfhe_api_coverage.py::test_deserialized_private_keys_are_unaffected [FULL]
path <- tempfile("sk", fileext = ".bin")
expect_true(fhe_serialize(sk, path, format = "binary"))
restored <- fhe_deserialize(path, "LWEPrivateKey", format = "binary")
expect_equal(get_length(restored), get_length(sk))
expect_identical(get_modulus(restored), get_modulus(sk))
## The restored key still decrypts what the original encrypted.
ct <- bin_encrypt(cc, sk, 1L, BinFHEOutput$FRESH, 4L)
expect_equal(bin_decrypt(cc, restored, ct), 1)
unlink(path)

## @openfhe-python: tests/test_binfhe_api_coverage.py::test_failed_deserialization_yields_a_null_key [FULL]
## Python returns (None, False); R raises an error and returns no key.
expect_error(fhe_deserialize(file.path(tempfile("missing-parent"), "sk"),
                             "LWEPrivateKey", format = "binary"))
