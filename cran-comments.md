# CRAN submission comments — openfhe.R 1.5.1

## Resubmission

This is a resubmission. Thank you for the review. All four points are
addressed below, in the order they were raised.

### 1. Software names in single quotes

`'OpenFHE'` is now single-quoted in the `Title` field, matching the
`Description` field where it was already quoted. Both use the upstream
project's own capitalization.

### 2. Missing `\value` tags

Every exported object that generates a `\usage` section now has a
`\value` section. That is 45 help topics: the 21 exported enumeration
constants, 16 S7 class constructors, and 8 functions. In each case the
text states the class of the result and what the result means, not just
its type — for example, that an enumeration constant is a named list of
integer scalars carrying the values of the corresponding C++
enumerators, which argument of which constructor it is passed to, and
what each name selects.

Functions that exist only for their side effects say so explicitly.
`clear_fhe_state()` reads "No return value, called for side effects",
followed by a description of what is dropped. The functions that
return their first argument invisibly after mutating C++-side state —
`bin_bt_key_gen()`, `eval_bootstrap_setup()`, `eval_bootstrap_key_gen()`
and `set_length()` — say which object comes back and what side effect
was the point of the call.

### 3. Commented-out example code

The commented-out block in `?fhe_ckks_tolerance` now executes. It
builds a CKKS context, generates keys, encodes and encrypts a short
vector, and reads the tolerance back off the ciphertext.

Four further topics that had no examples at all — `?fhe_context`,
`?key_gen`, `?encrypt`, `?decrypt` — and `?make_ckks_packed_plaintext`
gained executable examples covering the same ground. No example is
wrapped in `\donttest{}`: all six together run in well under a second
on this machine, since each uses a small ring dimension and a
multiplicative depth of 2.

The examples deliberately do not manipulate the OpenMP thread count, so
that the help pages show the encryption API and nothing else. Measured
uncapped on a 16-core machine — the worst case, and looser than the
`OMP_THREAD_LIMIT=2` the check farm sets — all examples in the package
together use 0.21s of CPU over 0.14s elapsed, well under the threshold.
The thread cap is applied where the parallel work actually is, once per
artifact: `tests/tinytest.R` for the tests, and a hidden `setup` chunk
in each vignette.

### 4. Authors, contributors and copyright holders

This is the point that needed the most work, and you were right to
raise it. The previous `Authors@R` carried a single placeholder entry
reading "Authors of the OpenFHE C++ library", which named no actual
holder and omitted every third-party component bundled inside that
library.

What was done:

* **The shipped tarball was audited file by file** for copyright and
  license statements — not the development tree, the tarball, so that
  what is declared is exactly what is distributed. Twelve distinct
  copyright holders beyond the package author were found.

* **`Authors@R` now names all of them** with `ctb` and `cph` roles: NJIT
  and Duality Technologies, Inc. for OpenFHE itself; Samuel Neves and
  Jean-Philippe Aumasson for the BLAKE2 and BLAKE2X reference code
  compiled into OpenFHE's PRNG; Randolph Voorhies, Shane Grant and
  Juan Pedro Bolivar Puente for the cereal serialization headers; THL
  A29 Limited, a Tencent company, and Milo Yip for RapidJSON; Alexander
  Chemeris for the msinttypes headers bundled inside RapidJSON; Marcin
  Kalicinski for RapidXml; and Rene Nyffenegger for the base64 codec.
  The author's own entry gained `cph`, which it should have carried
  from the start.

* **`inst/COPYRIGHTS` was added** and `Copyright: file inst/COPYRIGHTS`
  declared in DESCRIPTION. It lists, for each holder, the exact files
  covered, the license those files carry, and where the full license
  text lives in the tarball. It also records two acknowledgments that
  are not separate copyright claims and so are deliberately absent from
  `Authors@R`: the Boost serialization notices (Robert Ramey, David
  Abrahams) that cereal cites as inspiration in three of its headers,
  and the fact that this package's binding layer was written by
  consulting openfhe-python alongside the C++ headers.

* **`inst/openfhe/LICENSE` now ships.** It had been excluded by
  `.Rbuildignore` in the previous submission, so OpenFHE's BSD-2 license
  text was absent while 366 of its source files were present. The
  per-file license headers were intact, but the license file itself
  should have been there. It is now.

* **Unused parts of the bundled cereal tree no longer ship.** The build
  puts `cereal/include` on the compiler's include path and reads nothing
  else, so `cereal/unittests`, `sandbox`, `doc` and `scripts` were dead
  weight. Removing them also removes bundled copies of doctest (Viktor
  Kirilov) and of cereal's Boost-variant tests (Kyle Fleming) — code
  that was never compiled, and whose holders therefore no longer need
  declaring. The doctest copy also referenced a `LICENSE.txt` that was
  not present anywhere in the tree; dropping it resolves that.

No source files were modified in the vendored trees: every upstream
copyright and license header is preserved byte for byte.

## Test environments

All of the following were run against the tarball being submitted, not
against an earlier one.

* Local: macOS (Apple Silicon), R 4.6.1 — `R CMD check --as-cran`:
  0 ERRORs, 0 WARNINGs, 1 NOTE. This check is run with the check
  farm's own thread environment forced (`OMP_THREAD_LIMIT=2`,
  `_R_CHECK_LIMIT_CORES_=TRUE`, and the test, vignette and example
  `CPU_TO_ELAPSED_THRESHOLD` gates at 2.5), so the CPU-time NOTEs that
  a default local check silently skips would be reported here. None
  appeared at any stage: tests 60s/36s, vignettes 50s/31s, examples OK.
* mac-builder (r-release, arm64): passed.
* win-builder (R-devel): passed.
* GitHub Actions: ubuntu-latest (devel), ubuntu-latest (release),
  macOS-latest (release), windows-latest (release) — all four passed.

## NOTEs

* "checking CRAN incoming feasibility" — two items:

  - "New submission", the first submission of this package.

  - One URL, `https://openfhe-development.readthedocs.io/`, cited in
    two vignettes, reported as possibly invalid with status 429 (Too
    Many Requests). That is Read the Docs rate-limiting the checker,
    not a dead link; the page resolves normally in a browser.

* Possibly misspelled words in DESCRIPTION have been reported on some
  platforms (BFV, BGV, CKKS, FHEW, TFHE, Brakerski, Cheon, Chillotti,
  Ducas, Georgieva, Izabachene, Micciancio, Vaikuntanathan,
  Vercauteren, Badawi, homomorphic): all are names of cryptographic
  schemes or the surnames of their authors, spelled as published.

## Notes for the reviewers

* Installed size is about 9.8 Mb (libs about 8 Mb) because the OpenFHE
  library is statically linked into the package's shared object, which
  is the supported way to ship it without a system dependency.

* Tests and vignettes cap OpenMP at 2 threads via the package's
  `set_num_threads()`, in compliance with CRAN's two-core policy —
  once in `tests/tinytest.R` and once in each vignette's `setup`
  chunk. The examples are small enough not to need it (0.21s CPU over
  0.14s elapsed for all of them, uncapped, on 16 cores). On the CRAN
  macOS build system the package links the libomp bundled with the
  CRAN distribution of R.
