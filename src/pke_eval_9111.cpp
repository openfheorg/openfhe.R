// OPENFHE PYTHON SOURCE: src/lib/bindings.cpp (Eval* arg completion)
//
// The Eval* argument-completion
// surface. 20 new cpp11 bindings:
//
//   In-place family (8):
//     EvalAddInPlace ct/ct, ct/pt, ct/scalar
//     EvalSubInPlace ct/ct, ct/pt, ct/scalar
//     EvalMultInPlace ct/scalar (no ct/ct variant in the header —
//       cryptocontext.h only declares the scalar overloads; the
//       ct/ct and ct/pt overloads Python P1 refers to live on
//       SchemeBase and aren't exposed on CryptoContextImpl)
//     EvalNegateInPlace
//   Mutable family (4):
//     EvalAddMutable, EvalSubMutable, EvalMultMutable, EvalSquareMutable
//     (all ct/ct returning Ciphertext)
//   No-relin + relinearize (3):
//     EvalMultNoRelin, Relinearize, EvalMultAndRelinearize
//   Mod/level reduce + compress (5):
//     ModReduce, ModReduceInPlace
//     LevelReduce, LevelReduceInPlace (take EvalKey + levels)
//     Compress (towersLeft + noiseScaleDeg)
//
// `Rescale(ct)` is already bound in pke_bindings.cpp. At the R
// layer `rescale()` and `mod_reduce()` both dispatch to the same
// operation (CryptoContextImpl::Rescale delegates to ModReduce
// internally); both names are kept per design.md §10.
#include "openfhe_cpp11.h"
#include "openfhe_helpers.h"

using namespace cpp11;

// ── In-place family ─────────────────────────────────────

[[cpp11::register]]
void EvalAddInPlace__ct_ct(SEXP ct1_xp, SEXP ct2_xp) {
  external_pointer<Ciphertext<DCRTPoly>> ct1(ct1_xp);
  external_pointer<Ciphertext<DCRTPoly>> ct2(ct2_xp);
  catch_openfhe("CryptoContext::EvalAddInPlace(ct, ct)", [&]() {
    (*ct1)->GetCryptoContext()->EvalAddInPlace(*ct1, *ct2);
  });
}

[[cpp11::register]]
void EvalAddInPlace__ct_pt(SEXP ct_xp, SEXP pt_xp) {
  external_pointer<Ciphertext<DCRTPoly>> ct(ct_xp);
  external_pointer<Plaintext> pt(pt_xp);
  catch_openfhe("CryptoContext::EvalAddInPlace(ct, pt)", [&]() {
    (*ct)->GetCryptoContext()->EvalAddInPlace(*ct, *pt);
  });
}

[[cpp11::register]]
void EvalAddInPlace__ct_scalar(SEXP ct_xp, double scalar) {
  external_pointer<Ciphertext<DCRTPoly>> ct(ct_xp);
  catch_openfhe("CryptoContext::EvalAddInPlace(ct, double)", [&]() {
    (*ct)->GetCryptoContext()->EvalAddInPlace(*ct, scalar);
  });
}

[[cpp11::register]]
void EvalSubInPlace__ct_ct(SEXP ct1_xp, SEXP ct2_xp) {
  external_pointer<Ciphertext<DCRTPoly>> ct1(ct1_xp);
  external_pointer<Ciphertext<DCRTPoly>> ct2(ct2_xp);
  catch_openfhe("CryptoContext::EvalSubInPlace(ct, ct)", [&]() {
    (*ct1)->GetCryptoContext()->EvalSubInPlace(*ct1, *ct2);
  });
}

[[cpp11::register]]
void EvalSubInPlace__ct_pt(SEXP ct_xp, SEXP pt_xp) {
  external_pointer<Ciphertext<DCRTPoly>> ct(ct_xp);
  external_pointer<Plaintext> pt(pt_xp);
  catch_openfhe("CryptoContext::EvalSubInPlace(ct, pt)", [&]() {
    (*ct)->GetCryptoContext()->EvalSubInPlace(*ct, *pt);
  });
}

