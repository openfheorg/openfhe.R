// OPENFHE PYTHON SOURCE: src/lib/bindings.cpp (CKKS boot correction factor + EvalFastRotationExt + 3-arg EvalFastRotation convenience)
//
// three pieces.
//
// 1. CKKS bootstrap correction factor accessors (trivial
//    scalar getter/setter on CryptoContextImpl, cryptocontext.h
//    lines 3617 / 3621). Enables programmatic control of the
//    bootstrap correction factor, which user-facing code
//    currently can only set via the EvalBootstrapSetup
//    `correctionFactor` argument at setup time — this pair
//    exposes the post-setup read/write path.
//
// 2. EvalFastRotationExt (cryptocontext.h line 2409). Unlike
//    the plan's expectation, the public API is 4-arg
//    `(ciphertext, index, digits, addFirst)` — the eval-key
//    map is pulled from the cc-internal registry via
//    `CryptoContextImpl::GetEvalAutomorphismKeyMap(ct->GetKeyTag())`
//    inside the method body (header line 2411). R users
//    don't pass an EvalKeyMap; the EvalKeyMap wire format is
//    not needed cross-file here, so the EvalKeyMap typedef
//    promotion risk does not apply.
//
// 3. EvalFastRotation 3-argument convenience overload
//    (cryptocontext.h line 2395). The existing binding at
//    pke_bindings.cpp line 391 is the 4-arg form
//    `(ct, index, m, precomp)`. The 3-arg convenience form
//    is a separate header overload that computes
//    `m = GetRingDimension() * 2` internally. Bound here as
//    a distinct symbol so the R wrapper can switch on the
//    presence/absence of `m` at the R layer and route to
//    the right binding. Closes design.md §11 open question
//    #1 (phantom 3-arg EvalFastRotation is NOT a Python
//    defect — the C++ header declares both overloads).

#include "openfhe_cpp11.h"
#include "openfhe_helpers.h"

using namespace cpp11;

// FastRotationPrecomp is declared in pke_bindings.cpp at ~line
// 379 as `shared_ptr<vector<DCRTPoly>>`. Redeclare the same
// typedef file-locally here to avoid depending on internal
// linkage from pke_bindings.cpp. Both files wrap the same
// underlying C++ type, so the external_pointer payload is
// interoperable — a precomp created by EvalFastRotationPrecompute
// in pke_bindings.cpp can be passed to EvalFastRotationExt
// bound here.
using FastRotationPrecomp = std::shared_ptr<std::vector<DCRTPoly>>;

// ── CKKS boot correction factor ─────────────────────────

[[cpp11::register]]
int CryptoContext__GetCKKSBootCorrectionFactor(SEXP cc_xp) {
  external_pointer<CryptoContext<DCRTPoly>> cc(cc_xp);
  return catch_openfhe("CryptoContext::GetCKKSBootCorrectionFactor", [&]() {
    return static_cast<int>((*cc)->GetCKKSBootCorrectionFactor());
  });
}

[[cpp11::register]]
void CryptoContext__SetCKKSBootCorrectionFactor(SEXP cc_xp, int cf) {
  external_pointer<CryptoContext<DCRTPoly>> cc(cc_xp);
  catch_openfhe("CryptoContext::SetCKKSBootCorrectionFactor", [&]() {
    (*cc)->SetCKKSBootCorrectionFactor(static_cast<uint32_t>(cf));
  });
}

// ── EvalFastRotationExt ─────────────────────────────────

// The `add_first` flag controls whether the first digit of the
// decomposition is added to the output before the rotation is
// applied. See openfhe-development src/pke/lib/scheme/base-scheme.cpp
// for the semantics. The eval-key map is pulled from the cc
// registry via GetEvalAutomorphismKeyMap(ct->GetKeyTag())
// inside the CryptoContextImpl method, so the R caller does
// not need to hold an EvalKeyMap.
[[cpp11::register]]
SEXP EvalFastRotationExt__(SEXP ct_xp, int index, SEXP precomp_xp,
                           bool add_first) {
  external_pointer<Ciphertext<DCRTPoly>> ct(ct_xp);
  external_pointer<FastRotationPrecomp> precomp(precomp_xp);
  return catch_openfhe("CryptoContext::EvalFastRotationExt", [&]() {
    auto cc = (*ct)->GetCryptoContext();
    auto result = cc->EvalFastRotationExt(*ct,
      static_cast<uint32_t>(index),
      *precomp,
      add_first);
    return external_pointer<Ciphertext<DCRTPoly>>(
      new Ciphertext<DCRTPoly>(result));
  });
}

// ── EvalFastRotation 3-argument convenience overload ────

// Companion to the existing 4-arg binding in pke_bindings.cpp.
// The C++ header (cryptocontext.h line 2395) declares this as a
// convenience that calls the 4-arg form with
// `m = GetRingDimension() * 2`. Binding it as a distinct symbol
// lets the R wrapper switch on the presence of `m` and dispatch
// to whichever form matches the caller's intent.
[[cpp11::register]]
SEXP EvalFastRotation__3arg(SEXP ct_xp, int index, SEXP precomp_xp) {
  external_pointer<Ciphertext<DCRTPoly>> ct(ct_xp);
  external_pointer<FastRotationPrecomp> precomp(precomp_xp);
  return catch_openfhe("CryptoContext::EvalFastRotation(3-arg)", [&]() {
    auto cc = (*ct)->GetCryptoContext();
    auto result = cc->EvalFastRotation(*ct,
      static_cast<uint32_t>(index),
      *precomp);
    return external_pointer<Ciphertext<DCRTPoly>>(
      new Ciphertext<DCRTPoly>(result));
  });
}
