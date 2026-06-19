# Generate at-index (rotation) keys for a secret key

Standalone wrapper around the
`CryptoContext::EvalAtIndexKeyGen(privateKey, indexList)` C++ method.
Functionally identical to
[`eval_rotate_key_gen()`](https://bnaras.github.io/openfhe.R/reference/eval_rotate_key_gen.md)
(the C++ `EvalRotateKeyGen` is a thin inline wrapper around
`EvalAtIndexKeyGen`) and provided for surface parity with the C++ header
and openfhe-python, both of which bind the two names separately.

## Usage

``` r
eval_at_index_key_gen(cc, sk, index_list)
```

## Arguments

- cc:

  A `CryptoContext`.

- sk:

  A `PrivateKey` whose tag will be used to key the generated rotation
  keys in the cc's internal registry.

- index_list:

  Integer vector of rotation indices.

## Value

`NULL`, invisibly.
