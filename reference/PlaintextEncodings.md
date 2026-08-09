# Plaintext Encoding Types

Mirrors the C++ enum `PlaintextEncodings` in `pke/constants-defs.h`.

## Usage

``` r
PlaintextEncodings
```

## Value

A named `list` of 5 integer scalars, each the value of the OpenFHE C++
enumerator of the same name, naming how values are laid out inside a
plaintext polynomial: `COEF_PACKED_ENCODING`, `PACKED_ENCODING` (integer
SIMD slots), `STRING_ENCODING` and `CKKS_PACKED_ENCODING` (approximate
real or complex slots). `INVALID_ENCODING` marks an unset value. This is
the value reported by
[`get_encoding_type()`](https://openfheorg.github.io/openfhe.R/reference/plaintext_accessors.md)
on a `Plaintext`.
