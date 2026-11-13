# An RLWE ciphertext

The pair `{b, a}` of polynomials over one large modulus that the
`schemelet_` functions produce and consume. The class is an opaque
handle, as in openfhe-python. `PolyVector()` makes an empty one.

## Usage

``` r
PolyVector(ptr = NULL)

switch_modulus(x, modulus)
```

## Arguments

- ptr:

  External pointer (internal use). `NULL` (default) makes an empty
  vector.

- x:

  A `PolyVector`.

- modulus:

  The new modulus: a string of decimal digits, or a whole number of at
  most 2^53.

## Value

`PolyVector()`: an S7 object of class `PolyVector`, inheriting from
[OpenFHEObject](https://openfheorg.github.io/openfhe.R/reference/OpenFHEObject.md).
`switch_modulus()`: `x`, invisibly.

## Details

[`length()`](https://rdrr.io/r/base/length.html) gives the number of
polynomials.
[`clone()`](https://openfheorg.github.io/openfhe.R/reference/clone.md)
returns a copy. `switch_modulus()` changes the modulus of every
polynomial in place, keeping the residues, and `x - y` subtracts two
ciphertexts element by element.

[`schemelet_mod_switch()`](https://openfheorg.github.io/openfhe.R/reference/schemelet_get_element_params.md)
and `switch_modulus()` change the object they are given. Assigning a
`PolyVector` to another name does not copy it; use
[`clone()`](https://openfheorg.github.io/openfhe.R/reference/clone.md)
for a copy that later changes do not reach.

## See also

[`schemelet_encrypt_coeff()`](https://openfheorg.github.io/openfhe.R/reference/schemelet_get_element_params.md)
