// OPENFHE PYTHON SOURCE: src/lib/bindings.cpp (Plaintext class accessors)
//
// PlaintextImpl accessor surface.
//
// Binds the Get*/Set*/Is*/LowBound/HighBound methods from
// `temp/openfhe-rlibomp/include/openfhe/pke/encoding/plaintext.h`
// as individual cpp11 functions, each wrapped in catch_openfhe
// per design.md §5. 26 new bindings.
//
// Already bound elsewhere (in pke_bindings.cpp):
//   Plaintext__SetLength(pt_xp, len)
//   Plaintext__GetPackedValue(pt_xp)       [integer vector return]
//   Plaintext__GetRealPackedValue(pt_xp)   [double vector return]
//   Plaintext__ToString(pt_xp)             [used by print()]
//
// Deferred to later sub-releases:
//   GetCKKSPackedValue    - complex-plaintext path
//   GetElementModulus     - needs BigInteger wrapper, no audience
//   GetEncodingParams     - needs EncodingParams S7 class
//   Encode/Decode         - rarely called directly from user code;
//                           the factory methods call them internally
//
// Several base-class methods are declared `virtual` and throw
// `OPENFHE_THROW` in the base implementation (e.g. GetStringValue,
// GetLogPrecision, GetCoefPackedValue). The concrete plaintext
// subclass overrides the method for its own encoding type and the
// base-class throw is the fallback for "wrong kind of plaintext".
// catch_openfhe surfaces those throws as cpp11::stop conditions
// which the R wrapper catches and re-emits via cli::cli_abort.
#include "openfhe_cpp11.h"
#include "openfhe_helpers.h"

using namespace cpp11;

// Helper: Plaintext is stored as a shared_ptr<PlaintextImpl>. Every
// binding starts by dereferencing the external pointer to the
// shared_ptr. Pattern matches the existing Plaintext__* bindings in
// pke_bindings.cpp.

// ── Getters ─────────────────────────────────────────────

[[cpp11::register]]
int Plaintext__GetEncodingType(SEXP pt_xp) {
  external_pointer<Plaintext> p(pt_xp);
  return catch_openfhe("Plaintext::GetEncodingType", [&]() -> int {
    return static_cast<int>((*p)->GetEncodingType());
  });
}

[[cpp11::register]]
double Plaintext__GetScalingFactor(SEXP pt_xp) {
  external_pointer<Plaintext> p(pt_xp);
  return catch_openfhe("Plaintext::GetScalingFactor", [&]() -> double {
    return (*p)->GetScalingFactor();
  });
}

[[cpp11::register]]
double Plaintext__GetScalingFactorInt(SEXP pt_xp) {
  external_pointer<Plaintext> p(pt_xp);
  return catch_openfhe("Plaintext::GetScalingFactorInt", [&]() -> double {
    // NativeInteger -> double via ConvertToInt, matching the
    // BinFHEContext__GetMaxPlaintextSpace pattern in pke_bindings.cpp.
    return static_cast<double>((*p)->GetScalingFactorInt().ConvertToInt());
  });
}

[[cpp11::register]]
int Plaintext__GetSchemeID(SEXP pt_xp) {
  external_pointer<Plaintext> p(pt_xp);
  return catch_openfhe("Plaintext::GetSchemeID", [&]() -> int {
    return static_cast<int>((*p)->GetSchemeID());
  });
}

[[cpp11::register]]
bool Plaintext__IsEncoded(SEXP pt_xp) {
  external_pointer<Plaintext> p(pt_xp);
  return catch_openfhe("Plaintext::IsEncoded", [&]() -> bool {
    return (*p)->IsEncoded();
  });
}

[[cpp11::register]]
int Plaintext__GetCKKSDataType(SEXP pt_xp) {
  external_pointer<Plaintext> p(pt_xp);
  return catch_openfhe("Plaintext::GetCKKSDataType", [&]() -> int {
    return static_cast<int>((*p)->GetCKKSDataType());
  });
}

[[cpp11::register]]
int Plaintext__GetLength(SEXP pt_xp) {
  external_pointer<Plaintext> p(pt_xp);
  return catch_openfhe("Plaintext::GetLength", [&]() -> int {
    return static_cast<int>((*p)->GetLength());
  });
}

[[cpp11::register]]
int64_t Plaintext__LowBound(SEXP pt_xp) {
  external_pointer<Plaintext> p(pt_xp);
  return catch_openfhe("Plaintext::LowBound", [&]() -> int64_t {
    return (*p)->LowBound();
  });
}

[[cpp11::register]]
int64_t Plaintext__HighBound(SEXP pt_xp) {
  external_pointer<Plaintext> p(pt_xp);
  return catch_openfhe("Plaintext::HighBound", [&]() -> int64_t {
    return (*p)->HighBound();
  });
}

[[cpp11::register]]
int Plaintext__GetNoiseScaleDeg(SEXP pt_xp) {
  external_pointer<Plaintext> p(pt_xp);
  return catch_openfhe("Plaintext::GetNoiseScaleDeg", [&]() -> int {
    return static_cast<int>((*p)->GetNoiseScaleDeg());
  });
}

