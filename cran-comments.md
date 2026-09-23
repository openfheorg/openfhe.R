# CRAN submission comments — openfhe.R 1.5.1.2

## Why this release

1.5.1.1 was published on 2026-08-23. This release, a month later,
closes a memory-safety hole at the R-to-C++ boundary that a systematic
audit of the binding surface found, and fixes the installation failure
that the musl entry under *Additional issues* reports for 1.5.1.1. No
OpenFHE library upgrade is involved; the bundled library is the same
1.5.1 source with one further one-line patch, described below.

## The defect

Every object the package hands between R and C++ (crypto contexts,
keys, plaintexts, ciphertexts, parameter objects) is an external
pointer. The bindings consumed them through
`cpp11::external_pointer<T>(SEXP)`, which checks that it received *an*
external pointer and not that the pointer is a `T`. A `Plaintext`
handle passed where a `Ciphertext` belongs was therefore reinterpreted
as one. Seventeen wrong-class calls were tried against 1.5.1.1: seven
crashed the R session (SIGSEGV, SIGBUS, or SIGABRT), four returned a
wrong answer with no error, and six were caught only because OpenFHE's
own validators happened to look at the memory first.

Every binding now consumes handles through a small wrapper that tags
the pointer with its type when it is created and refuses a mismatched,
untagged, or released handle when it is consumed, raising an ordinary
R error naming both classes. The tag is the S7 class name, so the
R-side validator compares it against `class(self)[1]` with no lookup
table. `inst/tinytest/test_pointer_tags.R` replays all seventeen
calls and requires each to be an error.

Two smaller changes follow from the same audit. `bin_fhe_context()`
returns an object of a new `BinFHEContext` class rather than the base
class, so a Boolean-circuit context and a `CryptoContext` are distinct
types and passing one for the other is an error; and `decrypt()`
accepts the private key first as well as second, mirroring the two
`Decrypt` overloads the C++ header provides.

## Installation on musl

The check results for 1.5.1.1 list it under *Additional issues: musl*.
The bundled library's `get-call-stack.cpp` includes `<execinfo.h>`
under `#if defined(__linux__) && defined(__GNUC__)`. That header is a
glibc extension; musl-based Linux satisfies both tests and does not
have it, so the C++ build stops and the package does not install.

The guard now also requires `__has_include(<execinfo.h>)`, which is
standard in C++17. Where the header is absent the file takes the same
branch that macOS and Windows builds have always taken, returning an
empty call stack. Nothing observable changes on any platform: the
function is called only from OpenFHE's exception constructor, and the
stored call stack has no readers in the library or in this package.

I verified this in an Alpine Linux container (musl, aarch64, gcc
14.2.0, R from the `rhub/r-minimal` image) rather than taking it on
trust: the 1.5.1.1 tarball as submitted to CRAN fails there at
`get-call-stack.cpp:39` with the message the musl check reports, and
the tarball being submitted installs and passes the package's test
suite.

## A dependency that was not declared

The same container, having only the packages DESCRIPTION asked for,
showed that the package's error and warning messages go through cli
functions that call rlang at run time, and that cli lists rlang only
in Suggests. On a machine without rlang every one of the package's
error paths reported "there is no package called 'rlang'" instead of
its own message. `rlang` is now in Imports.

## Test environments

All run against the tarball being submitted.

* Local: macOS Tahoe 26.6.2 (Apple Silicon), R 4.6.1 — `R CMD check
  --as-cran`: 0 ERRORs, 0 WARNINGs, 0 NOTEs. Run with the check
  platforms' own thread environment forced (`OMP_THREAD_LIMIT=2`,
  `_R_CHECK_LIMIT_CORES_=TRUE`, and the test, vignette and example
  `CPU_TO_ELAPSED_THRESHOLD` gates at 2.5), so CPU-time NOTEs that a
  default local check silently skips would appear here. None did:
  install 64s/35s, tests 23s/15s, vignettes 52s/32s, examples OK. The
  bundled library was compiled from source in this check, as it is on
  CRAN.
* Alpine Linux 3.22, musl libc, aarch64, gcc 14.2.0, cmake 3.31
  (`rhub/r-minimal` container) — installs; 863 test assertions pass.
  In the same container without rlang, installation now stops at
  dependency resolution rather than installing a package whose error
  messages cannot be raised.
* [TO FILL BEFORE UPLOAD: GitHub Actions ubuntu-latest (devel),
  ubuntu-latest (release), macOS-latest (release), windows-latest
  (release); win-builder R-devel.]

## NOTE

* "checking CRAN incoming feasibility" may report the interval since
  the previous release, about one month. The reasons are given at the
  top of this file: a crash-class defect and a platform on which the
  current release does not install.

Possibly misspelled words in DESCRIPTION have been reported on some
platforms (BFV, BGV, CKKS, FHEW, TFHE, Brakerski, Cheon, Chillotti,
Ducas, Georgieva, Izabachene, Micciancio, Vaikuntanathan,
Vercauteren, Badawi, homomorphic): all are names of cryptographic
schemes or the surnames of their authors, spelled as published.

## Notes for the reviewers

* Installed size is about 10.0 Mb (libs about 8.2 Mb) because the
  OpenFHE library is statically linked into the package's shared
  object, which is the supported way to ship it without a system
  dependency.

* Tests and vignettes cap OpenMP at 2 threads via the package's
  `set_num_threads()`, in compliance with CRAN's two-core policy —
  once in `tests/tinytest.R` and once in each vignette's `setup`
  chunk. The examples are small enough not to need it. On the CRAN
  macOS build system the package links the libomp bundled with the
  CRAN distribution of R.

* Five test files are skipped on CRAN and run everywhere else, all for
  the same wall-clock reason: three cover BinFHE bootstrapping
  (`test_binfhe_eval_function.R`, `test_binfhe_methods.R`,
  `test_binfhe_eval_sign.R`) and two cover CKKS bootstrapping
  (`test_ckks_boot_rotation.R`, `test_interactive_bootstrap.R`). Each
  states the reason in its `exit_file()` message. 863 assertions run
  on CRAN; 971 run on CI and locally.

* The four points raised in the review of the first submission
  (single-quoting 'OpenFHE', `\value` tags, commented-out example
  code, and naming every copyright holder in `Authors@R` plus
  `inst/COPYRIGHTS`) remain addressed. The new `BinFHEContext` class
  page carries a `\value` tag, and the key-first `decrypt()` order is
  covered by the existing `decrypt()` page and its executable example.
