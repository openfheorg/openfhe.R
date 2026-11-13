## OPENFHE PYTHON SOURCE: tests/test_api_coverage.py
##
## R port of the upstream openfhe-python API-coverage tests. Each
## section names the Python test it ports. Where the R surface differs
## by design (notes/decisions/D14_binding_conventions.md) the section
## says how.
library(openfhe.R)

## The Python module fixture `ckks_context`.
cc <- fhe_context("CKKS",
  multiplicative_depth = 6L, batch_size = 8L, scaling_mod_size = 50L,
  ring_dim = 1024L, security_level = SecurityLevel$HEStd_NotSet,
  features = c(Feature$ADVANCEDSHE, Feature$MULTIPARTY))
keys <- key_gen(cc)
eval_mult_key_gen(cc, keys@secret)
eval_sum_key_gen(cc, keys@secret)

dec <- function(ct, sk = keys@secret, len = 2L) {
  pt <- decrypt(ct, sk, cc = cc)
  set_length(pt, len)
  round(Re(get_complex_packed_value(pt)), 4)
}
enc <- function(v) encrypt(keys@public, make_ckks_packed_plaintext(cc, v), cc = cc)

## @openfhe-python: tests/test_api_coverage.py::test_spreadsheet_add_apis_are_exposed [FULL]
## The R name of each Python member comes from the parity map, so the
## check is that every listed member is MAPPED to an exported function.
expected <- list(
  CryptoContext = c(
    "ClearAllCKKSCaches", "ClearSchemeSwitchPrecom", "ComposedEvalMult",
    "DeserializeEvalSumKey", "EvalAddInPlaceNoCheck",
    "EvalBootstrapPrecompute", "EvalBootstrapStCFirst", "EvalChebyPolys",
    "EvalChebyshevSeriesWithPrecomp", "EvalHermiteTrigSeries",
    "EvalMultInPlace", "EvalMultNoCheck", "EvalMultNoRelinNoCheck",
    "EvalPolyWithPrecomp", "EvalPowers", "GetAllEvalAutomorphismKeys",
    "GetAllEvalMultKeys", "GetAllEvalSumKeys", "GetEncodingParams",
    "GetEvalAutomorphismNoKeyIndices", "GetPlaintextForDecrypt",
    "GetRootOfUnity", "GetScheme", "getSchemeId", "GetSwkFC",
    "GetUniqueValues", "KeySwitch", "KeySwitchDown",
    "KeySwitchDownFirstElement", "KeySwitchExt", "KeySwitchInPlace",
    "LevelReduce", "LevelReduceInPlace", "MultiEvalAutomorphismKeyGen",
    "RecoverSharedKey", "SerializedObjectName", "SerializedVersion",
    "SerializeEvalSumKey", "SetBinCCForSchemeSwitch",
    "SetParamsFromCKKSCryptocontext", "setSchemeId", "SetSwkFC",
    "ShareKeys", "SparseKeyGen"),
  ## One map row covers CCParamsBFVRNS, CCParamsBGVRNS and CCParamsCKKSRNS;
  ## the three R methods are checked below.
  CCParams = "GetThresholdNumOfParties",
  Ciphertext = c(
    "CloneEmpty", "GetHopLevel", "GetScalingFactorInt",
    "NumberCiphertextElements", "SetEncodingType", "SetHopLevel",
    "SetScalingFactorInt", "SetKeyTag"),
  Plaintext = c(
    "GetCKKSDataType", "GetElementModulus", "GetElementRingDimension",
    "GetEncodingParams", "GetEncodingType", "GetScalingFactorInt",
    "SetCKKSDataType", "SetScalingFactorInt"),
  PublicKey = "GetCryptoContext",
  SchSwchParams = "SetParamsFromCKKSCryptocontextCalled")
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
for (p in list(BFVParams(), BGVParams(), CKKSParams())) {
  expect_equal(get_threshold_num_of_parties(p), 1)
}

## @openfhe-python: tests/test_api_coverage.py::test_new_value_conversions_and_support_types [FULL]
## Python's `Ciphertext()` is an empty object that takes setters; R's
## `Ciphertext()` is a null handle (D14 section 6), so the empty object
## is `clone_empty()` of a ciphertext.
ct_empty <- clone_empty(enc(c(0.25, 0.5)))
scaling_factor <- "1152921504606847099"   # 2^60 + 123
set_scaling_factor_int(ct_empty, scaling_factor)
set_encoding_type(ct_empty, PlaintextEncodings$CKKS_PACKED_ENCODING)
set_hop_level(ct_empty, 3L)
expect_identical(get_scaling_factor_int(ct_empty), scaling_factor)
expect_equal(get_encoding_type(ct_empty),
             PlaintextEncodings$CKKS_PACKED_ENCODING)
