// OPENFHE PYTHON SOURCE: src/lib/bindings.cpp (SchSwchParams; scheme switching between CKKS and FHEW)
//
// SchSwchParams: one registered setter and one getter cover the 19
// fields, selected by a field code (enum SchSwchField below, mirrored
// by .SCHSWCH_FIELD in R/scheme-switching.R).
//
// The CryptoContext methods:
//
//   CKKS -> FHEW   EvalCKKStoFHEWSetup, EvalCKKStoFHEWKeyGen,
//                  EvalCKKStoFHEWPrecompute, EvalCKKStoFHEW
//   FHEW -> CKKS   EvalFHEWtoCKKSSetup, EvalFHEWtoCKKSKeyGen,
//                  EvalFHEWtoCKKS
//   both ways      EvalSchemeSwitchingSetup, EvalSchemeSwitchingKeyGen,
//                  EvalCompareSwitchPrecompute,
//                  EvalCompareSchemeSwitching,
//                  EvalMin/MaxSchemeSwitching and their Alt forms
//   accessors      Get/SetBinCCForSchemeSwitch, Get/SetSwkFC,
//                  SetParamsFromCKKSCryptocontext
#include "openfhe_cpp11.h"
#include "openfhe_helpers.h"
#include "wide_integers.h"

#include <memory>
#include <sstream>
#include <string>
#include <vector>

#include "scheme/scheme-swch-params.h"

using namespace cpp11;
using namespace openfhe_r;

namespace {

using CC = CryptoContext<DCRTPoly>;
using BinCtx = std::shared_ptr<BinFHEContext>;

enum SchSwchField {
  F_SECURITY_LEVEL_CKKS = 0,
  F_SECURITY_LEVEL_FHEW = 1,
  F_ARBITRARY_FUNCTION_EVALUATION = 2,
  F_USE_DYNAMIC_MODE_FHEW = 3,
  F_COMPUTE_ARGMIN = 4,
  F_ONE_HOT_ENCODING = 5,
  F_USE_ALT_ARGMIN = 6,
  F_NUM_SLOTS_CKKS = 7,
  F_NUM_VALUES = 8,
  F_CTXT_MOD_SIZE_FHEW_LARGE_PREC = 9,
  F_CTXT_MOD_SIZE_FHEW_INTERMED_SWCH = 10,
  F_B_STEP_LTR_CKKS_TO_FHEW = 11,
  F_B_STEP_LTR_FHEW_TO_CKKS = 12,
  F_LEVEL_LTR_CKKS_TO_FHEW = 13,
  F_LEVEL_LTR_FHEW_TO_CKKS = 14,
  F_RING_DIMENSION = 15,
  F_SCALING_MOD_SIZE = 16,
  F_BATCH_SIZE = 17
};

KeyPair<DCRTPoly> key_pair(SEXP pk_xp, SEXP sk_xp) {
  xptr<PublicKey<DCRTPoly>> pk(pk_xp);
  xptr<PrivateKey<DCRTPoly>> sk(sk_xp);
  return KeyPair<DCRTPoly>(*pk, *sk);
}

SEXP ct_out(const Ciphertext<DCRTPoly>& ct) {
  if (!ct) cpp11::stop("the library returned no ciphertext");
  return xptr<Ciphertext<DCRTPoly>>(new Ciphertext<DCRTPoly>(ct));
}

list ct_list(const std::vector<Ciphertext<DCRTPoly>>& v) {
  writable::list out(static_cast<R_xlen_t>(v.size()));
  for (size_t i = 0; i < v.size(); ++i)
    out[static_cast<R_xlen_t>(i)] = ct_out(v[i]);
  return out;
}

SEXP lwe_sk_out(const LWEPrivateKey& sk) {
  if (!sk) cpp11::stop("the library returned no FHEW secret key");
  return xptr<LWEPrivateKey>(new LWEPrivateKey(sk));
}

}  // namespace

// ── SchSwchParams ───────────────────────────────────────

[[cpp11::register]]
SEXP SchSwchParams__new() {
  return xptr<SchSwchParams>(new SchSwchParams());
}

