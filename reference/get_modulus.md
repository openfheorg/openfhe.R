# The ciphertext modulus

The modulus of an object, as a string of decimal digits, because it
normally exceeds what an R number holds exactly.

## Usage

``` r
get_modulus(x, ...)
```

## Arguments

- x:

  A `CryptoContext` or an `ElementParams` object.

- ...:

  Reserved for future method-specific arguments.

## Value

A character string of decimal digits.

## Details

For a `CryptoContext` or an `ElementParams` object it is the composite
ciphertext modulus `Q`, the product of the RNS moduli. openfhe-python
returns this value for a `CryptoContext` as a floating-point number; R
returns it exactly.

## See also

[`get_modulus_ckks()`](https://openfheorg.github.io/openfhe.R/reference/get_modulus_ckks.md),
[`get_root_of_unity()`](https://openfheorg.github.io/openfhe.R/reference/get_modulus_ckks.md),
[`get_element_modulus()`](https://openfheorg.github.io/openfhe.R/reference/get_element_modulus.md)

## Examples

``` r
cc <- fhe_context("BFV", plaintext_modulus = 65537, multiplicative_depth = 1)
get_modulus(cc)
#> [1] "1329227995784783648948129721038553089"
```
