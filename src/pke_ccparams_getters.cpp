// OPENFHE PYTHON SOURCE: src/lib/bindings.cpp (bind_parameters)
//
// CCParams getter surface for BFV/BGV/CKKS.
//
// Per discovery D013 the derived-class CCParams<T> specialisations
// override setters (not getters) with DISABLED_FOR_XXX throwing
// bodies. Verified by grepping the three
// gen-cryptocontext-{bfvrns,bgvrns,ckksrns}-params.h files shows
// DISABLED_FOR_XXX appears only under setter overrides; no Get*
// method is overridden to throw. Getters therefore bind uniformly
// for all three schemes: 33 getters x 3 schemes = 99 new bindings
// (pke_bindings.cpp had zero existing CCParams getter bindings).
//
// Semantic note on two getters whose upstream types disagree with
// their matching setters:
//   - GetStatisticalSecurity() returns double but
//     SetStatisticalSecurity() takes uint32_t
//   - GetNumAdversarialQueries() returns double but
//     SetNumAdversarialQueries() takes uint32_t
// The underlying field must actually be double (the getter's
// `return` statement has to compile). This is a genuine upstream
// header inconsistency; R binds the getter as double per the
// header.
//
// Semantic note on getters whose matching setter is disabled
// upstream: the getter returns the default value of the underlying
// field (typically 0 for uint32_t, 0.0 for double, the enum's
// zero sentinel for enum fields). Calling e.g.
// CKKSParams__GetPlaintextModulus() on a CKKS params object
// returns 0, not a throw — matching the gap-matrix §24a expectation.
//
// Every binding wraps its C++ call site in catch_openfhe from
// openfhe_helpers.h per design.md §5.
#include "openfhe_cpp11.h"
#include "openfhe_helpers.h"

using namespace cpp11;

// ── BFV Parameter getters ─────────────────

[[cpp11::register]]
int BFVParams__GetScheme(SEXP params_xp) {
  external_pointer<CCParams<CryptoContextBFVRNS>> p(params_xp);
  return catch_openfhe("BFVParams::GetScheme", [&]() -> int {
    return static_cast<int>(p->GetScheme());
  });
}

[[cpp11::register]]
int64_t BFVParams__GetPlaintextModulus(SEXP params_xp) {
  external_pointer<CCParams<CryptoContextBFVRNS>> p(params_xp);
  return catch_openfhe("BFVParams::GetPlaintextModulus", [&]() -> int64_t {
    return static_cast<int64_t>(p->GetPlaintextModulus());
  });
}

[[cpp11::register]]
int BFVParams__GetDigitSize(SEXP params_xp) {
  external_pointer<CCParams<CryptoContextBFVRNS>> p(params_xp);
  return catch_openfhe("BFVParams::GetDigitSize", [&]() -> int {
    return static_cast<int>(p->GetDigitSize());
  });
}

[[cpp11::register]]
double BFVParams__GetStandardDeviation(SEXP params_xp) {
  external_pointer<CCParams<CryptoContextBFVRNS>> p(params_xp);
  return catch_openfhe("BFVParams::GetStandardDeviation", [&]() -> double {
    return static_cast<double>(p->GetStandardDeviation());
  });
}

[[cpp11::register]]
int BFVParams__GetSecretKeyDist(SEXP params_xp) {
  external_pointer<CCParams<CryptoContextBFVRNS>> p(params_xp);
  return catch_openfhe("BFVParams::GetSecretKeyDist", [&]() -> int {
    return static_cast<int>(p->GetSecretKeyDist());
  });
}

[[cpp11::register]]
int BFVParams__GetMaxRelinSkDeg(SEXP params_xp) {
  external_pointer<CCParams<CryptoContextBFVRNS>> p(params_xp);
  return catch_openfhe("BFVParams::GetMaxRelinSkDeg", [&]() -> int {
    return static_cast<int>(p->GetMaxRelinSkDeg());
  });
}

[[cpp11::register]]
int BFVParams__GetPREMode(SEXP params_xp) {
  external_pointer<CCParams<CryptoContextBFVRNS>> p(params_xp);
  return catch_openfhe("BFVParams::GetPREMode", [&]() -> int {
    return static_cast<int>(p->GetPREMode());
  });
}

[[cpp11::register]]
int BFVParams__GetMultipartyMode(SEXP params_xp) {
  external_pointer<CCParams<CryptoContextBFVRNS>> p(params_xp);
  return catch_openfhe("BFVParams::GetMultipartyMode", [&]() -> int {
    return static_cast<int>(p->GetMultipartyMode());
  });
}