// Every field but the initial CKKS modulus: integers, enum members and
// logicals all arrive as an int.
[[cpp11::register]]
void SchSwchParams__Set(SEXP xp, int field, int value) {
  xptr<SchSwchParams> p(xp);
  catch_openfhe("SchSwchParams::Set", [&]() {
    const uint32_t u = static_cast<uint32_t>(value);
    switch (field) {
      case F_SECURITY_LEVEL_CKKS: p->SetSecurityLevelCKKS(static_cast<SecurityLevel>(value)); break;
      case F_SECURITY_LEVEL_FHEW: p->SetSecurityLevelFHEW(static_cast<BINFHE_PARAMSET>(value)); break;
      case F_ARBITRARY_FUNCTION_EVALUATION: p->SetArbitraryFunctionEvaluation(value != 0); break;
      case F_USE_DYNAMIC_MODE_FHEW: p->SetUseDynamicModeFHEW(value != 0); break;
      case F_COMPUTE_ARGMIN: p->SetComputeArgmin(value != 0); break;
      case F_ONE_HOT_ENCODING: p->SetOneHotEncoding(value != 0); break;
      case F_USE_ALT_ARGMIN: p->SetUseAltArgmin(value != 0); break;
      case F_NUM_SLOTS_CKKS: p->SetNumSlotsCKKS(u); break;
      case F_NUM_VALUES: p->SetNumValues(u); break;
      case F_CTXT_MOD_SIZE_FHEW_LARGE_PREC: p->SetCtxtModSizeFHEWLargePrec(u); break;
      case F_CTXT_MOD_SIZE_FHEW_INTERMED_SWCH: p->SetCtxtModSizeFHEWIntermedSwch(u); break;
      case F_B_STEP_LTR_CKKS_TO_FHEW: p->SetBStepLTrCKKStoFHEW(u); break;
      case F_B_STEP_LTR_FHEW_TO_CKKS: p->SetBStepLTrFHEWtoCKKS(u); break;
      case F_LEVEL_LTR_CKKS_TO_FHEW: p->SetLevelLTrCKKStoFHEW(u); break;
      case F_LEVEL_LTR_FHEW_TO_CKKS: p->SetLevelLTrFHEWtoCKKS(u); break;
      case F_RING_DIMENSION: p->SetRingDimension(u); break;
      case F_SCALING_MOD_SIZE: p->SetScalingModSize(u); break;
      case F_BATCH_SIZE: p->SetBatchSize(u); break;
      default: cpp11::stop("unknown SchSwchParams field code %d", field);
    }
    return true;
  });
}

// The getters verify the object first (VerifyObjectData), so they
// throw until SetParamsFromCKKSCryptocontext has run.
[[cpp11::register]]
int SchSwchParams__Get(SEXP xp, int field) {
  xptr<SchSwchParams> p(xp);
  return catch_openfhe("SchSwchParams::Get", [&]() -> int {
    switch (field) {
      case F_SECURITY_LEVEL_CKKS: return static_cast<int>(p->GetSecurityLevelCKKS());
      case F_SECURITY_LEVEL_FHEW: return static_cast<int>(p->GetSecurityLevelFHEW());
      case F_ARBITRARY_FUNCTION_EVALUATION: return p->GetArbitraryFunctionEvaluation();
      case F_USE_DYNAMIC_MODE_FHEW: return p->GetUseDynamicModeFHEW();
      case F_COMPUTE_ARGMIN: return p->GetComputeArgmin();
      case F_ONE_HOT_ENCODING: return p->GetOneHotEncoding();
      case F_USE_ALT_ARGMIN: return p->GetUseAltArgmin();
      case F_NUM_SLOTS_CKKS: return static_cast<int>(p->GetNumSlotsCKKS());
      case F_NUM_VALUES: return static_cast<int>(p->GetNumValues());
      case F_CTXT_MOD_SIZE_FHEW_LARGE_PREC: return static_cast<int>(p->GetCtxtModSizeFHEWLargePrec());
      case F_CTXT_MOD_SIZE_FHEW_INTERMED_SWCH: return static_cast<int>(p->GetCtxtModSizeFHEWIntermedSwch());
      case F_B_STEP_LTR_CKKS_TO_FHEW: return static_cast<int>(p->GetBStepLTrCKKStoFHEW());
      case F_B_STEP_LTR_FHEW_TO_CKKS: return static_cast<int>(p->GetBStepLTrFHEWtoCKKS());
      case F_LEVEL_LTR_CKKS_TO_FHEW: return static_cast<int>(p->GetLevelLTrCKKStoFHEW());
      case F_LEVEL_LTR_FHEW_TO_CKKS: return static_cast<int>(p->GetLevelLTrFHEWtoCKKS());
      case F_RING_DIMENSION: return static_cast<int>(p->GetRingDimension());
      case F_SCALING_MOD_SIZE: return static_cast<int>(p->GetScalingModSize());
      case F_BATCH_SIZE: return static_cast<int>(p->GetBatchSize());
    }
    cpp11::stop("unknown SchSwchParams field code %d", field);
  });
}

