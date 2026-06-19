# Get the required multiplicative depth for CKKS bootstrapping

Get the required multiplicative depth for CKKS bootstrapping

## Usage

``` r
get_bootstrap_depth(level_budget, secret_key_dist = 1L)
```

## Arguments

- level_budget:

  Integer vector of length 2

- secret_key_dist:

  Secret key distribution (default: UNIFORM_TERNARY = 1)

## Value

Integer: required depth
