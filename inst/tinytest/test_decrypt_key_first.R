## OPENFHE PYTHON SOURCE: src/lib/bindings.cpp (Decrypt, both argument orders)
## @openfhe-python: FULL — Python binds Decrypt(privateKey, ciphertext)
## and Decrypt(ciphertext, privateKey); the C++ header declares the
## ciphertext-first form as primary and the key-first form as a
## forwarder. Both orders must decrypt to the same plaintext.

suppressPackageStartupMessages(library(openfhe.R))

cc <- fhe_context("CKKS", multiplicative_depth = 2L,
                  scaling_mod_size = 50L, batch_size = 8L)
kp <- key_gen(cc, eval_mult = TRUE)
x  <- c(0.25, 0.5, 0.75, 1)
pt <- make_ckks_packed_plaintext(cc, x)
ct <- encrypt(kp@public, pt, cc = cc)

vals <- function(p) get_real_packed_value(set_length(p, 4L))

## ciphertext-first (primary) and key-first (forwarder) agree
a <- decrypt(ct, kp@secret, cc = cc)
b <- decrypt(kp@secret, ct, cc = cc)
expect_inherits(b, "openfhe.R::Plaintext")
expect_equal(vals(a), x, tolerance = 1e-6)
expect_equal(vals(b), vals(a), tolerance = 1e-9)

## and on a computed ciphertext
d <- decrypt(kp@secret, eval_mult(ct, ct), cc = cc)
expect_equal(vals(d), x^2, tolerance = 1e-5)

## the key-first form needs the context just like the primary form
expect_error(decrypt(kp@secret, ct), "cc")

## wrong-class pairs still have no method
expect_error(decrypt(kp@public, ct, cc = cc), "Can't find method")
expect_error(decrypt(ct, ct, cc = cc), "Can't find method")

## BFV, so the exact schemes are covered too
cc2 <- fhe_context("BFV", plaintext_modulus = 65537L, multiplicative_depth = 1L)
kp2 <- key_gen(cc2)
pt2 <- make_packed_plaintext(cc2, c(1L, 2L, 3L))
ct2 <- encrypt(kp2@public, pt2, cc = cc2)
p1 <- decrypt(ct2, kp2@secret, cc = cc2)
p2 <- decrypt(kp2@secret, ct2, cc = cc2)
expect_equal(get_packed_value(set_length(p2, 3L)),
             get_packed_value(set_length(p1, 3L)))
