# Security Levels

Mirrors the C++ enum `SecurityLevel` in
`core/lattice/stdlatticeparms.h`.

## Usage

``` r
SecurityLevel
```

## Value

A named `list` of 7 integer scalars, each the value of the OpenFHE C++
enumerator of the same name. An element names the number of bits of
security the ring dimension is chosen to provide against a classical
(`HEStd_*_classic`) or quantum (`HEStd_*_quantum`) adversary, following
the HomomorphicEncryption.org standard tables. `HEStd_NotSet` skips the
table lookup, in which case the ring dimension must be set explicitly.
Pass an element as the `security_level` argument of
[`CKKSParams()`](https://openfheorg.github.io/openfhe.R/reference/CKKSParams.md),
[`BFVParams()`](https://openfheorg.github.io/openfhe.R/reference/BFVParams.md),
[`BGVParams()`](https://openfheorg.github.io/openfhe.R/reference/BGVParams.md)
or
[`fhe_context()`](https://openfheorg.github.io/openfhe.R/reference/fhe_context.md).
