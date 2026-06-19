// OPENFHE PYTHON SOURCE: src/lib/binfhe_bindings.cpp
// Phase 6: Binary FHE — Boolean gates and functional bootstrapping
#include "openfhe_cpp11.h"
#include "binfhecontext.h"

using namespace cpp11;

// ── BinFHE Context ──────────────────────────────────────

[[cpp11::register]]
SEXP BinFHEContext__new() {
  auto ctx = std::make_shared<BinFHEContext>();
  return external_pointer<std::shared_ptr<BinFHEContext>>(
    new std::shared_ptr<BinFHEContext>(ctx));
}

[[cpp11::register]]
void BinFHEContext__GenerateBinFHEContext(SEXP ctx_xp, int paramset, int method) {
  external_pointer<std::shared_ptr<BinFHEContext>> ctx(ctx_xp);
  (*ctx)->GenerateBinFHEContext(
    static_cast<BINFHE_PARAMSET>(paramset),
    static_cast<BINFHE_METHOD>(method));
}

// Overload for arbitrary-function bootstrapping (eval-sign, eval-function).
// Mirrors binfhecontext.h:126:
//   GenerateBinFHEContext(BINFHE_PARAMSET set, bool arbFunc, uint32_t logQ = 11,
//                         uint32_t N = 0, BINFHE_METHOD method = GINX,
//                         bool timeOptimization = false)
[[cpp11::register]]
void BinFHEContext__GenerateBinFHEContextArbFunc(SEXP ctx_xp, int paramset,
                                                 bool arb_func, int log_q, int n,
                                                 int method, bool time_optimization) {
  external_pointer<std::shared_ptr<BinFHEContext>> ctx(ctx_xp);
  (*ctx)->GenerateBinFHEContext(
    static_cast<BINFHE_PARAMSET>(paramset),
    arb_func,
    static_cast<uint32_t>(log_q),
    static_cast<uint32_t>(n),
    static_cast<BINFHE_METHOD>(method),
    time_optimization);
}

[[cpp11::register]]
double BinFHEContext__GetMaxPlaintextSpace(SEXP ctx_xp) {
  external_pointer<std::shared_ptr<BinFHEContext>> ctx(ctx_xp);
  return static_cast<double>((*ctx)->GetMaxPlaintextSpace().ConvertToInt());
}

// ── Key Generation ──────────────────────────────────────

[[cpp11::register]]
SEXP BinFHEContext__KeyGen(SEXP ctx_xp) {
  external_pointer<std::shared_ptr<BinFHEContext>> ctx(ctx_xp);
  auto sk = (*ctx)->KeyGen();
  return external_pointer<LWEPrivateKey>(new LWEPrivateKey(sk));
}

// keygen_mode argument added per
// binfhecontext.h line 273. Default int value 0 ==
// KEYGEN_MODE::SYM_ENCRYPT; passing 1 routes to PUB_ENCRYPT.
// Backward-compatible at the R layer because the R wrapper's
// default is KeygenMode$SYM_ENCRYPT.
[[cpp11::register]]
void BinFHEContext__BTKeyGen(SEXP ctx_xp, SEXP sk_xp, int keygen_mode) {
  external_pointer<std::shared_ptr<BinFHEContext>> ctx(ctx_xp);
  external_pointer<LWEPrivateKey> sk(sk_xp);
  (*ctx)->BTKeyGen(*sk, static_cast<KEYGEN_MODE>(keygen_mode));
}

// ── Encrypt / Decrypt ───────────────────────────────────

[[cpp11::register]]
SEXP BinFHEContext__Encrypt(SEXP ctx_xp, SEXP sk_xp, int message,
                            int output, int p) {
  external_pointer<std::shared_ptr<BinFHEContext>> ctx(ctx_xp);
  external_pointer<LWEPrivateKey> sk(sk_xp);
  auto ct = (*ctx)->Encrypt(*sk, static_cast<LWEPlaintext>(message),
    static_cast<BINFHE_OUTPUT>(output), static_cast<LWEPlaintextModulus>(p));
  return external_pointer<LWECiphertext>(new LWECiphertext(ct));
}

// Variant exposing the BINFHE_OUTPUT, p, and mod parameters for the
// arbitrary-function bootstrapping path (eval-sign.py uses LARGE_DIM + Q).
// mod is passed as a double; uint64_t round-trips exactly through R doubles
// up to 2^53, which covers all realistic logQ values.
[[cpp11::register]]
SEXP BinFHEContext__EncryptWithMod(SEXP ctx_xp, SEXP sk_xp, double message,
                                   int output, double p, double mod) {
  external_pointer<std::shared_ptr<BinFHEContext>> ctx(ctx_xp);
  external_pointer<LWEPrivateKey> sk(sk_xp);
  auto ct = (*ctx)->Encrypt(*sk,
    static_cast<LWEPlaintext>(static_cast<int64_t>(message)),
    static_cast<BINFHE_OUTPUT>(output),
    static_cast<LWEPlaintextModulus>(static_cast<uint64_t>(p)),
    NativeInteger(static_cast<uint64_t>(mod)));
  return external_pointer<LWECiphertext>(new LWECiphertext(ct));
}

[[cpp11::register]]
int BinFHEContext__Decrypt(SEXP ctx_xp, SEXP sk_xp, SEXP ct_xp, int p) {
  external_pointer<std::shared_ptr<BinFHEContext>> ctx(ctx_xp);
  external_pointer<LWEPrivateKey> sk(sk_xp);
  external_pointer<LWECiphertext> ct(ct_xp);
  LWEPlaintext result;
  (*ctx)->Decrypt(*sk, *ct, &result, static_cast<LWEPlaintextModulus>(p));
  return static_cast<int>(result);
}

