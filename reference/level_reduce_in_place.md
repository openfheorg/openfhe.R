# Reduce the modulus chain by multiple levels, in place

Reduce the modulus chain by multiple levels, in place

## Usage

``` r
level_reduce_in_place(x, ...)
```

## Arguments

- x:

  A `Ciphertext` (modified in place).

- ...:

  Method-specific arguments: `eval_key` (an `EvalKey`, or `NULL` for no
  key), `levels` (integer, default `1L`).

## Value

`x` invisibly.
