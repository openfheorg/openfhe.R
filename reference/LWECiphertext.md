# LWE Ciphertext (Binary FHE)

LWE Ciphertext (Binary FHE)

## Usage

``` r
LWECiphertext(ptr = NULL)
```

## Arguments

- ptr:

  External pointer (internal use)

## Value

An S7 object of class `LWECiphertext`, inheriting from
[OpenFHEObject](https://openfheorg.github.io/openfhe.R/reference/OpenFHEObject.md),
whose `ptr` property holds an external pointer to the C++ LWE
ciphertext. This is the encrypted-bit type the boolean- circuit (BinFHE)
schemes operate on; obtain one from
[`bin_encrypt()`](https://openfheorg.github.io/openfhe.R/reference/bin_encrypt.md)
or from a gate evaluation rather than by calling this constructor
directly.
