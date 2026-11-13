# Set the scheme identifier of a CryptoContext

The counterpart of the C++ `setSchemeId()`. The identifier is set when
the context is generated; this function is for code that assembles a
context by hand.

## Usage

``` r
set_scheme_id(cc, scheme_tag)
```

## Arguments

- cc:

  A `CryptoContext`.

- scheme_tag:

  A member of
  [SchemeId](https://openfheorg.github.io/openfhe.R/reference/SchemeId.md).

## Value

`cc`, invisibly.
