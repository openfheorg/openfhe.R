# Changelog

## openfhe.R 1.5.1.2

- Under `R CMD check` the package caps OpenFHE at two threads.

- [`set_num_threads()`](https://openfheorg.github.io/openfhe.R/reference/set_num_threads.md)
  now sets the cap through OpenFHE’s own thread controls rather than the
  OpenMP runtime, and returns the cap in effect (invisibly).

- The package now installs on musl-based Linux (Alpine).

- `rlang` is declared in `Imports`.

- Every handle the package passes between R and C++ now carries its
  type, and every binding checks that type before using the pointer.

- [`bin_fhe_context()`](https://openfheorg.github.io/openfhe.R/reference/bin_fhe_context.md)
  returns an object of the new `BinFHEContext` class instead of the base
  `OpenFHEObject`. The boolean-circuit context and the `CryptoContext`
  used by BFV, BGV, and CKKS are therefore distinct classes, and passing
  one where the other belongs is an error rather than a silent misuse.

- `OpenFHEObject`, the base class, is now abstract. It was never useful
  to construct directly, and every handle now belongs to a concrete
  class.

- [`decrypt()`](https://openfheorg.github.io/openfhe.R/reference/decrypt.md)
  accepts its arguments in either order, matching the C++ library, which
  declares both. `decrypt(private_key, ciphertext)` is now equivalent to
  `decrypt(ciphertext, private_key)`.

## openfhe.R 1.5.1.1

CRAN release: 2026-08-23

- Fixed undefined behavior in the vendored OpenFHE library reported by
  CRAN’s UBSAN check platforms.
  `RingGSWAccumulator::SignedDigitDecompose` sign-extended a balanced
  digit by shifting a signed value into and past the sign bit, which is
  undefined in C++17. The vendored library now carries the upstream fix
  (OpenFHE PR
  [\#1238](https://github.com/openfheorg/openfhe.R/issues/1238)), which
  computes the same digits without signed shifts. Results are unchanged.

- The
  [`eval_sign()`](https://openfheorg.github.io/openfhe.R/reference/eval_sign.md)
  example in the BinFHE vignette and its corresponding test are skipped
  on CRAN, where their bootstrapping-key generation dominated the check
  time. Both still run on CI and locally.

## openfhe.R 1.5.1

CRAN release: 2026-08-21

Initial release. An R interface to the OpenFHE C++ library for fully
homomorphic encryption, with a binding surface that mirrors
openfhe-python.

- Supports the BFV, BGV, and CKKS schemes for computation on encrypted
  integers and approximate reals, plus BinFHE (FHEW/TFHE) for Boolean
  circuits over encrypted bits.

- Provides threshold (multiparty) FHE, including interactive
  bootstrapping, for computations shared across several key-holders.

- Built on S7 classes and cpp11 bindings; the OpenFHE C++ library is
  vendored and built from source, so the package version tracks the
  library version.

- Ships an API tour vignette plus worked examples of CKKS bootstrapping
  and BinFHE Boolean circuits.
