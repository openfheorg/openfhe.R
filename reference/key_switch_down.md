# Scale a ciphertext down from extended CRT basis to Q

Brings a ciphertext that lives in the extended P*Q basis (for example,
the output of
[`eval_fast_rotation_ext()`](https://openfheorg.github.io/openfhe.R/reference/eval_fast_rotation_ext.md)
with hybrid key switching) back to the standard Q basis. Only supported
when the scheme is configured with hybrid key switching — other
key-switching techniques have no round-trip to extended P*Q and
therefore nothing to scale back from.

## Usage

``` r
key_switch_down(ct)
```

## Arguments

- ct:

  A `Ciphertext` in the extended P\*Q basis.

## Value

A `Ciphertext` in the Q basis.

## See also

[`eval_fast_rotation_ext()`](https://openfheorg.github.io/openfhe.R/reference/eval_fast_rotation_ext.md)
