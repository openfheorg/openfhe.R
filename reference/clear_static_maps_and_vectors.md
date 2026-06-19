# Clear OpenFHE static maps and vectors

Releases memory held in the upstream static eval-key maps and related
global caches. Useful in long-running R sessions where repeated context
construction accumulates static state. The call is idempotent; calling
it when no static state is held is a no-op.

## Usage

``` r
clear_static_maps_and_vectors()
```

## Value

`invisible(NULL)`.
