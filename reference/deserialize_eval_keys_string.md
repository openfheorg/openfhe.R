# Deserialize evaluation keys held in memory

Registers the keys in `data`, as
[`serialize_eval_keys()`](https://openfheorg.github.io/openfhe.R/reference/serialize_eval_keys.md)
with `filename = NULL` returns them.

## Usage

``` r
deserialize_eval_keys_string(
  data,
  type = c("mult", "automorphism", "sum"),
  format = NULL
)
```

## Arguments

- data:

  A raw vector (binary format) or a character string (JSON).

- type:

  `"mult"`, `"automorphism"` or `"sum"`.

- format:

  `NULL` (default) to take the format from `data`, or `"binary"` or
  `"json"`, which must then agree with `data`.

## Value

`TRUE`, invisibly.
