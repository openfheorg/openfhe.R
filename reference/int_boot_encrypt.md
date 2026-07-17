# Client-side re-encryption for interactive bootstrap

Encrypts the client's masked decryption result under the public key,
raising the ciphertext modulus back to a fresh level.

## Usage

``` r
int_boot_encrypt(pk, ct)
```

## Arguments

- pk:

  A `PublicKey`.

- ct:

  A `Ciphertext` from the client (typically the masked-decryption output
  processed off-line).

## Value

A refreshed `Ciphertext`.

## See also

[`int_boot_decrypt()`](https://openfheorg.github.io/openfhe.R/reference/int_boot_decrypt.md)
