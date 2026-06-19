# Homomorphic multiplication without relinearization

Returns the raw product of two ciphertexts as a higher-degree ciphertext
(the result has `n1 + n2 - 1` polynomial components where the inputs had
`n1` and `n2`). The standard
[`eval_mult()`](https://bnaras.github.io/openfhe.R/reference/eval_mult.md)
automatically relinearizes the result back to 2 components; this variant
skips the relinearization step so that multiple multiplications can be
chained at higher polynomial degree before a single
[`relinearize()`](https://bnaras.github.io/openfhe.R/reference/relinearize.md)
call at the end. Used by the `EvalMultAndRelinearize` fused variant and
by `EvalPolyWithPrecomp` for noise-optimal polynomial evaluation.

## Usage

``` r
eval_mult_no_relin(x, ...)
```

## Arguments

- x:

  A `Ciphertext`.

- ...:

  Method-specific arguments: `y` — a `Ciphertext` to multiply `x` by
  without relinearization.

## Value

A `Ciphertext` at higher polynomial degree.
