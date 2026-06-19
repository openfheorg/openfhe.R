# Retrieve all registered EvalSum key maps

Reads the entire `CryptoContextImpl` internal EvalSum key map.
Structurally identical to
[`get_all_eval_automorphism_keys()`](https://bnaras.github.io/openfhe.R/reference/get_all_eval_automorphism_keys.md):
both share backing storage on the C++ side, but the two accessors are
exposed separately so that fixture authors can match whichever OpenFHE
doc they are reading.

## Usage

``` r
get_all_eval_sum_keys()
```

## Value

A named list keyed by key-tag string. Each element is an `EvalKeyMap`.

## See also

[`get_eval_sum_key_map()`](https://bnaras.github.io/openfhe.R/reference/get_eval_sum_key_map.md),
[`insert_eval_sum_key()`](https://bnaras.github.io/openfhe.R/reference/insert_eval_sum_key.md)
