# Scheme Identifier

Mirrors the C++ enum `SCHEME` in `pke/scheme/scheme-id.h`. The R-side
name `SchemeId` matches the upstream header filename and avoids
colliding with a potential future `Scheme` S7 class.

## Usage

``` r
SchemeId
```

## Value

A named `list` of 4 integer scalars, each the value of the OpenFHE C++
enumerator of the same name, identifying the encryption scheme a context
implements: `CKKSRNS_SCHEME`, `BFVRNS_SCHEME` or `BGVRNS_SCHEME`, with
`INVALID_SCHEME` for an unset value. This is the value reported by
[`get_scheme()`](https://openfheorg.github.io/openfhe.R/reference/ccparams_getters.md)
on any `CCParams` object.
