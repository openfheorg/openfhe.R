## R-SPECIFIC: the internal fast constructor .fast_new() (R/fast-new.R)
## @openfhe-python: NONE — openfhe-python has no counterpart. Functions
## that return a handle build it with .fast_new() and not with the S7
## constructor (RConsortium/S7#723). This file checks that the two give
## the same object for every handle class, so that a change in how S7
## lays out an object fails here and not in a user's session.

library(openfhe.R)
ns <- asNamespace("openfhe.R")
fast_new <- ns$.fast_new

## Every class with OpenFHEObject as its parent.
is_handle_class <- function(x) {
  inherits(x, "S7_class") && identical(attr(x, "parent"), OpenFHEObject)
}
handle_classes <- Filter(is_handle_class, mget(ls(ns), envir = ns))
expect_true(length(handle_classes) >= 28L)

## Classes whose constructor takes `ptr` and nothing else: the S7
## constructor and .fast_new() must agree on an empty handle. The other
## classes (the three parameter classes and the serializer) build a C++
## object in their constructor and have no empty form.
for (nm in names(handle_classes)) {
  cls <- handle_classes[[nm]]
  if (!identical(names(formals(cls)), "ptr")) next
  default_ptr <- formals(cls)$ptr
  if (!is.null(default_ptr)) next
  via_s7 <- cls()
  if (!is.null(via_s7@ptr)) next
  expect_identical(fast_new(cls, NULL), via_s7, info = nm)
}

## Real pointers.
cc <- fhe_context("BFV", plaintext_modulus = 65537, multiplicative_depth = 1)
keys <- key_gen(cc, eval_mult = TRUE)
pt <- make_packed_plaintext(cc, 1:4)
ct <- encrypt(keys@public, pt, cc = cc)
bcc <- bin_fhe_context(BinFHEParamSet$TOY)
bsk <- bin_key_gen(bcc)
bct <- bin_encrypt(bcc, bsk, 1L)
real <- list(CryptoContext = cc, PublicKey = keys@public,
             PrivateKey = keys@secret, Plaintext = pt, Ciphertext = ct,
             BinFHEContext = bcc, LWEPrivateKey = bsk, LWECiphertext = bct)
for (nm in names(real)) {
  obj <- real[[nm]]
  cls <- handle_classes[[nm]]
  ## The object the package returned was itself built by .fast_new().
  expect_identical(obj, cls(ptr = obj@ptr), info = nm)
  expect_identical(fast_new(cls, obj@ptr), cls(ptr = obj@ptr), info = nm)
  expect_true(S7::S7_inherits(obj, cls), info = nm)
  expect_true(S7::S7_inherits(obj, OpenFHEObject), info = nm)
  expect_silent(S7::validate(obj))
}

## The checks of the OpenFHEObject validator are kept.
expect_error(fast_new(Ciphertext, pt@ptr), "holds a .*Plaintext.* handle")
expect_error(fast_new(Plaintext, ct@ptr), "holds a .*Ciphertext.* handle")
expect_error(fast_new(Ciphertext, 1), "external pointer")
expect_error(fast_new(Ciphertext, "x"), "external pointer")

## A fast-built object is a working operand.
sum_ct <- eval_add(fast_new(Ciphertext, ct@ptr), ct)
res <- decrypt(sum_ct, keys@secret, cc = cc)
set_length(res, 4L)
expect_identical(as.integer(get_packed_value(res)), c(2L, 4L, 6L, 8L))
