// OPENFHE PYTHON SOURCE: src/lib/bindings.cpp (miscellaneous)
//
// Small helpers that are
// called out in design.md §10 but that don't fit any
// of the larger per-category files (setters, getters, accessors,
// factories). One file so the surface is contained.
//
// Bindings in this file:
//   CryptoContext__Encrypt_PrivateKey    — secret-key encryption overload
//   CryptoContext__Enable_Mask           — uint32 feature mask overload
//   CryptoContext__GetSchemeId           — scheme identifier on a cc
//   CryptoContext__ClearStaticMapsAndVectors — static cleanup helper
//   PublicKey__GetKeyTag, PublicKey__SetKeyTag
//   PrivateKey__GetKeyTag, PrivateKey__SetKeyTag
//   KeyPair__IsGood                      — good() predicate
#include "openfhe_cpp11.h"
#include "openfhe_helpers.h"

using namespace cpp11;

// ── Encrypt via PrivateKey (secret-key encryption) ──────

[[cpp11::register]]
SEXP CryptoContext__Encrypt_PrivateKey(SEXP cc_xp, SEXP sk_xp, SEXP pt_xp) {
  external_pointer<CryptoContext<DCRTPoly>> cc(cc_xp);
  external_pointer<PrivateKey<DCRTPoly>> sk(sk_xp);
  external_pointer<Plaintext> pt(pt_xp);
  return catch_openfhe("CryptoContext::Encrypt(PrivateKey)", [&]() {
    auto ct = (*cc)->Encrypt(*sk, *pt);
    return external_pointer<Ciphertext<DCRTPoly>>(
        new Ciphertext<DCRTPoly>(ct));
  });
}

// ── Enable via uint32 feature mask ──────────────────────

[[cpp11::register]]
void CryptoContext__Enable_Mask(SEXP cc_xp, int mask) {
  external_pointer<CryptoContext<DCRTPoly>> cc(cc_xp);
  catch_openfhe("CryptoContext::Enable(mask)", [&]() {
    (*cc)->Enable(static_cast<uint32_t>(mask));
  });
}

// ── Scheme identifier on CryptoContext ──────────────────

[[cpp11::register]]
int CryptoContext__GetSchemeId(SEXP cc_xp) {
  external_pointer<CryptoContext<DCRTPoly>> cc(cc_xp);
  return catch_openfhe("CryptoContext::getSchemeId", [&]() -> int {
    return static_cast<int>((*cc)->getSchemeId());
  });
}

// ── Static maps cleanup ─────────────────────────────────

[[cpp11::register]]
void CryptoContext__ClearStaticMapsAndVectors() {
  catch_openfhe("CryptoContextImpl::ClearStaticMapsAndVectors", [&]() {
    CryptoContextImpl<DCRTPoly>::ClearStaticMapsAndVectors();
  });
}

// ── PublicKey / PrivateKey key-tag accessors ────────────

[[cpp11::register]]
std::string PublicKey__GetKeyTag(SEXP key_xp) {
  external_pointer<PublicKey<DCRTPoly>> key(key_xp);
  return catch_openfhe("PublicKey::GetKeyTag", [&]() -> std::string {
    return (*key)->GetKeyTag();
  });
}

[[cpp11::register]]
void PublicKey__SetKeyTag(SEXP key_xp, std::string tag) {
  external_pointer<PublicKey<DCRTPoly>> key(key_xp);
  catch_openfhe("PublicKey::SetKeyTag", [&]() {
    (*key)->SetKeyTag(tag);
  });
}

[[cpp11::register]]
std::string PrivateKey__GetKeyTag(SEXP key_xp) {
  external_pointer<PrivateKey<DCRTPoly>> key(key_xp);
  return catch_openfhe("PrivateKey::GetKeyTag", [&]() -> std::string {
    return (*key)->GetKeyTag();
  });
}

[[cpp11::register]]
void PrivateKey__SetKeyTag(SEXP key_xp, std::string tag) {
  external_pointer<PrivateKey<DCRTPoly>> key(key_xp);
  catch_openfhe("PrivateKey::SetKeyTag", [&]() {
    (*key)->SetKeyTag(tag);
  });
}

// KeyPair is a pure-R aggregate (see R/keys.R), not a wrapped
// external pointer, so there is no KeyPair__IsGood cpp11 binding
// to add. The R-side KeyPair constructor only produces objects
// that already hold valid PublicKey + PrivateKey, so a KeyPair
// with null `public` or null `secret` would require explicit
// construction by a caller bypassing the constructor. The
// user-facing good() predicate lives in R as
// `is_good(kp)` — see R/keys.R.
