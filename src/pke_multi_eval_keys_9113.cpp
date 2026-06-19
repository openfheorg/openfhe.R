// OPENFHE PYTHON SOURCE: src/lib/bindings.cpp (Multi-eval-key generators + EvalKeyMap helpers)
//
// the multi-eval-key family plus the
// EvalKeyMap get/insert helpers that make it end-to-end
// testable. Nine new cpp11 bindings.
//
// Multi-eval-key generators (3):
//   MultiEvalAutomorphismKeyGen (cryptocontext.h line 3185)
//   MultiEvalAtIndexKeyGen      (cryptocontext.h line 3206)
//   MultiEvalSumKeyGen          (cryptocontext.h line 3226)
//
// Multi-eval-key adders (2):
//   MultiAddEvalSumKeys          (cryptocontext.h line 3278)
//   MultiAddEvalAutomorphismKeys (cryptocontext.h line 3296)
//
// EvalKeyMap get/insert helpers (4), all static on CryptoContextImpl:
//   GetEvalSumKeyMap             (cryptocontext.h line 1115,
//     returns const std::map& so we wrap via make_shared to lift
//     into the same EvalKeyMapSP wire format the rest of this
//     file produces)
//   GetEvalAutomorphismKeyMapPtr (cryptocontext.h line 1092,
//     already returns a shared_ptr)
//   InsertEvalSumKey             (cryptocontext.h line 784 —
//     delegates internally to InsertEvalAutomorphismKey, but
//     R exposes both names to match the Python surface)
//   InsertEvalAutomorphismKey    (cryptocontext.h line 946)
//
// EvalKeyMap wire format: the R-facing external_pointer holds a
// heap-allocated std::shared_ptr<std::map<uint32_t, EvalKey<DCRTPoly>>>.
// The cpp11 external_pointer deleter calls delete on the
// heap-allocated shared_ptr; the shared_ptr destructor decrements
// the map refcount. This matches how Ciphertext<DCRTPoly> (itself
// a typedef for shared_ptr<CiphertextImpl<DCRTPoly>>) is wrapped
// throughout the rest of the bindings.
//
// All 9 call sites wrap in catch_openfhe per design.md §5.

#include "openfhe_cpp11.h"
#include "openfhe_helpers.h"
#include <map>
#include <memory>
#include <vector>

using namespace cpp11;

using EvalKeyMapT  = std::map<uint32_t, EvalKey<DCRTPoly>>;
using EvalKeyMapSP = std::shared_ptr<EvalKeyMapT>;

// ── Multi-eval-key generators ───────────────────────────

[[cpp11::register]]
SEXP MultiEvalAutomorphismKeyGen__(SEXP cc_xp, SEXP sk_xp, SEXP map_xp,
                                   integers index_list, std::string key_tag) {
  external_pointer<CryptoContext<DCRTPoly>> cc(cc_xp);
  external_pointer<PrivateKey<DCRTPoly>> sk(sk_xp);
  external_pointer<EvalKeyMapSP> map_sp(map_xp);
  return catch_openfhe("CryptoContext::MultiEvalAutomorphismKeyGen", [&]() {
    std::vector<uint32_t> indices;
    indices.reserve(index_list.size());
    for (R_xlen_t i = 0; i < index_list.size(); ++i) {
      indices.push_back(static_cast<uint32_t>(index_list[i]));
    }
    auto result = (*cc)->MultiEvalAutomorphismKeyGen(*sk, *map_sp, indices, key_tag);
    return external_pointer<EvalKeyMapSP>(new EvalKeyMapSP(result));
  });
}

[[cpp11::register]]
SEXP MultiEvalAtIndexKeyGen__(SEXP cc_xp, SEXP sk_xp, SEXP map_xp,
                              integers index_list, std::string key_tag) {
  external_pointer<CryptoContext<DCRTPoly>> cc(cc_xp);
  external_pointer<PrivateKey<DCRTPoly>> sk(sk_xp);
  external_pointer<EvalKeyMapSP> map_sp(map_xp);
  return catch_openfhe("CryptoContext::MultiEvalAtIndexKeyGen", [&]() {
    std::vector<int32_t> indices;
    indices.reserve(index_list.size());
    for (R_xlen_t i = 0; i < index_list.size(); ++i) {
      indices.push_back(static_cast<int32_t>(index_list[i]));
    }
    auto result = (*cc)->MultiEvalAtIndexKeyGen(*sk, *map_sp, indices, key_tag);
    return external_pointer<EvalKeyMapSP>(new EvalKeyMapSP(result));
  });
}

