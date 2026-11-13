# LWE key pair (Binary FHE)

The public key and the matching secret key from
[`bin_key_gen_pair()`](https://openfheorg.github.io/openfhe.R/reference/bin_key_gen_pair.md).
[`is_good()`](https://openfheorg.github.io/openfhe.R/reference/is_good.md)
is `TRUE` when both are present.

## Usage

``` r
LWEKeyPair(public = NULL, secret = NULL)
```

## Arguments

- public:

  An
  [LWEPublicKey](https://openfheorg.github.io/openfhe.R/reference/LWEPublicKey.md).

- secret:

  An
  [LWEPrivateKey](https://openfheorg.github.io/openfhe.R/reference/LWEPrivateKey.md).

## Value

An S7 object of class `LWEKeyPair` with properties `public` and
`secret`.
