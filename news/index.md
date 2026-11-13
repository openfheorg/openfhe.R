# Changelog

## openfhe.R 1.6.1

- The vendored library is OpenFHE 1.6.1. Every class, method and enum
  that the Python package `openfhe` 1.6.1.0 exposes has an R
  counterpart. Its tests and examples are run as tests of this package,
  except one example that needs a 128-bit build of the library.

- Contexts, keys and ciphertexts saved by openfhe.R 1.5.1.2, in the
  binary or the JSON format, are read by this version.

- `BinFHEParamSet` has the 112 members of OpenFHE 1.6.1. Every member
  except `TOY` and `MEDIUM` has a new integer value, so code must refer
  to members by name (`BinFHEParamSet$STD128`), never by number.

- OpenFHE 1.6.1 redefines the predefined Binary FHE parameter sets under
  their old names. `BinFHEParamSet$STD128_AP` now works only with
  `BinFHEMethod$AP`.

- [`bin_fhe_context()`](https://openfheorg.github.io/openfhe.R/reference/bin_fhe_context.md)
  builds the context for arbitrary-function evaluation whenever
  `arb_func`, `log_q`, `n` or `time_optimization` is supplied, as the
  C++ library does. Before, supplying `arb_func = FALSE` alone built the
  Boolean-gate context, which has different parameters.

- [`serialize_eval_keys()`](https://openfheorg.github.io/openfhe.R/reference/serialize_eval_keys.md)
  to a file that cannot be opened is an error. Before, the JSON format
  returned `TRUE` and wrote nothing.

- [`find_automorphism_index()`](https://openfheorg.github.io/openfhe.R/reference/find_automorphism_index.md)
  and
  [`find_automorphism_indices()`](https://openfheorg.github.io/openfhe.R/reference/find_automorphism_indices.md)
  refuse a value outside the 32-bit integer range.

- [`length()`](https://rdrr.io/r/base/length.html) of the object
  [`share_keys()`](https://openfheorg.github.io/openfhe.R/reference/share_keys.md)
  returns is the number of shares.

- Functions that return an encrypted value, a key or another handle no
  longer go through the ‘S7’ constructor, which saves about 45
  microseconds per call.

- [`bin_bt_key_gen()`](https://openfheorg.github.io/openfhe.R/reference/bin_bt_key_gen.md)
  gains the argument `internal32`.

- [`bin_encrypt()`](https://openfheorg.github.io/openfhe.R/reference/bin_encrypt.md)
  defaults to `output = BinFHEOutput$BOOTSTRAPPED`, and
  [`get_bootstrap_depth()`](https://openfheorg.github.io/openfhe.R/reference/get_bootstrap_depth.md)
  to `SecretKeyDist$UNIFORM_TERNARY`, as in OpenFHE 1.6.1.

- [`eval_add()`](https://openfheorg.github.io/openfhe.R/reference/eval_add.md),
  [`eval_sub()`](https://openfheorg.github.io/openfhe.R/reference/eval_sub.md)
  and
  [`eval_mult()`](https://openfheorg.github.io/openfhe.R/reference/eval_mult.md),
  with their `_in_place` and `_mutable` forms, accept every operand
  order and type the C++ library declares: a plaintext or a number as
  the first operand, and complex numbers for a CKKS context with complex
  data. `eval_sub(2, ct)` now calls the library’s own scalar-first
  subtraction.

- [`eval_poly()`](https://openfheorg.github.io/openfhe.R/reference/eval_poly.md),
  [`eval_chebyshev()`](https://openfheorg.github.io/openfhe.R/reference/eval_chebyshev.md)
  and their `_linear` and `_ps` forms accept integer and complex
  coefficient vectors as well as doubles. An integer vector is now
  evaluated with integer arithmetic; it was converted to double before.
  At OpenFHE 1.6.1 the Paterson-Stockmeyer Chebyshev evaluator returns
  wrong values for integer coefficients, so pass whole-number Chebyshev
  coefficients as doubles.

- [`eval_bin_gate()`](https://openfheorg.github.io/openfhe.R/reference/eval_bin_gate.md)
  gains `extended`.
  [`eval_floor()`](https://openfheorg.github.io/openfhe.R/reference/eval_floor.md)
  and
  [`compress()`](https://openfheorg.github.io/openfhe.R/reference/compress.md)
  take the library defaults `roundbits = 0` and `towers_left = 1`.
  [`level_reduce()`](https://openfheorg.github.io/openfhe.R/reference/level_reduce.md)
  and
  [`level_reduce_in_place()`](https://openfheorg.github.io/openfhe.R/reference/level_reduce_in_place.md)
  accept `NULL` for the evaluation key.
  [`get_bootstrap_depth()`](https://openfheorg.github.io/openfhe.R/reference/get_bootstrap_depth.md)
  gains `approx_mod_depth`.
  [`multiparty_key_gen()`](https://openfheorg.github.io/openfhe.R/reference/multiparty_key_gen.md)
  accepts a list of secret keys.
  [`get_length()`](https://openfheorg.github.io/openfhe.R/reference/plaintext_accessors.md)
  works on an `LWECiphertext`.

- New `set_*` functions change one parameter of a `BFVParams`,
  `BGVParams` or `CKKSParams` object after it has been constructed
  ([`set_multiplicative_depth()`](https://openfheorg.github.io/openfhe.R/reference/ccparams_setters.md),
  [`set_ring_dim()`](https://openfheorg.github.io/openfhe.R/reference/ccparams_setters.md)
  and 30 others; see
  [`?ccparams_setters`](https://openfheorg.github.io/openfhe.R/reference/ccparams_setters.md)),
  so a parameter object can be built step by step as the OpenFHE
  examples do. [`format()`](https://rdrr.io/r/base/format.html) and
  [`print()`](https://rdrr.io/r/base/print.html) of a parameter object
  show every field.

- New
  [`gen_crypto_context()`](https://openfheorg.github.io/openfhe.R/reference/gen_crypto_context.md)
  builds a context from a parameter object and enables no feature, as
  OpenFHE’s `GenCryptoContext()` does.
  [`fhe_context()`](https://openfheorg.github.io/openfhe.R/reference/fhe_context.md)
  is unchanged.

- [`make_ckks_packed_plaintext()`](https://openfheorg.github.io/openfhe.R/reference/make_ckks_packed_plaintext.md)
  accepts `params` with complex values.

- New evaluation functions:
  [`eval_add_many()`](https://openfheorg.github.io/openfhe.R/reference/eval_add_many.md),
  [`eval_add_many_in_place()`](https://openfheorg.github.io/openfhe.R/reference/eval_add_many.md),
  [`eval_mult_many()`](https://openfheorg.github.io/openfhe.R/reference/eval_add_many.md),
  [`eval_merge()`](https://openfheorg.github.io/openfhe.R/reference/eval_merge.md),
  [`eval_linear_wsum()`](https://openfheorg.github.io/openfhe.R/reference/eval_linear_wsum.md),
  [`eval_linear_wsum_mutable()`](https://openfheorg.github.io/openfhe.R/reference/eval_linear_wsum.md),
  [`eval_inner_product()`](https://openfheorg.github.io/openfhe.R/reference/eval_inner_product.md),
  [`eval_sum_rows()`](https://openfheorg.github.io/openfhe.R/reference/eval_sum_rows.md),
  [`eval_sum_cols()`](https://openfheorg.github.io/openfhe.R/reference/eval_sum_rows.md)
  with
  [`eval_sum_rows_key_gen()`](https://openfheorg.github.io/openfhe.R/reference/eval_sum_rows.md)
  and
  [`eval_sum_cols_key_gen()`](https://openfheorg.github.io/openfhe.R/reference/eval_sum_rows.md),
  [`eval_at_index()`](https://openfheorg.github.io/openfhe.R/reference/eval_at_index.md),
  [`composed_eval_mult()`](https://openfheorg.github.io/openfhe.R/reference/composed_eval_mult.md)
  and
  [`eval_mult_keys_gen()`](https://openfheorg.github.io/openfhe.R/reference/eval_mult_keys_gen.md).

- New in-place forms
  [`eval_square_in_place()`](https://openfheorg.github.io/openfhe.R/reference/eval_square_in_place.md),
  [`rescale_in_place()`](https://openfheorg.github.io/openfhe.R/reference/eval_square_in_place.md),
  [`relinearize_in_place()`](https://openfheorg.github.io/openfhe.R/reference/eval_square_in_place.md),
  [`eval_add_mutable_in_place()`](https://openfheorg.github.io/openfhe.R/reference/eval_add_mutable_in_place.md),
  [`eval_sub_mutable_in_place()`](https://openfheorg.github.io/openfhe.R/reference/eval_add_mutable_in_place.md)
  and
  [`eval_mult_mutable_in_place()`](https://openfheorg.github.io/openfhe.R/reference/eval_add_mutable_in_place.md),
  and the unchecked forms
  [`eval_add_in_place_no_check()`](https://openfheorg.github.io/openfhe.R/reference/eval_add_in_place_no_check.md),
  [`eval_mult_no_check()`](https://openfheorg.github.io/openfhe.R/reference/eval_add_in_place_no_check.md)
  and
  [`eval_mult_no_relin_no_check()`](https://openfheorg.github.io/openfhe.R/reference/eval_add_in_place_no_check.md).

- Proxy re-encryption:
  [`re_key_gen()`](https://openfheorg.github.io/openfhe.R/reference/re_key_gen.md)
  and
  [`re_encrypt()`](https://openfheorg.github.io/openfhe.R/reference/re_key_gen.md).

- [`make_string_plaintext()`](https://openfheorg.github.io/openfhe.R/reference/make_string_plaintext.md)
  encodes a character string.

- New accessors. On a context:
  [`get_modulus()`](https://openfheorg.github.io/openfhe.R/reference/get_modulus.md),
  [`get_modulus_ckks()`](https://openfheorg.github.io/openfhe.R/reference/get_modulus_ckks.md),
  [`get_root_of_unity()`](https://openfheorg.github.io/openfhe.R/reference/get_modulus_ckks.md),
  [`get_scheme()`](https://openfheorg.github.io/openfhe.R/reference/ccparams_getters.md),
  [`set_scheme_id()`](https://openfheorg.github.io/openfhe.R/reference/set_scheme_id.md),
  [`serialized_object_name()`](https://openfheorg.github.io/openfhe.R/reference/serialized_object_name.md),
  [`serialized_version()`](https://openfheorg.github.io/openfhe.R/reference/serialized_object_name.md),
  [`clear_all_ckks_caches()`](https://openfheorg.github.io/openfhe.R/reference/clear_all_ckks_caches.md),
  [`clear_bootstrap_precom()`](https://openfheorg.github.io/openfhe.R/reference/clear_all_ckks_caches.md),
  [`clear_scheme_switch_precom()`](https://openfheorg.github.io/openfhe.R/reference/clear_all_ckks_caches.md),
  [`get_plaintext_for_decrypt()`](https://openfheorg.github.io/openfhe.R/reference/get_plaintext_for_decrypt.md),
  the automorphism key index queries
  [`get_existing_eval_automorphism_key_indices()`](https://openfheorg.github.io/openfhe.R/reference/get_existing_eval_automorphism_key_indices.md),
  [`get_eval_automorphism_no_key_indices()`](https://openfheorg.github.io/openfhe.R/reference/get_existing_eval_automorphism_key_indices.md)
  and
  [`get_unique_values()`](https://openfheorg.github.io/openfhe.R/reference/get_existing_eval_automorphism_key_indices.md),
  and
  [`set_multiplicative_depth()`](https://openfheorg.github.io/openfhe.R/reference/ccparams_setters.md),
  [`set_eval_add_count()`](https://openfheorg.github.io/openfhe.R/reference/ccparams_setters.md),
  [`set_key_switch_count()`](https://openfheorg.github.io/openfhe.R/reference/ccparams_setters.md),
  [`set_pre_num_hops()`](https://openfheorg.github.io/openfhe.R/reference/ccparams_setters.md)
  and
  [`set_noise_estimate()`](https://openfheorg.github.io/openfhe.R/reference/ccparams_setters.md)
  on a live context. On a ciphertext:
  [`clone()`](https://openfheorg.github.io/openfhe.R/reference/clone.md),
  [`clone_empty()`](https://openfheorg.github.io/openfhe.R/reference/clone.md),
  [`number_ciphertext_elements()`](https://openfheorg.github.io/openfhe.R/reference/number_ciphertext_elements.md),
  [`get_elements()`](https://openfheorg.github.io/openfhe.R/reference/number_ciphertext_elements.md),
  [`set_elements()`](https://openfheorg.github.io/openfhe.R/reference/number_ciphertext_elements.md),
  [`remove_element()`](https://openfheorg.github.io/openfhe.R/reference/number_ciphertext_elements.md),
  [`get_hop_level()`](https://openfheorg.github.io/openfhe.R/reference/get_hop_level.md),
  [`set_hop_level()`](https://openfheorg.github.io/openfhe.R/reference/get_hop_level.md)
  and
  [`set_encoding_type()`](https://openfheorg.github.io/openfhe.R/reference/get_hop_level.md).
  On a plaintext:
  [`encode()`](https://openfheorg.github.io/openfhe.R/reference/encode.md),
  [`decode()`](https://openfheorg.github.io/openfhe.R/reference/encode.md),
  [`get_element_modulus()`](https://openfheorg.github.io/openfhe.R/reference/get_element_modulus.md),
  [`get_encoding_params()`](https://openfheorg.github.io/openfhe.R/reference/get_encoding_params.md)
  and
  [`set_format()`](https://openfheorg.github.io/openfhe.R/reference/get_element_modulus.md).

- [`get_modulus()`](https://openfheorg.github.io/openfhe.R/reference/get_modulus.md),
  [`ring_dimension()`](https://openfheorg.github.io/openfhe.R/reference/ring_dimension.md)
  and
  [`get_cyclotomic_order()`](https://openfheorg.github.io/openfhe.R/reference/get_cyclotomic_order.md)
  work on an `ElementParams` object;
  [`get_batch_size()`](https://openfheorg.github.io/openfhe.R/reference/ccparams_getters.md),
  [`get_plaintext_modulus()`](https://openfheorg.github.io/openfhe.R/reference/ccparams_getters.md)
  and the new
  [`get_plaintext_generator()`](https://openfheorg.github.io/openfhe.R/reference/get_plaintext_generator.md)
  on an `EncodingParams` object;
  [`get_key_tag()`](https://openfheorg.github.io/openfhe.R/reference/key_tag.md)
  and
  [`set_key_tag()`](https://openfheorg.github.io/openfhe.R/reference/key_tag.md)
  on an `EvalKey`;
  [`get_crypto_context()`](https://openfheorg.github.io/openfhe.R/reference/get_crypto_context.md)
  on a public or secret key.

- New classes `DCRTPoly` and `SchemeBase` (opaque handles) and enum
  `Format`.

- Key switching:
  [`key_switch_gen()`](https://openfheorg.github.io/openfhe.R/reference/key_switch_gen.md),
  [`key_switch()`](https://openfheorg.github.io/openfhe.R/reference/key_switch_gen.md),
  [`key_switch_in_place()`](https://openfheorg.github.io/openfhe.R/reference/key_switch_gen.md),
  [`key_switch_ext()`](https://openfheorg.github.io/openfhe.R/reference/key_switch_ext.md)
  and
  [`key_switch_down_first_element()`](https://openfheorg.github.io/openfhe.R/reference/key_switch_ext.md).
  [`multi_mult_eval_key()`](https://openfheorg.github.io/openfhe.R/reference/multi_mult_eval_key.md)
  completes the threshold multiplication-key protocol.
  [`sparse_key_gen()`](https://openfheorg.github.io/openfhe.R/reference/sparse_key_gen.md)
  is bound as the C++ library declares it.

- [`clear_eval_sum_keys()`](https://openfheorg.github.io/openfhe.R/reference/clear_eval_sum_keys.md),
  [`get_all_contexts()`](https://openfheorg.github.io/openfhe.R/reference/get_all_contexts.md),
  and
  [`enable_precompute_crt_tables_after_deserializaton()`](https://openfheorg.github.io/openfhe.R/reference/enable_precompute_crt_tables_after_deserializaton.md)
  with its `disable_` counterpart.

- [`eval_chebyshev_function_ptxt()`](https://openfheorg.github.io/openfhe.R/reference/eval_chebyshev_function_ptxt.md)
  evaluates a Chebyshev approximation in the clear, and
  [`get_multiplicative_depth_by_coeff_vector()`](https://openfheorg.github.io/openfhe.R/reference/get_multiplicative_depth_by_coeff_vector.md)
  gives the depth a polynomial evaluation consumes.

- [`eval_powers()`](https://openfheorg.github.io/openfhe.R/reference/eval_powers.md)
  and
  [`eval_cheby_polys()`](https://openfheorg.github.io/openfhe.R/reference/eval_powers.md)
  compute the powers, or the Chebyshev polynomials, of a ciphertext
  once, as an object of the new class `SeriesPowers`;
  [`eval_poly_with_precomp()`](https://openfheorg.github.io/openfhe.R/reference/eval_powers.md)
  and
  [`eval_chebyshev_series_with_precomp()`](https://openfheorg.github.io/openfhe.R/reference/eval_powers.md)
  then evaluate any number of series of the same degree from it.

- [`eval_bootstrap_precompute()`](https://openfheorg.github.io/openfhe.R/reference/eval_bootstrap_precompute.md)
  computes the plaintexts of CKKS bootstrapping after a setup with
  `precompute = FALSE`, and
  [`eval_bootstrap_stc_first()`](https://openfheorg.github.io/openfhe.R/reference/eval_bootstrap_stc_first.md)
  runs the slots-encoding variant of bootstrapping.

- CKKS functional bootstrapping, which refreshes a ciphertext and
  applies a function to it in one step. For a look-up table on integers:
  [`eval_fbt_setup()`](https://openfheorg.github.io/openfhe.R/reference/eval_fbt_setup.md),
  [`eval_fbt()`](https://openfheorg.github.io/openfhe.R/reference/eval_fbt_setup.md),
  [`eval_fbt_no_decoding()`](https://openfheorg.github.io/openfhe.R/reference/eval_fbt_setup.md)
  and
  [`eval_hom_decoding()`](https://openfheorg.github.io/openfhe.R/reference/eval_fbt_setup.md);
  for several tables on one input,
  [`eval_mvb_precompute()`](https://openfheorg.github.io/openfhe.R/reference/eval_mvb_precompute.md),
  [`eval_mvb()`](https://openfheorg.github.io/openfhe.R/reference/eval_mvb_precompute.md)
  and
  [`eval_mvb_no_decoding()`](https://openfheorg.github.io/openfhe.R/reference/eval_mvb_precompute.md);
  with
  [`get_hermite_trig_coefficients()`](https://openfheorg.github.io/openfhe.R/reference/get_hermite_trig_coefficients.md),
  [`get_fbt_depth()`](https://openfheorg.github.io/openfhe.R/reference/get_fbt_depth.md)
  and
  [`eval_hermite_trig_series()`](https://openfheorg.github.io/openfhe.R/reference/eval_hermite_trig_series.md).
  For a Fourier series on real values:
  [`eval_fe_func_bootstrap_setup()`](https://openfheorg.github.io/openfhe.R/reference/eval_fe_func_bootstrap_setup.md),
  [`eval_fe_func_bootstrap()`](https://openfheorg.github.io/openfhe.R/reference/eval_fe_func_bootstrap_setup.md),
  [`eval_fe_func_bootstrap_precompute()`](https://openfheorg.github.io/openfhe.R/reference/eval_fe_func_bootstrap_setup.md),
  [`eval_fe_func_bootstrap_with_precomp()`](https://openfheorg.github.io/openfhe.R/reference/eval_fe_func_bootstrap_setup.md)
  and
  [`get_fefbt_depth()`](https://openfheorg.github.io/openfhe.R/reference/get_fbt_depth.md).

- The RLWE schemelet that functional bootstrapping takes its input from:
  [`schemelet_get_element_params()`](https://openfheorg.github.io/openfhe.R/reference/schemelet_get_element_params.md),
  [`schemelet_encrypt_coeff()`](https://openfheorg.github.io/openfhe.R/reference/schemelet_get_element_params.md),
  [`schemelet_decrypt_coeff()`](https://openfheorg.github.io/openfhe.R/reference/schemelet_get_element_params.md),
  [`schemelet_mod_switch()`](https://openfheorg.github.io/openfhe.R/reference/schemelet_get_element_params.md),
  [`schemelet_convert_rlwe_to_ckks()`](https://openfheorg.github.io/openfhe.R/reference/schemelet_convert_rlwe_to_ckks.md),
  [`schemelet_convert_ckks_to_rlwe()`](https://openfheorg.github.io/openfhe.R/reference/schemelet_convert_rlwe_to_ckks.md)
  and
  [`schemelet_get_q_prime()`](https://openfheorg.github.io/openfhe.R/reference/schemelet_get_element_params.md),
  with the new class `PolyVector`
  ([`length()`](https://rdrr.io/r/base/length.html),
  [`clone()`](https://openfheorg.github.io/openfhe.R/reference/clone.md),
  `-`,
  [`switch_modulus()`](https://openfheorg.github.io/openfhe.R/reference/PolyVector.md)).

- Scheme switching between CKKS and FHEW. From CKKS to FHEW:
  [`eval_ckks_to_fhew_setup()`](https://openfheorg.github.io/openfhe.R/reference/eval_ckks_to_fhew_setup.md),
  [`eval_ckks_to_fhew_key_gen()`](https://openfheorg.github.io/openfhe.R/reference/eval_ckks_to_fhew_setup.md),
  [`eval_ckks_to_fhew_precompute()`](https://openfheorg.github.io/openfhe.R/reference/eval_ckks_to_fhew_setup.md)
  and
  [`eval_ckks_to_fhew()`](https://openfheorg.github.io/openfhe.R/reference/eval_ckks_to_fhew_setup.md).
  From FHEW to CKKS:
  [`eval_fhew_to_ckks_setup()`](https://openfheorg.github.io/openfhe.R/reference/eval_fhew_to_ckks_setup.md),
  [`eval_fhew_to_ckks_key_gen()`](https://openfheorg.github.io/openfhe.R/reference/eval_fhew_to_ckks_setup.md)
  and
  [`eval_fhew_to_ckks()`](https://openfheorg.github.io/openfhe.R/reference/eval_fhew_to_ckks_setup.md).
  Both ways:
  [`eval_scheme_switching_setup()`](https://openfheorg.github.io/openfhe.R/reference/eval_scheme_switching_setup.md),
  [`eval_scheme_switching_key_gen()`](https://openfheorg.github.io/openfhe.R/reference/eval_scheme_switching_setup.md),
  [`eval_compare_switch_precompute()`](https://openfheorg.github.io/openfhe.R/reference/eval_scheme_switching_setup.md),
  [`eval_compare_scheme_switching()`](https://openfheorg.github.io/openfhe.R/reference/eval_scheme_switching_setup.md),
  [`eval_min_scheme_switching()`](https://openfheorg.github.io/openfhe.R/reference/eval_scheme_switching_setup.md),
  [`eval_max_scheme_switching()`](https://openfheorg.github.io/openfhe.R/reference/eval_scheme_switching_setup.md)
  and their `_alt` forms. The parameters are an object of the new class
  `SchSwchParams`, with a `set_` and a `get_` function per field (see
  [`?SchSwchParams`](https://openfheorg.github.io/openfhe.R/reference/SchSwchParams.md)).
  Also
  [`get_bin_cc_for_scheme_switch()`](https://openfheorg.github.io/openfhe.R/reference/get_bin_cc_for_scheme_switch.md),
  [`set_bin_cc_for_scheme_switch()`](https://openfheorg.github.io/openfhe.R/reference/get_bin_cc_for_scheme_switch.md),
  [`get_swk_fc()`](https://openfheorg.github.io/openfhe.R/reference/get_bin_cc_for_scheme_switch.md),
  [`set_swk_fc()`](https://openfheorg.github.io/openfhe.R/reference/get_bin_cc_for_scheme_switch.md)
  and
  [`set_params_from_ckks_cryptocontext()`](https://openfheorg.github.io/openfhe.R/reference/set_params_from_ckks_cryptocontext.md).

- New classes `SchemeSwitchingDataSerializer` and
  `SchemeSwitchingDataDeserializer` write and read everything a
  scheme-switching computation needs in another session, with
  [`set_data_directory()`](https://openfheorg.github.io/openfhe.R/reference/SchemeSwitchingDataSerializer.md),
  [`serialize_scheme_switching_data()`](https://openfheorg.github.io/openfhe.R/reference/SchemeSwitchingDataSerializer.md),
  [`deserialize_scheme_switching_data()`](https://openfheorg.github.io/openfhe.R/reference/SchemeSwitchingDataSerializer.md)
  and
  [`get_raw_ciphertext()`](https://openfheorg.github.io/openfhe.R/reference/SchemeSwitchingDataSerializer.md).
  Unlike the C++ classes they have no default directory.

- Binary FHE, public-key encryption:
  [`bin_key_gen_pair()`](https://openfheorg.github.io/openfhe.R/reference/bin_key_gen_pair.md),
  [`bin_pub_key_gen()`](https://openfheorg.github.io/openfhe.R/reference/bin_key_gen_pair.md),
  [`bin_key_gen_n()`](https://openfheorg.github.io/openfhe.R/reference/bin_key_gen_pair.md),
  [`bin_key_switch_gen()`](https://openfheorg.github.io/openfhe.R/reference/bin_key_gen_pair.md)
  and
  [`switch_ct_to_qn()`](https://openfheorg.github.io/openfhe.R/reference/switch_ct_to_qn.md),
  with the new classes `LWEPublicKey`, `LWEKeyPair` and
  `LWESwitchingKey`.
  [`bin_encrypt()`](https://openfheorg.github.io/openfhe.R/reference/bin_encrypt.md)
  accepts an `LWEPublicKey` in place of the secret key.

- Binary FHE, bootstrapping keys as objects:
  [`get_bt_key()`](https://openfheorg.github.io/openfhe.R/reference/get_bt_key.md),
  [`get_bt_key_map()`](https://openfheorg.github.io/openfhe.R/reference/get_bt_key.md),
  [`bin_bt_key_load()`](https://openfheorg.github.io/openfhe.R/reference/get_bt_key.md),
  [`bin_bt_key_map_load_single_element()`](https://openfheorg.github.io/openfhe.R/reference/get_bt_key.md),
  [`bin_clear_bt_keys()`](https://openfheorg.github.io/openfhe.R/reference/get_bt_key.md),
  [`get_switch_key()`](https://openfheorg.github.io/openfhe.R/reference/get_bt_key.md),
  [`get_public_key()`](https://openfheorg.github.io/openfhe.R/reference/get_public_key.md),
  [`has_internal32_refresh_key()`](https://openfheorg.github.io/openfhe.R/reference/get_bt_key.md)
  and
  [`has_internal32_switch_key()`](https://openfheorg.github.io/openfhe.R/reference/get_bt_key.md),
  with the new class `RingGSWBTKey`.

- [`fhe_serialize()`](https://openfheorg.github.io/openfhe.R/reference/fhe_serialize.md)
  and
  [`fhe_deserialize()`](https://openfheorg.github.io/openfhe.R/reference/fhe_deserialize.md)
  handle the Binary FHE classes `BinFHEContext`, `LWECiphertext`,
  `LWEPrivateKey`, `LWEPublicKey` and `RingGSWBTKey`, so a Boolean
  circuit can be set up in one session and evaluated in another.

- Binary FHE, other additions:
  [`bin_bootstrap()`](https://openfheorg.github.io/openfhe.R/reference/bin_bootstrap.md),
  [`eval_constant()`](https://openfheorg.github.io/openfhe.R/reference/eval_constant.md),
  [`eval_decomp()`](https://openfheorg.github.io/openfhe.R/reference/eval_decomp.md);
  the parameter accessors
  [`get_n()`](https://openfheorg.github.io/openfhe.R/reference/get_n.md),
  [`get_big_n()`](https://openfheorg.github.io/openfhe.R/reference/get_n.md),
  [`get_q()`](https://openfheorg.github.io/openfhe.R/reference/get_n.md),
  [`get_big_q()`](https://openfheorg.github.io/openfhe.R/reference/get_n.md)
  and
  [`get_beta()`](https://openfheorg.github.io/openfhe.R/reference/get_n.md);
  [`get_pt_modulus()`](https://openfheorg.github.io/openfhe.R/reference/get_pt_modulus.md),
  [`set_modulus()`](https://openfheorg.github.io/openfhe.R/reference/get_pt_modulus.md)
  and
  [`set_pt_modulus()`](https://openfheorg.github.io/openfhe.R/reference/get_pt_modulus.md)
  on an `LWECiphertext`;
  [`get_modulus()`](https://openfheorg.github.io/openfhe.R/reference/get_modulus.md)
  and
  [`get_length()`](https://openfheorg.github.io/openfhe.R/reference/plaintext_accessors.md)
  on LWE ciphertexts and keys, which also compare with `==` and `!=`;
  [`serialized_object_name()`](https://openfheorg.github.io/openfhe.R/reference/serialized_object_name.md)
  and
  [`serialized_version()`](https://openfheorg.github.io/openfhe.R/reference/serialized_object_name.md)
  on a `BinFHEContext`.

- Serialization in memory.
  [`fhe_serialize()`](https://openfheorg.github.io/openfhe.R/reference/fhe_serialize.md)
  with no file name returns the serialized object, a raw vector for the
  binary format and a character string for JSON, and the new
  [`fhe_deserialize_string()`](https://openfheorg.github.io/openfhe.R/reference/fhe_deserialize_string.md)
  reads it back.
  [`serialize_eval_keys()`](https://openfheorg.github.io/openfhe.R/reference/serialize_eval_keys.md)
  with no file name does the same for the key registries, with the new
  [`deserialize_eval_keys_string()`](https://openfheorg.github.io/openfhe.R/reference/deserialize_eval_keys_string.md).

- [`fhe_serialize()`](https://openfheorg.github.io/openfhe.R/reference/fhe_serialize.md)
  and
  [`fhe_deserialize()`](https://openfheorg.github.io/openfhe.R/reference/fhe_deserialize.md)
  handle `EvalKey` and `EvalKeyMap` objects, and
  [`fhe_serialize()`](https://openfheorg.github.io/openfhe.R/reference/fhe_serialize.md)
  a list of `EvalKey` objects (in memory).

- [`serialize_eval_keys()`](https://openfheorg.github.io/openfhe.R/reference/serialize_eval_keys.md)
  gains `cc`, to serialize the keys of one context.

- New
  [`serialize_eval_bootstrap_key()`](https://openfheorg.github.io/openfhe.R/reference/serialize_eval_bootstrap_key.md)
  and
  [`deserialize_eval_bootstrap_key()`](https://openfheorg.github.io/openfhe.R/reference/serialize_eval_bootstrap_key.md)
  write and read the automorphism keys that CKKS bootstrapping uses.

- Integers that can exceed 53 bits are exchanged as strings of decimal
  digits, because an R number cannot hold them exactly.
  [`get_scaling_factor_int()`](https://openfheorg.github.io/openfhe.R/reference/plaintext_accessors.md)
  now returns such a string, and
  [`set_scaling_factor_int()`](https://openfheorg.github.io/openfhe.R/reference/plaintext_accessors.md)
  accepts one. Arguments of this kind also accept a whole number of at
  most 2^53.

- The `plaintext_modulus` argument of
  [`BFVParams()`](https://openfheorg.github.io/openfhe.R/reference/BFVParams.md)
  and
  [`BGVParams()`](https://openfheorg.github.io/openfhe.R/reference/BGVParams.md)
  accepts any 64-bit value; values above 2^31 were previously turned
  into `NA`.
  [`get_plaintext_modulus()`](https://openfheorg.github.io/openfhe.R/reference/ccparams_getters.md)
  returns a string of decimal digits when the modulus is above 2^53.

## openfhe.R 1.5.1.2

CRAN release: 2026-09-25

- Under `R CMD check` the package caps OpenFHE at two threads.

- [`set_num_threads()`](https://openfheorg.github.io/openfhe.R/reference/set_num_threads.md)
  now sets the cap through OpenFHE’s own thread controls rather than the
  OpenMP runtime, and returns the cap in effect (invisibly).

- The package now installs on musl-based Linux (Alpine).

- `rlang` is declared in `Imports`.

- Every handle the package passes between R and C++ now carries its
  type, and every binding checks that type before using the pointer.

- [`bin_fhe_context()`](https://openfheorg.github.io/openfhe.R/reference/bin_fhe_context.md)
  returns an object of the new `BinFHEContext` class instead of the base
  `OpenFHEObject`. The boolean-circuit context and the `CryptoContext`
  used by BFV, BGV, and CKKS are therefore distinct classes, and passing
  one where the other belongs is an error rather than a silent misuse.

- `OpenFHEObject`, the base class, is now abstract. It was never useful
  to construct directly, and every handle now belongs to a concrete
  class.

- [`decrypt()`](https://openfheorg.github.io/openfhe.R/reference/decrypt.md)
  accepts its arguments in either order, matching the C++ library, which
  declares both. `decrypt(private_key, ciphertext)` is now equivalent to
  `decrypt(ciphertext, private_key)`.

## openfhe.R 1.5.1.1

CRAN release: 2026-08-23

- Fixed undefined behavior in the vendored OpenFHE library reported by
  CRAN’s UBSAN check platforms.
  `RingGSWAccumulator::SignedDigitDecompose` sign-extended a balanced
  digit by shifting a signed value into and past the sign bit, which is
  undefined in C++17. The vendored library now carries the upstream fix
  (OpenFHE PR
  [\#1238](https://github.com/openfheorg/openfhe.R/issues/1238)), which
  computes the same digits without signed shifts. Results are unchanged.

- The
  [`eval_sign()`](https://openfheorg.github.io/openfhe.R/reference/eval_sign.md)
  example in the BinFHE vignette and its corresponding test are skipped
  on CRAN, where their bootstrapping-key generation dominated the check
  time. Both still run on CI and locally.

## openfhe.R 1.5.1

CRAN release: 2026-08-21

Initial release. An R interface to the OpenFHE C++ library for fully
homomorphic encryption, with a binding surface that mirrors
openfhe-python.

- Supports the BFV, BGV, and CKKS schemes for computation on encrypted
  integers and approximate reals, plus BinFHE (FHEW/TFHE) for Boolean
  circuits over encrypted bits.

- Provides threshold (multiparty) FHE, including interactive
  bootstrapping, for computations shared across several key-holders.

- Built on S7 classes and cpp11 bindings; the OpenFHE C++ library is
  vendored and built from source, so the package version tracks the
  library version.

- Ships an API tour vignette plus worked examples of CKKS bootstrapping
  and BinFHE Boolean circuits.
