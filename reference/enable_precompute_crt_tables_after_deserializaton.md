# Precompute CRT tables when a context is deserialized

By default OpenFHE precomputes its CRT tables when it deserializes a
context. `disable_precompute_crt_tables_after_deserializaton()` turns
that off, which makes deserialization faster for a context that will
only be inspected, and
`enable_precompute_crt_tables_after_deserializaton()` turns it back on.
The setting is global.

## Usage

``` r
enable_precompute_crt_tables_after_deserializaton()

disable_precompute_crt_tables_after_deserializaton()
```

## Value

`NULL`, invisibly.

## Details

The function names keep the spelling of the C++ functions they call.
