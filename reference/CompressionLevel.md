# Compression Level (interactive multi-party bootstrap)

Mirrors the C++ enum `CompressionLevel` in `pke/constants-defs.h`. Note
that the values start at 2, not 0: the header explains that compression
levels 0 and 1 are not supported and that the remaining values are
deliberately not renumbered.

## Usage

``` r
CompressionLevel
```

## Value

A named `list` of 2 integer scalars, each the value of the OpenFHE C++
enumerator of the same name, naming how far a ciphertext is compressed
before the interactive bootstrapping round-trip: `COMPACT` (2) sends the
least data but is only safe when the result is decrypted immediately,
while `SLACK` (3) leaves room for further computation on the result.
Pass an element as the `interactive_boot_compression_level` argument of
[`CKKSParams()`](https://openfheorg.github.io/openfhe.R/reference/CKKSParams.md)
or
[`fhe_context()`](https://openfheorg.github.io/openfhe.R/reference/fhe_context.md).
