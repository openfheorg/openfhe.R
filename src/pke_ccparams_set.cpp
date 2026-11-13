// OPENFHE PYTHON SOURCE: src/lib/bindings.cpp (bind_parameters: Set* and __str__)
//
// Every setter of lbcrypto::Params, callable after construction on any
// of the three parameter classes, and the stream form of a parameter
// object.
//
// openfhe-python binds all 33 setters on each of CCParamsBFVRNS,
// CCParamsBGVRNS and CCParamsCKKSRNS, including those a scheme
// overrides with a DISABLED_FOR_xxxRNS throw. This file does the same
// (D13 Decision 3, replacing the deviation recorded in D013): one
// registered function, a field code, and a template over the parameter
// class, so that a scheme-disabled setter reaches the override and
// OpenFHE's own error comes back.
//
// The field codes are mirrored in R/params-setters.R (.CCPARAMS_FIELD);
// inst/tinytest/test_params_set.R checks every code against its getter.
#include "openfhe_cpp11.h"
#include "openfhe_helpers.h"
#include "wide_integers.h"

#include <sstream>
#include <string>

using namespace cpp11;

namespace {

enum ParamField {
  F_PLAINTEXT_MODULUS = 0,
  F_DIGIT_SIZE,
  F_STANDARD_DEVIATION,
  F_SECRET_KEY_DIST,
  F_MAX_RELIN_SK_DEG,
  F_PRE_MODE,
  F_MULTIPARTY_MODE,
  F_EXECUTION_MODE,
  F_DECRYPTION_NOISE_MODE,
  F_NOISE_ESTIMATE,
  F_DESIRED_PRECISION,
  F_STATISTICAL_SECURITY,
  F_NUM_ADVERSARIAL_QUERIES,
  F_THRESHOLD_NUM_OF_PARTIES,
  F_KEY_SWITCH_TECHNIQUE,
  F_SCALING_TECHNIQUE,
  F_BATCH_SIZE,
  F_FIRST_MOD_SIZE,
  F_NUM_LARGE_DIGITS,
  F_MULTIPLICATIVE_DEPTH,
  F_SCALING_MOD_SIZE,
  F_SECURITY_LEVEL,
  F_RING_DIM,
  F_EVAL_ADD_COUNT,
  F_KEY_SWITCH_COUNT,
  F_ENCRYPTION_TECHNIQUE,
  F_MULTIPLICATION_TECHNIQUE,
  F_PRE_NUM_HOPS,
  F_INTERACTIVE_BOOT_COMPRESSION_LEVEL,
  F_COMPOSITE_DEGREE,
  F_REGISTER_WORD_SIZE,
  F_CKKS_DATA_TYPE
};

// The R wrapper sends an integer for counts and enums, a double for the
// three real-valued fields, and a decimal string for the plaintext
// modulus.
uint32_t u32(SEXP v) {
  int i = cpp11::as_cpp<int>(v);
  if (i < 0) cpp11::stop("`value` must not be negative");
  return static_cast<uint32_t>(i);
}
template <typename E>
E as_enum(SEXP v) { return static_cast<E>(cpp11::as_cpp<int>(v)); }

template <typename P>
void set_field(P& p, int field, SEXP v) {
  switch (field) {
    case F_PLAINTEXT_MODULUS:
      p.SetPlaintextModulus(static_cast<PlaintextModulus>(
          openfhe_r::uint64_from_r(cpp11::as_cpp<std::string>(v), "value")));
      return;
    case F_DIGIT_SIZE:               p.SetDigitSize(u32(v)); return;
    case F_STANDARD_DEVIATION:
      p.SetStandardDeviation(static_cast<float>(cpp11::as_cpp<double>(v)));
      return;
    case F_SECRET_KEY_DIST:          p.SetSecretKeyDist(as_enum<SecretKeyDist>(v)); return;
    case F_MAX_RELIN_SK_DEG:         p.SetMaxRelinSkDeg(u32(v)); return;
    case F_PRE_MODE:                 p.SetPREMode(as_enum<ProxyReEncryptionMode>(v)); return;
    case F_MULTIPARTY_MODE:          p.SetMultipartyMode(as_enum<MultipartyMode>(v)); return;
    case F_EXECUTION_MODE:           p.SetExecutionMode(as_enum<ExecutionMode>(v)); return;
    case F_DECRYPTION_NOISE_MODE:
      p.SetDecryptionNoiseMode(as_enum<DecryptionNoiseMode>(v));
      return;
    case F_NOISE_ESTIMATE:           p.SetNoiseEstimate(cpp11::as_cpp<double>(v)); return;
    case F_DESIRED_PRECISION:        p.SetDesiredPrecision(cpp11::as_cpp<double>(v)); return;
    case F_STATISTICAL_SECURITY:     p.SetStatisticalSecurity(u32(v)); return;
    case F_NUM_ADVERSARIAL_QUERIES:  p.SetNumAdversarialQueries(u32(v)); return;
    case F_THRESHOLD_NUM_OF_PARTIES: p.SetThresholdNumOfParties(u32(v)); return;
    case F_KEY_SWITCH_TECHNIQUE:
      p.SetKeySwitchTechnique(as_enum<KeySwitchTechnique>(v));
      return;
    case F_SCALING_TECHNIQUE:        p.SetScalingTechnique(as_enum<ScalingTechnique>(v)); return;
    case F_BATCH_SIZE:               p.SetBatchSize(u32(v)); return;
    case F_FIRST_MOD_SIZE:           p.SetFirstModSize(u32(v)); return;
    case F_NUM_LARGE_DIGITS:         p.SetNumLargeDigits(u32(v)); return;
    case F_MULTIPLICATIVE_DEPTH:     p.SetMultiplicativeDepth(u32(v)); return;
    case F_SCALING_MOD_SIZE:         p.SetScalingModSize(u32(v)); return;
    case F_SECURITY_LEVEL:           p.SetSecurityLevel(as_enum<SecurityLevel>(v)); return;
    case F_RING_DIM:                 p.SetRingDim(u32(v)); return;
    case F_EVAL_ADD_COUNT:           p.SetEvalAddCount(u32(v)); return;
    case F_KEY_SWITCH_COUNT:         p.SetKeySwitchCount(u32(v)); return;
    case F_ENCRYPTION_TECHNIQUE:
      p.SetEncryptionTechnique(as_enum<EncryptionTechnique>(v));
      return;
    case F_MULTIPLICATION_TECHNIQUE:
      p.SetMultiplicationTechnique(as_enum<MultiplicationTechnique>(v));
      return;
    case F_PRE_NUM_HOPS:             p.SetPRENumHops(u32(v)); return;
    case F_INTERACTIVE_BOOT_COMPRESSION_LEVEL:
      p.SetInteractiveBootCompressionLevel(as_enum<CompressionLevel>(v));
      return;
    case F_COMPOSITE_DEGREE:         p.SetCompositeDegree(u32(v)); return;
    case F_REGISTER_WORD_SIZE:       p.SetRegisterWordSize(u32(v)); return;
    case F_CKKS_DATA_TYPE:           p.SetCKKSDataType(as_enum<CKKSDataType>(v)); return;
  }
  cpp11::stop("unknown parameter field code %d", field);
}

template <typename P>
std::string stream_form(const P& p) {
  std::ostringstream os;
  os << p;
  return os.str();
}

// Which of the three parameter classes a handle carries, from its tag.
enum ParamClass { PC_BFV, PC_BGV, PC_CKKS };
ParamClass param_class(SEXP xp) {
  const std::string tag = openfhe_r::xptr_tag_name(xp);
  if (tag == "openfhe.R::BFVParams") return PC_BFV;
  if (tag == "openfhe.R::BGVParams") return PC_BGV;
  if (tag == "openfhe.R::CKKSParams") return PC_CKKS;
  cpp11::stop("expected a <BFVParams>, <BGVParams> or <CKKSParams> handle, got <%s>",
              tag.empty() ? "an untagged object" : tag.c_str());
}

}  // namespace

