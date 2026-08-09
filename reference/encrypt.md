# Encrypt a plaintext

`encrypt` dispatches on both the key type and the plaintext. The
`(PublicKey, Plaintext)` method performs public-key encryption and is
the canonical path used by every vignette. The `(PrivateKey, Plaintext)`
method performs symmetric / secret-key encryption using the private key
directly; it is useful in protocols that want the secret key to serve as
both encryption and decryption key (e.g. one-party tests, single-user
benchmarks).

## Usage

``` r
encrypt(key, pt, ...)
```

## Arguments

- key:

  A `PublicKey` or `PrivateKey`.

- pt:

  A `Plaintext`.

- ...:

  Additional arguments (`cc = CryptoContext` is required).

## Value

A `Ciphertext`.

## Examples

``` r
cc <- fhe_context("CKKS", multiplicative_depth = 2L,
                  scaling_mod_size = 50L, batch_size = 8L)
kp <- key_gen(cc, eval_mult = TRUE)
pt <- make_ckks_packed_plaintext(cc, c(0.5, 1.5, 2.5, 3.5))

## Public-key encryption -- the usual path, and the one that lets a
## party encrypt without holding the secret key:
ct <- encrypt(kp@public, pt, cc = cc)
ct
#> <Ciphertext> [active]

## Symmetric encryption with the secret key, for protocols where the
## same party encrypts and decrypts:
ct2 <- encrypt(kp@secret, pt, cc = cc)
ct2
#> <Ciphertext> [active]
```
