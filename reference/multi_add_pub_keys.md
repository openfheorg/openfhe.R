# Combine public keys from multiple parties

Combine public keys from multiple parties

## Usage

``` r
multi_add_pub_keys(cc, pk1, pk2, key_tag = "")
```

## Arguments

- cc:

  A CryptoContext

- pk1, pk2:

  PublicKey objects to combine

- key_tag:

  Character; optional tag to associate with the combined key. Default
  `""` (empty tag) to match the C++ header default. Round-trips through
  [`get_key_tag()`](https://bnaras.github.io/openfhe.R/reference/key_tag.md).

## Value

A combined PublicKey
