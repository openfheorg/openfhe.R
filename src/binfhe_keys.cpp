// OPENFHE PYTHON SOURCE: src/lib/binfhe_bindings.cpp (public-key encryption, key and parameter accessors, bootstrapping key management, LWE object accessors, serialization)
//
// The part of the BinFHE surface bound at OpenFHE 1.6.1:
//
//   keys          KeyGenN, KeyGenPair, PubKeyGen, KeySwitchGen, Encrypt
//                 with a public key, SwitchCTtoqn
//   evaluation    Bootstrap, EvalConstant, EvalDecomp
//   BT keys       GetBTKey, GetBTKeyMap, GetSwitchKey, GetPublicKey,
//                 BTKeyLoad, BTKeyMapLoadSingleElement, ClearBTKeys,
//                 HasInternal32RefreshKey, HasInternal32SwitchKey
//   parameters    Getn, GetN, Getq, GetQ, GetBeta
//   LWE objects   GetLength, GetModulus, GetptModulus, SetModulus,
//                 SetptModulus, ==
//   files         SerializeToFile and Deserialize* for BinFHEContext,
//                 LWECiphertext, LWEPrivateKey, LWEPublicKey,
//                 RingGSWBTKey
//
// A RingGSWBTKey handle owns a copy of the struct (its members are
// shared pointers, so the copy shares the key material). Moduli are
// NativeInteger values: the ones that are small in ordinary use go out
// through uint64_to_r, the rest as strings of decimal digits
// (wide_integers.h).
#include "openfhe_cpp11.h"
#include "openfhe_helpers.h"
#include "wide_integers.h"

#include <map>
#include <memory>
#include <string>
#include <vector>

#include "binfhecontext-ser.h"
#include "binfhecontext.h"

using namespace cpp11;
using namespace openfhe_r;

namespace {

using BinCtx = std::shared_ptr<BinFHEContext>;

SEXP ct_out(const LWECiphertext& ct) {
  if (!ct) cpp11::stop("the library returned no ciphertext");
  return xptr<LWECiphertext>(new LWECiphertext(ct));
}

SEXP btkey_out(const RingGSWBTKey& k) {
  return xptr<RingGSWBTKey>(new RingGSWBTKey(k));
}

template <typename Fn>
auto with_sertype(bool binary, Fn&& fn) {
  return binary ? fn(SerType::BINARY) : fn(SerType::JSON);
}

template <typename T>
bool to_file(const T& obj, const std::string& filename, bool binary) {
  return with_sertype(binary, [&](const auto& st) {
    return Serial::SerializeToFile(filename, obj, st);
  });
}

template <typename T>
T from_file(const std::string& filename, bool binary, const char* what) {
  T obj;
  bool ok = with_sertype(binary, [&](const auto& st) {
    return Serial::DeserializeFromFile(filename, obj, st);
  });
  if (!ok) cpp11::stop("Failed to deserialize %s from '%s'", what, filename.c_str());
  return obj;
}

}  // namespace

// ── Keys ────────────────────────────────────────────────

[[cpp11::register]]
SEXP BinFHEContext__KeyGenN(SEXP ctx_xp) {
  xptr<BinCtx> ctx(ctx_xp);
  return catch_openfhe("BinFHEContext::KeyGenN", [&]() {
    return xptr<LWEPrivateKey>(new LWEPrivateKey((*ctx)->KeyGenN()));
  });
}

[[cpp11::register]]
list BinFHEContext__KeyGenPair(SEXP ctx_xp) {
  xptr<BinCtx> ctx(ctx_xp);
  return catch_openfhe("BinFHEContext::KeyGenPair", [&]() {
    LWEKeyPair kp = (*ctx)->KeyGenPair();
    if (!kp || !kp->good()) cpp11::stop("key pair generation failed");
    writable::list out;
    out.push_back({"public"_nm = xptr<LWEPublicKey>(new LWEPublicKey(kp->publicKey))});
    out.push_back({"secret"_nm = xptr<LWEPrivateKey>(new LWEPrivateKey(kp->secretKey))});
    return list(out);
  });
}

[[cpp11::register]]
SEXP BinFHEContext__PubKeyGen(SEXP ctx_xp, SEXP sk_xp) {
  xptr<BinCtx> ctx(ctx_xp);
  xptr<LWEPrivateKey> sk(sk_xp);
  return catch_openfhe("BinFHEContext::PubKeyGen", [&]() {
    ConstLWEPrivateKey csk = *sk;
    return xptr<LWEPublicKey>(new LWEPublicKey((*ctx)->PubKeyGen(csk)));
  });
}

