# Evaluate a polynomial on a ciphertext

Evaluates p(x) = c0 + c1*x + c2*x^2 + ... on encrypted x. Uses OpenFHE's
default algorithm selector, which routes to
[`eval_poly_linear()`](https://openfheorg.github.io/openfhe.R/reference/eval_poly_linear.md)
for degree \< 5 and
[`eval_poly_ps()`](https://openfheorg.github.io/openfhe.R/reference/eval_poly_ps.md)
(Paterson-Stockmeyer) for higher degrees. Call the variants directly to
force one algorithm or the other — Linear is shallower for low-degree
polynomials; PS has fewer multiplications for high-degree polynomials.

## Usage

``` r
eval_poly(ct, coefficients)
```

## Arguments

- ct:

  A Ciphertext

- coefficients:

  Numeric vector of polynomial coefficients

## Value

A Ciphertext

## See also

[`eval_poly_linear()`](https://openfheorg.github.io/openfhe.R/reference/eval_poly_linear.md),
[`eval_poly_ps()`](https://openfheorg.github.io/openfhe.R/reference/eval_poly_ps.md)
