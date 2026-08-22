# CRAN submission comments — openfhe.R 1.5.1.1

## Why this release follows 1.5.1 so closely

1.5.1 was accepted on 2026-08-21. This release exists because the
check platforms found a real defect in it the following day, and I
would rather fix it now than leave it on CRAN.

Both the gcc-UBSAN and the M1-SAN platforms reported undefined
behavior in the bundled OpenFHE C++ library:

```
inst/openfhe/src/binfhe/lib/rgsw-acc.cpp:72:21: runtime error:
  left shift of 16776961 by 57 places cannot be represented in
  type 'long'
inst/openfhe/src/binfhe/lib/rgsw-acc.cpp:75:21: runtime error:
  left shift of negative value -16776961
```

and two more of the same kind at lines 79 and 85. Both platforms
reported `Status: OK` overall; the diagnostics were printed during
`tests/tinytest.R` and, on the gcc platform, during the vignette
rebuild.

If a shorter interval than usual is not acceptable, I am happy to
have this held; but the fix is small and self-contained, and the
alternative is knowingly leaving undefined behavior in place.

## The defect

`RingGSWAccumulator::SignedDigitDecompose` extracts a balanced digit
by sign-extending through a pair of shifts:

```cpp
auto r0{(d0 << gBitsMaxBits) >> gBitsMaxBits};
```

`d0` is a signed centered residue and `gBitsMaxBits` is
`NativeInteger::MaxBits() - gBits`, so the left shift both operates on
a negative value and produces a result outside the range of the signed
type. C++17 leaves both undefined, which is why the two message forms
above alternate between runs. The path is reached on the first
bootstrapped gate, through `EvalBinGate` → `BootstrapGateCore` →
`EvalAcc` → `AddToAccCGGI`.

## The fix

Upstream OpenFHE had already fixed this — issue #1226, pull request
#1238, merged 2026-08-05 — but the fix is not yet in a tagged OpenFHE
release, so 1.5.1 vendored the unfixed source. The bundled library now
carries that upstream commit, which computes the same digits from an
unsigned biased representation and so performs no signed shifts at
all. No code in the R package changed.

Results are unchanged. Every test produces the same values as before,
and upstream states the rewrite is bit-identical.

I verified this locally rather than taking it on trust. The package
was built twice under `-fsanitize=undefined` with gcc 16.2.1 on
Fedora 44, from two tarballs differing in exactly one file:

```
                                   before      after
sanitizer diagnostics                  30          0
distinct source locations               6          0
BinFHE assertions passing              85         85
```

The "6" is worth one remark. The check platforms report four
locations; there are six. Lines 109 and 113 are the same construct in
a second overload, and they are not reachable on CRAN because the
tests that exercise them call `exit_file()` there (see below). The
upstream fix covers all six.

## Also in this release

`inst/tinytest/test_binfhe_eval_sign.R` now carries the same
CRAN-skip guard that four other bootstrapping-heavy test files
already had. That file generated a set of BinFHE bootstrap keys at
the `STD128` parameter set, which was by a wide margin the most
expensive single operation in the package's tests, and it took the
`checking tests` stage on the Windows check platform to 227s. The
test is not weakened or deleted: it runs in full, at `STD128` with
all eight inputs, on GitHub Actions and locally under
`tinytest::test_all()`.

`vignettes/binfhe-boolean-circuits.Rmd` gained a paragraph and a
correction. It had said the large-Q `eval_sign()` path requires the
`STD128` parameter set "(not TOY)". That is not accurate: `TOY` works
on that path, and what is true is that `TOY` and `STD128` are the only
two sets the C++ layer accepts there. The added paragraph explains why
that section uses `STD128` while earlier sections use `TOY`. No code
in the vignette changed and no computed output changed.

## Test environments

All run against the tarball being submitted.

* Local: macOS (Apple Silicon), R 4.6.1 — `R CMD check --as-cran`:
  0 ERRORs, 0 WARNINGs, 1 NOTE. Run with the check platforms' own
  thread environment forced (`OMP_THREAD_LIMIT=2`,
  `_R_CHECK_LIMIT_CORES_=TRUE`, and the test, vignette and example
  `CPU_TO_ELAPSED_THRESHOLD` gates at 2.5), so CPU-time NOTEs that a
  default local check silently skips would appear here. None did:
  install 58s/33s, tests 21s/13s, vignettes 49s/29s, examples OK.
* Fedora 44, gcc 16.2.1, `-fsanitize=undefined` (container) — the
  reproduction described above. Clean after the fix.
* GitHub Actions: ubuntu-latest (devel), ubuntu-latest (release),
  macOS-latest (release), windows-latest (release). These are the
  environments where the bootstrapping-heavy tests still run in full.

## NOTE

* "checking CRAN incoming feasibility" reports `Days since last
  update: 1`. That is the interval explained at the top of this file.

Possibly misspelled words in DESCRIPTION have been reported on some
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
  chunk. The examples are small enough not to need it. On the CRAN
  macOS build system the package links the libomp bundled with the
  CRAN distribution of R.

* Five test files are skipped on CRAN and run everywhere else, all for
  the same wall-clock reason: three cover BinFHE bootstrapping
  (`test_binfhe_eval_function.R`, `test_binfhe_methods.R`,
  `test_binfhe_eval_sign.R`) and two cover CKKS bootstrapping
  (`test_ckks_boot_rotation.R`, `test_interactive_bootstrap.R`). Each
  states the reason in its `exit_file()` message. 825 assertions run
  on CRAN; 894 run on CI and locally.

* The four points raised in the review of the first submission
  (single-quoting 'OpenFHE', `\value` tags, commented-out example
  code, and naming every copyright holder in `Authors@R` plus
  `inst/COPYRIGHTS`) remain addressed. Nothing in this release
  touches them.
