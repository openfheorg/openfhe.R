# No thread cap here on purpose. Under R CMD check the package caps
# OpenFHE at CRAN's two threads in .onLoad() (keyed on
# _R_CHECK_LIMIT_CORES_, which --as-cran sets); outside a check the tests
# should use whatever the machine has.
library(openfhe.R)
if (requireNamespace("tinytest", quietly = TRUE)) {
  tinytest::test_package("openfhe.R")
}
