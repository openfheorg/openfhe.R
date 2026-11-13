# Create a Binary FHE context

Create a Binary FHE context

## Usage

``` r
bin_fhe_context(
  paramset = BinFHEParamSet$STD128,
  method = BinFHEMethod$GINX,
  arb_func = FALSE,
  log_q = 11L,
  n = 0L,
  time_optimization = FALSE
)
```

## Arguments

- paramset:

  A BinFHEParamSet value (default: STD128)

- method:

  A BinFHEMethod value (default: GINX)

- arb_func:

  If TRUE, build a context that supports arbitrary-function
  bootstrapping (EvalSign, EvalFunc). Supplying any of `arb_func`,
  `log_q`, `n`, or `time_optimization`, even at its default value,
  selects the C++ overload that derives the parameters from them instead
  of reading the table for `paramset`; the two give different contexts
  for the same `paramset`.

- log_q:

  log2 of the large ciphertext modulus Q used by functional
  bootstrapping (default 11; use 17 for the eval-sign example).

- n:

  Ring dimension override (0 lets OpenFHE pick).

- time_optimization:

  Enable the GINX time-optimization variant.

## Value

A
[BinFHEContext](https://openfheorg.github.io/openfhe.R/reference/BinFHEContext.md)
object.
