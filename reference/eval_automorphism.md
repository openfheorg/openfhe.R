# Apply an automorphism to a ciphertext

Evaluates the automorphism at the given index on `ct` using the eval-key
map returned by
[`eval_automorphism_key_gen()`](https://openfheorg.github.io/openfhe.R/reference/eval_automorphism_key_gen.md).
The result is a new ciphertext whose decrypted slot vector is a
permutation of `ct`'s slot vector (the permutation determined by the
automorphism group element).

## Usage

``` r
eval_automorphism(ct, index, eval_key_map)
```

## Arguments

- ct:

  A `Ciphertext`.

- index:

  Integer; the automorphism index (must match one of the indices passed
  to
  [`eval_automorphism_key_gen()`](https://openfheorg.github.io/openfhe.R/reference/eval_automorphism_key_gen.md)).

- eval_key_map:

  An `EvalKeyMap` from
  [`eval_automorphism_key_gen()`](https://openfheorg.github.io/openfhe.R/reference/eval_automorphism_key_gen.md).

## Value

A transformed `Ciphertext`.

## See also

[`eval_automorphism_key_gen()`](https://openfheorg.github.io/openfhe.R/reference/eval_automorphism_key_gen.md),
[`eval_rotate()`](https://openfheorg.github.io/openfhe.R/reference/eval_rotate.md)
