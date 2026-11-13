# Fill scheme-switching parameters from a CKKS context

Copies the first modulus, the ring dimension, the scaling modulus size
and the batch size of `cc` into `params`, and marks `params` as filled.
[`eval_ckks_to_fhew_setup()`](https://openfheorg.github.io/openfhe.R/reference/eval_ckks_to_fhew_setup.md)
and
[`eval_scheme_switching_setup()`](https://openfheorg.github.io/openfhe.R/reference/eval_scheme_switching_setup.md)
do this themselves.

## Usage

``` r
set_params_from_ckks_cryptocontext(cc, params)
```

## Arguments

- cc:

  A CKKS `CryptoContext`.

- params:

  A
  [SchSwchParams](https://openfheorg.github.io/openfhe.R/reference/SchSwchParams.md)
  object; changed in place.

## Value

`params`, invisibly.
