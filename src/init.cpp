// R-SPECIFIC: package init + utility functions
#include "openfhe_cpp11.h"
#include "config_core.h"
#include "utils/parallel.h"

// The library compiles ParallelControls under -DPARALLEL (set by its CMake
// exactly when WITH_OPENMP is on). Its inline bodies and its class layout
// both change under that define, so this translation unit must see the
// same value or the call below silently does nothing. configure derives
// -DPARALLEL from the installed config_core.h; this check makes a mismatch
// a build failure rather than an uncapped CRAN check.
#if defined(WITH_OPENMP) && !defined(PARALLEL)
#error "OpenFHE was built WITH_OPENMP but PARALLEL is not defined for the wrapper"
#endif
#if !defined(WITH_OPENMP) && defined(PARALLEL)
#error "PARALLEL is defined for the wrapper but OpenFHE was built without OpenMP"
#endif

// Thread control goes through OpenFHE's own OpenFHEParallelControls.
// SetNumThreads() clamps the request to [1, machineThreads] (the count
// latched from omp_get_max_threads() at library load), stores it in a
// process-global atomic that every library parallel region reads through
// its num_threads(GetThreadLimit(n)) clause, and also sets the OpenMP ICV.
// A bare omp_set_num_threads() is not enough: the explicit clauses
// override the ICV, and the ICV is thread-local, so regions started from
// worker threads would escape it. (Upstream OpenFHE PR #1233, carried on
// the r_pkg branch until a release contains it.) Returns the cap in
// effect after the clamp, so R can report a silent reduction.
[[cpp11::register]]
int openfhe_set_num_threads(int n) {
  lbcrypto::OpenFHEParallelControls.SetNumThreads(n);
  return lbcrypto::OpenFHEParallelControls.GetNumThreads();
}

// The cap the library will apply; 1 when built without OpenMP.
[[cpp11::register]]
int openfhe_get_num_threads() {
  return lbcrypto::OpenFHEParallelControls.GetNumThreads();
}

[[cpp11::register]]
int openfhe_native_int() {
#if NATIVEINT == 128
  return 128;
#else
  return 64;
#endif
}
