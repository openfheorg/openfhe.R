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

## Memory

The bootstrapping keys that
[`bin_bt_key_gen()`](https://openfheorg.github.io/openfhe.R/reference/bin_bt_key_gen.md)
stores in a context can occupy several gigabytes (about 5.8 GB for
`STD128` with `arb_func = TRUE` and `log_q = 12`). R's garbage collector
does not see this memory, so removing a context with
[`rm()`](https://rdrr.io/r/base/rm.html) does not release it until a
collection happens to run.

- Build one context and reuse it. The keys depend only on the parameters
  and the secret key.

- When a context is no longer needed, call
  [`bin_clear_bt_keys()`](https://openfheorg.github.io/openfhe.R/reference/get_bt_key.md).
  The keys are released at once.

- To release the rest of the context, remove it and call
  [`gc()`](https://rdrr.io/r/base/gc.html).
