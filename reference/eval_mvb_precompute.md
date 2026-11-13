# Several look-up tables on one input (multi-value bootstrapping)

`eval_mvb_precompute()` does the part of functional bootstrapping that
does not depend on the table: it computes the complex exponential of the
input and its powers. `eval_mvb()` and `eval_mvb_no_decoding()` then
apply a table to that precomputation, as
[`eval_fbt()`](https://openfheorg.github.io/openfhe.R/reference/eval_fbt_setup.md)
and
[`eval_fbt_no_decoding()`](https://openfheorg.github.io/openfhe.R/reference/eval_fbt_setup.md)
do to a ciphertext. Every table applied to one precomputation must have
the input modulus and order of the coefficients the precomputation was
made with.

## Usage

``` r
eval_mvb_precompute(ct, coeffs, digit_bit_size, initial_scaling, order = 1L)

eval_mvb(
  ciphertexts,
  coeffs,
  digit_bit_size,
  post_scaling,
  level_to_reduce = 0L,
  order = 1L
)

eval_mvb_no_decoding(ciphertexts, coeffs, digit_bit_size, order = 1L)
```

## Arguments

- ct:

  A `Ciphertext`.

- coeffs:

  The coefficients of the look-up table; see Details.

- digit_bit_size:

  Integer; number of bits of the input modulus.

- initial_scaling:

  The modulus the input is scaled by, usually
  [`get_modulus()`](https://openfheorg.github.io/openfhe.R/reference/get_modulus.md)
  of the element parameters from
  [`schemelet_get_element_params()`](https://openfheorg.github.io/openfhe.R/reference/schemelet_get_element_params.md).

- order:

  Integer; order of the Hermite interpolation. Default `1L`.

- ciphertexts:

  A
  [SeriesPowers](https://openfheorg.github.io/openfhe.R/reference/SeriesPowers.md)
  object from `eval_mvb_precompute()`.

- post_scaling:

  The scale applied to the coefficients (the `scale` of
  [`get_hermite_trig_coefficients()`](https://openfheorg.github.io/openfhe.R/reference/get_hermite_trig_coefficients.md)),
  undone here.

- level_to_reduce:

  Integer; levels to drop before decoding. Default `0L`.

## Value

`eval_mvb_precompute()`: a
[SeriesPowers](https://openfheorg.github.io/openfhe.R/reference/SeriesPowers.md)
object. The others: a `Ciphertext`.

## See also

[`eval_fbt_setup()`](https://openfheorg.github.io/openfhe.R/reference/eval_fbt_setup.md),
[`eval_hom_decoding()`](https://openfheorg.github.io/openfhe.R/reference/eval_fbt_setup.md)
