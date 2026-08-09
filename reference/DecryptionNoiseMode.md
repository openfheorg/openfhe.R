# Decryption Noise Mode

Mirrors the C++ enum `DecryptionNoiseMode` in `pke/constants-defs.h`.

## Usage

``` r
DecryptionNoiseMode
```

## Value

A named `list` of 2 integer scalars, each the value of the OpenFHE C++
enumerator of the same name: `FIXED_NOISE_DECRYPT` decrypts with a fixed
noise estimate, while `NOISE_FLOODING_DECRYPT` floods the result with
extra noise so that the decryption itself leaks nothing about the
circuit. Pass an element as the `decryption_noise_mode` argument of
[`CKKSParams()`](https://openfheorg.github.io/openfhe.R/reference/CKKSParams.md)
or
[`fhe_context()`](https://openfheorg.github.io/openfhe.R/reference/fhe_context.md).
