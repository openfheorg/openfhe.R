# Generate rotation keys for a secret key

Standalone wrapper around the
`CryptoContext::EvalRotateKeyGen(privateKey, indexList)` C++ method.
Populates the `CryptoContext`'s internal automorphism key registry for
the supplied rotation indices so that
[`eval_rotate()`](https://bnaras.github.io/openfhe.R/reference/eval_rotate.md)
can consume them.

## Usage

``` r
eval_rotate_key_gen(cc, sk, index_list)
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

## Details

[`key_gen()`](https://bnaras.github.io/openfhe.R/reference/key_gen.md)
folds this into its `rotations = ...` argument as a convenience for
fresh keypairs. The standalone wrapper is the right entry point when the
secret key already exists — for example as the lead-party rotation-key
generation step in a multi-party rotation protocol, where subsequent
parties contribute via
[`multi_eval_at_index_key_gen()`](https://bnaras.github.io/openfhe.R/reference/multi_eval_at_index_key_gen.md).
