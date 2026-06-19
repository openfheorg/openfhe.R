# Relinearize a higher-degree ciphertext

Reduces a ciphertext to 2 polynomial components. Needed after a sequence
of
[`eval_mult_no_relin()`](https://bnaras.github.io/openfhe.R/reference/eval_mult_no_relin.md)
calls to restore a decryptable form. A relinearization key must have
been generated via `key_gen(cc, eval_mult = TRUE)` before calling this.

## Usage

``` r
relinearize(x, ...)
```

## Arguments

- x:

  A `Ciphertext` (may have more than 2 components).

- ...:

  Reserved for future method-specific arguments.

## Value

A `Ciphertext` with exactly 2 components.
