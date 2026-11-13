# Moduli of an LWE ciphertext

[`get_modulus()`](https://openfheorg.github.io/openfhe.R/reference/get_modulus.md)
of an `LWECiphertext` is its ciphertext modulus, and `get_pt_modulus()`
its plaintext modulus. `set_modulus()` and `set_pt_modulus()` change the
values recorded in the ciphertext, in place; they do not rescale it.

## Usage

``` r
get_pt_modulus(ct)

set_modulus(ct, modulus)

set_pt_modulus(ct, plaintext_modulus)
```

## Arguments

- ct:

  An `LWECiphertext`.

- modulus, plaintext_modulus:

  The new value: a whole number of at most 2^53, or a string of decimal
  digits.

## Value

`get_pt_modulus()`: a number, or a string of decimal digits if the value
is above 2^53. The setters: `ct`, invisibly.

## Details

[`get_modulus()`](https://openfheorg.github.io/openfhe.R/reference/get_modulus.md)
and
[`get_length()`](https://openfheorg.github.io/openfhe.R/reference/plaintext_accessors.md)
also work on an `LWEPrivateKey` and an `LWEPublicKey`, and `==` and `!=`
compare two LWE ciphertexts, two secret keys or two public keys by
content.