[[cpp11::register]]
void EvalSubInPlace__ct_scalar(SEXP ct_xp, double scalar) {
  external_pointer<Ciphertext<DCRTPoly>> ct(ct_xp);
  catch_openfhe("CryptoContext::EvalSubInPlace(ct, double)", [&]() {
    (*ct)->GetCryptoContext()->EvalSubInPlace(*ct, scalar);
  });
}

[[cpp11::register]]
void EvalMultInPlace__ct_scalar(SEXP ct_xp, double scalar) {
  external_pointer<Ciphertext<DCRTPoly>> ct(ct_xp);
  catch_openfhe("CryptoContext::EvalMultInPlace(ct, double)", [&]() {
    (*ct)->GetCryptoContext()->EvalMultInPlace(*ct, scalar);
  });
}

[[cpp11::register]]
void EvalNegateInPlace__ct(SEXP ct_xp) {
  external_pointer<Ciphertext<DCRTPoly>> ct(ct_xp);
  catch_openfhe("CryptoContext::EvalNegateInPlace", [&]() {
    (*ct)->GetCryptoContext()->EvalNegateInPlace(*ct);
  });
}

// ── Mutable family ──────────────────────────────────────

[[cpp11::register]]
SEXP EvalAddMutable__ct_ct(SEXP ct1_xp, SEXP ct2_xp) {
  external_pointer<Ciphertext<DCRTPoly>> ct1(ct1_xp);
  external_pointer<Ciphertext<DCRTPoly>> ct2(ct2_xp);
  return catch_openfhe("CryptoContext::EvalAddMutable", [&]() {
    auto result = (*ct1)->GetCryptoContext()->EvalAddMutable(*ct1, *ct2);
    return external_pointer<Ciphertext<DCRTPoly>>(
        new Ciphertext<DCRTPoly>(result));
  });
}

[[cpp11::register]]
SEXP EvalSubMutable__ct_ct(SEXP ct1_xp, SEXP ct2_xp) {
  external_pointer<Ciphertext<DCRTPoly>> ct1(ct1_xp);
  external_pointer<Ciphertext<DCRTPoly>> ct2(ct2_xp);
  return catch_openfhe("CryptoContext::EvalSubMutable", [&]() {
    auto result = (*ct1)->GetCryptoContext()->EvalSubMutable(*ct1, *ct2);
    return external_pointer<Ciphertext<DCRTPoly>>(
        new Ciphertext<DCRTPoly>(result));
  });
}

[[cpp11::register]]
SEXP EvalMultMutable__ct_ct(SEXP ct1_xp, SEXP ct2_xp) {
  external_pointer<Ciphertext<DCRTPoly>> ct1(ct1_xp);
  external_pointer<Ciphertext<DCRTPoly>> ct2(ct2_xp);
  return catch_openfhe("CryptoContext::EvalMultMutable", [&]() {
    auto result = (*ct1)->GetCryptoContext()->EvalMultMutable(*ct1, *ct2);
    return external_pointer<Ciphertext<DCRTPoly>>(
        new Ciphertext<DCRTPoly>(result));
  });
}

[[cpp11::register]]
SEXP EvalSquareMutable__ct(SEXP ct_xp) {
  external_pointer<Ciphertext<DCRTPoly>> ct(ct_xp);
  return catch_openfhe("CryptoContext::EvalSquareMutable", [&]() {
    auto result = (*ct)->GetCryptoContext()->EvalSquareMutable(*ct);
    return external_pointer<Ciphertext<DCRTPoly>>(
        new Ciphertext<DCRTPoly>(result));
  });
}

// ── No-relin + relinearize ──────────────────────────────

[[cpp11::register]]
SEXP EvalMultNoRelin__ct_ct(SEXP ct1_xp, SEXP ct2_xp) {
  external_pointer<Ciphertext<DCRTPoly>> ct1(ct1_xp);
  external_pointer<Ciphertext<DCRTPoly>> ct2(ct2_xp);
  return catch_openfhe("CryptoContext::EvalMultNoRelin", [&]() {
    auto result = (*ct1)->GetCryptoContext()->EvalMultNoRelin(*ct1, *ct2);
    return external_pointer<Ciphertext<DCRTPoly>>(
        new Ciphertext<DCRTPoly>(result));
  });
}

