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
