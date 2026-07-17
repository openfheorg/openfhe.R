# Distribute a secret key into shares

Produces the set of shares that party `index` would distribute to the
other parties under the chosen `sharing_scheme`. The returned
`SecretShareMap` is opaque; in a real deployment the shares would be
serialized and routed over the network to each receiving party, and the
receiving parties would store them for use in an abort recovery.

## Usage

``` r
share_keys(cc, sk, n_parties, threshold, index, sharing_scheme = "additive")
```

## Arguments

- cc:

  A `CryptoContext` with the `MULTIPARTY` feature.

- sk:

  The `PrivateKey` to share.

- n_parties:

  Integer; total number of parties.

- threshold:

  Integer; minimum number of shares needed to reconstruct. For
  `"additive"` this must be `n_parties - 1`; for `"shamir"` it is
  typically `floor(n_parties/2) + 1`.

- index:

  Integer; the 1-based index of the party owning `sk` (the "my share
  index").

- sharing_scheme:

  Character; either `"additive"` (default) or `"shamir"`.

## Value

A `SecretShareMap` suitable for passing to
[`recover_shared_key()`](https://openfheorg.github.io/openfhe.R/reference/recover_shared_key.md).

## Details

Two sharing schemes are supported:

- `"additive"` — N-1 threshold; every party must contribute their share
  to reconstruct. Robust against corruption of any single party's
  storage but not against any party dropping out.

- `"shamir"` — `floor(N/2) + 1` threshold; the secret can be
  reconstructed from any majority subset of the distributed shares.
  Robust against up to `floor((N-1)/2)` parties dropping out.

## See also

[`recover_shared_key()`](https://openfheorg.github.io/openfhe.R/reference/recover_shared_key.md)
