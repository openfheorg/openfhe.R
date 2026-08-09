# Plaintext

Plaintext

## Usage

``` r
Plaintext(ptr = NULL)
```

## Arguments

- ptr:

  External pointer (internal use)

## Value

An S7 object of class `Plaintext`, inheriting from
[OpenFHEObject](https://openfheorg.github.io/openfhe.R/reference/OpenFHEObject.md),
whose `ptr` property holds an external pointer to the C++ plaintext. A
plaintext holds an encoded but unencrypted vector together with its
encoding type; obtain one from a `make_*_plaintext()` factory or from
[`decrypt()`](https://openfheorg.github.io/openfhe.R/reference/decrypt.md)
rather than by calling this constructor directly, and read its contents
with
[`get_packed_value()`](https://openfheorg.github.io/openfhe.R/reference/get_packed_value.md),
`get_real_value()` and the other accessors.
