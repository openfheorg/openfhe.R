## R-SPECIFIC: typed external-pointer guard (src/openfhe_cpp11.h xptr<T>)
## @openfhe-python: NONE — pybind11 rejects wrong-class arguments at the
## binding boundary by construction; this file is the R equivalent of
## that guarantee. Every case below reproduces a probe from the
## 2026-09-22 surface audit (temp/scratch/audit3, C01-C17) that used to
## segfault, abort, or return garbage. Each must now raise an R error
## naming the expected and received handle types, and the process must
## survive.

suppressPackageStartupMessages(library(openfhe.R))

cc <- fhe_context("CKKS", multiplicative_depth = 2L,
                  scaling_mod_size = 50L, batch_size = 8L)
kp <- key_gen(cc, eval_mult = TRUE)
pt <- make_ckks_packed_plaintext(cc, c(1, 2, 3, 4))
ct <- encrypt(kp@public, pt, cc = cc)

wrong <- function(expected, got) {
  sprintf("expected a <openfhe.R::%s> handle, got <openfhe.R::%s>",
          expected, got)
}

## ---- pointer tags are present and named after the S7 class ----------
expect_equal(openfhe.R:::xptr_type(cc@ptr),        "openfhe.R::CryptoContext")
expect_equal(openfhe.R:::xptr_type(ct@ptr),        "openfhe.R::Ciphertext")
expect_equal(openfhe.R:::xptr_type(pt@ptr),        "openfhe.R::Plaintext")
expect_equal(openfhe.R:::xptr_type(kp@public@ptr), "openfhe.R::PublicKey")
expect_equal(openfhe.R:::xptr_type(kp@secret@ptr), "openfhe.R::PrivateKey")
expect_equal(openfhe.R:::xptr_type(NULL), "")
expect_equal(openfhe.R:::xptr_type(1),    "")

## ---- C02: plaintext accessor given a ciphertext (was SIGSEGV) --------
expect_error(get_packed_value(ct), wrong("Plaintext", "Ciphertext"), fixed = TRUE)

## ---- C03: eval_poly given a plaintext (was SIGSEGV) ------------------
expect_error(eval_poly(pt, c(1, 2)), wrong("Ciphertext", "Plaintext"), fixed = TRUE)

## ---- C05: encoding params where element params belong (was SIGSEGV) --
expect_error(
  make_ckks_packed_plaintext(cc, c(1, 2), params = get_encoding_params(cc)),
  wrong("ElementParams", "EncodingParams"), fixed = TRUE)

## ---- C09: a ciphertext passed as fast-rotation digits (was SIGBUS) ---
expect_error(eval_fast_rotation(ct, 1L, precomp = ct),
             wrong("FastRotationPrecomputation", "Ciphertext"), fixed = TRUE)

## ---- C10: a public key where an eval-key map belongs (was SIGSEGV) ---
expect_error(eval_automorphism(ct, 3L, kp@public),
             wrong("EvalKeyMap", "PublicKey"), fixed = TRUE)

## ---- C15: a public key planted in the eval-mult registry (was SIGBUS later)
expect_error(insert_eval_mult_key(list(kp@public), "evil"),
             wrong("EvalKey", "PublicKey"), fixed = TRUE)

## ---- C01 / C12: mutable and no-relin paths given a plaintext ---------
expect_error(eval_add_mutable(ct, pt),   wrong("Ciphertext", "Plaintext"), fixed = TRUE)
expect_error(eval_sub_mutable(ct, pt),   wrong("Ciphertext", "Plaintext"), fixed = TRUE)
expect_error(eval_mult_mutable(ct, pt),  wrong("Ciphertext", "Plaintext"), fixed = TRUE)
expect_error(eval_mult_no_relin(ct, pt), wrong("Ciphertext", "Plaintext"), fixed = TRUE)

## ---- C04: level_reduce given a public key (was silently accepted) ----
expect_error(level_reduce(ct, kp@public), wrong("EvalKey", "PublicKey"), fixed = TRUE)

## ---- C08: int_boot_decrypt with the arguments swapped ----------------
expect_error(int_boot_decrypt(ct, kp@secret), wrong("PrivateKey", "Ciphertext"), fixed = TRUE)

## ---- C07: wrapping a plaintext pointer in a Ciphertext object --------
## The S7 validator refuses it at construction and on assignment.
expect_error(Ciphertext(ptr = pt@ptr), "holds a <openfhe.R::Plaintext> handle")
bad <- Ciphertext()
expect_error(bad@ptr <- pt@ptr, "holds a <openfhe.R::Plaintext> handle")
## The base class is abstract: nothing may hold an unclassed handle.
expect_error(OpenFHEObject(ptr = pt@ptr), "abstract")
## BinFHE contexts have their own class now, so the two context kinds
## are distinguishable at the R level as well as by tag.
expect_inherits(bin_fhe_context(), "openfhe.R::BinFHEContext")

## ---- BinFHE: C06 / C13 / C16 (bogus key, garbage decrypt, SIGABRT) ---
bctx <- bin_fhe_context()
bsk  <- bin_key_gen(bctx)
expect_error(bin_key_gen(cc),  wrong("BinFHEContext", "CryptoContext"), fixed = TRUE)
expect_error(bin_bt_key_gen(bctx, kp@secret), wrong("LWEPrivateKey", "PrivateKey"), fixed = TRUE)
expect_error(bin_decrypt(bctx, bsk, ct), wrong("LWECiphertext", "Ciphertext"), fixed = TRUE)
expect_error(bin_encrypt(bctx, bin_encrypt(bctx, bsk, 1L), 1L),
             wrong("LWEPrivateKey", "LWECiphertext"), fixed = TRUE)

## ---- non-pointer and NULL inputs get a typed message too -------------
expect_error(openfhe.R:::Plaintext__GetLength(NULL), "got NULL")
expect_error(openfhe.R:::Plaintext__GetLength(42),   "got an R object of type 'double'")

## ---- the happy path is untouched ------------------------------------
out <- decrypt(eval_add(ct, ct), kp@secret, cc = cc)
out <- set_length(out, 4L)
expect_equal(get_real_packed_value(out), c(2, 4, 6, 8), tolerance = 1e-6)
