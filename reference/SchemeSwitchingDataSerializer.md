# Write and read the data of a scheme-switching computation

A scheme-switching computation needs a CKKS context with its public key
and evaluation keys, the FHEW context inside it with its bootstrapping
keys, the switching key from FHEW to CKKS, and the ciphertext to work
on. `SchemeSwitchingDataSerializer` writes all of it to a directory, and
`SchemeSwitchingDataDeserializer` reads it back in another session, so
that one party can set the computation up and another can run it.

## Usage

``` r
SchemeSwitchingDataSerializer(
  crypto_context = NULL,
  public_key = NULL,
  raw_ciphertext = NULL,
  ptr = NULL
)

SchemeSwitchingDataDeserializer(ptr = NULL)

set_data_directory(x, dir)

serialize_scheme_switching_data(x)

deserialize_scheme_switching_data(x)

get_raw_ciphertext(x)
```

## Arguments

- crypto_context:

  A CKKS `CryptoContext` on which scheme switching has been set up and
  its keys generated
  ([`eval_scheme_switching_setup()`](https://openfheorg.github.io/openfhe.R/reference/eval_scheme_switching_setup.md),
  [`eval_scheme_switching_key_gen()`](https://openfheorg.github.io/openfhe.R/reference/eval_scheme_switching_setup.md)).

- public_key:

  The `PublicKey` of the context.

- raw_ciphertext:

  The `Ciphertext` to write.

- ptr:

  External pointer (internal use).

- x:

  A `SchemeSwitchingDataSerializer` or
  `SchemeSwitchingDataDeserializer`.

- dir:

  Character string; the directory.

## Value

The constructors: an S7 object of the class, inheriting from
[OpenFHEObject](https://openfheorg.github.io/openfhe.R/reference/OpenFHEObject.md).
`get_raw_ciphertext()`: a `Ciphertext`, or `NULL` before the data has
been read. The others: `x`, invisibly.

## Details

The writer is made from the context, the public key and the ciphertext.
`set_data_directory()` names the directory, which must exist, and
`serialize_scheme_switching_data()` writes the files (binary format,
fixed file names). The multiplication and automorphism keys written are
all those in the key registries.

The reader is made empty. After `set_data_directory()`,
`deserialize_scheme_switching_data()` reads the files, registers the
evaluation keys, and puts the FHEW context and the switching key into
the CKKS context.
[`get_crypto_context()`](https://openfheorg.github.io/openfhe.R/reference/get_crypto_context.md),
[`get_public_key()`](https://openfheorg.github.io/openfhe.R/reference/get_public_key.md)
and `get_raw_ciphertext()` then return the three objects.

The C++ classes default the directory to `demoData` under the working
directory. The R functions do not: reading or writing before
`set_data_directory()` is an error.
