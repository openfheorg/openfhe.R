# LWE public key (Binary FHE)

The public key of the LWE scheme of a BinFHE context, from
[`bin_key_gen_pair()`](https://openfheorg.github.io/openfhe.R/reference/bin_key_gen_pair.md)
or
[`bin_pub_key_gen()`](https://openfheorg.github.io/openfhe.R/reference/bin_key_gen_pair.md).
[`bin_encrypt()`](https://openfheorg.github.io/openfhe.R/reference/bin_encrypt.md)
accepts it in place of the secret key.

## Usage

``` r
LWEPublicKey(ptr = NULL)
```

## Arguments

- ptr:

  External pointer (internal use)

## Value

An S7 object of class `LWEPublicKey`, inheriting from
[OpenFHEObject](https://openfheorg.github.io/openfhe.R/reference/OpenFHEObject.md).
