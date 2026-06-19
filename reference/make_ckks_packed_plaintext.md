# Make a CKKS packed plaintext from real numbers

Encode a real-valued numeric vector as a CKKS packed plaintext. The
result is an unencrypted `Plaintext` object that can then be passed to
[`encrypt()`](https://bnaras.github.io/openfhe.R/reference/encrypt.md).

## Usage

``` r
make_ckks_packed_plaintext(
  cc,
  values,
  noise_scale_deg = 1L,
  level = 0L,
  params = NULL,
  slots = 0L
)
```

## Arguments

- cc:

  A `CryptoContext` built with `scheme = "CKKS"`.

- values:

  A numeric vector to pack. Length must not exceed `slots` (or
  `batch_size / 2` when `slots` is left at `0L`).

- noise_scale_deg:

  Integer degree of the initial scaling factor applied to the encoded
  plaintext, expressed as a power of the scheme's scaling factor.
  Defaults to `1L`, meaning "scale by the base scaling factor once",
  which is the value every current vignette implicitly uses. Setting
  `noise_scale_deg = 2L` encodes at scaling factor squared, which is
  occasionally useful when the plaintext is about to be subtracted from
  a ciphertext that has already been rescaled once and the two noise
  levels must agree. Under `FLEXIBLEAUTO` scaling the scheme's
  auto-rescale logic overrides this argument at context-generation time
  — see discovery D011 — so this parameter is only meaningful under
  `FIXEDMANUAL`. Couples tightly to `level`: a plaintext at
  `(noise_scale_deg = k, level = L)` may only interact with ciphertexts
  at the same `(k, L)`.

- level:

  Integer target encryption level of the encoded plaintext. Defaults to
  `0L`, meaning "encode at the fresh level, matching a just-encrypted
  ciphertext". When performing an operation between an encoded plaintext
  and a ciphertext that has already been rescaled `L` times, the
  plaintext must be encoded at `level = L` so the two sit at the same
  level of the modulus chain; otherwise the evaluator will silently
  mismatch or error depending on the scheme variant. The canonical case
  for setting this is encoding a constant vector for use inside a deep
  CKKS circuit, not for fresh-input computation. Couples to
  `noise_scale_deg` and to the multiplicative depth of the crypto
  context, which bounds the maximum valid `level`.

- params:

  Advanced. An `ElementParams` object to encode against, or `NULL` to
  use the `cryptocontext`'s own parameters at the chosen `level`.
  Defaults to `NULL`, which is the only value any current vignette or
  test uses. There is no R-side way to construct a fresh `ElementParams`
  (only to wrap one returned by `get_element_params(cc)`), so in
  practice the argument is accepted for surface parity with
  openfhe-python but is normally left at its default.

- slots:

  Integer number of CKKS slots to pack into. Defaults to `0L`, which is
  the upstream sentinel for "use the `batch_size` set on the context's
  params". Setting `slots` to a smaller power of two produces a
  plaintext that leaves the upper half of the packing register zero,
  which the evaluator exploits to reduce rotation cost in algorithms
  like `eval_sum`. The value must be a power of two and must not exceed
  `batch_size`. The natural time to set this is when you have a short
  input vector and rotations dominate the circuit cost, as in the
  CKKS-inner-product idiom; the natural time to leave it at `0L` is when
  you are encoding a full-width vector.

## Value

A `Plaintext`.
