# LWE Private Key (Binary FHE)

LWE Private Key (Binary FHE)

## Usage

``` r
LWEPrivateKey(ptr = NULL)
```

## Arguments

- ptr:

  External pointer (internal use)

## Value

An S7 object of class `LWEPrivateKey`, inheriting from
[OpenFHEObject](https://openfheorg.github.io/openfhe.R/reference/OpenFHEObject.md),
whose `ptr` property holds an external pointer to the C++ LWE secret
key. It both encrypts and decrypts in the boolean-circuit (BinFHE)
schemes; obtain one from
[`bin_key_gen()`](https://openfheorg.github.io/openfhe.R/reference/bin_key_gen.md)
rather than by calling this constructor directly.
