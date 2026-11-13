# openfhe.R 1.6.1

* The vendored library is OpenFHE 1.6.1. Every class, method and enum
  that the Python package `openfhe` 1.6.1.0 exposes has an R
  counterpart. Its tests and examples are run as tests of this
  package, except one example that needs a 128-bit build of the
  library.

* Contexts, keys and ciphertexts saved by openfhe.R 1.5.1.2, in the
  binary or the JSON format, are read by this version.

* `BinFHEParamSet` has the 112 members of OpenFHE 1.6.1. Every member
  except `TOY` and `MEDIUM` has a new integer value, so code must refer
  to members by name (`BinFHEParamSet$STD128`), never by number.

* OpenFHE 1.6.1 redefines the predefined Binary FHE parameter sets
  under their old names. `BinFHEParamSet$STD128_AP` now works only
  with `BinFHEMethod$AP`.

* `bin_fhe_context()` builds the context for arbitrary-function
  evaluation whenever `arb_func`, `log_q`, `n` or `time_optimization`
  is supplied, as the C++ library does. Before, supplying
  `arb_func = FALSE` alone built the Boolean-gate context, which has
  different parameters.

* `serialize_eval_keys()` to a file that cannot be opened is an error.
  Before, the JSON format returned `TRUE` and wrote nothing.

* `find_automorphism_index()` and `find_automorphism_indices()` refuse
  a value outside the 32-bit integer range.

* `length()` of the object `share_keys()` returns is the number of
  shares.

* Functions that return an encrypted value, a key or another handle
  no longer go through the 'S7' constructor, which saves about 45
  microseconds per call.

* `bin_bt_key_gen()` gains the argument `internal32`.

* The help pages for `bin_fhe_context()`, `bin_bt_key_gen()` and
  `bin_clear_bt_keys()` have a section on memory. The bootstrapping
  keys of a context can occupy several gigabytes that R's garbage
  collector does not see; `bin_clear_bt_keys()` releases them at once.

* `bin_encrypt()` defaults to `output = BinFHEOutput$BOOTSTRAPPED`, and
  `get_bootstrap_depth()` to `SecretKeyDist$UNIFORM_TERNARY`, as in
  OpenFHE 1.6.1.

* `eval_add()`, `eval_sub()` and `eval_mult()`, with their `_in_place`
  and `_mutable` forms, accept every operand order and type the C++
  library declares: a plaintext or a number as the first operand, and
  complex numbers for a CKKS context with complex data.
  `eval_sub(2, ct)` now calls the library's own scalar-first
  subtraction.

* `eval_poly()`, `eval_chebyshev()` and their `_linear` and `_ps` forms
  accept integer and complex coefficient vectors as well as doubles.
  An integer vector is now evaluated with integer arithmetic; it was
  converted to double before. At OpenFHE 1.6.1 the Paterson-Stockmeyer
  Chebyshev evaluator returns wrong values for integer coefficients, so
  pass whole-number Chebyshev coefficients as doubles.

* `eval_bin_gate()` gains `extended`. `eval_floor()` and `compress()`
  take the library defaults `roundbits = 0` and `towers_left = 1`.
  `level_reduce()` and `level_reduce_in_place()` accept `NULL` for the
  evaluation key. `get_bootstrap_depth()` gains `approx_mod_depth`.
  `multiparty_key_gen()` accepts a list of secret keys.
  `get_length()` works on an `LWECiphertext`.

* New `set_*` functions change one parameter of a `BFVParams`,
  `BGVParams` or `CKKSParams` object after it has been constructed
  (`set_multiplicative_depth()`, `set_ring_dim()` and 30 others; see
  `?ccparams_setters`), so a parameter object can be built step by step
  as the OpenFHE examples do. `format()` and `print()` of a parameter
  object show every field.

* New `gen_crypto_context()` builds a context from a parameter object
  and enables no feature, as OpenFHE's `GenCryptoContext()` does.
  `fhe_context()` is unchanged.

* `make_ckks_packed_plaintext()` accepts `params` with complex values.

