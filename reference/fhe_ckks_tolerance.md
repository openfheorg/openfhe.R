# Per-test CKKS precision tolerance

Computes a tolerance value suitable for comparing the cleartext result
of a CKKS circuit against a decrypted ciphertext. The value is a
function of the scheme's scaling factor, the circuit's multiplicative
depth at the point of decryption, and the `ScalingTechnique`-specific
precision loss per level.

## Usage

``` r
fhe_ckks_tolerance(x, ...)
```

## Arguments

- x:

  For the numeric method: integer multiplicative depth at the point of
  decryption. For the Ciphertext method: a `Ciphertext` object whose
  associated context supplies all parameters.

- ...:

  Method-specific arguments. The numeric method accepts
  `scaling_factor_bits` (integer bit size of the scaling modulus,
  typical values 50/59/78), `scaling_technique` (a character string like
  `"FLEXIBLEAUTO"` or an integer from the `ScalingTechnique` enum), and
  `k` (conservative multiplicative factor, default 8). The Ciphertext
  method accepts only `k`.

## Value

Numeric scalar — the tolerance value to use as `tolerance` in
[`tinytest::expect_equal()`](https://rdrr.io/pkg/tinytest/man/expect_equal.html)
or as `atol` in a manual diff.

## Details

Two dispatch forms:

- **Stage 1 (numeric)**: pass parameters as direct arguments. Useful
  when the ciphertext isn't yet constructed — e.g. in a fixture setup
  block that has to produce a tolerance before calling
  [`encrypt()`](https://bnaras.github.io/openfhe.R/reference/encrypt.md).

- **Stage 2 (Ciphertext)**: pass a `Ciphertext` directly. The helper
  reads the associated `CryptoContext` via
  [`get_crypto_context()`](https://bnaras.github.io/openfhe.R/reference/get_crypto_context.md),
  pulls the multiplicative depth (from context) minus the ciphertext's
  current level, computes the scaling factor bits via
  [`ckks_scaling_factor_bits()`](https://bnaras.github.io/openfhe.R/reference/ckks_scaling_factor_bits.md),
  and looks up the scaling technique. This form is preferred at test
  sites where a ciphertext exists.

## Examples

``` r
# Stage 1 — pass parameters directly:
tol1 <- fhe_ckks_tolerance(4L, 50L, "FLEXIBLEAUTO")

# Stage 2 — pass a ciphertext (requires a live CKKS context):
# cc <- fhe_context("CKKS", multiplicative_depth = 4L, scaling_mod_size = 50L)
# kp <- key_gen(cc, eval_mult = TRUE)
# pt <- make_ckks_packed_plaintext(cc, c(0.1, 0.2, 0.3, 0.4))
# ct <- encrypt(kp@public, pt, cc)
# tol2 <- fhe_ckks_tolerance(ct)
```
