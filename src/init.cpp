// R-SPECIFIC: package init + utility functions
#include "openfhe_cpp11.h"
#ifdef _OPENMP
#include <omp.h>
#endif

// Thread control. omp_set_num_threads() writes the live OpenMP nthreads-var
// ICV, shared with the linked OpenFHE library. This is only effective
// because our r_pkg fork patches OpenFHEParallelControls::GetThreadLimit to
// clamp by the live omp_get_max_threads() (see inst/openfhe parallel.h);
// stock OpenFHE caches its thread count at library load and overrides the
// ICV via num_threads(...) clauses, so a runtime call would be ignored.
[[cpp11::register]]
void openfhe_set_num_threads(int n) {
#ifdef _OPENMP
  omp_set_num_threads(n);
#else
  (void)n;
#endif
}

[[cpp11::register]]
int openfhe_get_num_threads() {
#ifdef _OPENMP
  return omp_get_max_threads();
#else
  return 1;
#endif
}

[[cpp11::register]]
int openfhe_native_int() {
#if NATIVEINT == 128
  return 128;
#else
  return 64;
#endif
}