[[cpp11::register]]
int Plaintext__GetLevel(SEXP pt_xp) {
  external_pointer<Plaintext> p(pt_xp);
  return catch_openfhe("Plaintext::GetLevel", [&]() -> int {
    return static_cast<int>((*p)->GetLevel());
  });
}

[[cpp11::register]]
int Plaintext__GetSlots(SEXP pt_xp) {
  external_pointer<Plaintext> p(pt_xp);
  return catch_openfhe("Plaintext::GetSlots", [&]() -> int {
    return static_cast<int>((*p)->GetSlots());
  });
}

[[cpp11::register]]
double Plaintext__GetLogError(SEXP pt_xp) {
  external_pointer<Plaintext> p(pt_xp);
  return catch_openfhe("Plaintext::GetLogError", [&]() -> double {
    return (*p)->GetLogError();
  });
}

[[cpp11::register]]
double Plaintext__GetLogPrecision(SEXP pt_xp) {
  external_pointer<Plaintext> p(pt_xp);
  return catch_openfhe("Plaintext::GetLogPrecision", [&]() -> double {
    return (*p)->GetLogPrecision();
  });
}

[[cpp11::register]]
std::string Plaintext__GetFormattedValues(SEXP pt_xp, int64_t precision) {
  external_pointer<Plaintext> p(pt_xp);
  return catch_openfhe("Plaintext::GetFormattedValues", [&]() -> std::string {
    return (*p)->GetFormattedValues(precision);
  });
}

[[cpp11::register]]
cpp11::integers Plaintext__GetCoefPackedValue(SEXP pt_xp) {
  external_pointer<Plaintext> p(pt_xp);
  return catch_openfhe("Plaintext::GetCoefPackedValue", [&]() {
    const std::vector<int64_t>& v = (*p)->GetCoefPackedValue();
    writable::integers out(v.size());
    for (size_t i = 0; i < v.size(); i++) {
      out[i] = static_cast<int>(v[i]);
    }
    return out;
  });
}

[[cpp11::register]]
std::string Plaintext__GetStringValue(SEXP pt_xp) {
  external_pointer<Plaintext> p(pt_xp);
  return catch_openfhe("Plaintext::GetStringValue", [&]() -> std::string {
    return (*p)->GetStringValue();
  });
}

[[cpp11::register]]
int Plaintext__GetElementRingDimension(SEXP pt_xp) {
  external_pointer<Plaintext> p(pt_xp);
  return catch_openfhe("Plaintext::GetElementRingDimension", [&]() -> int {
    return static_cast<int>((*p)->GetElementRingDimension());
  });
}

// ── Setters ─────────────────────────────────────────────

[[cpp11::register]]
void Plaintext__SetScalingFactor(SEXP pt_xp, double sf) {
  external_pointer<Plaintext> p(pt_xp);
  catch_openfhe("Plaintext::SetScalingFactor", [&]() {
    (*p)->SetScalingFactor(sf);
  });
}

[[cpp11::register]]
void Plaintext__SetScalingFactorInt(SEXP pt_xp, int64_t sf) {
  external_pointer<Plaintext> p(pt_xp);
  catch_openfhe("Plaintext::SetScalingFactorInt", [&]() {
    (*p)->SetScalingFactorInt(NativeInteger(static_cast<uint64_t>(sf)));
  });
}

[[cpp11::register]]
void Plaintext__SetCKKSDataType(SEXP pt_xp, int cdt) {
  external_pointer<Plaintext> p(pt_xp);
  catch_openfhe("Plaintext::SetCKKSDataType", [&]() {
    (*p)->SetCKKSDataType(static_cast<CKKSDataType>(cdt));
  });
}

[[cpp11::register]]
void Plaintext__SetNoiseScaleDeg(SEXP pt_xp, int d) {
  external_pointer<Plaintext> p(pt_xp);
  catch_openfhe("Plaintext::SetNoiseScaleDeg", [&]() {
    (*p)->SetNoiseScaleDeg(static_cast<size_t>(d));
  });
}

[[cpp11::register]]
void Plaintext__SetLevel(SEXP pt_xp, int level) {
  external_pointer<Plaintext> p(pt_xp);
  catch_openfhe("Plaintext::SetLevel", [&]() {
    (*p)->SetLevel(static_cast<size_t>(level));
  });
}

[[cpp11::register]]
void Plaintext__SetSlots(SEXP pt_xp, int slots) {
  external_pointer<Plaintext> p(pt_xp);
  catch_openfhe("Plaintext::SetSlots", [&]() {
    (*p)->SetSlots(static_cast<uint32_t>(slots));
  });
}

[[cpp11::register]]
void Plaintext__SetStringValue(SEXP pt_xp, std::string value) {
  external_pointer<Plaintext> p(pt_xp);
  catch_openfhe("Plaintext::SetStringValue", [&]() {
    (*p)->SetStringValue(value);
  });
}

[[cpp11::register]]
void Plaintext__SetIntVectorValue(SEXP pt_xp, cpp11::integers value) {
  external_pointer<Plaintext> p(pt_xp);
  catch_openfhe("Plaintext::SetIntVectorValue", [&]() {
    std::vector<int64_t> v(value.size());
    for (R_xlen_t i = 0; i < value.size(); i++) {
      v[i] = static_cast<int64_t>(value[i]);
    }
    (*p)->SetIntVectorValue(v);
  });
}