[[cpp11::register]]
void SchSwchParams__SetInitialCKKSModulus(SEXP xp, std::string modulus) {
  xptr<SchSwchParams> p(xp);
  catch_openfhe("SchSwchParams::SetInitialCKKSModulus", [&]() {
    p->SetInitialCKKSModulus(wide_from_r<NativeInteger>(modulus, "value"));
    return true;
  });
}

[[cpp11::register]]
std::string SchSwchParams__GetInitialCKKSModulus(SEXP xp) {
  xptr<SchSwchParams> p(xp);
  return catch_openfhe("SchSwchParams::GetInitialCKKSModulus", [&]() {
    return wide_to_r(p->GetInitialCKKSModulus());
  });
}

[[cpp11::register]]
void SchSwchParams__SetParamsFromCKKSCryptocontextCalled(SEXP xp) {
  xptr<SchSwchParams> p(xp);
  p->SetParamsFromCKKSCryptocontextCalled();
}

[[cpp11::register]]
std::string SchSwchParams__str(SEXP xp) {
  xptr<SchSwchParams> p(xp);
  std::ostringstream os;
  os << *p;
  return os.str();
}

// ── CryptoContext accessors ─────────────────────────────

[[cpp11::register]]
void SetParamsFromCKKSCryptocontext__(SEXP cc_xp, SEXP params_xp) {
  xptr<CC> cc(cc_xp);
  xptr<SchSwchParams> p(params_xp);
  catch_openfhe("CryptoContext::SetParamsFromCKKSCryptocontext", [&]() {
    (*cc)->SetParamsFromCKKSCryptocontext(*p);
    return true;
  });
}

// R NULL when the context holds none.
[[cpp11::register]]
SEXP GetBinCCForSchemeSwitch__(SEXP cc_xp) {
  xptr<CC> cc(cc_xp);
  return catch_openfhe("CryptoContext::GetBinCCForSchemeSwitch", [&]() -> SEXP {
    BinCtx b = (*cc)->GetBinCCForSchemeSwitch();
    if (!b) return R_NilValue;
    return xptr<BinCtx>(new BinCtx(b));
  });
}

[[cpp11::register]]
void SetBinCCForSchemeSwitch__(SEXP cc_xp, SEXP bin_xp) {
  xptr<CC> cc(cc_xp);
  xptr<BinCtx> b(bin_xp);
  catch_openfhe("CryptoContext::SetBinCCForSchemeSwitch", [&]() {
    (*cc)->SetBinCCForSchemeSwitch(*b);
    return true;
  });
}

[[cpp11::register]]
SEXP GetSwkFC__(SEXP cc_xp) {
  xptr<CC> cc(cc_xp);
  return catch_openfhe("CryptoContext::GetSwkFC", [&]() -> SEXP {
    Ciphertext<DCRTPoly> ct = (*cc)->GetSwkFC();
    if (!ct) return R_NilValue;
    return xptr<Ciphertext<DCRTPoly>>(new Ciphertext<DCRTPoly>(ct));
  });
}

[[cpp11::register]]
void SetSwkFC__(SEXP cc_xp, SEXP ct_xp) {
  xptr<CC> cc(cc_xp);
  xptr<Ciphertext<DCRTPoly>> ct(ct_xp);
  catch_openfhe("CryptoContext::SetSwkFC", [&]() {
    (*cc)->SetSwkFC(*ct);
    return true;
  });
}

// ── CKKS -> FHEW ────────────────────────────────────────

