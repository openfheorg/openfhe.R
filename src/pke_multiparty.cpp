// OPENFHE PYTHON SOURCE: src/lib/bindings.cpp (Multiparty/Threshold FHE)
// Phase 7: Multi-party key generation, distributed decryption
//
// argument completion pass.
//   - MultipartyKeyGen now takes (pk, makeSparse, fresh) per
//     cryptocontext.h line 3102.
//   - MultiAddPubKeys / MultiAddEvalKeys / MultiAddEvalMultKeys
//     gain the `keyTag` tail argument per cryptocontext.h lines
//     3314 / 3244 / 3331. Python exposes keyTag via py::arg with
//     a default of "", matching the header.
//   - MultiKeySwitchGen stays at 3 args (header line 3165); the
//     R wrapper exposes a binding that was otherwise present
//     but had no user-facing surface.
//   - All call sites wrap in catch_openfhe per design.md §5.
#include "openfhe_cpp11.h"
#include "openfhe_helpers.h"

using namespace cpp11;

// ── Multiparty Key Generation ───────────────────────────

// Lead party: generates initial keypair via the ordinary KeyGen
// route. Other parties: generate keypair using the lead's public
// key. `make_sparse` is the "produce an LWE-sparse secret" knob
// from the header (RLWE-only meaning) and `fresh` requests a
// freshly-sampled secret rather than a derived one; both default
// to false per the header signature.
[[cpp11::register]]
list MultipartyKeyGen(SEXP cc_xp, SEXP pk_xp,
                      bool make_sparse, bool fresh) {
  external_pointer<CryptoContext<DCRTPoly>> cc(cc_xp);
  external_pointer<PublicKey<DCRTPoly>> pk(pk_xp);
  return catch_openfhe("CryptoContext::MultipartyKeyGen(pk)", [&]() {
    auto kp = (*cc)->MultipartyKeyGen(*pk, make_sparse, fresh);
    writable::list result(2);
    result[0] = external_pointer<PublicKey<DCRTPoly>>(
      new PublicKey<DCRTPoly>(kp.publicKey));
    result[1] = external_pointer<PrivateKey<DCRTPoly>>(
      new PrivateKey<DCRTPoly>(kp.secretKey));
    result.attr("names") = writable::strings({"public", "secret"});
    return result;
  });
}

// ── Multi-party Key Combining ───────────────────────────

// Combine public keys from two parties. Result is a joint public
// key that encrypts messages decryptable only by the combined
// party set.
[[cpp11::register]]
SEXP MultiAddPubKeys(SEXP cc_xp, SEXP pk1_xp, SEXP pk2_xp,
                    std::string key_tag) {
  external_pointer<CryptoContext<DCRTPoly>> cc(cc_xp);
  external_pointer<PublicKey<DCRTPoly>> pk1(pk1_xp);
  external_pointer<PublicKey<DCRTPoly>> pk2(pk2_xp);
  return catch_openfhe("CryptoContext::MultiAddPubKeys", [&]() {
    auto result = (*cc)->MultiAddPubKeys(*pk1, *pk2, key_tag);
    return external_pointer<PublicKey<DCRTPoly>>(
      new PublicKey<DCRTPoly>(result));
  });
}

// Combine generic eval keys (e.g., partial key-switching keys).
[[cpp11::register]]
SEXP MultiAddEvalKeys(SEXP cc_xp, SEXP ek1_xp, SEXP ek2_xp,
                     std::string key_tag) {
  external_pointer<CryptoContext<DCRTPoly>> cc(cc_xp);
  external_pointer<EvalKey<DCRTPoly>> ek1(ek1_xp);
  external_pointer<EvalKey<DCRTPoly>> ek2(ek2_xp);
  return catch_openfhe("CryptoContext::MultiAddEvalKeys", [&]() {
    auto result = (*cc)->MultiAddEvalKeys(*ek1, *ek2, key_tag);
    return external_pointer<EvalKey<DCRTPoly>>(
      new EvalKey<DCRTPoly>(result));
  });
}

// Combine partial eval-mult keys. Distinct from MultiAddEvalKeys:
// the eval-mult flavor consumes keys produced by
// MultiEvalMultKeyGen rather than MultiKeySwitchGen, and has its
// own implementation path in the scheme.
[[cpp11::register]]
SEXP MultiAddEvalMultKeys(SEXP cc_xp, SEXP ek1_xp, SEXP ek2_xp,
                         std::string key_tag) {
  external_pointer<CryptoContext<DCRTPoly>> cc(cc_xp);
  external_pointer<EvalKey<DCRTPoly>> ek1(ek1_xp);
  external_pointer<EvalKey<DCRTPoly>> ek2(ek2_xp);
  return catch_openfhe("CryptoContext::MultiAddEvalMultKeys", [&]() {
    auto result = (*cc)->MultiAddEvalMultKeys(*ek1, *ek2, key_tag);
    return external_pointer<EvalKey<DCRTPoly>>(
      new EvalKey<DCRTPoly>(result));
  });
}

