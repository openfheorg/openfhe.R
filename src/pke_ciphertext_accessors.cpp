// OPENFHE PYTHON SOURCE: src/lib/bindings.cpp (Ciphertext accessors)
//
// CiphertextImpl accessor surface + the deferred
// CryptoContext::GetScalingFactorReal helper needed by the
// fhe_ckks_tolerance() Stage 2 form.
//
// 15 new cpp11 bindings:
//   14 direct Ciphertext accessors
//    1 CryptoContext lambda-routed getter (GetScalingFactorReal)
//
// Direct Ciphertext methods are on CiphertextImpl<DCRTPoly>;
// GetCryptoContext and GetKeyTag are inherited from
// CryptoObject<Element>.
//
// Deferred to later sub-steps:
//   - Clone / CloneEmpty — rare; R users typically retain the
//     original binding for the "undo" semantics Clone provides
//   - RemoveElement, GetHopLevel / SetHopLevel — 0 usage in
//     openfhe-python examples
//   - SetEncodingType — parity-deferred
//   - GetElement / GetElements / SetElement(s) — cut-line
//     (DCRTPoly not wrapped, no R audience)
//   - Metadata accessors — cut-line (internal)
#include "openfhe_cpp11.h"
#include "openfhe_helpers.h"

using namespace cpp11;

// ── Ciphertext accessors ────────────────────────────────

[[cpp11::register]]
int Ciphertext__GetLevel(SEXP ct_xp) {
  external_pointer<Ciphertext<DCRTPoly>> ct(ct_xp);
  return catch_openfhe("Ciphertext::GetLevel", [&]() -> int {
    return static_cast<int>((*ct)->GetLevel());
  });
}

[[cpp11::register]]
void Ciphertext__SetLevel(SEXP ct_xp, int level) {
  external_pointer<Ciphertext<DCRTPoly>> ct(ct_xp);
  catch_openfhe("Ciphertext::SetLevel", [&]() {
    (*ct)->SetLevel(static_cast<size_t>(level));
  });
}

[[cpp11::register]]
int Ciphertext__GetSlots(SEXP ct_xp) {
  external_pointer<Ciphertext<DCRTPoly>> ct(ct_xp);
  return catch_openfhe("Ciphertext::GetSlots", [&]() -> int {
    return static_cast<int>((*ct)->GetSlots());
  });
}

[[cpp11::register]]
void Ciphertext__SetSlots(SEXP ct_xp, int slots) {
  external_pointer<Ciphertext<DCRTPoly>> ct(ct_xp);
  catch_openfhe("Ciphertext::SetSlots", [&]() {
    (*ct)->SetSlots(static_cast<uint32_t>(slots));
  });
}

[[cpp11::register]]
int Ciphertext__GetNoiseScaleDeg(SEXP ct_xp) {
  external_pointer<Ciphertext<DCRTPoly>> ct(ct_xp);
  return catch_openfhe("Ciphertext::GetNoiseScaleDeg", [&]() -> int {
    return static_cast<int>((*ct)->GetNoiseScaleDeg());
  });
}

[[cpp11::register]]
void Ciphertext__SetNoiseScaleDeg(SEXP ct_xp, int d) {
  external_pointer<Ciphertext<DCRTPoly>> ct(ct_xp);
  catch_openfhe("Ciphertext::SetNoiseScaleDeg", [&]() {
    (*ct)->SetNoiseScaleDeg(static_cast<size_t>(d));
  });
}

[[cpp11::register]]
double Ciphertext__GetScalingFactor(SEXP ct_xp) {
  external_pointer<Ciphertext<DCRTPoly>> ct(ct_xp);
  return catch_openfhe("Ciphertext::GetScalingFactor", [&]() -> double {
    return (*ct)->GetScalingFactor();
  });
}

[[cpp11::register]]
void Ciphertext__SetScalingFactor(SEXP ct_xp, double sf) {
  external_pointer<Ciphertext<DCRTPoly>> ct(ct_xp);
  catch_openfhe("Ciphertext::SetScalingFactor", [&]() {
    (*ct)->SetScalingFactor(sf);
  });
}

[[cpp11::register]]
double Ciphertext__GetScalingFactorInt(SEXP ct_xp) {
  external_pointer<Ciphertext<DCRTPoly>> ct(ct_xp);
  return catch_openfhe("Ciphertext::GetScalingFactorInt", [&]() -> double {
    return static_cast<double>((*ct)->GetScalingFactorInt().ConvertToInt());
  });
}

[[cpp11::register]]
void Ciphertext__SetScalingFactorInt(SEXP ct_xp, int64_t sf) {
  external_pointer<Ciphertext<DCRTPoly>> ct(ct_xp);
  catch_openfhe("Ciphertext::SetScalingFactorInt", [&]() {
    (*ct)->SetScalingFactorInt(NativeInteger(static_cast<uint64_t>(sf)));
  });
}

[[cpp11::register]]
int Ciphertext__GetEncodingType(SEXP ct_xp) {
  external_pointer<Ciphertext<DCRTPoly>> ct(ct_xp);
  return catch_openfhe("Ciphertext::GetEncodingType", [&]() -> int {
    return static_cast<int>((*ct)->GetEncodingType());
  });
}

// Ciphertext__GetCryptoContext is already bound in pke_bindings.cpp
// as a cpp11-only binding (gap-matrix §24c noted it needed
// an R wrapper). The R wrapper below is added without
// duplicating the cpp11 binding.

[[cpp11::register]]
std::string Ciphertext__GetKeyTag(SEXP ct_xp) {
  external_pointer<Ciphertext<DCRTPoly>> ct(ct_xp);
  return catch_openfhe("Ciphertext::GetKeyTag", [&]() -> std::string {
    return (*ct)->GetKeyTag();
  });
}

[[cpp11::register]]
void Ciphertext__SetKeyTag(SEXP ct_xp, std::string tag) {
  external_pointer<Ciphertext<DCRTPoly>> ct(ct_xp);
  catch_openfhe("Ciphertext::SetKeyTag", [&]() {
    (*ct)->SetKeyTag(tag);
  });
}

// ── GetScalingFactorReal ───────────
//
// Lives on CryptoParametersRNS (rns-cryptoparameters.h:610).
// Takes a level argument (default 0). Returns the double-valued
// scaling factor at that level. Used by ckks_scaling_factor_bits()
// which takes log2 of the level-0 scaling factor to recover the
// bit size set by SetScalingModSize() at construction. Reuses the
// `as_rns_params` helper (defined in
// pke_cryptocontext_getters.cpp; re-declared here with extern
// linkage to avoid a cross-file dependency).

// Forward-declare the helper to avoid multiple-definition. The
// actual implementation lives in pke_cryptocontext_getters.cpp.
extern std::shared_ptr<CryptoParametersRNS> as_rns_params(
    const std::shared_ptr<CryptoParametersBase<DCRTPoly>>& base,
    const char* op);

[[cpp11::register]]
double CryptoContext__GetScalingFactorReal(SEXP cc_xp, int level) {
  external_pointer<CryptoContext<DCRTPoly>> cc(cc_xp);
  return catch_openfhe("CryptoContext::GetScalingFactorReal", [&]() -> double {
    auto rns = as_rns_params((*cc)->GetCryptoParameters(),
                             "CryptoContext::GetScalingFactorReal");
    return rns->GetScalingFactorReal(static_cast<uint32_t>(level));
  });
}
