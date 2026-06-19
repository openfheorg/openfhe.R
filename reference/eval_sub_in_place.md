# Homomorphic subtraction in place

Modifies the first argument in place to hold the result of subtracting
the second argument.

## Usage

``` r
eval_sub_in_place(x, ...)
```

## Arguments

- x:

  A `Ciphertext` (modified in place).

- ...:

  Method-specific arguments: `y` — a `Ciphertext`, `Plaintext`, or
  numeric scalar to subtract from `x`.

## Value

`x` invisibly.