[[cpp11::register]]
SEXP Relinearize__ct(SEXP ct_xp) {
  external_pointer<Ciphertext<DCRTPoly>> ct(ct_xp);
  return catch_openfhe("CryptoContext::Relinearize", [&]() {
    auto result = (*ct)->GetCryptoContext()->Relinearize(*ct);
    return external_pointer<Ciphertext<DCRTPoly>>(
        new Ciphertext<DCRTPoly>(result));
  });
}

[[cpp11::register]]
SEXP EvalMultAndRelinearize__ct_ct(SEXP ct1_xp, SEXP ct2_xp) {
  external_pointer<Ciphertext<DCRTPoly>> ct1(ct1_xp);
  external_pointer<Ciphertext<DCRTPoly>> ct2(ct2_xp);
  return catch_openfhe("CryptoContext::EvalMultAndRelinearize", [&]() {
    auto result = (*ct1)->GetCryptoContext()->EvalMultAndRelinearize(*ct1, *ct2);
    return external_pointer<Ciphertext<DCRTPoly>>(
        new Ciphertext<DCRTPoly>(result));
  });
}

// ── Mod/level reduce + compress ─────────────────────────

[[cpp11::register]]
SEXP ModReduce__ct(SEXP ct_xp) {
  external_pointer<Ciphertext<DCRTPoly>> ct(ct_xp);
  return catch_openfhe("CryptoContext::ModReduce", [&]() {
    auto result = (*ct)->GetCryptoContext()->ModReduce(*ct);
    return external_pointer<Ciphertext<DCRTPoly>>(
        new Ciphertext<DCRTPoly>(result));
  });
}

[[cpp11::register]]
void ModReduceInPlace__ct(SEXP ct_xp) {
  external_pointer<Ciphertext<DCRTPoly>> ct(ct_xp);
  catch_openfhe("CryptoContext::ModReduceInPlace", [&]() {
    (*ct)->GetCryptoContext()->ModReduceInPlace(*ct);
  });
}

[[cpp11::register]]
SEXP LevelReduce__ct(SEXP ct_xp, SEXP eval_key_xp, int levels) {
  external_pointer<Ciphertext<DCRTPoly>> ct(ct_xp);
  external_pointer<EvalKey<DCRTPoly>> ek(eval_key_xp);
  return catch_openfhe("CryptoContext::LevelReduce", [&]() {
    auto result = (*ct)->GetCryptoContext()->LevelReduce(
        *ct, *ek, static_cast<size_t>(levels));
    return external_pointer<Ciphertext<DCRTPoly>>(
        new Ciphertext<DCRTPoly>(result));
  });
}

[[cpp11::register]]
void LevelReduceInPlace__ct(SEXP ct_xp, SEXP eval_key_xp, int levels) {
  external_pointer<Ciphertext<DCRTPoly>> ct(ct_xp);
  external_pointer<EvalKey<DCRTPoly>> ek(eval_key_xp);
  catch_openfhe("CryptoContext::LevelReduceInPlace", [&]() {
    (*ct)->GetCryptoContext()->LevelReduceInPlace(
        *ct, *ek, static_cast<size_t>(levels));
  });
}

[[cpp11::register]]
SEXP Compress__ct(SEXP ct_xp, int towers_left, int noise_scale_deg) {
  external_pointer<Ciphertext<DCRTPoly>> ct(ct_xp);
  return catch_openfhe("CryptoContext::Compress", [&]() {
    auto result = (*ct)->GetCryptoContext()->Compress(
        *ct,
        static_cast<uint32_t>(towers_left),
        static_cast<size_t>(noise_scale_deg));
    return external_pointer<Ciphertext<DCRTPoly>>(
        new Ciphertext<DCRTPoly>(result));
  });
}
