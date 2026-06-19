// OPENFHE PYTHON SOURCE: src/lib/bindings.cpp
// Phase 1: BFV params, context, keygen, encrypt, decrypt
#include "openfhe_cpp11.h"

using namespace cpp11;

// ── Self-contained test (no R objects) ──────────────────

[[cpp11::register]]
bool selftest_bfv() {
  CCParams<CryptoContextBFVRNS> params;
  params.SetPlaintextModulus(65537);
  params.SetMultiplicativeDepth(2);

  CryptoContext<DCRTPoly> cc = GenCryptoContext(params);
  cc->Enable(PKESchemeFeature::PKE);
  cc->Enable(PKESchemeFeature::KEYSWITCH);
  cc->Enable(PKESchemeFeature::LEVELEDSHE);

  auto kp = cc->KeyGen();
  if (!kp.good()) return false;

  std::vector<int64_t> vals = {1, 2, 3, 4, 5, 6, 7, 8};
  Plaintext pt = cc->MakePackedPlaintext(vals);
  auto ct = cc->Encrypt(kp.publicKey, pt);

  Plaintext result;
  cc->Decrypt(kp.secretKey, ct, &result);
  result->SetLength(8);

  auto& dec = result->GetPackedValue();
  for (size_t i = 0; i < 8; i++) {
    if (dec[i] != vals[i]) return false;
  }
  return true;
}

// ── BFV Parameters ──────────────────────────────────────

[[cpp11::register]]
SEXP BFVParams__new() {
  return external_pointer<CCParams<CryptoContextBFVRNS>>(
    new CCParams<CryptoContextBFVRNS>());
}

[[cpp11::register]]
void BFVParams__SetPlaintextModulus(SEXP params_xp, int64_t value) {
  external_pointer<CCParams<CryptoContextBFVRNS>> p(params_xp);
  p->SetPlaintextModulus(static_cast<PlaintextModulus>(value));
}

[[cpp11::register]]
void BFVParams__SetMultiplicativeDepth(SEXP params_xp, int depth) {
  external_pointer<CCParams<CryptoContextBFVRNS>> p(params_xp);
  p->SetMultiplicativeDepth(static_cast<uint32_t>(depth));
}

[[cpp11::register]]
void BFVParams__SetSecurityLevel(SEXP params_xp, int level) {
  external_pointer<CCParams<CryptoContextBFVRNS>> p(params_xp);
  p->SetSecurityLevel(static_cast<SecurityLevel>(level));
}

[[cpp11::register]]
void BFVParams__SetBatchSize(SEXP params_xp, int size) {
  external_pointer<CCParams<CryptoContextBFVRNS>> p(params_xp);
  p->SetBatchSize(static_cast<uint32_t>(size));
}

[[cpp11::register]]
void BFVParams__SetRingDim(SEXP params_xp, int dim) {
  external_pointer<CCParams<CryptoContextBFVRNS>> p(params_xp);
  p->SetRingDim(static_cast<uint32_t>(dim));
}

// ── CryptoContext ───────────────────────────────────────

[[cpp11::register]]
SEXP GenCryptoContext__BFV(SEXP params_xp) {
  external_pointer<CCParams<CryptoContextBFVRNS>> p(params_xp);
  CryptoContext<DCRTPoly> cc = GenCryptoContext(*p);
  // CryptoContext is already shared_ptr<CryptoContextImpl<DCRTPoly>>
  // Store a heap copy of the shared_ptr
  return external_pointer<CryptoContext<DCRTPoly>>(
    new CryptoContext<DCRTPoly>(cc));
}

[[cpp11::register]]
void CryptoContext__Enable(SEXP cc_xp, int feature) {
  external_pointer<CryptoContext<DCRTPoly>> cc(cc_xp);
  (*cc)->Enable(static_cast<PKESchemeFeature>(feature));
}

[[cpp11::register]]
int CryptoContext__GetRingDimension(SEXP cc_xp) {
  external_pointer<CryptoContext<DCRTPoly>> cc(cc_xp);
  return static_cast<int>((*cc)->GetRingDimension());
}

// ── Key Generation ──────────────────────────────────────

