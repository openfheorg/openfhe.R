# BFV Parameters

Constructor for the BFV scheme's `CCParams` surface. Every argument maps
1:1 to an upstream `CCParams<CryptoContextBFVRNS>::Set*` method whose
override is *not* disabled in the BFV specialization. The 13 setters
that BFV explicitly disables (`SetScalingTechnique`, `SetFirstModSize`,
`SetPRENumHops`, `SetExecutionMode`, …) are not exposed here; see
discovery D013.

## Usage

``` r
BFVParams(
  plaintext_modulus = NULL,
  multiplicative_depth = NULL,
  scaling_mod_size = NULL,
  batch_size = NULL,
  security_level = NULL,
  secret_key_dist = NULL,
  key_switch_technique = NULL,
  ring_dim = NULL,
  digit_size = NULL,
  num_large_digits = NULL,
  standard_deviation = NULL,
  multiparty_mode = NULL,
  threshold_num_of_parties = NULL,
  multiplication_technique = NULL,
  max_relin_sk_deg = NULL,
  pre_mode = NULL,
  eval_add_count = NULL,
  key_switch_count = NULL,
  encryption_technique = NULL
)
```

## Arguments

- plaintext_modulus:

  Integer modulus `t` for the BFV plaintext space. BFV plaintexts are
  elements of `Z_t[x]/Phi_m(x)` and every homomorphic operation is
  performed modulo `t`. Must be a prime (or a composite supporting NTT
  in the batching case) and must be at least large enough that the
  end-to-end computation does not wrap modulo `t`. Typical values:
  `65537` (the smallest batching-friendly prime) for small-integer
  arithmetic, `786433` or larger when the operands or intermediate sums
  are larger. There is no scheme-level default — the user must supply
  one.

- multiplicative_depth:

  Integer depth of the multiplication circuit the context must support.
  BFV and BGV grow ciphertext noise with each multiplication, and the
  ring modulus `q` is sized by OpenFHE to survive exactly
  `multiplicative_depth` successive multiplications plus an `EvalAdd`
  chain between them. Set to the exact depth of your circuit; setting it
  too small causes correctness failure at decrypt, setting it too large
  inflates ring dimension and slows every operation. Couples tightly to
  `security_level` (together they pin `ring_dim`).

- scaling_mod_size:

  Integer bit-size of each intermediate scaling modulus in the RNS
  decomposition of `q`. Default leaves OpenFHE to choose from its
  internal tables (typically 60 bits). Override only when you know your
  depth budget needs a tighter value; the upstream simple-integers
  example uses the default.

- batch_size:

  Integer number of SIMD-batched plaintext slots. Default is
  `ring_dim / 2` under the full-packing convention. Set to a smaller
  power of two when your input vector is short and rotation cost
  dominates the circuit (the inner-product idiom). Must divide
  `ring_dim / 2`. Couples to `ring_dim`.

- security_level:

  One of `SecurityLevel$HEStd_128_classic` (default when unset),
  `HEStd_192_classic`, `HEStd_256_classic`, and their `_quantum`
  counterparts. Fixes the target hardness assumption and, together with
  `multiplicative_depth`, determines the minimum ring dimension via the
  upstream lattice-parameters tables in
  `core/lattice/stdlatticeparms.h`.

- secret_key_dist:

  One of `SecretKeyDist$GAUSSIAN`, `UNIFORM_TERNARY` (default under
  classic lattice parameters), or `SPARSE_TERNARY`. Controls the
  coefficient distribution of the secret key. Change only for research
  scenarios that demand a specific distribution; every production
  vignette uses the default.

- key_switch_technique:

  One of `KeySwitchTechnique$BV` (default for BFV) or `HYBRID`. `BV`
  produces smaller evaluation keys and is the simpler option; `HYBRID`
  is relevant only when you are also setting `num_large_digits` and
  benchmarking rotation cost.

- ring_dim:

  Integer power-of-two lattice ring dimension. Default (`NULL`) asks
  OpenFHE to compute the minimum ring dimension that satisfies
  `security_level` at the chosen `multiplicative_depth`. Override only
  to force a larger value than the auto-selection, typically to reserve
  headroom for later parameter sweeps.

- digit_size:

  Integer `r` for BV key-switching: the base-`2^r` digit decomposition
  of the ciphertext during a key-switch. Default `0L` selects the
  upstream default. Larger values decrease the number of digit
  multiplications at the cost of larger per-digit noise.

- num_large_digits:

  Integer number of digit groupings in HYBRID key switching. Only
  meaningful when `key_switch_technique = KeySwitchTechnique$HYBRID`;
  ignored otherwise. Default `0L` lets OpenFHE pick.

- standard_deviation:

  Numeric standard deviation of the Gaussian error distribution used
  during key generation and encryption. Default (`NULL`) uses the
  upstream default `3.19`. Override only in research scenarios.

- multiparty_mode:

  One of `MultipartyMode$FIXED_NOISE_MULTIPARTY` or
  `NOISE_FLOODING_MULTIPARTY`. Selects between threshold-FHE with fixed
  noise (no flooding) and noise-flooding-protected threshold-FHE. Both
  cox-threshold and CVXR-consensus-ADMM vignettes rely on threshold
  paths; leave at upstream default unless you are intentionally tuning
  the leakage/performance trade-off.

- threshold_num_of_parties:

  Integer count of parties in an n-of-n threshold protocol. Ignored in
  non-threshold contexts. The cox-threshold vignette uses 2; the
  threshold-fhe-5p Python example uses 5.

- multiplication_technique:

  One of `MultiplicationTechnique$BEHZ`, `HPS`, `HPSPOVERQ`,
  `HPSPOVERQLEVELED`. BFV-specific choice of how the plaintext modulus
  interacts with the ciphertext modulus during multiply. Default
  upstream is `HPSPOVERQLEVELED`; override only if you are benchmarking
  multiplication-path variants.

- max_relin_sk_deg:

  `parity-deferred:` maximum degree of the secret key that can be
  relinearized. Upstream default is 2. No current vignette or Python
  example exercises this; the cpp11 binding is in place so a later
  release can promote it without a recompile.

- pre_mode:

  `parity-deferred:` proxy re-encryption mode (`PREMode$NOT_SET`,
  `INDCPA`, `FIXED_NOISE_HRA`, `NOISE_FLOODING_HRA`). Only meaningful if
  the `PRE` feature is enabled on the context. No current vignette uses
  PRE.

- eval_add_count:

  `parity-deferred:` upstream noise-budget hint: maximum additions
  between multiplications. Used only by the noise-flooding path. Default
  0.

- key_switch_count:

  `parity-deferred:` upstream noise-budget hint: maximum key-switch
  count. Default 0.

- encryption_technique:

  `parity-deferred:` BFV-specific encryption variant
  (`EncryptionTechnique$STANDARD` or `EXTENDED`). Default STANDARD.

## Value

A `BFVParams` S7 object.