[[cpp11::register]]
SEXP BinFHEContext__KeySwitchGen(SEXP ctx_xp, SEXP sk_xp, SEXP skn_xp) {
  xptr<BinCtx> ctx(ctx_xp);
  xptr<LWEPrivateKey> sk(sk_xp);
  xptr<LWEPrivateKey> skn(skn_xp);
  return catch_openfhe("BinFHEContext::KeySwitchGen", [&]() {
    ConstLWEPrivateKey csk = *sk;
    ConstLWEPrivateKey cskn = *skn;
    return xptr<LWESwitchingKey>(
        new LWESwitchingKey((*ctx)->KeySwitchGen(csk, cskn)));
  });
}

// Encrypt under a public key. p and mod arrive as decimal strings.
[[cpp11::register]]
SEXP BinFHEContext__EncryptPK(SEXP ctx_xp, SEXP pk_xp, double message,
                              int output, std::string p, std::string mod) {
  xptr<BinCtx> ctx(ctx_xp);
  xptr<LWEPublicKey> pk(pk_xp);
  return catch_openfhe("BinFHEContext::Encrypt", [&]() {
    ConstLWEPublicKey cpk = *pk;
    return ct_out((*ctx)->Encrypt(
        cpk, static_cast<LWEPlaintext>(std::llround(message)),
        static_cast<BINFHE_OUTPUT>(output),
        static_cast<LWEPlaintextModulus>(uint64_from_r(p, "p")),
        wide_from_r<NativeInteger>(mod, "mod")));
  });
}

[[cpp11::register]]
SEXP BinFHEContext__SwitchCTtoqn(SEXP ctx_xp, SEXP ksk_xp, SEXP ct_xp) {
  xptr<BinCtx> ctx(ctx_xp);
  xptr<LWESwitchingKey> ksk(ksk_xp);
  xptr<LWECiphertext> ct(ct_xp);
  return catch_openfhe("BinFHEContext::SwitchCTtoqn", [&]() {
    if (!*ksk) cpp11::stop("null switching key");
    ConstLWESwitchingKey cksk = *ksk;
    ConstLWECiphertext cct = *ct;
    return ct_out((*ctx)->SwitchCTtoqn(cksk, cct));
  });
}

// ── Evaluation ──────────────────────────────────────────

[[cpp11::register]]
SEXP BinFHEContext__Bootstrap(SEXP ctx_xp, SEXP ct_xp, bool extended) {
  xptr<BinCtx> ctx(ctx_xp);
  xptr<LWECiphertext> ct(ct_xp);
  return catch_openfhe("BinFHEContext::Bootstrap", [&]() {
    ConstLWECiphertext cct = *ct;
    return ct_out((*ctx)->Bootstrap(cct, extended));
  });
}

[[cpp11::register]]
SEXP BinFHEContext__EvalConstant(SEXP ctx_xp, bool value) {
  xptr<BinCtx> ctx(ctx_xp);
  return catch_openfhe("BinFHEContext::EvalConstant", [&]() {
    return ct_out((*ctx)->EvalConstant(value));
  });
}

[[cpp11::register]]
list BinFHEContext__EvalDecomp(SEXP ctx_xp, SEXP ct_xp) {
  xptr<BinCtx> ctx(ctx_xp);
  xptr<LWECiphertext> ct(ct_xp);
  return catch_openfhe("BinFHEContext::EvalDecomp", [&]() {
    ConstLWECiphertext cct = *ct;
    std::vector<LWECiphertext> v = (*ctx)->EvalDecomp(cct);
    writable::list out(static_cast<R_xlen_t>(v.size()));
    for (size_t i = 0; i < v.size(); ++i)
      out[static_cast<R_xlen_t>(i)] = ct_out(v[i]);
    return list(out);
  });
}

// ── Bootstrapping keys ──────────────────────────────────

[[cpp11::register]]
SEXP BinFHEContext__GetBTKey(SEXP ctx_xp) {
  xptr<BinCtx> ctx(ctx_xp);
  return btkey_out((*ctx)->GetBTKey());
}

// Named by baseG.
[[cpp11::register]]
list BinFHEContext__GetBTKeyMap(SEXP ctx_xp) {
  xptr<BinCtx> ctx(ctx_xp);
  auto m = (*ctx)->GetBTKeyMap();
  const R_xlen_t n = m ? static_cast<R_xlen_t>(m->size()) : 0;
  writable::list out(n);
  writable::strings names(n);
  if (m) {
    R_xlen_t i = 0;
    for (const auto& kv : *m) {
      out[i] = btkey_out(kv.second);
      names[i] = std::to_string(kv.first);
      ++i;
    }
  }
  out.names() = names;
  return list(out);
}

