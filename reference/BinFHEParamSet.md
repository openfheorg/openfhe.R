# Binary FHE Parameter Sets

Mirrors the C++ enum `BINFHE_PARAMSET` in `binfhe/binfhe-constants.h`,
whose enumerators are numbered sequentially from 0.

## Usage

``` r
BinFHEParamSet
```

## Value

A named `list` of 44 integer scalars, each the value of the OpenFHE C++
enumerator of the same name. An element names a pre-tabulated set of
lattice parameters for the boolean-circuit (BinFHE) schemes: `TOY` and
`MEDIUM` are insecure sizes for experimentation, and the `STD128`,
`STD192` and `STD256` families give the corresponding bits of security,
with the `Q` suffix denoting a larger ciphertext modulus, the `_3` and
`_4` suffixes 3- and 4-input gates, `LMKCDEY` the
Lee-Micciancio-Kim-Choi-Deryabin-Eom-Yoo bootstrapping method and `LPF`
a low-probability-of-failure variant. Pass an element as the `paramset`
argument of
[`bin_fhe_context()`](https://openfheorg.github.io/openfhe.R/reference/bin_fhe_context.md).
