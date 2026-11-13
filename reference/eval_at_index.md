# Rotate the slots of a ciphertext by an index

`eval_at_index(ct, i)` moves slot `i + k` to slot `k`: a positive index
rotates to the left, a negative one to the right. Needs the key for that
index
([`eval_at_index_key_gen()`](https://openfheorg.github.io/openfhe.R/reference/eval_at_index_key_gen.md)).
[`eval_rotate()`](https://openfheorg.github.io/openfhe.R/reference/eval_rotate.md)
calls the C++ function `EvalRotate`, which does the same thing.

## Usage

``` r
eval_at_index(ct, index)
```

## Arguments

- ct:

  A `Ciphertext`.

- index:

  Integer; the rotation index.

## Value

A `Ciphertext`.
