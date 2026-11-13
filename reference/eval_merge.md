# Merge the first slots of several ciphertexts into one

Returns a ciphertext whose slot `i` holds the first slot of the `i`-th
input. The other slots of each input must be zero. Needs the rotation
keys for indices `-1, ..., -(n - 1)`, where `n` is the number of
ciphertexts (see
[`eval_at_index_key_gen()`](https://openfheorg.github.io/openfhe.R/reference/eval_at_index_key_gen.md)).

## Usage

``` r
eval_merge(ciphertexts)
```

## Arguments

- ciphertexts:

  A non-empty list of `Ciphertext` objects.

## Value

A `Ciphertext`.
