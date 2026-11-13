# Decompose a large-precision ciphertext into digits

Splits a ciphertext of large modulus into ciphertexts of its digits,
each of the small modulus of the context (a context built with
`arb_func = TRUE`).

## Usage

``` r
eval_decomp(ctx, ct)
```

## Arguments

- ctx:

  A `BinFHEContext`.

- ct:

  An `LWECiphertext`.

## Value

A list of `LWECiphertext` objects, least significant digit first.

## See also

[`eval_sign()`](https://openfheorg.github.io/openfhe.R/reference/eval_sign.md),
[`eval_floor()`](https://openfheorg.github.io/openfhe.R/reference/eval_floor.md)
