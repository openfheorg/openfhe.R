# Encryption Technique

Mirrors the C++ enum `EncryptionTechnique` in `pke/constants-defs.h`.

## Usage

``` r
EncryptionTechnique
```

## Value

A named `list` of 2 integer scalars, each the value of the OpenFHE C++
enumerator of the same name: `STANDARD` encrypts in the ciphertext
modulus, while `EXTENDED` encrypts in an enlarged modulus, which lowers
the noise BFV multiplication starts from. Pass an element as the
`encryption_technique` argument of
[`BFVParams()`](https://openfheorg.github.io/openfhe.R/reference/BFVParams.md)
or
[`fhe_context()`](https://openfheorg.github.io/openfhe.R/reference/fhe_context.md).
