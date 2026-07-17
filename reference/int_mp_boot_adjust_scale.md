# Prepare a ciphertext for multi-party interactive bootstrap

Multi-party analogue of
[`int_boot_adjust_scale()`](https://openfheorg.github.io/openfhe.R/reference/int_boot_adjust_scale.md).
Adjusts the ciphertext's scale before entering the distributed bootstrap
protocol.

## Usage

``` r
int_mp_boot_adjust_scale(ct)
```

## Arguments

- ct:

  A `Ciphertext`.

## Value

A `Ciphertext` ready for the multi-party bootstrap protocol.
