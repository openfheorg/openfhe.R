# Aggregate multi-party shares pairs

Combines the shares-pair lists produced by each party's call to
[`int_mp_boot_decrypt()`](https://bnaras.github.io/openfhe.R/reference/int_mp_boot_decrypt.md)
into a single aggregated shares pair for use in
[`int_mp_boot_encrypt()`](https://bnaras.github.io/openfhe.R/reference/int_mp_boot_encrypt.md).
The input is a list of per-party shares-pair lists (a list of lists of
`Ciphertext`).

## Usage

``` r
int_mp_boot_add(cc, shares_pair_list)
```

## Arguments

- cc:

  A `CryptoContext`.

- shares_pair_list:

  A list where each element is a list of `Ciphertext` objects from one
  party's
  [`int_mp_boot_decrypt()`](https://bnaras.github.io/openfhe.R/reference/int_mp_boot_decrypt.md)
  call.

## Value

A list of `Ciphertext` objects — the aggregated shares pair.