expect_equal(get_hop_level(ct_empty), 3)
expect_equal(number_ciphertext_elements(ct_empty), 0)
expect_true(S7::S7_inherits(clone_empty(ct_empty), Ciphertext))

expect_equal(get_threshold_num_of_parties(CKKSParams()), 1)

## Python returns None from this C++ `void` member; R returns the object
## invisibly (D14 section 4).
ssp <- SchSwchParams()
expect_true(S7::S7_inherits(set_params_from_ckks_cryptocontext_called(ssp),
                            SchSwchParams))

## @openfhe-python: tests/test_api_coverage.py::test_inplace_scalar_overloads_apply_the_right_operation [FULL]
ct <- enc(c(0.25, 0.5))
for (scalar in list(2.0, complex(real = 2.0, imaginary = 0.0))) {
  for (scalar_first in c(FALSE, TRUE)) {
    multiplied <- clone(ct)
    if (scalar_first) eval_mult_in_place(scalar, multiplied)
    else eval_mult_in_place(multiplied, scalar)
    expect_equal(dec(multiplied), c(0.5, 1.0))

    added <- clone(ct)
    if (scalar_first) eval_add_in_place(scalar, added)
    else eval_add_in_place(added, scalar)
    expect_equal(dec(added), c(2.25, 2.5))
  }
}

## @openfhe-python: tests/test_api_coverage.py::test_no_check_variants_match_their_checked_counterparts [FULL]
added <- clone(ct)
eval_add_in_place_no_check(added, ct)
expect_equal(dec(added), c(0.5, 1.0))
expect_equal(dec(eval_mult_no_check(ct, 2)), c(0.5, 1.0))
expect_equal(dec(composed_eval_mult(ct, ct)), c(0.0625, 0.25))
squared <- eval_mult_no_relin_no_check(ct, ct)
expect_equal(number_ciphertext_elements(squared), 3)
expect_equal(dec(relinearize(squared)), c(0.0625, 0.25))

## @openfhe-python: tests/test_api_coverage.py::test_series_precomputation_matches_direct_evaluation [FULL]
coefficients <- c(1.0, 2.0, 3.0)
powers <- eval_powers(ct, coefficients)
expect_true(S7::S7_inherits(powers, SeriesPowers))
expect_equal(dec(eval_poly_with_precomp(powers, coefficients)),
             dec(eval_poly(ct, coefficients)))
cheby_polys <- eval_cheby_polys(ct, coefficients, -1.0, 1.0)
expect_true(S7::S7_inherits(cheby_polys, SeriesPowers))
expect_equal(dec(eval_chebyshev_series_with_precomp(cheby_polys, coefficients)),
             dec(eval_chebyshev(ct, coefficients, -1.0, 1.0)))

## @openfhe-python: tests/test_api_coverage.py::test_key_sharing_round_trip [FULL]
## R returns the recovered key instead of filling one passed in, and
## the share map is an opaque `SecretShareMap` (D14 sections 4 and 6).
n_parties <- 3L
threshold <- 2L
shares <- share_keys(cc, keys@secret, n_parties, threshold, 1L, "additive")
expect_equal(length(shares), n_parties - 1L)
recovered <- recover_shared_key(cc, shares, n_parties, threshold, "additive")
expect_true(S7::S7_inherits(get_crypto_context(recovered), CryptoContext))
expect_equal(dec(enc(c(0.25, 0.5)), sk = recovered), c(0.25, 0.5))

## @openfhe-python: tests/test_api_coverage.py::test_private_key_without_context_has_none [FULL]
## R's `PrivateKey()` is a null handle; asking it for a context is an
## error where Python returns None from an empty key object.
expect_error(get_crypto_context(PrivateKey()))

## @openfhe-python: tests/test_api_coverage.py::test_eval_sum_key_serialization_round_trip [FULL]
key_tag <- get_key_tag(keys@secret)
for (fmt in c("binary", "json")) {
  by_tag <- tempfile("by_tag")
  by_context <- tempfile("by_context")
  expect_true(serialize_eval_keys(by_tag, type = "sum", format = fmt,
                                  key_tag = key_tag))
  expect_true(serialize_eval_keys(by_context, type = "sum", format = fmt,
                                  cc = cc))

  ## Clear the global key map first, otherwise the round trip cannot fail.
  clear_eval_sum_keys()
  expect_false(key_tag %in% names(get_all_eval_sum_keys()))

  expect_true(deserialize_eval_keys(by_tag, type = "sum", format = fmt))
  expect_true(key_tag %in% names(get_all_eval_sum_keys()))

  clear_eval_sum_keys()
  expect_true(deserialize_eval_keys(by_context, type = "sum", format = fmt))
  expect_true(key_tag %in% names(get_all_eval_sum_keys()))
  unlink(c(by_tag, by_context))
}

