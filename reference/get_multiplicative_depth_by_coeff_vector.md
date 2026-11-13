# Multiplicative depth of a polynomial evaluation

The depth the Paterson-Stockmeyer evaluation of a polynomial or
Chebyshev series with the given coefficient vector consumes. It depends
only on the number of coefficients.

## Usage

``` r
get_multiplicative_depth_by_coeff_vector(vec, is_normalized = FALSE)
```

## Arguments

- vec:

  The coefficient vector (numeric or complex).

- is_normalized:

  Logical; `TRUE` if the coefficients are normalized, which saves one
  level. Default `FALSE`.

## Value

An integer.

## See also

[`eval_poly()`](https://openfheorg.github.io/openfhe.R/reference/eval_poly.md),
[`eval_chebyshev()`](https://openfheorg.github.io/openfhe.R/reference/eval_chebyshev.md)
