# Set a parameter on a parameter object

Change one parameter of a `BFVParams`, `BGVParams`, or `CKKSParams`
object after it has been constructed. Each function wraps the
`CCParams<T>::Set*` method of the same name. The parameter constructors
take the same parameters as arguments; these functions are for code that
builds a parameter object step by step, as the OpenFHE examples do.

## Usage

``` r
set_plaintext_modulus(params, ...)

set_digit_size(params, ...)

set_standard_deviation(params, ...)

set_secret_key_dist(params, ...)

set_max_relin_sk_deg(params, ...)

set_pre_mode(params, ...)

set_multiparty_mode(params, ...)

set_execution_mode(params, ...)

set_decryption_noise_mode(params, ...)

set_noise_estimate(params, ...)

set_desired_precision(params, ...)

set_statistical_security(params, ...)

set_num_adversarial_queries(params, ...)

set_threshold_num_of_parties(params, ...)

set_key_switch_technique(params, ...)

set_scaling_technique(params, ...)

set_batch_size(params, ...)

set_first_mod_size(params, ...)

set_num_large_digits(params, ...)

set_multiplicative_depth(params, ...)

set_scaling_mod_size(params, ...)

set_security_level(params, ...)

set_ring_dim(params, ...)

set_eval_add_count(params, ...)

set_key_switch_count(params, ...)

set_encryption_technique(params, ...)

set_multiplication_technique(params, ...)

set_pre_num_hops(params, ...)

set_interactive_boot_compression_level(params, ...)

set_composite_degree(params, ...)

set_register_word_size(params, ...)
```

## Arguments

- params:

  A `BFVParams`, `BGVParams`, or `CKKSParams` object.

- ...:

  Method-specific arguments: `value`, the new value of the parameter.

## Value

`params`, invisibly. The object is modified in place.

## Details

Every setter is defined for all three parameter classes, as in the C++
library. A parameter that a scheme does not use is refused by OpenFHE,
and its error is raised: for example `set_plaintext_modulus()` on a
`CKKSParams` object.

Parameters whose values are members of an enumeration take the member,
for example `set_security_level(p, SecurityLevel$HEStd_128_classic)`.

## Functions

- `set_plaintext_modulus`: plaintext modulus (BFV, BGV). A whole number
  of at most 2^53, or a string of decimal digits.

- `set_digit_size`: digit size for BV key switching.

- `set_standard_deviation`: standard deviation of the error
  distribution.

- `set_secret_key_dist`: secret-key distribution, a member of
  [SecretKeyDist](https://openfheorg.github.io/openfhe.R/reference/SecretKeyDist.md).

- `set_max_relin_sk_deg`: maximum degree of the secret key for which
  relinearization keys are generated.

- `set_pre_mode`: proxy re-encryption mode, a member of
  [PREMode](https://openfheorg.github.io/openfhe.R/reference/PREMode.md).

- `set_multiparty_mode`: multiparty mode, a member of
  [MultipartyMode](https://openfheorg.github.io/openfhe.R/reference/MultipartyMode.md).

- `set_execution_mode`: execution mode (CKKS), a member of
  [ExecutionMode](https://openfheorg.github.io/openfhe.R/reference/ExecutionMode.md).

- `set_decryption_noise_mode`: decryption noise mode (CKKS), a member of
  [DecryptionNoiseMode](https://openfheorg.github.io/openfhe.R/reference/DecryptionNoiseMode.md).

- `set_noise_estimate`: noise estimate for noise flooding (CKKS).

- `set_desired_precision`: desired precision for noise flooding (CKKS).

- `set_statistical_security`: statistical security, in bits, for noise
  flooding.

- `set_num_adversarial_queries`: bound on the number of adversarial
  queries, for noise flooding.

- `set_threshold_num_of_parties`: number of parties in threshold FHE.

- `set_key_switch_technique`: key-switching technique, a member of
  [KeySwitchTechnique](https://openfheorg.github.io/openfhe.R/reference/KeySwitchTechnique.md).

- `set_scaling_technique`: scaling technique, a member of
  [ScalingTechnique](https://openfheorg.github.io/openfhe.R/reference/ScalingTechnique.md).

- `set_batch_size`: batch size (number of plaintext slots).

- `set_first_mod_size`: bit size of the first modulus.

- `set_num_large_digits`: number of large digits for hybrid key
  switching.

- `set_multiplicative_depth`: multiplicative depth.

- `set_scaling_mod_size`: bit size of the scaling moduli.

- `set_security_level`: security level, a member of
  [SecurityLevel](https://openfheorg.github.io/openfhe.R/reference/SecurityLevel.md).

- `set_ring_dim`: ring dimension.

- `set_eval_add_count`: number of additions per level (BFV, BGV).

- `set_key_switch_count`: number of key switches per level (BFV, BGV).

- `set_encryption_technique`: encryption technique (BFV), a member of
  [EncryptionTechnique](https://openfheorg.github.io/openfhe.R/reference/EncryptionTechnique.md).

- `set_multiplication_technique`: multiplication technique (BFV), a
  member of
  [MultiplicationTechnique](https://openfheorg.github.io/openfhe.R/reference/MultiplicationTechnique.md).

- `set_pre_num_hops`: number of proxy re-encryption hops (BGV).

- `set_interactive_boot_compression_level`: compression level for
  interactive bootstrapping (CKKS), a member of
  [CompressionLevel](https://openfheorg.github.io/openfhe.R/reference/CompressionLevel.md).

- `set_composite_degree`: composite degree for composite scaling (CKKS).

- `set_register_word_size`: register word size for composite scaling
  (CKKS).

## See also

[ccparams_getters](https://openfheorg.github.io/openfhe.R/reference/ccparams_getters.md)
for the matching `get_*` functions;
[`BFVParams()`](https://openfheorg.github.io/openfhe.R/reference/BFVParams.md),
[`BGVParams()`](https://openfheorg.github.io/openfhe.R/reference/BGVParams.md),
[`CKKSParams()`](https://openfheorg.github.io/openfhe.R/reference/CKKSParams.md).

## Examples

``` r
p <- CKKSParams()
set_multiplicative_depth(p, 2L)
set_scaling_mod_size(p, 50L)
set_batch_size(p, 8L)
get_multiplicative_depth(p)
#> [1] 2
```
