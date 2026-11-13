# Homomorphic subtraction in place

Stores `x - y` in the ciphertext operand. One operand is a `Ciphertext`;
the other is a `Ciphertext`, a `Plaintext`, or a single real or complex
number (CKKS). The operands may be given in either order, and the result
is always `x - y`: with `eval_sub_in_place(2, ct)` the ciphertext
becomes `2 - ct`.

## Usage

``` r
eval_sub_in_place(x, ...)
```

## Arguments

- x:

  A `Ciphertext`, a `Plaintext`, or a single real or complex number.

- ...:

  Method-specific arguments: `y`, the other operand.

## Value

The modified `Ciphertext`, invisibly.
