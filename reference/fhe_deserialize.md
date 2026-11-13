# Deserialize an OpenFHE object from file

Deserialize an OpenFHE object from file

## Usage

``` r
fhe_deserialize(
  filename,
  type = c("CryptoContext", "PublicKey", "PrivateKey", "Ciphertext", "EvalKey",
    "EvalKeyMap", "BinFHEContext", "LWECiphertext", "LWEPrivateKey", "LWEPublicKey",
    "RingGSWBTKey"),
  format = "binary"
)
```

## Arguments

- filename:

  Path to serialized file

- type:

  One of `"CryptoContext"`, `"PublicKey"`, `"PrivateKey"`,
  `"Ciphertext"`, `"EvalKey"`, `"EvalKeyMap"`, or, for Binary FHE,
  `"BinFHEContext"`, `"LWECiphertext"`, `"LWEPrivateKey"`,
  `"LWEPublicKey"`, `"RingGSWBTKey"`.

- format:

  "binary" (default) or "json"

## Value

The deserialized object

## See also

[`fhe_deserialize_string()`](https://openfheorg.github.io/openfhe.R/reference/fhe_deserialize_string.md)
for data held in memory.
