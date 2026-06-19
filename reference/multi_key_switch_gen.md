# Multi-party key-switch eval-key generation

Generates an eval key that switches ciphertexts encrypted under
`sk_orig` into a form decryptable by `sk_new`, starting from an existing
eval key that carries the key-switch auxiliary information. Used by
threshold protocols to route partial decryptions across a re-keyed party
set.

## Usage

``` r
multi_key_switch_gen(cc, sk_orig, sk_new, eval_key)
```

## Arguments

- cc:

  A CryptoContext

- sk_orig:

  The original party's PrivateKey

- sk_new:

  The new party's PrivateKey

- eval_key:

  An EvalKey carrying key-switch auxiliary data

## Value

An EvalKey suitable for routing through
[`multi_add_eval_keys()`](https://bnaras.github.io/openfhe.R/reference/multi_add_eval_keys.md)
to combine with other parties' key-switch shares
