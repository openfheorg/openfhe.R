# Homomorphic addition in place

Stores the sum of the two operands in the ciphertext operand, without
allocating a new `Ciphertext`. One operand is a `Ciphertext`; the other
is a `Ciphertext`, a `Plaintext`, or a single real or complex number
(CKKS). The operands may be given in either order, as in the C++
library. When both are ciphertexts the first one receives the result.

## Usage

``` r
eval_add_in_place(x, ...)
```

## Arguments

- x:

  A `Ciphertext`, a `Plaintext`, or a single real or complex number.

- ...:

  Method-specific arguments: `y`, the other operand.

## Value

The modified `Ciphertext`, invisibly.
