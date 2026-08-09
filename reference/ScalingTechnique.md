# Scaling Techniques (CKKS)

Mirrors the C++ enum `ScalingTechnique` in `pke/constants-defs.h`.

## Usage

``` r
ScalingTechnique
```

## Value

A named `list` of 8 integer scalars, each the value of the OpenFHE C++
enumerator of the same name. The element chosen tells a CKKS context how
to manage the scaling factor between multiplications: `FIXEDMANUAL`
leaves rescaling to the caller, `FIXEDAUTO` and the `FLEXIBLE*` variants
rescale automatically with increasing precision, the `COMPOSITESCALING*`
variants split the scaling factor across several moduli, and `NORESCALE`
disables rescaling. `INVALID_RS_TECHNIQUE` marks an unset value. Pass an
element as the `scaling_technique` argument of
[`CKKSParams()`](https://openfheorg.github.io/openfhe.R/reference/CKKSParams.md),
[`BGVParams()`](https://openfheorg.github.io/openfhe.R/reference/BGVParams.md)
or
[`fhe_context()`](https://openfheorg.github.io/openfhe.R/reference/fhe_context.md).
