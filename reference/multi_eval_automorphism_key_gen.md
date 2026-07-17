# Generate a joint automorphism-key share for multi-party rotation

Produces this party's share of the joined automorphism eval key map for
the supplied `index_list`. Each other party calls the same method with
their own secret share, and the shares are combined via
[`multi_add_eval_automorphism_keys()`](https://openfheorg.github.io/openfhe.R/reference/multi_add_eval_automorphism_keys.md)
to produce the final joined map.

## Usage

``` r
multi_eval_automorphism_key_gen(cc, sk, eval_key_map, index_list, key_tag = "")
```

## Arguments

- cc:

  A `CryptoContext` with the `MULTIPARTY` feature enabled.

- sk:

  This party's `PrivateKey` share.

- eval_key_map:

  An existing `EvalKeyMap` carrying the prior-party automorphism key
  state, obtained via
  [`get_eval_automorphism_key_map()`](https://openfheorg.github.io/openfhe.R/reference/get_eval_automorphism_key_map.md)
  after the lead party has populated the cc registry through
  `key_gen(cc, rotations = ...)`.

- index_list:

  Integer vector of rotation indices.

- key_tag:

  Character; optional tag to associate with the produced map. Default
  `""`.

## Value

An `EvalKeyMap` holding this party's joint share.
