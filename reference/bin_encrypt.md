# Encrypt a value for Binary FHE

Encrypt a value for Binary FHE

## Usage

``` r
bin_encrypt(ctx, sk, message, output = 2L, p = 4L, mod = NULL)
```

## Arguments

- ctx:

  A BinFHE context

- sk:

  An LWEPrivateKey

- message:

  Integer (0 or 1 for Boolean; larger for integer FHE)

- output:

  BINFHE_OUTPUT (default: 2 = BOOTSTRAPPED). Use
  `BinFHEOutput$LARGE_DIM` together with `mod` for the
  functional-bootstrapping path.

- p:

  Plaintext modulus (default: 4)

- mod:

  Optional large ciphertext modulus Q for the LARGE_DIM path. NULL
  (default) selects the standard small-modulus encrypt.

## Value

An LWECiphertext
