# Homomorphic multiplication by a number, in place

Multiplies a ciphertext by a single real or complex number (CKKS) and
stores the result in the ciphertext. The operands may be given in either
order. OpenFHE declares no in-place product of two ciphertexts or of a
ciphertext and a plaintext on the `CryptoContext`; use
[`eval_mult()`](https://openfheorg.github.io/openfhe.R/reference/eval_mult.md)
for those.

## Usage

``` r
eval_mult_in_place(x, ...)
```

## Arguments

- x:

  A `Ciphertext`, or a single real or complex number.

- ...:

  Method-specific arguments: `y`, the other operand.

## Value

The modified `Ciphertext`, invisibly.
