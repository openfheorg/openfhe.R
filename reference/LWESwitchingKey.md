# LWE switching key (Binary FHE)

A key that switches an LWE ciphertext of modulus `Q` and dimension `N`
to one of modulus `q` and dimension `n`, from
[`bin_key_switch_gen()`](https://openfheorg.github.io/openfhe.R/reference/bin_key_gen_pair.md)
or
[`get_switch_key()`](https://openfheorg.github.io/openfhe.R/reference/get_bt_key.md).
It is an opaque handle, as in openfhe-python.

## Usage

``` r
LWESwitchingKey(ptr = NULL)
```

## Arguments

- ptr:

  External pointer (internal use)

## Value

An S7 object of class `LWESwitchingKey`, inheriting from
[OpenFHEObject](https://openfheorg.github.io/openfhe.R/reference/OpenFHEObject.md).
