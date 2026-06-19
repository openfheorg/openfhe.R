# Clear the EvalAutomorphism key cache

Companion to
[`clear_eval_mult_keys()`](https://bnaras.github.io/openfhe.R/reference/clear_eval_mult_keys.md)
for the EvalAutomorphism key map (used by rotation and sum operations).
`key_tag = NULL` clears everything (same as
[`clear_fhe_state()`](https://bnaras.github.io/openfhe.R/reference/clear_fhe_state.md)'s
`"automorphism_keys"` branch); a character scalar clears only that tag's
entries.

## Usage

``` r
clear_eval_automorphism_keys(key_tag = NULL)
```

## Arguments

- key_tag:

  `NULL` (default) to clear everything, or a character scalar to clear
  only one tag's entries.

## Value

`NULL`, invisibly.

## See also

[`clear_fhe_state()`](https://bnaras.github.io/openfhe.R/reference/clear_fhe_state.md),
[`clear_eval_mult_keys()`](https://bnaras.github.io/openfhe.R/reference/clear_eval_mult_keys.md)
