// OPENFHE PYTHON SOURCE: src/lib/bindings.cpp (CryptoContext getters)
//
// CryptoContext getter fleet.
//
// 21 new cpp11 bindings:
//   8 direct CryptoContext getters
//   1 direct CryptoContext setter (SetKeyGenLevel — the only mutable
//     field on CryptoContextImpl)
//   12 lambda-routed getters that go through
//      cc->GetCryptoParameters()->Get*() on the C++ side
//
// Design decisions captured during the getter-fleet work:
//   1. get_scheme(cc) NOT bound. design.md §11 Q3 resolution: the
//      Scheme shared_ptr is used only internally by CryptoContextImpl
//      for method dispatch; no user-facing need. get_scheme_id(cc)
//      already provides the integer SchemeId tag.
//   2. GetModulus / GetRootOfUnity deferred. Both return BigInteger
//      (IntType&) which needs string-wrapping or a new BigInteger
//      type to surface cleanly in R. 0-usage parity-deferred
//      anyway; not worth the complication.
//   3. SetNoiseEstimate / SetMultiplicativeDepth / SetEvalAddCount /
//      SetKeySwitchCount / SetPRENumHops NOT bound. These do not
//      exist as mutators on CryptoContextImpl — only the
//      CCParams constructor path can set them (before context
//      generation). Design.md §10's setter items are therefore
//      already covered there; only SetKeyGenLevel
//      (the one genuine CryptoContext-mutating setter) is bound.
//   4. GetScalingFactorReal deferred alongside the
//      Ciphertext accessors and fhe_ckks_tolerance() Stage 2 form.
//
// Every binding wraps its C++ call site in catch_openfhe per
// design.md §5.
#include "openfhe_cpp11.h"
#include "openfhe_helpers.h"

using namespace cpp11;

// ── Direct CryptoContext getters / setters ──────────────

[[cpp11::register]]
SEXP CryptoContext__GetCryptoParameters(SEXP cc_xp) {
  external_pointer<CryptoContext<DCRTPoly>> cc(cc_xp);
  return catch_openfhe("CryptoContext::GetCryptoParameters", [&]() {
    auto cp = (*cc)->GetCryptoParameters();
    return external_pointer<std::shared_ptr<CryptoParametersBase<DCRTPoly>>>(
        new std::shared_ptr<CryptoParametersBase<DCRTPoly>>(cp));
  });
}

[[cpp11::register]]
int CryptoContext__GetKeyGenLevel(SEXP cc_xp) {
  external_pointer<CryptoContext<DCRTPoly>> cc(cc_xp);
  return catch_openfhe("CryptoContext::GetKeyGenLevel", [&]() -> int {
    return static_cast<int>((*cc)->GetKeyGenLevel());
  });
}

[[cpp11::register]]
void CryptoContext__SetKeyGenLevel(SEXP cc_xp, int level) {
  external_pointer<CryptoContext<DCRTPoly>> cc(cc_xp);
  catch_openfhe("CryptoContext::SetKeyGenLevel", [&]() {
    (*cc)->SetKeyGenLevel(static_cast<size_t>(level));
  });
}

[[cpp11::register]]
SEXP CryptoContext__GetElementParams(SEXP cc_xp) {
  external_pointer<CryptoContext<DCRTPoly>> cc(cc_xp);
  return catch_openfhe("CryptoContext::GetElementParams", [&]() {
    auto ep = (*cc)->GetElementParams();
    return external_pointer<std::shared_ptr<typename DCRTPoly::Params>>(
        new std::shared_ptr<typename DCRTPoly::Params>(ep));
  });
}

[[cpp11::register]]
SEXP CryptoContext__GetEncodingParams(SEXP cc_xp) {
  external_pointer<CryptoContext<DCRTPoly>> cc(cc_xp);
  return catch_openfhe("CryptoContext::GetEncodingParams", [&]() {
    auto ep = (*cc)->GetEncodingParams();
    return external_pointer<std::shared_ptr<EncodingParamsImpl>>(
        new std::shared_ptr<EncodingParamsImpl>(ep));
  });
}