[[cpp11::register]]
int BFVParams__GetExecutionMode(SEXP params_xp) {
  external_pointer<CCParams<CryptoContextBFVRNS>> p(params_xp);
  return catch_openfhe("BFVParams::GetExecutionMode", [&]() -> int {
    return static_cast<int>(p->GetExecutionMode());
  });
}

[[cpp11::register]]
int BFVParams__GetDecryptionNoiseMode(SEXP params_xp) {
  external_pointer<CCParams<CryptoContextBFVRNS>> p(params_xp);
  return catch_openfhe("BFVParams::GetDecryptionNoiseMode", [&]() -> int {
    return static_cast<int>(p->GetDecryptionNoiseMode());
  });
}

[[cpp11::register]]
double BFVParams__GetNoiseEstimate(SEXP params_xp) {
  external_pointer<CCParams<CryptoContextBFVRNS>> p(params_xp);
  return catch_openfhe("BFVParams::GetNoiseEstimate", [&]() -> double {
    return p->GetNoiseEstimate();
  });
}

[[cpp11::register]]
double BFVParams__GetDesiredPrecision(SEXP params_xp) {
  external_pointer<CCParams<CryptoContextBFVRNS>> p(params_xp);
  return catch_openfhe("BFVParams::GetDesiredPrecision", [&]() -> double {
    return p->GetDesiredPrecision();
  });
}

[[cpp11::register]]
double BFVParams__GetStatisticalSecurity(SEXP params_xp) {
  external_pointer<CCParams<CryptoContextBFVRNS>> p(params_xp);
  return catch_openfhe("BFVParams::GetStatisticalSecurity", [&]() -> double {
    return p->GetStatisticalSecurity();
  });
}

[[cpp11::register]]
double BFVParams__GetNumAdversarialQueries(SEXP params_xp) {
  external_pointer<CCParams<CryptoContextBFVRNS>> p(params_xp);
  return catch_openfhe("BFVParams::GetNumAdversarialQueries", [&]() -> double {
    return p->GetNumAdversarialQueries();
  });
}

[[cpp11::register]]
int BFVParams__GetThresholdNumOfParties(SEXP params_xp) {
  external_pointer<CCParams<CryptoContextBFVRNS>> p(params_xp);
  return catch_openfhe("BFVParams::GetThresholdNumOfParties", [&]() -> int {
    return static_cast<int>(p->GetThresholdNumOfParties());
  });
}

[[cpp11::register]]
int BFVParams__GetKeySwitchTechnique(SEXP params_xp) {
  external_pointer<CCParams<CryptoContextBFVRNS>> p(params_xp);
  return catch_openfhe("BFVParams::GetKeySwitchTechnique", [&]() -> int {
    return static_cast<int>(p->GetKeySwitchTechnique());
  });
}

[[cpp11::register]]
int BFVParams__GetScalingTechnique(SEXP params_xp) {
  external_pointer<CCParams<CryptoContextBFVRNS>> p(params_xp);
  return catch_openfhe("BFVParams::GetScalingTechnique", [&]() -> int {
    return static_cast<int>(p->GetScalingTechnique());
  });
}

[[cpp11::register]]
int BFVParams__GetBatchSize(SEXP params_xp) {
  external_pointer<CCParams<CryptoContextBFVRNS>> p(params_xp);
  return catch_openfhe("BFVParams::GetBatchSize", [&]() -> int {
    return static_cast<int>(p->GetBatchSize());
  });
}

[[cpp11::register]]
int BFVParams__GetFirstModSize(SEXP params_xp) {
  external_pointer<CCParams<CryptoContextBFVRNS>> p(params_xp);
  return catch_openfhe("BFVParams::GetFirstModSize", [&]() -> int {
    return static_cast<int>(p->GetFirstModSize());
  });
}

[[cpp11::register]]
int BFVParams__GetNumLargeDigits(SEXP params_xp) {
  external_pointer<CCParams<CryptoContextBFVRNS>> p(params_xp);
  return catch_openfhe("BFVParams::GetNumLargeDigits", [&]() -> int {
    return static_cast<int>(p->GetNumLargeDigits());
  });
}

[[cpp11::register]]
int BFVParams__GetMultiplicativeDepth(SEXP params_xp) {
  external_pointer<CCParams<CryptoContextBFVRNS>> p(params_xp);
  return catch_openfhe("BFVParams::GetMultiplicativeDepth", [&]() -> int {
    return static_cast<int>(p->GetMultiplicativeDepth());
  });
}

