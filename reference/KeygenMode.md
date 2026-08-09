# Key Generation Mode

Mirrors the C++ enum `KEYGEN_MODE` in `binfhe/binfhe-constants.h`.

## Usage

``` r
KeygenMode
```

## Value

A named `list` of 2 integer scalars, each the value of the OpenFHE C++
enumerator of the same name: `SYM_ENCRYPT` generates only the material
needed for symmetric-key encryption, while `PUB_ENCRYPT` additionally
generates a public key. Pass an element as the `keygen_mode` argument of
[`bin_bt_key_gen()`](https://openfheorg.github.io/openfhe.R/reference/bin_bt_key_gen.md).