[[cpp11::register]]
list CryptoContext__KeyGen(SEXP cc_xp) {
  external_pointer<CryptoContext<DCRTPoly>> cc(cc_xp);
  auto kp = (*cc)->KeyGen();

  writable::list result(2);
  result[0] = external_pointer<PublicKey<DCRTPoly>>(
    new PublicKey<DCRTPoly>(kp.publicKey));
  result[1] = external_pointer<PrivateKey<DCRTPoly>>(
    new PrivateKey<DCRTPoly>(kp.secretKey));

  result.attr("names") = writable::strings({"public", "secret"});
  return result;
}

[[cpp11::register]]
void CryptoContext__EvalMultKeyGen(SEXP cc_xp, SEXP sk_xp) {
  external_pointer<CryptoContext<DCRTPoly>> cc(cc_xp);
  external_pointer<PrivateKey<DCRTPoly>> sk(sk_xp);
  (*cc)->EvalMultKeyGen(*sk);
}

[[cpp11::register]]
void CryptoContext__EvalRotateKeyGen(SEXP cc_xp, SEXP sk_xp, integers indices) {
  external_pointer<CryptoContext<DCRTPoly>> cc(cc_xp);
  external_pointer<PrivateKey<DCRTPoly>> sk(sk_xp);
  std::vector<int32_t> idx_vec;
  for (R_xlen_t i = 0; i < indices.size(); i++) {
    idx_vec.push_back(indices[i]);
  }
  (*cc)->EvalRotateKeyGen(*sk, idx_vec);
}

// EvalAtIndexKeyGen is the underlying primitive that
// EvalRotateKeyGen forwards to verbatim (see cryptocontext.h
// line 2463). Both names are kept for surface parity with the
// C++ header and openfhe-python, which binds them separately.
[[cpp11::register]]
void CryptoContext__EvalAtIndexKeyGen(SEXP cc_xp, SEXP sk_xp, integers indices) {
  external_pointer<CryptoContext<DCRTPoly>> cc(cc_xp);
  external_pointer<PrivateKey<DCRTPoly>> sk(sk_xp);
  std::vector<int32_t> idx_vec;
  for (R_xlen_t i = 0; i < indices.size(); i++) {
    idx_vec.push_back(indices[i]);
  }
  (*cc)->EvalAtIndexKeyGen(*sk, idx_vec);
}

// ── Plaintext ───────────────────────────────────────────

[[cpp11::register]]
SEXP CryptoContext__MakePackedPlaintext(SEXP cc_xp, integers values,
                                         int noise_scale_deg,
                                         int level) {
  external_pointer<CryptoContext<DCRTPoly>> cc(cc_xp);
  std::vector<int64_t> vec;
  vec.reserve(values.size());
  for (R_xlen_t i = 0; i < values.size(); i++) {
    vec.push_back(static_cast<int64_t>(values[i]));
  }
  Plaintext pt = (*cc)->MakePackedPlaintext(
      vec,
      static_cast<size_t>(noise_scale_deg),
      static_cast<uint32_t>(level));
  return external_pointer<Plaintext>(new Plaintext(pt));
}

[[cpp11::register]]
integers Plaintext__GetPackedValue(SEXP pt_xp) {
  external_pointer<Plaintext> pt(pt_xp);
  auto& vals = (*pt)->GetPackedValue();
  writable::integers result(vals.size());
  for (size_t i = 0; i < vals.size(); i++) {
    result[i] = static_cast<int>(vals[i]);
  }
  return result;
}

[[cpp11::register]]
void Plaintext__SetLength(SEXP pt_xp, int len) {
  external_pointer<Plaintext> pt(pt_xp);
  (*pt)->SetLength(static_cast<size_t>(len));
}

[[cpp11::register]]
std::string Plaintext__ToString(SEXP pt_xp) {
  external_pointer<Plaintext> pt(pt_xp);
  std::stringstream ss;
  ss << **pt;
  return ss.str();
}

// ── Encrypt / Decrypt ───────────────────────────────────

