# Hoisted slot rotation using precomputed digits

Hoisted slot rotation using precomputed digits

## Usage

``` r
eval_fast_rotation(ct, ...)
```

## Arguments

- ct:

  A Ciphertext

- ...:

  Method-specific arguments: `index` (rotation amount, positive = left,
  negative = right), `m` (cyclotomic order, typically
  `2 * ring_dimension(ctx)`), `precomp` (a FastRotationPrecomputation
  from
  [`eval_fast_rotation_precompute()`](https://bnaras.github.io/openfhe.R/reference/eval_fast_rotation_precompute.md))

## Value

A Ciphertext
