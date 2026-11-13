# Precomputed powers of a ciphertext

The powers, or the Chebyshev polynomials, of one ciphertext, as
[`eval_powers()`](https://openfheorg.github.io/openfhe.R/reference/eval_powers.md)
and
[`eval_cheby_polys()`](https://openfheorg.github.io/openfhe.R/reference/eval_powers.md)
compute them. The class is an opaque handle, as in openfhe-python: it is
passed to
[`eval_poly_with_precomp()`](https://openfheorg.github.io/openfhe.R/reference/eval_powers.md)
or
[`eval_chebyshev_series_with_precomp()`](https://openfheorg.github.io/openfhe.R/reference/eval_powers.md),
which leave it unchanged.

## Usage

``` r
SeriesPowers(ptr = NULL)
```

## Arguments

- ptr:

  External pointer (internal use)

## Value

An S7 object of class `SeriesPowers`, inheriting from
[OpenFHEObject](https://openfheorg.github.io/openfhe.R/reference/OpenFHEObject.md).
