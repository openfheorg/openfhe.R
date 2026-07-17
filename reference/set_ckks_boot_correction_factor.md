# Set the CKKS bootstrap correction factor

Sets the scheme-level correction factor used by subsequent bootstraps.
Normally this is set via the `correction_factor` argument to
[`eval_bootstrap_setup()`](https://openfheorg.github.io/openfhe.R/reference/eval_bootstrap_setup.md)
at bootstrap setup time; this pair exists for post-setup programmatic
control.

## Usage

``` r
set_ckks_boot_correction_factor(cc, cf)
```

## Arguments

- cc:

  A `CryptoContext`.

- cf:

  Integer; the new correction factor.

## Value

The `cc`, invisibly.

## See also

[`get_ckks_boot_correction_factor()`](https://openfheorg.github.io/openfhe.R/reference/get_ckks_boot_correction_factor.md)
