# Arithmetic without the library's operand checks

These call the C++ functions of the same names, which skip the checks
OpenFHE normally makes on its operands (same context, same key,
compatible levels) and do not adjust levels or scales. They are for code
that has already established those conditions; with operands that do not
meet them the result is not meaningful. Use
[`eval_add_in_place()`](https://openfheorg.github.io/openfhe.R/reference/eval_add_in_place.md),
[`eval_mult()`](https://openfheorg.github.io/openfhe.R/reference/eval_mult.md)
and
[`eval_mult_no_relin()`](https://openfheorg.github.io/openfhe.R/reference/eval_mult_no_relin.md)
otherwise.

## Usage

``` r
eval_add_in_place_no_check(ct1, ct2)

eval_mult_no_check(ct, scalar)

eval_mult_no_relin_no_check(ct1, ct2)
```

## Arguments

- ct1, ct:

  A `Ciphertext`.

- ct2:

  A `Ciphertext`.

- scalar:

  A whole number of at most 2^53, or a string of decimal digits for a
  larger value.

## Value

`eval_add_in_place_no_check()` returns `ct1`, invisibly; the other two
return a new `Ciphertext`.

## Details

`eval_add_in_place_no_check()` adds `ct2` into `ct1`.
`eval_mult_no_check()` multiplies every element of a ciphertext by an
integer scalar. `eval_mult_no_relin_no_check()` returns the tensor
product of the elements of two ciphertexts, without relinearizing. That
is their product in CKKS for two ciphertexts at the same level and
scale. It is not the BFV product, which includes a scaling step this
function does not perform.
