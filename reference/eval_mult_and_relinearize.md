# Fused multiply-and-relinearize

Equivalent to `relinearize(eval_mult_no_relin(x, y))` but slightly more
efficient in OpenFHE's implementation. Use this at the end of a
multiplication chain.

## Usage

``` r
eval_mult_and_relinearize(x, ...)
```

## Arguments

- x:

  A `Ciphertext`.

- ...:

  Method-specific arguments: `y` — a `Ciphertext` to multiply `x` by in
  a fused multiply-and-relinearize step.

## Value

A relinearized `Ciphertext`.
