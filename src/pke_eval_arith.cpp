// OPENFHE PYTHON SOURCE: src/lib/bindings.cpp (EvalAdd/EvalSub/EvalMult overload completion)
//
// The operand-order and complex-scalar overloads of EvalAdd, EvalSub and
// EvalMult, with their InPlace and Mutable forms, that cryptocontext.h
// declares and openfhe-python 1.6.1.0 binds. The (ct, ct), (ct, pt) and
// (ct, double) forms are in pke_bindings.cpp and pke_eval.cpp.
//
// One registered function per shape; `op` selects the operation. Every
// branch calls the header overload with the operands in the order the
// caller gave them. Nothing is rewritten as another operation: a
// scalar-first subtraction calls EvalSub(scalar, ct), not a negated
// EvalSub(ct, scalar).
//
//   op: 0 = add, 1 = sub, 2 = mult
#include "openfhe_cpp11.h"
#include "openfhe_helpers.h"

#include <complex>

using namespace cpp11;

namespace {

enum ArithOp { OP_ADD = 0, OP_SUB = 1, OP_MULT = 2 };

ArithOp arith_op(int op) {
  if (op < OP_ADD || op > OP_MULT) cpp11::stop("unknown arithmetic operation code %d", op);
  return static_cast<ArithOp>(op);
}

SEXP wrap_ct(const Ciphertext<DCRTPoly>& ct) {
  return xptr<Ciphertext<DCRTPoly>>(new Ciphertext<DCRTPoly>(ct));
}

// Ciphertext and scalar, in the order given. S is double or
// std::complex<double>.
template <typename S>
Ciphertext<DCRTPoly> scalar_op(ArithOp op, ConstCiphertext<DCRTPoly>& ct, S s,
                               bool scalar_first) {
  auto cc = ct->GetCryptoContext();
  switch (op) {
    case OP_ADD:  return scalar_first ? cc->EvalAdd(s, ct)  : cc->EvalAdd(ct, s);
    case OP_SUB:  return scalar_first ? cc->EvalSub(s, ct)  : cc->EvalSub(ct, s);
    case OP_MULT: return scalar_first ? cc->EvalMult(s, ct) : cc->EvalMult(ct, s);
  }
  cpp11::stop("unreachable");
}

template <typename S>
void scalar_op_in_place(ArithOp op, Ciphertext<DCRTPoly>& ct, S s,
                        bool scalar_first) {
  auto cc = ct->GetCryptoContext();
  switch (op) {
    case OP_ADD:
      if (scalar_first) cc->EvalAddInPlace(s, ct); else cc->EvalAddInPlace(ct, s);
      return;
    case OP_SUB:
      if (scalar_first) cc->EvalSubInPlace(s, ct); else cc->EvalSubInPlace(ct, s);
      return;
    case OP_MULT:
      if (scalar_first) cc->EvalMultInPlace(s, ct); else cc->EvalMultInPlace(ct, s);
      return;
  }
}

}  // namespace

// (ct, double) and (double, ct).
[[cpp11::register]]
SEXP EvalArith__real(int op, SEXP ct_xp, double scalar, bool scalar_first) {
  xptr<Ciphertext<DCRTPoly>> ct(ct_xp);
  ArithOp o = arith_op(op);
  return catch_openfhe("CryptoContext::Eval{Add,Sub,Mult}(ct, double)", [&]() {
    return wrap_ct(scalar_op<double>(o, *ct, scalar, scalar_first));
  });
}

// (ct, complex) and (complex, ct).
[[cpp11::register]]
SEXP EvalArith__complex(int op, SEXP ct_xp, double re, double im,
                        bool scalar_first) {
  xptr<Ciphertext<DCRTPoly>> ct(ct_xp);
  ArithOp o = arith_op(op);
  return catch_openfhe("CryptoContext::Eval{Add,Sub,Mult}(ct, complex)", [&]() {
    return wrap_ct(scalar_op<std::complex<double>>(
        o, *ct, std::complex<double>(re, im), scalar_first));
  });
}

