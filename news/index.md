# Changelog

## openfhe.R 1.5.1.1

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
