// OPENFHE PYTHON SOURCE: src/lib/bindings.cpp (object accessors bound at OpenFHE 1.6.1)
//
// Accessors of ParmType (ElementParams), EncodingParams, Ciphertext,
// Plaintext, the key classes and CryptoContext that openfhe-python
// 1.6.1.0 exposes and the package did not bind through 1.5.1.2.
//
// Every modulus and root of unity leaves as a decimal string
// (wide_integers.h). CryptoContext::GetModulus is exact here;
// openfhe-python returns ConvertToDouble() (upstream-defects P15).
#include "openfhe_cpp11.h"
#include "openfhe_helpers.h"
#include "wide_integers.h"

#include <memory>
#include <set>
#include <string>
#include <vector>

using namespace cpp11;

namespace {

using CT = Ciphertext<DCRTPoly>;
using ElementParamsSP = std::shared_ptr<DCRTPoly::Params>;
using EncodingParamsSP = std::shared_ptr<EncodingParamsImpl>;
using SchemeSP = std::shared_ptr<SchemeBase<DCRTPoly>>;

SEXP wrap_ct(const CT& ct) { return xptr<CT>(new CT(ct)); }
SEXP wrap_cc(const CryptoContext<DCRTPoly>& cc) {
  return xptr<CryptoContext<DCRTPoly>>(new CryptoContext<DCRTPoly>(cc));
}

std::set<uint32_t> index_set(const integers& v) {
  std::set<uint32_t> s;
  for (R_xlen_t i = 0; i < v.size(); ++i) s.insert(static_cast<uint32_t>(v[i]));
  return s;
}
writable::integers index_vector(const std::set<uint32_t>& s) {
  writable::integers out(static_cast<R_xlen_t>(s.size()));
  R_xlen_t i = 0;
  for (uint32_t x : s) out[i++] = static_cast<int>(x);
  return out;
}

std::shared_ptr<CryptoParametersRNS> rns_params(const CryptoContext<DCRTPoly>& cc,
                                                const char* func) {
  auto p = std::dynamic_pointer_cast<CryptoParametersRNS>(cc->GetCryptoParameters());
  if (!p) OPENFHE_THROW(std::string("Failed to cast to CryptoParametersRNS in ") + func + "()");
  return p;
}

}  // namespace

// ── ElementParams (Python: ParmType) ────────────────────

[[cpp11::register]]
int ElementParams__GetCyclotomicOrder(SEXP ep_xp) {
  xptr<ElementParamsSP> ep(ep_xp);
  return static_cast<int>((*ep)->GetCyclotomicOrder());
}

[[cpp11::register]]
int ElementParams__GetRingDimension(SEXP ep_xp) {
  xptr<ElementParamsSP> ep(ep_xp);
  return static_cast<int>((*ep)->GetRingDimension());
}

[[cpp11::register]]
std::string ElementParams__GetModulus(SEXP ep_xp) {
  xptr<ElementParamsSP> ep(ep_xp);
  return openfhe_r::wide_to_r((*ep)->GetModulus());
}

// ── EncodingParams ──────────────────────────────────────

[[cpp11::register]]
int EncodingParams__GetBatchSize(SEXP ep_xp) {
  xptr<EncodingParamsSP> ep(ep_xp);
  return static_cast<int>((*ep)->GetBatchSize());
}

[[cpp11::register]]
SEXP EncodingParams__GetPlaintextModulus(SEXP ep_xp) {
  xptr<EncodingParamsSP> ep(ep_xp);
  return openfhe_r::uint64_to_r((*ep)->GetPlaintextModulus());
}

[[cpp11::register]]
SEXP EncodingParams__GetPlaintextGenerator(SEXP ep_xp) {
  xptr<EncodingParamsSP> ep(ep_xp);
  return openfhe_r::uint64_to_r(static_cast<uint64_t>((*ep)->GetPlaintextGenerator()));
}

// ── CryptoContext ───────────────────────────────────────

