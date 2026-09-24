# Set the number of OpenMP threads OpenFHE may use

OpenFHE parallelizes its core arithmetic with OpenMP and, by default,
uses every hardware thread the machine reports. `set_num_threads()` sets
the cap through OpenFHE's own thread controls, which every parallel
region in the library consults when it starts, so the change takes
effect immediately, on every platform, and regardless of which thread
the work runs on. It is a no-op when the package was built without
OpenMP.

## Usage

``` r
set_num_threads(n)
```

## Arguments

- n:

  integer; the requested maximum number of threads (at least 1).

## Value

integer; the cap now in effect, invisibly.

## Details

Requests above the number of threads available when the library was
loaded (the hardware count, or `OMP_NUM_THREADS` if that was set before
R started) are reduced to that number. The value in effect is returned,
so a reduced request is visible to the caller;
[`get_num_threads()`](https://openfheorg.github.io/openfhe.R/reference/get_num_threads.md)
reports the same value later.

The package default is uncapped, so interactive users get full
parallelism. Under `R CMD check`, which sets `_R_CHECK_LIMIT_CORES_`,
the package caps itself at two threads when it is loaded, in line with
CRAN's two-thread policy. This also covers packages that depend on
'openfhe.R', which therefore need no thread handling of their own.

## See also

[`get_num_threads()`](https://openfheorg.github.io/openfhe.R/reference/get_num_threads.md)

## Examples

``` r
old <- get_num_threads()
set_num_threads(2L)
set_num_threads(old)
```