[[cpp11::register]]
int CryptoContext__GetCyclotomicOrder(SEXP cc_xp) {
  external_pointer<CryptoContext<DCRTPoly>> cc(cc_xp);
  return catch_openfhe("CryptoContext::GetCyclotomicOrder", [&]() -> int {
    return static_cast<int>((*cc)->GetCyclotomicOrder());
  });
}

[[cpp11::register]]
int CryptoContext__GetCKKSDataType(SEXP cc_xp) {
  external_pointer<CryptoContext<DCRTPoly>> cc(cc_xp);
  return catch_openfhe("CryptoContext::GetCKKSDataType", [&]() -> int {
    return static_cast<int>((*cc)->GetCKKSDataType());
  });
}

// ── Lambda-routed CryptoParameters getters ──────────────
//
// Each of these goes through cc->GetCryptoParameters()->Get*() on
// the C++ side. Some further route through GetEncodingParams()
// (e.g. GetBatchSize).
//
// CryptoParametersBase<DCRTPoly> only has a small subset of the
// getters we need — GetPlaintextModulus, GetEncodingParams,
// GetDigitSize (via the virtual default). The scheme-parameter
// getters (GetScalingTechnique, GetMultiplicativeDepth, etc.)
// live on CryptoParametersRNS (which inherits from
// CryptoParametersRLWE<DCRTPoly> which inherits from
// CryptoParametersBase<DCRTPoly>). We dynamic_pointer_cast from
// the base pointer to CryptoParametersRNS to reach them. In
// practice every OpenFHE context is RNS-based at DCRTPoly level,
// so the cast always succeeds; a null result would indicate a
// pre-RNS scheme which this binding does not target.
//
// Helper: cast the base crypto-parameters pointer to RNS, throwing
// through catch_openfhe if the cast fails. Non-static so other
// translation units (e.g. pke_ciphertext_accessors.cpp for the
// deferred GetScalingFactorReal binding) can extern-declare and
// reuse it.
std::shared_ptr<CryptoParametersRNS> as_rns_params(
    const std::shared_ptr<CryptoParametersBase<DCRTPoly>>& base,
    const char* op) {
  auto rns = std::dynamic_pointer_cast<CryptoParametersRNS>(base);
  if (!rns) {
    throw std::runtime_error(
        std::string(op) +
        ": CryptoParameters are not CryptoParametersRNS; "
        "only RNS-based schemes (BFV/BGV/CKKS) are supported");
  }
  return rns;
}

[[cpp11::register]]
int64_t CryptoContext__GetPlaintextModulus(SEXP cc_xp) {
  external_pointer<CryptoContext<DCRTPoly>> cc(cc_xp);
  return catch_openfhe("CryptoContext::GetPlaintextModulus", [&]() -> int64_t {
    return static_cast<int64_t>(
        (*cc)->GetCryptoParameters()->GetPlaintextModulus());
  });
}

[[cpp11::register]]
int CryptoContext__GetBatchSize(SEXP cc_xp) {
  external_pointer<CryptoContext<DCRTPoly>> cc(cc_xp);
  return catch_openfhe("CryptoContext::GetBatchSize", [&]() -> int {
    return static_cast<int>(
        (*cc)->GetCryptoParameters()->GetEncodingParams()->GetBatchSize());
  });
}

[[cpp11::register]]
int CryptoContext__GetScalingTechnique(SEXP cc_xp) {
  external_pointer<CryptoContext<DCRTPoly>> cc(cc_xp);
  return catch_openfhe("CryptoContext::GetScalingTechnique", [&]() -> int {
    auto rns = as_rns_params((*cc)->GetCryptoParameters(),
                             "CryptoContext::GetScalingTechnique");
    return static_cast<int>(rns->GetScalingTechnique());
  });
}

[[cpp11::register]]
int CryptoContext__GetDigitSize(SEXP cc_xp) {
  external_pointer<CryptoContext<DCRTPoly>> cc(cc_xp);
  return catch_openfhe("CryptoContext::GetDigitSize", [&]() -> int {
    return static_cast<int>(
        (*cc)->GetCryptoParameters()->GetDigitSize());
  });
}

