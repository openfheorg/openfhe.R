# Evaluate cosine on a ciphertext

Evaluate cosine on a ciphertext

## Usage

``` r
eval_cos(ct, a, b, degree)
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
holding the encrypted, slot-wise cosine of `ct`, approximated by a
Chebyshev polynomial of the given `degree` on the interval `[a, b]`.
Accuracy degrades outside that interval, and the result sits
`ceiling(log2(degree)) + 1` levels below `ct`.