// The composite ciphertext modulus Q, exactly.
[[cpp11::register]]
std::string CryptoContext__GetModulus(SEXP cc_xp) {
  xptr<CryptoContext<DCRTPoly>> cc(cc_xp);
  return catch_openfhe("CryptoContext::GetModulus", [&]() {
    return openfhe_r::wide_to_r(
        (*cc)->GetCryptoParameters()->GetElementParams()->GetModulus());
  });
}

// The first RNS modulus q_0 of a CKKS context.
[[cpp11::register]]
std::string CryptoContext__GetModulusCKKS(SEXP cc_xp) {
  xptr<CryptoContext<DCRTPoly>> cc(cc_xp);
  return catch_openfhe("CryptoContext::GetModulusCKKS", [&]() {
    auto p = std::dynamic_pointer_cast<CryptoParametersCKKSRNS>((*cc)->GetCryptoParameters());
    if (!p) OPENFHE_THROW("the context is not a CKKS context");
    return openfhe_r::wide_to_r(p->GetElementParams()->GetParams()[0]->GetModulus());
  });
}

[[cpp11::register]]
std::string CryptoContext__GetRootOfUnity(SEXP cc_xp) {
  xptr<CryptoContext<DCRTPoly>> cc(cc_xp);
  return catch_openfhe("CryptoContext::GetRootOfUnity", [&]() {
    return openfhe_r::wide_to_r((*cc)->GetRootOfUnity());
  });
}

[[cpp11::register]]
SEXP CryptoContext__GetScheme(SEXP cc_xp) {
  xptr<CryptoContext<DCRTPoly>> cc(cc_xp);
  return xptr<SchemeSP>(new SchemeSP((*cc)->GetScheme()));
}

[[cpp11::register]]
void CryptoContext__setSchemeId(SEXP cc_xp, int scheme_tag) {
  xptr<CryptoContext<DCRTPoly>> cc(cc_xp);
  (*cc)->setSchemeId(static_cast<SCHEME>(scheme_tag));
}

[[cpp11::register]]
std::string CryptoContext__SerializedObjectName(SEXP cc_xp) {
  xptr<CryptoContext<DCRTPoly>> cc(cc_xp);
  return (*cc)->SerializedObjectName();
}

[[cpp11::register]]
int CryptoContext__SerializedVersion() {
  return static_cast<int>(CryptoContextImpl<DCRTPoly>::SerializedVersion());
}

//   which: 0 ClearAllCKKSCaches, 1 ClearBootstrapPrecom,
//          2 ClearSchemeSwitchPrecom
[[cpp11::register]]
void CryptoContext__ClearCaches(SEXP cc_xp, int which) {
  xptr<CryptoContext<DCRTPoly>> cc(cc_xp);
  catch_openfhe("CryptoContext::Clear*", [&]() {
    switch (which) {
      case 0: (*cc)->ClearAllCKKSCaches(); return;
      case 1: (*cc)->ClearBootstrapPrecom(); return;
      case 2: (*cc)->ClearSchemeSwitchPrecom(); return;
    }
    cpp11::stop("unknown cache code %d", which);
  });
}

// Setters on the RNS crypto parameters of a context, as openfhe-python
// binds them (GetParamsRNSChecked).
//   field: 0 noise estimate (double), 1 multiplicative depth,
//          2 eval-add count, 3 key-switch count, 4 PRE hops
[[cpp11::register]]
void CryptoContext__SetRNS(SEXP cc_xp, int field, double value) {
  xptr<CryptoContext<DCRTPoly>> cc(cc_xp);
  catch_openfhe("CryptoContext::Set*", [&]() {
    const uint32_t u = static_cast<uint32_t>(value);
    switch (field) {
      case 0: rns_params(*cc, "SetNoiseEstimate")->SetNoiseEstimate(value); return;
      case 1: rns_params(*cc, "SetMultiplicativeDepth")->SetMultiplicativeDepth(u); return;
      case 2: rns_params(*cc, "SetEvalAddCount")->SetEvalAddCount(u); return;
      case 3: rns_params(*cc, "SetKeySwitchCount")->SetKeySwitchCount(u); return;
      case 4: rns_params(*cc, "SetPRENumHops")->SetPRENumHops(u); return;
    }
    cpp11::stop("unknown context parameter code %d", field);
  });
}

