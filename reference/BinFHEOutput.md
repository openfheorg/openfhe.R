# Binary FHE Output Types

Mirrors the C++ enum `BINFHE_OUTPUT` in `binfhe/binfhe-constants.h`.

## Usage

``` r
BinFHEOutput
```

## Value

A named `list` of 5 integer scalars, each the value of the OpenFHE C++
enumerator of the same name, describing the form the ciphertext produced
by a BinFHE operation should take: `FRESH` (noise reset to the level of
a fresh encryption), `BOOTSTRAPPED`, `LARGE_DIM` and `SMALL_DIM` (the
LWE dimension the result is expressed in). `INVALID_OUTPUT` marks an
unset value. Pass an element as the `output` argument of
[`bin_encrypt()`](https://openfheorg.github.io/openfhe.R/reference/bin_encrypt.md).
