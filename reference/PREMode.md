# Proxy Re-encryption Mode

Mirrors the C++ enum `ProxyReEncryptionMode` in `pke/constants-defs.h`.
The R-side name `PREMode` is a shortened form, the same pattern as
`Feature` for `PKESchemeFeature`.

## Usage

``` r
PREMode
```

## Value

A named `list` of 4 integer scalars, each the value of the OpenFHE C++
enumerator of the same name, naming the security notion the
re-encryption key should satisfy: `INDCPA`, `FIXED_NOISE_HRA` or
`NOISE_FLOODING_HRA`, the last two being honest-re-encryption-attack
secure. `NOT_SET` disables proxy re-encryption. Pass an element as the
`pre_mode` argument of
[`CKKSParams()`](https://openfheorg.github.io/openfhe.R/reference/CKKSParams.md),
[`BFVParams()`](https://openfheorg.github.io/openfhe.R/reference/BFVParams.md),
[`BGVParams()`](https://openfheorg.github.io/openfhe.R/reference/BGVParams.md)
or
[`fhe_context()`](https://openfheorg.github.io/openfhe.R/reference/fhe_context.md).
