# Retrieve the sum-key map for a given key tag

Accessor for the cc-internal static map populated by
[`eval_sum_key_gen()`](https://openfheorg.github.io/openfhe.R/reference/eval_sum_key_gen.md).
Used by the multi-party sum protocol to pull the lead party's initial
eval-sum map so other parties can produce their shares.

## Usage

``` r
get_eval_sum_key_map(key_tag)
```

## Arguments

- key_tag:

  Character; the key tag used when the map was originally generated.
  Typically the
  [`get_key_tag()`](https://openfheorg.github.io/openfhe.R/reference/key_tag.md)
  of the secret key that produced it.

## Value

An `EvalKeyMap`.

## Details

The underlying C++ call returns a `const std::map&`; the R wrapper
copies the map into a fresh `shared_ptr` to give the returned
`EvalKeyMap` owning semantics. The returned map is a snapshot:
subsequent modifications to the cc registry are not reflected.
