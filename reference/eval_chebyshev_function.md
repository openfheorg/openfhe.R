# Evaluate a user-supplied function on a CKKS ciphertext via Chebyshev approximation

Computes the Chebyshev coefficients for `func` on `[a, b]` via
[`eval_chebyshev_coefficients()`](https://bnaras.github.io/openfhe.R/reference/eval_chebyshev_coefficients.md)
and applies the resulting series to `ct` via
[`eval_chebyshev()`](https://bnaras.github.io/openfhe.R/reference/eval_chebyshev.md).
This mirrors the upstream `CryptoContext::EvalChebyshevFunction` helper,
which is a thin wrapper around `EvalChebyshevCoefficients` followed by
`EvalChebyshevSeries` on the C++ side.

## Usage

``` r
eval_chebyshev_function(ct, func, a, b, degree)
```

## Arguments

- ct:

  A Ciphertext holding CKKS-encoded real values in `[a, b]`.

- func:

  An R function taking a single numeric argument and returning a numeric
  scalar. It is evaluated on cleartext Chebyshev nodes inside `[a, b]`
  to produce the approximating coefficients.

- a:

  Lower bound of the approximation interval.

- b:

  Upper bound of the approximation interval.

- degree:

  Chebyshev polynomial degree (must be \>= 1).

## Value

A Ciphertext holding the elementwise approximation of `func` applied to
the plaintext slots of `ct`.

## See also

[`eval_chebyshev()`](https://bnaras.github.io/openfhe.R/reference/eval_chebyshev.md),
[`eval_chebyshev_coefficients()`](https://bnaras.github.io/openfhe.R/reference/eval_chebyshev_coefficients.md),
[`eval_logistic()`](https://bnaras.github.io/openfhe.R/reference/eval_logistic.md),
[`eval_sin()`](https://bnaras.github.io/openfhe.R/reference/eval_sin.md),
[`eval_cos()`](https://bnaras.github.io/openfhe.R/reference/eval_cos.md),
[`eval_divide()`](https://bnaras.github.io/openfhe.R/reference/eval_divide.md).
