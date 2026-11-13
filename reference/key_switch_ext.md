# Steps of hybrid key switching

Hybrid key switching works in an extended basis `P*Q` and comes back to
`Q` at the end. These functions expose two of its steps, for code that
hoists or defers them (CKKS). `key_switch_ext()` takes a ciphertext to
the extended basis, multiplying its elements by `P`; with
`add_first = FALSE` the first element of the result is left at zero.
`key_switch_down_first_element()` brings only the first element back to
`Q` and returns it as a ring element.
[`key_switch_down()`](https://openfheorg.github.io/openfhe.R/reference/key_switch_down.md)
brings a whole ciphertext back.

## Usage

``` r
key_switch_ext(ct, add_first)

key_switch_down_first_element(ct)
```

## Arguments

- ct:

  A `Ciphertext`.

- add_first:

  Logical.

## Value

`key_switch_ext()`: a `Ciphertext` in the extended basis.
`key_switch_down_first_element()`: a
[DCRTPoly](https://openfheorg.github.io/openfhe.R/reference/DCRTPoly.md).
