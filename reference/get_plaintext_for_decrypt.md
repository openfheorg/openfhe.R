# An empty plaintext of the type a decryption will fill

The counterpart of the C++ static `GetPlaintextForDecrypt()`: a
plaintext of the given encoding with no value yet, for code that
decrypts by hand.

## Usage

``` r
get_plaintext_for_decrypt(
  encoding_type,
  element_params,
  encoding_params,
  ckks_data_type = CKKSDataType$REAL
)
```

## Arguments

- encoding_type:

  A member of
  [PlaintextEncodings](https://openfheorg.github.io/openfhe.R/reference/PlaintextEncodings.md).

- element_params:

  An `ElementParams` object.

- encoding_params:

  An `EncodingParams` object.

- ckks_data_type:

  A member of
  [CKKSDataType](https://openfheorg.github.io/openfhe.R/reference/CKKSDataType.md);
  default `CKKSDataType$REAL`.

## Value

A `Plaintext`.
