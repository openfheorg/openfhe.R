# BGV Parameters

Constructor for the BGV scheme's `CCParams` surface. Every argument maps
1:1 to an enabled `CCParams<CryptoContextBGVRNS>::Set*` method. The 10
BGV-disabled setters (`SetEncryptionTechnique`,
`SetMultiplicationTechnique`, `SetExecutionMode`, …) are not exposed;
see discovery D013.

## Usage

``` r
BGVParams(
  plaintext_modulus = NULL,
  multiplicative_depth = NULL,
  scaling_mod_size = NULL,
  scaling_technique = NULL,
  batch_size = NULL,
  first_mod_size = NULL,
  security_level = NULL,
  secret_key_dist = NULL,
  key_switch_technique = NULL,
  ring_dim = NULL,
  digit_size = NULL,
  num_large_digits = NULL,
  standard_deviation = NULL,
  multiparty_mode = NULL,
  threshold_num_of_parties = NULL,
  max_relin_sk_deg = NULL,
  pre_mode = NULL,
  statistical_security = NULL,
  num_adversarial_queries = NULL,
  eval_add_count = NULL,
  key_switch_count = NULL,
  pre_num_hops = NULL
)
```

## Arguments

- plaintext_modulus:

  Integer modulus `t` for the BGV plaintext space. See the BFV entry for
  full semantics; BGV shares the same `Z_t`-valued plaintext model.

- multiplicative_depth:

  Integer multiplicative depth; sizes the ring modulus `q`. See the BFV
  entry for the full coupling.

- scaling_mod_size:

  Integer bit-size per scaling modulus in the modulus chain.

- scaling_technique:

  One of `ScalingTechnique$FIXEDMANUAL`, `FIXEDAUTO`, `FLEXIBLEAUTO`
  (upstream default), `FLEXIBLEAUTOEXT`. Selects whether the scheme
  rescales automatically between multiplications (`*AUTO*`) or leaves it
  to the caller (`FIXEDMANUAL`). Every vignette uses an auto mode; pick
  `FIXEDMANUAL` only if you need deterministic control over rescale
  insertion.

- batch_size:

  Integer SIMD slot count; see the BFV entry.

- first_mod_size:

  Integer bit size of the first (largest) prime in the modulus chain.
  Default leaves OpenFHE to pick. Override only when tuning the noise
  budget at the top of the chain.

- security_level:

  See the BFV entry.

- secret_key_dist:

  See the BFV entry.

- key_switch_technique:

  See the BFV entry. BGV accepts both `BV` and `HYBRID`.

- ring_dim:

  See the BFV entry.

- digit_size:

  See the BFV entry.

- num_large_digits:

  See the BFV entry.

- standard_deviation:

  See the BFV entry.

- multiparty_mode:

  See the BFV entry.

- threshold_num_of_parties:

  See the BFV entry.

- max_relin_sk_deg:

  `parity-deferred:` see the BFV entry.

- pre_mode:

  `parity-deferred:` see the BFV entry.

- statistical_security:

  `parity-deferred:` statistical security parameter (bits), used by the
  noise-flooding decryption path.

- num_adversarial_queries:

  `parity-deferred:` upper bound on the number of adversarial queries
  the noise-flooding path must survive.

- eval_add_count:

  `parity-deferred:` see the BFV entry.

- key_switch_count:

  `parity-deferred:` see the BFV entry.

- pre_num_hops:

  `parity-deferred:` maximum number of hops for proxy re-encryption in
  BGV. Only meaningful if the PRE feature is enabled.

## Value

A `BGVParams` S7 object.