[[cpp11::register]]
int BFVParams__GetScalingModSize(SEXP params_xp) {
  external_pointer<CCParams<CryptoContextBFVRNS>> p(params_xp);
  return catch_openfhe("BFVParams::GetScalingModSize", [&]() -> int {
    return static_cast<int>(p->GetScalingModSize());
  });
}

[[cpp11::register]]
int BFVParams__GetSecurityLevel(SEXP params_xp) {
  external_pointer<CCParams<CryptoContextBFVRNS>> p(params_xp);
  return catch_openfhe("BFVParams::GetSecurityLevel", [&]() -> int {
    return static_cast<int>(p->GetSecurityLevel());
  });
}

[[cpp11::register]]
int BFVParams__GetRingDim(SEXP params_xp) {
  external_pointer<CCParams<CryptoContextBFVRNS>> p(params_xp);
  return catch_openfhe("BFVParams::GetRingDim", [&]() -> int {
    return static_cast<int>(p->GetRingDim());
  });
}

[[cpp11::register]]
int BFVParams__GetEvalAddCount(SEXP params_xp) {
  external_pointer<CCParams<CryptoContextBFVRNS>> p(params_xp);
  return catch_openfhe("BFVParams::GetEvalAddCount", [&]() -> int {
    return static_cast<int>(p->GetEvalAddCount());
  });
}

[[cpp11::register]]
int BFVParams__GetKeySwitchCount(SEXP params_xp) {
  external_pointer<CCParams<CryptoContextBFVRNS>> p(params_xp);
  return catch_openfhe("BFVParams::GetKeySwitchCount", [&]() -> int {
    return static_cast<int>(p->GetKeySwitchCount());
  });
}

[[cpp11::register]]
int BFVParams__GetEncryptionTechnique(SEXP params_xp) {
  external_pointer<CCParams<CryptoContextBFVRNS>> p(params_xp);
  return catch_openfhe("BFVParams::GetEncryptionTechnique", [&]() -> int {
    return static_cast<int>(p->GetEncryptionTechnique());
  });
}

[[cpp11::register]]
int BFVParams__GetMultiplicationTechnique(SEXP params_xp) {
  external_pointer<CCParams<CryptoContextBFVRNS>> p(params_xp);
  return catch_openfhe("BFVParams::GetMultiplicationTechnique", [&]() -> int {
    return static_cast<int>(p->GetMultiplicationTechnique());
  });
}

[[cpp11::register]]
int BFVParams__GetPRENumHops(SEXP params_xp) {
  external_pointer<CCParams<CryptoContextBFVRNS>> p(params_xp);
  return catch_openfhe("BFVParams::GetPRENumHops", [&]() -> int {
    return static_cast<int>(p->GetPRENumHops());
  });
}

[[cpp11::register]]
int BFVParams__GetInteractiveBootCompressionLevel(SEXP params_xp) {
  external_pointer<CCParams<CryptoContextBFVRNS>> p(params_xp);
  return catch_openfhe("BFVParams::GetInteractiveBootCompressionLevel", [&]() -> int {
    return static_cast<int>(p->GetInteractiveBootCompressionLevel());
  });
}

[[cpp11::register]]
int BFVParams__GetCompositeDegree(SEXP params_xp) {
  external_pointer<CCParams<CryptoContextBFVRNS>> p(params_xp);
  return catch_openfhe("BFVParams::GetCompositeDegree", [&]() -> int {
    return static_cast<int>(p->GetCompositeDegree());
  });
}

[[cpp11::register]]
int BFVParams__GetRegisterWordSize(SEXP params_xp) {
  external_pointer<CCParams<CryptoContextBFVRNS>> p(params_xp);
  return catch_openfhe("BFVParams::GetRegisterWordSize", [&]() -> int {
    return static_cast<int>(p->GetRegisterWordSize());
  });
}

[[cpp11::register]]
int BFVParams__GetCKKSDataType(SEXP params_xp) {
  external_pointer<CCParams<CryptoContextBFVRNS>> p(params_xp);
  return catch_openfhe("BFVParams::GetCKKSDataType", [&]() -> int {
    return static_cast<int>(p->GetCKKSDataType());
  });
}

// ── BGV Parameter getters ─────────────────

[[cpp11::register]]
int BGVParams__GetScheme(SEXP params_xp) {
  external_pointer<CCParams<CryptoContextBGVRNS>> p(params_xp);
  return catch_openfhe("BGVParams::GetScheme", [&]() -> int {
    return static_cast<int>(p->GetScheme());
  });
}

