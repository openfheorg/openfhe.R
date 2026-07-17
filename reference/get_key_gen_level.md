# Key-generation level of a CryptoContext

Integer level at which subsequent
[`key_gen()`](https://openfheorg.github.io/openfhe.R/reference/key_gen.md)
calls will generate keys. Defaults to `0L`. Useful when generating keys
at a non-fresh level for deep circuit protocols.

## Usage

``` r
get_key_gen_level(cc, ...)
```

## Arguments

- cc:

  A `CryptoContext`.

- ...:

  Reserved for future method-specific arguments.

## Value

Integer.
