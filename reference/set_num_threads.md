# Set the number of OpenMP threads OpenFHE may use

OpenFHE parallelizes its core arithmetic with OpenMP and, by default,
uses every core the machine reports. `set_num_threads()` calls the
OpenMP runtime directly (`omp_set_num_threads`) to cap the threads used
by homomorphic operations run afterward in the current session. The
change takes effect immediately and on every platform, regardless of
when the package was loaded. It is a no-op when the package was built
without OpenMP.

## Usage

``` r
set_num_threads(n)
```

## Arguments

- n:

  integer; the maximum number of threads (at least 1).

## Value

`NULL`, invisibly. Called for its side effect.

## Details

The package default is uncapped, so interactive users get full
parallelism. The package's own tests and vignettes call
`set_num_threads(2L)` to stay within CRAN's two-thread policy.

## See also

[`get_num_threads()`](https://openfheorg.github.io/openfhe.R/reference/get_num_threads.md)

## Examples

``` r
old <- get_num_threads()
set_num_threads(2L)
set_num_threads(old)
```