[[cpp11::register]]
SEXP CryptoContext__Encrypt_PublicKey(SEXP cc_xp, SEXP pk_xp, SEXP pt_xp) {
  external_pointer<CryptoContext<DCRTPoly>> cc(cc_xp);
  external_pointer<PublicKey<DCRTPoly>> pk(pk_xp);
  external_pointer<Plaintext> pt(pt_xp);
  auto ct = (*cc)->Encrypt(*pk, *pt);
  return external_pointer<Ciphertext<DCRTPoly>>(
    new Ciphertext<DCRTPoly>(ct));
}

[[cpp11::register]]
SEXP CryptoContext__Decrypt(SEXP cc_xp, SEXP sk_xp, SEXP ct_xp) {
  external_pointer<CryptoContext<DCRTPoly>> cc(cc_xp);
  external_pointer<PrivateKey<DCRTPoly>> sk(sk_xp);
  external_pointer<Ciphertext<DCRTPoly>> ct(ct_xp);
  Plaintext result;
  (*cc)->Decrypt(*sk, *ct, &result);
  return external_pointer<Plaintext>(new Plaintext(result));
}

// ── Get CryptoContext from Ciphertext ───────────────────

[[cpp11::register]]
SEXP Ciphertext__GetCryptoContext(SEXP ct_xp) {
  external_pointer<Ciphertext<DCRTPoly>> ct(ct_xp);
  auto cc = (*ct)->GetCryptoContext();
  return external_pointer<CryptoContext<DCRTPoly>>(
    new CryptoContext<DCRTPoly>(cc));
}

// ── Homomorphic Arithmetic ──────────────────────────────

// ct + ct
[[cpp11::register]]
SEXP EvalAdd__ct_ct(SEXP ct1_xp, SEXP ct2_xp) {
  external_pointer<Ciphertext<DCRTPoly>> ct1(ct1_xp);
  external_pointer<Ciphertext<DCRTPoly>> ct2(ct2_xp);
  auto cc = (*ct1)->GetCryptoContext();
  auto result = cc->EvalAdd(*ct1, *ct2);
  return external_pointer<Ciphertext<DCRTPoly>>(
    new Ciphertext<DCRTPoly>(result));
}

// ct + pt
[[cpp11::register]]
SEXP EvalAdd__ct_pt(SEXP ct_xp, SEXP pt_xp) {
  external_pointer<Ciphertext<DCRTPoly>> ct(ct_xp);
  external_pointer<Plaintext> pt(pt_xp);
  auto cc = (*ct)->GetCryptoContext();
  auto result = cc->EvalAdd(*ct, *pt);
  return external_pointer<Ciphertext<DCRTPoly>>(
    new Ciphertext<DCRTPoly>(result));
}

// ct + scalar (double — works for CKKS; for BFV/BGV use ct_pt overload)
[[cpp11::register]]
SEXP EvalAdd__ct_scalar(SEXP ct_xp, double scalar) {
  external_pointer<Ciphertext<DCRTPoly>> ct(ct_xp);
  auto cc = (*ct)->GetCryptoContext();
  auto result = cc->EvalAdd(*ct, scalar);
  return external_pointer<Ciphertext<DCRTPoly>>(
    new Ciphertext<DCRTPoly>(result));
}

// ct + integer (create constant packed plaintext, then add)
[[cpp11::register]]
SEXP EvalAdd__ct_int(SEXP ct_xp, int scalar) {
  external_pointer<Ciphertext<DCRTPoly>> ct(ct_xp);
  auto cc = (*ct)->GetCryptoContext();
  auto n = cc->GetRingDimension();
  std::vector<int64_t> vec(n, static_cast<int64_t>(scalar));
  Plaintext pt = cc->MakePackedPlaintext(vec);
  auto result = cc->EvalAdd(*ct, pt);
  return external_pointer<Ciphertext<DCRTPoly>>(
    new Ciphertext<DCRTPoly>(result));
}

// ct - ct
[[cpp11::register]]
SEXP EvalSub__ct_ct(SEXP ct1_xp, SEXP ct2_xp) {
  external_pointer<Ciphertext<DCRTPoly>> ct1(ct1_xp);
  external_pointer<Ciphertext<DCRTPoly>> ct2(ct2_xp);
  auto cc = (*ct1)->GetCryptoContext();
  auto result = cc->EvalSub(*ct1, *ct2);
  return external_pointer<Ciphertext<DCRTPoly>>(
    new Ciphertext<DCRTPoly>(result));
}