[[cpp11::register]]
void CCParams__Set(SEXP params_xp, int field, SEXP value) {
  switch (param_class(params_xp)) {
    case PC_BFV: {
      xptr<CCParams<CryptoContextBFVRNS>> p(params_xp);
      catch_openfhe("CCParams<CryptoContextBFVRNS>::Set*", [&]() { set_field(*p, field, value); });
      return;
    }
    case PC_BGV: {
      xptr<CCParams<CryptoContextBGVRNS>> p(params_xp);
      catch_openfhe("CCParams<CryptoContextBGVRNS>::Set*", [&]() { set_field(*p, field, value); });
      return;
    }
    case PC_CKKS: {
      xptr<CCParams<CryptoContextCKKSRNS>> p(params_xp);
      catch_openfhe("CCParams<CryptoContextCKKSRNS>::Set*", [&]() { set_field(*p, field, value); });
      return;
    }
  }
}

// operator<< of the parameter object: what openfhe-python returns from
// __str__.
[[cpp11::register]]
std::string CCParams__ToString(SEXP params_xp) {
  switch (param_class(params_xp)) {
    case PC_BFV: {
      xptr<CCParams<CryptoContextBFVRNS>> p(params_xp);
      return stream_form(*p);
    }
    case PC_BGV: {
      xptr<CCParams<CryptoContextBGVRNS>> p(params_xp);
      return stream_form(*p);
    }
    case PC_CKKS: {
      xptr<CCParams<CryptoContextCKKSRNS>> p(params_xp);
      return stream_form(*p);
    }
  }
  cpp11::stop("unreachable");
}
