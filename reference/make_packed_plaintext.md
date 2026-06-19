# Make a packed integer plaintext

Encode an integer vector as a BFV / BGV packed plaintext. The result is
an unencrypted `Plaintext` object that can then be passed to
[`encrypt()`](https://bnaras.github.io/openfhe.R/reference/encrypt.md).

## Usage

``` r
make_packed_plaintext(cc, values, noise_scale_deg = 1L, level = 0L)
```

## Arguments

- cc:

  A `CryptoContext`.

- values:

  An integer vector to pack. Length must not exceed `batch_size` set at
  context creation.

- noise_scale_deg:

  Integer degree of the initial scaling factor applied to the encoded
  plaintext. Defaults to `1L`; only meaningful under `FIXEDMANUAL`
  scaling (under `FLEXIBLEAUTO` the scheme overrides this value — see
  discovery D011). Every current vignette leaves it at the default.

- level:

  Integer target level in the RNS modulus chain. Defaults to `0L`,
  meaning "fresh level, matching a just-encrypted ciphertext". Set to
  match the level of a ciphertext the plaintext will interact with if
  the ciphertext has already been rescaled.

## Value

A `Plaintext`.
