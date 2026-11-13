# Homomorphic subtract, mutable variant

Homomorphic subtract, mutable variant

## Usage

``` r
eval_sub_mutable(x, ...)
```

## Arguments

- x:

  A `Ciphertext` or a `Plaintext` (may be modified internally).

- ...:

  Method-specific arguments: `y`, a `Ciphertext` or a `Plaintext` (may
  be modified internally). At least one of `x` and `y` is a
  `Ciphertext`.

## Value

A new `Ciphertext` holding `x - y`.
