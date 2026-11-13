# Hop level and encoding type of a ciphertext

The hop level is the number of proxy re-encryptions recorded on a
ciphertext. The encoding type records which plaintext encoding the
ciphertext carries (see
[`get_encoding_type()`](https://openfheorg.github.io/openfhe.R/reference/plaintext_accessors.md)).

## Usage

``` r
get_hop_level(ct)

set_hop_level(ct, hop_level)

set_encoding_type(ct, encoding_type)
```

## Arguments

- ct:

  A `Ciphertext`.

- hop_level:

  Integer.

- encoding_type:

  A member of
  [PlaintextEncodings](https://openfheorg.github.io/openfhe.R/reference/PlaintextEncodings.md).

## Value

`get_hop_level()`: an integer. The setters return `ct`, invisibly.
