# Report the number of OpenMP threads available to OpenFHE

Returns the cap OpenFHE currently applies to its parallel regions: the
number of hardware threads at load, or the value most recently passed to
[`set_num_threads()`](https://openfheorg.github.io/openfhe.R/reference/set_num_threads.md).
Returns `1` when the package was built without OpenMP.

## Usage

``` r
get_num_threads()
```

## Value

integer; the current thread cap.

## See also

[`set_num_threads()`](https://openfheorg.github.io/openfhe.R/reference/set_num_threads.md)

## Examples

``` r
get_num_threads()
#> [1] 4
```
