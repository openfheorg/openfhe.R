// OPENFHE PYTHON SOURCE: NONE — SerializeEvalSumKey / DeserializeEvalSumKey are R-first
//
// openfhe-python v1.5.1.0 does not bind SerializeEvalSumKey or
// DeserializeEvalSumKey. The Python design routes sum-key
// serialization through the automorphism backend on the C++
// side (cryptocontext-ser.h lines 730/756 — both SerializeEvalSumKey
// and DeserializeEvalSumKey just delegate to the matching
// EvalAutomorphismKey entry points), so Python users reach for
// the automorphism surface directly. R exposes both entry
// points so fixture authors can match whichever OpenFHE doc
// they are reading. Logged in notes/upstream-defects.md R-only
// surface section.
//
// Two new cpp11
// bindings, both file-based and wrapped in catch_openfhe.
// Mirror the pke_serialization.cpp EvalMultKey /
// EvalAutomorphismKey pattern exactly — the only difference is
// the template specialization.

#include "openfhe_cpp11.h"
#include "openfhe_helpers.h"
#include "cryptocontext-ser.h"
#include <fstream>
#include <string>

using namespace cpp11;

[[cpp11::register]]
bool Serialize__EvalSumKey(std::string filename, bool binary,
                           std::string key_tag) {
  return catch_openfhe("CryptoContextImpl::SerializeEvalSumKey", [&]() {
    std::ofstream ofs(filename, std::ios::out | std::ios::binary);
    bool ok;
    if (binary) {
      ok = CryptoContextImpl<DCRTPoly>::SerializeEvalSumKey<SerType::SERBINARY>(
        ofs, SerType::BINARY, key_tag);
    } else {
      ok = CryptoContextImpl<DCRTPoly>::SerializeEvalSumKey<SerType::SERJSON>(
        ofs, SerType::JSON, key_tag);
    }
    ofs.close();
    return ok;
  });
}

[[cpp11::register]]
bool Deserialize__EvalSumKey(std::string filename, bool binary) {
  return catch_openfhe("CryptoContextImpl::DeserializeEvalSumKey", [&]() {
    std::ifstream ifs(filename, std::ios::in | std::ios::binary);
    if (!ifs.is_open()) {
      cpp11::stop("Cannot open '%s'", filename.c_str());
    }
    bool ok;
    if (binary) {
      ok = CryptoContextImpl<DCRTPoly>::DeserializeEvalSumKey<SerType::SERBINARY>(
        ifs, SerType::BINARY);
    } else {
      ok = CryptoContextImpl<DCRTPoly>::DeserializeEvalSumKey<SerType::SERJSON>(
        ifs, SerType::JSON);
    }
    return ok;
  });
}
