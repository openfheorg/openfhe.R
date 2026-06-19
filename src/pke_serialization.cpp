// OPENFHE PYTHON SOURCE: src/lib/pke/serialization.cpp
// Phase 3: file-based serialization for all major types
#include "openfhe_cpp11.h"

// Serialization headers
#include "ciphertext-ser.h"
#include "cryptocontext-ser.h"
#include "key/key-ser.h"

using namespace cpp11;

// ── Serialize to file ───────────────────────────────────

[[cpp11::register]]
bool Serialize__CryptoContext(SEXP cc_xp, std::string filename, bool binary) {
  external_pointer<CryptoContext<DCRTPoly>> cc(cc_xp);
  if (binary)
    return Serial::SerializeToFile(filename, *cc, SerType::BINARY);
  else
    return Serial::SerializeToFile(filename, *cc, SerType::JSON);
}

[[cpp11::register]]
bool Serialize__PublicKey(SEXP pk_xp, std::string filename, bool binary) {
  external_pointer<PublicKey<DCRTPoly>> pk(pk_xp);
  if (binary)
    return Serial::SerializeToFile(filename, *pk, SerType::BINARY);
  else
    return Serial::SerializeToFile(filename, *pk, SerType::JSON);
}

[[cpp11::register]]
bool Serialize__PrivateKey(SEXP sk_xp, std::string filename, bool binary) {
  external_pointer<PrivateKey<DCRTPoly>> sk(sk_xp);
  if (binary)
    return Serial::SerializeToFile(filename, *sk, SerType::BINARY);
  else
    return Serial::SerializeToFile(filename, *sk, SerType::JSON);
}

[[cpp11::register]]
bool Serialize__Ciphertext(SEXP ct_xp, std::string filename, bool binary) {
  external_pointer<Ciphertext<DCRTPoly>> ct(ct_xp);
  if (binary)
    return Serial::SerializeToFile(filename, *ct, SerType::BINARY);
  else
    return Serial::SerializeToFile(filename, *ct, SerType::JSON);
}

// ── Deserialize from file ───────────────────────────────

[[cpp11::register]]
SEXP Deserialize__CryptoContext(std::string filename, bool binary) {
  CryptoContext<DCRTPoly> cc;
  bool ok;
  if (binary)
    ok = Serial::DeserializeFromFile<DCRTPoly>(filename, cc, SerType::BINARY);
  else
    ok = Serial::DeserializeFromFile<DCRTPoly>(filename, cc, SerType::JSON);
  if (!ok) cpp11::stop("Failed to deserialize CryptoContext from '%s'", filename.c_str());
  return external_pointer<CryptoContext<DCRTPoly>>(
    new CryptoContext<DCRTPoly>(cc));
}

[[cpp11::register]]
SEXP Deserialize__PublicKey(std::string filename, bool binary) {
  PublicKey<DCRTPoly> pk;
  bool ok;
  if (binary)
    ok = Serial::DeserializeFromFile(filename, pk, SerType::BINARY);
  else
    ok = Serial::DeserializeFromFile(filename, pk, SerType::JSON);
  if (!ok) cpp11::stop("Failed to deserialize PublicKey from '%s'", filename.c_str());
  return external_pointer<PublicKey<DCRTPoly>>(
    new PublicKey<DCRTPoly>(pk));
}

[[cpp11::register]]
SEXP Deserialize__PrivateKey(std::string filename, bool binary) {
  PrivateKey<DCRTPoly> sk;
  bool ok;
  if (binary)
    ok = Serial::DeserializeFromFile(filename, sk, SerType::BINARY);
  else
    ok = Serial::DeserializeFromFile(filename, sk, SerType::JSON);
  if (!ok) cpp11::stop("Failed to deserialize PrivateKey from '%s'", filename.c_str());
  return external_pointer<PrivateKey<DCRTPoly>>(
    new PrivateKey<DCRTPoly>(sk));
}

[[cpp11::register]]
SEXP Deserialize__Ciphertext(std::string filename, bool binary) {
  Ciphertext<DCRTPoly> ct;
  bool ok;
  if (binary)
    ok = Serial::DeserializeFromFile(filename, ct, SerType::BINARY);
  else
    ok = Serial::DeserializeFromFile(filename, ct, SerType::JSON);
  if (!ok) cpp11::stop("Failed to deserialize Ciphertext from '%s'", filename.c_str());
  return external_pointer<Ciphertext<DCRTPoly>>(
    new Ciphertext<DCRTPoly>(ct));
}

// ── Eval key serialization (static methods) ─────────────

[[cpp11::register]]
bool Serialize__EvalMultKey(std::string filename, bool binary, std::string key_tag) {
  std::ofstream ofs(filename, std::ios::out | std::ios::binary);
  bool ok;
  if (binary)
    ok = CryptoContextImpl<DCRTPoly>::SerializeEvalMultKey<SerType::SERBINARY>(ofs, SerType::BINARY, key_tag);
  else
    ok = CryptoContextImpl<DCRTPoly>::SerializeEvalMultKey<SerType::SERJSON>(ofs, SerType::JSON, key_tag);
  ofs.close();
  return ok;
}

[[cpp11::register]]
bool Deserialize__EvalMultKey(std::string filename, bool binary) {
  std::ifstream ifs(filename, std::ios::in | std::ios::binary);
  if (!ifs.is_open()) cpp11::stop("Cannot open '%s'", filename.c_str());
  bool ok;
  if (binary)
    ok = CryptoContextImpl<DCRTPoly>::DeserializeEvalMultKey<SerType::SERBINARY>(ifs, SerType::BINARY);
  else
    ok = CryptoContextImpl<DCRTPoly>::DeserializeEvalMultKey<SerType::SERJSON>(ifs, SerType::JSON);
  return ok;
}

[[cpp11::register]]
bool Serialize__EvalAutomorphismKey(std::string filename, bool binary, std::string key_tag) {
  std::ofstream ofs(filename, std::ios::out | std::ios::binary);
  bool ok;
  if (binary)
    ok = CryptoContextImpl<DCRTPoly>::SerializeEvalAutomorphismKey<SerType::SERBINARY>(ofs, SerType::BINARY, key_tag);
  else
    ok = CryptoContextImpl<DCRTPoly>::SerializeEvalAutomorphismKey<SerType::SERJSON>(ofs, SerType::JSON, key_tag);
  ofs.close();
  return ok;
}

[[cpp11::register]]
bool Deserialize__EvalAutomorphismKey(std::string filename, bool binary) {
  std::ifstream ifs(filename, std::ios::in | std::ios::binary);
  if (!ifs.is_open()) cpp11::stop("Cannot open '%s'", filename.c_str());
  bool ok;
  if (binary)
    ok = CryptoContextImpl<DCRTPoly>::DeserializeEvalAutomorphismKey<SerType::SERBINARY>(ifs, SerType::BINARY);
  else
    ok = CryptoContextImpl<DCRTPoly>::DeserializeEvalAutomorphismKey<SerType::SERJSON>(ifs, SerType::JSON);
  return ok;
}

// ── Context cleanup ─────────────────────────────────────

[[cpp11::register]]
void ClearEvalMultKeys() {
  CryptoContextImpl<DCRTPoly>::ClearEvalMultKeys();
}

[[cpp11::register]]
void ClearEvalAutomorphismKeys() {
  CryptoContextImpl<DCRTPoly>::ClearEvalAutomorphismKeys();
}

[[cpp11::register]]
void ReleaseAllContexts() {
  CryptoContextFactory<DCRTPoly>::ReleaseAllContexts();
}
