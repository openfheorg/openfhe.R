# Final re-encryption for multi-party interactive bootstrap

Lead party's final step in the multi-party interactive bootstrap. Takes
the aggregated shares pair from
[`int_mp_boot_add()`](https://bnaras.github.io/openfhe.R/reference/int_mp_boot_add.md)
plus the common random element and the original ciphertext, produces the
refreshed ciphertext at a fresh modulus level.

## Usage

``` r
int_mp_boot_encrypt(pk, shares_pair, a, ct)
```

## Arguments

- pk:

  The lead party's `PublicKey`.

- shares_pair:

  A list of `Ciphertext` objects — the aggregated shares pair from
  [`int_mp_boot_add()`](https://bnaras.github.io/openfhe.R/reference/int_mp_boot_add.md).

- a:

  The common random element `Ciphertext` used in the per-party
  [`int_mp_boot_decrypt()`](https://bnaras.github.io/openfhe.R/reference/int_mp_boot_decrypt.md)
  calls.

- ct:

  The original `Ciphertext` being refreshed.

## Value

A refreshed `Ciphertext`.
