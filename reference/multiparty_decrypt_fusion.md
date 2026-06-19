# Fuse partial decryptions into final plaintext

Combines partial decryptions from any number of parties (n \>= 2). The
lead party's partial decryption (from
[`multiparty_decrypt_lead()`](https://bnaras.github.io/openfhe.R/reference/multiparty_decrypt_lead.md))
must be supplied first; subsequent partials (from
[`multiparty_decrypt_main()`](https://bnaras.github.io/openfhe.R/reference/multiparty_decrypt_main.md))
follow in any order.

## Usage

``` r
multiparty_decrypt_fusion(cc, ...)
```

## Arguments

- cc:

  A CryptoContext

- ...:

  Two or more partially decrypted Ciphertext objects. The first must be
  from the lead party.

## Value

A Plaintext with the final decrypted result