[[cpp11::register]]
int64_t BGVParams__GetPlaintextModulus(SEXP params_xp) {
  external_pointer<CCParams<CryptoContextBGVRNS>> p(params_xp);
  return catch_openfhe("BGVParams::GetPlaintextModulus", [&]() -> int64_t {
    return static_cast<int64_t>(p->GetPlaintextModulus());
  });
}

[[cpp11::register]]
int BGVParams__GetDigitSize(SEXP params_xp) {
  external_pointer<CCParams<CryptoContextBGVRNS>> p(params_xp);
  return catch_openfhe("BGVParams::GetDigitSize", [&]() -> int {
    return static_cast<int>(p->GetDigitSize());
  });
}

[[cpp11::register]]
double BGVParams__GetStandardDeviation(SEXP params_xp) {
  external_pointer<CCParams<CryptoContextBGVRNS>> p(params_xp);
  return catch_openfhe("BGVParams::GetStandardDeviation", [&]() -> double {
    return static_cast<double>(p->GetStandardDeviation());
  });
}

[[cpp11::register]]
int BGVParams__GetSecretKeyDist(SEXP params_xp) {
  external_pointer<CCParams<CryptoContextBGVRNS>> p(params_xp);
  return catch_openfhe("BGVParams::GetSecretKeyDist", [&]() -> int {
    return static_cast<int>(p->GetSecretKeyDist());
  });
}

[[cpp11::register]]
int BGVParams__GetMaxRelinSkDeg(SEXP params_xp) {
  external_pointer<CCParams<CryptoContextBGVRNS>> p(params_xp);
  return catch_openfhe("BGVParams::GetMaxRelinSkDeg", [&]() -> int {
    return static_cast<int>(p->GetMaxRelinSkDeg());
  });
}

[[cpp11::register]]
int BGVParams__GetPREMode(SEXP params_xp) {
  external_pointer<CCParams<CryptoContextBGVRNS>> p(params_xp);
  return catch_openfhe("BGVParams::GetPREMode", [&]() -> int {
    return static_cast<int>(p->GetPREMode());
  });
}

[[cpp11::register]]
int BGVParams__GetMultipartyMode(SEXP params_xp) {
  external_pointer<CCParams<CryptoContextBGVRNS>> p(params_xp);
  return catch_openfhe("BGVParams::GetMultipartyMode", [&]() -> int {
    return static_cast<int>(p->GetMultipartyMode());
  });
}

[[cpp11::register]]
int BGVParams__GetExecutionMode(SEXP params_xp) {
  external_pointer<CCParams<CryptoContextBGVRNS>> p(params_xp);
  return catch_openfhe("BGVParams::GetExecutionMode", [&]() -> int {
    return static_cast<int>(p->GetExecutionMode());
  });
}

[[cpp11::register]]
int BGVParams__GetDecryptionNoiseMode(SEXP params_xp) {
  external_pointer<CCParams<CryptoContextBGVRNS>> p(params_xp);
  return catch_openfhe("BGVParams::GetDecryptionNoiseMode", [&]() -> int {
    return static_cast<int>(p->GetDecryptionNoiseMode());
  });
}

[[cpp11::register]]
double BGVParams__GetNoiseEstimate(SEXP params_xp) {
  external_pointer<CCParams<CryptoContextBGVRNS>> p(params_xp);
  return catch_openfhe("BGVParams::GetNoiseEstimate", [&]() -> double {
    return p->GetNoiseEstimate();
  });
}

[[cpp11::register]]
double BGVParams__GetDesiredPrecision(SEXP params_xp) {
  external_pointer<CCParams<CryptoContextBGVRNS>> p(params_xp);
  return catch_openfhe("BGVParams::GetDesiredPrecision", [&]() -> double {
    return p->GetDesiredPrecision();
  });
}

[[cpp11::register]]
double BGVParams__GetStatisticalSecurity(SEXP params_xp) {
  external_pointer<CCParams<CryptoContextBGVRNS>> p(params_xp);
  return catch_openfhe("BGVParams::GetStatisticalSecurity", [&]() -> double {
    return p->GetStatisticalSecurity();
  });
}

[[cpp11::register]]
double BGVParams__GetNumAdversarialQueries(SEXP params_xp) {
  external_pointer<CCParams<CryptoContextBGVRNS>> p(params_xp);
  return catch_openfhe("BGVParams::GetNumAdversarialQueries", [&]() -> double {
    return p->GetNumAdversarialQueries();
  });
}