// ct - scalar (double)
[[cpp11::register]]
SEXP EvalSub__ct_scalar(SEXP ct_xp, double scalar) {
  external_pointer<Ciphertext<DCRTPoly>> ct(ct_xp);
  auto cc = (*ct)->GetCryptoContext();
  auto result = cc->EvalSub(*ct, scalar);
  return external_pointer<Ciphertext<DCRTPoly>>(
    new Ciphertext<DCRTPoly>(result));
}

// ct - integer
[[cpp11::register]]
SEXP EvalSub__ct_int(SEXP ct_xp, int scalar) {
  external_pointer<Ciphertext<DCRTPoly>> ct(ct_xp);
  auto cc = (*ct)->GetCryptoContext();
  auto n = cc->GetRingDimension();
  std::vector<int64_t> vec(n, static_cast<int64_t>(scalar));
  Plaintext pt = cc->MakePackedPlaintext(vec);
  auto result = cc->EvalSub(*ct, pt);
  return external_pointer<Ciphertext<DCRTPoly>>(
    new Ciphertext<DCRTPoly>(result));
}

// ct - pt
[[cpp11::register]]
SEXP EvalSub__ct_pt(SEXP ct_xp, SEXP pt_xp) {
  external_pointer<Ciphertext<DCRTPoly>> ct(ct_xp);
  external_pointer<Plaintext> pt(pt_xp);
  auto cc = (*ct)->GetCryptoContext();
  auto result = cc->EvalSub(*ct, *pt);
  return external_pointer<Ciphertext<DCRTPoly>>(
    new Ciphertext<DCRTPoly>(result));
}

// ct * ct
[[cpp11::register]]
SEXP EvalMult__ct_ct(SEXP ct1_xp, SEXP ct2_xp) {
  external_pointer<Ciphertext<DCRTPoly>> ct1(ct1_xp);
  external_pointer<Ciphertext<DCRTPoly>> ct2(ct2_xp);
  auto cc = (*ct1)->GetCryptoContext();
  auto result = cc->EvalMult(*ct1, *ct2);
  return external_pointer<Ciphertext<DCRTPoly>>(
    new Ciphertext<DCRTPoly>(result));
}

// ct * scalar (double)
[[cpp11::register]]
SEXP EvalMult__ct_scalar(SEXP ct_xp, double scalar) {
  external_pointer<Ciphertext<DCRTPoly>> ct(ct_xp);
  auto cc = (*ct)->GetCryptoContext();
  auto result = cc->EvalMult(*ct, scalar);
  return external_pointer<Ciphertext<DCRTPoly>>(
    new Ciphertext<DCRTPoly>(result));
}

// ct * pt
[[cpp11::register]]
SEXP EvalMult__ct_pt(SEXP ct_xp, SEXP pt_xp) {
  external_pointer<Ciphertext<DCRTPoly>> ct(ct_xp);
  external_pointer<Plaintext> pt(pt_xp);
  auto cc = (*ct)->GetCryptoContext();
  auto result = cc->EvalMult(*ct, *pt);
  return external_pointer<Ciphertext<DCRTPoly>>(
    new Ciphertext<DCRTPoly>(result));
}

// ct * integer
[[cpp11::register]]
SEXP EvalMult__ct_int(SEXP ct_xp, int scalar) {
  external_pointer<Ciphertext<DCRTPoly>> ct(ct_xp);
  auto cc = (*ct)->GetCryptoContext();
  auto n = cc->GetRingDimension();
  std::vector<int64_t> vec(n, static_cast<int64_t>(scalar));
  Plaintext pt = cc->MakePackedPlaintext(vec);
  auto result = cc->EvalMult(*ct, pt);
  return external_pointer<Ciphertext<DCRTPoly>>(
    new Ciphertext<DCRTPoly>(result));
}

// -ct
[[cpp11::register]]
SEXP EvalNegate(SEXP ct_xp) {
  external_pointer<Ciphertext<DCRTPoly>> ct(ct_xp);
  auto cc = (*ct)->GetCryptoContext();
  auto result = cc->EvalNegate(*ct);
  return external_pointer<Ciphertext<DCRTPoly>>(
    new Ciphertext<DCRTPoly>(result));
}

