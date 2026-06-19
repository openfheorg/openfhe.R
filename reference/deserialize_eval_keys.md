# Deserialize evaluation keys from file

Deserialize evaluation keys from file

## Usage

``` r
deserialize_eval_keys(
  filename,
  type = c("mult", "automorphism", "sum"),
  format = "binary"
)
```

## Arguments

- filename:

  Path to serialized file

- type:

  "mult", "automorphism", or "sum"

- format:

  "binary" (default) or "json"

## Value

TRUE on success (invisibly)
