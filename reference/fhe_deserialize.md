# Deserialize an OpenFHE object from file

Deserialize an OpenFHE object from file

## Usage

``` r
fhe_deserialize(
  filename,
  type = c("CryptoContext", "PublicKey", "PrivateKey", "Ciphertext"),
  format = "binary"
)
```

## Arguments

- filename:

  Path to serialized file

- type:

  One of "CryptoContext", "PublicKey", "PrivateKey", "Ciphertext"

- format:

  "binary" (default) or "json"

## Value

The deserialized object
