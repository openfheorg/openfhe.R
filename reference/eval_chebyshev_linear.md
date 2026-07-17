# Evaluate a Chebyshev series via the linear evaluator

Forces the "linear" Chebyshev evaluator regardless of degree. Shallower
circuit depth than Paterson-Stockmeyer but uses more multiplications at
high degree.

## Usage

``` r
eval_chebyshev_linear(ct, coefficients, a, b)
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

[`eval_chebyshev()`](https://openfheorg.github.io/openfhe.R/reference/eval_chebyshev.md),
[`eval_chebyshev_ps()`](https://openfheorg.github.io/openfhe.R/reference/eval_chebyshev_ps.md)
