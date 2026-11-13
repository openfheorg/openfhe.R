# Trigonometric Hermite interpolation of a look-up table

Computes the coefficients of the trigonometric Hermite interpolation of
a function on the integers modulo `p`. They are the `coeffs` argument of
[`eval_fbt()`](https://openfheorg.github.io/openfhe.R/reference/eval_fbt_setup.md)
and its relatives in the general case.

## Usage

``` r
get_hermite_trig_coefficients(func, p, order, scale)
```

## Arguments

- func:

  A function of one whole number in `0, ..., p - 1` returning one whole
  number: the look-up table.

- p:

  Integer; the input plaintext modulus.

- order:

  Integer; the order of the interpolation (1, 2 or 3).

- scale:

  Numeric; the coefficients are divided by it. A scale that brings their
  magnitude near one is recommended; it is undone by the `post_scaling`
  argument of
  [`eval_fbt()`](https://openfheorg.github.io/openfhe.R/reference/eval_fbt_setup.md).

## Value

A complex vector.

## Examples

``` r
get_hermite_trig_coefficients(function(x) x %% 4, p = 8L, order = 1L,
                              scale = 1)
#> [1]  7.500000e-01+0.000000e+00i -8.500145e-17+1.214306e-16i
#> [3] -3.750000e-01+3.750000e-01i  6.071532e-17+1.561251e-16i
#> [5] -2.500000e-01-1.530808e-16i -1.665335e-16-5.724587e-17i
#> [7] -1.250000e-01-1.250000e-01i
```
