# Combine encrypted and unencrypted masked decryptions

Final step of the two-party interactive bootstrap protocol. Adds the
server's masked decryption to the client's re-encryption to produce the
refreshed ciphertext.

## Usage

``` r
int_boot_add(ct1, ct2)
```

## Arguments

- ct1, ct2:

  `Ciphertext` objects — typically the outputs of
  [`int_boot_decrypt()`](https://bnaras.github.io/openfhe.R/reference/int_boot_decrypt.md)
  and
  [`int_boot_encrypt()`](https://bnaras.github.io/openfhe.R/reference/int_boot_encrypt.md).

## Value

A refreshed `Ciphertext`.
