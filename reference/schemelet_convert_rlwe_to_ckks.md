# Convert between RLWE and CKKS ciphertexts

`schemelet_convert_rlwe_to_ckks()` embeds an RLWE ciphertext modulo
`big_q` into a CKKS ciphertext with `slots` slots at `level`, so that
[`eval_fbt()`](https://openfheorg.github.io/openfhe.R/reference/eval_fbt_setup.md)
can process it. `schemelet_convert_ckks_to_rlwe()` extracts an RLWE
ciphertext modulo `q` from a CKKS ciphertext. Both ciphertexts are under
the same secret key.

## Usage

``` r
schemelet_convert_rlwe_to_ckks(cc, coeffs, pub_key, big_q, slots, level = 0L)

schemelet_convert_ckks_to_rlwe(ctxt, q)
```

## Arguments

- cc:

  A CKKS `CryptoContext`.

- coeffs:

  A
  [PolyVector](https://openfheorg.github.io/openfhe.R/reference/PolyVector.md);
  the RLWE ciphertext.

- pub_key:

  The `PublicKey`, used for an encryption of zero that supplies the
  metadata of the CKKS ciphertext.

- big_q:

  The modulus of the RLWE ciphertext: a string of decimal digits, or a
  whole number of at most 2^53.

- slots:

  Integer; number of slots of the CKKS ciphertext.

- level:

  Integer; level of the CKKS ciphertext. Default `0L`.

- ctxt:

  A CKKS `Ciphertext` with two elements.

- q:

  The modulus of the RLWE ciphertext to produce, as for `big_q`.

## Value

`schemelet_convert_rlwe_to_ckks()`: a `Ciphertext`.
`schemelet_convert_ckks_to_rlwe()`: a
[PolyVector](https://openfheorg.github.io/openfhe.R/reference/PolyVector.md).

## See also

[`schemelet_encrypt_coeff()`](https://openfheorg.github.io/openfhe.R/reference/schemelet_get_element_params.md),
[`eval_fbt()`](https://openfheorg.github.io/openfhe.R/reference/eval_fbt_setup.md)
