# The scheme object of a CryptoContext

The object that implements the operations of a context's scheme, as
returned by
[`get_scheme()`](https://openfheorg.github.io/openfhe.R/reference/ccparams_getters.md)
on a `CryptoContext`. It is an opaque handle, as in openfhe-python, with
no methods of its own.

## Usage

``` r
SchemeBase(ptr = NULL)
```

## Arguments

- ptr:

  External pointer (internal use)

## Value

An S7 object of class `SchemeBase`, inheriting from
[OpenFHEObject](https://openfheorg.github.io/openfhe.R/reference/OpenFHEObject.md).