[[cpp11::register]]
SEXP CryptoContext__GetPlaintextForDecrypt(int encoding_type, SEXP ep_xp,
                                           SEXP encp_xp, int ckks_data_type) {
  xptr<ElementParamsSP> ep(ep_xp);
  xptr<EncodingParamsSP> encp(encp_xp);
  return catch_openfhe("CryptoContext::GetPlaintextForDecrypt", [&]() {
    Plaintext pt = CryptoContextImpl<DCRTPoly>::GetPlaintextForDecrypt(
        static_cast<PlaintextEncodings>(encoding_type), *ep, *encp,
        static_cast<CKKSDataType>(ckks_data_type));
    return xptr<Plaintext>(new Plaintext(pt));
  });
}

// ── Automorphism key indices ────────────────────────────

[[cpp11::register]]
integers CryptoContext__GetUniqueValues(integers old_values, integers new_values) {
  return index_vector(CryptoContextImpl<DCRTPoly>::GetUniqueValues(
      index_set(old_values), index_set(new_values)));
}

[[cpp11::register]]
integers CryptoContext__GetExistingEvalAutomorphismKeyIndices(std::string key_tag) {
  return catch_openfhe("CryptoContext::GetExistingEvalAutomorphismKeyIndices", [&]() {
    return index_vector(
        CryptoContextImpl<DCRTPoly>::GetExistingEvalAutomorphismKeyIndices(key_tag));
  });
}

[[cpp11::register]]
integers CryptoContext__GetEvalAutomorphismNoKeyIndices(std::string key_tag,
                                                        integers indices) {
  return catch_openfhe("CryptoContext::GetEvalAutomorphismNoKeyIndices", [&]() {
    return index_vector(CryptoContextImpl<DCRTPoly>::GetEvalAutomorphismNoKeyIndices(
        key_tag, index_set(indices)));
  });
}

// ── Keys ────────────────────────────────────────────────

[[cpp11::register]]
std::string EvalKey__GetKeyTag(SEXP ek_xp) {
  xptr<EvalKey<DCRTPoly>> ek(ek_xp);
  if (!*ek) cpp11::stop("the <EvalKey> is empty");
  return (*ek)->GetKeyTag();
}

[[cpp11::register]]
void EvalKey__SetKeyTag(SEXP ek_xp, std::string tag) {
  xptr<EvalKey<DCRTPoly>> ek(ek_xp);
  if (!*ek) cpp11::stop("the <EvalKey> is empty");
  (*ek)->SetKeyTag(tag);
}

[[cpp11::register]]
SEXP PublicKey__GetCryptoContext(SEXP pk_xp) {
  xptr<PublicKey<DCRTPoly>> pk(pk_xp);
  return wrap_cc((*pk)->GetCryptoContext());
}

[[cpp11::register]]
SEXP PrivateKey__GetCryptoContext(SEXP sk_xp) {
  xptr<PrivateKey<DCRTPoly>> sk(sk_xp);
  return wrap_cc((*sk)->GetCryptoContext());
}

// ── Ciphertext ──────────────────────────────────────────

[[cpp11::register]]
SEXP Ciphertext__Clone(SEXP ct_xp, bool empty) {
  xptr<CT> ct(ct_xp);
  return catch_openfhe("Ciphertext::Clone", [&]() {
    return wrap_ct(empty ? (*ct)->CloneEmpty() : (*ct)->Clone());
  });
}

[[cpp11::register]]
int Ciphertext__NumberCiphertextElements(SEXP ct_xp) {
  xptr<CT> ct(ct_xp);
  return static_cast<int>((*ct)->NumberCiphertextElements());
}

// Zero-based index, as in C++ and Python; the R wrapper converts.
[[cpp11::register]]
void Ciphertext__RemoveElement(SEXP ct_xp, int index) {
  xptr<CT> ct(ct_xp);
  auto& elems = (*ct)->GetElements();
  if (index < 0 || static_cast<size_t>(index) >= elems.size()) {
    cpp11::stop("element index out of range: the ciphertext has %d element(s)",
                static_cast<int>(elems.size()));
  }
  elems.erase(elems.begin() + index);
}

