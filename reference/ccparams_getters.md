# CCParams getters (all schemes)

Retrieve a parameter from a `BFVParams`, `BGVParams`, or `CKKSParams`
object. Each getter wraps the corresponding upstream `CCParams<T>::Get*`
method and returns its value unchanged.

## Usage

``` r
get_ring_dim(params, ...)

get_plaintext_modulus(params, ...)

get_digit_size(params, ...)

get_composite_degree(params, ...)

get_scheme(params, ...)

get_standard_deviation(params, ...)

get_secret_key_dist(params, ...)

get_max_relin_sk_deg(params, ...)

get_pre_mode(params, ...)

get_multiparty_mode(params, ...)

get_execution_mode(params, ...)

get_decryption_noise_mode(params, ...)

get_noise_estimate(params, ...)

get_desired_precision(params, ...)

get_statistical_security(params, ...)

get_num_adversarial_queries(params, ...)

get_threshold_num_of_parties(params, ...)

get_key_switch_technique(params, ...)

get_scaling_technique(params, ...)

get_batch_size(params, ...)

get_first_mod_size(params, ...)

get_num_large_digits(params, ...)

get_multiplicative_depth(params, ...)

get_scaling_mod_size(params, ...)

get_security_level(params, ...)

get_eval_add_count(params, ...)

get_key_switch_count(params, ...)

get_encryption_technique(params, ...)

get_multiplication_technique(params, ...)

get_pre_num_hops(params, ...)

get_interactive_boot_compression_level(params, ...)

get_register_word_size(params, ...)

get_ckks_data_type(params, ...)
```

## Arguments

- params:

  A `BFVParams`, `BGVParams`, or `CKKSParams`.

- ...:

  Reserved for future method-specific arguments (currently unused — all
  getters take only `params`).

## Value

The underlying parameter value. Types vary per getter.

## Details

Several parameters are "disabled" on specific schemes (their setters
throw at runtime). For a disabled scheme/parameter combination the
getter returns the default value of the underlying field (typically `0L`
for `uint32_t`, `0` for `double`, or the enum's zero sentinel) rather
than throwing. This is benign — the field was never set so its default
is all the information available — but it means e.g. calling
`get_plaintext_modulus(params)` on a `CKKSParams` object returns `0`
rather than a meaningful modulus.

## Functions

- `get_ring_dim`: Ring dimension `n` of the lattice the scheme operates
  over. For RLWE schemes this is the cyclotomic ring's degree
  `n = phi(m)` (Euler's totient of the cyclotomic order) and must be a
  power of two. The ring dimension is the load-bearing cryptographic
  parameter — security level and multiplicative depth together pin the
  minimum `n`, and most runtime costs scale as `O(n log n)` per
  homomorphic operation.

- `get_plaintext_modulus`: Plaintext modulus `t` for the BFV and BGV
  plaintext spaces. BFV/BGV plaintexts are elements of `Z_t[x]/Phi_m(x)`
  and every homomorphic operation is performed modulo `t`. On a
  `CKKSParams` object this returns the default field value (`0`) because
  CKKS does not use a plaintext modulus. The value is a number when it
  is at most 2^53 and a string of decimal digits above that, where an R
  number is no longer exact.

- `get_digit_size`: Digit size `r` for BV key-switching: the base-`2^r`
  digit decomposition of the ciphertext during a key-switch. Larger
  values decrease the number of digit multiplications at the cost of
  larger per-digit noise.

- `get_composite_degree`: Composite-scaling degree for the CKKS
  `COMPOSITESCALINGAUTO`/`COMPOSITESCALINGMANUAL` scaling techniques.
  Only meaningful when
  `scaling_technique = ScalingTechnique$COMPOSITESCALING*`; `0` under
  the default FLEXIBLEAUTO path.

- `get_scheme`: integer scheme identifier (see `SchemeId` for the enum
  values).

- `get_standard_deviation`: standard deviation of the Gaussian error
  distribution.

- `get_secret_key_dist`: secret-key distribution (see `SecretKeyDist`).

- `get_max_relin_sk_deg`: maximum relinearization secret-key degree.

- `get_pre_mode`: proxy re-encryption mode (see `PREMode`).

- `get_multiparty_mode`: multiparty mode (see `MultipartyMode`).

- `get_execution_mode`: execution mode (see `ExecutionMode`).

- `get_decryption_noise_mode`: decryption noise mode (see
  `DecryptionNoiseMode`).

- `get_noise_estimate`: noise-flooding noise estimate (double).

- `get_desired_precision`: noise-flooding target precision (double,
  bits).

- `get_statistical_security`: statistical security parameter. Return
  type is `double` per header inconsistency; see the Return-type note.

- `get_num_adversarial_queries`: upper bound on adversarial queries.
  Return type is `double` per header inconsistency; see the Return-type
  note.

- `get_threshold_num_of_parties`: threshold-FHE party count.

- `get_key_switch_technique`: key-switching technique (see
  `KeySwitchTechnique`).

- `get_scaling_technique`: scaling technique (see `ScalingTechnique`).

- `get_batch_size`: SIMD batch size.

- `get_first_mod_size`: bit size of the first (largest) prime in the
  CKKS modulus chain.

- `get_num_large_digits`: number of large digits for HYBRID key
  switching.

- `get_multiplicative_depth`: configured multiplicative depth. Note:
  this is the depth the context was constructed to support, not the
  current depth budget after operations.

- `get_scaling_mod_size`: bit size of each CKKS scaling modulus.

- `get_security_level`: target security level (see `SecurityLevel`).

- `get_eval_add_count`: BFV/BGV noise-flooding hint: maximum additions
  between multiplications.

- `get_key_switch_count`: BFV/BGV noise-flooding hint: maximum
  key-switch count.

- `get_encryption_technique`: BFV encryption technique (see
  `EncryptionTechnique`).

- `get_multiplication_technique`: BFV multiplication technique (see
  `MultiplicationTechnique`).

- `get_pre_num_hops`: PRE hop count.

- `get_interactive_boot_compression_level`: CKKS interactive bootstrap
  compression level (see `CompressionLevel`).

- `get_register_word_size`: register word size for multi-precision
  arithmetic.

- `get_ckks_data_type`: CKKS data type (see `CKKSDataType`).

## Return-type note

`get_statistical_security` and `get_num_adversarial_queries` return
`double` rather than `integer`. This matches an inconsistency in the
upstream Params base class: the corresponding setters take `uint32_t`
but the getters return `double`. The underlying field is a `double` — R
binds per the header, not per the setter signature.

`get_plaintext_modulus` returns a number for a modulus of at most 2^53
and a string of decimal digits for a larger one, which an R number
cannot hold exactly.