[[cpp11::register]]
int BGVParams__GetThresholdNumOfParties(SEXP params_xp) {
  external_pointer<CCParams<CryptoContextBGVRNS>> p(params_xp);
  return catch_openfhe("BGVParams::GetThresholdNumOfParties", [&]() -> int {
    return static_cast<int>(p->GetThresholdNumOfParties());
  });
}

[[cpp11::register]]
int BGVParams__GetKeySwitchTechnique(SEXP params_xp) {
  external_pointer<CCParams<CryptoContextBGVRNS>> p(params_xp);
  return catch_openfhe("BGVParams::GetKeySwitchTechnique", [&]() -> int {
    return static_cast<int>(p->GetKeySwitchTechnique());
  });
}

[[cpp11::register]]
int BGVParams__GetScalingTechnique(SEXP params_xp) {
  external_pointer<CCParams<CryptoContextBGVRNS>> p(params_xp);
  return catch_openfhe("BGVParams::GetScalingTechnique", [&]() -> int {
    return static_cast<int>(p->GetScalingTechnique());
  });
}

[[cpp11::register]]
int BGVParams__GetBatchSize(SEXP params_xp) {
  external_pointer<CCParams<CryptoContextBGVRNS>> p(params_xp);
  return catch_openfhe("BGVParams::GetBatchSize", [&]() -> int {
    return static_cast<int>(p->GetBatchSize());
  });
}

[[cpp11::register]]
int BGVParams__GetFirstModSize(SEXP params_xp) {
  external_pointer<CCParams<CryptoContextBGVRNS>> p(params_xp);
  return catch_openfhe("BGVParams::GetFirstModSize", [&]() -> int {
    return static_cast<int>(p->GetFirstModSize());
  });
}

[[cpp11::register]]
int BGVParams__GetNumLargeDigits(SEXP params_xp) {
  external_pointer<CCParams<CryptoContextBGVRNS>> p(params_xp);
  return catch_openfhe("BGVParams::GetNumLargeDigits", [&]() -> int {
    return static_cast<int>(p->GetNumLargeDigits());
  });
}

[[cpp11::register]]
int BGVParams__GetMultiplicativeDepth(SEXP params_xp) {
  external_pointer<CCParams<CryptoContextBGVRNS>> p(params_xp);
  return catch_openfhe("BGVParams::GetMultiplicativeDepth", [&]() -> int {
    return static_cast<int>(p->GetMultiplicativeDepth());
  });
}

[[cpp11::register]]
int BGVParams__GetScalingModSize(SEXP params_xp) {
  external_pointer<CCParams<CryptoContextBGVRNS>> p(params_xp);
  return catch_openfhe("BGVParams::GetScalingModSize", [&]() -> int {
    return static_cast<int>(p->GetScalingModSize());
  });
}

[[cpp11::register]]
int BGVParams__GetSecurityLevel(SEXP params_xp) {
  external_pointer<CCParams<CryptoContextBGVRNS>> p(params_xp);
  return catch_openfhe("BGVParams::GetSecurityLevel", [&]() -> int {
    return static_cast<int>(p->GetSecurityLevel());
  });
}

[[cpp11::register]]
int BGVParams__GetRingDim(SEXP params_xp) {
  external_pointer<CCParams<CryptoContextBGVRNS>> p(params_xp);
  return catch_openfhe("BGVParams::GetRingDim", [&]() -> int {
    return static_cast<int>(p->GetRingDim());
  });
}

[[cpp11::register]]
int BGVParams__GetEvalAddCount(SEXP params_xp) {
  external_pointer<CCParams<CryptoContextBGVRNS>> p(params_xp);
  return catch_openfhe("BGVParams::GetEvalAddCount", [&]() -> int {
    return static_cast<int>(p->GetEvalAddCount());
  });
}

[[cpp11::register]]
int BGVParams__GetKeySwitchCount(SEXP params_xp) {
  external_pointer<CCParams<CryptoContextBGVRNS>> p(params_xp);
  return catch_openfhe("BGVParams::GetKeySwitchCount", [&]() -> int {
    return static_cast<int>(p->GetKeySwitchCount());
  });
}

[[cpp11::register]]
int BGVParams__GetEncryptionTechnique(SEXP params_xp) {
  external_pointer<CCParams<CryptoContextBGVRNS>> p(params_xp);
  return catch_openfhe("BGVParams::GetEncryptionTechnique", [&]() -> int {
    return static_cast<int>(p->GetEncryptionTechnique());
  });
}

