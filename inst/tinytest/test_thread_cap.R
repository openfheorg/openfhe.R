## R-SPECIFIC: the thread cap the package applies under R CMD check
## (R/zzz.R .onLoad, set_num_threads(), get_num_threads())
## @openfhe-python: NONE — openfhe-python has no thread cap of its own;
## this guards CRAN's two-core limit for tests, examples and vignettes.

suppressPackageStartupMessages(library(openfhe.R))

# ── The cap in force ────────────────────────────────────

## .onLoad() caps OpenFHE at two threads when _R_CHECK_LIMIT_CORES_ is
## set and not "false", the rule R CMD check --as-cran uses. Read the
## live value: a cap that was set and did not take must fail here.
chk <- tolower(Sys.getenv("_R_CHECK_LIMIT_CORES_", ""))
under_check <- nzchar(chk) && chk != "false"
n <- get_num_threads()
if (under_check) {
  expect_true(n <= 2L,
              info = sprintf("under R CMD check, threads in use: %d", n))
} else {
  expect_true(n >= 1L)
}

# ── set_num_threads() reaches the library ───────────────

set_num_threads(1L)
expect_identical(get_num_threads(), 1L)
set_num_threads(n)
expect_identical(get_num_threads(), n)