// ct * ct (square)
[[cpp11::register]]
SEXP EvalSquare(SEXP ct_xp) {
  external_pointer<Ciphertext<DCRTPoly>> ct(ct_xp);
  auto cc = (*ct)->GetCryptoContext();
  auto result = cc->EvalSquare(*ct);
  return external_pointer<Ciphertext<DCRTPoly>>(
    new Ciphertext<DCRTPoly>(result));
}

// ── Rotation / Reduction ────────────────────────────────

[[cpp11::register]]
SEXP EvalRotate(SEXP ct_xp, int index) {
  external_pointer<Ciphertext<DCRTPoly>> ct(ct_xp);
  auto cc = (*ct)->GetCryptoContext();
  auto result = cc->EvalRotate(*ct, index);
  return external_pointer<Ciphertext<DCRTPoly>>(
    new Ciphertext<DCRTPoly>(result));
}

[[cpp11::register]]
SEXP EvalSum(SEXP ct_xp, int batch_size) {
  external_pointer<Ciphertext<DCRTPoly>> ct(ct_xp);
  auto cc = (*ct)->GetCryptoContext();
  auto result = cc->EvalSum(*ct, static_cast<uint32_t>(batch_size));
  return external_pointer<Ciphertext<DCRTPoly>>(
    new Ciphertext<DCRTPoly>(result));
}

[[cpp11::register]]
SEXP Rescale(SEXP ct_xp) {
  external_pointer<Ciphertext<DCRTPoly>> ct(ct_xp);
  auto cc = (*ct)->GetCryptoContext();
  auto result = cc->Rescale(*ct);
  return external_pointer<Ciphertext<DCRTPoly>>(
    new Ciphertext<DCRTPoly>(result));
}

// EvalFastRotationPrecompute returns a shared_ptr<vector<DCRTPoly>>
// (the digit decomposition reused across multiple EvalFastRotation
// calls). We wrap the heap-allocated shared_ptr in an external_pointer
// so the R side can hold and pass it.
using FastRotationPrecomp = std::shared_ptr<std::vector<DCRTPoly>>;

[[cpp11::register]]
SEXP EvalFastRotationPrecompute(SEXP ct_xp) {
  external_pointer<Ciphertext<DCRTPoly>> ct(ct_xp);
  auto cc = (*ct)->GetCryptoContext();
  FastRotationPrecomp precomp = cc->EvalFastRotationPrecompute(*ct);
  return external_pointer<FastRotationPrecomp>(
    new FastRotationPrecomp(precomp));
}

[[cpp11::register]]
SEXP EvalFastRotation(SEXP ct_xp, int index, double m, SEXP precomp_xp) {
  external_pointer<Ciphertext<DCRTPoly>> ct(ct_xp);
  external_pointer<FastRotationPrecomp> precomp(precomp_xp);
  auto cc = (*ct)->GetCryptoContext();
  auto result = cc->EvalFastRotation(*ct,
    static_cast<uint32_t>(index),
    static_cast<uint32_t>(m),
    *precomp);
  return external_pointer<Ciphertext<DCRTPoly>>(
    new Ciphertext<DCRTPoly>(result));
}

// ── BGV Parameters ──────────────────────────────────────

[[cpp11::register]]
SEXP BGVParams__new() {
  return external_pointer<CCParams<CryptoContextBGVRNS>>(
    new CCParams<CryptoContextBGVRNS>());
}

[[cpp11::register]]
void BGVParams__SetPlaintextModulus(SEXP params_xp, int64_t value) {
  external_pointer<CCParams<CryptoContextBGVRNS>> p(params_xp);
  p->SetPlaintextModulus(static_cast<PlaintextModulus>(value));
}

[[cpp11::register]]
void BGVParams__SetMultiplicativeDepth(SEXP params_xp, int depth) {
  external_pointer<CCParams<CryptoContextBGVRNS>> p(params_xp);
  p->SetMultiplicativeDepth(static_cast<uint32_t>(depth));
}

