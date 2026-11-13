# Modulus and representation of a plaintext's element

`get_element_modulus()` returns the modulus of the ring element that
encodes the plaintext, as a string of decimal digits. `set_format()`
converts that element between the evaluation and coefficient
representations.

## Usage

``` r
get_element_modulus(pt)

set_format(pt, format)
```

## Arguments

- pt:

  A `Plaintext`.

- format:

  A member of
  [Format](https://openfheorg.github.io/openfhe.R/reference/Format.md).

## Value

`get_element_modulus()`: a character string of decimal digits.
`set_format()`: `pt`, invisibly.

## See also

[`get_modulus()`](https://openfheorg.github.io/openfhe.R/reference/get_modulus.md)
