# Map of secret-key shares for threshold-FHE abort recovery

Opaque S7 wrapper around a
`shared_ptr<std::unordered_map<uint32_t, DCRTPoly>>`. Produced by
[`share_keys()`](https://bnaras.github.io/openfhe.R/reference/share_keys.md)
— each call returns one party's contribution to the distributed shares
of their own secret key. Consumed by
[`recover_shared_key()`](https://bnaras.github.io/openfhe.R/reference/recover_shared_key.md),
which reconstructs the original secret from `threshold` or more shares
when a party drops out.

## Usage

``` r
SecretShareMap(ptr = NULL)
```

## Arguments

- ptr:

  External pointer (internal use).

## Details

The map is keyed by party index (1-based uint32). Users do not index
into it directly; it is a transport format for the secret-sharing
protocol.
