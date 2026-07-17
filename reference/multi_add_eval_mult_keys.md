# Combine partial eval-mult keys from multiple parties

The eval-mult flavor of
[`multi_add_eval_keys()`](https://openfheorg.github.io/openfhe.R/reference/multi_add_eval_keys.md).
Consumes keys produced by a multi-party eval-mult key generator rather
than by
[`multi_key_switch_gen()`](https://openfheorg.github.io/openfhe.R/reference/multi_key_switch_gen.md).
Where the R generator is not yet exposed, the wrapper still lets
downstream code exercise the add-keys flow against keys constructed
through the underlying cpp11 binding.

## Usage

``` r
multi_add_eval_mult_keys(cc, ek1, ek2, key_tag = "")
```

## Arguments

- cc:

  A CryptoContext

- ek1, ek2:

  EvalKey objects (eval-mult partials) to combine

- key_tag:

  Character; optional tag to associate with the combined key. Default
  `""`.

## Value

A combined EvalKey
