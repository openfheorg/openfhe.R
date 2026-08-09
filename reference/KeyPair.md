# Key Pair

Contains a public key and a secret (private) key.

## Usage

``` r
KeyPair(public = NULL, secret = NULL)
```

## Arguments

- public:

  A PublicKey

- secret:

  A PrivateKey

## Value

An S7 object of class `KeyPair` with two properties, `public` (a
[PublicKey](https://openfheorg.github.io/openfhe.R/reference/PublicKey.md))
and `secret` (a
[PrivateKey](https://openfheorg.github.io/openfhe.R/reference/PrivateKey.md)),
which are the two halves of one freshly generated key. Obtain one from
[`key_gen()`](https://openfheorg.github.io/openfhe.R/reference/key_gen.md)
rather than by calling this constructor directly.
