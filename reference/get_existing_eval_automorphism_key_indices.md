# Which automorphism keys exist

`get_existing_eval_automorphism_key_indices()` returns the automorphism
indices for which keys are registered under a key tag.
`get_eval_automorphism_no_key_indices()` returns those of a given set of
indices that have no key yet. `get_unique_values()` is the set
difference they are built on: the values of `new_values` that are not in
`old_values`.

## Usage

``` r
get_existing_eval_automorphism_key_indices(key_tag)

get_eval_automorphism_no_key_indices(key_tag, indices)

get_unique_values(old_values, new_values)
```

## Arguments

- key_tag:

  Character string; the tag of the secret key the keys were generated
  for (see
  [`get_key_tag()`](https://openfheorg.github.io/openfhe.R/reference/key_tag.md)).

- indices, old_values, new_values:

  Integer vectors.

## Value

An integer vector in increasing order.

## Details

The indices are automorphism indices, as
[`find_automorphism_index()`](https://openfheorg.github.io/openfhe.R/reference/find_automorphism_index.md)
returns, not rotation amounts.
