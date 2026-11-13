# No thread cap here on purpose. Under R CMD check the package caps
# OpenFHE at CRAN's two threads in .onLoad() (keyed on
# _R_CHECK_LIMIT_CORES_, which --as-cran sets); outside a check the tests
# should use whatever the machine has.
#
# The files are run one at a time with a garbage collection after each,
# not with one call to tinytest::test_package(). A context with its keys
# can hold gigabytes that R's collector does not see, so without the
# collections the memory of every finished file stays until R happens to
# collect, and the full suite needs several times the memory of its
# largest file (notes/discoveries/D043).
library(openfhe.R)
if (requireNamespace("tinytest", quietly = TRUE)) {
  files <- list.files(system.file("tinytest", package = "openfhe.R"),
                      pattern = "^test.*[.][rR]$", full.names = TRUE)
  n_pass <- 0L
  failed <- list()
  for (f in files) {
    ## at_home = FALSE is what test_package() passes; the heavy files
    ## decide for themselves from at_home() and the CI variable.
    res <- tinytest::run_test_file(f, at_home = FALSE, verbose = 0L)
    ok <- vapply(res, isTRUE, logical(1L))
    n_pass <- n_pass + sum(ok)
    failed <- c(failed, res[!ok])
    rm(res)
    invisible(gc())
  }
  cat(sprintf("%d files, %d results, %d failed\n",
              length(files), n_pass + length(failed), length(failed)))
  if (length(failed) > 0L) {
    for (r in failed) print(r)
    stop(sprintf("%d test result(s) failed", length(failed)))
  }
}
