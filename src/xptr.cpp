// R-SPECIFIC: R-visible side of the tagged external pointer in
// openfhe_cpp11.h. The S7 validator in R/openfhe-object.R calls
// xptr_type() so that constructing, say, Ciphertext(ptr = pt@ptr) fails
// at construction with a clear message instead of at first use.
#include "openfhe_cpp11.h"
using namespace cpp11;

// Tag name of an external pointer created by this package, or "" for
// anything else (NULL, a non-pointer, or a pointer from another package).
[[cpp11::register]]
std::string xptr_type(SEXP xp) {
  return openfhe_r::xptr_tag_name(xp);
}
