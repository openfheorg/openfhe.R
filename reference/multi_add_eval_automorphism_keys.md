# Combine two automorphism-key map shares

Combine two automorphism-key map shares

## Usage

``` r
multi_add_eval_automorphism_keys(
  cc,
  eval_key_map1,
  eval_key_map2,
  key_tag = ""
)
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
[`insert_eval_automorphism_key()`](https://bnaras.github.io/openfhe.R/reference/insert_eval_automorphism_key.md).
