# Generate a joint sum-key share for multi-party EvalSum

Generate a joint sum-key share for multi-party EvalSum

## Usage

``` r
multi_eval_sum_key_gen(cc, sk, eval_key_map, key_tag = "")
```

## Arguments

- cc:

  A `CryptoContext`.

- sk:

  This party's `PrivateKey` share.

- eval_key_map:

  An existing `EvalKeyMap` carrying the prior-party sum-key state,
  obtained via
  [`get_eval_sum_key_map()`](https://openfheorg.github.io/openfhe.R/reference/get_eval_sum_key_map.md)
  after the lead party has populated the cc registry through
  [`eval_sum_key_gen()`](https://openfheorg.github.io/openfhe.R/reference/eval_sum_key_gen.md).

- key_tag:

  Character; default `""`.

## Value

An `EvalKeyMap`.