[[cpp11::register]]
SEXP GenCryptoContext__BGV(SEXP params_xp) {
  external_pointer<CCParams<CryptoContextBGVRNS>> p(params_xp);
  CryptoContext<DCRTPoly> cc = GenCryptoContext(*p);
  return external_pointer<CryptoContext<DCRTPoly>>(
    new CryptoContext<DCRTPoly>(cc));
}

// ── CKKS Parameters ─────────────────────────────────────

[[cpp11::register]]
SEXP CKKSParams__new() {
  return external_pointer<CCParams<CryptoContextCKKSRNS>>(
    new CCParams<CryptoContextCKKSRNS>());
}

[[cpp11::register]]
void CKKSParams__SetMultiplicativeDepth(SEXP params_xp, int depth) {
  external_pointer<CCParams<CryptoContextCKKSRNS>> p(params_xp);
  p->SetMultiplicativeDepth(static_cast<uint32_t>(depth));
}

[[cpp11::register]]
void CKKSParams__SetScalingModSize(SEXP params_xp, int size) {
  external_pointer<CCParams<CryptoContextCKKSRNS>> p(params_xp);
  p->SetScalingModSize(static_cast<uint32_t>(size));
}

[[cpp11::register]]
void CKKSParams__SetBatchSize(SEXP params_xp, int size) {
  external_pointer<CCParams<CryptoContextCKKSRNS>> p(params_xp);
  p->SetBatchSize(static_cast<uint32_t>(size));
}

[[cpp11::register]]
void CKKSParams__SetRingDim(SEXP params_xp, int dim) {
  external_pointer<CCParams<CryptoContextCKKSRNS>> p(params_xp);
  p->SetRingDim(static_cast<uint32_t>(dim));
}

[[cpp11::register]]
void CKKSParams__SetSecurityLevel(SEXP params_xp, int level) {
  external_pointer<CCParams<CryptoContextCKKSRNS>> p(params_xp);
  p->SetSecurityLevel(static_cast<SecurityLevel>(level));
}

[[cpp11::register]]
void CKKSParams__SetScalingTechnique(SEXP params_xp, int tech) {
  external_pointer<CCParams<CryptoContextCKKSRNS>> p(params_xp);
  p->SetScalingTechnique(static_cast<ScalingTechnique>(tech));
}

[[cpp11::register]]
void CKKSParams__SetFirstModSize(SEXP params_xp, int size) {
  external_pointer<CCParams<CryptoContextCKKSRNS>> p(params_xp);
  p->SetFirstModSize(static_cast<uint32_t>(size));
}

[[cpp11::register]]
void CKKSParams__SetNumLargeDigits(SEXP params_xp, int dnum) {
  external_pointer<CCParams<CryptoContextCKKSRNS>> p(params_xp);
  p->SetNumLargeDigits(static_cast<uint32_t>(dnum));
}

[[cpp11::register]]
void CKKSParams__SetKeySwitchTechnique(SEXP params_xp, int tech) {
  external_pointer<CCParams<CryptoContextCKKSRNS>> p(params_xp);
  p->SetKeySwitchTechnique(static_cast<KeySwitchTechnique>(tech));
}

[[cpp11::register]]
void CKKSParams__SetDigitSize(SEXP params_xp, int size) {
  external_pointer<CCParams<CryptoContextCKKSRNS>> p(params_xp);
  p->SetDigitSize(static_cast<uint32_t>(size));
}

[[cpp11::register]]
SEXP GenCryptoContext__CKKS(SEXP params_xp) {
  external_pointer<CCParams<CryptoContextCKKSRNS>> p(params_xp);
  CryptoContext<DCRTPoly> cc = GenCryptoContext(*p);
  return external_pointer<CryptoContext<DCRTPoly>>(
    new CryptoContext<DCRTPoly>(cc));
}

// ── CKKS Plaintext ──────────────────────────────────────

