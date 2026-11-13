# CKKS functional bootstrapping of a look-up table

Functional bootstrapping refreshes a ciphertext and applies a look-up
table to the encrypted integers in the same step. The input is an RLWE
ciphertext converted to CKKS with
[`schemelet_convert_rlwe_to_ckks()`](https://openfheorg.github.io/openfhe.R/reference/schemelet_convert_rlwe_to_ckks.md),
and the output goes back with
[`schemelet_convert_ckks_to_rlwe()`](https://openfheorg.github.io/openfhe.R/reference/schemelet_convert_rlwe_to_ckks.md).

## Usage

``` r
eval_fbt_setup(
  cc,
  coeffs,
  num_slots,
  p_in,
  p_out,
  big_q,
  pub_key,
  dim1,
  level_budget,
  lvls_after_boot = 0L,
  depth_leveled_computation = 0L,
  order = 1L
)

eval_fbt(
  ct,
  coeffs,
  digit_bit_size,
  initial_scaling,
  post_scaling,
  level_to_reduce = 0L,
  order = 1L
)

eval_fbt_no_decoding(ct, coeffs, digit_bit_size, initial_scaling, order = 1L)

eval_hom_decoding(ct, post_scaling, level_to_reduce = 0L)
```

## Arguments

- cc:

  A CKKS `CryptoContext` with `Feature$FHE` enabled.

- coeffs:

  The coefficients of the look-up table; see Details.

- num_slots:

  Integer; number of CKKS slots.

- p_in, p_out:

  Input and output plaintext moduli.

- big_q:

  The modulus of the RLWE ciphertext converted to CKKS.

- pub_key:

  The `PublicKey`.

- dim1:

  Integer vector of length 2; baby-step dimensions of the two linear
  transforms (`0` for the library's choice).

- level_budget:

  Integer vector of length 2; level budgets of the two linear
  transforms.

- lvls_after_boot:

  Integer; levels available after bootstrapping. Default `0L`.

- depth_leveled_computation:

  Integer; levels of the computation done between
  `eval_fbt_no_decoding()` (or
  [`eval_mvb_no_decoding()`](https://openfheorg.github.io/openfhe.R/reference/eval_mvb_precompute.md))
  and `eval_hom_decoding()`. Default `0L`.

- order:

  Integer; order of the Hermite interpolation. Default `1L`.

- ct:

  A `Ciphertext`.

- digit_bit_size:

  Integer; number of bits of the input modulus.

- initial_scaling:

  The modulus the input is scaled by, usually
  [`get_modulus()`](https://openfheorg.github.io/openfhe.R/reference/get_modulus.md)
  of the element parameters from
  [`schemelet_get_element_params()`](https://openfheorg.github.io/openfhe.R/reference/schemelet_get_element_params.md).

- post_scaling:

  The scale applied to the coefficients (the `scale` of
  [`get_hermite_trig_coefficients()`](https://openfheorg.github.io/openfhe.R/reference/get_hermite_trig_coefficients.md)),
  undone here.

- level_to_reduce:

  Integer; levels to drop before decoding. Default `0L`.

## Value

`eval_fbt_setup()`: `cc`, invisibly. The others: a `Ciphertext`.

## Details

`eval_fbt_setup()` prepares the context; call
[`eval_bootstrap_key_gen()`](https://openfheorg.github.io/openfhe.R/reference/eval_bootstrap_key_gen.md)
and
[`eval_mult_key_gen()`](https://openfheorg.github.io/openfhe.R/reference/eval_mult_key_gen.md)
after it. `eval_fbt()` applies the table. `eval_fbt_no_decoding()` stops
before the return to coefficient encoding, leaving a slot-packed CKKS
ciphertext on which leveled operations can be done;
`eval_hom_decoding()` then finishes.

The R type of `coeffs` selects the form of the table, as the Python type
does in openfhe-python. An integer vector is the optimized Boolean case
(input modulus 2, order 1), with the two coefficients
`c(f(1), f(0) - f(1))`; build it with
[`as.integer()`](https://rdrr.io/r/base/integer.html). A double or
complex vector is the general case, with the coefficients from
[`get_hermite_trig_coefficients()`](https://openfheorg.github.io/openfhe.R/reference/get_hermite_trig_coefficients.md).

`p_in`, `p_out`, `big_q`, `initial_scaling` and `post_scaling` are
strings of decimal digits, or whole numbers of at most 2^53.

## See also

[`eval_mvb_precompute()`](https://openfheorg.github.io/openfhe.R/reference/eval_mvb_precompute.md)
to apply several tables to one input;
[`get_fbt_depth()`](https://openfheorg.github.io/openfhe.R/reference/get_fbt_depth.md).
