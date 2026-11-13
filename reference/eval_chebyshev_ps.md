# Evaluate a Chebyshev series via the Paterson-Stockmeyer method

Forces the Paterson-Stockmeyer Chebyshev evaluator regardless of degree.
Efficient for high-degree polynomials.

## Usage

``` r
eval_chebyshev_ps(ct, coefficients, a, b)
```

## Arguments

- ct:

  A Ciphertext

- coefficients:

  Integer, double or complex vector of Chebyshev coefficients, as for
  [`eval_chebyshev()`](https://openfheorg.github.io/openfhe.R/reference/eval_chebyshev.md).
  Pass whole-number coefficients as doubles: at OpenFHE 1.6.1 this
  evaluator returns wrong values for integer coefficients.

- a:

  Lower bound of the approximation interval

- b:

  Upper bound of the approximation interval

## Value

A Ciphertext

## See also

[`eval_chebyshev()`](https://openfheorg.github.io/openfhe.R/reference/eval_chebyshev.md),
[`eval_chebyshev_linear()`](https://openfheorg.github.io/openfhe.R/reference/eval_chebyshev_linear.md)
