# Associated CryptoContext of a Ciphertext

Returns the `CryptoContext` that was used to construct `ct`. OpenFHE
ciphertexts carry a back-pointer to their context so that homomorphic
operations can dispatch to the correct scheme implementation without
requiring the user to pass the context explicitly.

## Usage

``` r
get_crypto_context(ct, ...)
```

## Arguments

- ct:

  A `Ciphertext`.

- ...:

  Reserved for future method-specific arguments.

## Value

A `CryptoContext` S7 object.

## Details

Naming note: `get_crypto_context` is distinct from
`get_crypto_parameters`. The former returns the high-level
`CryptoContext` S7 wrapper; the latter returns the opaque
`CryptoParameters` S7 wrapper.
