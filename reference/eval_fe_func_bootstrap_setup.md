# CKKS functional bootstrapping of a Fourier series

Refreshes a ciphertext and evaluates on its values the function whose
Fourier coefficients are `coefficients`, in the same step (CKKS with
`CKKSDataType$COMPLEX`).

## Usage

``` r
eval_fe_func_bootstrap_setup(
  cc,
  level_budget = c(5L, 4L),
  dim1 = c(0L, 0L),
  slots = 0L
)

eval_fe_func_bootstrap(ct, coefficients)

eval_fe_func_bootstrap_precompute(ct, coefficients)

eval_fe_func_bootstrap_with_precomp(powers, coefficients)
```

## Arguments

- cc:

  A CKKS `CryptoContext` with `Feature$FHE` enabled.

- level_budget:

  Integer vector of length 2. Default `c(5L, 4L)`.

- dim1:

  Integer vector of length 2. Default `c(0L, 0L)`.

- slots:

  Integer; number of slots, `0L` (default) for full packing.

- ct:

  A `Ciphertext`.

- coefficients:

  Numeric or complex vector of Fourier coefficients.

- powers:

  A
  [SeriesPowers](https://openfheorg.github.io/openfhe.R/reference/SeriesPowers.md)
  object from `eval_fe_func_bootstrap_precompute()`.

## Value

`eval_fe_func_bootstrap_setup()`: `cc`, invisibly.
`eval_fe_func_bootstrap_precompute()`: a
[SeriesPowers](https://openfheorg.github.io/openfhe.R/reference/SeriesPowers.md)
object. The others: a `Ciphertext`.

## Details

`eval_fe_func_bootstrap_setup()` prepares the context; call
[`eval_bootstrap_key_gen()`](https://openfheorg.github.io/openfhe.R/reference/eval_bootstrap_key_gen.md)
after it. `eval_fe_func_bootstrap()` does the whole evaluation.
`eval_fe_func_bootstrap_precompute()` and
`eval_fe_func_bootstrap_with_precomp()` split it, so that several series
of the same length can be evaluated on one input.

The setup shares the bootstrapping precomputation of the context for
`slots` with
[`eval_bootstrap_setup()`](https://openfheorg.github.io/openfhe.R/reference/eval_bootstrap_setup.md)
and
[`eval_fbt_setup()`](https://openfheorg.github.io/openfhe.R/reference/eval_fbt_setup.md):
a context holds one of the three per slot count.

## See also

[`get_fefbt_depth()`](https://openfheorg.github.io/openfhe.R/reference/get_fbt_depth.md)
