# Serialize evaluation keys to file

Serialize evaluation keys to file

## Usage

``` r
serialize_eval_keys(
  filename,
  type = c("mult", "automorphism", "sum"),
  format = "binary",
  key_tag = ""
)
```

## Arguments

- filename:

  Path to output file

- type:

  "mult" or "automorphism"

- format:

  "binary" (default) or "json"

- key_tag:

  Key tag (default: "")

## Value

TRUE on success (invisibly)
