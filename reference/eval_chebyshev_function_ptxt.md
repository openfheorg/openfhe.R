# Chebyshev approximation of a function, in the clear

The cleartext counterpart of
[`eval_chebyshev_function()`](https://openfheorg.github.io/openfhe.R/reference/eval_chebyshev_function.md):
it evaluates the degree-`degree` Chebyshev approximation of `func` on
`[a, b]` at the points `ptxt`, with the arithmetic OpenFHE uses on
ciphertexts. Comparing its result with `func(ptxt)` gives the
approximation error of a degree before any encrypted computation is run.

## Usage

``` r
eval_chebyshev_function_ptxt(func, ptxt, a, b, degree)
```

## Arguments

- func:

  A function of one number returning one number.

- ptxt:

  Numeric vector of points in `[a, b]`.

- a, b:

  Numeric; the interval.

- degree:

  Integer; the degree of the approximation, at least 1.

## Value

A numeric vector the length of `ptxt`.

## Examples

``` r
x <- seq(-1, 1, by = 0.5)
eval_chebyshev_function_ptxt(exp, x, -1, 1, 8L) - exp(x)
#> [1]  9.983549e-09 -1.046324e-08 -6.661338e-16  1.156027e-08 -1.219007e-08
```