[[cpp11::register]]
int Ciphertext__GetHopLevel(SEXP ct_xp) {
  xptr<CT> ct(ct_xp);
  return static_cast<int>((*ct)->GetHopLevel());
}

[[cpp11::register]]
void Ciphertext__SetHopLevel(SEXP ct_xp, int hop_level) {
  xptr<CT> ct(ct_xp);
  (*ct)->SetHopLevel(static_cast<size_t>(hop_level));
}

[[cpp11::register]]
void Ciphertext__SetEncodingType(SEXP ct_xp, int encoding_type) {
  xptr<CT> ct(ct_xp);
  (*ct)->SetEncodingType(static_cast<PlaintextEncodings>(encoding_type));
}

// Copies of the ring elements, one handle each.
[[cpp11::register]]
list Ciphertext__GetElements(SEXP ct_xp) {
  xptr<CT> ct(ct_xp);
  const auto& elems = (*ct)->GetElements();
  writable::list out(static_cast<R_xlen_t>(elems.size()));
  for (size_t i = 0; i < elems.size(); ++i) {
    out[static_cast<R_xlen_t>(i)] = xptr<DCRTPoly>(new DCRTPoly(elems[i]));
  }
  return out;
}

[[cpp11::register]]
void Ciphertext__SetElements(SEXP ct_xp, list elements) {
  xptr<CT> ct(ct_xp);
  std::vector<DCRTPoly> v;
  v.reserve(elements.size());
  for (R_xlen_t i = 0; i < elements.size(); ++i) {
    SEXP xp = elements[i];
    xptr<DCRTPoly> e(xp);
    v.push_back(*e);
  }
  catch_openfhe("Ciphertext::SetElements", [&]() {
    (*ct)->SetElements(std::move(v));
  });
}

// ── Plaintext ───────────────────────────────────────────

[[cpp11::register]]
bool Plaintext__Encode(SEXP pt_xp) {
  xptr<Plaintext> pt(pt_xp);
  return catch_openfhe("Plaintext::Encode", [&]() { return (*pt)->Encode(); });
}

[[cpp11::register]]
bool Plaintext__Decode(SEXP pt_xp) {
  xptr<Plaintext> pt(pt_xp);
  return catch_openfhe("Plaintext::Decode", [&]() { return (*pt)->Decode(); });
}

// The CKKS form, which takes what the decoder needs to know about the
// ciphertext the plaintext came from.
[[cpp11::register]]
bool Plaintext__Decode__ckks(SEXP pt_xp, int depth, double scaling_factor,
                             int scal_tech, int execution_mode) {
  xptr<Plaintext> pt(pt_xp);
  return catch_openfhe("Plaintext::Decode(depth, scalingFactor, scalTech, executionMode)", [&]() {
    return (*pt)->Decode(static_cast<size_t>(depth), scaling_factor,
                         static_cast<ScalingTechnique>(scal_tech),
                         static_cast<ExecutionMode>(execution_mode));
  });
}

[[cpp11::register]]
std::string Plaintext__GetElementModulus(SEXP pt_xp) {
  xptr<Plaintext> pt(pt_xp);
  return catch_openfhe("Plaintext::GetElementModulus", [&]() {
    return openfhe_r::wide_to_r((*pt)->GetElementModulus());
  });
}

[[cpp11::register]]
SEXP Plaintext__GetEncodingParams(SEXP pt_xp) {
  xptr<Plaintext> pt(pt_xp);
  return xptr<EncodingParamsSP>(new EncodingParamsSP((*pt)->GetEncodingParams()));
}

[[cpp11::register]]
void Plaintext__SetFormat(SEXP pt_xp, int format) {
  xptr<Plaintext> pt(pt_xp);
  catch_openfhe("Plaintext::SetFormat", [&]() {
    (*pt)->SetFormat(static_cast<Format>(format));
  });
}
