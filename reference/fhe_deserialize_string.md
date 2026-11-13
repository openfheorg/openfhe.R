# Deserialize an OpenFHE object held in memory

The inverse of
[`fhe_serialize()`](https://openfheorg.github.io/openfhe.R/reference/fhe_serialize.md)
with `filename = NULL`.

## Usage

``` r
fhe_deserialize_string(
  data,
  type = c("CryptoContext", "PublicKey", "PrivateKey", "Ciphertext", "EvalKey",
    "EvalKeyMap", "EvalKeyVector"),
  format = NULL
)
```

## Arguments

- data:

  A raw vector (binary format) or a character string (JSON), as
  [`fhe_serialize()`](https://openfheorg.github.io/openfhe.R/reference/fhe_serialize.md)
  returns.

- type:

  One of `"CryptoContext"`, `"PublicKey"`, `"PrivateKey"`,
  `"Ciphertext"`, `"EvalKey"`, `"EvalKeyMap"`, or `"EvalKeyVector"` for
  a serialized list of `EvalKey` objects.

- format:

  `NULL` (default) to take the format from `data`, or `"binary"` or
  `"json"`, which must then agree with `data`.

## Value

The deserialized object; for `"EvalKeyVector"` a list of `EvalKey`
objects.
