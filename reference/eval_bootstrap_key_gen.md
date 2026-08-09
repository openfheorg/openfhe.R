# Generate bootstrapping keys

Generate bootstrapping keys

## Usage

``` r
eval_bootstrap_key_gen(cc, sk, slots)
```

## Arguments

- cc:

  A CryptoContext

- sk:

  A PrivateKey

- slots:

  Number of slots

## Value

Invisibly, the `cc` crypto context that was passed in. Called for its
side effect: the rotation and evaluation keys bootstrapping needs are
generated from `sk` and stored inside the C++ context, after which
[`eval_bootstrap()`](https://openfheorg.github.io/openfhe.R/reference/eval_bootstrap.md)
can be called.
