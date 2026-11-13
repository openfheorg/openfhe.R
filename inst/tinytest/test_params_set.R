## OPENFHE PYTHON SOURCE: src/lib/bindings.cpp (bind_parameters: Set*, __str__)
##
## @openfhe-python: src/lib/bindings.cpp [FULL: the 32 CCParams setters as calls after construction on all three parameter classes, and __str__]
##
## Each setter is called twice with different values and read back
## through its getter, so a field code that reached the wrong C++
## setter, or a value dropped on the way, fails. A setter that a scheme
## disables must raise OpenFHE's error; the table below is the
## enabled/disabled matrix of the 1.6.1 headers
## (scheme/*/gen-cryptocontext-*-params.h).
library(openfhe.R)

ns <- asNamespace("openfhe.R")
fields <- names(ns$.CCPARAMS_FIELD)
kinds <- ns$.CCPARAMS_KIND

## The field codes are 0..31 in table order, as in enum ParamField.
expect_identical(unname(ns$.CCPARAMS_FIELD), 0:31)
expect_identical(names(kinds), fields)

## Scheme-disabled setters, per parameter class.
disabled <- list(
  BFV = c("execution_mode", "decryption_noise_mode", "noise_estimate",
          "desired_precision", "statistical_security",
          "num_adversarial_queries", "scaling_technique", "first_mod_size",
          "pre_num_hops", "interactive_boot_compression_level",
          "composite_degree", "register_word_size", "ckks_data_type"),
  BGV = c("execution_mode", "decryption_noise_mode", "noise_estimate",
          "desired_precision", "encryption_technique",
          "multiplication_technique", "interactive_boot_compression_level",
          "composite_degree", "register_word_size", "ckks_data_type"),
  CKKS = c("plaintext_modulus", "multiparty_mode", "threshold_num_of_parties",
           "eval_add_count", "key_switch_count", "encryption_technique",
           "multiplication_technique", "pre_num_hops")
)
new_params <- list(BFV = BFVParams, BGV = BGVParams, CKKS = CKKSParams)

## Two distinct valid values of each kind.
value <- function(kind, k) {
  switch(kind,
         wide = c(65537, 786433)[k],
         real = c(3.5, 4.5)[k],
         count = c(3L, 5L)[k],
         enum = c(1L, 0L)[k])
}

for (scheme in names(new_params)) {
  for (f in fields) {
    setter <- get(paste0("set_", f), envir = ns)
    getter <- get(paste0("get_", f), envir = ns)
    p <- new_params[[scheme]]()
    if (f %in% disabled[[scheme]]) {
      expect_error(setter(p, value(kinds[[f]], 1L)), "not available",
                   info = paste(scheme, f))
    } else {
      for (k in 1:2) {
        v <- value(kinds[[f]], k)
        r <- setter(p, v)
        expect_identical(r, p, info = paste(scheme, f))
        expect_equal(as.numeric(getter(p)), as.numeric(v), tolerance = 1e-6,
                     info = paste(scheme, f, k))
      }
    }
  }
}

# ── Values are checked before they reach C++ ─────────────
p <- BFVParams()
expect_error(set_multiplicative_depth(p, -1L), "non-negative whole number")
expect_error(set_multiplicative_depth(p, 1.5), "non-negative whole number")
expect_error(set_multiplicative_depth(p, c(1L, 2L)), "non-negative whole number")
expect_error(set_multiplicative_depth(p, NA_integer_), "non-negative whole number")
expect_error(set_standard_deviation(p, "3.19"), "single number")
expect_error(set_plaintext_modulus(p, -5), "non-negative whole number")
expect_error(set_plaintext_modulus(p, "18446744073709551616"), "too large")
## A plaintext modulus above 2^53 goes in as a string and comes back
## as one.
set_plaintext_modulus(p, "1152921504606846977")
expect_identical(get_plaintext_modulus(p), "1152921504606846977")

## A handle of another class is refused.
cc <- fhe_context("BFV", plaintext_modulus = 65537, multiplicative_depth = 1)
expect_error(openfhe.R:::CCParams__Set(cc@ptr, 19L, 2L), "BFVParams")

# ── A context built step by step, as the OpenFHE examples do ──
p <- BFVParams()
set_plaintext_modulus(p, 65537)
set_multiplicative_depth(p, 2L)
set_security_level(p, SecurityLevel$HEStd_128_classic)
q <- BFVParams(plaintext_modulus = 65537, multiplicative_depth = 2L,
               security_level = SecurityLevel$HEStd_128_classic)
## The stream form lists every field, so equal text is equal settings.
expect_identical(format(p), format(q))

# ── gen_crypto_context(): GenCryptoContext(params) ───────
## No feature is enabled on the returned context, as in C++ and
## Python: key generation is refused until PKE is enabled. The
## parameters differ from every context made above, because OpenFHE
## hands back the existing context, features included, for parameters
## it has already seen.
p2 <- BFVParams()
set_plaintext_modulus(p2, 786433)
set_multiplicative_depth(p2, 3L)
cc2 <- gen_crypto_context(p2)
expect_true(S7::S7_inherits(cc2, CryptoContext))
expect_error(key_gen(cc2), "not been enabled")
enable_feature(cc2, Feature$PKE)
enable_feature(cc2, Feature$KEYSWITCH)
enable_feature(cc2, Feature$LEVELEDSHE)
kp2 <- key_gen(cc2)
v <- c(1L, 2L, 3L, 4L)
ct2 <- encrypt(kp2@public, make_packed_plaintext(cc2, v), cc = cc2)
pt2 <- decrypt(ct2, kp2@secret, cc = cc2)
set_length(pt2, length(v))
expect_identical(as.integer(get_packed_value(pt2)), v)
expect_identical(get_plaintext_modulus(cc2), 786433)
## The other two schemes, and a refused argument.
expect_true(S7::S7_inherits(gen_crypto_context(BGVParams(plaintext_modulus = 65537)),
                            CryptoContext))
expect_true(S7::S7_inherits(
  gen_crypto_context(CKKSParams(multiplicative_depth = 1L, scaling_mod_size = 50L)),
  CryptoContext))
expect_error(gen_crypto_context("BFV"), "BFVParams")

# ── format() and print(): Python's __str__ ───────────────
s <- format(p)
expect_true(is.character(s) && length(s) == 1L)
expect_true(grepl("scheme: BFVRNS", s, fixed = TRUE))
expect_true(grepl("ptModulus: 65537", s, fixed = TRUE))
expect_true(grepl("multiplicativeDepth:2", s, fixed = TRUE))
set_multiplicative_depth(p, 3L)
expect_true(grepl("multiplicativeDepth:3", format(p), fixed = TRUE))
expect_true(grepl("scheme: CKKSRNS", format(CKKSParams()), fixed = TRUE))
expect_true(grepl("scheme: BGVRNS", format(BGVParams()), fixed = TRUE))
out <- capture.output(r <- print(p), type = "message")
expect_identical(r, p)
