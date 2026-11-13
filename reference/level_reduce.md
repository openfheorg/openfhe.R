# Reduce the modulus chain by multiple levels

Drops `levels` levels from `x`'s modulus chain in a single operation.
Useful when `x` is at a deeper level than the ciphertext it will
interact with next; level-reducing brings them onto the same rung of the
chain.

## Usage

``` r
level_reduce(x, ...)
```

## Arguments

- x:

  A `Ciphertext`.

- ...:

  Method-specific arguments: `eval_key` (an `EvalKey`, or `NULL` for no
  key), `levels` (integer, default `1L`).

## Value

A `Ciphertext` at `x$level + levels`.

## Details

The C++ signature takes an evaluation key, which the RNS schemes do not
use. Pass `NULL`, as the OpenFHE examples pass a null key, or an
`EvalKey`.
