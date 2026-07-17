# Server-side masked decryption for interactive bootstrap

First step of the single-party interactive bootstrap protocol. The
server applies its secret key share to produce a "masked" partial
decryption that the client can finish off-line. Pairs with
[`int_boot_encrypt()`](https://openfheorg.github.io/openfhe.R/reference/int_boot_encrypt.md)
/
[`int_boot_add()`](https://openfheorg.github.io/openfhe.R/reference/int_boot_add.md)
/
[`int_boot_adjust_scale()`](https://openfheorg.github.io/openfhe.R/reference/int_boot_adjust_scale.md)
to complete the refresh.

## Usage

``` r
int_boot_decrypt(sk, ct)
```

## Arguments

- sk:

  A `PrivateKey` (server's share).

- ct:

  A `Ciphertext` to refresh.

## Value

A `Ciphertext` holding the masked decryption.

## See also

[`int_boot_encrypt()`](https://openfheorg.github.io/openfhe.R/reference/int_boot_encrypt.md),
[`int_boot_add()`](https://openfheorg.github.io/openfhe.R/reference/int_boot_add.md),
[`int_boot_adjust_scale()`](https://openfheorg.github.io/openfhe.R/reference/int_boot_adjust_scale.md)