// Multi-party key switch generation. Takes the original party's
// secret, the new party's secret, and an existing eval key that
// carries the key-switch auxiliary information.
[[cpp11::register]]
SEXP MultiKeySwitchGen(SEXP cc_xp, SEXP sk_orig_xp, SEXP sk_new_xp, SEXP ek_xp) {
  external_pointer<CryptoContext<DCRTPoly>> cc(cc_xp);
  external_pointer<PrivateKey<DCRTPoly>> sk_orig(sk_orig_xp);
  external_pointer<PrivateKey<DCRTPoly>> sk_new(sk_new_xp);
  external_pointer<EvalKey<DCRTPoly>> ek(ek_xp);
  return catch_openfhe("CryptoContext::MultiKeySwitchGen", [&]() {
    auto result = (*cc)->MultiKeySwitchGen(*sk_orig, *sk_new, *ek);
    return external_pointer<EvalKey<DCRTPoly>>(
      new EvalKey<DCRTPoly>(result));
  });
}

// ── Distributed Decryption ──────────────────────────────

// Lead party's partial decryption. The single-ciphertext form
// shown here is the original signature; the vector form is
// provided separately.
[[cpp11::register]]
SEXP MultipartyDecryptLead(SEXP cc_xp, SEXP sk_xp, SEXP ct_xp) {
  external_pointer<CryptoContext<DCRTPoly>> cc(cc_xp);
  external_pointer<PrivateKey<DCRTPoly>> sk(sk_xp);
  external_pointer<Ciphertext<DCRTPoly>> ct(ct_xp);
  return catch_openfhe("CryptoContext::MultipartyDecryptLead", [&]() {
    std::vector<Ciphertext<DCRTPoly>> ct_vec = {*ct};
    auto result = (*cc)->MultipartyDecryptLead(ct_vec, *sk);
    return external_pointer<Ciphertext<DCRTPoly>>(
      new Ciphertext<DCRTPoly>(result[0]));
  });
}

// Other party's partial decryption, single-ciphertext form.
[[cpp11::register]]
SEXP MultipartyDecryptMain(SEXP cc_xp, SEXP sk_xp, SEXP ct_xp) {
  external_pointer<CryptoContext<DCRTPoly>> cc(cc_xp);
  external_pointer<PrivateKey<DCRTPoly>> sk(sk_xp);
  external_pointer<Ciphertext<DCRTPoly>> ct(ct_xp);
  return catch_openfhe("CryptoContext::MultipartyDecryptMain", [&]() {
    std::vector<Ciphertext<DCRTPoly>> ct_vec = {*ct};
    auto result = (*cc)->MultipartyDecryptMain(ct_vec, *sk);
    return external_pointer<Ciphertext<DCRTPoly>>(
      new Ciphertext<DCRTPoly>(result[0]));
  });
}

// Fusion: combine partial decryptions from N parties into the final
// plaintext. The partials_list argument is a cpp11::list whose elements
// are external pointers to Ciphertext<DCRTPoly>; the lead party's
// partial must come first, followed by every other party's partial in
// any order. OpenFHE's underlying API takes a std::vector of arbitrary
// length, so this binding handles the n-party threshold-FHE flow
// (threshold-fhe-5p.py) as well as the original 2-party case.
[[cpp11::register]]
SEXP MultipartyDecryptFusion(SEXP cc_xp, list partials_list) {
  external_pointer<CryptoContext<DCRTPoly>> cc(cc_xp);
  return catch_openfhe("CryptoContext::MultipartyDecryptFusion", [&]() {
    std::vector<Ciphertext<DCRTPoly>> partials;
    partials.reserve(partials_list.size());
    for (R_xlen_t i = 0; i < partials_list.size(); ++i) {
      SEXP p_xp = partials_list[i];
      external_pointer<Ciphertext<DCRTPoly>> p(p_xp);
      partials.push_back(*p);
    }
    Plaintext result;
    (*cc)->MultipartyDecryptFusion(partials, &result);
    return external_pointer<Plaintext>(new Plaintext(result));
  });
}