// ── Boolean Gates ───────────────────────────────────────

[[cpp11::register]]
SEXP BinFHEContext__EvalBinGate(SEXP ctx_xp, int gate, SEXP ct1_xp, SEXP ct2_xp) {
  external_pointer<std::shared_ptr<BinFHEContext>> ctx(ctx_xp);
  external_pointer<LWECiphertext> ct1(ct1_xp);
  external_pointer<LWECiphertext> ct2(ct2_xp);
  auto result = (*ctx)->EvalBinGate(static_cast<BINGATE>(gate), *ct1, *ct2);
  return external_pointer<LWECiphertext>(new LWECiphertext(result));
}

// vector-form EvalBinGate per
// binfhecontext.h line 322. The header doc comment
// specifically calls out MAJORITY / AND3 / OR3 / AND4 / OR4
// / CMUX as the gates this overload is designed for; passing
// a list of arbitrary length with a 2-input gate surfaces
// through catch_openfhe as the scheme's own error.
[[cpp11::register]]
SEXP BinFHEContext__EvalBinGate__vec(SEXP ctx_xp, int gate,
                                     cpp11::list ct_list) {
  external_pointer<std::shared_ptr<BinFHEContext>> ctx(ctx_xp);
  std::vector<LWECiphertext> ct_vec;
  ct_vec.reserve(ct_list.size());
  for (R_xlen_t i = 0; i < ct_list.size(); ++i) {
    SEXP ct_xp = ct_list[i];
    external_pointer<LWECiphertext> ct(ct_xp);
    ct_vec.push_back(*ct);
  }
  auto result = (*ctx)->EvalBinGate(static_cast<BINGATE>(gate), ct_vec);
  return external_pointer<LWECiphertext>(new LWECiphertext(result));
}

[[cpp11::register]]
SEXP BinFHEContext__EvalNOT(SEXP ctx_xp, SEXP ct_xp) {
  external_pointer<std::shared_ptr<BinFHEContext>> ctx(ctx_xp);
  external_pointer<LWECiphertext> ct(ct_xp);
  auto result = (*ctx)->EvalNOT(*ct);
  return external_pointer<LWECiphertext>(new LWECiphertext(result));
}

// ── Functional bootstrapping ────────────────────────────

[[cpp11::register]]
SEXP BinFHEContext__EvalSign(SEXP ctx_xp, SEXP ct_xp, bool scheme_switch) {
  external_pointer<std::shared_ptr<BinFHEContext>> ctx(ctx_xp);
  external_pointer<LWECiphertext> ct(ct_xp);
  auto result = (*ctx)->EvalSign(*ct, scheme_switch);
  return external_pointer<LWECiphertext>(new LWECiphertext(result));
}

[[cpp11::register]]
SEXP BinFHEContext__EvalFloor(SEXP ctx_xp, SEXP ct_xp, int roundbits) {
  external_pointer<std::shared_ptr<BinFHEContext>> ctx(ctx_xp);
  external_pointer<LWECiphertext> ct(ct_xp);
  auto result = (*ctx)->EvalFloor(*ct, static_cast<uint32_t>(roundbits));
  return external_pointer<LWECiphertext>(new LWECiphertext(result));
}

// Evaluate an arbitrary function on an LWE ciphertext via a precomputed
// lookup table. We don't bind OpenFHE's GenerateLUTviaFunction because
// its signature takes a raw C function pointer that cannot capture an R
// closure. Instead, the R caller passes a length-p plaintext-domain LUT
// (i.e. the values f(0,p), f(1,p), ..., f(p-1,p)) and this binding
// expands it internally to the length-q ciphertext-domain form OpenFHE's
// EvalFunc expects. The expansion mirrors the body of
// BinFHEContext::GenerateLUTviaFunction in
// openfhe-development/src/binfhe/lib/binfhecontext.cpp:366: each entry is
// (q/p) * f(idx, p) where idx = (i*p)/q, with q the inner LWE modulus.
[[cpp11::register]]
SEXP BinFHEContext__EvalFunc(SEXP ctx_xp, SEXP ct_xp, doubles plaintext_lut) {
  external_pointer<std::shared_ptr<BinFHEContext>> ctx(ctx_xp);
  external_pointer<LWECiphertext> ct(ct_xp);

  uint64_t p_int = static_cast<uint64_t>(plaintext_lut.size());
  if (p_int == 0 || (p_int & (p_int - 1)) != 0) {
    cpp11::stop("plaintext modulus p (length of LUT) must be a power of two");
  }
  NativeInteger p(p_int);

  NativeInteger q = (*ctx)->GetParams()->GetLWEParams()->Getq();
  uint64_t q_int = q.ConvertToInt();
  NativeInteger scale = q / p;

  std::vector<NativeInteger> lut_vec(q_int, scale);
  for (uint64_t i = 0; i < q_int; ++i) {
    uint64_t idx = (i * p_int) / q_int;
    NativeInteger fval(static_cast<uint64_t>(plaintext_lut[static_cast<R_xlen_t>(idx)]));
    lut_vec[i] *= fval;
    if (lut_vec[i] >= q) {
      cpp11::stop("LUT value out of range; f must output in Z_p");
    }
  }

  auto result = (*ctx)->EvalFunc(*ct, lut_vec);
  return external_pointer<LWECiphertext>(new LWECiphertext(result));
}
