# Key tag accessors

Every `PublicKey` / `PrivateKey` carries a string "key tag" identifying
which key pair it belongs to. The tag is set at key-generation time by
OpenFHE and can be inspected or overwritten via these accessors. In
threshold / multiparty protocols the tag is used to associate a key with
the party that owns it; in single-user protocols it is typically left at
its default.

## Usage

``` r
get_key_tag(key, ...)

set_key_tag(key, ...)
```

## Arguments

- key:

  A `PublicKey` or `PrivateKey`.

- ...:

  Reserved for future method-specific arguments. `set_key_tag` accepts a
  `value` argument here.

## Value

`get_key_tag`: character scalar. `set_key_tag`: the key invisibly.
