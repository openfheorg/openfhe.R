# Generate a sparse key pair

Calls the C++ `SparseKeyGen()`, which the OpenFHE header describes as a
key pair "with special structure and without full entropy" for uses such
as ring reduction, and as not supported by any scheme at present. Use
[`key_gen()`](https://openfheorg.github.io/openfhe.R/reference/key_gen.md)
for ordinary keys.

## Usage

``` r
sparse_key_gen(cc)
```

## Arguments

- cc:

  A `CryptoContext`.

## Value

A `KeyPair`.
