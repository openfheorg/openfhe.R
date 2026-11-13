# Switch FHEW ciphertexts to a CKKS ciphertext

Packs the messages of a list of FHEW (LWE) ciphertexts into the slots of
one CKKS ciphertext (CKKS with real data and `Feature$SCHEMESWITCH`).

## Usage

``` r
eval_fhew_to_ckks_setup(cc, cc_lwe, num_slots_ckks = 0L, log_q = 25L)

eval_fhew_to_ckks_key_gen(
  cc,
  key_pair,
  lwesk,
  num_slots = 0L,
  num_ctxts = 0L,
  dim1 = 0L,
  l = 0L
)

eval_fhew_to_ckks(
  cc,
  lwe_ciphertexts,
  num_ctxts = 0L,
  num_slots = 0L,
  p = 4L,
  pmin = 0,
  pmax = 2,
  dim1 = 0L
)
```

## Arguments

- cc:

  A CKKS `CryptoContext`.

- cc_lwe:

  The `BinFHEContext` the ciphertexts come from.

- num_slots_ckks, num_slots:

  Integer; number of CKKS slots, `0L` (default) for the library's
  choice.

- log_q:

  Integer; bits of the FHEW ciphertext modulus. Default `25L`.

- key_pair:

  The `KeyPair` of the CKKS context.

- lwesk:

  The `LWEPrivateKey` of the FHEW context.

- num_ctxts:

  Integer; number of ciphertexts to switch, `0L` (default) for all.

- dim1:

  Integer; baby-step dimension of the linear transform, `0L` (default)
  for the library's choice.

- l:

  Integer; level of the linear transform (the C++ argument `L`). Default
  `0L`.

- lwe_ciphertexts:

  A list of `LWECiphertext` objects.

- p:

  Integer; plaintext modulus of the FHEW ciphertexts. Default `4L`.

- pmin, pmax:

  Numeric; the range of the messages. Defaults `0` and `2`.

## Value

`eval_fhew_to_ckks()`: a `Ciphertext`. The others: `cc`, invisibly.

## Details

`eval_fhew_to_ckks_setup()` records the FHEW context `cc_lwe` in the
CKKS context, and `eval_fhew_to_ckks_key_gen()` generates the keys of
the switch.

The messages are taken modulo `p`; `pmin` and `pmax` give the range they
lie in, which sets the interval of the Chebyshev approximation the
switch evaluates. The defaults are for bits.

## See also

[`eval_ckks_to_fhew()`](https://openfheorg.github.io/openfhe.R/reference/eval_ckks_to_fhew_setup.md)
