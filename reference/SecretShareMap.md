# Map of secret-key shares for threshold-FHE abort recovery

Opaque S7 wrapper around a
`shared_ptr<std::unordered_map<uint32_t, DCRTPoly>>`. Produced by
[`share_keys()`](https://openfheorg.github.io/openfhe.R/reference/share_keys.md)
— each call returns one party's contribution to the distributed shares
of their own secret key. Consumed by
[`recover_shared_key()`](https://openfheorg.github.io/openfhe.R/reference/recover_shared_key.md),
which reconstructs the original secret from `threshold` or more shares
when a party drops out.

## Usage

``` r
SecretShareMap(ptr = NULL)
```

## Arguments

- ptr:

  External pointer (internal use).

## Value

An S7 object of class `SecretShareMap`, inheriting from
[OpenFHEObject](https://openfheorg.github.io/openfhe.R/reference/OpenFHEObject.md),
whose `ptr` property holds an external pointer to the C++
`std::unordered_map<uint32_t, DCRTPoly>`. It carries one share per party
index and acts as the transport format for the threshold-FHE
abort-recovery protocol; it is produced by
[`share_keys()`](https://openfheorg.github.io/openfhe.R/reference/share_keys.md)
rather than by calling this constructor directly.

## Details

The map is keyed by party index (1-based uint32). Users do not index
into it directly; it is a transport format for the secret-sharing
protocol.
