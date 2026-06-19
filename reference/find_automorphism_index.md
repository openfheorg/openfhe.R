# Compute the automorphism index for a single slot index

Maps a CKKS slot index to the corresponding automorphism index in the
cyclotomic ring `Z[X]/(X^N + 1)`. The automorphism group of the ring is
isomorphic to the multiplicative group `(Z/2N)*`; this function returns
the representative of that group that corresponds to rotating the
plaintext slots by the given amount.

## Usage

``` r
find_automorphism_index(cc, index)
```

## Arguments

- cc:

  A `CryptoContext`.

- index:

  Integer; the slot index (positive = left rotation, negative = right
  rotation).

## Value

Integer; the automorphism group element corresponding to that rotation.

## Details

Used as a primitive by
[`find_automorphism_indices()`](https://bnaras.github.io/openfhe.R/reference/find_automorphism_indices.md)
and by code that needs to address automorphism keys directly (for
example, selectively generating eval keys for a sparse set of rotation
amounts).

**R-first binding**: `openfhe-python` does not bind
`FindAutomorphismIndex`. Logged in `notes/upstream-defects.md` under
R-only surface.

## See also

[`find_automorphism_indices()`](https://bnaras.github.io/openfhe.R/reference/find_automorphism_indices.md)
for the vector form.
