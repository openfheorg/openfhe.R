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

## Value

An S7 object of class `FastRotationPrecomputation`, inheriting from
[OpenFHEObject](https://openfheorg.github.io/openfhe.R/reference/OpenFHEObject.md),
whose `ptr` property holds an external pointer to the C++ digit
decomposition. It caches the work that is common to every rotation of
one source ciphertext; obtain one from
[`eval_fast_rotation_precompute()`](https://openfheorg.github.io/openfhe.R/reference/eval_fast_rotation_precompute.md)
and pass it to
[`eval_fast_rotation()`](https://openfheorg.github.io/openfhe.R/reference/eval_fast_rotation.md)
rather than calling this constructor directly.
