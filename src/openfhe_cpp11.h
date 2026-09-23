// R-SPECIFIC: shared header for OpenFHE + cpp11, and the tagged external
// pointer every binding uses.
//
// Why a tagged pointer. cpp11::external_pointer<T>(SEXP) checks only that
// the SEXP is an EXTPTRSXP. It does not check that the pointer inside is
// a T. A binding declared to take a Ciphertext handle, when handed a
// Plaintext handle, reinterprets PlaintextImpl memory as CiphertextImpl
// and either crashes or returns garbage. The 2026-09-22 surface audit
// reproduced seven hard crashes and four silent wrong answers from that
// single omission (temp/scratch/audit3/report.md, probes C01-C17).
//
// xptr<T> closes the hole at one choke point:
//   * creation  (xptr<T>(new T(...)))  stores a tag symbol on the
//     external pointer naming the wrapped type;
//   * consumption (xptr<T> x(sexp))     refuses, via cpp11::stop, any SEXP
//     that is not an external pointer, carries a different tag, or has
//     already been released (null address).
// The tag symbol is the S7 class name the R layer gives the same object
// ("openfhe.R::Ciphertext" and so on), so the R-side validator in
// R/openfhe-object.R can compare xptr_type(ptr) against class(self)[1]
// with no lookup table. Types without an R class fall back to the
// compiler's type name; they are still tagged and still checked.
//
// For shared_ptr types: xptr<shared_ptr<T>> stores a heap-allocated
// shared_ptr. The default deleter calls delete on it, which decrements
// the refcount.
#pragma once

#include <cpp11.hpp>
#include <cpp11/external_pointer.hpp>
#include <map>
#include <memory>
#include <typeinfo>
#include <unordered_map>
#include <vector>
#include "openfhe.h"
#include "binfhecontext.h"

using namespace lbcrypto;

namespace openfhe_r {

// ---- type -> tag name ----------------------------------------------------

template <typename T>
struct xptr_traits {
  static const char* name() { return typeid(T).name(); }
};

// One explicit specialization per wrapped type. The name is the S7 class
// the R layer uses for the same object.
template <> struct xptr_traits<CryptoContext<DCRTPoly>> {
  static const char* name() { return "openfhe.R::CryptoContext"; } };
template <> struct xptr_traits<Ciphertext<DCRTPoly>> {
  static const char* name() { return "openfhe.R::Ciphertext"; } };
template <> struct xptr_traits<Plaintext> {
  static const char* name() { return "openfhe.R::Plaintext"; } };
template <> struct xptr_traits<PublicKey<DCRTPoly>> {
  static const char* name() { return "openfhe.R::PublicKey"; } };
template <> struct xptr_traits<PrivateKey<DCRTPoly>> {
  static const char* name() { return "openfhe.R::PrivateKey"; } };
template <> struct xptr_traits<EvalKey<DCRTPoly>> {
  static const char* name() { return "openfhe.R::EvalKey"; } };
template <> struct xptr_traits<CCParams<CryptoContextCKKSRNS>> {
  static const char* name() { return "openfhe.R::CKKSParams"; } };
template <> struct xptr_traits<CCParams<CryptoContextBFVRNS>> {
  static const char* name() { return "openfhe.R::BFVParams"; } };
template <> struct xptr_traits<CCParams<CryptoContextBGVRNS>> {
  static const char* name() { return "openfhe.R::BGVParams"; } };
template <> struct xptr_traits<LWECiphertext> {
  static const char* name() { return "openfhe.R::LWECiphertext"; } };
template <> struct xptr_traits<LWEPrivateKey> {
  static const char* name() { return "openfhe.R::LWEPrivateKey"; } };
template <> struct xptr_traits<std::shared_ptr<BinFHEContext>> {
  static const char* name() { return "openfhe.R::BinFHEContext"; } };
template <> struct xptr_traits<std::shared_ptr<std::map<uint32_t, EvalKey<DCRTPoly>>>> {
  static const char* name() { return "openfhe.R::EvalKeyMap"; } };
template <> struct xptr_traits<std::shared_ptr<std::unordered_map<uint32_t, DCRTPoly>>> {
  static const char* name() { return "openfhe.R::SecretShareMap"; } };
template <> struct xptr_traits<std::shared_ptr<std::vector<DCRTPoly>>> {
  static const char* name() { return "openfhe.R::FastRotationPrecomputation"; } };
template <> struct xptr_traits<std::shared_ptr<DCRTPoly::Params>> {
  static const char* name() { return "openfhe.R::ElementParams"; } };
template <> struct xptr_traits<std::shared_ptr<EncodingParamsImpl>> {
  static const char* name() { return "openfhe.R::EncodingParams"; } };
template <> struct xptr_traits<std::shared_ptr<CryptoParametersBase<DCRTPoly>>> {
  static const char* name() { return "openfhe.R::CryptoParameters"; } };

// The tag is an interned R symbol, so equality is pointer equality.
template <typename T>
inline SEXP xptr_tag() {
  static SEXP tag = Rf_install(xptr_traits<T>::name());
  return tag;
}

// Name carried by an arbitrary external pointer, or "" if it is not
// one of ours. Used by the R-side validator and by error messages.
inline const char* xptr_tag_name(SEXP xp) {
  if (TYPEOF(xp) != EXTPTRSXP) return "";
  SEXP tag = R_ExternalPtrTag(xp);
  if (TYPEOF(tag) != SYMSXP) return "";
  return CHAR(PRINTNAME(tag));
}

// ---- the pointer ----------------------------------------------------------

template <typename T, void Deleter(T*) = cpp11::default_deleter<T>>
class xptr : public cpp11::external_pointer<T, Deleter> {
  using base = cpp11::external_pointer<T, Deleter>;

  static SEXP checked(SEXP xp) {
    const char* want = xptr_traits<T>::name();
    if (xp == nullptr || TYPEOF(xp) == NILSXP) {
      cpp11::stop("expected a <%s> handle, got NULL", want);
    }
    if (TYPEOF(xp) != EXTPTRSXP) {
      cpp11::stop("expected a <%s> handle, got an R object of type '%s'",
                  want, Rf_type2char(TYPEOF(xp)));
    }
    if (R_ExternalPtrTag(xp) != xptr_tag<T>()) {
      const char* got = xptr_tag_name(xp);
      if (got[0] == '\0') got = "an untagged external pointer";
      cpp11::stop("expected a <%s> handle, got <%s>", want, got);
    }
    if (R_ExternalPtrAddr(xp) == nullptr) {
      cpp11::stop("<%s> handle is null: the object was released or never initialized",
                  want);
    }
    return xp;
  }

 public:
  using pointer = T*;

  xptr() noexcept : base() {}
  xptr(std::nullptr_t) noexcept : base() {}

  // Consumption: a SEXP coming in from R.
  xptr(SEXP data) : base(checked(data)) {}

  // Creation: a freshly allocated T going out to R.
  xptr(pointer p, bool use_deleter = true, bool finalize_on_exit = true)
      : base(p, use_deleter, finalize_on_exit) {
    R_SetExternalPtrTag(static_cast<SEXP>(*this), xptr_tag<T>());
  }
};

}  // namespace openfhe_r

using openfhe_r::xptr;
