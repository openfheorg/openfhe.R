# Extended hoisted slot rotation

Applies a rotation using precomputed digit decomposition like
[`eval_fast_rotation()`](https://openfheorg.github.io/openfhe.R/reference/eval_fast_rotation.md),
but with the extension that the first digit of the decomposition can be
folded into the output before the rotation is applied (controlled by
`add_first`). Used inside the CKKS bootstrap fast-rotation inner loop
per `openfhe-development`'s `scheme/base-scheme.cpp`. The eval-key map
is pulled from the `CryptoContext` internal registry via the
ciphertext's key tag, so there is no `EvalKeyMap` argument at the R
boundary — the automorphism keys must already be resident on the cc
(call `key_gen(cc, rotations = ...)` to populate them, then reuse the
`ct` here).

## Usage

``` r
eval_fast_rotation_ext(ct, ...)
```

## Arguments

- ct:

  A `Ciphertext`.

- ...:

  Method-specific arguments: `index` (rotation amount, positive = left,
  negative = right), `precomp` (a `FastRotationPrecomputation` from
  [`eval_fast_rotation_precompute()`](https://openfheorg.github.io/openfhe.R/reference/eval_fast_rotation_precompute.md)),
  `add_first` (logical, default `FALSE`).

## Value

A `Ciphertext`.

## See also

[`eval_fast_rotation()`](https://openfheorg.github.io/openfhe.R/reference/eval_fast_rotation.md)
