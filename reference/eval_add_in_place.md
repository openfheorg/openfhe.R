# Homomorphic addition in place

Modifies the first argument in place to hold the result of adding the
second argument. Avoids allocating a new Ciphertext, which matters in
tight loops or when ciphertext memory footprint is a concern.

## Usage

``` r
eval_add_in_place(x, ...)
```

## Arguments

- x:

  A `Ciphertext` (modified in place).

- ...:

  Method-specific arguments: `y` — a `Ciphertext`, `Plaintext`, or
  numeric scalar to add into `x`.

## Value

`x` invisibly.
