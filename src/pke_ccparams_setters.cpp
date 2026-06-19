// OPENFHE PYTHON SOURCE: src/lib/bindings.cpp (bind_parameters)
//
// extended CCParams setter surface for BFV/BGV/CKKS.
//
// Per discovery D013, each of the three `CCParams<T>` specialisations
// overrides a subset of `Params` base-class setters with a
// `DISABLED_FOR_XXXRNS` throw body. Those overrides are NOT bound at
// the cpp11 layer: the R constructor rejects unknown arguments before
// the cpp11 call site is reached, and the cpp11 surface therefore
// matches the set of *enabled* C++ setters rather than the union of
// declared ones. This is narrower than openfhe-python's bind_parameters
// surface (which uses py::overload_cast on the derived-class
// override and therefore includes the throwing methods) and is a
// deliberate R-side deviation documented in notes/upstream-defects.md
// and notes/discoveries/D013_ccparams_disabled_setters.md.
//
// Enabled-setter counts (per D013 spreadsheet):
//   BFV  = 19 total enabled (5 already in pke_bindings.cpp + 14 here)
//   BGV  = 22 total enabled (2 already in pke_bindings.cpp + 20 here)
//   CKKS = 24 total enabled (10 already in pke_bindings.cpp + 14 here)
//   Total new cpp11 bindings in this file: 48
//
// Every binding wraps its C++ call site in catch_openfhe from
// openfhe_helpers.h per design.md §5.
#include "openfhe_cpp11.h"
#include "openfhe_helpers.h"

using namespace cpp11;

// ── BFV Parameters ────────────────────────

[[cpp11::register]]
void BFVParams__SetDigitSize(SEXP params_xp, int value) {
  external_pointer<CCParams<CryptoContextBFVRNS>> p(params_xp);
  catch_openfhe("BFVParams::SetDigitSize", [&]() {
    p->SetDigitSize(static_cast<uint32_t>(value));
  });
}

[[cpp11::register]]
void BFVParams__SetStandardDeviation(SEXP params_xp, double value) {
  external_pointer<CCParams<CryptoContextBFVRNS>> p(params_xp);
  catch_openfhe("BFVParams::SetStandardDeviation", [&]() {
    p->SetStandardDeviation(static_cast<float>(value));
  });
}

[[cpp11::register]]
void BFVParams__SetSecretKeyDist(SEXP params_xp, int value) {
  external_pointer<CCParams<CryptoContextBFVRNS>> p(params_xp);
  catch_openfhe("BFVParams::SetSecretKeyDist", [&]() {
    p->SetSecretKeyDist(static_cast<SecretKeyDist>(value));
  });
}

[[cpp11::register]]
void BFVParams__SetMaxRelinSkDeg(SEXP params_xp, int value) {
  external_pointer<CCParams<CryptoContextBFVRNS>> p(params_xp);
  catch_openfhe("BFVParams::SetMaxRelinSkDeg", [&]() {
    p->SetMaxRelinSkDeg(static_cast<uint32_t>(value));
  });
}

[[cpp11::register]]
void BFVParams__SetPREMode(SEXP params_xp, int value) {
  external_pointer<CCParams<CryptoContextBFVRNS>> p(params_xp);
  catch_openfhe("BFVParams::SetPREMode", [&]() {
    p->SetPREMode(static_cast<ProxyReEncryptionMode>(value));
  });
}

[[cpp11::register]]
void BFVParams__SetMultipartyMode(SEXP params_xp, int value) {
  external_pointer<CCParams<CryptoContextBFVRNS>> p(params_xp);
  catch_openfhe("BFVParams::SetMultipartyMode", [&]() {
    p->SetMultipartyMode(static_cast<MultipartyMode>(value));
  });
}

[[cpp11::register]]
void BFVParams__SetThresholdNumOfParties(SEXP params_xp, int value) {
  external_pointer<CCParams<CryptoContextBFVRNS>> p(params_xp);
  catch_openfhe("BFVParams::SetThresholdNumOfParties", [&]() {
    p->SetThresholdNumOfParties(static_cast<uint32_t>(value));
  });
}

[[cpp11::register]]
void BFVParams__SetKeySwitchTechnique(SEXP params_xp, int value) {
  external_pointer<CCParams<CryptoContextBFVRNS>> p(params_xp);
  catch_openfhe("BFVParams::SetKeySwitchTechnique", [&]() {
    p->SetKeySwitchTechnique(static_cast<KeySwitchTechnique>(value));
  });
}

[[cpp11::register]]
void BFVParams__SetNumLargeDigits(SEXP params_xp, int value) {
  external_pointer<CCParams<CryptoContextBFVRNS>> p(params_xp);
  catch_openfhe("BFVParams::SetNumLargeDigits", [&]() {
    p->SetNumLargeDigits(static_cast<uint32_t>(value));
  });
}

