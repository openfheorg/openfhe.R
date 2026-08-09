# PKE Scheme Features (bitmask)

Mirrors the C++ enum `PKESchemeFeature` in `pke/constants-defs.h`. The
values are bit flags, so several may be combined with
[`bitwOr()`](https://rdrr.io/r/base/bitwise.html) to describe a set of
capabilities.

## Usage

``` r
Feature
```

## Value

A named `list` of 8 integer scalars. Each element carries the integer
value the OpenFHE C++ enumerator of the same name has, and names a
capability of a crypto context: `PKE` (encryption and decryption),
`KEYSWITCH`, `PRE` (proxy re-encryption), `LEVELEDSHE` (leveled
homomorphic arithmetic), `ADVANCEDSHE`, `MULTIPARTY`, `FHE`
(bootstrapping) and `SCHEMESWITCH`. Pass an element to
[`enable_feature()`](https://openfheorg.github.io/openfhe.R/reference/enable_feature.md)
to turn that capability on for a context.
