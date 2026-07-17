# Insert an EvalMult key vector into the cc registry

Adds a vector of `EvalKey` objects to the CryptoContext's internal
EvalMult-key map under `key_tag`. Silently replaces any existing
matching keys. If `key_tag` is the empty string (`""`, the default), the
tag is retrieved from the eval-key vector itself (each `EvalKey` carries
its own tag).

## Usage

``` r
insert_eval_mult_key(eval_keys, key_tag = "")
```

## Arguments

- eval_keys:

  A list of `EvalKey` objects (from
  [`multi_key_switch_gen()`](https://openfheorg.github.io/openfhe.R/reference/multi_key_switch_gen.md),
  [`multi_add_eval_mult_keys()`](https://openfheorg.github.io/openfhe.R/reference/multi_add_eval_mult_keys.md),
  or from a deserialization).

- key_tag:

  Character; the tag to register the vector under. Default `""`
  (auto-detect from the first eval key in the vector).

## Value

`NULL`, invisibly.

## Details

Used in checkpoint/resume workflows: after `fhe_deserialize_eval_keys()`
or
[`multi_add_eval_mult_keys()`](https://openfheorg.github.io/openfhe.R/reference/multi_add_eval_mult_keys.md)
produces a combined eval-mult key vector, this function registers it
into the cc's internal storage so that subsequent
[`eval_mult()`](https://openfheorg.github.io/openfhe.R/reference/eval_mult.md)
calls on ciphertexts encrypted under the associated party's key can
consume it.

## See also

[`insert_eval_sum_key()`](https://openfheorg.github.io/openfhe.R/reference/insert_eval_sum_key.md),
[`insert_eval_automorphism_key()`](https://openfheorg.github.io/openfhe.R/reference/insert_eval_automorphism_key.md)
