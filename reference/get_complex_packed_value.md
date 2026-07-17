# Get complex values from a CKKS plaintext

Reads the CKKS plaintext's internal slot vector as complex numbers.
Every CKKS plaintext slot carries a `std::complex<double>` internally;
when a plaintext was constructed from a real-valued vector via
[`make_ckks_packed_plaintext()`](https://openfheorg.github.io/openfhe.R/reference/make_ckks_packed_plaintext.md),
the imaginary parts are all zero (up to CKKS encoding noise). When a
plaintext was constructed from a complex vector (the is-complex dispatch
path), both real and imaginary parts carry information.

## Usage

``` r
get_complex_packed_value(pt)
```

## Arguments

- pt:

  A `Plaintext`.

## Value

A native R `complex` vector.

## See also

[`get_real_packed_value()`](https://openfheorg.github.io/openfhe.R/reference/get_real_packed_value.md)
for the real-only view,
[`make_ckks_packed_plaintext()`](https://openfheorg.github.io/openfhe.R/reference/make_ckks_packed_plaintext.md)
for the matching constructor.
