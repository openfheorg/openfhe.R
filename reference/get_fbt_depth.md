# Multiplicative depth of functional bootstrapping

`get_fbt_depth()` gives the depth
[`eval_fbt()`](https://openfheorg.github.io/openfhe.R/reference/eval_fbt_setup.md)
consumes for a look-up table, and `get_fefbt_depth()` the depth
[`eval_fe_func_bootstrap()`](https://openfheorg.github.io/openfhe.R/reference/eval_fe_func_bootstrap_setup.md)
consumes for a Fourier series. Add the levels wanted after bootstrapping
to get the `multiplicative_depth` of the context.

## Usage

``` r
get_fbt_depth(
  level_budget,
  coefficients,
  p_input,
  order,
  skd,
  first_mod_size = 60L
)

get_fefbt_depth(
  level_budget,
  coefficients,
  skd = SecretKeyDist$SPARSE_TERNARY,
  first_mod_size = 60L
)
```

## Arguments

- level_budget:

  Integer vector of length 2; the levels spent on the
  coefficients-to-slots and slots-to-coefficients transforms.

- coefficients:

  The coefficients of the look-up table (as for
  [`eval_fbt()`](https://openfheorg.github.io/openfhe.R/reference/eval_fbt_setup.md))
  or of the Fourier series.

- p_input:

  The input plaintext modulus: a string of decimal digits, or a whole
  number of at most 2^53.

- order:

  Integer; the order of the Hermite interpolation.

- skd:

  Secret key distribution, an element of
  [SecretKeyDist](https://openfheorg.github.io/openfhe.R/reference/SecretKeyDist.md).

- first_mod_size:

  Integer; size of the first modulus in bits (read only for
  `SecretKeyDist$SPARSE_ENCAPSULATED`). Default `60L`.

## Value

An integer.
