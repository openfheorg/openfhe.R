# Create a fully homomorphic encryption context

High-level constructor that creates a `CryptoContext` with sensible
defaults. `PKE`, `KEYSWITCH`, and `LEVELEDSHE` features are enabled
automatically.

## Usage

``` r
fhe_context(scheme = c("BFV", "BGV", "CKKS"), ..., features = NULL)
```

## Arguments

- scheme:

  Character: "BFV", "BGV", or "CKKS".

- ...:

  Scheme-specific `CCParams` setter arguments. Forwarded to
  [`BFVParams()`](https://openfheorg.github.io/openfhe.R/reference/BFVParams.md),
  [`BGVParams()`](https://openfheorg.github.io/openfhe.R/reference/BGVParams.md),
  or
  [`CKKSParams()`](https://openfheorg.github.io/openfhe.R/reference/CKKSParams.md).
  Example:
  `fhe_context("BFV", plaintext_modulus = 65537, multiplicative_depth = 2)`
  or
  `fhe_context("CKKS", multiplicative_depth = 4, scaling_mod_size = 50, scaling_technique = ScalingTechnique$FLEXIBLEAUTO)`.

- features:

  Additional `Feature` values to enable on the context beyond the
  default `PKE|KEYSWITCH|LEVELEDSHE` triple.

## Value

A `CryptoContext` object.

## Details

All scheme-specific `CCParams` setter arguments are accepted via `...`
and forwarded to the appropriate per-scheme constructor
([`BFVParams()`](https://openfheorg.github.io/openfhe.R/reference/BFVParams.md),
[`BGVParams()`](https://openfheorg.github.io/openfhe.R/reference/BGVParams.md),
or
[`CKKSParams()`](https://openfheorg.github.io/openfhe.R/reference/CKKSParams.md)).
See those functions' argument lists for the valid per-scheme setter
surface — each scheme accepts only the setters that are *not* disabled
in its upstream `CCParams<T>` specialization. Passing an invalid
scheme-specific argument produces an R-level "unused argument" error at
the underlying `*Params()` call site.

## See also

[`BFVParams()`](https://openfheorg.github.io/openfhe.R/reference/BFVParams.md),
[`BGVParams()`](https://openfheorg.github.io/openfhe.R/reference/BGVParams.md),
[`CKKSParams()`](https://openfheorg.github.io/openfhe.R/reference/CKKSParams.md)
