# Clear cached evaluation keys and contexts

Clear cached evaluation keys and contexts

## Usage

``` r
clear_fhe_state(what = c("mult_keys", "automorphism_keys", "contexts"))
```

## Arguments

- what:

  Character vector: subset of "mult_keys", "automorphism_keys",
  "contexts"

## Value

No return value, called for side effects. Depending on `what`, it drops
the process-wide caches of relinearization keys and of automorphism
(rotation) keys, and releases the registry of crypto contexts, freeing
the memory they hold.
