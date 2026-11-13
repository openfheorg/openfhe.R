# Release the precomputations a CKKS context has cached

CKKS bootstrapping and scheme switching keep precomputed tables in the
context. `clear_bootstrap_precom()` and `clear_scheme_switch_precom()`
release one kind each, and raise an error on a context that is not CKKS.
`clear_all_ckks_caches()` releases both and does nothing on a context of
another scheme.

## Usage

``` r
clear_all_ckks_caches(cc)

clear_bootstrap_precom(cc)

clear_scheme_switch_precom(cc)
```

## Arguments

- cc:

  A `CryptoContext`.

## Value

`cc`, invisibly.
