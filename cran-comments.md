# CRAN submission comments — openfhe.R 1.5.1

## New submission

This is the first CRAN submission of openfhe.R, an R interface to the
OpenFHE fully homomorphic encryption library. The OpenFHE C++ sources
(and the header-only cereal serialization library) are vendored under
`inst/openfhe/` and compiled into static archives at install time.

## Test environments

* Local: macOS (Apple Silicon), R 4.6.1 — `R CMD check --as-cran`:
  0 ERRORs, 0 WARNINGs, 1 NOTE (new submission).
* mac-builder (r-release, arm64): Status OK.
* win-builder (R-devel): 2 NOTEs, discussed below.
* GitHub Actions: Linux (release), macOS (release), Windows (release) —
  all passing.

## NOTEs

* "New submission" — first submission of this package.

* Possibly misspelled words in DESCRIPTION (BFV, BGV, CKKS, FHEW,
  TFHE, Brakerski, Cheon, Chillotti, Ducas, Georgieva, Izabachene,
  Micciancio, Vaikuntanathan, Vercauteren, Badawi, homomorphic): all
  are names of cryptographic schemes or the surnames of their authors,
  spelled as published.

* win-builder additionally reports a "checking compiled code" NOTE
  whose text is an internal error of the check itself ("'cc' is not on
  the path"); the compiled-code check runs to completion and passes on
  the platforms where a C compiler is on the path (local macOS,
  mac-builder).

## Notes for the reviewers

* Installed size is about 10 Mb (libs about 8 Mb) because the OpenFHE
  library is statically linked into the package's shared object, which
  is the supported way to ship it without a system dependency.

* Examples, tests, and vignettes cap OpenMP at 2 threads via the
  package's `set_num_threads()` in compliance with CRAN's two-core
  policy; on the CRAN macOS build system the package links the libomp
  bundled with the CRAN distribution of R.
