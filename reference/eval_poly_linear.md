# Evaluate a polynomial via the linear evaluator

Forces the "linear" Horner-style polynomial evaluator regardless of
degree. Shallower circuit depth than the Paterson-Stockmeyer variant but
uses more multiplications at high degree. Cheaper for degree \< 5; fall
over to
[`eval_poly_ps()`](https://bnaras.github.io/openfhe.R/reference/eval_poly_ps.md)
above that.

## Usage

``` r
eval_poly_linear(ct, coefficients)
```

## Arguments

- ct:

  A Ciphertext

- coefficients:

  Numeric vector of polynomial coefficients

## Value

A Ciphertext

## See also

[`eval_poly()`](https://bnaras.github.io/openfhe.R/reference/eval_poly.md),
[`eval_poly_ps()`](https://bnaras.github.io/openfhe.R/reference/eval_poly_ps.md)
