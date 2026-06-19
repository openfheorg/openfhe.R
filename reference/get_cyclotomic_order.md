# Cyclotomic order of a CryptoContext

Integer `m` such that the underlying polynomial ring is `Z[x]/(x^n + 1)`
with `n = m/2` (the ring dimension). Always `2 * ring_dimension(cc)` for
power-of-two cyclotomics.

## Usage

``` r
get_cyclotomic_order(cc, ...)
```

## Arguments

- cc:

  A `CryptoContext`.

- ...:

  Reserved for future method-specific arguments.

## Value

Integer.
