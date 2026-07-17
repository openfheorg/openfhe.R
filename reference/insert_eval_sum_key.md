# Insert a joined sum-key map into the cc registry

After combining multi-party shares via
[`multi_add_eval_sum_keys()`](https://openfheorg.github.io/openfhe.R/reference/multi_add_eval_sum_keys.md),
the joined map has to be inserted back into the cc's internal static
registry before
[`eval_sum()`](https://openfheorg.github.io/openfhe.R/reference/eval_sum.md)
can consume it. `insert_eval_sum_key()` routes the map through
`CryptoContextImpl::InsertEvalSumKey` (which delegates internally to
`InsertEvalAutomorphismKey` — the same static storage is shared between
the two surfaces).

## Usage

``` r
insert_eval_sum_key(eval_key_map, key_tag = "")
```

## Arguments

- eval_key_map:

  An `EvalKeyMap` from
  [`multi_add_eval_sum_keys()`](https://openfheorg.github.io/openfhe.R/reference/multi_add_eval_sum_keys.md)
  or constructed through the distributed key-gen flow.

- key_tag:

  Character; the tag to register the map under. Default `""`.

## Value

`NULL`, invisibly.
