# Set up CKKS bootstrapping

The multiplicative depth of `cc` must be at least
[`get_bootstrap_depth()`](https://openfheorg.github.io/openfhe.R/reference/get_bootstrap_depth.md)
for `level_budget`. At OpenFHE 1.6.1 the library does not check this,
and a setup with `precompute = TRUE` on a shallower context ends the R
session.

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

  Logical; compute the encoding and decoding plaintexts of bootstrapping
  now (default: TRUE). With `FALSE`, call
  [`eval_bootstrap_precompute()`](https://openfheorg.github.io/openfhe.R/reference/eval_bootstrap_precompute.md)
  before
  [`eval_bootstrap()`](https://openfheorg.github.io/openfhe.R/reference/eval_bootstrap.md).

- bt_slots_encoding:

  Logical; controls whether the bootstrap precomputes with slot-count
  encoding (the `BTSlotsEncoding` tail argument on cryptocontext.h line
  3513). Default `FALSE` matching the C++ default.

## Value

Invisibly, the `cc` crypto context that was passed in. Called for its
side effect: the linear transforms bootstrapping needs are precomputed
and cached inside the C++ context. Call it before
[`eval_bootstrap_key_gen()`](https://openfheorg.github.io/openfhe.R/reference/eval_bootstrap_key_gen.md).
