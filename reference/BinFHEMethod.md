# Binary FHE Methods

Mirrors the C++ enum `BINFHE_METHOD` in `binfhe/binfhe-constants.h`.

## Usage

``` r
BinFHEMethod
```

## Value

A named `list` of 4 integer scalars, each the value of the OpenFHE C++
enumerator of the same name, selecting the bootstrapping method a
boolean-circuit context uses: `AP` (Alperin-Sheriff-Peikert), `GINX`
(Gama-Izabachene-Nguyen-Xie, the default) or `LMKCDEY`. `INVALID_METHOD`
marks an unset value. Pass an element as the `method` argument of
[`bin_fhe_context()`](https://openfheorg.github.io/openfhe.R/reference/bin_fhe_context.md).
