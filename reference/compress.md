# Compress a ciphertext to fewer towers

Truncates the ciphertext's RNS modulus representation to `towers_left`
towers and sets its noise-scale-degree to `noise_scale_deg`. Used by the
interactive multi-party bootstrapping protocol to shrink a ciphertext
before sending it across the network.

## Usage

``` r
compress(x, ...)
```

## Arguments

- x:

  A `Ciphertext`.

- ...:

  Method-specific arguments: `towers_left` (integer, target tower count,
  default `1L`), `noise_scale_deg` (integer, default `1L`).

## Value

A compressed `Ciphertext`.
