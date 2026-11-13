# Evaluate several series on one ciphertext

Evaluating a polynomial or a Chebyshev series on a ciphertext spends
most of its time computing the powers (or the Chebyshev polynomials) of
the ciphertext. These functions separate the two steps, so that several
series can be evaluated on the same ciphertext for the cost of one set
of powers (CKKS only).

## Usage

``` r
eval_powers(ct, coefficients)

eval_poly_with_precomp(powers, coefficients)

eval_cheby_polys(ct, coefficients, a, b)

eval_chebyshev_series_with_precomp(polys, coefficients)
```

## Arguments

- ct:

  A `Ciphertext`.

- coefficients:

  Integer, double or complex vector of coefficients, constant term
  first, as for
  [`eval_poly()`](https://openfheorg.github.io/openfhe.R/reference/eval_poly.md)
  and
  [`eval_chebyshev()`](https://openfheorg.github.io/openfhe.R/reference/eval_chebyshev.md).
  Pass whole-number Chebyshev coefficients as doubles; see
  [`eval_chebyshev()`](https://openfheorg.github.io/openfhe.R/reference/eval_chebyshev.md).

- powers:

  A
  [SeriesPowers](https://openfheorg.github.io/openfhe.R/reference/SeriesPowers.md)
  object from `eval_powers()`.

- a, b:

  Numeric; the interval of the Chebyshev approximation.

- polys:

  A
  [SeriesPowers](https://openfheorg.github.io/openfhe.R/reference/SeriesPowers.md)
  object from `eval_cheby_polys()`.

## Value

`eval_powers()` and `eval_cheby_polys()`: a
[SeriesPowers](https://openfheorg.github.io/openfhe.R/reference/SeriesPowers.md)
object. The other two: a `Ciphertext`.

## Details

`eval_powers()` computes the powers that
[`eval_poly()`](https://openfheorg.github.io/openfhe.R/reference/eval_poly.md)
would compute for `coefficients`, and `eval_poly_with_precomp()`
evaluates a polynomial from them. `eval_cheby_polys()` and
`eval_chebyshev_series_with_precomp()` are the same pair for
[`eval_chebyshev()`](https://openfheorg.github.io/openfhe.R/reference/eval_chebyshev.md).

The precomputation depends on `coefficients` only through the degree
(the length of the vector), so it can be reused for any series of that
degree. Below degree 5 only the powers with a nonzero coefficient are
computed, so there the nonzero terms must match as well.

## Examples

``` r
cc <- fhe_context("CKKS", multiplicative_depth = 4L, scaling_mod_size = 50L,
                  batch_size = 8L, features = Feature$ADVANCEDSHE)
keys <- key_gen(cc, eval_mult = TRUE)
ct <- encrypt(keys@public, make_ckks_packed_plaintext(cc, c(0.5, 1, 2)), cc = cc)
p <- c(1, 0, 2, 0, 0, 1)
q <- c(0, 1, 0, 3, 0, -1)
powers <- eval_powers(ct, p)
ct_p <- eval_poly_with_precomp(powers, p)
ct_q <- eval_poly_with_precomp(powers, q)
```
