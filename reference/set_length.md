# Set the effective length of a plaintext

Set the effective length of a plaintext

## Usage

``` r
set_length(pt, len)
```

## Arguments

- pt:

  A Plaintext

- len:

  Integer length

## Value

Invisibly, the `pt` plaintext that was passed in. Called for its side
effect: the plaintext is truncated in place so that the accessors report
only the first `len` slots, which is how the padding introduced by
encoding is trimmed after decryption.
