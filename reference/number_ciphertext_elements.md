# The ring elements of a ciphertext

A ciphertext is a list of ring elements: two when fresh, three after a
multiplication that has not been relinearized.

## Usage

``` r
number_ciphertext_elements(ct)

get_elements(ct)

get_elements_mutable(ct)

set_elements(ct, elements)

set_elements_move(ct, elements)

remove_element(ct, index)
```

## Arguments

- ct:

  A `Ciphertext`.

- elements:

  A list of
  [DCRTPoly](https://openfheorg.github.io/openfhe.R/reference/DCRTPoly.md)
  objects.

- index:

  Integer; which element to remove, counting from 1.

## Value

`number_ciphertext_elements()`: an integer. `get_elements()` and
`get_elements_mutable()`: a list of `DCRTPoly` objects. The others
return `ct`, invisibly.

## Details

`number_ciphertext_elements()` counts them. `get_elements()` returns
copies of them as a list of
[DCRTPoly](https://openfheorg.github.io/openfhe.R/reference/DCRTPoly.md)
handles, and `set_elements()` replaces the elements of a ciphertext with
copies of the ones given. `remove_element()` deletes one.
`get_elements_mutable()` and `set_elements_move()` are the names
openfhe-python gives to the same two operations; in R, as in Python,
they exchange copies.
