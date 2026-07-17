# Evaluate a polynomial via the Paterson-Stockmeyer method

Forces the Paterson-Stockmeyer polynomial evaluator regardless of
degree. Efficient for high-degree polynomials (fewer multiplications at
the cost of more additions and a deeper circuit); for degree \< 5 prefer
[`eval_poly_linear()`](https://openfheorg.github.io/openfhe.R/reference/eval_poly_linear.md).

## Usage

``` r
eval_poly_ps(ct, coefficients)
```

## Arguments

- ct:

  A Ciphertext

- coefficients:

  Numeric vector of polynomial coefficients

## Value

A Ciphertext

## See also

[`eval_poly()`](https://openfheorg.github.io/openfhe.R/reference/eval_poly.md),
[`eval_poly_linear()`](https://openfheorg.github.io/openfhe.R/reference/eval_poly_linear.md)