[[cpp11::register]]
SEXP CryptoContext__MakeCKKSPackedPlaintext(SEXP cc_xp, doubles values,
                                             int noise_scale_deg,
                                             int level,
                                             SEXP params_xp,
                                             int slots) {
  external_pointer<CryptoContext<DCRTPoly>> cc(cc_xp);
  std::vector<double> vec;
  vec.reserve(values.size());
  for (R_xlen_t i = 0; i < values.size(); i++) {
    vec.push_back(values[i]);
  }
  // params_xp == R_NilValue -> nullptr (context default).
  // Non-null ElementParams construction is provided by
  // get_element_params(cc); otherwise the only legal R-side
  // value for params_xp is NULL.
  std::shared_ptr<typename DCRTPoly::Params> params_ptr = nullptr;
  if (params_xp != R_NilValue) {
    external_pointer<std::shared_ptr<typename DCRTPoly::Params>> ep(params_xp);
    params_ptr = *ep;
  }
  Plaintext pt = (*cc)->MakeCKKSPackedPlaintext(
      vec,
      static_cast<size_t>(noise_scale_deg),
      static_cast<uint32_t>(level),
      params_ptr,
      static_cast<uint32_t>(slots));
  return external_pointer<Plaintext>(new Plaintext(pt));
}

[[cpp11::register]]
SEXP CryptoContext__MakeCoefPackedPlaintext(SEXP cc_xp, integers values,
                                             int noise_scale_deg,
                                             int level) {
  external_pointer<CryptoContext<DCRTPoly>> cc(cc_xp);
  std::vector<int64_t> vec;
  vec.reserve(values.size());
  for (R_xlen_t i = 0; i < values.size(); i++) {
    vec.push_back(static_cast<int64_t>(values[i]));
  }
  Plaintext pt = (*cc)->MakeCoefPackedPlaintext(
      vec,
      static_cast<size_t>(noise_scale_deg),
      static_cast<uint32_t>(level));
  return external_pointer<Plaintext>(new Plaintext(pt));
}

[[cpp11::register]]
doubles Plaintext__GetRealPackedValue(SEXP pt_xp) {
  external_pointer<Plaintext> pt(pt_xp);
  auto vals = (*pt)->GetRealPackedValue();
  writable::doubles result(vals.size());
  for (size_t i = 0; i < vals.size(); i++) {
    result[i] = vals[i];
  }
  return result;
}

// ── CKKS Polynomial / Chebyshev evaluation ──────────────

[[cpp11::register]]
SEXP EvalPoly(SEXP ct_xp, doubles coefficients) {
  external_pointer<Ciphertext<DCRTPoly>> ct(ct_xp);
  auto cc = (*ct)->GetCryptoContext();
  std::vector<double> coeffs;
  coeffs.reserve(coefficients.size());
  for (R_xlen_t i = 0; i < coefficients.size(); i++)
    coeffs.push_back(coefficients[i]);
  auto result = cc->EvalPoly(*ct, coeffs);
  return external_pointer<Ciphertext<DCRTPoly>>(
    new Ciphertext<DCRTPoly>(result));
}

[[cpp11::register]]
SEXP EvalChebyshevSeries(SEXP ct_xp, doubles coefficients, double a, double b) {
  external_pointer<Ciphertext<DCRTPoly>> ct(ct_xp);
  auto cc = (*ct)->GetCryptoContext();
  std::vector<double> coeffs;
  coeffs.reserve(coefficients.size());
  for (R_xlen_t i = 0; i < coefficients.size(); i++)
    coeffs.push_back(coefficients[i]);
  auto result = cc->EvalChebyshevSeries(*ct, coeffs, a, b);
  return external_pointer<Ciphertext<DCRTPoly>>(
    new Ciphertext<DCRTPoly>(result));
}

// ── CKKS Transcendental functions ───────────────────────

[[cpp11::register]]
SEXP EvalSin_(SEXP ct_xp, double a, double b, int degree) {
  external_pointer<Ciphertext<DCRTPoly>> ct(ct_xp);
  auto cc = (*ct)->GetCryptoContext();
  auto result = cc->EvalSin(*ct, a, b, static_cast<uint32_t>(degree));
  return external_pointer<Ciphertext<DCRTPoly>>(
    new Ciphertext<DCRTPoly>(result));
}

[[cpp11::register]]
SEXP EvalCos_(SEXP ct_xp, double a, double b, int degree) {
  external_pointer<Ciphertext<DCRTPoly>> ct(ct_xp);
  auto cc = (*ct)->GetCryptoContext();
  auto result = cc->EvalCos(*ct, a, b, static_cast<uint32_t>(degree));
  return external_pointer<Ciphertext<DCRTPoly>>(
    new Ciphertext<DCRTPoly>(result));
}

