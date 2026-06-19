# CKKS scaling-mod-size in bits

Reads the real-valued scaling factor at level 0 from `cc` via
[`get_scaling_factor_real()`](https://bnaras.github.io/openfhe.R/reference/get_scaling_factor_real.md)
and returns its `log2` rounded to the nearest integer. For a CKKS
context constructed with `set_scaling_mod_size(50L)` this returns `50L`.

## Usage

``` r
ckks_scaling_factor_bits(cc)
```

## Arguments

- cc:

  A `CryptoContext` (should be CKKS — meaningful only for CKKS
  contexts).

## Value

Integer.

## Details

Used by the Stage 2 form of
[`fhe_ckks_tolerance()`](https://bnaras.github.io/openfhe.R/reference/fhe_ckks_tolerance.md).
