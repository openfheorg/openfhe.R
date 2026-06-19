# openfhe.R 1.5.1

Initial release. An R interface to the OpenFHE C++ library for fully
homomorphic encryption, with a binding surface that mirrors
openfhe-python.

* Supports the BFV, BGV, and CKKS schemes for computation on encrypted
  integers and approximate reals, plus BinFHE (FHEW/TFHE) for Boolean
  circuits over encrypted bits.

* Provides threshold (multiparty) FHE, including interactive
  bootstrapping, for computations shared across several key-holders.

* Built on S7 classes and cpp11 bindings; the OpenFHE C++ library is
  vendored and built from source, so the package version tracks the
  library version.

* Ships an API tour vignette plus worked examples of CKKS bootstrapping
  and BinFHE Boolean circuits.
