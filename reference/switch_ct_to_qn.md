# Switch a public-key ciphertext to the small modulus and dimension

A ciphertext encrypted under a public key has modulus `Q` and dimension
`N`. `switch_ct_to_qn()` converts it to modulus `q` and dimension `n`,
the form the gates take.

## Usage

``` r
switch_ct_to_qn(ctx, ksk, ct)
```

## Arguments

- ctx:

  A `BinFHEContext`.

- ksk:

  An
  [LWESwitchingKey](https://openfheorg.github.io/openfhe.R/reference/LWESwitchingKey.md),
  from
  [`get_switch_key()`](https://openfheorg.github.io/openfhe.R/reference/get_bt_key.md)
  or
  [`bin_key_switch_gen()`](https://openfheorg.github.io/openfhe.R/reference/bin_key_gen_pair.md).

- ct:

  An `LWECiphertext` of modulus `Q` and dimension `N`.

## Value

An `LWECiphertext`.
