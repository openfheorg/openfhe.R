# Retrieve all registered EvalAutomorphism key maps

Reads the entire `CryptoContextImpl` internal EvalAutomorphism key map —
a named R list keyed by secret-key tag, where each element is an
`EvalKeyMap` (the rotation/automorphism key map for that party). Used
for rotation and EvalAtIndex under the EvalKeyMap wire format.

## Usage

``` r
get_all_eval_automorphism_keys()
```

## Value

A named list keyed by key-tag string. Each element is an `EvalKeyMap`
(opaque wrapper around `shared_ptr<map<uint32_t, EvalKey<DCRTPoly>>>`).

## See also

[`get_eval_automorphism_key_map()`](https://openfheorg.github.io/openfhe.R/reference/get_eval_automorphism_key_map.md)
for per-tag lookup,
[`insert_eval_automorphism_key()`](https://openfheorg.github.io/openfhe.R/reference/insert_eval_automorphism_key.md)
for the write path.
