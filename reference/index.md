# Package index

## Context and Keys

- [`fhe_context()`](https://openfheorg.github.io/openfhe.R/reference/fhe_context.md)
  : Create a fully homomorphic encryption context
- [`gen_crypto_context()`](https://openfheorg.github.io/openfhe.R/reference/gen_crypto_context.md)
  : Generate a CryptoContext from a parameter object
- [`key_gen()`](https://openfheorg.github.io/openfhe.R/reference/key_gen.md)
  : Generate key pair
- [`enable_feature()`](https://openfheorg.github.io/openfhe.R/reference/enable_feature.md)
  : Enable a feature on a CryptoContext
- [`CryptoContext()`](https://openfheorg.github.io/openfhe.R/reference/CryptoContext.md)
  : Crypto Context
- [`BFVParams()`](https://openfheorg.github.io/openfhe.R/reference/BFVParams.md)
  : BFV Parameters
- [`BGVParams()`](https://openfheorg.github.io/openfhe.R/reference/BGVParams.md)
  : BGV Parameters
- [`CKKSParams()`](https://openfheorg.github.io/openfhe.R/reference/CKKSParams.md)
  : CKKS Parameters
- [`KeyPair()`](https://openfheorg.github.io/openfhe.R/reference/KeyPair.md)
  : Key Pair
- [`PublicKey()`](https://openfheorg.github.io/openfhe.R/reference/PublicKey.md)
  : Public Key
- [`PrivateKey()`](https://openfheorg.github.io/openfhe.R/reference/PrivateKey.md)
  : Private Key

## Encryption and Decryption

- [`encrypt()`](https://openfheorg.github.io/openfhe.R/reference/encrypt.md)
  : Encrypt a plaintext
- [`decrypt()`](https://openfheorg.github.io/openfhe.R/reference/decrypt.md)
  : Decrypt a ciphertext
- [`make_packed_plaintext()`](https://openfheorg.github.io/openfhe.R/reference/make_packed_plaintext.md)
  : Make a packed integer plaintext
- [`make_coef_packed_plaintext()`](https://openfheorg.github.io/openfhe.R/reference/make_coef_packed_plaintext.md)
  : Make a coefficient-packed integer plaintext
- [`make_ckks_packed_plaintext()`](https://openfheorg.github.io/openfhe.R/reference/make_ckks_packed_plaintext.md)
  : Make a CKKS packed plaintext from real numbers
- [`get_packed_value()`](https://openfheorg.github.io/openfhe.R/reference/get_packed_value.md)
  : Get packed integer values from a plaintext
- [`get_real_packed_value()`](https://openfheorg.github.io/openfhe.R/reference/get_real_packed_value.md)
  : Get real values from a CKKS plaintext
- [`Ciphertext()`](https://openfheorg.github.io/openfhe.R/reference/Ciphertext.md)
  : Ciphertext class
- [`Plaintext()`](https://openfheorg.github.io/openfhe.R/reference/Plaintext.md)
  : Plaintext

## Plaintext accessors

- [`get_noise_scale_deg()`](https://openfheorg.github.io/openfhe.R/reference/plaintext_accessors.md)
  [`get_length()`](https://openfheorg.github.io/openfhe.R/reference/plaintext_accessors.md)
  [`get_level()`](https://openfheorg.github.io/openfhe.R/reference/plaintext_accessors.md)
  [`get_scaling_factor()`](https://openfheorg.github.io/openfhe.R/reference/plaintext_accessors.md)
  [`get_log_precision()`](https://openfheorg.github.io/openfhe.R/reference/plaintext_accessors.md)
  [`get_formatted_values()`](https://openfheorg.github.io/openfhe.R/reference/plaintext_accessors.md)
  [`set_ckks_data_type()`](https://openfheorg.github.io/openfhe.R/reference/plaintext_accessors.md)
  [`get_encoding_type()`](https://openfheorg.github.io/openfhe.R/reference/plaintext_accessors.md)
  [`get_scaling_factor_int()`](https://openfheorg.github.io/openfhe.R/reference/plaintext_accessors.md)
  [`get_scheme_id()`](https://openfheorg.github.io/openfhe.R/reference/plaintext_accessors.md)
  [`is_encoded()`](https://openfheorg.github.io/openfhe.R/reference/plaintext_accessors.md)
  [`low_bound()`](https://openfheorg.github.io/openfhe.R/reference/plaintext_accessors.md)
  [`high_bound()`](https://openfheorg.github.io/openfhe.R/reference/plaintext_accessors.md)
  [`get_slots()`](https://openfheorg.github.io/openfhe.R/reference/plaintext_accessors.md)
  [`get_log_error()`](https://openfheorg.github.io/openfhe.R/reference/plaintext_accessors.md)
  [`get_coef_packed_value()`](https://openfheorg.github.io/openfhe.R/reference/plaintext_accessors.md)
  [`get_string_value()`](https://openfheorg.github.io/openfhe.R/reference/plaintext_accessors.md)
  [`get_element_ring_dimension()`](https://openfheorg.github.io/openfhe.R/reference/plaintext_accessors.md)
  [`set_scaling_factor()`](https://openfheorg.github.io/openfhe.R/reference/plaintext_accessors.md)
  [`set_scaling_factor_int()`](https://openfheorg.github.io/openfhe.R/reference/plaintext_accessors.md)
  [`set_noise_scale_deg()`](https://openfheorg.github.io/openfhe.R/reference/plaintext_accessors.md)
  [`set_level()`](https://openfheorg.github.io/openfhe.R/reference/plaintext_accessors.md)
  [`set_slots()`](https://openfheorg.github.io/openfhe.R/reference/plaintext_accessors.md)
  [`set_string_value()`](https://openfheorg.github.io/openfhe.R/reference/plaintext_accessors.md)
  [`set_int_vector_value()`](https://openfheorg.github.io/openfhe.R/reference/plaintext_accessors.md)
  : Plaintext accessors
- [`plaintext_params_hash()`](https://openfheorg.github.io/openfhe.R/reference/plaintext_params_hash.md)
  : Deterministic hash of a plaintext's identifying parameters

## Key tags

- [`get_key_tag()`](https://openfheorg.github.io/openfhe.R/reference/key_tag.md)
  [`set_key_tag()`](https://openfheorg.github.io/openfhe.R/reference/key_tag.md)
  : Key tag accessors
- [`is_good()`](https://openfheorg.github.io/openfhe.R/reference/is_good.md)
  : Is a KeyPair valid?

## Ciphertext accessors

- [`get_crypto_context()`](https://openfheorg.github.io/openfhe.R/reference/get_crypto_context.md)
  : Associated CryptoContext of a Ciphertext
- [`get_scaling_factor_real()`](https://openfheorg.github.io/openfhe.R/reference/get_scaling_factor_real.md)
  : Real-valued CKKS scaling factor at a modulus-chain level
- [`ckks_scaling_factor_bits()`](https://openfheorg.github.io/openfhe.R/reference/ckks_scaling_factor_bits.md)
  : CKKS scaling-mod-size in bits

## CryptoContext getters

- [`get_crypto_parameters()`](https://openfheorg.github.io/openfhe.R/reference/get_crypto_parameters.md)
  : Crypto parameters of a CryptoContext
- [`get_element_params()`](https://openfheorg.github.io/openfhe.R/reference/get_element_params.md)
  : Element parameters of a CryptoContext
- [`get_encoding_params()`](https://openfheorg.github.io/openfhe.R/reference/get_encoding_params.md)
  : Encoding parameters of a CryptoContext
- [`get_cyclotomic_order()`](https://openfheorg.github.io/openfhe.R/reference/get_cyclotomic_order.md)
  : Cyclotomic order of a CryptoContext
- [`get_key_gen_level()`](https://openfheorg.github.io/openfhe.R/reference/get_key_gen_level.md)
  : Key-generation level of a CryptoContext
- [`set_key_gen_level()`](https://openfheorg.github.io/openfhe.R/reference/set_key_gen_level.md)
  : Set the key-generation level of a CryptoContext

## Homomorphic Operations

- [`eval_add()`](https://openfheorg.github.io/openfhe.R/reference/eval_add.md)
  : Homomorphic addition
- [`eval_sub()`](https://openfheorg.github.io/openfhe.R/reference/eval_sub.md)
  : Homomorphic subtraction
- [`eval_mult()`](https://openfheorg.github.io/openfhe.R/reference/eval_mult.md)
  : Homomorphic multiplication
- [`eval_negate()`](https://openfheorg.github.io/openfhe.R/reference/eval_negate.md)
  : Homomorphic negation
- [`eval_square()`](https://openfheorg.github.io/openfhe.R/reference/eval_square.md)
  : Homomorphic squaring
- [`eval_rotate()`](https://openfheorg.github.io/openfhe.R/reference/eval_rotate.md)
  : Rotate ciphertext slots
- [`eval_sum()`](https://openfheorg.github.io/openfhe.R/reference/eval_sum.md)
  : Sum all slots in a ciphertext
- [`rescale()`](https://openfheorg.github.io/openfhe.R/reference/rescale.md)
  : Rescale a CKKS ciphertext (alias for ModReduce)
- [`ring_dimension()`](https://openfheorg.github.io/openfhe.R/reference/ring_dimension.md)
  : Ring dimension of a CryptoContext
- [`eval_add_in_place()`](https://openfheorg.github.io/openfhe.R/reference/eval_add_in_place.md)
  : Homomorphic addition in place
- [`eval_sub_in_place()`](https://openfheorg.github.io/openfhe.R/reference/eval_sub_in_place.md)
  : Homomorphic subtraction in place
- [`eval_mult_in_place()`](https://openfheorg.github.io/openfhe.R/reference/eval_mult_in_place.md)
  : Homomorphic multiplication by a number, in place
- [`eval_negate_in_place()`](https://openfheorg.github.io/openfhe.R/reference/eval_negate_in_place.md)
  : Homomorphic negation in place
- [`eval_add_mutable()`](https://openfheorg.github.io/openfhe.R/reference/eval_add_mutable.md)
  : Homomorphic add, mutable variant
- [`eval_sub_mutable()`](https://openfheorg.github.io/openfhe.R/reference/eval_sub_mutable.md)
  : Homomorphic subtract, mutable variant
- [`eval_mult_mutable()`](https://openfheorg.github.io/openfhe.R/reference/eval_mult_mutable.md)
  : Homomorphic multiply, mutable variant
- [`eval_square_mutable()`](https://openfheorg.github.io/openfhe.R/reference/eval_square_mutable.md)
  : Homomorphic square, mutable variant
- [`eval_mult_no_relin()`](https://openfheorg.github.io/openfhe.R/reference/eval_mult_no_relin.md)
  : Homomorphic multiplication without relinearization
- [`relinearize()`](https://openfheorg.github.io/openfhe.R/reference/relinearize.md)
  : Relinearize a higher-degree ciphertext
- [`eval_mult_and_relinearize()`](https://openfheorg.github.io/openfhe.R/reference/eval_mult_and_relinearize.md)
  : Fused multiply-and-relinearize
- [`mod_reduce()`](https://openfheorg.github.io/openfhe.R/reference/mod_reduce.md)
  : Reduce the modulus chain by one level
- [`mod_reduce_in_place()`](https://openfheorg.github.io/openfhe.R/reference/mod_reduce_in_place.md)
  : Reduce the modulus chain by one level, in place
- [`level_reduce()`](https://openfheorg.github.io/openfhe.R/reference/level_reduce.md)
  : Reduce the modulus chain by multiple levels
- [`level_reduce_in_place()`](https://openfheorg.github.io/openfhe.R/reference/level_reduce_in_place.md)
  : Reduce the modulus chain by multiple levels, in place
- [`compress()`](https://openfheorg.github.io/openfhe.R/reference/compress.md)
  : Compress a ciphertext to fewer towers
- [`eval_add_many()`](https://openfheorg.github.io/openfhe.R/reference/eval_add_many.md)
  [`eval_add_many_in_place()`](https://openfheorg.github.io/openfhe.R/reference/eval_add_many.md)
  [`eval_mult_many()`](https://openfheorg.github.io/openfhe.R/reference/eval_add_many.md)
  : Add or multiply a list of ciphertexts
- [`eval_merge()`](https://openfheorg.github.io/openfhe.R/reference/eval_merge.md)
  : Merge the first slots of several ciphertexts into one
- [`eval_linear_wsum()`](https://openfheorg.github.io/openfhe.R/reference/eval_linear_wsum.md)
  [`eval_linear_wsum_mutable()`](https://openfheorg.github.io/openfhe.R/reference/eval_linear_wsum.md)
  : Weighted sum of ciphertexts (CKKS)
- [`eval_inner_product()`](https://openfheorg.github.io/openfhe.R/reference/eval_inner_product.md)
  : Inner product of two encrypted vectors
- [`eval_sum_rows()`](https://openfheorg.github.io/openfhe.R/reference/eval_sum_rows.md)
  [`eval_sum_cols()`](https://openfheorg.github.io/openfhe.R/reference/eval_sum_rows.md)
  [`eval_sum_rows_key_gen()`](https://openfheorg.github.io/openfhe.R/reference/eval_sum_rows.md)
  [`eval_sum_cols_key_gen()`](https://openfheorg.github.io/openfhe.R/reference/eval_sum_rows.md)
  : Sum the rows or the columns of an encrypted matrix
- [`eval_at_index()`](https://openfheorg.github.io/openfhe.R/reference/eval_at_index.md)
  : Rotate the slots of a ciphertext by an index
- [`eval_square_in_place()`](https://openfheorg.github.io/openfhe.R/reference/eval_square_in_place.md)
  [`rescale_in_place()`](https://openfheorg.github.io/openfhe.R/reference/eval_square_in_place.md)
  [`relinearize_in_place()`](https://openfheorg.github.io/openfhe.R/reference/eval_square_in_place.md)
  : Square, rescale or relinearize a ciphertext in place
- [`eval_add_mutable_in_place()`](https://openfheorg.github.io/openfhe.R/reference/eval_add_mutable_in_place.md)
  [`eval_sub_mutable_in_place()`](https://openfheorg.github.io/openfhe.R/reference/eval_add_mutable_in_place.md)
  [`eval_mult_mutable_in_place()`](https://openfheorg.github.io/openfhe.R/reference/eval_add_mutable_in_place.md)
  : Mutable arithmetic on two ciphertexts, in place
- [`eval_add_in_place_no_check()`](https://openfheorg.github.io/openfhe.R/reference/eval_add_in_place_no_check.md)
  [`eval_mult_no_check()`](https://openfheorg.github.io/openfhe.R/reference/eval_add_in_place_no_check.md)
  [`eval_mult_no_relin_no_check()`](https://openfheorg.github.io/openfhe.R/reference/eval_add_in_place_no_check.md)
  : Arithmetic without the library's operand checks
- [`composed_eval_mult()`](https://openfheorg.github.io/openfhe.R/reference/composed_eval_mult.md)
  : Multiply two ciphertexts and reduce the modulus
- [`eval_mult_keys_gen()`](https://openfheorg.github.io/openfhe.R/reference/eval_mult_keys_gen.md)
  : Generate relinearization keys for higher powers of the secret key
- [`make_string_plaintext()`](https://openfheorg.github.io/openfhe.R/reference/make_string_plaintext.md)
  : Encode a character string as a plaintext

## Proxy re-encryption and key switching

- [`re_key_gen()`](https://openfheorg.github.io/openfhe.R/reference/re_key_gen.md)
  [`re_encrypt()`](https://openfheorg.github.io/openfhe.R/reference/re_key_gen.md)
  : Proxy re-encryption
- [`key_switch_gen()`](https://openfheorg.github.io/openfhe.R/reference/key_switch_gen.md)
  [`key_switch()`](https://openfheorg.github.io/openfhe.R/reference/key_switch_gen.md)
  [`key_switch_in_place()`](https://openfheorg.github.io/openfhe.R/reference/key_switch_gen.md)
  : Switch a ciphertext from one secret key to another
- [`key_switch_ext()`](https://openfheorg.github.io/openfhe.R/reference/key_switch_ext.md)
  [`key_switch_down_first_element()`](https://openfheorg.github.io/openfhe.R/reference/key_switch_ext.md)
  : Steps of hybrid key switching
- [`sparse_key_gen()`](https://openfheorg.github.io/openfhe.R/reference/sparse_key_gen.md)
  : Generate a sparse key pair
- [`multi_mult_eval_key()`](https://openfheorg.github.io/openfhe.R/reference/multi_mult_eval_key.md)
  : A party's share of the joint multiplication key (threshold FHE)
- [`clear_eval_sum_keys()`](https://openfheorg.github.io/openfhe.R/reference/clear_eval_sum_keys.md)
  : Remove summation keys from the registry
- [`get_all_contexts()`](https://openfheorg.github.io/openfhe.R/reference/get_all_contexts.md)
  : All contexts the library currently holds
- [`enable_precompute_crt_tables_after_deserializaton()`](https://openfheorg.github.io/openfhe.R/reference/enable_precompute_crt_tables_after_deserializaton.md)
  [`disable_precompute_crt_tables_after_deserializaton()`](https://openfheorg.github.io/openfhe.R/reference/enable_precompute_crt_tables_after_deserializaton.md)
  : Precompute CRT tables when a context is deserialized
- [`eval_chebyshev_function_ptxt()`](https://openfheorg.github.io/openfhe.R/reference/eval_chebyshev_function_ptxt.md)
  : Chebyshev approximation of a function, in the clear
- [`get_multiplicative_depth_by_coeff_vector()`](https://openfheorg.github.io/openfhe.R/reference/get_multiplicative_depth_by_coeff_vector.md)
  : Multiplicative depth of a polynomial evaluation

## CKKS Advanced

- [`eval_poly()`](https://openfheorg.github.io/openfhe.R/reference/eval_poly.md)
  : Evaluate a polynomial on a ciphertext
- [`eval_poly_linear()`](https://openfheorg.github.io/openfhe.R/reference/eval_poly_linear.md)
  : Evaluate a polynomial via the linear evaluator
- [`eval_poly_ps()`](https://openfheorg.github.io/openfhe.R/reference/eval_poly_ps.md)
  : Evaluate a polynomial via the Paterson-Stockmeyer method
- [`eval_chebyshev()`](https://openfheorg.github.io/openfhe.R/reference/eval_chebyshev.md)
  : Evaluate a Chebyshev series on a ciphertext
- [`eval_chebyshev_linear()`](https://openfheorg.github.io/openfhe.R/reference/eval_chebyshev_linear.md)
  : Evaluate a Chebyshev series via the linear evaluator
- [`eval_chebyshev_ps()`](https://openfheorg.github.io/openfhe.R/reference/eval_chebyshev_ps.md)
  : Evaluate a Chebyshev series via the Paterson-Stockmeyer method
- [`eval_chebyshev_coefficients()`](https://openfheorg.github.io/openfhe.R/reference/eval_chebyshev_coefficients.md)
  : Chebyshev coefficients for a real-valued function
- [`eval_chebyshev_function()`](https://openfheorg.github.io/openfhe.R/reference/eval_chebyshev_function.md)
  : Evaluate a user-supplied function on a CKKS ciphertext via Chebyshev
  approximation
- [`eval_powers()`](https://openfheorg.github.io/openfhe.R/reference/eval_powers.md)
  [`eval_poly_with_precomp()`](https://openfheorg.github.io/openfhe.R/reference/eval_powers.md)
  [`eval_cheby_polys()`](https://openfheorg.github.io/openfhe.R/reference/eval_powers.md)
  [`eval_chebyshev_series_with_precomp()`](https://openfheorg.github.io/openfhe.R/reference/eval_powers.md)
  : Evaluate several series on one ciphertext
- [`SeriesPowers()`](https://openfheorg.github.io/openfhe.R/reference/SeriesPowers.md)
  : Precomputed powers of a ciphertext
- [`eval_sin()`](https://openfheorg.github.io/openfhe.R/reference/eval_sin.md)
  : Evaluate sine on a ciphertext (Chebyshev approximation)
- [`eval_cos()`](https://openfheorg.github.io/openfhe.R/reference/eval_cos.md)
  : Evaluate cosine on a ciphertext
- [`eval_logistic()`](https://openfheorg.github.io/openfhe.R/reference/eval_logistic.md)
  : Evaluate logistic function on a ciphertext
- [`eval_divide()`](https://openfheorg.github.io/openfhe.R/reference/eval_divide.md)
  : Evaluate division approximation on a ciphertext
- [`eval_bootstrap()`](https://openfheorg.github.io/openfhe.R/reference/eval_bootstrap.md)
  : Perform CKKS bootstrapping
- [`eval_bootstrap_setup()`](https://openfheorg.github.io/openfhe.R/reference/eval_bootstrap_setup.md)
  : Set up CKKS bootstrapping
- [`eval_bootstrap_key_gen()`](https://openfheorg.github.io/openfhe.R/reference/eval_bootstrap_key_gen.md)
  : Generate bootstrapping keys
- [`eval_bootstrap_precompute()`](https://openfheorg.github.io/openfhe.R/reference/eval_bootstrap_precompute.md)
  : Precompute the plaintexts of CKKS bootstrapping
- [`eval_bootstrap_stc_first()`](https://openfheorg.github.io/openfhe.R/reference/eval_bootstrap_stc_first.md)
  : CKKS bootstrapping with slots-to-coefficients first
- [`get_bootstrap_depth()`](https://openfheorg.github.io/openfhe.R/reference/get_bootstrap_depth.md)
  : Get the required multiplicative depth for CKKS bootstrapping
- [`get_ckks_boot_correction_factor()`](https://openfheorg.github.io/openfhe.R/reference/get_ckks_boot_correction_factor.md)
  : Get the CKKS bootstrap correction factor
- [`set_ckks_boot_correction_factor()`](https://openfheorg.github.io/openfhe.R/reference/set_ckks_boot_correction_factor.md)
  : Set the CKKS bootstrap correction factor
- [`eval_fast_rotation()`](https://openfheorg.github.io/openfhe.R/reference/eval_fast_rotation.md)
  : Hoisted slot rotation using precomputed digits
- [`eval_fast_rotation_ext()`](https://openfheorg.github.io/openfhe.R/reference/eval_fast_rotation_ext.md)
  : Extended hoisted slot rotation
- [`eval_fast_rotation_precompute()`](https://openfheorg.github.io/openfhe.R/reference/eval_fast_rotation_precompute.md)
  : Precompute digit decomposition for hoisted fast rotations
- [`FastRotationPrecomputation()`](https://openfheorg.github.io/openfhe.R/reference/FastRotationPrecomputation.md)
  : Precomputed digit decomposition for hoisted rotations
- [`get_complex_packed_value()`](https://openfheorg.github.io/openfhe.R/reference/get_complex_packed_value.md)
  : Get complex values from a CKKS plaintext
- [`find_automorphism_index()`](https://openfheorg.github.io/openfhe.R/reference/find_automorphism_index.md)
  : Compute the automorphism index for a single slot index
- [`find_automorphism_indices()`](https://openfheorg.github.io/openfhe.R/reference/find_automorphism_indices.md)
  : Compute the automorphism indices for a list of slot indices
- [`eval_automorphism_key_gen()`](https://openfheorg.github.io/openfhe.R/reference/eval_automorphism_key_gen.md)
  : Generate automorphism evaluation keys for a set of indices
- [`eval_automorphism()`](https://openfheorg.github.io/openfhe.R/reference/eval_automorphism.md)
  : Apply an automorphism to a ciphertext

## Interactive bootstrap

- [`key_switch_down()`](https://openfheorg.github.io/openfhe.R/reference/key_switch_down.md)
  : Scale a ciphertext down from extended CRT basis to Q
- [`int_boot_decrypt()`](https://openfheorg.github.io/openfhe.R/reference/int_boot_decrypt.md)
  : Server-side masked decryption for interactive bootstrap
- [`int_boot_encrypt()`](https://openfheorg.github.io/openfhe.R/reference/int_boot_encrypt.md)
  : Client-side re-encryption for interactive bootstrap
- [`int_boot_add()`](https://openfheorg.github.io/openfhe.R/reference/int_boot_add.md)
  : Combine encrypted and unencrypted masked decryptions
- [`int_boot_adjust_scale()`](https://openfheorg.github.io/openfhe.R/reference/int_boot_adjust_scale.md)
  : Prepare a ciphertext for interactive bootstrap
- [`int_mp_boot_adjust_scale()`](https://openfheorg.github.io/openfhe.R/reference/int_mp_boot_adjust_scale.md)
  : Prepare a ciphertext for multi-party interactive bootstrap
- [`int_mp_boot_random_element_gen()`](https://openfheorg.github.io/openfhe.R/reference/int_mp_boot_random_element_gen.md)
  : Generate a common random element for multi-party bootstrap
- [`int_mp_boot_decrypt()`](https://openfheorg.github.io/openfhe.R/reference/int_mp_boot_decrypt.md)
  : Multi-party masked decryption for interactive bootstrap
- [`int_mp_boot_add()`](https://openfheorg.github.io/openfhe.R/reference/int_mp_boot_add.md)
  : Aggregate multi-party shares pairs
- [`int_mp_boot_encrypt()`](https://openfheorg.github.io/openfhe.R/reference/int_mp_boot_encrypt.md)
  : Final re-encryption for multi-party interactive bootstrap

## Serialization and key registry

- [`fhe_serialize()`](https://openfheorg.github.io/openfhe.R/reference/fhe_serialize.md)
  : Serialize an OpenFHE object
- [`fhe_deserialize()`](https://openfheorg.github.io/openfhe.R/reference/fhe_deserialize.md)
  : Deserialize an OpenFHE object from file
- [`fhe_deserialize_string()`](https://openfheorg.github.io/openfhe.R/reference/fhe_deserialize_string.md)
  : Deserialize an OpenFHE object held in memory
- [`serialize_eval_keys()`](https://openfheorg.github.io/openfhe.R/reference/serialize_eval_keys.md)
  : Serialize evaluation keys from the key registry
- [`deserialize_eval_keys()`](https://openfheorg.github.io/openfhe.R/reference/deserialize_eval_keys.md)
  : Deserialize evaluation keys from file
- [`deserialize_eval_keys_string()`](https://openfheorg.github.io/openfhe.R/reference/deserialize_eval_keys_string.md)
  : Deserialize evaluation keys held in memory
- [`serialize_eval_bootstrap_key()`](https://openfheorg.github.io/openfhe.R/reference/serialize_eval_bootstrap_key.md)
  [`deserialize_eval_bootstrap_key()`](https://openfheorg.github.io/openfhe.R/reference/serialize_eval_bootstrap_key.md)
  : Serialize the keys CKKS bootstrapping uses
- [`clear_fhe_state()`](https://openfheorg.github.io/openfhe.R/reference/clear_fhe_state.md)
  : Clear cached evaluation keys and contexts
- [`with_fhe_context()`](https://openfheorg.github.io/openfhe.R/reference/with_fhe_context.md)
  : Execute code with automatic cleanup of FHE state
- [`eval_sum_key_gen()`](https://openfheorg.github.io/openfhe.R/reference/eval_sum_key_gen.md)
  : Generate sum keys for a secret key
- [`eval_mult_key_gen()`](https://openfheorg.github.io/openfhe.R/reference/eval_mult_key_gen.md)
  : Generate relinearization (eval-mult) keys for a secret key
- [`eval_rotate_key_gen()`](https://openfheorg.github.io/openfhe.R/reference/eval_rotate_key_gen.md)
  : Generate rotation keys for a secret key
- [`eval_at_index_key_gen()`](https://openfheorg.github.io/openfhe.R/reference/eval_at_index_key_gen.md)
  : Generate at-index (rotation) keys for a secret key
- [`insert_eval_mult_key()`](https://openfheorg.github.io/openfhe.R/reference/insert_eval_mult_key.md)
  : Insert an EvalMult key vector into the cc registry
- [`insert_eval_sum_key()`](https://openfheorg.github.io/openfhe.R/reference/insert_eval_sum_key.md)
  : Insert a joined sum-key map into the cc registry
- [`insert_eval_automorphism_key()`](https://openfheorg.github.io/openfhe.R/reference/insert_eval_automorphism_key.md)
  : Insert a joined automorphism-key map into the cc registry
- [`clear_eval_mult_keys()`](https://openfheorg.github.io/openfhe.R/reference/clear_eval_mult_keys.md)
  : Clear the EvalMult key cache
- [`clear_eval_automorphism_keys()`](https://openfheorg.github.io/openfhe.R/reference/clear_eval_automorphism_keys.md)
  : Clear the EvalAutomorphism key cache
- [`get_all_eval_mult_keys()`](https://openfheorg.github.io/openfhe.R/reference/get_all_eval_mult_keys.md)
  : Retrieve all registered EvalMult key vectors
- [`get_eval_mult_key_vector()`](https://openfheorg.github.io/openfhe.R/reference/get_eval_mult_key_vector.md)
  : Retrieve the EvalMult key vector for a given key tag
- [`get_all_eval_automorphism_keys()`](https://openfheorg.github.io/openfhe.R/reference/get_all_eval_automorphism_keys.md)
  : Retrieve all registered EvalAutomorphism key maps
- [`get_eval_automorphism_key_map()`](https://openfheorg.github.io/openfhe.R/reference/get_eval_automorphism_key_map.md)
  : Retrieve the automorphism-key map for a given key tag
- [`get_all_eval_sum_keys()`](https://openfheorg.github.io/openfhe.R/reference/get_all_eval_sum_keys.md)
  : Retrieve all registered EvalSum key maps
- [`get_eval_sum_key_map()`](https://openfheorg.github.io/openfhe.R/reference/get_eval_sum_key_map.md)
  : Retrieve the sum-key map for a given key tag

## Threshold FHE

- [`multiparty_key_gen()`](https://openfheorg.github.io/openfhe.R/reference/multiparty_key_gen.md)
  : Generate a key pair for a secondary party in threshold FHE
- [`multiparty_decrypt_lead()`](https://openfheorg.github.io/openfhe.R/reference/multiparty_decrypt_lead.md)
  : Lead party's partial decryption
- [`multiparty_decrypt_main()`](https://openfheorg.github.io/openfhe.R/reference/multiparty_decrypt_main.md)
  : Non-lead party's partial decryption
- [`multiparty_decrypt_fusion()`](https://openfheorg.github.io/openfhe.R/reference/multiparty_decrypt_fusion.md)
  : Fuse partial decryptions into final plaintext
- [`threshold_decrypt()`](https://openfheorg.github.io/openfhe.R/reference/threshold_decrypt.md)
  : Threshold decryption convenience: lead + main + fusion in one call
- [`multi_add_pub_keys()`](https://openfheorg.github.io/openfhe.R/reference/multi_add_pub_keys.md)
  : Combine public keys from multiple parties
- [`multi_add_eval_keys()`](https://openfheorg.github.io/openfhe.R/reference/multi_add_eval_keys.md)
  : Combine evaluation keys from multiple parties
- [`multi_add_eval_mult_keys()`](https://openfheorg.github.io/openfhe.R/reference/multi_add_eval_mult_keys.md)
  : Combine partial eval-mult keys from multiple parties
- [`multi_key_switch_gen()`](https://openfheorg.github.io/openfhe.R/reference/multi_key_switch_gen.md)
  : Multi-party key-switch eval-key generation
- [`multi_eval_sum_key_gen()`](https://openfheorg.github.io/openfhe.R/reference/multi_eval_sum_key_gen.md)
  : Generate a joint sum-key share for multi-party EvalSum
- [`multi_eval_automorphism_key_gen()`](https://openfheorg.github.io/openfhe.R/reference/multi_eval_automorphism_key_gen.md)
  : Generate a joint automorphism-key share for multi-party rotation
- [`multi_eval_at_index_key_gen()`](https://openfheorg.github.io/openfhe.R/reference/multi_eval_at_index_key_gen.md)
  : Generate a joint rotation-at-index key share
- [`multi_add_eval_sum_keys()`](https://openfheorg.github.io/openfhe.R/reference/multi_add_eval_sum_keys.md)
  : Combine two sum-key map shares into a joint sum-key map
- [`multi_add_eval_automorphism_keys()`](https://openfheorg.github.io/openfhe.R/reference/multi_add_eval_automorphism_keys.md)
  : Combine two automorphism-key map shares
- [`share_keys()`](https://openfheorg.github.io/openfhe.R/reference/share_keys.md)
  : Distribute a secret key into shares
- [`recover_shared_key()`](https://openfheorg.github.io/openfhe.R/reference/recover_shared_key.md)
  : Recover a secret key from distributed shares
- [`EvalKey()`](https://openfheorg.github.io/openfhe.R/reference/EvalKey.md)
  : EvalKey class for multi-party key operations
- [`EvalKeyMap()`](https://openfheorg.github.io/openfhe.R/reference/EvalKeyMap.md)
  : Map of homomorphic evaluation keys
- [`SecretShareMap()`](https://openfheorg.github.io/openfhe.R/reference/SecretShareMap.md)
  : Map of secret-key shares for threshold-FHE abort recovery

## Binary FHE

- [`bin_fhe_context()`](https://openfheorg.github.io/openfhe.R/reference/bin_fhe_context.md)
  : Create a Binary FHE context
- [`bin_key_gen()`](https://openfheorg.github.io/openfhe.R/reference/bin_key_gen.md)
  : Generate BinFHE secret key
- [`bin_bt_key_gen()`](https://openfheorg.github.io/openfhe.R/reference/bin_bt_key_gen.md)
  : Generate BinFHE bootstrapping keys
- [`bin_encrypt()`](https://openfheorg.github.io/openfhe.R/reference/bin_encrypt.md)
  : Encrypt a value for Binary FHE
- [`bin_decrypt()`](https://openfheorg.github.io/openfhe.R/reference/bin_decrypt.md)
  : Decrypt a Binary FHE ciphertext
- [`eval_bin_gate()`](https://openfheorg.github.io/openfhe.R/reference/eval_bin_gate.md)
  : Evaluate a binary gate on encrypted values
- [`eval_not()`](https://openfheorg.github.io/openfhe.R/reference/eval_not.md)
  : Evaluate NOT on an encrypted value
- [`eval_sign()`](https://openfheorg.github.io/openfhe.R/reference/eval_sign.md)
  : Evaluate sign on an encrypted value (functional bootstrapping)
- [`eval_func()`](https://openfheorg.github.io/openfhe.R/reference/eval_func.md)
  : Evaluate an arbitrary function on an encrypted value
- [`eval_floor()`](https://openfheorg.github.io/openfhe.R/reference/eval_floor.md)
  : Evaluate a floor (rounding) function on an LWE ciphertext
- [`generate_lut_via_function()`](https://openfheorg.github.io/openfhe.R/reference/generate_lut_via_function.md)
  : Generate a lookup table for an arbitrary plaintext function
- [`get_max_plaintext_space()`](https://openfheorg.github.io/openfhe.R/reference/get_max_plaintext_space.md)
  : Maximum supported plaintext space for functional bootstrapping
- [`bin_key_gen_pair()`](https://openfheorg.github.io/openfhe.R/reference/bin_key_gen_pair.md)
  [`bin_pub_key_gen()`](https://openfheorg.github.io/openfhe.R/reference/bin_key_gen_pair.md)
  [`bin_key_gen_n()`](https://openfheorg.github.io/openfhe.R/reference/bin_key_gen_pair.md)
  [`bin_key_switch_gen()`](https://openfheorg.github.io/openfhe.R/reference/bin_key_gen_pair.md)
  : Keys of the LWE scheme of a BinFHE context
- [`switch_ct_to_qn()`](https://openfheorg.github.io/openfhe.R/reference/switch_ct_to_qn.md)
  : Switch a public-key ciphertext to the small modulus and dimension
- [`bin_bootstrap()`](https://openfheorg.github.io/openfhe.R/reference/bin_bootstrap.md)
  : Bootstrap an LWE ciphertext
- [`eval_constant()`](https://openfheorg.github.io/openfhe.R/reference/eval_constant.md)
  : A constant as an LWE ciphertext
- [`eval_decomp()`](https://openfheorg.github.io/openfhe.R/reference/eval_decomp.md)
  : Decompose a large-precision ciphertext into digits
- [`get_bt_key()`](https://openfheorg.github.io/openfhe.R/reference/get_bt_key.md)
  [`get_bt_key_map()`](https://openfheorg.github.io/openfhe.R/reference/get_bt_key.md)
  [`bin_bt_key_load()`](https://openfheorg.github.io/openfhe.R/reference/get_bt_key.md)
  [`bin_bt_key_map_load_single_element()`](https://openfheorg.github.io/openfhe.R/reference/get_bt_key.md)
  [`bin_clear_bt_keys()`](https://openfheorg.github.io/openfhe.R/reference/get_bt_key.md)
  [`get_switch_key()`](https://openfheorg.github.io/openfhe.R/reference/get_bt_key.md)
  [`has_internal32_refresh_key()`](https://openfheorg.github.io/openfhe.R/reference/get_bt_key.md)
  [`has_internal32_switch_key()`](https://openfheorg.github.io/openfhe.R/reference/get_bt_key.md)
  : The bootstrapping keys of a BinFHE context
- [`get_public_key()`](https://openfheorg.github.io/openfhe.R/reference/get_public_key.md)
  : The public key an object holds
- [`get_n()`](https://openfheorg.github.io/openfhe.R/reference/get_n.md)
  [`get_big_n()`](https://openfheorg.github.io/openfhe.R/reference/get_n.md)
  [`get_q()`](https://openfheorg.github.io/openfhe.R/reference/get_n.md)
  [`get_big_q()`](https://openfheorg.github.io/openfhe.R/reference/get_n.md)
  [`get_beta()`](https://openfheorg.github.io/openfhe.R/reference/get_n.md)
  : Parameters of a BinFHE context
- [`get_pt_modulus()`](https://openfheorg.github.io/openfhe.R/reference/get_pt_modulus.md)
  [`set_modulus()`](https://openfheorg.github.io/openfhe.R/reference/get_pt_modulus.md)
  [`set_pt_modulus()`](https://openfheorg.github.io/openfhe.R/reference/get_pt_modulus.md)
  : Moduli of an LWE ciphertext
- [`BinFHEContext()`](https://openfheorg.github.io/openfhe.R/reference/BinFHEContext.md)
  : BinFHE context (Binary FHE)
- [`LWECiphertext()`](https://openfheorg.github.io/openfhe.R/reference/LWECiphertext.md)
  : LWE Ciphertext (Binary FHE)
- [`LWEPrivateKey()`](https://openfheorg.github.io/openfhe.R/reference/LWEPrivateKey.md)
  : LWE Private Key (Binary FHE)
- [`LWEPublicKey()`](https://openfheorg.github.io/openfhe.R/reference/LWEPublicKey.md)
  : LWE public key (Binary FHE)
- [`LWEKeyPair()`](https://openfheorg.github.io/openfhe.R/reference/LWEKeyPair.md)
  : LWE key pair (Binary FHE)
- [`LWESwitchingKey()`](https://openfheorg.github.io/openfhe.R/reference/LWESwitchingKey.md)
  : LWE switching key (Binary FHE)
- [`RingGSWBTKey()`](https://openfheorg.github.io/openfhe.R/reference/RingGSWBTKey.md)
  : Bootstrapping key (Binary FHE)

## Scheme switching

Switching between CKKS and FHEW ciphertexts, and the comparison, minimum
and maximum built on it.

- [`SchSwchParams()`](https://openfheorg.github.io/openfhe.R/reference/SchSwchParams.md)
  [`set_security_level_ckks()`](https://openfheorg.github.io/openfhe.R/reference/SchSwchParams.md)
  [`set_security_level_fhew()`](https://openfheorg.github.io/openfhe.R/reference/SchSwchParams.md)
  [`set_arbitrary_function_evaluation()`](https://openfheorg.github.io/openfhe.R/reference/SchSwchParams.md)
  [`set_use_dynamic_mode_fhew()`](https://openfheorg.github.io/openfhe.R/reference/SchSwchParams.md)
  [`set_compute_argmin()`](https://openfheorg.github.io/openfhe.R/reference/SchSwchParams.md)
  [`set_one_hot_encoding()`](https://openfheorg.github.io/openfhe.R/reference/SchSwchParams.md)
  [`set_use_alt_argmin()`](https://openfheorg.github.io/openfhe.R/reference/SchSwchParams.md)
  [`set_num_slots_ckks()`](https://openfheorg.github.io/openfhe.R/reference/SchSwchParams.md)
  [`set_num_values()`](https://openfheorg.github.io/openfhe.R/reference/SchSwchParams.md)
  [`set_ctxt_mod_size_fhew_large_prec()`](https://openfheorg.github.io/openfhe.R/reference/SchSwchParams.md)
  [`set_ctxt_mod_size_fhew_intermed_swch()`](https://openfheorg.github.io/openfhe.R/reference/SchSwchParams.md)
  [`set_b_step_ltr_ckks_to_fhew()`](https://openfheorg.github.io/openfhe.R/reference/SchSwchParams.md)
  [`set_b_step_ltr_fhew_to_ckks()`](https://openfheorg.github.io/openfhe.R/reference/SchSwchParams.md)
  [`set_level_ltr_ckks_to_fhew()`](https://openfheorg.github.io/openfhe.R/reference/SchSwchParams.md)
  [`set_level_ltr_fhew_to_ckks()`](https://openfheorg.github.io/openfhe.R/reference/SchSwchParams.md)
  [`set_ring_dimension()`](https://openfheorg.github.io/openfhe.R/reference/SchSwchParams.md)
  [`set_initial_ckks_modulus()`](https://openfheorg.github.io/openfhe.R/reference/SchSwchParams.md)
  [`set_params_from_ckks_cryptocontext_called()`](https://openfheorg.github.io/openfhe.R/reference/SchSwchParams.md)
  [`get_security_level_ckks()`](https://openfheorg.github.io/openfhe.R/reference/SchSwchParams.md)
  [`get_security_level_fhew()`](https://openfheorg.github.io/openfhe.R/reference/SchSwchParams.md)
  [`get_arbitrary_function_evaluation()`](https://openfheorg.github.io/openfhe.R/reference/SchSwchParams.md)
  [`get_use_dynamic_mode_fhew()`](https://openfheorg.github.io/openfhe.R/reference/SchSwchParams.md)
  [`get_compute_argmin()`](https://openfheorg.github.io/openfhe.R/reference/SchSwchParams.md)
  [`get_one_hot_encoding()`](https://openfheorg.github.io/openfhe.R/reference/SchSwchParams.md)
  [`get_use_alt_argmin()`](https://openfheorg.github.io/openfhe.R/reference/SchSwchParams.md)
  [`get_num_slots_ckks()`](https://openfheorg.github.io/openfhe.R/reference/SchSwchParams.md)
  [`get_num_values()`](https://openfheorg.github.io/openfhe.R/reference/SchSwchParams.md)
  [`get_ctxt_mod_size_fhew_large_prec()`](https://openfheorg.github.io/openfhe.R/reference/SchSwchParams.md)
  [`get_ctxt_mod_size_fhew_intermed_swch()`](https://openfheorg.github.io/openfhe.R/reference/SchSwchParams.md)
  [`get_b_step_ltr_ckks_to_fhew()`](https://openfheorg.github.io/openfhe.R/reference/SchSwchParams.md)
  [`get_b_step_ltr_fhew_to_ckks()`](https://openfheorg.github.io/openfhe.R/reference/SchSwchParams.md)
  [`get_level_ltr_ckks_to_fhew()`](https://openfheorg.github.io/openfhe.R/reference/SchSwchParams.md)
  [`get_level_ltr_fhew_to_ckks()`](https://openfheorg.github.io/openfhe.R/reference/SchSwchParams.md)
  [`get_ring_dimension()`](https://openfheorg.github.io/openfhe.R/reference/SchSwchParams.md)
  [`get_initial_ckks_modulus()`](https://openfheorg.github.io/openfhe.R/reference/SchSwchParams.md)
  : Parameters of scheme switching
- [`eval_ckks_to_fhew_setup()`](https://openfheorg.github.io/openfhe.R/reference/eval_ckks_to_fhew_setup.md)
  [`eval_ckks_to_fhew_key_gen()`](https://openfheorg.github.io/openfhe.R/reference/eval_ckks_to_fhew_setup.md)
  [`eval_ckks_to_fhew_precompute()`](https://openfheorg.github.io/openfhe.R/reference/eval_ckks_to_fhew_setup.md)
  [`eval_ckks_to_fhew()`](https://openfheorg.github.io/openfhe.R/reference/eval_ckks_to_fhew_setup.md)
  : Switch a CKKS ciphertext to FHEW ciphertexts
- [`eval_fhew_to_ckks_setup()`](https://openfheorg.github.io/openfhe.R/reference/eval_fhew_to_ckks_setup.md)
  [`eval_fhew_to_ckks_key_gen()`](https://openfheorg.github.io/openfhe.R/reference/eval_fhew_to_ckks_setup.md)
  [`eval_fhew_to_ckks()`](https://openfheorg.github.io/openfhe.R/reference/eval_fhew_to_ckks_setup.md)
  : Switch FHEW ciphertexts to a CKKS ciphertext
- [`eval_scheme_switching_setup()`](https://openfheorg.github.io/openfhe.R/reference/eval_scheme_switching_setup.md)
  [`eval_scheme_switching_key_gen()`](https://openfheorg.github.io/openfhe.R/reference/eval_scheme_switching_setup.md)
  [`eval_compare_switch_precompute()`](https://openfheorg.github.io/openfhe.R/reference/eval_scheme_switching_setup.md)
  [`eval_compare_scheme_switching()`](https://openfheorg.github.io/openfhe.R/reference/eval_scheme_switching_setup.md)
  [`eval_min_scheme_switching()`](https://openfheorg.github.io/openfhe.R/reference/eval_scheme_switching_setup.md)
  [`eval_min_scheme_switching_alt()`](https://openfheorg.github.io/openfhe.R/reference/eval_scheme_switching_setup.md)
  [`eval_max_scheme_switching()`](https://openfheorg.github.io/openfhe.R/reference/eval_scheme_switching_setup.md)
  [`eval_max_scheme_switching_alt()`](https://openfheorg.github.io/openfhe.R/reference/eval_scheme_switching_setup.md)
  : Comparison, minimum and maximum through scheme switching
- [`get_bin_cc_for_scheme_switch()`](https://openfheorg.github.io/openfhe.R/reference/get_bin_cc_for_scheme_switch.md)
  [`set_bin_cc_for_scheme_switch()`](https://openfheorg.github.io/openfhe.R/reference/get_bin_cc_for_scheme_switch.md)
  [`get_swk_fc()`](https://openfheorg.github.io/openfhe.R/reference/get_bin_cc_for_scheme_switch.md)
  [`set_swk_fc()`](https://openfheorg.github.io/openfhe.R/reference/get_bin_cc_for_scheme_switch.md)
  : The FHEW side of a scheme-switching context
- [`set_params_from_ckks_cryptocontext()`](https://openfheorg.github.io/openfhe.R/reference/set_params_from_ckks_cryptocontext.md)
  : Fill scheme-switching parameters from a CKKS context
- [`SchemeSwitchingDataSerializer()`](https://openfheorg.github.io/openfhe.R/reference/SchemeSwitchingDataSerializer.md)
  [`SchemeSwitchingDataDeserializer()`](https://openfheorg.github.io/openfhe.R/reference/SchemeSwitchingDataSerializer.md)
  [`set_data_directory()`](https://openfheorg.github.io/openfhe.R/reference/SchemeSwitchingDataSerializer.md)
  [`serialize_scheme_switching_data()`](https://openfheorg.github.io/openfhe.R/reference/SchemeSwitchingDataSerializer.md)
  [`deserialize_scheme_switching_data()`](https://openfheorg.github.io/openfhe.R/reference/SchemeSwitchingDataSerializer.md)
  [`get_raw_ciphertext()`](https://openfheorg.github.io/openfhe.R/reference/SchemeSwitchingDataSerializer.md)
  : Write and read the data of a scheme-switching computation

## Enums

- [`Feature`](https://openfheorg.github.io/openfhe.R/reference/Feature.md)
  : PKE Scheme Features (bitmask)
- [`SecurityLevel`](https://openfheorg.github.io/openfhe.R/reference/SecurityLevel.md)
  : Security Levels
- [`ScalingTechnique`](https://openfheorg.github.io/openfhe.R/reference/ScalingTechnique.md)
  : Scaling Techniques (CKKS)
- [`KeySwitchTechnique`](https://openfheorg.github.io/openfhe.R/reference/KeySwitchTechnique.md)
  : Key Switching Techniques
- [`SecretKeyDist`](https://openfheorg.github.io/openfhe.R/reference/SecretKeyDist.md)
  : Secret Key Distribution
- [`BinFHEParamSet`](https://openfheorg.github.io/openfhe.R/reference/BinFHEParamSet.md)
  : Binary FHE Parameter Sets
- [`BinFHEMethod`](https://openfheorg.github.io/openfhe.R/reference/BinFHEMethod.md)
  : Binary FHE Methods
- [`BinGate`](https://openfheorg.github.io/openfhe.R/reference/BinGate.md)
  : Binary Gate Types
- [`BinFHEOutput`](https://openfheorg.github.io/openfhe.R/reference/BinFHEOutput.md)
  : Binary FHE Output Types
- [`KeygenMode`](https://openfheorg.github.io/openfhe.R/reference/KeygenMode.md)
  : Key Generation Mode
- [`PlaintextEncodings`](https://openfheorg.github.io/openfhe.R/reference/PlaintextEncodings.md)
  : Plaintext Encoding Types
- [`DistributionType`](https://openfheorg.github.io/openfhe.R/reference/DistributionType.md)
  : Distribution Type (lattice parameters)
- [`MultipartyMode`](https://openfheorg.github.io/openfhe.R/reference/MultipartyMode.md)
  : Multiparty Mode
- [`ExecutionMode`](https://openfheorg.github.io/openfhe.R/reference/ExecutionMode.md)
  : Execution Mode
- [`DecryptionNoiseMode`](https://openfheorg.github.io/openfhe.R/reference/DecryptionNoiseMode.md)
  : Decryption Noise Mode
- [`PREMode`](https://openfheorg.github.io/openfhe.R/reference/PREMode.md)
  : Proxy Re-encryption Mode
- [`MultiplicationTechnique`](https://openfheorg.github.io/openfhe.R/reference/MultiplicationTechnique.md)
  : Multiplication Technique (BFV)
- [`EncryptionTechnique`](https://openfheorg.github.io/openfhe.R/reference/EncryptionTechnique.md)
  : Encryption Technique
- [`CKKSDataType`](https://openfheorg.github.io/openfhe.R/reference/CKKSDataType.md)
  : CKKS Data Type
- [`CompressionLevel`](https://openfheorg.github.io/openfhe.R/reference/CompressionLevel.md)
  : Compression Level (interactive multi-party bootstrap)
- [`SchemeId`](https://openfheorg.github.io/openfhe.R/reference/SchemeId.md)
  : Scheme Identifier

## Functional bootstrapping

CKKS functional bootstrapping of RLWE ciphertexts: look-up tables,
several tables on one input, and Fourier series.

- [`eval_fbt_setup()`](https://openfheorg.github.io/openfhe.R/reference/eval_fbt_setup.md)
  [`eval_fbt()`](https://openfheorg.github.io/openfhe.R/reference/eval_fbt_setup.md)
  [`eval_fbt_no_decoding()`](https://openfheorg.github.io/openfhe.R/reference/eval_fbt_setup.md)
  [`eval_hom_decoding()`](https://openfheorg.github.io/openfhe.R/reference/eval_fbt_setup.md)
  : CKKS functional bootstrapping of a look-up table
- [`eval_mvb_precompute()`](https://openfheorg.github.io/openfhe.R/reference/eval_mvb_precompute.md)
  [`eval_mvb()`](https://openfheorg.github.io/openfhe.R/reference/eval_mvb_precompute.md)
  [`eval_mvb_no_decoding()`](https://openfheorg.github.io/openfhe.R/reference/eval_mvb_precompute.md)
  : Several look-up tables on one input (multi-value bootstrapping)
- [`eval_hermite_trig_series()`](https://openfheorg.github.io/openfhe.R/reference/eval_hermite_trig_series.md)
  : Evaluate a trigonometric Hermite series on a ciphertext
- [`eval_fe_func_bootstrap_setup()`](https://openfheorg.github.io/openfhe.R/reference/eval_fe_func_bootstrap_setup.md)
  [`eval_fe_func_bootstrap()`](https://openfheorg.github.io/openfhe.R/reference/eval_fe_func_bootstrap_setup.md)
  [`eval_fe_func_bootstrap_precompute()`](https://openfheorg.github.io/openfhe.R/reference/eval_fe_func_bootstrap_setup.md)
  [`eval_fe_func_bootstrap_with_precomp()`](https://openfheorg.github.io/openfhe.R/reference/eval_fe_func_bootstrap_setup.md)
  : CKKS functional bootstrapping of a Fourier series
- [`get_hermite_trig_coefficients()`](https://openfheorg.github.io/openfhe.R/reference/get_hermite_trig_coefficients.md)
  : Trigonometric Hermite interpolation of a look-up table
- [`get_fbt_depth()`](https://openfheorg.github.io/openfhe.R/reference/get_fbt_depth.md)
  [`get_fefbt_depth()`](https://openfheorg.github.io/openfhe.R/reference/get_fbt_depth.md)
  : Multiplicative depth of functional bootstrapping
- [`schemelet_get_element_params()`](https://openfheorg.github.io/openfhe.R/reference/schemelet_get_element_params.md)
  [`schemelet_encrypt_coeff()`](https://openfheorg.github.io/openfhe.R/reference/schemelet_get_element_params.md)
  [`schemelet_decrypt_coeff()`](https://openfheorg.github.io/openfhe.R/reference/schemelet_get_element_params.md)
  [`schemelet_mod_switch()`](https://openfheorg.github.io/openfhe.R/reference/schemelet_get_element_params.md)
  [`schemelet_get_q_prime()`](https://openfheorg.github.io/openfhe.R/reference/schemelet_get_element_params.md)
  : RLWE encryption under a CKKS secret key
- [`schemelet_convert_rlwe_to_ckks()`](https://openfheorg.github.io/openfhe.R/reference/schemelet_convert_rlwe_to_ckks.md)
  [`schemelet_convert_ckks_to_rlwe()`](https://openfheorg.github.io/openfhe.R/reference/schemelet_convert_rlwe_to_ckks.md)
  : Convert between RLWE and CKKS ciphertexts
- [`PolyVector()`](https://openfheorg.github.io/openfhe.R/reference/PolyVector.md)
  [`switch_modulus()`](https://openfheorg.github.io/openfhe.R/reference/PolyVector.md)
  : An RLWE ciphertext

## Supporting types

- [`ElementParams()`](https://openfheorg.github.io/openfhe.R/reference/ElementParams.md)
  : Element Parameters (opaque)
- [`CryptoParameters()`](https://openfheorg.github.io/openfhe.R/reference/CryptoParameters.md)
  : Crypto Parameters (opaque)
- [`EncodingParams()`](https://openfheorg.github.io/openfhe.R/reference/EncodingParams.md)
  : Encoding Parameters (opaque)

## Object accessors

- [`get_modulus()`](https://openfheorg.github.io/openfhe.R/reference/get_modulus.md)
  : The ciphertext modulus
- [`get_modulus_ckks()`](https://openfheorg.github.io/openfhe.R/reference/get_modulus_ckks.md)
  [`get_root_of_unity()`](https://openfheorg.github.io/openfhe.R/reference/get_modulus_ckks.md)
  : Moduli and root of unity of a CryptoContext
- [`get_plaintext_generator()`](https://openfheorg.github.io/openfhe.R/reference/get_plaintext_generator.md)
  : The plaintext generator of an encoding
- [`set_scheme_id()`](https://openfheorg.github.io/openfhe.R/reference/set_scheme_id.md)
  : Set the scheme identifier of a CryptoContext
- [`serialized_object_name()`](https://openfheorg.github.io/openfhe.R/reference/serialized_object_name.md)
  [`serialized_version()`](https://openfheorg.github.io/openfhe.R/reference/serialized_object_name.md)
  : Name and version of a serialized object
- [`clear_all_ckks_caches()`](https://openfheorg.github.io/openfhe.R/reference/clear_all_ckks_caches.md)
  [`clear_bootstrap_precom()`](https://openfheorg.github.io/openfhe.R/reference/clear_all_ckks_caches.md)
  [`clear_scheme_switch_precom()`](https://openfheorg.github.io/openfhe.R/reference/clear_all_ckks_caches.md)
  : Release the precomputations a CKKS context has cached
- [`get_plaintext_for_decrypt()`](https://openfheorg.github.io/openfhe.R/reference/get_plaintext_for_decrypt.md)
  : An empty plaintext of the type a decryption will fill
- [`get_existing_eval_automorphism_key_indices()`](https://openfheorg.github.io/openfhe.R/reference/get_existing_eval_automorphism_key_indices.md)
  [`get_eval_automorphism_no_key_indices()`](https://openfheorg.github.io/openfhe.R/reference/get_existing_eval_automorphism_key_indices.md)
  [`get_unique_values()`](https://openfheorg.github.io/openfhe.R/reference/get_existing_eval_automorphism_key_indices.md)
  : Which automorphism keys exist
- [`clone()`](https://openfheorg.github.io/openfhe.R/reference/clone.md)
  [`clone_empty()`](https://openfheorg.github.io/openfhe.R/reference/clone.md)
  : Copy a ciphertext
- [`number_ciphertext_elements()`](https://openfheorg.github.io/openfhe.R/reference/number_ciphertext_elements.md)
  [`get_elements()`](https://openfheorg.github.io/openfhe.R/reference/number_ciphertext_elements.md)
  [`get_elements_mutable()`](https://openfheorg.github.io/openfhe.R/reference/number_ciphertext_elements.md)
  [`set_elements()`](https://openfheorg.github.io/openfhe.R/reference/number_ciphertext_elements.md)
  [`set_elements_move()`](https://openfheorg.github.io/openfhe.R/reference/number_ciphertext_elements.md)
  [`remove_element()`](https://openfheorg.github.io/openfhe.R/reference/number_ciphertext_elements.md)
  : The ring elements of a ciphertext
- [`get_hop_level()`](https://openfheorg.github.io/openfhe.R/reference/get_hop_level.md)
  [`set_hop_level()`](https://openfheorg.github.io/openfhe.R/reference/get_hop_level.md)
  [`set_encoding_type()`](https://openfheorg.github.io/openfhe.R/reference/get_hop_level.md)
  : Hop level and encoding type of a ciphertext
- [`encode()`](https://openfheorg.github.io/openfhe.R/reference/encode.md)
  [`decode()`](https://openfheorg.github.io/openfhe.R/reference/encode.md)
  : Encode or decode a plaintext
- [`get_element_modulus()`](https://openfheorg.github.io/openfhe.R/reference/get_element_modulus.md)
  [`set_format()`](https://openfheorg.github.io/openfhe.R/reference/get_element_modulus.md)
  : Modulus and representation of a plaintext's element
- [`DCRTPoly()`](https://openfheorg.github.io/openfhe.R/reference/DCRTPoly.md)
  : A ring element of a ciphertext
- [`SchemeBase()`](https://openfheorg.github.io/openfhe.R/reference/SchemeBase.md)
  : The scheme object of a CryptoContext
- [`Format`](https://openfheorg.github.io/openfhe.R/reference/Format.md)
  : Polynomial representation

## CCParams getters

- [`get_ring_dim()`](https://openfheorg.github.io/openfhe.R/reference/ccparams_getters.md)
  [`get_plaintext_modulus()`](https://openfheorg.github.io/openfhe.R/reference/ccparams_getters.md)
  [`get_digit_size()`](https://openfheorg.github.io/openfhe.R/reference/ccparams_getters.md)
  [`get_composite_degree()`](https://openfheorg.github.io/openfhe.R/reference/ccparams_getters.md)
  [`get_scheme()`](https://openfheorg.github.io/openfhe.R/reference/ccparams_getters.md)
  [`get_standard_deviation()`](https://openfheorg.github.io/openfhe.R/reference/ccparams_getters.md)
  [`get_secret_key_dist()`](https://openfheorg.github.io/openfhe.R/reference/ccparams_getters.md)
  [`get_max_relin_sk_deg()`](https://openfheorg.github.io/openfhe.R/reference/ccparams_getters.md)
  [`get_pre_mode()`](https://openfheorg.github.io/openfhe.R/reference/ccparams_getters.md)
  [`get_multiparty_mode()`](https://openfheorg.github.io/openfhe.R/reference/ccparams_getters.md)
  [`get_execution_mode()`](https://openfheorg.github.io/openfhe.R/reference/ccparams_getters.md)
  [`get_decryption_noise_mode()`](https://openfheorg.github.io/openfhe.R/reference/ccparams_getters.md)
  [`get_noise_estimate()`](https://openfheorg.github.io/openfhe.R/reference/ccparams_getters.md)
  [`get_desired_precision()`](https://openfheorg.github.io/openfhe.R/reference/ccparams_getters.md)
  [`get_statistical_security()`](https://openfheorg.github.io/openfhe.R/reference/ccparams_getters.md)
  [`get_num_adversarial_queries()`](https://openfheorg.github.io/openfhe.R/reference/ccparams_getters.md)
  [`get_threshold_num_of_parties()`](https://openfheorg.github.io/openfhe.R/reference/ccparams_getters.md)
  [`get_key_switch_technique()`](https://openfheorg.github.io/openfhe.R/reference/ccparams_getters.md)
  [`get_scaling_technique()`](https://openfheorg.github.io/openfhe.R/reference/ccparams_getters.md)
  [`get_batch_size()`](https://openfheorg.github.io/openfhe.R/reference/ccparams_getters.md)
  [`get_first_mod_size()`](https://openfheorg.github.io/openfhe.R/reference/ccparams_getters.md)
  [`get_num_large_digits()`](https://openfheorg.github.io/openfhe.R/reference/ccparams_getters.md)
  [`get_multiplicative_depth()`](https://openfheorg.github.io/openfhe.R/reference/ccparams_getters.md)
  [`get_scaling_mod_size()`](https://openfheorg.github.io/openfhe.R/reference/ccparams_getters.md)
  [`get_security_level()`](https://openfheorg.github.io/openfhe.R/reference/ccparams_getters.md)
  [`get_eval_add_count()`](https://openfheorg.github.io/openfhe.R/reference/ccparams_getters.md)
  [`get_key_switch_count()`](https://openfheorg.github.io/openfhe.R/reference/ccparams_getters.md)
  [`get_encryption_technique()`](https://openfheorg.github.io/openfhe.R/reference/ccparams_getters.md)
  [`get_multiplication_technique()`](https://openfheorg.github.io/openfhe.R/reference/ccparams_getters.md)
  [`get_pre_num_hops()`](https://openfheorg.github.io/openfhe.R/reference/ccparams_getters.md)
  [`get_interactive_boot_compression_level()`](https://openfheorg.github.io/openfhe.R/reference/ccparams_getters.md)
  [`get_register_word_size()`](https://openfheorg.github.io/openfhe.R/reference/ccparams_getters.md)
  [`get_ckks_data_type()`](https://openfheorg.github.io/openfhe.R/reference/ccparams_getters.md)
  : CCParams getters (all schemes)

## CCParams setters

- [`set_plaintext_modulus()`](https://openfheorg.github.io/openfhe.R/reference/ccparams_setters.md)
  [`set_digit_size()`](https://openfheorg.github.io/openfhe.R/reference/ccparams_setters.md)
  [`set_standard_deviation()`](https://openfheorg.github.io/openfhe.R/reference/ccparams_setters.md)
  [`set_secret_key_dist()`](https://openfheorg.github.io/openfhe.R/reference/ccparams_setters.md)
  [`set_max_relin_sk_deg()`](https://openfheorg.github.io/openfhe.R/reference/ccparams_setters.md)
  [`set_pre_mode()`](https://openfheorg.github.io/openfhe.R/reference/ccparams_setters.md)
  [`set_multiparty_mode()`](https://openfheorg.github.io/openfhe.R/reference/ccparams_setters.md)
  [`set_execution_mode()`](https://openfheorg.github.io/openfhe.R/reference/ccparams_setters.md)
  [`set_decryption_noise_mode()`](https://openfheorg.github.io/openfhe.R/reference/ccparams_setters.md)
  [`set_noise_estimate()`](https://openfheorg.github.io/openfhe.R/reference/ccparams_setters.md)
  [`set_desired_precision()`](https://openfheorg.github.io/openfhe.R/reference/ccparams_setters.md)
  [`set_statistical_security()`](https://openfheorg.github.io/openfhe.R/reference/ccparams_setters.md)
  [`set_num_adversarial_queries()`](https://openfheorg.github.io/openfhe.R/reference/ccparams_setters.md)
  [`set_threshold_num_of_parties()`](https://openfheorg.github.io/openfhe.R/reference/ccparams_setters.md)
  [`set_key_switch_technique()`](https://openfheorg.github.io/openfhe.R/reference/ccparams_setters.md)
  [`set_scaling_technique()`](https://openfheorg.github.io/openfhe.R/reference/ccparams_setters.md)
  [`set_batch_size()`](https://openfheorg.github.io/openfhe.R/reference/ccparams_setters.md)
  [`set_first_mod_size()`](https://openfheorg.github.io/openfhe.R/reference/ccparams_setters.md)
  [`set_num_large_digits()`](https://openfheorg.github.io/openfhe.R/reference/ccparams_setters.md)
  [`set_multiplicative_depth()`](https://openfheorg.github.io/openfhe.R/reference/ccparams_setters.md)
  [`set_scaling_mod_size()`](https://openfheorg.github.io/openfhe.R/reference/ccparams_setters.md)
  [`set_security_level()`](https://openfheorg.github.io/openfhe.R/reference/ccparams_setters.md)
  [`set_ring_dim()`](https://openfheorg.github.io/openfhe.R/reference/ccparams_setters.md)
  [`set_eval_add_count()`](https://openfheorg.github.io/openfhe.R/reference/ccparams_setters.md)
  [`set_key_switch_count()`](https://openfheorg.github.io/openfhe.R/reference/ccparams_setters.md)
  [`set_encryption_technique()`](https://openfheorg.github.io/openfhe.R/reference/ccparams_setters.md)
  [`set_multiplication_technique()`](https://openfheorg.github.io/openfhe.R/reference/ccparams_setters.md)
  [`set_pre_num_hops()`](https://openfheorg.github.io/openfhe.R/reference/ccparams_setters.md)
  [`set_interactive_boot_compression_level()`](https://openfheorg.github.io/openfhe.R/reference/ccparams_setters.md)
  [`set_composite_degree()`](https://openfheorg.github.io/openfhe.R/reference/ccparams_setters.md)
  [`set_register_word_size()`](https://openfheorg.github.io/openfhe.R/reference/ccparams_setters.md)
  : Set a parameter on a parameter object

## Utilities

- [`get_native_int()`](https://openfheorg.github.io/openfhe.R/reference/get_native_int.md)
  : Get the native integer size of the OpenFHE build
- [`set_num_threads()`](https://openfheorg.github.io/openfhe.R/reference/set_num_threads.md)
  : Set the number of OpenMP threads OpenFHE may use
- [`get_num_threads()`](https://openfheorg.github.io/openfhe.R/reference/get_num_threads.md)
  : Report the number of OpenMP threads available to OpenFHE
- [`set_length()`](https://openfheorg.github.io/openfhe.R/reference/set_length.md)
  : Set the effective length of a plaintext
- [`clear_static_maps_and_vectors()`](https://openfheorg.github.io/openfhe.R/reference/clear_static_maps_and_vectors.md)
  : Clear OpenFHE static maps and vectors
- [`OpenFHEObject()`](https://openfheorg.github.io/openfhe.R/reference/OpenFHEObject.md)
  : Base class for OpenFHE objects
- [`ptr_is_valid()`](https://openfheorg.github.io/openfhe.R/reference/ptr_is_valid.md)
  : Check if an external pointer is valid (non-NULL)
- [`get_ptr()`](https://openfheorg.github.io/openfhe.R/reference/get_ptr.md)
  : Extract pointer with validation
- [`openfhe.R`](https://openfheorg.github.io/openfhe.R/reference/openfhe.R-package.md)
  [`openfhe.R-package`](https://openfheorg.github.io/openfhe.R/reference/openfhe.R-package.md)
  : openfhe.R: R Interface to the 'OpenFHE' Fully Homomorphic Encryption
  Library

## CKKS numerical tolerance

- [`fhe_ckks_tolerance()`](https://openfheorg.github.io/openfhe.R/reference/fhe_ckks_tolerance.md)
  : Per-test CKKS precision tolerance
