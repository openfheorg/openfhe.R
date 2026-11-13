# Homomorphic add, mutable variant

The Mutable\* family exists so that operations that can safely mutate
their inputs during evaluation (e.g. a temporary intermediate in a
longer circuit) can do so without forcing a defensive copy. Semantically
equivalent to the non-Mutable counterpart from the user's perspective;
the difference is performance under specific workloads.

## Usage

``` r
eval_add_mutable(x, ...)
```

## Arguments

- x:

  A `Ciphertext` or a `Plaintext` (may be modified internally).

- ...:

  Method-specific arguments: `y`, a `Ciphertext` or a `Plaintext` (may
  be modified internally). At least one of `x` and `y` is a
  `Ciphertext`.

## Value

A new `Ciphertext` holding `x + y`.
