# The public key an object holds

For a `BinFHEContext`, the LWE public key among its bootstrapping keys,
present after
[`bin_bt_key_gen()`](https://openfheorg.github.io/openfhe.R/reference/bin_bt_key_gen.md)
with `KeygenMode$PUB_ENCRYPT`. For a `SchemeSwitchingDataDeserializer`,
the CKKS public key it has read.

## Usage

``` r
get_public_key(x, ...)
```

## Arguments

- x:

  A `BinFHEContext` or a
  [SchemeSwitchingDataDeserializer](https://openfheorg.github.io/openfhe.R/reference/SchemeSwitchingDataSerializer.md).

- ...:

  Not used.

## Value

An
[LWEPublicKey](https://openfheorg.github.io/openfhe.R/reference/LWEPublicKey.md)
or a `PublicKey`, or `NULL` if the object holds none.

## See also

[`get_bt_key()`](https://openfheorg.github.io/openfhe.R/reference/get_bt_key.md)
