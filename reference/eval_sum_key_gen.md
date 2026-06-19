# Generate sum keys for a secret key

Populates the `CryptoContext`'s internal sum-key registry (keyed by the
secret key's tag) so that
[`eval_sum()`](https://bnaras.github.io/openfhe.R/reference/eval_sum.md)
and the multi-party sum-key protocol can consume the generated entries.
Closes a long-standing gap: the underlying
`CryptoContext__EvalSumKeyGen` cpp11 binding has been present since the
early phases but had no standalone R wrapper — users had to go through
[`key_gen()`](https://bnaras.github.io/openfhe.R/reference/key_gen.md)'s
side-effects only. The wrapper lands so that the multi-party sum-key
flow (which needs to call this on each party's secret share) has a
direct R-level entry point.

## Usage

``` r
eval_sum_key_gen(cc, sk)
```

## Arguments

- cc:

  A `CryptoContext`.

- sk:

  A `PrivateKey` whose tag will be used to key the generated sum-key map
  in the cc's internal registry.

## Value

`NULL`, invisibly.
