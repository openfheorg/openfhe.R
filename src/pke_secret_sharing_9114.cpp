// OPENFHE PYTHON SOURCE: NONE — ShareKeys/RecoverSharedKey are R-first bindings
//
// openfhe-python v1.5.1.0 does not bind ShareKeys or
// RecoverSharedKey. The R package binds them here and tracks
// the gap in notes/upstream-defects.md. Future
// three-way parity harness runs should mark these two methods
// as "R-only" and skip the Python comparison.
//
// vector-form distributed decryption +
// secret sharing. Four new cpp11 bindings:
//
//   MultipartyDecryptLead__ct_vec  (cryptocontext.h line 3115,
//     original signature takes vector<Ciphertext>; the single-ct
//     form wraps into a 1-element vector internally.
//     We expose the list-taking form so a batch of
//     ciphertexts can be partially decrypted in one round trip).
//
//   MultipartyDecryptMain__ct_vec  (cryptocontext.h line 3137)
//
//   CryptoContext__ShareKeys       (cryptocontext.h line 4036,
//     DCRTPoly specialization — returns an
//     unordered_map<uint32_t, DCRTPoly> that the R binding
//     wraps in a shared_ptr and surfaces as a SecretShareMap.
//     The base-template version at line 3471 throws
//     "Not implemented" via OPENFHE_THROW so the catch_openfhe
//     bridge would surface that as a cpp11::stop — we rely on
//     DCRTPoly being the only Element type wired through this
//     file to route to the working specialization).
//
//   CryptoContext__RecoverSharedKey (cryptocontext.h line 3486 —
//     non-template virtual on the base, routes to a scheme-
//     specific implementation under the DCRTPoly specialization.
//     The in-parameter is a reference to a PrivateKey that must
//     be pre-allocated as an empty PrivateKeyImpl bound to the
//     cc; the R binding constructs that empty PrivateKeyImpl
//     internally so R users do not have to know about the
//     in-place-fill convention. Returns a new PrivateKey
//     external_pointer to the R side).

#include "openfhe_cpp11.h"
#include "openfhe_helpers.h"
#include <map>
#include <memory>
#include <unordered_map>
#include <vector>

using namespace cpp11;

using ShareMapT  = std::unordered_map<uint32_t, DCRTPoly>;
using ShareMapSP = std::shared_ptr<ShareMapT>;

// ── Vector-form distributed decryption ──────────────────

// Helper: marshal a cpp11::list of external_pointer<Ciphertext>
// into std::vector<Ciphertext<DCRTPoly>>. Each element must be a
// Ciphertext external_pointer; the caller is responsible for
// type-checking on the R side.
static std::vector<Ciphertext<DCRTPoly>> list_to_ct_vec(list ct_list) {
  std::vector<Ciphertext<DCRTPoly>> out;
  out.reserve(ct_list.size());
  for (R_xlen_t i = 0; i < ct_list.size(); ++i) {
    SEXP ct_xp = ct_list[i];
    external_pointer<Ciphertext<DCRTPoly>> ct(ct_xp);
    out.push_back(*ct);
  }
  return out;
}

// Helper: marshal a std::vector<Ciphertext> into a cpp11::list
// of external_pointer<Ciphertext>.
static list ct_vec_to_list(const std::vector<Ciphertext<DCRTPoly>>& ct_vec) {
  writable::list out(ct_vec.size());
  for (size_t i = 0; i < ct_vec.size(); ++i) {
    out[i] = external_pointer<Ciphertext<DCRTPoly>>(
      new Ciphertext<DCRTPoly>(ct_vec[i]));
  }
  return out;
}

[[cpp11::register]]
SEXP MultipartyDecryptLead__ct_vec(SEXP cc_xp, SEXP sk_xp, list ct_list) {
  external_pointer<CryptoContext<DCRTPoly>> cc(cc_xp);
  external_pointer<PrivateKey<DCRTPoly>> sk(sk_xp);
  return catch_openfhe("CryptoContext::MultipartyDecryptLead(vec)", [&]() {
    auto ct_vec = list_to_ct_vec(ct_list);
    auto result = (*cc)->MultipartyDecryptLead(ct_vec, *sk);
    return ct_vec_to_list(result);
  });
}

[[cpp11::register]]
SEXP MultipartyDecryptMain__ct_vec(SEXP cc_xp, SEXP sk_xp, list ct_list) {
  external_pointer<CryptoContext<DCRTPoly>> cc(cc_xp);
  external_pointer<PrivateKey<DCRTPoly>> sk(sk_xp);
  return catch_openfhe("CryptoContext::MultipartyDecryptMain(vec)", [&]() {
    auto ct_vec = list_to_ct_vec(ct_list);
    auto result = (*cc)->MultipartyDecryptMain(ct_vec, *sk);
    return ct_vec_to_list(result);
  });
}

// ── ShareKeys / RecoverSharedKey ────────────────────────

// Produces the shares of `sk` that party `index` would
// distribute under `sharing_scheme` (`"additive"` or
// `"shamir"`). The returned SecretShareMap wire format is a
// heap-allocated shared_ptr<unordered_map<uint32_t, DCRTPoly>>
// managed by the external_pointer's default deleter, matching
// the EvalKeyMap pattern.
[[cpp11::register]]
SEXP CryptoContext__ShareKeys(SEXP cc_xp, SEXP sk_xp,
                              int n_parties, int threshold, int index,
                              std::string sharing_scheme) {
  external_pointer<CryptoContext<DCRTPoly>> cc(cc_xp);
  external_pointer<PrivateKey<DCRTPoly>> sk(sk_xp);
  return catch_openfhe("CryptoContext::ShareKeys", [&]() {
    auto result = (*cc)->ShareKeys(
      *sk,
      static_cast<uint32_t>(n_parties),
      static_cast<uint32_t>(threshold),
      static_cast<uint32_t>(index),
      sharing_scheme);
    ShareMapSP sp = std::make_shared<ShareMapT>(std::move(result));
    return external_pointer<ShareMapSP>(new ShareMapSP(sp));
  });
}

// Reconstructs a PrivateKey from a SecretShareMap. The
// C++ signature takes a mutable PrivateKey reference that must
// be pre-allocated; R users never see that because the binding
// constructs the empty PrivateKeyImpl<DCRTPoly> bound to `cc`
// internally before calling the scheme routine.
[[cpp11::register]]
SEXP CryptoContext__RecoverSharedKey(SEXP cc_xp, SEXP share_map_xp,
                                     int n_parties, int threshold,
                                     std::string sharing_scheme) {
  external_pointer<CryptoContext<DCRTPoly>> cc(cc_xp);
  external_pointer<ShareMapSP> share_map(share_map_xp);
  return catch_openfhe("CryptoContext::RecoverSharedKey", [&]() {
    PrivateKey<DCRTPoly> sk_recovered =
      std::make_shared<PrivateKeyImpl<DCRTPoly>>(*cc);
    (*cc)->RecoverSharedKey(
      sk_recovered,
      **share_map,
      static_cast<uint32_t>(n_parties),
      static_cast<uint32_t>(threshold),
      sharing_scheme);
    return external_pointer<PrivateKey<DCRTPoly>>(
      new PrivateKey<DCRTPoly>(sk_recovered));
  });
}
