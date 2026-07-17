# Generate a lookup table for an arbitrary plaintext function

Computes `f(0:(p-1), p)` and returns it as a numeric vector suitable for
[`eval_func()`](https://openfheorg.github.io/openfhe.R/reference/eval_func.md).
This is the R-side analogue of OpenFHE's `GenerateLUTviaFunction` — we
don't bind the C++ helper because its signature takes a raw function
pointer that can't capture an R closure, and R is natively vectorised so
a pure-R helper is both simpler and faster than wiring an R callback
through cpp11.

## Usage

``` r
generate_lut_via_function(f, p)
```

## Arguments

- f:

  A function `function(m, p)` that returns the table entry for input `m`
  under plaintext modulus `p`. Vectorised functions are supported.

- p:

  The plaintext modulus (typically `get_max_plaintext_space(ctx)`)

## Value

A length-`p` numeric vector of LUT entries