[[cpp11::register]]
void BFVParams__SetScalingModSize(SEXP params_xp, int value) {
  external_pointer<CCParams<CryptoContextBFVRNS>> p(params_xp);
  catch_openfhe("BFVParams::SetScalingModSize", [&]() {
    p->SetScalingModSize(static_cast<uint32_t>(value));
  });
}

[[cpp11::register]]
void BFVParams__SetEvalAddCount(SEXP params_xp, int value) {
  external_pointer<CCParams<CryptoContextBFVRNS>> p(params_xp);
  catch_openfhe("BFVParams::SetEvalAddCount", [&]() {
    p->SetEvalAddCount(static_cast<uint32_t>(value));
  });
}

[[cpp11::register]]
void BFVParams__SetKeySwitchCount(SEXP params_xp, int value) {
  external_pointer<CCParams<CryptoContextBFVRNS>> p(params_xp);
  catch_openfhe("BFVParams::SetKeySwitchCount", [&]() {
    p->SetKeySwitchCount(static_cast<uint32_t>(value));
  });
}

[[cpp11::register]]
void BFVParams__SetEncryptionTechnique(SEXP params_xp, int value) {
  external_pointer<CCParams<CryptoContextBFVRNS>> p(params_xp);
  catch_openfhe("BFVParams::SetEncryptionTechnique", [&]() {
    p->SetEncryptionTechnique(static_cast<EncryptionTechnique>(value));
  });
}

[[cpp11::register]]
void BFVParams__SetMultiplicationTechnique(SEXP params_xp, int value) {
  external_pointer<CCParams<CryptoContextBFVRNS>> p(params_xp);
  catch_openfhe("BFVParams::SetMultiplicationTechnique", [&]() {
    p->SetMultiplicationTechnique(static_cast<MultiplicationTechnique>(value));
  });
}

// ── BGV Parameters ────────────────────────

[[cpp11::register]]
void BGVParams__SetDigitSize(SEXP params_xp, int value) {
  external_pointer<CCParams<CryptoContextBGVRNS>> p(params_xp);
  catch_openfhe("BGVParams::SetDigitSize", [&]() {
    p->SetDigitSize(static_cast<uint32_t>(value));
  });
}

[[cpp11::register]]
void BGVParams__SetStandardDeviation(SEXP params_xp, double value) {
  external_pointer<CCParams<CryptoContextBGVRNS>> p(params_xp);
  catch_openfhe("BGVParams::SetStandardDeviation", [&]() {
    p->SetStandardDeviation(static_cast<float>(value));
  });
}

[[cpp11::register]]
void BGVParams__SetSecretKeyDist(SEXP params_xp, int value) {
  external_pointer<CCParams<CryptoContextBGVRNS>> p(params_xp);
  catch_openfhe("BGVParams::SetSecretKeyDist", [&]() {
    p->SetSecretKeyDist(static_cast<SecretKeyDist>(value));
  });
}

[[cpp11::register]]
void BGVParams__SetMaxRelinSkDeg(SEXP params_xp, int value) {
  external_pointer<CCParams<CryptoContextBGVRNS>> p(params_xp);
  catch_openfhe("BGVParams::SetMaxRelinSkDeg", [&]() {
    p->SetMaxRelinSkDeg(static_cast<uint32_t>(value));
  });
}

[[cpp11::register]]
void BGVParams__SetPREMode(SEXP params_xp, int value) {
  external_pointer<CCParams<CryptoContextBGVRNS>> p(params_xp);
  catch_openfhe("BGVParams::SetPREMode", [&]() {
    p->SetPREMode(static_cast<ProxyReEncryptionMode>(value));
  });
}

[[cpp11::register]]
void BGVParams__SetMultipartyMode(SEXP params_xp, int value) {
  external_pointer<CCParams<CryptoContextBGVRNS>> p(params_xp);
  catch_openfhe("BGVParams::SetMultipartyMode", [&]() {
    p->SetMultipartyMode(static_cast<MultipartyMode>(value));
  });
}

[[cpp11::register]]
void BGVParams__SetStatisticalSecurity(SEXP params_xp, int value) {
  external_pointer<CCParams<CryptoContextBGVRNS>> p(params_xp);
  catch_openfhe("BGVParams::SetStatisticalSecurity", [&]() {
    p->SetStatisticalSecurity(static_cast<uint32_t>(value));
  });
}

[[cpp11::register]]
void BGVParams__SetNumAdversarialQueries(SEXP params_xp, int value) {
  external_pointer<CCParams<CryptoContextBGVRNS>> p(params_xp);
  catch_openfhe("BGVParams::SetNumAdversarialQueries", [&]() {
    p->SetNumAdversarialQueries(static_cast<uint32_t>(value));
  });
}

