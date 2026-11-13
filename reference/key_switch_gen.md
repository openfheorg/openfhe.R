# Switch a ciphertext from one secret key to another

`key_switch_gen()` makes the key that switches ciphertexts under
`old_private_key` to ciphertexts under `new_private_key`. `key_switch()`
applies it and returns the switched ciphertext; `key_switch_in_place()`
switches the ciphertext it is given.

## Usage

``` r
key_switch_gen(cc, old_private_key, new_private_key)

key_switch(ct, eval_key)

key_switch_in_place(ct, eval_key)
```

## Arguments

- cc:

  A `CryptoContext`.

- old_private_key, new_private_key:

  `PrivateKey` objects.

- ct:

  A `Ciphertext`.

- eval_key:

  The `EvalKey` from `key_switch_gen()`.

## Value

`key_switch_gen()`: an `EvalKey`. `key_switch()`: a `Ciphertext`.
`key_switch_in_place()`: `ct`, invisibly.

## See also

[`re_key_gen()`](https://openfheorg.github.io/openfhe.R/reference/re_key_gen.md)
for the form that needs only the public key of the receiving party.
