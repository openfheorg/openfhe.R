# A constant as an LWE ciphertext

Returns a ciphertext of the Boolean `value` that needs no key: a trivial
encryption, for use as a constant input of a gate.

## Usage

``` r
eval_constant(ctx, value)
```

## Arguments

- ctx:

  A `BinFHEContext`.

- value:

  Logical.

## Value

An `LWECiphertext`.
