# Serialize an OpenFHE object

Writes an object to a file, or, with `filename = NULL`, returns its
serialized form: a raw vector for the binary format and a character
string for JSON.

## Usage

``` r
fhe_serialize(x, ...)
```

## Arguments

- x:

  A `CryptoContext`, `PublicKey`, `PrivateKey`, `Ciphertext`, `EvalKey`
  or `EvalKeyMap`, or a list of `EvalKey` objects (in memory only). For
  Binary FHE, a `BinFHEContext`, `LWECiphertext`, `LWEPrivateKey`,
  `LWEPublicKey` or `RingGSWBTKey` (to a file only).

- ...:

  Method arguments: `filename`, a path, or `NULL` (default) to serialize
  in memory; `format`, `"binary"` (default) or `"json"`.

## Value

With a file name, `TRUE` invisibly. Otherwise a raw vector
(`format = "binary"`) or a character string (`format = "json"`).

## See also

[`fhe_deserialize()`](https://openfheorg.github.io/openfhe.R/reference/fhe_deserialize.md),
[`fhe_deserialize_string()`](https://openfheorg.github.io/openfhe.R/reference/fhe_deserialize_string.md)

## Examples

``` r
cc <- fhe_context("BFV", plaintext_modulus = 65537, multiplicative_depth = 1)
keys <- key_gen(cc)
bytes <- fhe_serialize(keys@public)
pk <- fhe_deserialize_string(bytes, "PublicKey")
```
