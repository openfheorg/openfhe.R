# Evaluate a trigonometric Hermite series on a ciphertext

The series evaluation inside functional bootstrapping. It approximates
`exp(i * pi / 2 * x)` by the Chebyshev series `coefficients_cheb` on
`[a, b]`, squares it twice to get `exp(2 * pi * i * x)`, evaluates the
polynomial with coefficients `coefficients_herm` in that exponential,
and returns twice the real part:
`2 * Re(sum_j h_j exp(2 * pi * i * j * x))` (CKKS only).

## Usage

``` r
eval_hermite_trig_series(
  ct,
  coefficients_cheb,
  a,
  b,
  coefficients_herm,
  precomp = 0L
)
```

## Arguments

- ct:

  A `Ciphertext`.

- coefficients_cheb:

  Numeric or complex vector; Chebyshev coefficients of
  `exp(i * pi / 2 * x)` on `[a, b]`.

- a, b:

  Numeric; the interval of the Chebyshev approximation.

- coefficients_herm:

  The coefficients of the Hermite series in powers of the exponential,
  divided by 2: an integer vector, or a double or complex vector.

- precomp:

  Integer. `0L` (default) or `1L`: compute the exponential and keep it
  in the first or the second place. `2L`: reuse the first one kept. Any
  other value: reuse the second.

## Value

A `Ciphertext`.

## Details

The exponential is kept in the bootstrapping precomputation of the
context for the slot count of `ct`, in one of two places, so the context
must have been set up for bootstrapping
([`eval_fbt_setup()`](https://openfheorg.github.io/openfhe.R/reference/eval_fbt_setup.md),
[`eval_bootstrap_setup()`](https://openfheorg.github.io/openfhe.R/reference/eval_bootstrap_setup.md)
or
[`eval_fe_func_bootstrap_setup()`](https://openfheorg.github.io/openfhe.R/reference/eval_fe_func_bootstrap_setup.md))
and must hold the conjugation key
([`eval_bootstrap_key_gen()`](https://openfheorg.github.io/openfhe.R/reference/eval_bootstrap_key_gen.md)).
