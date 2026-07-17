# Map of homomorphic evaluation keys

Opaque S7 wrapper around a
`shared_ptr<std::map<uint32_t, EvalKey<DCRTPoly>>>`. Produced by the
`multi_eval_*_key_gen()` family and by
[`get_eval_sum_key_map()`](https://openfheorg.github.io/openfhe.R/reference/get_eval_sum_key_map.md)
/
[`get_eval_automorphism_key_map()`](https://openfheorg.github.io/openfhe.R/reference/get_eval_automorphism_key_map.md);
consumed by
[`multi_add_eval_sum_keys()`](https://openfheorg.github.io/openfhe.R/reference/multi_add_eval_sum_keys.md),
[`multi_add_eval_automorphism_keys()`](https://openfheorg.github.io/openfhe.R/reference/multi_add_eval_automorphism_keys.md),
[`insert_eval_sum_key()`](https://openfheorg.github.io/openfhe.R/reference/insert_eval_sum_key.md),
and
[`insert_eval_automorphism_key()`](https://openfheorg.github.io/openfhe.R/reference/insert_eval_automorphism_key.md).
The map is keyed by a rotation/automorphism index and carries one
`EvalKey` per index.

## Usage

``` r
EvalKeyMap(ptr = NULL)
```

## Arguments

- ptr:

  External pointer (internal use).

## Details

Users do not construct or index into an `EvalKeyMap` directly — it is a
transport format for the multi-party eval-key protocols. In a
single-user protocol the same data is tracked inside the
`CryptoContext`'s internal key registry (populated by `EvalSumKeyGen()`
/ `EvalRotateKeyGen()`) and is only exposed as an `EvalKeyMap` when the
distributed-party flow needs to exchange it.