* New evaluation functions: `eval_add_many()`,
  `eval_add_many_in_place()`, `eval_mult_many()`, `eval_merge()`,
  `eval_linear_wsum()`, `eval_linear_wsum_mutable()`,
  `eval_inner_product()`, `eval_sum_rows()`, `eval_sum_cols()` with
  `eval_sum_rows_key_gen()` and `eval_sum_cols_key_gen()`,
  `eval_at_index()`, `composed_eval_mult()` and `eval_mult_keys_gen()`.

* New in-place forms `eval_square_in_place()`, `rescale_in_place()`,
  `relinearize_in_place()`, `eval_add_mutable_in_place()`,
  `eval_sub_mutable_in_place()` and `eval_mult_mutable_in_place()`, and
  the unchecked forms `eval_add_in_place_no_check()`,
  `eval_mult_no_check()` and `eval_mult_no_relin_no_check()`.

* Proxy re-encryption: `re_key_gen()` and `re_encrypt()`.

* `make_string_plaintext()` encodes a character string.

* New accessors. On a context: `get_modulus()`, `get_modulus_ckks()`,
  `get_root_of_unity()`, `get_scheme()`, `set_scheme_id()`,
  `serialized_object_name()`, `serialized_version()`,
  `clear_all_ckks_caches()`, `clear_bootstrap_precom()`,
  `clear_scheme_switch_precom()`, `get_plaintext_for_decrypt()`, the
  automorphism key index queries
  `get_existing_eval_automorphism_key_indices()`,
  `get_eval_automorphism_no_key_indices()` and `get_unique_values()`,
  and `set_multiplicative_depth()`, `set_eval_add_count()`,
  `set_key_switch_count()`, `set_pre_num_hops()` and
  `set_noise_estimate()` on a live context. On a ciphertext: `clone()`,
  `clone_empty()`, `number_ciphertext_elements()`, `get_elements()`,
  `set_elements()`, `remove_element()`, `get_hop_level()`,
  `set_hop_level()` and `set_encoding_type()`. On a plaintext:
  `encode()`, `decode()`, `get_element_modulus()`,
  `get_encoding_params()` and `set_format()`.

* `get_modulus()`, `ring_dimension()` and `get_cyclotomic_order()` work
  on an `ElementParams` object; `get_batch_size()`,
  `get_plaintext_modulus()` and the new `get_plaintext_generator()` on
  an `EncodingParams` object; `get_key_tag()` and `set_key_tag()` on an
  `EvalKey`; `get_crypto_context()` on a public or secret key.

* New classes `DCRTPoly` and `SchemeBase` (opaque handles) and enum
  `Format`.

* Key switching: `key_switch_gen()`, `key_switch()`,
  `key_switch_in_place()`, `key_switch_ext()` and
  `key_switch_down_first_element()`. `multi_mult_eval_key()` completes
  the threshold multiplication-key protocol. `sparse_key_gen()` is
  bound as the C++ library declares it.

* `clear_eval_sum_keys()`, `get_all_contexts()`, and
  `enable_precompute_crt_tables_after_deserializaton()` with its
  `disable_` counterpart.

* `eval_chebyshev_function_ptxt()` evaluates a Chebyshev approximation
  in the clear, and `get_multiplicative_depth_by_coeff_vector()` gives
  the depth a polynomial evaluation consumes.

* `eval_powers()` and `eval_cheby_polys()` compute the powers, or the
  Chebyshev polynomials, of a ciphertext once, as an object of the new
  class `SeriesPowers`; `eval_poly_with_precomp()` and
  `eval_chebyshev_series_with_precomp()` then evaluate any number of
  series of the same degree from it.

* `eval_bootstrap_precompute()` computes the plaintexts of CKKS
  bootstrapping after a setup with `precompute = FALSE`, and
  `eval_bootstrap_stc_first()` runs the slots-encoding variant of
  bootstrapping.

