# Ciphertext class

Wraps an encrypted OpenFHE ciphertext. Supports arithmetic operators
`+`, `-`, `*` which dispatch to homomorphic operations.

## Usage

``` r
Ciphertext(ptr = NULL)
```

## Arguments

- ptr:

  External pointer (internal use)

## Value

An S7 object of class `Ciphertext`, inheriting from
[OpenFHEObject](https://openfheorg.github.io/openfhe.R/reference/OpenFHEObject.md),
whose `ptr` property holds an external pointer to the C++ ciphertext.
Ciphertexts are produced by
[`encrypt()`](https://openfheorg.github.io/openfhe.R/reference/encrypt.md)
and by the `eval_*()` family rather than by calling this constructor
directly, and they carry the encrypted vector together with the level
and scaling-factor bookkeeping the scheme needs.