// R NULL when the context holds no such key.
[[cpp11::register]]
SEXP BinFHEContext__GetSwitchKey(SEXP ctx_xp) {
  xptr<BinCtx> ctx(ctx_xp);
  const LWESwitchingKey& k = (*ctx)->GetSwitchKey();
  if (!k) return R_NilValue;
  return xptr<LWESwitchingKey>(new LWESwitchingKey(k));
}

[[cpp11::register]]
SEXP BinFHEContext__GetPublicKey(SEXP ctx_xp) {
  xptr<BinCtx> ctx(ctx_xp);
  const LWEPublicKey& k = (*ctx)->GetPublicKey();
  if (!k) return R_NilValue;
  return xptr<LWEPublicKey>(new LWEPublicKey(k));
}

[[cpp11::register]]
void BinFHEContext__BTKeyLoad(SEXP ctx_xp, SEXP key_xp, bool internal32) {
  xptr<BinCtx> ctx(ctx_xp);
  xptr<RingGSWBTKey> key(key_xp);
  catch_openfhe("BinFHEContext::BTKeyLoad", [&]() {
    (*ctx)->BTKeyLoad(*key, internal32);
    return true;
  });
}

[[cpp11::register]]
void BinFHEContext__BTKeyMapLoadSingleElement(SEXP ctx_xp, int base_g,
                                              SEXP key_xp) {
  xptr<BinCtx> ctx(ctx_xp);
  xptr<RingGSWBTKey> key(key_xp);
  catch_openfhe("BinFHEContext::BTKeyMapLoadSingleElement", [&]() {
    (*ctx)->BTKeyMapLoadSingleElement(static_cast<uint32_t>(base_g), *key);
    return true;
  });
}

[[cpp11::register]]
void BinFHEContext__ClearBTKeys(SEXP ctx_xp) {
  xptr<BinCtx> ctx(ctx_xp);
  (*ctx)->ClearBTKeys();
}

[[cpp11::register]]
bool BinFHEContext__HasInternal32Key(SEXP ctx_xp, bool refresh) {
  xptr<BinCtx> ctx(ctx_xp);
  return refresh ? (*ctx)->HasInternal32RefreshKey()
                 : (*ctx)->HasInternal32SwitchKey();
}

// ── Parameters ──────────────────────────────────────────
//
// which: 0 n, 1 N, 2 q, 3 Q, 4 beta
[[cpp11::register]]
SEXP BinFHEContext__GetParam(SEXP ctx_xp, int which) {
  xptr<BinCtx> ctx(ctx_xp);
  return catch_openfhe("BinFHEContext::GetParams", [&]() -> SEXP {
    if (which == 4)
      return uint64_to_r((*ctx)->GetBeta().ConvertToInt<uint64_t>());
    const auto& params = (*ctx)->GetParams();
    if (!params) cpp11::stop("the context has no parameters; generate it first");
    const auto& lwe = params->GetLWEParams();
    switch (which) {
      case 0: return cpp11::as_sexp(static_cast<int>(lwe->Getn()));
      case 1: return cpp11::as_sexp(static_cast<int>(lwe->GetN()));
      case 2: return uint64_to_r(lwe->Getq().ConvertToInt<uint64_t>());
      case 3: return uint64_to_r(lwe->GetQ().ConvertToInt<uint64_t>());
    }
    cpp11::stop("unknown parameter code %d", which);
  });
}

[[cpp11::register]]
std::string BinFHEContext__SerializedObjectName(SEXP ctx_xp) {
  xptr<BinCtx> ctx(ctx_xp);
  return (*ctx)->SerializedObjectName();
}

[[cpp11::register]]
int BinFHEContext__SerializedVersion() {
  return static_cast<int>(BinFHEContext::SerializedVersion());
}

// ── LWE objects ─────────────────────────────────────────
//
// kind: 0 LWECiphertext, 1 LWEPrivateKey, 2 LWEPublicKey

[[cpp11::register]]
int LWE__GetLength(SEXP xp, int kind) {
  switch (kind) {
    case 0: { xptr<LWECiphertext> x(xp); return static_cast<int>((*x)->GetLength()); }
    case 1: { xptr<LWEPrivateKey> x(xp); return static_cast<int>((*x)->GetLength()); }
    case 2: { xptr<LWEPublicKey> x(xp); return static_cast<int>((*x)->GetLength()); }
  }
  cpp11::stop("unknown LWE object kind %d", kind);
}

