# Precompute digit decomposition for hoisted fast rotations

Computes the digit decomposition of a ciphertext once so that multiple
[`eval_fast_rotation()`](https://bnaras.github.io/openfhe.R/reference/eval_fast_rotation.md)
calls against the same ciphertext avoid redoing it. The cyclotomic order
`m` (typically `2 * N`, where `N` is the ring dimension) is required by
[`eval_fast_rotation()`](https://bnaras.github.io/openfhe.R/reference/eval_fast_rotation.md).

## Usage

``` r
eval_fast_rotation_precompute(ct, ...)
```

## Arguments

- ct:

  A Ciphertext

- ...:

  Reserved for future method-specific arguments

## Value

A FastRotationPrecomputation
