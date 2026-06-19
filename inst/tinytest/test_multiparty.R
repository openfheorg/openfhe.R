## Phase 7: Threshold FHE (2-party) test
## @openfhe-python: threshold-fhe.py [PARTIAL: decrypt-only, no homomorphic ops on threshold ciphertexts]
## Full protocol (multi-round key exchange + EvalMult on threshold data) needs:
##   MultiKeySwitchGen, MultiMultEvalKey, MultiAddEvalMultKeys,
##   InsertEvalMultKey, EvalSumKeyGen, MultiAddEvalSumKeys, InsertEvalSumKey
## These should be covered in a vignette with the complete protocol.
library(openfhe.R)

# ── Setup: BFV context with MULTIPARTY enabled ──────────
cc <- fhe_context("BFV",
  plaintext_modulus = 65537,
  multiplicative_depth = 2,
  features = c(Feature$MULTIPARTY)
)

# ── Party 1 (lead): generate initial keys ───────────────
kp1 <- key_gen(cc)
expect_true(S7::S7_inherits(kp1, KeyPair))

# ── Party 2: generate keys using party 1's public key ───
kp2 <- multiparty_key_gen(cc, kp1@public)
expect_true(S7::S7_inherits(kp2, KeyPair))

# ── Encrypt with party 2's public key (per OpenFHE protocol) ──
x <- c(1L, 2L, 3L, 4L, 5L, 6L, 7L, 8L)
pt <- make_packed_plaintext(cc, x)
ct <- encrypt(kp2@public, pt, cc = cc)
expect_true(S7::S7_inherits(ct, Ciphertext))

# ── Threshold decryption: each party partially decrypts ──
partial1 <- multiparty_decrypt_lead(cc, kp1@secret, ct)
expect_true(S7::S7_inherits(partial1, Ciphertext))

partial2 <- multiparty_decrypt_main(cc, kp2@secret, ct)
expect_true(S7::S7_inherits(partial2, Ciphertext))

# ── Fuse partial decryptions ────────────────────────────
result <- multiparty_decrypt_fusion(cc, partial1, partial2)
set_length(result, 8L)
expect_identical(get_packed_value(result)[1:8], x)
