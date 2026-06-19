# Real-valued CKKS scaling factor at a modulus-chain level

Returns `cryptoParams->GetScalingFactorReal(level)` — the double-valued
scaling factor at the given `level` of the CKKS modulus chain.
Meaningful only for CKKS contexts; BFV/BGV contexts return the default
field value (effectively `1.0`).

## Usage

``` r
get_scaling_factor_real(cc, ...)
```

## Arguments

- cc:

  A `CryptoContext`.

- ...:

  Method-specific arguments. The CryptoContext method accepts `level`
  (integer level in the RNS modulus chain, default `0L` — the top of the
  chain = the scaling factor at fresh encryption time).

## Value

Numeric scalar.

## Details

Used by
[`ckks_scaling_factor_bits()`](https://bnaras.github.io/openfhe.R/reference/ckks_scaling_factor_bits.md)
(which takes `log2` of the level-0 value to recover the bit size
originally set via `set_scaling_mod_size()`) and by the Stage 2 form of
[`fhe_ckks_tolerance()`](https://bnaras.github.io/openfhe.R/reference/fhe_ckks_tolerance.md).
