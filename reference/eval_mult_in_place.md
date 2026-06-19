# Homomorphic multiplication in place

Modifies the first argument in place to hold the result of multiplying
by a numeric scalar. `CryptoContextImpl` only declares `EvalMultInPlace`
scalar overloads in the v1.5.1.0 header surface — the ct/ct and ct/pt
variants that upstream-defects P1 refers to live on `SchemeBase` and are
not exposed on `CryptoContextImpl`, so R's `eval_mult_in_place` supports
only the scalar case. The ct/ct multiplication continues to work via the
non-in-place
[`eval_mult()`](https://bnaras.github.io/openfhe.R/reference/eval_mult.md)
generic.

## Usage

``` r
eval_mult_in_place(x, ...)
```

## Arguments

- x:

  A `Ciphertext` (modified in place).

- ...:

  Method-specific arguments: `y` — a numeric scalar to multiply `x` by.

## Value

`x` invisibly.
