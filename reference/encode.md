# Encode or decode a plaintext

A plaintext holds a value and its encoding as a ring element. The
functions that make plaintexts encode them, and
[`decrypt()`](https://openfheorg.github.io/openfhe.R/reference/decrypt.md)
decodes its result, so these are for code that manipulates the element
directly.

## Usage

``` r
encode(pt)

decode(
  pt,
  depth = NULL,
  scaling_factor = NULL,
  scal_tech = NULL,
  execution_mode = NULL
)
```

## Arguments

- pt:

  A `Plaintext`.

- depth:

  Integer; the noise scale degree of the ciphertext.

- scaling_factor:

  Numeric; its scaling factor.

- scal_tech:

  A member of
  [ScalingTechnique](https://openfheorg.github.io/openfhe.R/reference/ScalingTechnique.md).

- execution_mode:

  A member of
  [ExecutionMode](https://openfheorg.github.io/openfhe.R/reference/ExecutionMode.md).

## Value

`TRUE` on success.

## Details

`encode()` computes the element from the value and `decode()` the value
from the element. The CKKS form of `decode()` takes what the decoder
needs to know about the ciphertext the plaintext came from; give all
four arguments or none. The result of
[`decrypt()`](https://openfheorg.github.io/openfhe.R/reference/decrypt.md)
is already decoded, and decoding it again does not reproduce its value.
