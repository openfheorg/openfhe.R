// R-SPECIFIC: the values of the mirrored OpenFHE enums, as compiled.
//
// R/enums.R mirrors OpenFHE's C++ enums as literal integers. A literal
// that falls out of step with the vendored headers still names *some*
// enumerator, and the library accepts it without error (OpenFHE 1.6
// reordered BINFHE_PARAMSET; a stale STD128 selected another parameter
// set). This file reports the values the compiler assigned, read from
// the same headers the wrapper is built against, so a test can compare
// them with the R lists name by name. See
// inst/tinytest/test_enums_compiled.R.
//
// BINFHE_PARAMSET is enumerated through the header's own X-macro, so a
// member added upstream appears here without an edit. The other enums
// have no such list in the headers and are spelled out; a name removed
// or renamed upstream is then a compile error.

#include "openfhe_cpp11.h"
#include "binfhecontext.h"

#include <string>
#include <utility>
#include <vector>

namespace {

using EnumEntries = std::vector<std::pair<std::string, int>>;

cpp11::writable::integers as_named(const EnumEntries& entries) {
  cpp11::writable::integers values(static_cast<R_xlen_t>(entries.size()));
  cpp11::writable::strings names(static_cast<R_xlen_t>(entries.size()));
  for (size_t i = 0; i < entries.size(); ++i) {
    values[static_cast<R_xlen_t>(i)] = entries[i].second;
    names[static_cast<R_xlen_t>(i)] = entries[i].first;
  }
  values.names() = names;
  return values;
}

}  // namespace

#define OFHE_E(x) {#x, static_cast<int>(lbcrypto::x)}

