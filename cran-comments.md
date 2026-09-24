# CRAN submission comments — openfhe.R 1.5.1.2 (resubmission)

## Why this resubmission

This is the 1.5.1.2 submission of 2026-09-23 with one further fix. The
incoming pretest on the Debian clang flavor reported

```
* checking examples ... [23s/1s] NOTE
Examples with CPU time > 2.5 times elapsed time
                    user system elapsed  ratio
fhe_context        1.244  0.066   0.042 31.190
fhe_ckks_tolerance 3.142  0.142   0.109 30.128
encrypt            3.107  0.136   0.112 28.955
key_gen            1.571  0.057   0.093 17.505
decrypt            1.245  0.071   0.106 12.415
```

while tests and vignettes on the same run sat at 2.0. The notes from
the first submission stand and are carried below; the next section
explains the NOTE and its fix. The version number is unchanged because
the first tarball did not reach CRAN.

## Examples CPU time

The package's tests and vignettes capped OpenFHE at two OpenMP threads
by calling `set_num_threads(2L)`. The examples had no such call, so each
one ran with a team of every hardware thread on the machine, 32 on the
Debian box. The examples are small (40 to 110 ms each), and LLVM's
OpenMP runtime, which a clang build of R uses, keeps idle worker
threads spinning for 200 ms after every parallel region by default. For
the whole of a small example, therefore, all 32 workers consumed CPU,
and the ratio is the thread count. The gcc flavor's libgomp spins for
far less time, which is why only the clang flavor reported it.

Two changes:

* When the package is loaded under `R CMD check` (which sets
  `_R_CHECK_LIMIT_CORES_`; the package reads it with the same rule
  `parallel:::.check_ncores()` applies before spawning workers),
  `.onLoad()` caps OpenFHE at two threads. This is now the package's
  only cap: the explicit `set_num_threads(2L)` calls that the tests and
  vignettes carried are removed, since the load hook runs before any of
  them and also covers packages that import 'openfhe.R'. Interactive use
  is unchanged.

* `set_num_threads()` now sets the cap through OpenFHE's own thread
  controls rather than through `omp_set_num_threads()`. The bundled
  library carries upstream OpenFHE PR #1233 (a process-wide cap that
  every parallel region in the library consults, not yet in an OpenFHE
  release), replacing the one-line fork patch that 1.5.1 and 1.5.1.1
  shipped for the same purpose. The library source is otherwise the
  same as in 1.5.1.2.

I reproduced the NOTE before fixing it, rather than reasoning about it:
on a 16-core macOS machine with libomp's default 200 ms block time
restored (the Homebrew build sets it to zero) and a 32-thread team to
match the Debian box, `R CMD check --as-cran` on the 1.5.1.2 tarball
prints the same NOTE with the same examples at ratios of 13.5 to 15.4.
The resubmitted tarball under the same environment reports examples
OK, with every example between 1.5 and 2.1, and the example that
prints `get_num_threads()` shows 2.

## Test environments

All run against the tarball being submitted.

* Local: macOS Tahoe 26.6.2 (Apple Silicon), R 4.6.1 — `R CMD check
  --as-cran`: 0 ERRORs, 0 WARNINGs, 0 NOTEs, with the check platforms'
  thread environment applied (`_R_CHECK_LIMIT_CORES_=TRUE`, the test,
  vignette and example `CPU_TO_ELAPSED_THRESHOLD` gates at 2.5,
  `KMP_BLOCKTIME=200ms`, `OMP_NUM_THREADS=32`, and no
  `OMP_THREAD_LIMIT`), so that the NOTE above would appear here if it
  were still present. Tests 25s/13s, vignettes 54s/29s, examples OK.
  The bundled library was compiled from source in this check, as it is
  on CRAN.
* win-builder, R-devel (x86_64 Windows, gcc 14.3.0): passed,
  2026-09-24. A first upload of this resubmission failed to compile
  there: the wrapper now calls the library's thread controls, which are
  compiled only when the library's OpenMP define is visible, and the
  Windows configure script did not pass that define to the wrapper as
  the Unix one does. `configure.win` now does, and the wrapper refuses
  to compile if the two ever disagree again.
* The Alpine and GitHub Actions results below are for the first 1.5.1.2
  tarball. The difference between the two is confined to the library's
  thread-controls header and one `num_threads` clause, and on the R side
  to `.onLoad()`, the two thread functions, the removed
  `set_num_threads(2L)` calls, and `configure.win`.

## Notes carried over from the first submission

### The defect this release fixes

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
R error naming both classes. `inst/tinytest/test_pointer_tags.R`
replays all seventeen calls and requires each to be an error.
`bin_fhe_context()` returns an object of a new `BinFHEContext` class,
and `decrypt()` accepts the private key first as well as second,
mirroring the two `Decrypt` overloads the C++ header provides.

### Installation on musl

The check results for 1.5.1.1 list it under *Additional issues: musl*.
The bundled library's `get-call-stack.cpp` includes `<execinfo.h>`
under `#if defined(__linux__) && defined(__GNUC__)`. That header is a
glibc extension; musl-based Linux satisfies both tests and does not
have it. The guard now also requires `__has_include(<execinfo.h>)`.
Verified in an Alpine Linux container (musl, aarch64, gcc 14.2.0,
`rhub/r-minimal`): the 1.5.1.1 tarball fails there at
`get-call-stack.cpp:39` with the message the musl check reports, and
the fixed tarball installs and passes the test suite (863 assertions).

### A dependency that was not declared

The same container showed that the package's error and warning
messages go through cli functions that call rlang at run time, and that
cli lists rlang only in Suggests. `rlang` is now in Imports.

### Other environments, first tarball

* GitHub Actions: ubuntu-latest (R-devel), ubuntu-latest (release),
  macOS-latest (release), windows-latest (release) — all four passed.

## NOTE

* "checking CRAN incoming feasibility" may report the interval since
  the previous release, about one month. The reasons are given above: a
  crash-class defect and a platform on which the current release does
  not install.

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

* Thread policy: two OpenMP threads under `R CMD check`, set once in
  `.onLoad()` as described above. On the CRAN macOS build system the
  package links the libomp bundled with the CRAN distribution of R.

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
  `inst/COPYRIGHTS`) remain addressed.
