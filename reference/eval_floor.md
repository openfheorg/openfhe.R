# Evaluate a floor (rounding) function on an LWE ciphertext

Performs the LWE equivalent of `floor(ct / 2^roundbits)` via functional
bootstrapping. Used as a primitive in arbitrary- function evaluation
pipelines where the bit-level rounding operation is needed separately
from
[`eval_func()`](https://openfheorg.github.io/openfhe.R/reference/eval_func.md)'s
LUT path.

## Usage

``` r
eval_floor(ctx, ct, roundbits)
```

## Arguments

- ctx:

  A BinFHEContext

- ct:

  An LWECiphertext

- roundbits:

  Integer; the number of low-order bits to round off.

## Value

A new LWECiphertext holding the rounded value.

## Details

Binding-level note: the underlying `BinFHEContext__EvalFloor` cpp11
binding has been present since the earliest BinFHE work; the R wrapper
was added later to close the latent gap (cpp11-only entry with no R
path).

## See also

[`eval_func()`](https://openfheorg.github.io/openfhe.R/reference/eval_func.md),
[`eval_sign()`](https://openfheorg.github.io/openfhe.R/reference/eval_sign.md)
