# Precompute the plaintexts of CKKS bootstrapping

Computes and stores the encoding and decoding plaintexts that
bootstrapping uses.
[`eval_bootstrap_setup()`](https://openfheorg.github.io/openfhe.R/reference/eval_bootstrap_setup.md)
does this itself unless it is called with `precompute = FALSE`; this
function does it afterwards.

## Usage

``` r
eval_bootstrap_precompute(cc, slots = 0L)
```

## Arguments

- cc:

  A `CryptoContext`.

- slots:

  Integer; the number of slots to be bootstrapped. Default `0L`.

## Value

`cc`, invisibly.

## Details

After a setup with `precompute = FALSE`, call this function before
[`eval_bootstrap()`](https://openfheorg.github.io/openfhe.R/reference/eval_bootstrap.md).
At OpenFHE 1.6.1 the library does not check that the plaintexts exist,
and bootstrapping without them ends the R session.

## See also

[`eval_bootstrap_setup()`](https://openfheorg.github.io/openfhe.R/reference/eval_bootstrap_setup.md),
[`clear_bootstrap_precom()`](https://openfheorg.github.io/openfhe.R/reference/clear_all_ckks_caches.md)
