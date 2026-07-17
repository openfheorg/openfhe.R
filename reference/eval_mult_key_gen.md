# Generate relinearization (eval-mult) keys for a secret key

Standalone wrapper around the
`CryptoContext::EvalMultKeyGen(privateKey)` C++ method. Populates the
`CryptoContext`'s internal eval-mult registry (keyed by the secret key's
tag) so that ciphertext × ciphertext multiplication can be relinearized.

## Usage

``` r
eval_mult_key_gen(cc, sk)
```

## Arguments

- cc:

  A `CryptoContext`.

- sk:

  A `PrivateKey` whose tag will be used to key the generated eval-mult
  key in the cc's internal registry.

## Value

`NULL`, invisibly.

## Details

[`key_gen()`](https://openfheorg.github.io/openfhe.R/reference/key_gen.md)
folds this into its `eval_mult = TRUE` branch as a convenience for fresh
keypairs. The standalone wrapper is the right entry point when the
secret key already exists — for example in any threshold or multi-party
flow that holds a secret-key share but did not generate it through
[`key_gen()`](https://openfheorg.github.io/openfhe.R/reference/key_gen.md).
