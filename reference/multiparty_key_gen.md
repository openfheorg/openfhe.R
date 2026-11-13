# Generate a key pair for a secondary party in threshold FHE

The lead party uses
[`key_gen()`](https://openfheorg.github.io/openfhe.R/reference/key_gen.md)
to generate the initial keypair. Subsequent parties call this with the
lead's public key.

## Usage

``` r
multiparty_key_gen(cc, lead_pk, make_sparse = FALSE, fresh = FALSE)
```

## Arguments

- cc:

  A CryptoContext (must have MULTIPARTY feature enabled)

- lead_pk:

  The lead party's PublicKey, or a list of `PrivateKey` objects for the
  form that combines secret keys.

- make_sparse:

  Logical; if `TRUE`, produce an LWE-sparse secret. Default `FALSE` to
  match the C++ header default. RLWE-only semantics; BFV/BGV/CKKS accept
  both values.

- fresh:

  Logical; if `TRUE`, sample a fresh secret rather than deriving one
  from the existing key material. Default `FALSE`.

## Value

A KeyPair for this party, or, for a list of secret keys, the key pair of
the combined secret.

## Details

OpenFHE declares a second form that takes the secret keys of all parties
and returns the key pair of their sum. Pass a list of `PrivateKey`
objects as `lead_pk` to call it; `make_sparse` and `fresh` do not apply
to that form.
