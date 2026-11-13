# CRAN submission comments — openfhe.R 1.6.1

## What this release is

The package version is the version of the bundled OpenFHE C++ library.
This release moves the bundled library from OpenFHE 1.5.1 to OpenFHE
1.6.1 and binds the rest of what that library's own Python package
exposes, so that R and Python users have the same functions. The
additions are listed in `NEWS.md`.

Contexts, keys and ciphertexts saved by openfhe.R 1.5.1.2 are read by
this version (checked for the BFV, BGV and CKKS schemes, in the binary
and the JSON format).

## The bundled library

The source under `inst/openfhe` is the OpenFHE 1.6.1 release with
seven small patches, all for building inside an R package and none
changing what the library computes:

* CMake accepts the OpenMP library R was built with, in place of a
  hard-coded path;
* pragma guards written in the form R's pragma check accepts;
* no `-Werror`, and LF line endings;
* the cereal headers from a fork with the same two adjustments, placed
  at `inst/openfhe/cereal`;
* the `<execinfo.h>` include guarded with `__has_include`, for musl;
* a `cp` of a folder the tarball does not ship is skipped.

Three patches that 1.5.1.2 carried are gone because OpenFHE 1.6.1
contains them: the routing of the library's diagnostic output to R's
message stream, the fix for the undefined behavior the sanitizer
checks reported against 1.5.1, and the process-wide thread cap.

The copyright holders of the bundled code are the same as in 1.5.1.2.
`inst/COPYRIGHTS` and `Authors@R` were re-audited against the built
tarball.

## Test environments

All run against the tarball being submitted.

* Local: macOS 27.2 (Apple Silicon), R 4.6.2 — `R CMD check --as-cran`
  with the check platforms' thread environment applied
  (`_R_CHECK_LIMIT_CORES_=TRUE`, the test, vignette and example
  CPU-to-elapsed gates at 2.5, `KMP_BLOCKTIME=200ms`,
  `OMP_NUM_THREADS=32`): 0 ERRORs, 0 WARNINGs, 0 NOTEs. Tests 49s/26s,
  vignettes 29s/16s, examples OK. The bundled library was compiled from
  source in this check, as it is on CRAN.
* [TO FILL BEFORE UPLOAD: win-builder R-devel.]
* [TO FILL BEFORE UPLOAD: GitHub Actions, ubuntu-latest (R-devel and
  release), macOS-latest, windows-latest.]
* Alpine Linux 3.22 (musl, aarch64) container, R-devel r90878, gcc
  14.2.0 — `R CMD check --no-manual --ignore-vignettes`: 0 ERRORs,
  0 WARNINGs, 1 NOTE. The NOTE is from "checking compiled code":
  `nm` reports "no symbols" for the package's shared object. The code
  of the three vignettes
  was run separately in the same container and completed.
* [TO FILL BEFORE UPLOAD: macOS builder.]

## Reverse dependencies

One, 'homomorpheR' (1.0). Its CRAN tarball was checked with
`R CMD check --as-cran` against this version: installation, examples,
tests and the vignette rebuild are OK. The same package as already
installed against 'openfhe.R' 1.5.1.2 also passes its tests with this
version, without being reinstalled.

## Notes for the reviewers

* Installed size is about 15 Mb (libs about 12 Mb) because the OpenFHE
  library is statically linked into the package's shared object, which
  is the supported way to ship it without a system dependency. It was
  about 10 Mb in 1.5.1.2; the growth is the larger library and the
  added bindings.

* Thread policy is unchanged: two OpenMP threads under `R CMD check`,
  set once in `.onLoad()`.

* Check time. The test suite grew with the bindings, from 971
  assertions to 3239. To keep the Windows check within the time the
  incoming checks allow, 32 test files are skipped on CRAN and run on
  GitHub Actions and locally. They cover bootstrapping (CKKS and
  Binary FHE), scheme switching, serialization of large key files, and
  the longer ports of the upstream examples; each states its reason in
  its `exit_file()` message. 2513 assertions run on CRAN.

* Possibly misspelled words in DESCRIPTION have been reported on some
  platforms (BFV, BGV, CKKS, FHEW, TFHE, Brakerski, Cheon, Chillotti,
  Ducas, Georgieva, Izabachene, Micciancio, Vaikuntanathan,
  Vercauteren, Badawi, homomorphic): all are names of cryptographic
  schemes or the surnames of their authors, spelled as published.