* CKKS functional bootstrapping, which refreshes a ciphertext and
  applies a function to it in one step. For a look-up table on
  integers: `eval_fbt_setup()`, `eval_fbt()`, `eval_fbt_no_decoding()`
  and `eval_hom_decoding()`; for several tables on one input,
  `eval_mvb_precompute()`, `eval_mvb()` and `eval_mvb_no_decoding()`;
  with `get_hermite_trig_coefficients()`, `get_fbt_depth()` and
  `eval_hermite_trig_series()`. For a Fourier series on real values:
  `eval_fe_func_bootstrap_setup()`, `eval_fe_func_bootstrap()`,
  `eval_fe_func_bootstrap_precompute()`,
  `eval_fe_func_bootstrap_with_precomp()` and `get_fefbt_depth()`.

* The RLWE schemelet that functional bootstrapping takes its input
  from: `schemelet_get_element_params()`, `schemelet_encrypt_coeff()`,
  `schemelet_decrypt_coeff()`, `schemelet_mod_switch()`,
  `schemelet_convert_rlwe_to_ckks()`,
  `schemelet_convert_ckks_to_rlwe()` and `schemelet_get_q_prime()`,
  with the new class `PolyVector` (`length()`, `clone()`, `-`,
  `switch_modulus()`).

* Scheme switching between CKKS and FHEW. From CKKS to FHEW:
  `eval_ckks_to_fhew_setup()`, `eval_ckks_to_fhew_key_gen()`,
  `eval_ckks_to_fhew_precompute()` and `eval_ckks_to_fhew()`. From
  FHEW to CKKS: `eval_fhew_to_ckks_setup()`,
  `eval_fhew_to_ckks_key_gen()` and `eval_fhew_to_ckks()`. Both ways:
  `eval_scheme_switching_setup()`, `eval_scheme_switching_key_gen()`,
  `eval_compare_switch_precompute()`,
  `eval_compare_scheme_switching()`, `eval_min_scheme_switching()`,
  `eval_max_scheme_switching()` and their `_alt` forms. The parameters
  are an object of the new class `SchSwchParams`, with a `set_` and a
  `get_` function per field (see `?SchSwchParams`). Also
  `get_bin_cc_for_scheme_switch()`, `set_bin_cc_for_scheme_switch()`,
  `get_swk_fc()`, `set_swk_fc()` and
  `set_params_from_ckks_cryptocontext()`.

* New classes `SchemeSwitchingDataSerializer` and
  `SchemeSwitchingDataDeserializer` write and read everything a
  scheme-switching computation needs in another session, with
  `set_data_directory()`, `serialize_scheme_switching_data()`,
  `deserialize_scheme_switching_data()` and `get_raw_ciphertext()`.
  Unlike the C++ classes they have no default directory.

* Binary FHE, public-key encryption: `bin_key_gen_pair()`,
  `bin_pub_key_gen()`, `bin_key_gen_n()`, `bin_key_switch_gen()` and
  `switch_ct_to_qn()`, with the new classes `LWEPublicKey`,
  `LWEKeyPair` and `LWESwitchingKey`. `bin_encrypt()` accepts an
  `LWEPublicKey` in place of the secret key.

* Binary FHE, bootstrapping keys as objects: `get_bt_key()`,
  `get_bt_key_map()`, `bin_bt_key_load()`,
  `bin_bt_key_map_load_single_element()`, `bin_clear_bt_keys()`,
  `get_switch_key()`, `get_public_key()`,
  `has_internal32_refresh_key()` and `has_internal32_switch_key()`,
  with the new class `RingGSWBTKey`.

* `fhe_serialize()` and `fhe_deserialize()` handle the Binary FHE
  classes `BinFHEContext`, `LWECiphertext`, `LWEPrivateKey`,
  `LWEPublicKey` and `RingGSWBTKey`, so a Boolean circuit can be set
  up in one session and evaluated in another.

* Binary FHE, other additions: `bin_bootstrap()`, `eval_constant()`,
  `eval_decomp()`; the parameter accessors `get_n()`, `get_big_n()`,
  `get_q()`, `get_big_q()` and `get_beta()`; `get_pt_modulus()`,
  `set_modulus()` and `set_pt_modulus()` on an `LWECiphertext`;
  `get_modulus()` and `get_length()` on LWE ciphertexts and keys, which
  also compare with `==` and `!=`; `serialized_object_name()` and
  `serialized_version()` on a `BinFHEContext`.

