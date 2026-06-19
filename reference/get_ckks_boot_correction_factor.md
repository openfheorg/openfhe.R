# Get the CKKS bootstrap correction factor

Reads the current correction factor the scheme uses during the bootstrap
`EvalModReduceInternal` step. Companion of
[`set_ckks_boot_correction_factor()`](https://bnaras.github.io/openfhe.R/reference/set_ckks_boot_correction_factor.md).
Changes here affect all subsequent bootstrap operations on this
`CryptoContext` until another call to
[`set_ckks_boot_correction_factor()`](https://bnaras.github.io/openfhe.R/reference/set_ckks_boot_correction_factor.md).

## Usage

``` r
get_ckks_boot_correction_factor(cc)
```

## Arguments

- cc:

  A `CryptoContext`.

## Value

Integer; the current correction factor.

## See also

[`set_ckks_boot_correction_factor()`](https://bnaras.github.io/openfhe.R/reference/set_ckks_boot_correction_factor.md),
[`eval_bootstrap_setup()`](https://bnaras.github.io/openfhe.R/reference/eval_bootstrap_setup.md)
