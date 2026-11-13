# Sum the rows or the columns of an encrypted matrix

A matrix is packed into the slots row by row. `eval_sum_rows()` adds its
rows together and `eval_sum_cols()` its columns. Each takes the keys
made by the matching key generator, which returns them as an
`EvalKeyMap`.

## Usage

``` r
eval_sum_rows(ct, num_rows, eval_sum_key_map, subring_dim = 0L)

eval_sum_cols(ct, num_cols, eval_sum_key_map)

eval_sum_rows_key_gen(
  cc,
  sk,
  public_key = NULL,
  row_size = 0L,
  subring_dim = 0L
)

eval_sum_cols_key_gen(cc, sk)
```

## Arguments

- ct:

  A `Ciphertext` holding the matrix.

- num_rows, num_cols:

  Integer; the number of rows, or columns, of the matrix.

- eval_sum_key_map:

  An `EvalKeyMap` from `eval_sum_rows_key_gen()` or
  `eval_sum_cols_key_gen()`.

- subring_dim:

  Integer; the subring dimension, `0L` (default) for the full ring.

- cc:

  A `CryptoContext`.

- sk:

  A `PrivateKey`.

- public_key:

  A `PublicKey`, or `NULL` (default) for the form that takes no public
  key.

- row_size:

  Integer; the length of a row, `0L` (default) for the value the library
  derives.

## Value

`eval_sum_rows()` and `eval_sum_cols()` return a `Ciphertext`; the key
generators return an `EvalKeyMap`.
