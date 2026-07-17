# Chebyshev coefficients for a real-valued function

Computes the Chebyshev (first-kind) coefficients that approximate a
univariate function `func` on the interval \\\[a, b\]\\ using the
discrete orthogonality formula at `degree + 1` Chebyshev nodes. This is
a direct port of the upstream routine `EvalChebyshevCoefficients()` in
`core/lib/math/chebyshev.cpp` of openfhe-development, and the returned
vector is in exactly the form that
[`eval_chebyshev()`](https://openfheorg.github.io/openfhe.R/reference/eval_chebyshev.md)
(and the upstream `EvalChebyshevSeries`) expect — the zeroth coefficient
is not halved.

## Usage

``` r
eval_chebyshev_coefficients(func, a, b, degree)
```

## Arguments

- func:

  An R function taking a single numeric argument and returning a numeric
  scalar.

- a:

  Lower bound of the approximation interval.

- b:

  Upper bound of the approximation interval.

- degree:

  Chebyshev polynomial degree (must be \>= 1).

## Value

Numeric vector of length `degree + 1`.

## See also

[`eval_chebyshev()`](https://openfheorg.github.io/openfhe.R/reference/eval_chebyshev.md),
[`eval_chebyshev_function()`](https://openfheorg.github.io/openfhe.R/reference/eval_chebyshev_function.md).
