# Prepare a ciphertext for interactive bootstrap

Adjusts a ciphertext's scale to meet the scheme's requirements before
entering the interactive bootstrap protocol. Typically called before
[`int_boot_decrypt()`](https://openfheorg.github.io/openfhe.R/reference/int_boot_decrypt.md).

## Usage

``` r
int_boot_adjust_scale(ct)
```

## Arguments

- ct:

  A `Ciphertext`.

## Value

A `Ciphertext` ready for
[`int_boot_decrypt()`](https://openfheorg.github.io/openfhe.R/reference/int_boot_decrypt.md).
