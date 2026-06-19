# Generate automorphism evaluation keys for a set of indices

Generates the eval-key map needed to apply
[`eval_automorphism()`](https://bnaras.github.io/openfhe.R/reference/eval_automorphism.md)
at the given set of slot indices. The generated keys are both inserted
into the CryptoContext's internal eval-automorphism-key registry (keyed
by `sk`'s tag) **and** returned as an `EvalKeyMap` handle that the
caller can pass directly to
[`eval_automorphism()`](https://bnaras.github.io/openfhe.R/reference/eval_automorphism.md).

## Usage

``` r
eval_automorphism_key_gen(cc, sk, indices)
```

## Arguments

- cc:

  A `CryptoContext`.

- sk:

  A `PrivateKey`.

- indices:

  Integer vector of automorphism indices (not slot indices — use
  [`find_automorphism_indices()`](https://bnaras.github.io/openfhe.R/reference/find_automorphism_indices.md)
  to compute them from slot indices).

## Value

An `EvalKeyMap` with one entry per input index.

## Details

On the C++ side this is equivalent to calling
`EvalAutomorphismKeyGen(sk, indices)` which internally calls
`CryptoContextImpl::InsertEvalAutomorphismKey` with the generated map
(cryptocontext.h line 2237). The dual return / registry-insert pattern
matches the openfhe-python behavior at the equivalent entry point.

Companion to
[`eval_rotate_key_gen()`](https://bnaras.github.io/openfhe.R/reference/eval_rotate_key_gen.md)
(reached via
[`key_gen()`](https://bnaras.github.io/openfhe.R/reference/key_gen.md)'s
`rotations` argument): both populate the same cc-internal storage. The
automorphism form gives raw access to the automorphism group element
(bypassing the rotate-to-automorphism slot mapping that
`eval_rotate_key_gen` performs internally).

## See also

[`eval_automorphism()`](https://bnaras.github.io/openfhe.R/reference/eval_automorphism.md),
[`find_automorphism_indices()`](https://bnaras.github.io/openfhe.R/reference/find_automorphism_indices.md)
