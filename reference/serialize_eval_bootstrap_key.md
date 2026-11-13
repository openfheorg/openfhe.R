# Serialize the keys CKKS bootstrapping uses

`serialize_eval_bootstrap_key()` writes to a file the automorphism keys
that bootstrapping with `slots` slots uses, out of those registered for
`cc` under `key_tag`. `deserialize_eval_bootstrap_key()` reads such a
file into the registry: with `cc` and `slots`, the keys that
bootstrapping setup asks for; without `cc`, the keys with the
automorphism indices in `index_list`.

## Usage

``` r
serialize_eval_bootstrap_key(filename, cc, key_tag, slots, format = "binary")

deserialize_eval_bootstrap_key(
  filename,
  cc = NULL,
  key_tag,
  slots = NULL,
  index_list = NULL,
  format = "binary"
)
```

## Arguments

- filename:

  Path to the file.

- cc:

  A `CryptoContext` on which
  [`eval_bootstrap_setup()`](https://openfheorg.github.io/openfhe.R/reference/eval_bootstrap_setup.md)
  has been called. For `deserialize_eval_bootstrap_key()`, `NULL` to
  select keys by `index_list`.

- key_tag:

  Character string; the key tag.

- slots:

  Integer; the number of slots.

- format:

  "binary" (default) or "json"

- index_list:

  Integer vector of automorphism indices; used when `cc` is `NULL`.

## Value

`TRUE` on success, `FALSE` otherwise.
