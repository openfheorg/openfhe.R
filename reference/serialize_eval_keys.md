# Serialize evaluation keys from the key registry

Writes the registered multiplication, automorphism or summation keys to
a file, or, with `filename = NULL`, returns them serialized in memory.
The keys are those under `key_tag`, or, when `cc` is given, those of
that context.

## Usage

``` r
serialize_eval_keys(
  filename = NULL,
  type = c("mult", "automorphism", "sum"),
  format = "binary",
  key_tag = "",
  cc = NULL
)
```

## Arguments

- filename:

  Path to the output file, or `NULL` (default) to serialize in memory.

- type:

  `"mult"`, `"automorphism"` or `"sum"`.

- format:

  "binary" (default) or "json"

- key_tag:

  Key tag; `""` (default) for the keys of every tag.

- cc:

  A `CryptoContext`, or `NULL` (default). When given, `key_tag` is not
  used.

## Value

With a file name, `TRUE` invisibly. Otherwise a raw vector
(`format = "binary"`) or a character string (`format = "json"`).

## See also

[`deserialize_eval_keys()`](https://openfheorg.github.io/openfhe.R/reference/deserialize_eval_keys.md),
[`deserialize_eval_keys_string()`](https://openfheorg.github.io/openfhe.R/reference/deserialize_eval_keys_string.md)
