# Crypto parameters of a CryptoContext

Returns the `CryptoParameters` S7 object carrying the opaque
`std::shared_ptr<CryptoParametersBase<DCRTPoly>>` at the C++ level.
Useful for introspection; most R users will prefer to call the
individual lambda-routed getters (e.g. `get_scaling_technique(cc)`,
`get_batch_size(cc)`) directly instead of going through the
CryptoParameters object.

## Usage

``` r
get_crypto_parameters(cc, ...)
```

## Arguments

- cc:

  A `CryptoContext`.

- ...:

  Reserved for future method-specific arguments.

## Value

A `CryptoParameters` S7 object.
