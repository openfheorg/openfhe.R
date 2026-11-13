# Encode a character string as a plaintext

Each character becomes one coefficient, so the plaintext modulus must be
large enough for the character codes; the OpenFHE examples use 256. Read
the string back with
[`get_string_value()`](https://openfheorg.github.io/openfhe.R/reference/plaintext_accessors.md).

## Usage

``` r
make_string_plaintext(cc, str)
```

## Arguments

- cc:

  A `CryptoContext` (BFV or BGV).

- str:

  A single character string.

## Value

A `Plaintext`.