[[cpp11::register]]
double CryptoContext__GetNoiseEstimate(SEXP cc_xp) {
  external_pointer<CryptoContext<DCRTPoly>> cc(cc_xp);
  return catch_openfhe("CryptoContext::GetNoiseEstimate", [&]() -> double {
    auto rns = as_rns_params((*cc)->GetCryptoParameters(),
                             "CryptoContext::GetNoiseEstimate");
    return rns->GetNoiseEstimate();
  });
}

[[cpp11::register]]
int CryptoContext__GetMultiplicativeDepth(SEXP cc_xp) {
  external_pointer<CryptoContext<DCRTPoly>> cc(cc_xp);
  return catch_openfhe("CryptoContext::GetMultiplicativeDepth", [&]() -> int {
    auto rns = as_rns_params((*cc)->GetCryptoParameters(),
                             "CryptoContext::GetMultiplicativeDepth");
    return static_cast<int>(rns->GetMultiplicativeDepth());
  });
}

[[cpp11::register]]
int CryptoContext__GetEvalAddCount(SEXP cc_xp) {
  external_pointer<CryptoContext<DCRTPoly>> cc(cc_xp);
  return catch_openfhe("CryptoContext::GetEvalAddCount", [&]() -> int {
    auto rns = as_rns_params((*cc)->GetCryptoParameters(),
                             "CryptoContext::GetEvalAddCount");
    return static_cast<int>(rns->GetEvalAddCount());
  });
}

[[cpp11::register]]
int CryptoContext__GetKeySwitchCount(SEXP cc_xp) {
  external_pointer<CryptoContext<DCRTPoly>> cc(cc_xp);
  return catch_openfhe("CryptoContext::GetKeySwitchCount", [&]() -> int {
    auto rns = as_rns_params((*cc)->GetCryptoParameters(),
                             "CryptoContext::GetKeySwitchCount");
    return static_cast<int>(rns->GetKeySwitchCount());
  });
}

[[cpp11::register]]
int CryptoContext__GetPRENumHops(SEXP cc_xp) {
  external_pointer<CryptoContext<DCRTPoly>> cc(cc_xp);
  return catch_openfhe("CryptoContext::GetPRENumHops", [&]() -> int {
    auto rns = as_rns_params((*cc)->GetCryptoParameters(),
                             "CryptoContext::GetPRENumHops");
    return static_cast<int>(rns->GetPRENumHops());
  });
}

[[cpp11::register]]
int CryptoContext__GetRegisterWordSize(SEXP cc_xp) {
  external_pointer<CryptoContext<DCRTPoly>> cc(cc_xp);
  return catch_openfhe("CryptoContext::GetRegisterWordSize", [&]() -> int {
    auto rns = as_rns_params((*cc)->GetCryptoParameters(),
                             "CryptoContext::GetRegisterWordSize");
    return static_cast<int>(rns->GetRegisterWordSize());
  });
}

[[cpp11::register]]
int CryptoContext__GetCompositeDegree(SEXP cc_xp) {
  external_pointer<CryptoContext<DCRTPoly>> cc(cc_xp);
  return catch_openfhe("CryptoContext::GetCompositeDegree", [&]() -> int {
    auto rns = as_rns_params((*cc)->GetCryptoParameters(),
                             "CryptoContext::GetCompositeDegree");
    return static_cast<int>(rns->GetCompositeDegree());
  });
}

[[cpp11::register]]
int CryptoContext__GetKeySwitchTechnique(SEXP cc_xp) {
  external_pointer<CryptoContext<DCRTPoly>> cc(cc_xp);
  return catch_openfhe("CryptoContext::GetKeySwitchTechnique", [&]() -> int {
    auto rns = as_rns_params((*cc)->GetCryptoParameters(),
                             "CryptoContext::GetKeySwitchTechnique");
    return static_cast<int>(rns->GetKeySwitchTechnique());
  });
}
