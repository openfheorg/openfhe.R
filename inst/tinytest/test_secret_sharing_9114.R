## @openfhe-python: NONE — ShareKeys/RecoverSharedKey are R-first [R-ONLY]
##
## SecretShareMap S7 class +
## share_keys() / recover_shared_key() + vector-form
## MultipartyDecryptLead/Main. Tests the abort-recovery flow
## documented in OpenFHE's UnitTestMultipartyAborts: a 3-party
## BFV threshold setup where party 1 drops out and party 1's
## secret is reconstructed from its distributed additive shares,
## then the reconstructed secret participates in the threshold
## decrypt alongside parties 2 and 3.
library(openfhe.R)

# ── Setup: 3-party BFV daisy-chain ──────────────────────
cc <- fhe_context("BFV",
  plaintext_modulus = 65537,
  multiplicative_depth = 2,
  batch_size = 16L,
  features = c(Feature$MULTIPARTY, Feature$ADVANCEDSHE)
)

kp1 <- key_gen(cc)
kp2 <- multiparty_key_gen(cc, kp1@public)
kp3 <- multiparty_key_gen(cc, kp2@public)

N         <- 3L
THRESHOLD <- N - 1L   # additive sharing needs N-1

# ── SecretShareMap class smoke test ─────────────────────

ssm_empty <- SecretShareMap()
expect_true(S7::S7_inherits(ssm_empty, SecretShareMap))
expect_false(openfhe.R:::ptr_is_valid(ssm_empty))

# ── share_keys: party 1 distributes their secret ────────

kp1_shares <- share_keys(cc, kp1@secret, N, THRESHOLD, 1L,
                         sharing_scheme = "additive")
expect_true(S7::S7_inherits(kp1_shares, SecretShareMap))
expect_true(openfhe.R:::ptr_is_valid(kp1_shares))

# ── recover_shared_key: reconstruct kp1's secret ────────

## Reconstruct party 1's secret from the distributed shares.
## The recovered key is a PrivateKey that participates in the
## threshold decrypt interchangeably with the original kp1@secret.
kp1_sk_recovered <- recover_shared_key(cc, kp1_shares, N, THRESHOLD,
                                       sharing_scheme = "additive")
expect_true(S7::S7_inherits(kp1_sk_recovered, PrivateKey))
expect_true(openfhe.R:::ptr_is_valid(kp1_sk_recovered))

# ── End-to-end: encrypt under kp3's public, threshold-decrypt
#    using the RECOVERED party-1 secret (simulating party 1
#    dropping out and being reconstructed from its shares) ──

x <- c(11L, 22L, 33L, 44L, 55L, 66L, 77L, 88L)
pt <- make_packed_plaintext(cc, x)
ct <- encrypt(kp3@public, pt, cc = cc)

partial1_recovered <- multiparty_decrypt_lead(cc, kp1_sk_recovered, ct)
partial2           <- multiparty_decrypt_main(cc, kp2@secret,      ct)
partial3           <- multiparty_decrypt_main(cc, kp3@secret,      ct)

result <- multiparty_decrypt_fusion(cc, partial1_recovered, partial2, partial3)
set_length(result, 8L)
expect_identical(get_packed_value(result)[1:8], x)

# ── Vector-form MultipartyDecryptLead / _Main ───────────

## Batch of three ciphertexts, all partially decrypted in one
## call per party. Verify shape + round-trip correctness.
x1 <- 1L:8L
x2 <- 101L:108L
x3 <- 201L:208L
ct_batch <- list(
  encrypt(kp3@public, make_packed_plaintext(cc, x1), cc = cc),
  encrypt(kp3@public, make_packed_plaintext(cc, x2), cc = cc),
  encrypt(kp3@public, make_packed_plaintext(cc, x3), cc = cc)
)

p1_batch <- multiparty_decrypt_lead(cc, kp1@secret, ct_batch)
expect_true(is.list(p1_batch))
expect_equal(length(p1_batch), 3L)
for (p in p1_batch) expect_true(S7::S7_inherits(p, Ciphertext))

p2_batch <- multiparty_decrypt_main(cc, kp2@secret, ct_batch)
p3_batch <- multiparty_decrypt_main(cc, kp3@secret, ct_batch)
expect_equal(length(p2_batch), 3L)
expect_equal(length(p3_batch), 3L)

## Fuse each batch entry and verify round-trip.
for (i in seq_along(ct_batch)) {
  r <- multiparty_decrypt_fusion(cc, p1_batch[[i]], p2_batch[[i]], p3_batch[[i]])
  set_length(r, 8L)
  expected <- list(x1, x2, x3)[[i]]
  expect_identical(get_packed_value(r)[1:8], expected)
}

# ── Single-ct form still works (backward compat) ────────

partial1_single <- multiparty_decrypt_lead(cc, kp1@secret, ct_batch[[1]])
expect_true(S7::S7_inherits(partial1_single, Ciphertext))

# ── Shamir sharing smoke test ───────────────────────────

## Shamir threshold = floor(N/2) + 1. With N=3 that's 2.
THRESH_SHAMIR <- as.integer(floor(N / 2) + 1)
expect_equal(THRESH_SHAMIR, 2L)

kp1_shamir <- share_keys(cc, kp1@secret, N, THRESH_SHAMIR, 1L,
                         sharing_scheme = "shamir")
expect_true(S7::S7_inherits(kp1_shamir, SecretShareMap))

kp1_sk_shamir_recovered <- recover_shared_key(cc, kp1_shamir, N, THRESH_SHAMIR,
                                              sharing_scheme = "shamir")
expect_true(S7::S7_inherits(kp1_sk_shamir_recovered, PrivateKey))

## Shamir-recovered key also round-trips through the threshold
## decrypt.
partial1_sh <- multiparty_decrypt_lead(cc, kp1_sk_shamir_recovered, ct)
partial2_sh <- multiparty_decrypt_main(cc, kp2@secret, ct)
partial3_sh <- multiparty_decrypt_main(cc, kp3@secret, ct)
r_sh <- multiparty_decrypt_fusion(cc, partial1_sh, partial2_sh, partial3_sh)
set_length(r_sh, 8L)
expect_identical(get_packed_value(r_sh)[1:8], x)

# ── Formals check ───────────────────────────────────────

expect_identical(names(formals(share_keys)),
                 c("cc", "sk", "n_parties", "threshold", "index",
                   "sharing_scheme"))
expect_identical(names(formals(recover_shared_key)),
                 c("cc", "share_map", "n_parties", "threshold",
                   "sharing_scheme"))