// both = false: EvalCKKStoFHEWSetup; true: EvalSchemeSwitchingSetup.
// Either fills `params` from the context first; the handle keeps the
// filled values.
[[cpp11::register]]
SEXP SchemeSwitchSetup__(SEXP cc_xp, SEXP params_xp, bool both) {
  xptr<CC> cc(cc_xp);
  xptr<SchSwchParams> p(params_xp);
  return catch_openfhe(
      "CryptoContext::Eval{CKKStoFHEW,SchemeSwitching}Setup", [&]() {
    if (both) return lwe_sk_out((*cc)->EvalSchemeSwitchingSetup(*p));
    // The C++ method takes the parameters by value; fill the handle's
    // copy too so that its getters work afterwards, as they do after
    // EvalSchemeSwitchingSetup.
    (*cc)->SetParamsFromCKKSCryptocontext(*p);
    return lwe_sk_out((*cc)->EvalCKKStoFHEWSetup(*p));
  });
}

// The names of the three key-generation bindings in this file spell
// the acronyms in lower case so that test_no_hidden_folds.R derives
// the names of their R wrappers from them.
[[cpp11::register]]
void EvalCkksToFhewKeyGen__(SEXP cc_xp, SEXP pk_xp, SEXP sk_xp,
                            SEXP lwesk_xp) {
  xptr<CC> cc(cc_xp);
  xptr<LWEPrivateKey> lwesk(lwesk_xp);
  catch_openfhe("CryptoContext::EvalCKKStoFHEWKeyGen", [&]() {
    KeyPair<DCRTPoly> kp = key_pair(pk_xp, sk_xp);
    ConstLWEPrivateKey csk = *lwesk;
    (*cc)->EvalCKKStoFHEWKeyGen(kp, csk);
    return true;
  });
}

[[cpp11::register]]
void EvalSchemeSwitchingKeyGen__(SEXP cc_xp, SEXP pk_xp, SEXP sk_xp,
                                 SEXP lwesk_xp) {
  xptr<CC> cc(cc_xp);
  xptr<LWEPrivateKey> lwesk(lwesk_xp);
  catch_openfhe("CryptoContext::EvalSchemeSwitchingKeyGen", [&]() {
    KeyPair<DCRTPoly> kp = key_pair(pk_xp, sk_xp);
    ConstLWEPrivateKey csk = *lwesk;
    (*cc)->EvalSchemeSwitchingKeyGen(kp, csk);
    return true;
  });
}

[[cpp11::register]]
void EvalCKKStoFHEWPrecompute__(SEXP cc_xp, double scale) {
  xptr<CC> cc(cc_xp);
  catch_openfhe("CryptoContext::EvalCKKStoFHEWPrecompute", [&]() {
    (*cc)->EvalCKKStoFHEWPrecompute(scale);
    return true;
  });
}

[[cpp11::register]]
list EvalCKKStoFHEW__(SEXP ct_xp, int num_ctxts) {
  xptr<Ciphertext<DCRTPoly>> ct(ct_xp);
  return catch_openfhe("CryptoContext::EvalCKKStoFHEW", [&]() {
    auto cc = (*ct)->GetCryptoContext();
    ConstCiphertext<DCRTPoly> cct = *ct;
    std::vector<LWECiphertext> v =
        cc->EvalCKKStoFHEW(cct, static_cast<uint32_t>(num_ctxts));
    writable::list out(static_cast<R_xlen_t>(v.size()));
    for (size_t i = 0; i < v.size(); ++i)
      out[static_cast<R_xlen_t>(i)] =
          xptr<LWECiphertext>(new LWECiphertext(v[i]));
    return list(out);
  });
}

// ── FHEW -> CKKS ────────────────────────────────────────

[[cpp11::register]]
void EvalFHEWtoCKKSSetup__(SEXP cc_xp, SEXP bin_xp, int num_slots_ckks,
                           int log_q) {
  xptr<CC> cc(cc_xp);
  xptr<BinCtx> b(bin_xp);
  catch_openfhe("CryptoContext::EvalFHEWtoCKKSSetup", [&]() {
    (*cc)->EvalFHEWtoCKKSSetup(*b, static_cast<uint32_t>(num_slots_ckks),
                               static_cast<uint32_t>(log_q));
    return true;
  });
}

[[cpp11::register]]
void EvalFhewToCkksKeyGen__(SEXP cc_xp, SEXP pk_xp, SEXP sk_xp, SEXP lwesk_xp,
                            int num_slots, int num_ctxts, int dim1, int l) {
  xptr<CC> cc(cc_xp);
  xptr<LWEPrivateKey> lwesk(lwesk_xp);
  catch_openfhe("CryptoContext::EvalFHEWtoCKKSKeyGen", [&]() {
    KeyPair<DCRTPoly> kp = key_pair(pk_xp, sk_xp);
    ConstLWEPrivateKey csk = *lwesk;
    (*cc)->EvalFHEWtoCKKSKeyGen(kp, csk, static_cast<uint32_t>(num_slots),
                                static_cast<uint32_t>(num_ctxts),
                                static_cast<uint32_t>(dim1),
                                static_cast<uint32_t>(l));
    return true;
  });
}

