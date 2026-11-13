# Inner product of two encrypted vectors

Multiplies the two operands slot by slot and sums the first `batch_size`
slots; the result is in the first slot. Needs the relinearization key
and the summation keys
([`eval_sum_key_gen()`](https://openfheorg.github.io/openfhe.R/reference/eval_sum_key_gen.md)).

## Usage

``` r
eval_inner_product(ct1, ct2, batch_size)
```

## Arguments

- ct1:

  A `Ciphertext`.

- ct2:

  A `Ciphertext` or a `Plaintext`.

- batch_size:

  Integer; the number of slots to sum.

## Value

A `Ciphertext`.
