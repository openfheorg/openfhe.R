# Get the required multiplicative depth for CKKS bootstrapping

Get the required multiplicative depth for CKKS bootstrapping

## Usage

``` r
get_bootstrap_depth(
  level_budget,
  secret_key_dist = SecretKeyDist$UNIFORM_TERNARY,
  approx_mod_depth = NULL
)
```

## Arguments

- level_budget:

  Integer vector of length 2

- secret_key_dist:

  Secret key distribution, an element of
  [SecretKeyDist](https://openfheorg.github.io/openfhe.R/reference/SecretKeyDist.md)
  (default: `SecretKeyDist$UNIFORM_TERNARY`)

- approx_mod_depth:

  Optional integer: the depth of the Chebyshev interpolation of the
  approximate modular reduction. When given, the three-argument C++ form
  is called, which OpenFHE keeps for backward compatibility. `NULL`
  (default) calls the two-argument form, which derives that depth from
  `secret_key_dist`.

## Value

Integer: required depth
