# Polynomial representation

Mirrors the C++ enum `Format` in `core/utils/inttypes.h`: whether a ring
element is held in `EVALUATION` (number-theoretic transform) or
`COEFFICIENT` representation. Used by
[`set_format()`](https://openfheorg.github.io/openfhe.R/reference/get_element_modulus.md).

## Usage

``` r
Format
```

## Value

A named `list` of 2 integer scalars, each the value of the OpenFHE C++
enumerator of the same name.