[[cpp11::register]]
int BGVParams__GetMultiplicationTechnique(SEXP params_xp) {
  external_pointer<CCParams<CryptoContextBGVRNS>> p(params_xp);
  return catch_openfhe("BGVParams::GetMultiplicationTechnique", [&]() -> int {
    return static_cast<int>(p->GetMultiplicationTechnique());
  });
}

[[cpp11::register]]
int BGVParams__GetPRENumHops(SEXP params_xp) {
  external_pointer<CCParams<CryptoContextBGVRNS>> p(params_xp);
  return catch_openfhe("BGVParams::GetPRENumHops", [&]() -> int {
    return static_cast<int>(p->GetPRENumHops());
  });
}

[[cpp11::register]]
int BGVParams__GetInteractiveBootCompressionLevel(SEXP params_xp) {
  external_pointer<CCParams<CryptoContextBGVRNS>> p(params_xp);
  return catch_openfhe("BGVParams::GetInteractiveBootCompressionLevel", [&]() -> int {
    return static_cast<int>(p->GetInteractiveBootCompressionLevel());
  });
}

[[cpp11::register]]
int BGVParams__GetCompositeDegree(SEXP params_xp) {
  external_pointer<CCParams<CryptoContextBGVRNS>> p(params_xp);
  return catch_openfhe("BGVParams::GetCompositeDegree", [&]() -> int {
    return static_cast<int>(p->GetCompositeDegree());
  });
}

[[cpp11::register]]
int BGVParams__GetRegisterWordSize(SEXP params_xp) {
  external_pointer<CCParams<CryptoContextBGVRNS>> p(params_xp);
  return catch_openfhe("BGVParams::GetRegisterWordSize", [&]() -> int {
    return static_cast<int>(p->GetRegisterWordSize());
  });
}

[[cpp11::register]]
int BGVParams__GetCKKSDataType(SEXP params_xp) {
  external_pointer<CCParams<CryptoContextBGVRNS>> p(params_xp);
  return catch_openfhe("BGVParams::GetCKKSDataType", [&]() -> int {
    return static_cast<int>(p->GetCKKSDataType());
  });
}

// ── CKKS Parameter getters ────────────────

[[cpp11::register]]
int CKKSParams__GetScheme(SEXP params_xp) {
  external_pointer<CCParams<CryptoContextCKKSRNS>> p(params_xp);
  return catch_openfhe("CKKSParams::GetScheme", [&]() -> int {
    return static_cast<int>(p->GetScheme());
  });
}

[[cpp11::register]]
int64_t CKKSParams__GetPlaintextModulus(SEXP params_xp) {
  external_pointer<CCParams<CryptoContextCKKSRNS>> p(params_xp);
  return catch_openfhe("CKKSParams::GetPlaintextModulus", [&]() -> int64_t {
    return static_cast<int64_t>(p->GetPlaintextModulus());
  });
}

[[cpp11::register]]
int CKKSParams__GetDigitSize(SEXP params_xp) {
  external_pointer<CCParams<CryptoContextCKKSRNS>> p(params_xp);
  return catch_openfhe("CKKSParams::GetDigitSize", [&]() -> int {
    return static_cast<int>(p->GetDigitSize());
  });
}

[[cpp11::register]]
double CKKSParams__GetStandardDeviation(SEXP params_xp) {
  external_pointer<CCParams<CryptoContextCKKSRNS>> p(params_xp);
  return catch_openfhe("CKKSParams::GetStandardDeviation", [&]() -> double {
    return static_cast<double>(p->GetStandardDeviation());
  });
}

[[cpp11::register]]
int CKKSParams__GetSecretKeyDist(SEXP params_xp) {
  external_pointer<CCParams<CryptoContextCKKSRNS>> p(params_xp);
  return catch_openfhe("CKKSParams::GetSecretKeyDist", [&]() -> int {
    return static_cast<int>(p->GetSecretKeyDist());
  });
}

[[cpp11::register]]
int CKKSParams__GetMaxRelinSkDeg(SEXP params_xp) {
  external_pointer<CCParams<CryptoContextCKKSRNS>> p(params_xp);
  return catch_openfhe("CKKSParams::GetMaxRelinSkDeg", [&]() -> int {
    return static_cast<int>(p->GetMaxRelinSkDeg());
  });
}

[[cpp11::register]]
int CKKSParams__GetPREMode(SEXP params_xp) {
  external_pointer<CCParams<CryptoContextCKKSRNS>> p(params_xp);
  return catch_openfhe("CKKSParams::GetPREMode", [&]() -> int {
    return static_cast<int>(p->GetPREMode());
  });
}

