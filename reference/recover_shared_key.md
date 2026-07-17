# Recover a secret key from distributed shares

Inverse of
[`share_keys()`](https://openfheorg.github.io/openfhe.R/reference/share_keys.md).
Given a `SecretShareMap` holding at least `threshold` shares,
reconstructs a `PrivateKey` equivalent to the original secret at the
point of sharing. The reconstructed key participates in distributed
decryption identically to the original, so a dropped-out party's share
of a threshold decryption can still be completed by the remaining
parties.

## Usage

``` r
recover_shared_key(
  cc,
  share_map,
  n_parties,
  threshold,
  sharing_scheme = "additive"
)
```

## Arguments

- cc:

  A `CryptoContext`. Used to construct the empty placeholder key that
  the scheme routine fills in.

- share_map:

  A `SecretShareMap` from
  [`share_keys()`](https://openfheorg.github.io/openfhe.R/reference/share_keys.md).

- n_parties:

  Integer; must match the value used at
  [`share_keys()`](https://openfheorg.github.io/openfhe.R/reference/share_keys.md)
  time.

- threshold:

  Integer; must match the value used at
  [`share_keys()`](https://openfheorg.github.io/openfhe.R/reference/share_keys.md)
  time.

- sharing_scheme:

  Character; must match the value used at
  [`share_keys()`](https://openfheorg.github.io/openfhe.R/reference/share_keys.md)
  time.

## Value

A `PrivateKey` holding the reconstructed secret.

## Details

Under the hood, the C++ API takes a mutable `PrivateKey` reference that
must be pre-allocated as an empty `PrivateKeyImpl` bound to `cc`. The R
wrapper constructs that empty placeholder internally so R users do not
have to know about the in-place-fill convention.

## See also

[`share_keys()`](https://openfheorg.github.io/openfhe.R/reference/share_keys.md)
