# Set up CKKS bootstrapping

Set up CKKS bootstrapping

## Usage

``` r
eval_bootstrap_setup(
  cc,
  level_budget = c(5L, 4L),
  dim1 = c(0L, 0L),
  slots = 0L,
  correction_factor = 0L,
  precompute = TRUE,
  bt_slots_encoding = FALSE
)
```

## Arguments

- cc:

  A CryptoContext

- level_budget:

  Integer vector of length 2 (default: c(5, 4))

- dim1:

  Integer vector of length 2 (default: c(0, 0))

- slots:

  Number of slots (default: 0 = automatic)

- correction_factor:

  Correction factor (default: 0)

- precompute:

  Precompute rotation keys (default: TRUE)

- bt_slots_encoding:

  Logical; controls whether the bootstrap precomputes with slot-count
  encoding (the `BTSlotsEncoding` tail argument on cryptocontext.h line
  3513). Default `FALSE` matching the C++ default.
