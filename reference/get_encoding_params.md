# Encoding parameters of a CryptoContext

Returns the `EncodingParams` S7 object wrapping
`std::shared_ptr<EncodingParamsImpl>`. Holds the plaintext modulus,
batch size, and other encoding-level parameters.

## Usage

``` r
get_encoding_params(cc, ...)
```

## Arguments

- cc:

  A `CryptoContext`.

- ...:

  Reserved for future method-specific arguments.

## Value

An `EncodingParams` S7 object.
