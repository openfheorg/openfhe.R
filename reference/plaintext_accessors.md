# Plaintext accessors

Retrieve or set fields on a `Plaintext` object. Each accessor wraps the
corresponding upstream `PlaintextImpl::Get*`/`Set*` method and returns
its value unchanged.

## Usage

``` r
get_noise_scale_deg(x, ...)

get_length(x, ...)

get_level(x, ...)

get_scaling_factor(x, ...)

get_log_precision(x, ...)

get_formatted_values(x, ...)

set_ckks_data_type(x, ...)

get_encoding_type(x, ...)

get_scaling_factor_int(x, ...)

get_scheme_id(x, ...)

is_encoded(x, ...)

low_bound(x, ...)

high_bound(x, ...)

get_slots(x, ...)

get_log_error(x, ...)

get_coef_packed_value(x, ...)

get_string_value(x, ...)

get_element_ring_dimension(x, ...)

set_scaling_factor(x, ...)

set_scaling_factor_int(x, ...)

set_noise_scale_deg(x, ...)

set_level(x, ...)

set_slots(x, ...)

set_string_value(x, ...)

set_int_vector_value(x, ...)
```

## Arguments

- x:

  A `Plaintext`.

- ...:

  Reserved for future method-specific arguments. Setters accept a
  `value` argument here; `get_formatted_values` accepts a `precision`
  integer.

## Value

The underlying field value. Types vary per accessor.

## Details

Several base-class accessors are declared `virtual` and throw
`OPENFHE_THROW` in the base implementation (e.g. `get_string_value` on a
non-string plaintext, `get_log_precision` on a non-CKKS plaintext).
Calling an accessor on the wrong kind of plaintext therefore raises an R
error via
[`cli::cli_abort`](https://cli.r-lib.org/reference/cli_abort.html), not
a silent wrong value.

## Functions

- `get_noise_scale_deg`: Integer noise-scale-degree of a CKKS plaintext.
  After construction the degree is the value passed to
  `make_ckks_packed_plaintext(..., noise_scale_deg)` under `FIXEDMANUAL`
  scaling; under `FLEXIBLEAUTO` the scheme overrides the user-supplied
  value at context-generation time. Incremented by each multiplication
  before a rescale.

- `get_length`: Integer effective length of a packed plaintext — the
  number of slots that hold user-supplied values. Defaults to the full
  batch size at construction;
  [`set_length()`](https://openfheorg.github.io/openfhe.R/reference/set_length.md)
  can shorten it for display or decryption purposes.

- `get_level`: Integer level of the plaintext in the RNS modulus chain.
  `0` for a fresh plaintext; incremented by each
  [`rescale()`](https://openfheorg.github.io/openfhe.R/reference/rescale.md)
  the plaintext survives. For CKKS-packed plaintexts the level must
  match the ciphertext level at every homomorphic operation, or the
  evaluator rejects the pair.

- `get_scaling_factor`: Numeric scaling factor for CKKS-based plaintexts
  — the multiplier the real vector is scaled by before encoding. Equals
  `2^scaling_mod_size` for a freshly-encoded plaintext under
  FLEXIBLEAUTO; halves after each rescale. For BFV/BGV plaintexts this
  is returned as a default value (no rescaling applies).

- `get_log_precision`: Numeric log2 of the precision lost during CKKS
  encoding. Only meaningful for CKKS plaintexts; throws via
  `OPENFHE_THROW` for BFV/BGV and is surfaced as an R error by
  [`cli::cli_abort`](https://cli.r-lib.org/reference/cli_abort.html).

- `get_formatted_values`: String-format the plaintext's encoded values
  with `precision` decimal digits. Implemented on the concrete plaintext
  subclass (packed, CKKS, string, coefficient); throws on plaintexts
  whose subclass does not override.

- `set_ckks_data_type`: Set the CKKS data type to `CKKSDataType$REAL` or
  `CKKSDataType$COMPLEX`. Only meaningful for CKKS plaintexts. Most R
  vignettes use the default `REAL` type; set to `COMPLEX` only when you
  are constructing a CKKS plaintext from a complex vector.

- `get_encoding_type`: integer encoding type (see `PlaintextEncodings`
  for the enum values).

- `get_scaling_factor_int`: BGV integer scaling factor. Returned as a
  double carrying a losslessly rounded 53-bit integer.

- `get_scheme_id`: scheme identifier (see `SchemeId` enum).

- `is_encoded`: logical "has the plaintext been encoded yet?" The
  factory methods typically encode plaintexts eagerly, so this is `TRUE`
  for fresh plaintexts. Returns `FALSE` only for plaintexts constructed
  in a two-step uninitialised form.

- `low_bound`: integer lower bound that can be encoded with the current
  plaintext modulus: `-floor(t / 2)`.

- `high_bound`: integer upper bound that can be encoded with the current
  plaintext modulus: `floor(t / 2)`.

- `get_slots`: integer CKKS slot count. For `Plaintext` dispatch this is
  the `GetSlots()` value set at construction.

- `get_log_error`: numeric log2 of the error estimate. Only meaningful
  for CKKS plaintexts; throws for BFV/BGV.

- `get_coef_packed_value`: integer vector of the underlying coef-packed
  encoding. Throws for plaintexts whose subclass is not coef-packed.

- `get_string_value`: string value of a string-encoded plaintext. Throws
  for plaintexts whose subclass is not string-encoded.

- `get_element_ring_dimension`: integer ring dimension of the underlying
  `Element`. This is the plaintext's view of the lattice ring dimension;
  typically matches the crypto context's ring dimension.

- `set_scaling_factor`: set the CKKS plaintext scaling factor.

- `set_scaling_factor_int`: set the BGV plaintext integer scaling
  factor.

- `set_noise_scale_deg`: set the plaintext noise scale degree. Most
  users should not call this directly — the factory methods and the
  evaluator manage `noise_scale_deg` automatically.

- `set_level`: set the plaintext level. As with `set_noise_scale_deg`,
  most users should not call this directly.

- `set_slots`: set the CKKS slot count. As with `set_length`, this is
  typically managed by the factory methods.

- `set_string_value`: set the string value of a string-encoded
  plaintext. Throws for plaintexts whose subclass is not string-encoded.

- `set_int_vector_value`: set the integer-vector value of an
  integer-encoded plaintext. Throws for plaintexts whose subclass does
  not support an integer vector.
