# Multiparty Mode

Mirrors the C++ enum `MultipartyMode` in `pke/constants-defs.h`.

## Usage

``` r
MultipartyMode
```

## Value

A named `list` of 3 integer scalars, each the value of the OpenFHE C++
enumerator of the same name, selecting how a threshold context masks the
secret shares: `FIXED_NOISE_MULTIPARTY` adds a fixed amount of noise,
while `NOISE_FLOODING_MULTIPARTY` adds enough to give provable circuit
privacy at a higher cost. `INVALID_MULTIPARTY_MODE` marks an unset
value. Pass an element as the `multiparty_mode` argument of
[`BFVParams()`](https://openfheorg.github.io/openfhe.R/reference/BFVParams.md),
[`BGVParams()`](https://openfheorg.github.io/openfhe.R/reference/BGVParams.md)
or
[`fhe_context()`](https://openfheorg.github.io/openfhe.R/reference/fhe_context.md).
