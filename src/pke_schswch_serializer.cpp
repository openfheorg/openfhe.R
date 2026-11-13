// OPENFHE PYTHON SOURCE: src/lib/pke/fbt.cpp (SchemeSwitchingDataSerializer, SchemeSwitchingDataDeserializer)
//
// The two classes that write and read everything a scheme-switching
// computation needs in another process: the CKKS context, its public
// key and evaluation keys, the FHEW context with its bootstrapping
// keys, the switching key from FHEW to CKKS, and one ciphertext. The
// class itself is in schemeswitching-data-serializer.{h,cpp}, a copy
// of an OpenFHE unit-test utility (see that file).
//
// The C++ classes default the data directory to "demoData" under the
// working directory. The R handles record whether SetDataDirectory was
// called, and the R wrappers refuse to read or write before it was, so
// that nothing is written to the working directory unasked.
#include "openfhe_cpp11.h"
#include "openfhe_helpers.h"

#include <string>

#include "schemeswitching-data-serializer.h"

using namespace cpp11;

namespace {

struct RSerializer : SchemeSwitchingDataSerializer {
  using SchemeSwitchingDataSerializer::SchemeSwitchingDataSerializer;
  bool dir_set = false;
};

struct RDeserializer : SchemeSwitchingDataDeserializer {
  bool dir_set = false;
  bool loaded = false;
};

}  // namespace

namespace openfhe_r {
template <> struct xptr_traits<RSerializer> {
  static const char* name() { return "openfhe.R::SchemeSwitchingDataSerializer"; } };
template <> struct xptr_traits<RDeserializer> {
  static const char* name() { return "openfhe.R::SchemeSwitchingDataDeserializer"; } };
}  // namespace openfhe_r

[[cpp11::register]]
SEXP SchSwchSerializer__new(SEXP cc_xp, SEXP pk_xp, SEXP ct_xp) {
  xptr<CryptoContext<DCRTPoly>> cc(cc_xp);
  xptr<PublicKey<DCRTPoly>> pk(pk_xp);
  xptr<Ciphertext<DCRTPoly>> ct(ct_xp);
  return catch_openfhe("SchemeSwitchingDataSerializer", [&]() {
    // The constructor dereferences the context.
    if (!*cc) cpp11::stop("null crypto context");
    if (!*pk) cpp11::stop("null public key");
    if (!*ct) cpp11::stop("null ciphertext");
    return xptr<RSerializer>(new RSerializer(*cc, *pk, *ct));
  });
}

[[cpp11::register]]
SEXP SchSwchDeserializer__new() {
  return xptr<RDeserializer>(new RDeserializer());
}

[[cpp11::register]]
void SchSwchSerializer__SetDataDirectory(SEXP xp, std::string dir) {
  xptr<RSerializer> s(xp);
  catch_openfhe("SchemeSwitchingDataSerializer::SetDataDirectory", [&]() {
    s->SetDataDirectory(dir);
    s->dir_set = true;
    return true;
  });
}

[[cpp11::register]]
void SchSwchDeserializer__SetDataDirectory(SEXP xp, std::string dir) {
  xptr<RDeserializer> d(xp);
  catch_openfhe("SchemeSwitchingDataDeserializer::SetDataDirectory", [&]() {
    d->SetDataDirectory(dir);
    d->dir_set = true;
    return true;
  });
}

[[cpp11::register]]
void SchSwchSerializer__Serialize(SEXP xp) {
  xptr<RSerializer> s(xp);
  if (!s->dir_set) cpp11::stop("no data directory has been set");
  catch_openfhe("SchemeSwitchingDataSerializer::Serialize", [&]() {
    s->Serialize();
    return true;
  });
}

[[cpp11::register]]
void SchSwchDeserializer__Deserialize(SEXP xp) {
  xptr<RDeserializer> d(xp);
  if (!d->dir_set) cpp11::stop("no data directory has been set");
  catch_openfhe("SchemeSwitchingDataDeserializer::Deserialize", [&]() {
    d->Deserialize();
    d->loaded = true;
    return true;
  });
}

// which: 0 crypto context, 1 public key, 2 ciphertext. R NULL before
// Deserialize().
[[cpp11::register]]
SEXP SchSwchDeserializer__get(SEXP xp, int which) {
  xptr<RDeserializer> d(xp);
  switch (which) {
    case 0: {
      auto cc = d->getCryptoContext();
      if (!cc) return R_NilValue;
      return xptr<CryptoContext<DCRTPoly>>(new CryptoContext<DCRTPoly>(cc));
    }
    case 1: {
      auto pk = d->getPublicKey();
      if (!pk) return R_NilValue;
      return xptr<PublicKey<DCRTPoly>>(new PublicKey<DCRTPoly>(pk));
    }
    case 2: {
      auto ct = d->getRAWCiphertext();
      if (!ct) return R_NilValue;
      return xptr<Ciphertext<DCRTPoly>>(new Ciphertext<DCRTPoly>(ct));
    }
  }
  cpp11::stop("unknown accessor code %d", which);
}
