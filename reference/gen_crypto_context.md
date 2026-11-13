# Generate a CryptoContext from a parameter object

The counterpart of OpenFHE's `GenCryptoContext(parameters)`. It returns
the context with no feature enabled; call
[`enable_feature()`](https://openfheorg.github.io/openfhe.R/reference/enable_feature.md)
for each feature the computation needs, as the OpenFHE examples do.
[`fhe_context()`](https://openfheorg.github.io/openfhe.R/reference/fhe_context.md)
does both steps in one call and enables the three features most
computations use.

## Usage

``` r
gen_crypto_context(params)
```

## Arguments

- params:

  A `BFVParams`, `BGVParams`, or `CKKSParams` object.

## Value

A `CryptoContext` with no feature enabled.

## See also

[`fhe_context()`](https://openfheorg.github.io/openfhe.R/reference/fhe_context.md),
[`enable_feature()`](https://openfheorg.github.io/openfhe.R/reference/enable_feature.md),
[ccparams_setters](https://openfheorg.github.io/openfhe.R/reference/ccparams_setters.md)

## Examples

``` r
p <- BFVParams()
set_plaintext_modulus(p, 65537)
set_multiplicative_depth(p, 2L)
cc <- gen_crypto_context(p)
enable_feature(cc, Feature$PKE)
enable_feature(cc, Feature$KEYSWITCH)
enable_feature(cc, Feature$LEVELEDSHE)
ring_dimension(cc)
#> [1] 8192
```
