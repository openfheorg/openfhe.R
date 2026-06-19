# Retrieve the automorphism-key map for a given key tag

Accessor for the cc-internal static automorphism-key map. The underlying
C++ call returns a `shared_ptr` directly (no copy), so the returned
`EvalKeyMap` is a live view of the cc registry.

## Usage

``` r
get_eval_automorphism_key_map(key_tag)
```

## Arguments

- key_tag:

  Character; the key tag used when the map was originally generated.

## Value

An `EvalKeyMap`.