[[cpp11::register]]
std::string LWE__GetModulus(SEXP xp, int kind) {
  switch (kind) {
    case 0: { xptr<LWECiphertext> x(xp); return wide_to_r((*x)->GetModulus()); }
    case 1: { xptr<LWEPrivateKey> x(xp); return wide_to_r((*x)->GetModulus()); }
    case 2: { xptr<LWEPublicKey> x(xp); return wide_to_r((*x)->GetModulus()); }
  }
  cpp11::stop("unknown LWE object kind %d", kind);
}

[[cpp11::register]]
bool LWE__equal(SEXP a_xp, SEXP b_xp, int kind) {
  switch (kind) {
    case 0: { xptr<LWECiphertext> a(a_xp), b(b_xp); return **a == **b; }
    case 1: { xptr<LWEPrivateKey> a(a_xp), b(b_xp); return **a == **b; }
    case 2: { xptr<LWEPublicKey> a(a_xp), b(b_xp); return **a == **b; }
  }
  cpp11::stop("unknown LWE object kind %d", kind);
}

[[cpp11::register]]
SEXP LWECiphertext__GetptModulus(SEXP ct_xp) {
  xptr<LWECiphertext> ct(ct_xp);
  return uint64_to_r((*ct)->GetptModulus().ConvertToInt<uint64_t>());
}

[[cpp11::register]]
void LWECiphertext__SetModulus(SEXP ct_xp, std::string modulus) {
  xptr<LWECiphertext> ct(ct_xp);
  catch_openfhe("LWECiphertext::SetModulus", [&]() {
    (*ct)->SetModulus(wide_from_r<NativeInteger>(modulus, "modulus"));
    return true;
  });
}

[[cpp11::register]]
void LWECiphertext__SetptModulus(SEXP ct_xp, std::string plaintext_modulus) {
  xptr<LWECiphertext> ct(ct_xp);
  catch_openfhe("LWECiphertext::SetptModulus", [&]() {
    (*ct)->SetptModulus(
        wide_from_r<NativeInteger>(plaintext_modulus, "plaintext_modulus"));
    return true;
  });
}

// ── Files ───────────────────────────────────────────────
//
// kind: 0 BinFHEContext, 1 LWECiphertext, 2 LWEPrivateKey,
//       3 LWEPublicKey, 4 RingGSWBTKey

[[cpp11::register]]
bool BinFHE__SerializeToFile(SEXP xp, int kind, std::string filename,
                             bool binary) {
  return catch_openfhe("Serial::SerializeToFile", [&]() -> bool {
    switch (kind) {
      case 0: { xptr<BinCtx> x(xp); return to_file(**x, filename, binary); }
      case 1: { xptr<LWECiphertext> x(xp); return to_file(*x, filename, binary); }
      case 2: { xptr<LWEPrivateKey> x(xp); return to_file(*x, filename, binary); }
      case 3: { xptr<LWEPublicKey> x(xp); return to_file(*x, filename, binary); }
      case 4: { xptr<RingGSWBTKey> x(xp); return to_file(*x, filename, binary); }
    }
    cpp11::stop("unknown BinFHE object kind %d", kind);
  });
}

[[cpp11::register]]
SEXP BinFHE__DeserializeFromFile(std::string filename, int kind, bool binary) {
  return catch_openfhe("Serial::DeserializeFromFile", [&]() -> SEXP {
    switch (kind) {
      case 0: {
        auto ctx = std::make_shared<BinFHEContext>(
            from_file<BinFHEContext>(filename, binary, "BinFHEContext"));
        return xptr<BinCtx>(new BinCtx(ctx));
      }
      case 1: {
        auto x = from_file<LWECiphertext>(filename, binary, "LWECiphertext");
        if (!x) cpp11::stop("deserialization produced no LWECiphertext");
        return xptr<LWECiphertext>(new LWECiphertext(x));
      }
      case 2: {
        auto x = from_file<LWEPrivateKey>(filename, binary, "LWEPrivateKey");
        if (!x) cpp11::stop("deserialization produced no LWEPrivateKey");
        return xptr<LWEPrivateKey>(new LWEPrivateKey(x));
      }
      case 3: {
        auto x = from_file<LWEPublicKey>(filename, binary, "LWEPublicKey");
        if (!x) cpp11::stop("deserialization produced no LWEPublicKey");
        return xptr<LWEPublicKey>(new LWEPublicKey(x));
      }
      case 4:
        return btkey_out(from_file<RingGSWBTKey>(filename, binary, "RingGSWBTKey"));
    }
    cpp11::stop("unknown BinFHE object kind %d", kind);
  });
}
