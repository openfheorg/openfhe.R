# Combine two sum-key map shares into a joint sum-key map

Combine two sum-key map shares into a joint sum-key map

## Usage

``` r
multi_add_eval_sum_keys(cc, eval_key_map1, eval_key_map2, key_tag = "")
```

## Arguments

- cc:

  A `CryptoContext`.

- eval_key_map1, eval_key_map2:

  `EvalKeyMap` shares from two parties.

- key_tag:

  Character; default `""`.

## Value

A combined `EvalKeyMap` suitable for insertion into the cc registry via
[`insert_eval_sum_key()`](https://openfheorg.github.io/openfhe.R/reference/insert_eval_sum_key.md).
