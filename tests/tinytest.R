# Cap OpenMP to CRAN's two-core policy. set_num_threads() writes the live
# OpenMP ICV, which the r_pkg OpenFHE fork honors (GetThreadLimit clamps by
# omp_get_max_threads()), so this caps the library's parallel regions
# immediately and on every platform -- unlike an OMP_NUM_THREADS env var,
# which the runtime latches before this file can run.
library(openfhe.R)
set_num_threads(2L)
if (requireNamespace("tinytest", quietly = TRUE)) {
  tinytest::test_package("openfhe.R")
}
