# Scheme Identifier

Returned by
[`get_scheme()`](https://bnaras.github.io/openfhe.R/reference/ccparams_getters.md)
on any `CCParams` object. R-side name `SchemeId` matches the upstream
`pke/scheme/scheme-id.h` header filename and avoids colliding with a
future `Scheme` S7 class (design.md §6 mentions a potential wrapper
around `std::shared_ptr<SchemeBase<DCRTPoly>>` with that name).

## Usage

``` r
SchemeId
```

## Details

Source: pke/scheme/scheme-id.h enum SCHEME