// InPlace, (ct, double) and (double, ct). The ciphertext is modified.
[[cpp11::register]]
void EvalArithInPlace__real(int op, SEXP ct_xp, double scalar,
                            bool scalar_first) {
  xptr<Ciphertext<DCRTPoly>> ct(ct_xp);
  ArithOp o = arith_op(op);
  catch_openfhe("CryptoContext::Eval{Add,Sub,Mult}InPlace(ct, double)", [&]() {
    scalar_op_in_place<double>(o, *ct, scalar, scalar_first);
  });
}

// InPlace, (ct, complex) and (complex, ct).
[[cpp11::register]]
void EvalArithInPlace__complex(int op, SEXP ct_xp, double re, double im,
                               bool scalar_first) {
  xptr<Ciphertext<DCRTPoly>> ct(ct_xp);
  ArithOp o = arith_op(op);
  catch_openfhe("CryptoContext::Eval{Add,Sub,Mult}InPlace(ct, complex)", [&]() {
    scalar_op_in_place<std::complex<double>>(
        o, *ct, std::complex<double>(re, im), scalar_first);
  });
}

// (pt, ct): plaintext first.
[[cpp11::register]]
SEXP EvalArith__pt_ct(int op, SEXP pt_xp, SEXP ct_xp) {
  xptr<Plaintext> pt(pt_xp);
  xptr<Ciphertext<DCRTPoly>> ct(ct_xp);
  ArithOp o = arith_op(op);
  return catch_openfhe("CryptoContext::Eval{Add,Sub,Mult}(pt, ct)", [&]() {
    auto cc = (*ct)->GetCryptoContext();
    ConstCiphertext<DCRTPoly> c = *ct;
    switch (o) {
      case OP_ADD:  return wrap_ct(cc->EvalAdd(*pt, c));
      case OP_SUB:  return wrap_ct(cc->EvalSub(*pt, c));
      case OP_MULT: {
        ConstPlaintext p = *pt;
        return wrap_ct(cc->EvalMult(p, c));
      }
    }
    cpp11::stop("unreachable");
  });
}

// InPlace (pt, ct): the ciphertext, the second operand, is modified.
// The header declares this for add and sub only.
[[cpp11::register]]
void EvalArithInPlace__pt_ct(int op, SEXP pt_xp, SEXP ct_xp) {
  xptr<Plaintext> pt(pt_xp);
  xptr<Ciphertext<DCRTPoly>> ct(ct_xp);
  ArithOp o = arith_op(op);
  catch_openfhe("CryptoContext::Eval{Add,Sub}InPlace(pt, ct)", [&]() {
    auto cc = (*ct)->GetCryptoContext();
    switch (o) {
      case OP_ADD: cc->EvalAddInPlace(*pt, *ct); return;
      case OP_SUB: cc->EvalSubInPlace(*pt, *ct); return;
      case OP_MULT:
        cpp11::stop("EvalMultInPlace(pt, ct) is not declared by OpenFHE");
    }
  });
}

// Mutable with a plaintext operand, either order.
[[cpp11::register]]
SEXP EvalArithMutable__pt(int op, SEXP ct_xp, SEXP pt_xp, bool pt_first) {
  xptr<Ciphertext<DCRTPoly>> ct(ct_xp);
  xptr<Plaintext> pt(pt_xp);
  ArithOp o = arith_op(op);
  return catch_openfhe("CryptoContext::Eval{Add,Sub,Mult}Mutable(ct, pt)", [&]() {
    auto cc = (*ct)->GetCryptoContext();
    switch (o) {
      case OP_ADD:
        return wrap_ct(pt_first ? cc->EvalAddMutable(*pt, *ct)
                                : cc->EvalAddMutable(*ct, *pt));
      case OP_SUB:
        return wrap_ct(pt_first ? cc->EvalSubMutable(*pt, *ct)
                                : cc->EvalSubMutable(*ct, *pt));
      case OP_MULT:
        return wrap_ct(pt_first ? cc->EvalMultMutable(*pt, *ct)
                                : cc->EvalMultMutable(*ct, *pt));
    }
    cpp11::stop("unreachable");
  });
}
