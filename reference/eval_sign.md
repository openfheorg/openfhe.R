# Evaluate sign on an encrypted value (functional bootstrapping)

Extracts the most-significant bit of an LWE ciphertext encrypted under
the large modulus Q. The context must have been created with
`arb_func = TRUE`.

## Usage

``` r
eval_sign(ctx, ct, scheme_switch = FALSE)
```

## Arguments

- ctx:

  A BinFHE context built with `arb_func = TRUE`

- ct:

  An LWECiphertext encrypted via `bin_encrypt(..., mod = Q)`

- scheme_switch:

  Logical; when `TRUE`, the output ciphertext is encoded compatibly with
  the CKKS\<-\>FHEW scheme-switching pipeline (the `schemeSwitch` flag
  at `binfhecontext.h` line 367). Default `FALSE` for the standalone
  FHEW path. Per the upstream header description, this is the "flag that
  indicates if it should be compatible to scheme switching".

## Value

An LWECiphertext encrypting 0 if the input was negative (i.e. lay in the
upper half of \[0, Q)), 1 otherwise