[[cpp11::register]]
SEXP EvalLogistic_(SEXP ct_xp, double a, double b, int degree) {
  external_pointer<Ciphertext<DCRTPoly>> ct(ct_xp);
  auto cc = (*ct)->GetCryptoContext();
  auto result = cc->EvalLogistic(*ct, a, b, static_cast<uint32_t>(degree));
  return external_pointer<Ciphertext<DCRTPoly>>(
    new Ciphertext<DCRTPoly>(result));
}

[[cpp11::register]]
SEXP EvalDivide_(SEXP ct_xp, double a, double b, int degree) {
  external_pointer<Ciphertext<DCRTPoly>> ct(ct_xp);
  auto cc = (*ct)->GetCryptoContext();
  auto result = cc->EvalDivide(*ct, a, b, static_cast<uint32_t>(degree));
  return external_pointer<Ciphertext<DCRTPoly>>(
    new Ciphertext<DCRTPoly>(result));
}

// ── CKKS Bootstrapping ─────────────────────────────────

[[cpp11::register]]
void CryptoContext__EvalBootstrapSetup(SEXP cc_xp,
    integers level_budget, integers dim1, int slots,
    int correction_factor, bool precompute, bool bt_slots_encoding) {
  // the 6th argument `bt_slots_encoding`
  // was added per cryptocontext.h line 3513. It had been missing
  // from the R binding despite being part of the header
  // signature since v1.5.1.0.
  external_pointer<CryptoContext<DCRTPoly>> cc(cc_xp);
  std::vector<uint32_t> lb, d1;
  for (R_xlen_t i = 0; i < level_budget.size(); i++)
    lb.push_back(static_cast<uint32_t>(level_budget[i]));
  for (R_xlen_t i = 0; i < dim1.size(); i++)
    d1.push_back(static_cast<uint32_t>(dim1[i]));
  (*cc)->EvalBootstrapSetup(lb, d1, static_cast<uint32_t>(slots),
    static_cast<uint32_t>(correction_factor), precompute, bt_slots_encoding);
}

[[cpp11::register]]
void CryptoContext__EvalBootstrapKeyGen(SEXP cc_xp, SEXP sk_xp, int slots) {
  external_pointer<CryptoContext<DCRTPoly>> cc(cc_xp);
  external_pointer<PrivateKey<DCRTPoly>> sk(sk_xp);
  (*cc)->EvalBootstrapKeyGen(*sk, static_cast<uint32_t>(slots));
}

[[cpp11::register]]
SEXP CryptoContext__EvalBootstrap(SEXP ct_xp, int num_iterations, int precision) {
  external_pointer<Ciphertext<DCRTPoly>> ct(ct_xp);
  auto cc = (*ct)->GetCryptoContext();
  auto result = cc->EvalBootstrap(*ct, static_cast<uint32_t>(num_iterations),
    static_cast<uint32_t>(precision));
  return external_pointer<Ciphertext<DCRTPoly>>(
    new Ciphertext<DCRTPoly>(result));
}

// ── FHECKKSRNS static methods ───────────────────────────

[[cpp11::register]]
int FHECKKSRNS__GetBootstrapDepth(integers level_budget, int secret_key_dist) {
  std::vector<uint32_t> lb;
  for (R_xlen_t i = 0; i < level_budget.size(); i++)
    lb.push_back(static_cast<uint32_t>(level_budget[i]));
  return static_cast<int>(
    FHECKKSRNS::GetBootstrapDepth(lb, static_cast<SecretKeyDist>(secret_key_dist)));
}

// ── EvalSumKeyGen ───────────────────────────────────────

[[cpp11::register]]
void CryptoContext__EvalSumKeyGen(SEXP cc_xp, SEXP sk_xp) {
  external_pointer<CryptoContext<DCRTPoly>> cc(cc_xp);
  external_pointer<PrivateKey<DCRTPoly>> sk(sk_xp);
  (*cc)->EvalSumKeyGen(*sk);
}