## @openfhe-python: tests/test_api_coverage.py::test_eval_sum_key_serialization_reports_unusable_paths [FULL]
## @openfhe-python: tests/test_api_coverage.py::test_mult_and_automorphism_key_deserialization_reports_unusable_paths [FULL]
## @openfhe-python: tests/test_api_coverage.py::test_key_serialization_reports_unwritable_paths [FULL]
## A path whose parent directory does not exist. Python returns False;
## the R functions raise an error, as every R file function does.
unusable_path <- file.path(tempfile("missing-parent"), "keys")
for (fmt in c("binary", "json")) {
  expect_error(serialize_eval_keys(unusable_path, type = "sum", format = fmt,
                                   key_tag = key_tag))
  expect_error(serialize_eval_keys(unusable_path, type = "sum", format = fmt,
                                   cc = cc))
  expect_error(deserialize_eval_keys(unusable_path, type = "sum", format = fmt))
  expect_error(deserialize_eval_keys(unusable_path, type = "mult", format = fmt))
  expect_error(deserialize_eval_keys(unusable_path, type = "automorphism",
                                     format = fmt))
  expect_error(serialize_eval_keys(unusable_path, type = "mult", format = fmt,
                                   key_tag = key_tag))
  expect_error(serialize_eval_keys(unusable_path, type = "automorphism",
                                   format = fmt, key_tag = key_tag))
  expect_error(serialize_eval_bootstrap_key(unusable_path, cc, key_tag, 8L,
                                            format = fmt))
}
expect_false(file.exists(dirname(unusable_path)))

## @openfhe-python: tests/test_api_coverage.py::test_null_context_arguments_raise_instead_of_crashing [FULL]
## Python's None is R's NULL or a null handle; both must be an R error.
ct1 <- enc(0.5)
expect_error(schemelet_convert_rlwe_to_ckks(NULL, PolyVector(), keys@public,
                                            1, 1L, 0L))
expect_error(schemelet_convert_rlwe_to_ckks(CryptoContext(), PolyVector(),
                                            keys@public, 1, 1L, 0L))
expect_error(SchemeSwitchingDataSerializer(NULL, keys@public, ct1))
expect_error(SchemeSwitchingDataSerializer(cc, NULL, ct1))
expect_error(SchemeSwitchingDataSerializer(cc, keys@public, NULL))
expect_error(SchemeSwitchingDataSerializer(CryptoContext(), keys@public, ct1))
expect_error(SchemeSwitchingDataSerializer(cc, PublicKey(), ct1))
expect_error(SchemeSwitchingDataSerializer(cc, keys@public, Ciphertext()))

## @openfhe-python: tests/test_api_coverage.py::test_schemelet_null_arguments_raise_instead_of_crashing [FULL]
ep <- schemelet_get_element_params(keys@secret)
expect_error(schemelet_decrypt_coeff(PolyVector(), 65537, 17, keys@secret,
                                     ep, 8L))
expect_error(schemelet_convert_rlwe_to_ckks(cc, PolyVector(), keys@public,
                                            1, 1L, 0L))
for (null_key in list(NULL, PrivateKey())) {
  expect_error(schemelet_get_element_params(null_key))
  expect_error(schemelet_encrypt_coeff(1, 65537, 17, null_key, ep))
  expect_error(schemelet_decrypt_coeff(PolyVector(), 65537, 17, null_key,
                                       ep, 8L))
}
for (null_ep in list(NULL, ElementParams())) {
  expect_error(schemelet_encrypt_coeff(1, 65537, 17, keys@secret, null_ep))
  expect_error(schemelet_decrypt_coeff(PolyVector(), 65537, 17, keys@secret,
                                       null_ep, 8L))
}
expect_error(schemelet_mod_switch(PolyVector(), 65537, 17))
expect_error(schemelet_convert_ckks_to_rlwe(NULL, 65537))
expect_error(schemelet_convert_ckks_to_rlwe(Ciphertext(), 65537))
expect_error(schemelet_get_q_prime(NULL, 1L))
expect_error(schemelet_get_q_prime(PublicKey(), 1L))

