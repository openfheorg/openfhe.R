// OPENFHE PYTHON SOURCE: src/lib/bindings.cpp (eval-key getter fleet)
//
// four new getters on the cc-internal
// eval-key registry — the read-only diagnostic surface that
// mirrors the write surface.
//
//   CryptoContext__GetAllEvalMultKeys
//     (cryptocontext.h line 1072; returns
//      std::map<std::string, std::vector<EvalKey<DCRTPoly>>>&)
//   CryptoContext__GetEvalMultKeyVector
//     (cryptocontext.h line 1079; returns
//      const std::vector<EvalKey<DCRTPoly>>&)
//   CryptoContext__GetAllEvalAutomorphismKeys
//     (cryptocontext.h line 1085; returns
//      std::map<std::string,
//               std::shared_ptr<std::map<uint32_t, EvalKey<DCRTPoly>>>>&)
//   CryptoContext__GetAllEvalSumKeys
//     (cryptocontext.h line 1108; same return type as the
//      automorphism getter — the two share backing storage on
//      the C++ side)
//
// All four are static on CryptoContextImpl<DCRTPoly>. The
// outer `std::map<std::string, ...>` is marshalled into an R
// named list; the inner value type differs by getter.
//
// First cross-file consumer of the EvalKeyMapSP typedef
// (shared_ptr<map<uint32_t, EvalKey<DCRTPoly>>>). Redeclared
// file-locally to avoid cross-file linkage dependency on its
// translation unit — the external_pointer payload is
// wire-compatible because both files use the same underlying
// C++ typedef shape.

#include "openfhe_cpp11.h"
#include "openfhe_helpers.h"
#include <map>
#include <memory>
#include <string>
#include <vector>

using namespace cpp11;

using EvalKeyMapT  = std::map<uint32_t, EvalKey<DCRTPoly>>;
using EvalKeyMapSP = std::shared_ptr<EvalKeyMapT>;

// ── Inner-value marshallers ─────────────────────────────

// Marshal a std::vector<EvalKey<DCRTPoly>> into a cpp11 list
// of external_pointer<EvalKey<DCRTPoly>>. Each element is a
// heap-allocated copy of the shared_ptr so the R wrapper has
// owning semantics independent of the cc-internal vector.
static list evalkey_vec_to_list(const std::vector<EvalKey<DCRTPoly>>& v) {
  writable::list out(v.size());
  for (size_t i = 0; i < v.size(); ++i) {
    out[i] = external_pointer<EvalKey<DCRTPoly>>(
      new EvalKey<DCRTPoly>(v[i]));
  }
  return out;
}

// Wrap a single EvalKeyMapSP (shared_ptr<map<uint32_t,EvalKey>>)
// as an external_pointer. This is the inner-value marshaller for
// GetAllEvalAutomorphismKeys / GetAllEvalSumKeys.
static SEXP wrap_evalkey_map_sp(const EvalKeyMapSP& sp) {
  return external_pointer<EvalKeyMapSP>(new EvalKeyMapSP(sp));
}

// ── GetAllEvalMultKeys ──────────────────────────────────

[[cpp11::register]]
list CryptoContext__GetAllEvalMultKeys() {
  return catch_openfhe("CryptoContextImpl::GetAllEvalMultKeys", [&]() {
    const auto& m = CryptoContextImpl<DCRTPoly>::GetAllEvalMultKeys();
    writable::list out(m.size());
    writable::strings nms(m.size());
    size_t i = 0;
    for (const auto& kv : m) {
      nms[i] = kv.first;
      out[i] = evalkey_vec_to_list(kv.second);
      ++i;
    }
    out.attr("names") = nms;
    return out;
  });
}

// ── GetEvalMultKeyVector ────────────────────────────────

[[cpp11::register]]
list CryptoContext__GetEvalMultKeyVector(std::string key_tag) {
  return catch_openfhe("CryptoContextImpl::GetEvalMultKeyVector", [&]() {
    const auto& v = CryptoContextImpl<DCRTPoly>::GetEvalMultKeyVector(key_tag);
    return evalkey_vec_to_list(v);
  });
}

// ── GetAllEvalAutomorphismKeys ──────────────────────────

[[cpp11::register]]
list CryptoContext__GetAllEvalAutomorphismKeys() {
  return catch_openfhe("CryptoContextImpl::GetAllEvalAutomorphismKeys", [&]() {
    const auto& m = CryptoContextImpl<DCRTPoly>::GetAllEvalAutomorphismKeys();
    writable::list out(m.size());
    writable::strings nms(m.size());
    size_t i = 0;
    for (const auto& kv : m) {
      nms[i] = kv.first;
      out[i] = wrap_evalkey_map_sp(kv.second);
      ++i;
    }
    out.attr("names") = nms;
    return out;
  });
}

// ── GetAllEvalSumKeys ───────────────────────────────────

[[cpp11::register]]
list CryptoContext__GetAllEvalSumKeys() {
  return catch_openfhe("CryptoContextImpl::GetAllEvalSumKeys", [&]() {
    const auto& m = CryptoContextImpl<DCRTPoly>::GetAllEvalSumKeys();
    writable::list out(m.size());
    writable::strings nms(m.size());
    size_t i = 0;
    for (const auto& kv : m) {
      nms[i] = kv.first;
      out[i] = wrap_evalkey_map_sp(kv.second);
      ++i;
    }
    out.attr("names") = nms;
    return out;
  });
}
