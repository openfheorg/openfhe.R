# BinFHE context (Binary FHE)

BinFHE context (Binary FHE)

## Usage

``` r
BinFHEContext(ptr = NULL)
```

## Arguments

- ptr:

  External pointer (internal use)

## Value

An S7 object of class `BinFHEContext`, inheriting from
[OpenFHEObject](https://openfheorg.github.io/openfhe.R/reference/OpenFHEObject.md),
whose `ptr` property holds an external pointer to the C++
boolean-circuit context. It is the BinFHE counterpart of
[CryptoContext](https://openfheorg.github.io/openfhe.R/reference/CryptoContext.md)
and is deliberately a different class, so a
[CryptoContext](https://openfheorg.github.io/openfhe.R/reference/CryptoContext.md)
cannot be passed where a BinFHE context belongs or the other way round.
Obtain one from
[`bin_fhe_context()`](https://openfheorg.github.io/openfhe.R/reference/bin_fhe_context.md)
rather than by calling this constructor directly.
