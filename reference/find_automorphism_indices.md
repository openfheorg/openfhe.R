# Compute the automorphism indices for a list of slot indices

Vector form of
[`find_automorphism_index()`](https://openfheorg.github.io/openfhe.R/reference/find_automorphism_index.md).
Takes a vector of slot indices and returns the corresponding
automorphism indices in the same order.

## Usage

``` r
find_automorphism_indices(cc, indices)
```

## Arguments

- cc:

  A `CryptoContext`.

- indices:

  Integer vector of slot indices.

## Value

Integer vector of automorphism indices.

## See also

[`find_automorphism_index()`](https://openfheorg.github.io/openfhe.R/reference/find_automorphism_index.md)
