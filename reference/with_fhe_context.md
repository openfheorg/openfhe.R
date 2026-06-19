# Execute code with automatic cleanup of FHE state

Clears eval keys and releases contexts on exit (even on error).

## Usage

``` r
with_fhe_context(expr)
```

## Arguments

- expr:

  Expression to evaluate

## Value

Result of expr
