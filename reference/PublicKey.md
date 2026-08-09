# Public Key

Public Key

## Usage

``` r
PublicKey(ptr = NULL)
```

## Arguments

- ptr:

  External pointer (internal use)

## Value

An S7 object of class `PublicKey`, inheriting from
[OpenFHEObject](https://openfheorg.github.io/openfhe.R/reference/OpenFHEObject.md),
whose `ptr` property holds an external pointer to the C++ public key.
This is the key
[`encrypt()`](https://openfheorg.github.io/openfhe.R/reference/encrypt.md)
takes; obtain one as the `public` element of the
[KeyPair](https://openfheorg.github.io/openfhe.R/reference/KeyPair.md)
returned by
[`key_gen()`](https://openfheorg.github.io/openfhe.R/reference/key_gen.md)
rather than by calling this constructor directly.
