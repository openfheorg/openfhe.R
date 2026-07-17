# Generate a joint rotation-at-index key share

The `EvalAtIndex` flavor of
[`multi_eval_automorphism_key_gen()`](https://openfheorg.github.io/openfhe.R/reference/multi_eval_automorphism_key_gen.md);
takes signed rotation indices rather than automorphism indices.
Semantically equivalent but lives on a distinct C++ entry point.

## Usage

``` r
multi_eval_at_index_key_gen(cc, sk, eval_key_map, index_list, key_tag = "")
```

## Arguments

- cc:

  A `CryptoContext`.

- sk:

  This party's `PrivateKey` share.

- eval_key_map:

  An existing `EvalKeyMap`.

- index_list:

  Integer vector of signed rotation indices.

- key_tag:

  Character; default `""`.

## Value

An `EvalKeyMap`.
