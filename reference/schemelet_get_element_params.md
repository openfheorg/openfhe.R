# RLWE encryption under a CKKS secret key

The RLWE schemelet of OpenFHE (`SchemeletRLWEMP`): integers modulo `p`
are encrypted as the coefficients of an RLWE ciphertext over one large
modulus `q`, under the secret key of a CKKS context. It is the input and
output format of CKKS functional bootstrapping; see
[`eval_fbt()`](https://openfheorg.github.io/openfhe.R/reference/eval_fbt_setup.md).

## Usage

``` r
schemelet_get_element_params(private_key, level = 0L)

schemelet_encrypt_coeff(
  input,
  q,
  p,
  private_key,
  element_params,
  bit_reverse = FALSE
)

schemelet_decrypt_coeff(
  input,
  q,
  p,
  private_key,
  element_params,
  num_slots,
  length = 0L,
  bit_reverse = FALSE
)

schemelet_mod_switch(input, q1, q2)

schemelet_get_q_prime(pub_key, lvls)
```

## Arguments

- private_key:

  A `PrivateKey` of a CKKS context.

- level:

  Integer; number of levels to remove. Default `0L`.

- input:

  For `schemelet_encrypt_coeff()`, a vector of whole numbers, each
  reduced modulo `p` as a signed value. For `schemelet_decrypt_coeff()`
  and `schemelet_mod_switch()`, a
  [PolyVector](https://openfheorg.github.io/openfhe.R/reference/PolyVector.md).

- q, p, q1, q2:

  Moduli: strings of decimal digits, or whole numbers of at most 2^53.
  `q` is the ciphertext modulus and `p` the plaintext modulus.

- element_params:

  An `ElementParams` object from `schemelet_get_element_params()`.

- bit_reverse:

  Logical; encode the input in bit-reversed order (and undo it at
  decryption). Default `FALSE`.

- num_slots:

  Integer; the number of slots used in the CKKS computation, which sets
  the stride between message coefficients.

- length:

  Integer; number of values to return, `0L` (default) for `num_slots`.

- pub_key:

  A `PublicKey` of a CKKS context.

- lvls:

  Integer; number of moduli after `q_0` to include.

## Value

`schemelet_get_element_params()`: an `ElementParams` object.
`schemelet_encrypt_coeff()`: a
[PolyVector](https://openfheorg.github.io/openfhe.R/reference/PolyVector.md).
`schemelet_decrypt_coeff()`: a numeric vector. `schemelet_mod_switch()`:
`input`, invisibly. `schemelet_get_q_prime()`: a string of decimal
digits.

## Details

`schemelet_get_element_params()` returns the element parameters of the
key's context with `level` levels removed. Its modulus is the one
`schemelet_encrypt_coeff()` samples its encryption of zero over.

`schemelet_encrypt_coeff()` encrypts `input` and returns the RLWE
ciphertext modulo `q`. `schemelet_decrypt_coeff()` decrypts one,
returning values in `(-p/2, p/2]`.

`schemelet_mod_switch()` switches a ciphertext from modulus `q2` to
modulus `q1` in place, scaling by `q1/q2` with rounding.

`schemelet_get_q_prime()` returns the product `q_0 * q_1 * ... * q_lvls`
of the first `lvls + 1` RNS moduli of the key's parameters.

## See also

[`schemelet_convert_rlwe_to_ckks()`](https://openfheorg.github.io/openfhe.R/reference/schemelet_convert_rlwe_to_ckks.md)

## Examples

``` r
cc <- fhe_context("CKKS", multiplicative_depth = 2L, scaling_mod_size = 50L,
                  batch_size = 8L)
keys <- key_gen(cc)
ep <- schemelet_get_element_params(keys@secret)
q <- "1152921504606846976"   # 2^60
ct <- schemelet_encrypt_coeff(c(1, 2, 3, 4, 5, 6, 7, 0), q, 16,
                              keys@secret, ep)
schemelet_decrypt_coeff(ct, q, 16, keys@secret, ep, num_slots = 8L)
#> [1] 1 2 3 4 5 6 7 0
```