[[cpp11::register]]
cpp11::writable::list openfhe_enum_values() {
  using namespace cpp11::literals;

  EnumEntries paramset = {
#define OFHE_PARAMSET_ENTRY(name, methods) {#name, static_cast<int>(lbcrypto::name)},
      BINFHE_PARAMSET_LIST(OFHE_PARAMSET_ENTRY)
#undef OFHE_PARAMSET_ENTRY
  };

  EnumEntries feature = {OFHE_E(PKE),        OFHE_E(KEYSWITCH),   OFHE_E(PRE),
                         OFHE_E(LEVELEDSHE), OFHE_E(ADVANCEDSHE), OFHE_E(MULTIPARTY),
                         OFHE_E(FHE),        OFHE_E(SCHEMESWITCH)};

  EnumEntries scaling = {OFHE_E(FIXEDMANUAL),          OFHE_E(FIXEDAUTO),
                         OFHE_E(FLEXIBLEAUTO),         OFHE_E(FLEXIBLEAUTOEXT),
                         OFHE_E(COMPOSITESCALINGAUTO), OFHE_E(COMPOSITESCALINGMANUAL),
                         OFHE_E(NORESCALE),            OFHE_E(INVALID_RS_TECHNIQUE)};

  EnumEntries keyswitch = {OFHE_E(INVALID_KS_TECH), OFHE_E(BV), OFHE_E(HYBRID)};

  EnumEntries security = {OFHE_E(HEStd_128_classic), OFHE_E(HEStd_192_classic),
                          OFHE_E(HEStd_256_classic), OFHE_E(HEStd_128_quantum),
                          OFHE_E(HEStd_192_quantum), OFHE_E(HEStd_256_quantum),
                          OFHE_E(HEStd_NotSet)};

  EnumEntries secret_key_dist = {OFHE_E(GAUSSIAN), OFHE_E(UNIFORM_TERNARY),
                                 OFHE_E(SPARSE_TERNARY), OFHE_E(SPARSE_ENCAPSULATED)};

  EnumEntries binfhe_method = {OFHE_E(INVALID_METHOD), OFHE_E(AP), OFHE_E(GINX),
                               OFHE_E(LMKCDEY)};

  EnumEntries bingate = {OFHE_E(OR),       OFHE_E(AND),       OFHE_E(NOR),  OFHE_E(NAND),
                         OFHE_E(XOR),      OFHE_E(XNOR),      OFHE_E(MAJORITY),
                         OFHE_E(AND3),     OFHE_E(OR3),       OFHE_E(AND4), OFHE_E(OR4),
                         OFHE_E(XOR_FAST), OFHE_E(XNOR_FAST), OFHE_E(CMUX)};

  EnumEntries binfhe_output = {OFHE_E(INVALID_OUTPUT), OFHE_E(FRESH), OFHE_E(BOOTSTRAPPED),
                               OFHE_E(LARGE_DIM), OFHE_E(SMALL_DIM)};

  EnumEntries keygen_mode = {OFHE_E(SYM_ENCRYPT), OFHE_E(PUB_ENCRYPT)};

  EnumEntries encodings = {OFHE_E(INVALID_ENCODING), OFHE_E(COEF_PACKED_ENCODING),
                           OFHE_E(PACKED_ENCODING), OFHE_E(STRING_ENCODING),
                           OFHE_E(CKKS_PACKED_ENCODING)};

  EnumEntries distribution = {OFHE_E(HEStd_uniform), OFHE_E(HEStd_error),
                              OFHE_E(HEStd_ternary)};

  EnumEntries multiparty = {OFHE_E(INVALID_MULTIPARTY_MODE), OFHE_E(FIXED_NOISE_MULTIPARTY),
                            OFHE_E(NOISE_FLOODING_MULTIPARTY)};

  EnumEntries execution = {OFHE_E(EXEC_EVALUATION), OFHE_E(EXEC_NOISE_ESTIMATION)};

  EnumEntries decryption_noise = {OFHE_E(FIXED_NOISE_DECRYPT),
                                  OFHE_E(NOISE_FLOODING_DECRYPT)};

  EnumEntries pre_mode = {OFHE_E(NOT_SET), OFHE_E(INDCPA), OFHE_E(FIXED_NOISE_HRA),
                          OFHE_E(NOISE_FLOODING_HRA)};

  EnumEntries mult_technique = {OFHE_E(BEHZ), OFHE_E(HPS), OFHE_E(HPSPOVERQ),
                                OFHE_E(HPSPOVERQLEVELED)};

  EnumEntries enc_technique = {OFHE_E(STANDARD), OFHE_E(EXTENDED)};

  EnumEntries ckks_data_type = {OFHE_E(REAL), OFHE_E(COMPLEX)};

  EnumEntries compression = {OFHE_E(COMPACT), OFHE_E(SLACK)};

  EnumEntries scheme_id = {OFHE_E(INVALID_SCHEME), OFHE_E(CKKSRNS_SCHEME),
                           OFHE_E(BFVRNS_SCHEME), OFHE_E(BGVRNS_SCHEME)};

  // Format is declared at global scope (core/utils/inttypes.h).
  EnumEntries format = {{"EVALUATION", static_cast<int>(Format::EVALUATION)},
                        {"COEFFICIENT", static_cast<int>(Format::COEFFICIENT)}};

  // The list names are the names of the R objects in R/enums.R.
  return cpp11::writable::list({
      "Format"_nm = as_named(format),
      "BinFHEParamSet"_nm = as_named(paramset),
      "Feature"_nm = as_named(feature),
      "ScalingTechnique"_nm = as_named(scaling),
      "KeySwitchTechnique"_nm = as_named(keyswitch),
      "SecurityLevel"_nm = as_named(security),
      "SecretKeyDist"_nm = as_named(secret_key_dist),
      "BinFHEMethod"_nm = as_named(binfhe_method),
      "BinGate"_nm = as_named(bingate),
      "BinFHEOutput"_nm = as_named(binfhe_output),
      "KeygenMode"_nm = as_named(keygen_mode),
      "PlaintextEncodings"_nm = as_named(encodings),
      "DistributionType"_nm = as_named(distribution),
      "MultipartyMode"_nm = as_named(multiparty),
      "ExecutionMode"_nm = as_named(execution),
      "DecryptionNoiseMode"_nm = as_named(decryption_noise),
      "PREMode"_nm = as_named(pre_mode),
      "MultiplicationTechnique"_nm = as_named(mult_technique),
      "EncryptionTechnique"_nm = as_named(enc_technique),
      "CKKSDataType"_nm = as_named(ckks_data_type),
      "CompressionLevel"_nm = as_named(compression),
      "SchemeId"_nm = as_named(scheme_id),
  });
}

#undef OFHE_E
