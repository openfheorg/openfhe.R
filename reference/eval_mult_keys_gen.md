# Generate relinearization keys for higher powers of the secret key

Generates the keys that relinearize a ciphertext of more than three
elements, as
[`eval_mult_no_relin()`](https://openfheorg.github.io/openfhe.R/reference/eval_mult_no_relin.md)
produces when it is applied repeatedly: one key for each power of the
secret key up to the `max_relin_sk_deg` of the context.
[`eval_mult_key_gen()`](https://openfheorg.github.io/openfhe.R/reference/eval_mult_key_gen.md)
generates the key for the second power only.

## Usage

``` r
eval_mult_keys_gen(cc, sk)
```

## Arguments

- cc:

  A `CryptoContext`.

- sk:

  A `PrivateKey`.

## Value

`NULL`, invisibly.