[[cpp11::register]]
void BGVParams__SetThresholdNumOfParties(SEXP params_xp, int value) {
  external_pointer<CCParams<CryptoContextBGVRNS>> p(params_xp);
  catch_openfhe("BGVParams::SetThresholdNumOfParties", [&]() {
    p->SetThresholdNumOfParties(static_cast<uint32_t>(value));
  });
}

[[cpp11::register]]
void BGVParams__SetKeySwitchTechnique(SEXP params_xp, int value) {
  external_pointer<CCParams<CryptoContextBGVRNS>> p(params_xp);
  catch_openfhe("BGVParams::SetKeySwitchTechnique", [&]() {
    p->SetKeySwitchTechnique(static_cast<KeySwitchTechnique>(value));
  });
}

[[cpp11::register]]
void BGVParams__SetScalingTechnique(SEXP params_xp, int value) {
  external_pointer<CCParams<CryptoContextBGVRNS>> p(params_xp);
  catch_openfhe("BGVParams::SetScalingTechnique", [&]() {
    p->SetScalingTechnique(static_cast<ScalingTechnique>(value));
  });
}

[[cpp11::register]]
void BGVParams__SetBatchSize(SEXP params_xp, int value) {
  external_pointer<CCParams<CryptoContextBGVRNS>> p(params_xp);
  catch_openfhe("BGVParams::SetBatchSize", [&]() {
    p->SetBatchSize(static_cast<uint32_t>(value));
  });
}

[[cpp11::register]]
void BGVParams__SetFirstModSize(SEXP params_xp, int value) {
  external_pointer<CCParams<CryptoContextBGVRNS>> p(params_xp);
  catch_openfhe("BGVParams::SetFirstModSize", [&]() {
    p->SetFirstModSize(static_cast<uint32_t>(value));
  });
}

[[cpp11::register]]
void BGVParams__SetNumLargeDigits(SEXP params_xp, int value) {
  external_pointer<CCParams<CryptoContextBGVRNS>> p(params_xp);
  catch_openfhe("BGVParams::SetNumLargeDigits", [&]() {
    p->SetNumLargeDigits(static_cast<uint32_t>(value));
  });
}

[[cpp11::register]]
void BGVParams__SetScalingModSize(SEXP params_xp, int value) {
  external_pointer<CCParams<CryptoContextBGVRNS>> p(params_xp);
  catch_openfhe("BGVParams::SetScalingModSize", [&]() {
    p->SetScalingModSize(static_cast<uint32_t>(value));
  });
}

[[cpp11::register]]
void BGVParams__SetSecurityLevel(SEXP params_xp, int value) {
  external_pointer<CCParams<CryptoContextBGVRNS>> p(params_xp);
  catch_openfhe("BGVParams::SetSecurityLevel", [&]() {
    p->SetSecurityLevel(static_cast<SecurityLevel>(value));
  });
}

[[cpp11::register]]
void BGVParams__SetRingDim(SEXP params_xp, int value) {
  external_pointer<CCParams<CryptoContextBGVRNS>> p(params_xp);
  catch_openfhe("BGVParams::SetRingDim", [&]() {
    p->SetRingDim(static_cast<uint32_t>(value));
  });
}

[[cpp11::register]]
void BGVParams__SetEvalAddCount(SEXP params_xp, int value) {
  external_pointer<CCParams<CryptoContextBGVRNS>> p(params_xp);
  catch_openfhe("BGVParams::SetEvalAddCount", [&]() {
    p->SetEvalAddCount(static_cast<uint32_t>(value));
  });
}

[[cpp11::register]]
void BGVParams__SetKeySwitchCount(SEXP params_xp, int value) {
  external_pointer<CCParams<CryptoContextBGVRNS>> p(params_xp);
  catch_openfhe("BGVParams::SetKeySwitchCount", [&]() {
    p->SetKeySwitchCount(static_cast<uint32_t>(value));
  });
}

[[cpp11::register]]
void BGVParams__SetPRENumHops(SEXP params_xp, int value) {
  external_pointer<CCParams<CryptoContextBGVRNS>> p(params_xp);
  catch_openfhe("BGVParams::SetPRENumHops", [&]() {
    p->SetPRENumHops(static_cast<uint32_t>(value));
  });
}

// ── CKKS Parameters ───────────────────────

[[cpp11::register]]
void CKKSParams__SetStandardDeviation(SEXP params_xp, double value) {
  external_pointer<CCParams<CryptoContextCKKSRNS>> p(params_xp);
  catch_openfhe("CKKSParams::SetStandardDeviation", [&]() {
    p->SetStandardDeviation(static_cast<float>(value));
  });
}

