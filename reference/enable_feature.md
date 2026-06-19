# Enable a feature on a CryptoContext

Accepts either a single `PKESchemeFeature` enum value or a `uint32_t`
bitwise-OR mask of `PKESchemeFeature` values (for surface parity with
the C++ `Enable(uint32_t)` overload). The two paths dispatch on the
value itself: a mask is detected by being strictly larger than the
largest single-feature value (`Feature$SCHEMESWITCH = 0x80 = 128`) or by
having more than one bit set.

## Usage

``` r
enable_feature(cc, ...)
```

## Arguments

- cc:

  A `CryptoContext`.

- ...:

  `feature`: a `Feature` value (single) or an integer mask (e.g.
  `Feature$PKE + Feature$KEYSWITCH + Feature$LEVELEDSHE`, i.e. `11L`).

## Value

`cc` invisibly.
