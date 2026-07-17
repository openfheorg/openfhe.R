# Report the number of OpenMP threads available to OpenFHE

Returns `omp_get_max_threads()`: the maximum number of threads OpenFHE
will use for a parallel region under the current settings (see
[`set_num_threads()`](https://openfheorg.github.io/openfhe.R/reference/set_num_threads.md)).
Returns `1` when the package was built without OpenMP.

## Usage

``` r
get_num_threads()
```

## Value

integer; the OpenMP thread limit.

## See also

[`set_num_threads()`](https://openfheorg.github.io/openfhe.R/reference/set_num_threads.md)

## Examples

``` r
get_num_threads()
#> [1] 4
```
