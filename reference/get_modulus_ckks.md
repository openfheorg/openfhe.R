# Moduli and root of unity of a CryptoContext

`get_modulus_ckks()` returns the first RNS modulus `q_0` of a CKKS
context. `get_root_of_unity()` returns the root of unity recorded in the
context's element parameters, which is `"0"` for the composite
(double-CRT) parameters the RNS schemes use. Both are strings of decimal
digits.

## Usage

``` r
get_modulus_ckks(cc)

get_root_of_unity(cc)
```

## Arguments

- cc:

  A `CryptoContext`.

## Value

A character string of decimal digits.

## See also

[`get_modulus()`](https://openfheorg.github.io/openfhe.R/reference/get_modulus.md)