* Serialization in memory. `fhe_serialize()` with no file name returns
  the serialized object, a raw vector for the binary format and a
  character string for JSON, and the new `fhe_deserialize_string()`
  reads it back. `serialize_eval_keys()` with no file name does the
  same for the key registries, with the new
  `deserialize_eval_keys_string()`.

* `fhe_serialize()` and `fhe_deserialize()` handle `EvalKey` and
  `EvalKeyMap` objects, and `fhe_serialize()` a list of `EvalKey`
  objects (in memory).

* `serialize_eval_keys()` gains `cc`, to serialize the keys of one
  context.

* New `serialize_eval_bootstrap_key()` and
  `deserialize_eval_bootstrap_key()` write and read the automorphism
  keys that CKKS bootstrapping uses.

* Integers that can exceed 53 bits are exchanged as strings of decimal
  digits, because an R number cannot hold them exactly.
  `get_scaling_factor_int()` now returns such a string, and
  `set_scaling_factor_int()` accepts one. Arguments of this kind also
  accept a whole number of at most 2^53.

* The `plaintext_modulus` argument of `BFVParams()` and `BGVParams()`
  accepts any 64-bit value; values above 2^31 were previously turned
  into `NA`. `get_plaintext_modulus()` returns a string of decimal
  digits when the modulus is above 2^53.

# openfhe.R 1.5.1.2

* Under `R CMD check` the package caps OpenFHE at two threads.

* `set_num_threads()` now sets the cap through OpenFHE's own thread
  controls rather than the OpenMP runtime, and returns the cap in
  effect (invisibly).

* The package now installs on musl-based Linux (Alpine).

* `rlang` is declared in `Imports`. 

* Every handle the package passes between R and C++ now carries its
  type, and every binding checks that type before using the pointer.

* `bin_fhe_context()` returns an object of the new `BinFHEContext`
  class instead of the base `OpenFHEObject`. The boolean-circuit
  context and the `CryptoContext` used by BFV, BGV, and CKKS are
  therefore distinct classes, and passing one where the other belongs
  is an error rather than a silent misuse. 
  
* `OpenFHEObject`, the base class, is now abstract. It was never useful
  to construct directly, and every handle now belongs to a concrete
  class.

* `decrypt()` accepts its arguments in either order, matching the C++
  library, which declares both. `decrypt(private_key, ciphertext)` is
  now equivalent to `decrypt(ciphertext, private_key)`. 


# openfhe.R 1.5.1.1

* Fixed undefined behavior in the vendored OpenFHE library reported by
  CRAN's UBSAN check platforms. `RingGSWAccumulator::SignedDigitDecompose`
  sign-extended a balanced digit by shifting a signed value into and past
  the sign bit, which is undefined in C++17. The vendored library now
  carries the upstream fix (OpenFHE PR #1238), which computes the same
  digits without signed shifts. Results are unchanged.

* The `eval_sign()` example in the BinFHE vignette and its corresponding
  test are skipped on CRAN, where their bootstrapping-key generation
  dominated the check time. Both still run on CI and locally.


# openfhe.R 1.5.1

Initial release. An R interface to the OpenFHE C++ library for fully
homomorphic encryption, with a binding surface that mirrors
openfhe-python.

* Supports the BFV, BGV, and CKKS schemes for computation on encrypted
  integers and approximate reals, plus BinFHE (FHEW/TFHE) for Boolean
  circuits over encrypted bits.

* Provides threshold (multiparty) FHE, including interactive
  bootstrapping, for computations shared across several key-holders.

* Built on S7 classes and cpp11 bindings; the OpenFHE C++ library is
  vendored and built from source, so the package version tracks the
  library version.

* Ships an API tour vignette plus worked examples of CKKS bootstrapping
  and BinFHE Boolean circuits.
