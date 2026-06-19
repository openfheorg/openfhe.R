# Retrieve the EvalMult key vector for a given key tag

Reads the vector of EvalMult keys registered under `key_tag`. Errors
(via `catch_openfhe`) if the tag is not present in the registry.

## Usage

``` r
get_eval_mult_key_vector(key_tag)
```

## Arguments

- key_tag:

  Character; the tag to look up (typically `get_key_tag(sk)` of a
  generated `PrivateKey`).

## Value

A list of `EvalKey` objects.

## See also

[`get_all_eval_mult_keys()`](https://bnaras.github.io/openfhe.R/reference/get_all_eval_mult_keys.md),
[`insert_eval_mult_key()`](https://bnaras.github.io/openfhe.R/reference/insert_eval_mult_key.md)
