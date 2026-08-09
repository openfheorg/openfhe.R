# Evaluate division approximation on a ciphertext

Evaluate division approximation on a ciphertext

## Usage

``` r
eval_divide(ct, a, b, degree)
```

## Arguments

- ct:

  A Ciphertext

- a:

  Lower bound of the approximation interval

- b:

  Upper bound of the approximation interval

- degree:

  Chebyshev polynomial degree

## Value

A
[Ciphertext](https://openfheorg.github.io/openfhe.R/reference/Ciphertext.md)
holding the encrypted, slot-wise reciprocal of `ct`, approximated by a
Chebyshev polynomial of the given `degree` on the interval `[a, b]`. The
interval must exclude zero, accuracy degrades outside it, and the result
sits `ceiling(log2(degree)) + 1` levels below `ct`.
