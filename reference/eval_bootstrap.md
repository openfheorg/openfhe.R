# Perform CKKS bootstrapping

Refreshes the ciphertext to allow further computation.

## Usage

``` r
eval_bootstrap(ct, num_iterations = 1L, precision = 0L)
```

## Arguments

- ct:

  A Ciphertext

- num_iterations:

  Number of bootstrap iterations (default: 1)

- precision:

  Target precision (default: 0 = automatic)

## Value

A refreshed Ciphertext
