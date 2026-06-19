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
  bootstrapping (EvalSign, EvalFunc). Selecting any of `arb_func`,
  `log_q`, `n`, or `time_optimization` activates the extended overload.

- log_q:

  log2 of the large ciphertext modulus Q used by functional
  bootstrapping (default 11; use 17 for the eval-sign example).

- n:

  Ring dimension override (0 lets OpenFHE pick).

- time_optimization:

  Enable the GINX time-optimization variant.

## Value

A BinFHEContext (stored as OpenFHEObject)
