# All contexts the library currently holds

OpenFHE keeps every context it has generated in a registry, and returns
the registered one when asked for parameters it has seen. This function
lists the registry.

## Usage

``` r
get_all_contexts()
```

## Value

A list of `CryptoContext` objects.

## See also

[`clear_fhe_state()`](https://openfheorg.github.io/openfhe.R/reference/clear_fhe_state.md),
which can empty the registry.
