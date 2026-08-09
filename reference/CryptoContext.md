# Crypto Context

Crypto Context

## Usage

``` r
CryptoContext(ptr = NULL)
```

## Arguments

- ptr:

  External pointer (internal use)

## Value

An S7 object of class `CryptoContext`, inheriting from
[OpenFHEObject](https://openfheorg.github.io/openfhe.R/reference/OpenFHEObject.md),
whose `ptr` property holds an external pointer to the C++ crypto
context. The context owns the scheme parameters and the registry of
evaluation keys, and is the first argument to most operations. Obtain
one from
[`fhe_context()`](https://openfheorg.github.io/openfhe.R/reference/fhe_context.md)
rather than by calling this constructor directly.
