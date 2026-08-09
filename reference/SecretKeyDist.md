# Secret Key Distribution

Mirrors the C++ enum `SecretKeyDist` in
`core/lattice/constants-lattice.h`.

## Usage

``` r
SecretKeyDist
```

## Value

A named `list` of 4 integer scalars, each the value of the OpenFHE C++
enumerator of the same name, naming the distribution the secret key
polynomial is drawn from: `GAUSSIAN`, `UNIFORM_TERNARY` (the default,
coefficients uniform on -1, 0, 1), `SPARSE_TERNARY` (ternary with a
fixed small Hamming weight) and `SPARSE_ENCAPSULATED`. Pass an element
as the `secret_key_dist` argument of
[`CKKSParams()`](https://openfheorg.github.io/openfhe.R/reference/CKKSParams.md),
[`BFVParams()`](https://openfheorg.github.io/openfhe.R/reference/BFVParams.md),
[`BGVParams()`](https://openfheorg.github.io/openfhe.R/reference/BGVParams.md)
or
[`fhe_context()`](https://openfheorg.github.io/openfhe.R/reference/fhe_context.md).
