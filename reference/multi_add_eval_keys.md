# Combine evaluation keys from multiple parties

Combines two partial key-switching eval keys into a joint eval key. See
[`multi_add_eval_mult_keys()`](https://bnaras.github.io/openfhe.R/reference/multi_add_eval_mult_keys.md)
for the eval-mult variant — the two functions consume keys produced by
different generators and are not interchangeable.

## Usage

``` r
multi_add_eval_keys(cc, ek1, ek2, key_tag = "")
```

## Arguments

- cc:

  A CryptoContext

- ek1, ek2:

  EvalKey objects to combine

- key_tag:

  Character; optional tag to associate with the combined key. Default
  `""`.

## Value

A combined EvalKey
