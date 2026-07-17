# Evaluate an arbitrary function on an encrypted value

Functional bootstrapping with a precomputed lookup table. The context
must have been created with `arb_func = TRUE`.

## Usage

``` r
eval_func(ctx, ct, lut)
```

## Arguments

- ctx:

  A BinFHE context built with `arb_func = TRUE`

- ct:

  An LWECiphertext encrypted with `output = BinFHEOutput$LARGE_DIM`

- lut:

  A numeric vector of length `p` (the plaintext modulus) typically
  produced by
  [`generate_lut_via_function()`](https://openfheorg.github.io/openfhe.R/reference/generate_lut_via_function.md)

## Value

An LWECiphertext encrypting `lut[plaintext(ct) + 1]`
