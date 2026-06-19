# Evaluate a Chebyshev series on a ciphertext

Uses OpenFHE's default algorithm selector, which routes to
[`eval_chebyshev_linear()`](https://bnaras.github.io/openfhe.R/reference/eval_chebyshev_linear.md)
for degree \< 5 and
[`eval_chebyshev_ps()`](https://bnaras.github.io/openfhe.R/reference/eval_chebyshev_ps.md)
(Paterson-Stockmeyer) for higher degrees. Call the variants directly to
force one algorithm or the other.

## Usage

``` r
eval_chebyshev(ct, coefficients, a, b)
```

## Arguments

- ct:

  A Ciphertext

- coefficients:

  Numeric vector of Chebyshev coefficients

- a:

  Lower bound of the approximation interval

- b:

  Upper bound of the approximation interval

## Value

A Ciphertext

## See also

[`eval_chebyshev_coefficients()`](https://bnaras.github.io/openfhe.R/reference/eval_chebyshev_coefficients.md)
and
[`eval_chebyshev_function()`](https://bnaras.github.io/openfhe.R/reference/eval_chebyshev_function.md)
for constructing the coefficient vector from a user-supplied function;
[`eval_chebyshev_linear()`](https://bnaras.github.io/openfhe.R/reference/eval_chebyshev_linear.md)
/
[`eval_chebyshev_ps()`](https://bnaras.github.io/openfhe.R/reference/eval_chebyshev_ps.md)
for forcing the algorithm.
