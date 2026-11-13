# Proxy re-encryption

`re_key_gen()` makes a re-encryption key from one party's secret key and
another party's public key. With it, `re_encrypt()` turns a ciphertext
under the first party's key into one the second party can decrypt,
without decrypting it. The context needs `Feature$PRE`.

## Usage

``` r
re_key_gen(cc, old_private_key, new_public_key)

re_encrypt(ct, eval_key, public_key = NULL)
```

## Arguments

- cc:

  A `CryptoContext`.

- old_private_key:

  The `PrivateKey` the ciphertexts are currently encrypted under.

- new_public_key:

  The `PublicKey` of the party who is to decrypt.

- ct:

  A `Ciphertext`.

- eval_key:

  The `EvalKey` from `re_key_gen()`.

- public_key:

  The `PublicKey` of the party the ciphertext is currently encrypted
  for, or `NULL` (default). It is used to re-randomize the result in the
  security modes that require it.

## Value

`re_key_gen()` returns an `EvalKey`; `re_encrypt()` a `Ciphertext`.
