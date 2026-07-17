# Clear the EvalMult key cache

Clears the `CryptoContextImpl` internal EvalMult key map. With
`key_tag = NULL` (the default), clears the entire cache — equivalent to
the no-arg `ClearEvalMultKeys()` form used by
[`clear_fhe_state()`](https://openfheorg.github.io/openfhe.R/reference/clear_fhe_state.md).
With a non-NULL `key_tag`, clears only the entries registered under that
tag, preserving everything else. Useful in checkpoint workflows where a
single party's keys need to be evicted without wiping the whole
registry.

## Usage

``` r
clear_eval_mult_keys(key_tag = NULL)
```

## Arguments

- key_tag:

  `NULL` (default) to clear everything, or a character scalar to clear
  only one tag's entries.

## Value

`NULL`, invisibly.

## See also

[`clear_fhe_state()`](https://openfheorg.github.io/openfhe.R/reference/clear_fhe_state.md),
[`clear_eval_automorphism_keys()`](https://openfheorg.github.io/openfhe.R/reference/clear_eval_automorphism_keys.md)
