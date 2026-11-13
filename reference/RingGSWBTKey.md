# Bootstrapping key (Binary FHE)

The refreshing key, switching key and public key that
[`bin_bt_key_gen()`](https://openfheorg.github.io/openfhe.R/reference/bin_bt_key_gen.md)
generates, as one object, from
[`get_bt_key()`](https://openfheorg.github.io/openfhe.R/reference/get_bt_key.md).
It is an opaque handle, as in openfhe-python: write it to a file with
[`fhe_serialize()`](https://openfheorg.github.io/openfhe.R/reference/fhe_serialize.md)
and load it into a context with
[`bin_bt_key_load()`](https://openfheorg.github.io/openfhe.R/reference/get_bt_key.md).

## Usage

``` r
RingGSWBTKey(ptr = NULL)
```

## Arguments

- ptr:

  External pointer (internal use)

## Value

An S7 object of class `RingGSWBTKey`, inheriting from
[OpenFHEObject](https://openfheorg.github.io/openfhe.R/reference/OpenFHEObject.md).
