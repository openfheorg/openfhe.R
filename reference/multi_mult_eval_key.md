# A party's share of the joint multiplication key (threshold FHE)

In the threshold protocol each party multiplies the combined
key-switching key by its own secret share; the results are then added
with
[`multi_add_eval_mult_keys()`](https://openfheorg.github.io/openfhe.R/reference/multi_add_eval_mult_keys.md)
to give the joint relinearization key.

## Usage

``` r
multi_mult_eval_key(cc, sk, eval_key, key_tag = "")
```

## Arguments

- cc:

  A `CryptoContext`.

- sk:

  The party's `PrivateKey` (its secret share).

- eval_key:

  The combined `EvalKey` from
  [`multi_add_eval_keys()`](https://openfheorg.github.io/openfhe.R/reference/multi_add_eval_keys.md).

- key_tag:

  Character string; the tag for the result, `""` (default) to keep the
  library's choice.

## Value

An `EvalKey`.
