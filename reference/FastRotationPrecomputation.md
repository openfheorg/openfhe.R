# Precomputed digit decomposition for hoisted rotations

Returned by
[`eval_fast_rotation_precompute()`](https://openfheorg.github.io/openfhe.R/reference/eval_fast_rotation_precompute.md)
and consumed by
[`eval_fast_rotation()`](https://openfheorg.github.io/openfhe.R/reference/eval_fast_rotation.md).
Hoisting amortizes the per-rotation decomposition over many rotations of
the same source ciphertext.

## Usage

``` r
FastRotationPrecomputation(ptr = NULL)
```

## Arguments

- ptr:

  External pointer (internal use)
