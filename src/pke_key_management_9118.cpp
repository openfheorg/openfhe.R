// OPENFHE PYTHON SOURCE: src/lib/bindings.cpp (InsertEvalMultKey + single-tag clear overloads)
//
// InsertEvalMultKey + single-tag
// overloads of ClearEvalMultKeys / ClearEvalAutomorphismKeys.
//
// The no-arg forms of the clear functions are already bound
// in pke_serialization.cpp (lines 157-163). What this file adds is
// the single-tag form at cryptocontext.h lines 704 / 930, which
// clears only the key-tag-specific entry rather than the whole
// cache. Useful for checkpoint-and-resume workflows where a
// single party's keys need to be evicted without wiping the
// entire registry.
//
// InsertEvalMultKey (cryptocontext.h line 719) takes a
// std::vector<EvalKey<DCRTPoly>>. R users pass a list of EvalKey
// S7 wrappers (from R/multiparty.R); the binding walks
// the list and rebuilds the C++ vector.

#include "openfhe_cpp11.h"
#include "openfhe_helpers.h"
#include <vector>

using namespace cpp11;

// Helper: marshal a cpp11::list of external_pointer<EvalKey>
// into std::vector<EvalKey<DCRTPoly>>. Parallel to the
// list_to_ct_vec helper for Ciphertexts; distinct because
// EvalKey<DCRTPoly> and Ciphertext<DCRTPoly> are different
// typedefs on the C++ side.
static std::vector<EvalKey<DCRTPoly>> list_to_evalkey_vec(list ek_list) {
  std::vector<EvalKey<DCRTPoly>> out;
  out.reserve(ek_list.size());
  for (R_xlen_t i = 0; i < ek_list.size(); ++i) {
    SEXP ek_xp = ek_list[i];
    external_pointer<EvalKey<DCRTPoly>> ek(ek_xp);
    out.push_back(*ek);
  }
  return out;
}

// ── InsertEvalMultKey ───────────────────────────────────

[[cpp11::register]]
void CryptoContext__InsertEvalMultKey(list eval_key_list,
                                      std::string key_tag) {
  catch_openfhe("CryptoContextImpl::InsertEvalMultKey", [&]() {
    auto vec = list_to_evalkey_vec(eval_key_list);
    CryptoContextImpl<DCRTPoly>::InsertEvalMultKey(vec, key_tag);
  });
}

// ── Single-tag clear overloads ──────────────────────────

// The no-arg forms live in pke_serialization.cpp (lines
// 157-163) and are exposed via clear_fhe_state(). The
// single-tag forms land here for the tag-scoped eviction
// path that audience-A checkpoint workflows need.

[[cpp11::register]]
void CryptoContext__ClearEvalMultKeys__tag(std::string key_tag) {
  catch_openfhe("CryptoContextImpl::ClearEvalMultKeys(tag)", [&]() {
    CryptoContextImpl<DCRTPoly>::ClearEvalMultKeys(key_tag);
  });
}

[[cpp11::register]]
void CryptoContext__ClearEvalAutomorphismKeys__tag(std::string key_tag) {
  catch_openfhe("CryptoContextImpl::ClearEvalAutomorphismKeys(tag)", [&]() {
    CryptoContextImpl<DCRTPoly>::ClearEvalAutomorphismKeys(key_tag);
  });
}