[[cpp11::register]]
int CKKSParams__GetMultipartyMode(SEXP params_xp) {
  external_pointer<CCParams<CryptoContextCKKSRNS>> p(params_xp);
  return catch_openfhe("CKKSParams::GetMultipartyMode", [&]() -> int {
    return static_cast<int>(p->GetMultipartyMode());
  });
}

[[cpp11::register]]
int CKKSParams__GetExecutionMode(SEXP params_xp) {
  external_pointer<CCParams<CryptoContextCKKSRNS>> p(params_xp);
  return catch_openfhe("CKKSParams::GetExecutionMode", [&]() -> int {
    return static_cast<int>(p->GetExecutionMode());
  });
}

[[cpp11::register]]
int CKKSParams__GetDecryptionNoiseMode(SEXP params_xp) {
  external_pointer<CCParams<CryptoContextCKKSRNS>> p(params_xp);
  return catch_openfhe("CKKSParams::GetDecryptionNoiseMode", [&]() -> int {
    return static_cast<int>(p->GetDecryptionNoiseMode());
  });
}

[[cpp11::register]]
double CKKSParams__GetNoiseEstimate(SEXP params_xp) {
  external_pointer<CCParams<CryptoContextCKKSRNS>> p(params_xp);
  return catch_openfhe("CKKSParams::GetNoiseEstimate", [&]() -> double {
    return p->GetNoiseEstimate();
  });
}

[[cpp11::register]]
double CKKSParams__GetDesiredPrecision(SEXP params_xp) {
  external_pointer<CCParams<CryptoContextCKKSRNS>> p(params_xp);
  return catch_openfhe("CKKSParams::GetDesiredPrecision", [&]() -> double {
    return p->GetDesiredPrecision();
  });
}

[[cpp11::register]]
double CKKSParams__GetStatisticalSecurity(SEXP params_xp) {
  external_pointer<CCParams<CryptoContextCKKSRNS>> p(params_xp);
  return catch_openfhe("CKKSParams::GetStatisticalSecurity", [&]() -> double {
    return p->GetStatisticalSecurity();
  });
}

[[cpp11::register]]
double CKKSParams__GetNumAdversarialQueries(SEXP params_xp) {
  external_pointer<CCParams<CryptoContextCKKSRNS>> p(params_xp);
  return catch_openfhe("CKKSParams::GetNumAdversarialQueries", [&]() -> double {
    return p->GetNumAdversarialQueries();
  });
}

[[cpp11::register]]
int CKKSParams__GetThresholdNumOfParties(SEXP params_xp) {
  external_pointer<CCParams<CryptoContextCKKSRNS>> p(params_xp);
  return catch_openfhe("CKKSParams::GetThresholdNumOfParties", [&]() -> int {
    return static_cast<int>(p->GetThresholdNumOfParties());
  });
}

[[cpp11::register]]
int CKKSParams__GetKeySwitchTechnique(SEXP params_xp) {
  external_pointer<CCParams<CryptoContextCKKSRNS>> p(params_xp);
  return catch_openfhe("CKKSParams::GetKeySwitchTechnique", [&]() -> int {
    return static_cast<int>(p->GetKeySwitchTechnique());
  });
}

[[cpp11::register]]
int CKKSParams__GetScalingTechnique(SEXP params_xp) {
  external_pointer<CCParams<CryptoContextCKKSRNS>> p(params_xp);
  return catch_openfhe("CKKSParams::GetScalingTechnique", [&]() -> int {
    return static_cast<int>(p->GetScalingTechnique());
  });
}

[[cpp11::register]]
int CKKSParams__GetBatchSize(SEXP params_xp) {
  external_pointer<CCParams<CryptoContextCKKSRNS>> p(params_xp);
  return catch_openfhe("CKKSParams::GetBatchSize", [&]() -> int {
    return static_cast<int>(p->GetBatchSize());
  });
}

[[cpp11::register]]
int CKKSParams__GetFirstModSize(SEXP params_xp) {
  external_pointer<CCParams<CryptoContextCKKSRNS>> p(params_xp);
  return catch_openfhe("CKKSParams::GetFirstModSize", [&]() -> int {
    return static_cast<int>(p->GetFirstModSize());
  });
}

[[cpp11::register]]
int CKKSParams__GetNumLargeDigits(SEXP params_xp) {
  external_pointer<CCParams<CryptoContextCKKSRNS>> p(params_xp);
  return catch_openfhe("CKKSParams::GetNumLargeDigits", [&]() -> int {
    return static_cast<int>(p->GetNumLargeDigits());
  });
}

