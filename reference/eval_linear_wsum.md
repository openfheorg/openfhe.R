# Weighted sum of ciphertexts (CKKS)

Computes
`constants[1] * ciphertexts[[1]] + ... + constants[n] * ciphertexts[[n]]`.

## Usage

``` r
eval_linear_wsum(ciphertexts, constants)

eval_linear_wsum_mutable(constants, ciphertexts)
```

## Arguments

- ciphertexts:

  A non-empty list of `Ciphertext` objects.

- constants:

  One constant per ciphertext: an integer, double or complex vector.
  Each type is evaluated with its own arithmetic.

## Value

A `Ciphertext`.

## Details

`eval_linear_wsum_mutable()` may adjust the given ciphertexts (their
level and scale) while it works, which saves copies. It takes the
constants first, as the C++ function of that name does.