[[cpp11::register]]
SEXP EvalFHEWtoCKKS__(SEXP cc_xp, list lwe_ciphertexts, int num_ctxts,
                      int num_slots, int p, double pmin, double pmax,
                      int dim1) {
  xptr<CC> cc(cc_xp);
  std::vector<LWECiphertext> v;
  v.reserve(lwe_ciphertexts.size());
  for (R_xlen_t i = 0; i < lwe_ciphertexts.size(); ++i) {
    SEXP xp = lwe_ciphertexts[i];
    xptr<LWECiphertext> ct(xp);
    v.push_back(*ct);
  }
  return catch_openfhe("CryptoContext::EvalFHEWtoCKKS", [&]() {
    return ct_out((*cc)->EvalFHEWtoCKKS(
        v, static_cast<uint32_t>(num_ctxts), static_cast<uint32_t>(num_slots),
        static_cast<uint32_t>(p), pmin, pmax, static_cast<uint32_t>(dim1)));
  });
}

// ── Comparison, minimum and maximum ─────────────────────

[[cpp11::register]]
void EvalCompareSwitchPrecompute__(SEXP cc_xp, int p_lwe, double scale_sign,
                                   bool unit) {
  xptr<CC> cc(cc_xp);
  catch_openfhe("CryptoContext::EvalCompareSwitchPrecompute", [&]() {
    (*cc)->EvalCompareSwitchPrecompute(static_cast<uint32_t>(p_lwe),
                                       scale_sign, unit);
    return true;
  });
}

[[cpp11::register]]
SEXP EvalCompareSchemeSwitching__(SEXP ct1_xp, SEXP ct2_xp, int num_ctxts,
                                  int num_slots, int p_lwe, double scale_sign,
                                  bool unit) {
  xptr<Ciphertext<DCRTPoly>> ct1(ct1_xp);
  xptr<Ciphertext<DCRTPoly>> ct2(ct2_xp);
  return catch_openfhe("CryptoContext::EvalCompareSchemeSwitching", [&]() {
    auto cc = (*ct1)->GetCryptoContext();
    ConstCiphertext<DCRTPoly> c1 = *ct1;
    ConstCiphertext<DCRTPoly> c2 = *ct2;
    return ct_out(cc->EvalCompareSchemeSwitching(
        c1, c2, static_cast<uint32_t>(num_ctxts),
        static_cast<uint32_t>(num_slots), static_cast<uint32_t>(p_lwe),
        scale_sign, unit));
  });
}

// which: 0 min, 1 min (alt), 2 max, 3 max (alt)
[[cpp11::register]]
list EvalMinMaxSchemeSwitching__(SEXP ct_xp, SEXP pk_xp, int which,
                                 int num_values, int num_slots, int p_lwe,
                                 double scale_sign) {
  xptr<Ciphertext<DCRTPoly>> ct(ct_xp);
  xptr<PublicKey<DCRTPoly>> pk(pk_xp);
  return catch_openfhe("CryptoContext::Eval{Min,Max}SchemeSwitching", [&]() {
    auto cc = (*ct)->GetCryptoContext();
    ConstCiphertext<DCRTPoly> cct = *ct;
    PublicKey<DCRTPoly> key = *pk;
    const uint32_t nv = static_cast<uint32_t>(num_values);
    const uint32_t ns = static_cast<uint32_t>(num_slots);
    const uint32_t pl = static_cast<uint32_t>(p_lwe);
    switch (which) {
      case 0: return ct_list(cc->EvalMinSchemeSwitching(cct, key, nv, ns, pl, scale_sign));
      case 1: return ct_list(cc->EvalMinSchemeSwitchingAlt(cct, key, nv, ns, pl, scale_sign));
      case 2: return ct_list(cc->EvalMaxSchemeSwitching(cct, key, nv, ns, pl, scale_sign));
      case 3: return ct_list(cc->EvalMaxSchemeSwitchingAlt(cct, key, nv, ns, pl, scale_sign));
    }
    cpp11::stop("unknown min/max code %d", which);
  });
}