[[cpp11::register]]
SEXP MultiEvalSumKeyGen__(SEXP cc_xp, SEXP sk_xp, SEXP map_xp,
                          std::string key_tag) {
  external_pointer<CryptoContext<DCRTPoly>> cc(cc_xp);
  external_pointer<PrivateKey<DCRTPoly>> sk(sk_xp);
  external_pointer<EvalKeyMapSP> map_sp(map_xp);
  return catch_openfhe("CryptoContext::MultiEvalSumKeyGen", [&]() {
    auto result = (*cc)->MultiEvalSumKeyGen(*sk, *map_sp, key_tag);
    return external_pointer<EvalKeyMapSP>(new EvalKeyMapSP(result));
  });
}

// ── Multi-eval-key adders ───────────────────────────────

[[cpp11::register]]
SEXP MultiAddEvalSumKeys__(SEXP cc_xp, SEXP map1_xp, SEXP map2_xp,
                           std::string key_tag) {
  external_pointer<CryptoContext<DCRTPoly>> cc(cc_xp);
  external_pointer<EvalKeyMapSP> map1(map1_xp);
  external_pointer<EvalKeyMapSP> map2(map2_xp);
  return catch_openfhe("CryptoContext::MultiAddEvalSumKeys", [&]() {
    auto result = (*cc)->MultiAddEvalSumKeys(*map1, *map2, key_tag);
    return external_pointer<EvalKeyMapSP>(new EvalKeyMapSP(result));
  });
}

[[cpp11::register]]
SEXP MultiAddEvalAutomorphismKeys__(SEXP cc_xp, SEXP map1_xp, SEXP map2_xp,
                                    std::string key_tag) {
  external_pointer<CryptoContext<DCRTPoly>> cc(cc_xp);
  external_pointer<EvalKeyMapSP> map1(map1_xp);
  external_pointer<EvalKeyMapSP> map2(map2_xp);
  return catch_openfhe("CryptoContext::MultiAddEvalAutomorphismKeys", [&]() {
    auto result = (*cc)->MultiAddEvalAutomorphismKeys(*map1, *map2, key_tag);
    return external_pointer<EvalKeyMapSP>(new EvalKeyMapSP(result));
  });
}

// ── EvalKeyMap get helpers ──────────────────────────────

// GetEvalSumKeyMap returns `const std::map&` — copy into a fresh
// shared_ptr so the R-side wrapper has owning semantics and the
// cc's internal registry is not exposed by raw reference.
[[cpp11::register]]
SEXP CryptoContext__GetEvalSumKeyMap(std::string key_tag) {
  return catch_openfhe("CryptoContextImpl::GetEvalSumKeyMap", [&]() {
    const auto& map_ref =
      CryptoContextImpl<DCRTPoly>::GetEvalSumKeyMap(key_tag);
    EvalKeyMapSP sp = std::make_shared<EvalKeyMapT>(map_ref);
    return external_pointer<EvalKeyMapSP>(new EvalKeyMapSP(sp));
  });
}

// GetEvalAutomorphismKeyMapPtr already returns a shared_ptr — no
// copy needed, just wrap.
[[cpp11::register]]
SEXP CryptoContext__GetEvalAutomorphismKeyMapPtr(std::string key_tag) {
  return catch_openfhe("CryptoContextImpl::GetEvalAutomorphismKeyMapPtr", [&]() {
    EvalKeyMapSP sp =
      CryptoContextImpl<DCRTPoly>::GetEvalAutomorphismKeyMapPtr(key_tag);
    return external_pointer<EvalKeyMapSP>(new EvalKeyMapSP(sp));
  });
}

// ── EvalKeyMap insert helpers ───────────────────────────

// InsertEvalSumKey delegates to InsertEvalAutomorphismKey
// internally (same static storage). Exposing both names at the
// R layer matches the Python surface.
[[cpp11::register]]
void CryptoContext__InsertEvalSumKey(SEXP map_xp, std::string key_tag) {
  external_pointer<EvalKeyMapSP> map_sp(map_xp);
  catch_openfhe("CryptoContextImpl::InsertEvalSumKey", [&]() {
    CryptoContextImpl<DCRTPoly>::InsertEvalSumKey(*map_sp, key_tag);
  });
}

[[cpp11::register]]
void CryptoContext__InsertEvalAutomorphismKey(SEXP map_xp, std::string key_tag) {
  external_pointer<EvalKeyMapSP> map_sp(map_xp);
  catch_openfhe("CryptoContextImpl::InsertEvalAutomorphismKey", [&]() {
    CryptoContextImpl<DCRTPoly>::InsertEvalAutomorphismKey(*map_sp, key_tag);
  });
}