## @openfhe-python: tests/test_api_coverage.py::test_integer_conversions_reject_invalid_python_ints [FULL]
## Wide integers cross as decimal strings (D14 section 1). The package
## is built with 64-bit native integers.
pt <- make_ckks_packed_plaintext(cc, 0.5)
native_max <- "18446744073709551615"             # 2^64 - 1
expect_error(switch_modulus(PolyVector(), -1))
expect_error(switch_modulus(PolyVector(), "-1"))
expect_error(set_scaling_factor_int(pt, "18446744073709551616"))   # 2^64
expect_error(set_scaling_factor_int(pt, "184467440737095516150"))  # 10 (2^64 - 1)
expect_error(set_scaling_factor_int(pt, TRUE))
set_scaling_factor_int(pt, native_max)
expect_identical(get_scaling_factor_int(pt), native_max)
## BigInteger is not limited to the native word size: 2^220 + 123456789.
big <- "1684996666696914987166688442938726917102321526408785780068975764301"
expect_silent(switch_modulus(PolyVector(), big))

## @openfhe-python: tests/test_api_coverage.py::test_module_exposes_its_version [N/A FOR R: the package version is checked against the vendored library in test_surface_parity.R]
## @openfhe-python: tests/test_api_coverage.py::test_enum_members_are_exported_at_module_level [N/A FOR R: enum members are elements of exported lists; test_enums_compiled.R checks every value]

## @openfhe-python: tests/test_api_coverage.py::test_element_params_feed_get_plaintext_for_decrypt [FULL]
element_params <- get_element_params(cc)
expect_equal(ring_dimension(element_params), ring_dimension(cc))
expect_equal(get_cyclotomic_order(element_params), get_cyclotomic_order(cc))
pt_dec <- get_plaintext_for_decrypt(PlaintextEncodings$CKKS_PACKED_ENCODING,
                                    element_params, get_encoding_params(cc))
expect_true(S7::S7_inherits(pt_dec, Plaintext))

## @openfhe-python: tests/test_api_coverage.py::test_context_getters [FULL]
expect_equal(get_scheme_id(cc), SchemeId$CKKSRNS_SCHEME)
expect_identical(serialized_object_name(cc), "CryptoContext")
expect_true(serialized_version(cc) >= 1)
expect_equal(get_batch_size(get_encoding_params(cc)), 8)
expect_true(S7::S7_inherits(get_scheme(cc), SchemeBase))
## DCRTPoly stores a root of unity per RNS tower, so the aggregate is 0.
expect_identical(get_root_of_unity(cc), "0")

## @openfhe-python: tests/test_api_coverage.py::test_static_key_maps_and_index_helpers [FULL]
expect_true(key_tag %in% names(get_all_eval_mult_keys()))
expect_true(key_tag %in% names(get_all_eval_sum_keys()))
expect_true(key_tag %in% names(get_all_eval_automorphism_keys()))
expect_equal(sort(get_unique_values(c(1L, 2L, 3L), c(3L, 4L, 5L))), c(4, 5))
existing <- get_existing_eval_automorphism_key_indices(key_tag)
expect_true(length(existing) > 0L)
absent <- max(existing) + 1
expect_equal(get_eval_automorphism_no_key_indices(key_tag, c(existing, absent)),
             absent)

## @openfhe-python: tests/test_api_coverage.py::test_key_switching_and_level_reduction [FULL]
switch_key <- key_switch_gen(cc, keys@secret, keys@secret)
expect_equal(dec(key_switch(ct, switch_key)), c(0.25, 0.5))
in_place <- clone(ct)
key_switch_in_place(in_place, switch_key)
expect_equal(dec(in_place), c(0.25, 0.5))
extended <- key_switch_ext(ct, TRUE)
expect_true(S7::S7_inherits(key_switch_down_first_element(extended), DCRTPoly))
expect_equal(dec(key_switch_down(extended)), c(0.25, 0.5))
## LevelReduce drops RNS towers without touching the level under
## FLEXIBLEAUTOEXT, so the check is that the value survives.
expect_equal(dec(level_reduce(ct, NULL, 1L)), c(0.25, 0.5))
reduced_in_place <- clone(ct)
level_reduce_in_place(reduced_in_place, NULL, 1L)
expect_equal(dec(reduced_in_place), c(0.25, 0.5))

## @openfhe-python: tests/test_api_coverage.py::test_sparse_key_gen_and_public_key_context [FULL]
expect_true(S7::S7_inherits(sparse_key_gen(cc), KeyPair))
expect_true(S7::S7_inherits(get_crypto_context(keys@public), CryptoContext))

clear_fhe_state()
