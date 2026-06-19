# Non-lead party's partial decryption

Other parties call this after the lead. Accepts either a single
`Ciphertext` or a list of `Ciphertext` objects with the same semantics
as
[`multiparty_decrypt_lead()`](https://bnaras.github.io/openfhe.R/reference/multiparty_decrypt_lead.md).

## Usage

``` r
multiparty_decrypt_main(cc, sk, ct)
```

## Arguments

- cc:

  A CryptoContext

- sk:

  This party's PrivateKey

- ct:

  A Ciphertext or a list of Ciphertexts

## Value

A partially decrypted Ciphertext or list of Ciphertexts, mirroring the
input shape.
