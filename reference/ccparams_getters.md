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

Per discovery D013, several parameters are "disabled" on specific
schemes (their setters throw at runtime). For a disabled
scheme/parameter combination the getter returns the default value of the
underlying field (typically `0L` for `uint32_t`, `0` for `double`, or
the enum's zero sentinel) rather than throwing. This is benign — the
field was never set so its default is all the information available —
but it means e.g. calling `get_plaintext_modulus(params)` on a
`CKKSParams` object returns `0` rather than a meaningful modulus.

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
  CKKS does not use a plaintext modulus — see discovery D013.

- `get_digit_size`: Digit size `r` for BV key-switching: the base-`2^r`
  digit decomposition of the ciphertext during a key-switch. Larger
  values decrease the number of digit multiplications at the cost of
  larger per-digit noise.

- `get_composite_degree`: Composite-scaling degree for the CKKS
  `COMPOSITESCALINGAUTO`/`COMPOSITESCALINGMANUAL` scaling techniques.
  Only meaningful when
  `scaling_technique = ScalingTechnique$COMPOSITESCALING*`; `0` under
  the default FLEXIBLEAUTO path.

- `get_scheme`: `parity-deferred:` integer scheme identifier (see
  `SchemeId` for the enum values).

- `get_standard_deviation`: `parity-deferred:` standard deviation of the
  Gaussian error distribution.

- `get_secret_key_dist`: `parity-deferred:` secret-key distribution (see
  `SecretKeyDist`).

- `get_max_relin_sk_deg`: `parity-deferred:` maximum relinearization
  secret-key degree.

- `get_pre_mode`: `parity-deferred:` proxy re-encryption mode (see
  `PREMode`).

- `get_multiparty_mode`: `parity-deferred:` multiparty mode (see
  `MultipartyMode`).

- `get_execution_mode`: `parity-deferred:` execution mode (see
  `ExecutionMode`).

- `get_decryption_noise_mode`: `parity-deferred:` decryption noise mode
  (see `DecryptionNoiseMode`).

- `get_noise_estimate`: `parity-deferred:` noise-flooding noise estimate
  (double).

- `get_desired_precision`: `parity-deferred:` noise-flooding target
  precision (double, bits).

- `get_statistical_security`: `parity-deferred:` statistical security
  parameter. Return type is `double` per header inconsistency; see the
  Return-type note.

- `get_num_adversarial_queries`: `parity-deferred:` upper bound on
  adversarial queries. Return type is `double` per header inconsistency;
  see the Return-type note.

- `get_threshold_num_of_parties`: `parity-deferred:` threshold-FHE party
  count.

- `get_key_switch_technique`: `parity-deferred:` key-switching technique
  (see `KeySwitchTechnique`).

- `get_scaling_technique`: `parity-deferred:` scaling technique (see
  `ScalingTechnique`).

- `get_batch_size`: `parity-deferred:` SIMD batch size.

- `get_first_mod_size`: `parity-deferred:` bit size of the first
  (largest) prime in the CKKS modulus chain.

- `get_num_large_digits`: `parity-deferred:` number of large digits for
  HYBRID key switching.

- `get_multiplicative_depth`: `parity-deferred:` configured
  multiplicative depth. Note: this is the depth the context was
  constructed to support, not the current depth budget after operations.

- `get_scaling_mod_size`: `parity-deferred:` bit size of each CKKS
  scaling modulus.

- `get_security_level`: `parity-deferred:` target security level (see
  `SecurityLevel`).

- `get_eval_add_count`: `parity-deferred:` BFV/BGV noise-flooding hint:
  maximum additions between multiplications.

- `get_key_switch_count`: `parity-deferred:` BFV/BGV noise-flooding
  hint: maximum key-switch count.

- `get_encryption_technique`: `parity-deferred:` BFV encryption
  technique (see `EncryptionTechnique`).

- `get_multiplication_technique`: `parity-deferred:` BFV multiplication
  technique (see `MultiplicationTechnique`).

- `get_pre_num_hops`: `parity-deferred:` PRE hop count.

- `get_interactive_boot_compression_level`: `parity-deferred:` CKKS
  interactive bootstrap compression level (see `CompressionLevel`).

- `get_register_word_size`: `parity-deferred:` register word size for
  multi-precision arithmetic.

- `get_ckks_data_type`: `parity-deferred:` CKKS data type (see
  `CKKSDataType`).

## Return-type note

`get_statistical_security` and `get_num_adversarial_queries` return
`double` rather than `integer`. This matches an inconsistency in the
upstream Params base class: the corresponding setters take `uint32_t`
but the getters return `double`. The underlying field is a `double` — R
binds per the header, not per the setter signature.

`get_plaintext_modulus` returns an R `integer` on 32-bit-safe values;
for moduli that exceed the 32-bit signed integer range the return value
is a `numeric` (double) carrying a losslessly rounded 53-bit integer,
per the `design.md` §7 return-type convention.
