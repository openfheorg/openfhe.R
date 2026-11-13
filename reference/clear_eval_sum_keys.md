# Remove summation keys from the registry

Removes the keys that
[`eval_sum_key_gen()`](https://openfheorg.github.io/openfhe.R/reference/eval_sum_key_gen.md)
registered: all of them, or those under one key tag.

## Usage

``` r
clear_eval_sum_keys(key_tag = NULL)
```

## Arguments

- key_tag:

  Character string, or `NULL` (default) for all keys.

## Value

`NULL`, invisibly.

## See also

[`clear_eval_mult_keys()`](https://openfheorg.github.io/openfhe.R/reference/clear_eval_mult_keys.md),
[`clear_eval_automorphism_keys()`](https://openfheorg.github.io/openfhe.R/reference/clear_eval_automorphism_keys.md)
