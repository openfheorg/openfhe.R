// OPENFHE PYTHON SOURCE: src/lib/bindings.cpp (IntBoot + IntMPBoot families)
//                       NONE for KeySwitchDown — R-first
//
// Three method groups.
//
// 1. KeySwitchDown — cryptocontext.h line 2421. Scales a
//    ciphertext down from the extended CRT basis P*Q to Q;
//    only meaningful when hybrid key switching is in use. No
//    openfhe-python binding exists (R-first / R-only).
//    Logged in notes/upstream-defects.md under the "R-only
//    surface" section. Harness tag: R_ONLY.
//
// 2. IntBoot* family (4 methods) — cryptocontext.h lines
//    3351-3397. Single-party interactive bootstrap primitives
//    used to refresh a ciphertext without running the full
//    non-interactive bootstrap. Python binds these.
//      IntBootDecrypt       (line 3351)
//      IntBootEncrypt       (line 3366)
//      IntBootAdd           (line 3380)
//      IntBootAdjustScale   (line 3395)
//
// 3. IntMPBoot* family (6 methods) — cryptocontext.h lines
//    3406-3459. Multi-party interactive bootstrap primitives
//    for threshold-FHE protocols. Python binds all six.
//      IntMPBootAdjustScale          (line 3406)
//      IntMPBootRandomElementGen(pk) (line 3414, overload 1)
//      IntMPBootRandomElementGen(ct) (line 3422, overload 2)
//      IntMPBootDecrypt              (line 3433, returns vector)
//      IntMPBootAdd                  (line 3444, takes vector<vector>)
//      IntMPBootEncrypt              (line 3457)
//
// All 11 call sites wrap in catch_openfhe per design.md §5.

#include "openfhe_cpp11.h"
#include "openfhe_helpers.h"
#include <vector>

using namespace cpp11;

// File-local helpers for marshalling vector<Ciphertext<DCRTPoly>>
// between R lists and std::vector. Mirrors the helpers in
// pke_secret_sharing_9114.cpp.
static std::vector<Ciphertext<DCRTPoly>> list_to_ct_vec_9117(list ct_list) {
  std::vector<Ciphertext<DCRTPoly>> out;
  out.reserve(ct_list.size());
  for (R_xlen_t i = 0; i < ct_list.size(); ++i) {
    SEXP ct_xp = ct_list[i];
    external_pointer<Ciphertext<DCRTPoly>> ct(ct_xp);
    out.push_back(*ct);
  }
  return out;
}

static list ct_vec_to_list_9117(const std::vector<Ciphertext<DCRTPoly>>& ct_vec) {
  writable::list out(ct_vec.size());
  for (size_t i = 0; i < ct_vec.size(); ++i) {
    out[i] = external_pointer<Ciphertext<DCRTPoly>>(
      new Ciphertext<DCRTPoly>(ct_vec[i]));
  }
  return out;
}

// ── KeySwitchDown (R-first) ─────────────────────────────

[[cpp11::register]]
SEXP KeySwitchDown__(SEXP ct_xp) {
  external_pointer<Ciphertext<DCRTPoly>> ct(ct_xp);
  return catch_openfhe("CryptoContext::KeySwitchDown", [&]() {
    auto cc = (*ct)->GetCryptoContext();
    auto result = cc->KeySwitchDown(*ct);
    return external_pointer<Ciphertext<DCRTPoly>>(
      new Ciphertext<DCRTPoly>(result));
  });
}

// ── IntBoot* family (single-party interactive bootstrap) ──

[[cpp11::register]]
SEXP IntBootDecrypt__(SEXP sk_xp, SEXP ct_xp) {
  external_pointer<PrivateKey<DCRTPoly>> sk(sk_xp);
  external_pointer<Ciphertext<DCRTPoly>> ct(ct_xp);
  return catch_openfhe("CryptoContext::IntBootDecrypt", [&]() {
    auto cc = (*ct)->GetCryptoContext();
    auto result = cc->IntBootDecrypt(*sk, *ct);
    return external_pointer<Ciphertext<DCRTPoly>>(
      new Ciphertext<DCRTPoly>(result));
  });
}

[[cpp11::register]]
SEXP IntBootEncrypt__(SEXP pk_xp, SEXP ct_xp) {
  external_pointer<PublicKey<DCRTPoly>> pk(pk_xp);
  external_pointer<Ciphertext<DCRTPoly>> ct(ct_xp);
  return catch_openfhe("CryptoContext::IntBootEncrypt", [&]() {
    auto cc = (*ct)->GetCryptoContext();
    auto result = cc->IntBootEncrypt(*pk, *ct);
    return external_pointer<Ciphertext<DCRTPoly>>(
      new Ciphertext<DCRTPoly>(result));
  });
}

[[cpp11::register]]
SEXP IntBootAdd__(SEXP ct1_xp, SEXP ct2_xp) {
  external_pointer<Ciphertext<DCRTPoly>> ct1(ct1_xp);
  external_pointer<Ciphertext<DCRTPoly>> ct2(ct2_xp);
  return catch_openfhe("CryptoContext::IntBootAdd", [&]() {
    auto cc = (*ct1)->GetCryptoContext();
    auto result = cc->IntBootAdd(*ct1, *ct2);
    return external_pointer<Ciphertext<DCRTPoly>>(
      new Ciphertext<DCRTPoly>(result));
  });
}

