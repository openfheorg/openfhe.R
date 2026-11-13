# Encrypt a value for Binary FHE

Encrypt a value for Binary FHE

## Usage

``` r
bin_encrypt(
  ctx,
  sk,
  message,
  output = BinFHEOutput$BOOTSTRAPPED,
  p = 4L,
  mod = NULL
)
```

## Arguments

- ctx:

  A BinFHE context

- sk:

  An LWEPrivateKey, or an
  [LWEPublicKey](https://openfheorg.github.io/openfhe.R/reference/LWEPublicKey.md)
  to encrypt under the public key.

- message:

  Integer (0 or 1 for Boolean; larger for integer FHE)

- output:

  An element of
  [BinFHEOutput](https://openfheorg.github.io/openfhe.R/reference/BinFHEOutput.md)
  (default: `BinFHEOutput$BOOTSTRAPPED`). Use `BinFHEOutput$LARGE_DIM`
  together with `mod` for the functional-bootstrapping path. With a
  public key the default is `BinFHEOutput$SMALL_DIM`, as in
  openfhe-python, which needs the switching key that
  [`bin_bt_key_gen()`](https://openfheorg.github.io/openfhe.R/reference/bin_bt_key_gen.md)
  generates.

- p:

  Plaintext modulus (default: 4)

- mod:

  Optional large ciphertext modulus Q for the LARGE_DIM path. NULL
  (default) selects the standard small-modulus encrypt. A whole number
  of at most 2^53, or a string of decimal digits for a larger value.

## Value

An LWECiphertext
