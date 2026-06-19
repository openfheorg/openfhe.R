# Retrieve all registered EvalMult key vectors

Reads the entire `CryptoContextImpl` internal EvalMult key map — a named
R list keyed by secret-key tag, where each element is itself a list of
`EvalKey` objects (the vector of multiplication-eval keys registered
under that tag).

## Usage

``` r
get_all_eval_mult_keys()
```

## Value

A named list keyed by key-tag string. Each element is a list of
`EvalKey` objects.

## Details

The returned list is a **snapshot**: each `EvalKey` wraps a fresh
`shared_ptr` copy, so retained references survive subsequent
[`clear_eval_mult_keys()`](https://bnaras.github.io/openfhe.R/reference/clear_eval_mult_keys.md)
calls. The underlying keys are still shared with the cc registry —
modifications through other paths remain visible.

Primary consumer: checkpoint/resume workflows that need to audit which
parties have keys registered before serializing the cc.

## See also

[`get_eval_mult_key_vector()`](https://bnaras.github.io/openfhe.R/reference/get_eval_mult_key_vector.md)
for per-tag lookup,
[`insert_eval_mult_key()`](https://bnaras.github.io/openfhe.R/reference/insert_eval_mult_key.md)
for the write path.
