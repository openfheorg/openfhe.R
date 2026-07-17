# Insert a joined automorphism-key map into the cc registry

After combining multi-party automorphism-key shares via
[`multi_add_eval_automorphism_keys()`](https://openfheorg.github.io/openfhe.R/reference/multi_add_eval_automorphism_keys.md),
insert the joined map into the cc-internal registry so that
[`eval_rotate()`](https://openfheorg.github.io/openfhe.R/reference/eval_rotate.md)
/
[`eval_fast_rotation()`](https://openfheorg.github.io/openfhe.R/reference/eval_fast_rotation.md)
can consume it.

## Usage

``` r
insert_eval_automorphism_key(eval_key_map, key_tag = "")
```

## Arguments

- eval_key_map:

  An `EvalKeyMap`.

- key_tag:

  Character; default `""`.

## Value

`NULL`, invisibly.