[[cpp11::register]]
int CKKSParams__GetMultiplicativeDepth(SEXP params_xp) {
  external_pointer<CCParams<CryptoContextCKKSRNS>> p(params_xp);
  return catch_openfhe("CKKSParams::GetMultiplicativeDepth", [&]() -> int {
    return static_cast<int>(p->GetMultiplicativeDepth());
  });
}

[[cpp11::register]]
int CKKSParams__GetScalingModSize(SEXP params_xp) {
  external_pointer<CCParams<CryptoContextCKKSRNS>> p(params_xp);
  return catch_openfhe("CKKSParams::GetScalingModSize", [&]() -> int {
    return static_cast<int>(p->GetScalingModSize());
  });
}

[[cpp11::register]]
int CKKSParams__GetSecurityLevel(SEXP params_xp) {
  external_pointer<CCParams<CryptoContextCKKSRNS>> p(params_xp);
  return catch_openfhe("CKKSParams::GetSecurityLevel", [&]() -> int {
    return static_cast<int>(p->GetSecurityLevel());
  });
}

[[cpp11::register]]
int CKKSParams__GetRingDim(SEXP params_xp) {
  external_pointer<CCParams<CryptoContextCKKSRNS>> p(params_xp);
  return catch_openfhe("CKKSParams::GetRingDim", [&]() -> int {
    return static_cast<int>(p->GetRingDim());
  });
}

[[cpp11::register]]
int CKKSParams__GetEvalAddCount(SEXP params_xp) {
  external_pointer<CCParams<CryptoContextCKKSRNS>> p(params_xp);
  return catch_openfhe("CKKSParams::GetEvalAddCount", [&]() -> int {
    return static_cast<int>(p->GetEvalAddCount());
  });
}

[[cpp11::register]]
int CKKSParams__GetKeySwitchCount(SEXP params_xp) {
  external_pointer<CCParams<CryptoContextCKKSRNS>> p(params_xp);
  return catch_openfhe("CKKSParams::GetKeySwitchCount", [&]() -> int {
    return static_cast<int>(p->GetKeySwitchCount());
  });
}

[[cpp11::register]]
int CKKSParams__GetEncryptionTechnique(SEXP params_xp) {
  external_pointer<CCParams<CryptoContextCKKSRNS>> p(params_xp);
  return catch_openfhe("CKKSParams::GetEncryptionTechnique", [&]() -> int {
    return static_cast<int>(p->GetEncryptionTechnique());
  });
}

[[cpp11::register]]
int CKKSParams__GetMultiplicationTechnique(SEXP params_xp) {
  external_pointer<CCParams<CryptoContextCKKSRNS>> p(params_xp);
  return catch_openfhe("CKKSParams::GetMultiplicationTechnique", [&]() -> int {
    return static_cast<int>(p->GetMultiplicationTechnique());
  });
}

[[cpp11::register]]
int CKKSParams__GetPRENumHops(SEXP params_xp) {
  external_pointer<CCParams<CryptoContextCKKSRNS>> p(params_xp);
  return catch_openfhe("CKKSParams::GetPRENumHops", [&]() -> int {
    return static_cast<int>(p->GetPRENumHops());
  });
}

[[cpp11::register]]
int CKKSParams__GetInteractiveBootCompressionLevel(SEXP params_xp) {
  external_pointer<CCParams<CryptoContextCKKSRNS>> p(params_xp);
  return catch_openfhe("CKKSParams::GetInteractiveBootCompressionLevel", [&]() -> int {
    return static_cast<int>(p->GetInteractiveBootCompressionLevel());
  });
}

[[cpp11::register]]
int CKKSParams__GetCompositeDegree(SEXP params_xp) {
  external_pointer<CCParams<CryptoContextCKKSRNS>> p(params_xp);
  return catch_openfhe("CKKSParams::GetCompositeDegree", [&]() -> int {
    return static_cast<int>(p->GetCompositeDegree());
  });
}

[[cpp11::register]]
int CKKSParams__GetRegisterWordSize(SEXP params_xp) {
  external_pointer<CCParams<CryptoContextCKKSRNS>> p(params_xp);
  return catch_openfhe("CKKSParams::GetRegisterWordSize", [&]() -> int {
    return static_cast<int>(p->GetRegisterWordSize());
  });
}

[[cpp11::register]]
int CKKSParams__GetCKKSDataType(SEXP params_xp) {
  external_pointer<CCParams<CryptoContextCKKSRNS>> p(params_xp);
  return catch_openfhe("CKKSParams::GetCKKSDataType", [&]() -> int {
    return static_cast<int>(p->GetCKKSDataType());
  });
}
