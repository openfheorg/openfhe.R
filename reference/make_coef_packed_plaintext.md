# Make a coefficient-packed integer plaintext

Encode an integer vector as a coefficient-packed plaintext. Coefficient
packing places each input value in a separate polynomial coefficient and
is the alternative to the SIMD batched packing produced by
[`make_packed_plaintext()`](https://bnaras.github.io/openfhe.R/reference/make_packed_plaintext.md).
Used by the integer-modulus Ring-LWE vignettes where per-coefficient
access is needed.

## Usage

``` r
make_coef_packed_plaintext(cc, values, noise_scale_deg = 1L, level = 0L)
```

## Arguments

- cc:

  A `CryptoContext` (BFV or BGV).

- values:

  An integer vector whose length must not exceed the ring dimension of
  `cc`.

- noise_scale_deg:

  See the
  [`make_packed_plaintext()`](https://bnaras.github.io/openfhe.R/reference/make_packed_plaintext.md)
  entry.

- level:

  See the
  [`make_packed_plaintext()`](https://bnaras.github.io/openfhe.R/reference/make_packed_plaintext.md)
  entry.

## Value

A `Plaintext`.