[[cpp11::register]]
void CKKSParams__SetSecretKeyDist(SEXP params_xp, int value) {
  external_pointer<CCParams<CryptoContextCKKSRNS>> p(params_xp);
  catch_openfhe("CKKSParams::SetSecretKeyDist", [&]() {
    p->SetSecretKeyDist(static_cast<SecretKeyDist>(value));
  });
}

[[cpp11::register]]
void CKKSParams__SetMaxRelinSkDeg(SEXP params_xp, int value) {
  external_pointer<CCParams<CryptoContextCKKSRNS>> p(params_xp);
  catch_openfhe("CKKSParams::SetMaxRelinSkDeg", [&]() {
    p->SetMaxRelinSkDeg(static_cast<uint32_t>(value));
  });
}

[[cpp11::register]]
void CKKSParams__SetPREMode(SEXP params_xp, int value) {
  external_pointer<CCParams<CryptoContextCKKSRNS>> p(params_xp);
  catch_openfhe("CKKSParams::SetPREMode", [&]() {
    p->SetPREMode(static_cast<ProxyReEncryptionMode>(value));
  });
}

[[cpp11::register]]
void CKKSParams__SetExecutionMode(SEXP params_xp, int value) {
  external_pointer<CCParams<CryptoContextCKKSRNS>> p(params_xp);
  catch_openfhe("CKKSParams::SetExecutionMode", [&]() {
    p->SetExecutionMode(static_cast<ExecutionMode>(value));
  });
}

[[cpp11::register]]
void CKKSParams__SetDecryptionNoiseMode(SEXP params_xp, int value) {
  external_pointer<CCParams<CryptoContextCKKSRNS>> p(params_xp);
  catch_openfhe("CKKSParams::SetDecryptionNoiseMode", [&]() {
    p->SetDecryptionNoiseMode(static_cast<DecryptionNoiseMode>(value));
  });
}

[[cpp11::register]]
void CKKSParams__SetNoiseEstimate(SEXP params_xp, double value) {
  external_pointer<CCParams<CryptoContextCKKSRNS>> p(params_xp);
  catch_openfhe("CKKSParams::SetNoiseEstimate", [&]() {
    p->SetNoiseEstimate(value);
  });
}

[[cpp11::register]]
void CKKSParams__SetDesiredPrecision(SEXP params_xp, double value) {
  external_pointer<CCParams<CryptoContextCKKSRNS>> p(params_xp);
  catch_openfhe("CKKSParams::SetDesiredPrecision", [&]() {
    p->SetDesiredPrecision(value);
  });
}

[[cpp11::register]]
void CKKSParams__SetStatisticalSecurity(SEXP params_xp, int value) {
  external_pointer<CCParams<CryptoContextCKKSRNS>> p(params_xp);
  catch_openfhe("CKKSParams::SetStatisticalSecurity", [&]() {
    p->SetStatisticalSecurity(static_cast<uint32_t>(value));
  });
}

[[cpp11::register]]
void CKKSParams__SetNumAdversarialQueries(SEXP params_xp, int value) {
  external_pointer<CCParams<CryptoContextCKKSRNS>> p(params_xp);
  catch_openfhe("CKKSParams::SetNumAdversarialQueries", [&]() {
    p->SetNumAdversarialQueries(static_cast<uint32_t>(value));
  });
}

[[cpp11::register]]
void CKKSParams__SetInteractiveBootCompressionLevel(SEXP params_xp, int value) {
  external_pointer<CCParams<CryptoContextCKKSRNS>> p(params_xp);
  catch_openfhe("CKKSParams::SetInteractiveBootCompressionLevel", [&]() {
    p->SetInteractiveBootCompressionLevel(static_cast<CompressionLevel>(value));
  });
}

[[cpp11::register]]
void CKKSParams__SetCompositeDegree(SEXP params_xp, int value) {
  external_pointer<CCParams<CryptoContextCKKSRNS>> p(params_xp);
  catch_openfhe("CKKSParams::SetCompositeDegree", [&]() {
    p->SetCompositeDegree(static_cast<uint32_t>(value));
  });
}

[[cpp11::register]]
void CKKSParams__SetRegisterWordSize(SEXP params_xp, int value) {
  external_pointer<CCParams<CryptoContextCKKSRNS>> p(params_xp);
  catch_openfhe("CKKSParams::SetRegisterWordSize", [&]() {
    p->SetRegisterWordSize(static_cast<uint32_t>(value));
  });
}

[[cpp11::register]]
void CKKSParams__SetCKKSDataType(SEXP params_xp, int value) {
  external_pointer<CCParams<CryptoContextCKKSRNS>> p(params_xp);
  catch_openfhe("CKKSParams::SetCKKSDataType", [&]() {
    p->SetCKKSDataType(static_cast<CKKSDataType>(value));
  });
}
