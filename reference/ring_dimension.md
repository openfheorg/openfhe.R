# Ring dimension of a CryptoContext

Returns N, the cyclotomic ring dimension. The cyclotomic order M used by
[`eval_fast_rotation()`](https://bnaras.github.io/openfhe.R/reference/eval_fast_rotation.md)
is `2 * N`.

## Usage

``` r
ring_dimension(cc, ...)
```

## Arguments

- cc:

  A CryptoContext

- ...:

  Reserved for future method-specific arguments

## Value

Integer ring dimension
