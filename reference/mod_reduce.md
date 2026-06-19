# Reduce the modulus chain by one level

Synonym for
[`rescale()`](https://bnaras.github.io/openfhe.R/reference/rescale.md).
Both names dispatch to the same C++ operation
(`CryptoContextImpl::Rescale` delegates to `ModReduce` internally); the
R binding keeps both so fixture and vignette authors can use whichever
name matches the OpenFHE documentation they're following.

## Usage

``` r
mod_reduce(x, ...)
```

## Arguments

- x:

  A `Ciphertext`.

- ...:

  Reserved for future method-specific arguments.

## Value

A `Ciphertext` at one lower level.

## See also

[`rescale()`](https://bnaras.github.io/openfhe.R/reference/rescale.md),
[`mod_reduce_in_place()`](https://bnaras.github.io/openfhe.R/reference/mod_reduce_in_place.md)
