# Threshold decryption convenience: lead + main + fusion in one call

Performs a full n-of-n threshold decryption of `ct` given the ordered
list of party secret keys. The first key in `sks` is used for
[`multiparty_decrypt_lead()`](https://openfheorg.github.io/openfhe.R/reference/multiparty_decrypt_lead.md);
the remaining keys for
[`multiparty_decrypt_main()`](https://openfheorg.github.io/openfhe.R/reference/multiparty_decrypt_main.md);
the resulting partials are then fused with
[`multiparty_decrypt_fusion()`](https://openfheorg.github.io/openfhe.R/reference/multiparty_decrypt_fusion.md).

## Usage

``` r
threshold_decrypt(cc, sks, ct)
```

## Arguments

- cc:

  A CryptoContext

- sks:

  A list of PrivateKey objects, lead first

- ct:

  The Ciphertext to decrypt

## Value

A Plaintext

## Details

Use this when you have all secret keys in one place (testing,
simulation, single-process demos). In a real distributed deployment each
site holds only its own secret key and the partials travel over the
network — that flow uses the lead / main / fusion functions directly.
