# Switch a CKKS ciphertext to FHEW ciphertexts

Scheme switching takes the values in the slots of a CKKS ciphertext to
one FHEW (LWE) ciphertext each, on which Boolean gates, the sign and
look-up tables can be evaluated (CKKS with real data and
`Feature$SCHEMESWITCH`).

## Usage

``` r
eval_ckks_to_fhew_setup(cc, schswchparams)

eval_ckks_to_fhew_key_gen(cc, key_pair, lwesk)

eval_ckks_to_fhew_precompute(cc, scale = 1)

eval_ckks_to_fhew(ct, num_ctxts = 0L)
```

## Arguments

- cc:

  A CKKS `CryptoContext`.

- schswchparams:

  A
  [SchSwchParams](https://openfheorg.github.io/openfhe.R/reference/SchSwchParams.md)
  object. The setup fills its CKKS fields from `cc`.

- key_pair:

  The `KeyPair` of the CKKS context.

- lwesk:

  The `LWEPrivateKey` of the FHEW context.

- scale:

  Numeric; the scale. Default `1`.

- ct:

  A `Ciphertext`.

- num_ctxts:

  Integer; the number of slots to switch, `0L` (default) for all.

## Value

`eval_ckks_to_fhew_setup()`: an `LWEPrivateKey`. `eval_ckks_to_fhew()`:
a list of `LWECiphertext` objects. The others: `cc`, invisibly.

## Details

`eval_ckks_to_fhew_setup()` creates the FHEW context inside `cc` (read
it with
[`get_bin_cc_for_scheme_switch()`](https://openfheorg.github.io/openfhe.R/reference/get_bin_cc_for_scheme_switch.md))
and returns its secret key. `eval_ckks_to_fhew_key_gen()` generates the
keys of the switch. `eval_ckks_to_fhew_precompute()` fixes the scale the
values are multiplied by before the switch, normally one over the FHEW
plaintext modulus. `eval_ckks_to_fhew()` does the switch.

## See also

[`eval_fhew_to_ckks()`](https://openfheorg.github.io/openfhe.R/reference/eval_fhew_to_ckks_setup.md)
for the other direction;
[`eval_scheme_switching_setup()`](https://openfheorg.github.io/openfhe.R/reference/eval_scheme_switching_setup.md)
for both at once.