[[cpp11::register]]
SEXP IntBootAdjustScale__(SEXP ct_xp) {
  external_pointer<Ciphertext<DCRTPoly>> ct(ct_xp);
  return catch_openfhe("CryptoContext::IntBootAdjustScale", [&]() {
    auto cc = (*ct)->GetCryptoContext();
    auto result = cc->IntBootAdjustScale(*ct);
    return external_pointer<Ciphertext<DCRTPoly>>(
      new Ciphertext<DCRTPoly>(result));
  });
}

// ── IntMPBoot* family (multi-party interactive bootstrap) ──

[[cpp11::register]]
SEXP IntMPBootAdjustScale__(SEXP ct_xp) {
  external_pointer<Ciphertext<DCRTPoly>> ct(ct_xp);
  return catch_openfhe("CryptoContext::IntMPBootAdjustScale", [&]() {
    auto cc = (*ct)->GetCryptoContext();
    auto result = cc->IntMPBootAdjustScale(*ct);
    return external_pointer<Ciphertext<DCRTPoly>>(
      new Ciphertext<DCRTPoly>(result));
  });
}

// Overload 1: generate a random element from a PublicKey.
[[cpp11::register]]
SEXP IntMPBootRandomElementGen__pk(SEXP cc_xp, SEXP pk_xp) {
  external_pointer<CryptoContext<DCRTPoly>> cc(cc_xp);
  external_pointer<PublicKey<DCRTPoly>> pk(pk_xp);
  return catch_openfhe("CryptoContext::IntMPBootRandomElementGen(pk)", [&]() {
    auto result = (*cc)->IntMPBootRandomElementGen(*pk);
    return external_pointer<Ciphertext<DCRTPoly>>(
      new Ciphertext<DCRTPoly>(result));
  });
}

// Overload 2: generate a random element from a reference
// Ciphertext (the reference supplies the cc and parameters).
[[cpp11::register]]
SEXP IntMPBootRandomElementGen__ct(SEXP ct_xp) {
  external_pointer<Ciphertext<DCRTPoly>> ct(ct_xp);
  return catch_openfhe("CryptoContext::IntMPBootRandomElementGen(ct)", [&]() {
    auto cc = (*ct)->GetCryptoContext();
    auto result = cc->IntMPBootRandomElementGen(*ct);
    return external_pointer<Ciphertext<DCRTPoly>>(
      new Ciphertext<DCRTPoly>(result));
  });
}

// IntMPBootDecrypt returns vector<Ciphertext>. R wrapper will
// receive a list and can unpack the first element if a single-
// partial view is desired.
[[cpp11::register]]
SEXP IntMPBootDecrypt__(SEXP sk_xp, SEXP ct_xp, SEXP a_xp) {
  external_pointer<PrivateKey<DCRTPoly>> sk(sk_xp);
  external_pointer<Ciphertext<DCRTPoly>> ct(ct_xp);
  external_pointer<Ciphertext<DCRTPoly>> a(a_xp);
  return catch_openfhe("CryptoContext::IntMPBootDecrypt", [&]() {
    auto cc = (*ct)->GetCryptoContext();
    auto result = cc->IntMPBootDecrypt(*sk, *ct, *a);
    return ct_vec_to_list_9117(result);
  });
}

// IntMPBootAdd takes vector<vector<Ciphertext>> — each inner
// vector is one party's shares-pair (the result of
// IntMPBootDecrypt for that party). The R side supplies a list
// of lists; marshal each inner list into a std::vector and
// collect the outer layer. The header takes the argument by
// non-const reference which is a design oddity but reading
// the openfhe-development implementation confirms the method
// does not mutate the input — we rebuild a local copy from
// the R list and pass it.
[[cpp11::register]]
SEXP IntMPBootAdd__(SEXP cc_xp, list shares_pair_list) {
  external_pointer<CryptoContext<DCRTPoly>> cc(cc_xp);
  return catch_openfhe("CryptoContext::IntMPBootAdd", [&]() {
    std::vector<std::vector<Ciphertext<DCRTPoly>>> shares_vec;
    shares_vec.reserve(shares_pair_list.size());
    for (R_xlen_t i = 0; i < shares_pair_list.size(); ++i) {
      SEXP inner = shares_pair_list[i];
      list inner_list(inner);
      shares_vec.push_back(list_to_ct_vec_9117(inner_list));
    }
    auto result = (*cc)->IntMPBootAdd(shares_vec);
    return ct_vec_to_list_9117(result);
  });
}

// IntMPBootEncrypt takes a `sharesPair` std::vector<Ciphertext>
// (combined shares from IntMPBootAdd) plus two ciphertexts (the
// random-element `a` and the target `ct`). Returns a single
// refreshed Ciphertext. R side passes a list of Ciphertexts for
// sharesPair and two external pointers for a and ct.
[[cpp11::register]]
SEXP IntMPBootEncrypt__(SEXP pk_xp, list shares_pair_list,
                        SEXP a_xp, SEXP ct_xp) {
  external_pointer<PublicKey<DCRTPoly>> pk(pk_xp);
  external_pointer<Ciphertext<DCRTPoly>> a(a_xp);
  external_pointer<Ciphertext<DCRTPoly>> ct(ct_xp);
  return catch_openfhe("CryptoContext::IntMPBootEncrypt", [&]() {
    auto cc = (*ct)->GetCryptoContext();
    auto shares_pair = list_to_ct_vec_9117(shares_pair_list);
    auto result = cc->IntMPBootEncrypt(*pk, shares_pair, *a, *ct);
    return external_pointer<Ciphertext<DCRTPoly>>(
      new Ciphertext<DCRTPoly>(result));
  });
}
