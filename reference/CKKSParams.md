# CKKS Parameters

Constructor for the CKKS scheme's `CCParams` surface. Every argument
maps 1:1 to an enabled `CCParams<CryptoContextCKKSRNS>::Set*` method.
The 8 CKKS-disabled setters (`SetPlaintextModulus`, `SetEvalAddCount`,
`SetKeySwitchCount`, `SetEncryptionTechnique`,
`SetMultiplicationTechnique`, `SetPRENumHops`, `SetMultipartyMode`,
`SetThresholdNumOfParties`) are not exposed; see discovery D013. CKKS is
a fixed-point scheme over the complex numbers and has no plaintext
modulus; `threshold_num_of_parties` is currently CKKS-disabled upstream
even though the scheme supports threshold variants via a separate code
path.

## Usage

``` r
CKKSParams(
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
  interactive_boot_compression_level = NULL,
  standard_deviation = NULL,
  register_word_size = NULL,
  ckks_data_type = NULL,
  max_relin_sk_deg = NULL,
  pre_mode = NULL,
  execution_mode = NULL,
  decryption_noise_mode = NULL,
  noise_estimate = NULL,
  desired_precision = NULL,
  statistical_security = NULL,
  num_adversarial_queries = NULL,
  composite_degree = NULL
)
```

## Arguments

- multiplicative_depth:

  See the BFV entry.

- scaling_mod_size:

  Integer bit-size of the CKKS rescaling factor (typically 50 or 59
  bits). Together with `multiplicative_depth` this pins the modulus
  chain and therefore the precision budget available at the bottom of
  the circuit. Upstream default varies by scaling technique; when in
  doubt use the value the matching Python example uses.

- scaling_technique:

  See the BGV entry. CKKS additionally supports `NORESCALE` (debug-only)
  and the `COMPOSITESCALING*` modes.

- batch_size:

  See the BFV entry.

- first_mod_size:

  See the BGV entry.

- security_level:

  See the BFV entry.

- secret_key_dist:

  See the BFV entry.

- key_switch_technique:

  See the BFV entry. CKKS typically benefits from `HYBRID`.

- ring_dim:

  See the BFV entry.

- digit_size:

  See the BFV entry.

- num_large_digits:

  See the BFV entry.

- interactive_boot_compression_level:

  One of `CompressionLevel$COMPACT` (2) or `SLACK` (3). Controls the
  compression level to which the input ciphertext is brought before
  interactive multi-party bootstrapping. `COMPACT` is more efficient but
  assumes a stronger security model; `SLACK` is less efficient with
  weaker assumptions. Used by the `tckks- interactive-mp-bootstrapping*`
  Python examples.

- standard_deviation:

  See the BFV entry.

- register_word_size:

  Integer word size (in bits) for the register-based multi-precision
  arithmetic path. Default leaves it to upstream. Used by the
  simple-real-numbers-composite- scaling Python example.

- ckks_data_type:

  One of `CKKSDataType$REAL` (default) or `COMPLEX`. Selects whether
  CKKS plaintexts are modeled as real vectors or complex vectors. All
  current R vignettes use `REAL`.

- max_relin_sk_deg:

  `parity-deferred:` see the BFV entry.

- pre_mode:

  `parity-deferred:` see the BFV entry.

- execution_mode:

  `parity-deferred:` one of `ExecutionMode$EXEC_EVALUATION` (default) or
  `EXEC_NOISE_ESTIMATION`. The noise-estimation mode is only used by the
  adversarial-query noise-flooding path.

- decryption_noise_mode:

  `parity-deferred:` one of `DecryptionNoiseMode$FIXED_NOISE_DECRYPT`
  (default) or `NOISE_FLOODING_DECRYPT`.

- noise_estimate:

  `parity-deferred:` numeric noise estimate used by the noise-flooding
  path. Paired with `execution_mode = EXEC_NOISE_ESTIMATION`.

- desired_precision:

  `parity-deferred:` numeric target precision (in bits) for the
  noise-flooding path.

- statistical_security:

  `parity-deferred:` see the BGV entry.

- num_adversarial_queries:

  `parity-deferred:` see the BGV entry.

- composite_degree:

  `parity-deferred:` composite scaling degree for the
  `COMPOSITESCALING*` scaling techniques. Upstream default 0 means
  single-prime scaling.

## Value

A `CKKSParams` S7 object.
