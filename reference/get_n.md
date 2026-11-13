# Parameters of a BinFHE context

The LWE parameters of a context. OpenFHE names them by letter case,
which R function names do not carry: `get_n()` is the lattice dimension
`n` and `get_big_n()` the ring dimension `N`; `get_q()` is the small
ciphertext modulus `q` and `get_big_q()` the large modulus `Q` (the C++
`Getn()`, `GetN()`, `Getq()` and `GetQ()`). `get_beta()` is the bound
`beta` in the plaintext space `q / (2 * beta)`.

## Usage

``` r
get_n(ctx)

get_big_n(ctx)

get_q(ctx)

get_big_q(ctx)

get_beta(ctx)
```

## Arguments

- ctx:

  A `BinFHEContext`.

## Value

`get_n()` and `get_big_n()`: an integer. The others: a number, or a
string of decimal digits if the value is above 2^53.

## See also

[`get_max_plaintext_space()`](https://openfheorg.github.io/openfhe.R/reference/get_max_plaintext_space.md)

## Examples

``` r
ctx <- bin_fhe_context(BinFHEParamSet$TOY)
c(n = get_n(ctx), N = get_big_n(ctx), q = get_q(ctx), Q = get_big_q(ctx))
#>         n         N         q         Q 
#>        64       512       512 134215681 
```
