# Mutable arithmetic on two ciphertexts, in place

The result of `ct1 + ct2`, `ct1 - ct2` or `ct1 * ct2` replaces the
contents of `ct1`. As in the other mutable forms
([`eval_add_mutable()`](https://openfheorg.github.io/openfhe.R/reference/eval_add_mutable.md)),
the library may also adjust `ct2`.

## Usage

``` r
eval_add_mutable_in_place(ct1, ct2)

eval_sub_mutable_in_place(ct1, ct2)

eval_mult_mutable_in_place(ct1, ct2)
```

## Arguments

- ct1:

  A `Ciphertext`; receives the result.

- ct2:

  A `Ciphertext`; may be modified.

## Value

`ct1`, invisibly.
