# Key Switching Techniques

Mirrors the C++ enum `KeySwitchTechnique` in `pke/constants-defs.h`.

## Usage

``` r
KeySwitchTechnique
```

## Value

A named `list` of 3 integer scalars, each the value of the OpenFHE C++
enumerator of the same name. `BV` selects the Brakerski-Vaikuntanathan
digit-decomposition key switch and `HYBRID` the hybrid variant, which is
the usual choice; `INVALID_KS_TECH` marks an unset value. Pass an
element as the `key_switch_technique` argument of
[`CKKSParams()`](https://openfheorg.github.io/openfhe.R/reference/CKKSParams.md),
[`BFVParams()`](https://openfheorg.github.io/openfhe.R/reference/BFVParams.md),
[`BGVParams()`](https://openfheorg.github.io/openfhe.R/reference/BGVParams.md)
or
[`fhe_context()`](https://openfheorg.github.io/openfhe.R/reference/fhe_context.md).
