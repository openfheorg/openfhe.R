# Multi-party masked decryption for interactive bootstrap

Each party calls this with their own secret share, the ciphertext being
refreshed, and the common random element from
[`int_mp_boot_random_element_gen()`](https://openfheorg.github.io/openfhe.R/reference/int_mp_boot_random_element_gen.md).
Returns a list of two `Ciphertext` objects — the party's
masked-decryption "shares pair". Each party's shares pair gets collected
and fed into
[`int_mp_boot_add()`](https://openfheorg.github.io/openfhe.R/reference/int_mp_boot_add.md).

## Usage

``` r
int_mp_boot_decrypt(sk, ct, a)
```

## Arguments

- sk:

  A `PrivateKey` (this party's share).

- ct:

  A `Ciphertext` to refresh.

- a:

  A `Ciphertext` holding the common random element from
  [`int_mp_boot_random_element_gen()`](https://openfheorg.github.io/openfhe.R/reference/int_mp_boot_random_element_gen.md).

## Value

A list of two `Ciphertext` objects (the party's shares pair).
