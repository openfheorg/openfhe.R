# Get real values from a CKKS plaintext

Get real values from a CKKS plaintext

## Usage

``` r
get_real_packed_value(pt)
```

## Arguments

- pt:

  A Plaintext

## Value

Numeric vector

## See also

[`get_complex_packed_value()`](https://openfheorg.github.io/openfhe.R/reference/get_complex_packed_value.md)
for the complex-view accessor on the same underlying plaintext (each
slot internally carries a complex pair — this function returns only the
real parts).
