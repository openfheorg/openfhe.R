# Distribution Type (lattice parameters)

Mirrors the C++ enum `DistributionType` in
`core/lattice/stdlatticeparms.h`.

## Usage

``` r
DistributionType
```

## Value

A named `list` of 3 integer scalars, each the value of the OpenFHE C++
enumerator of the same name, naming the secret distribution a row of the
HomomorphicEncryption.org standard parameter tables applies to:
`HEStd_uniform`, `HEStd_error` or `HEStd_ternary`.
