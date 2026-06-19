## Threshold FHE: 5-party additive flow.
## @openfhe-python: pke/threshold-fhe-5p.py [PARTIAL: additive
## operations only — multiplications across threshold parties
## (MultiKeySwitchGen / MultiMultEvalKey / InsertEvalMultKey chain)
## and EvalSum across threshold parties are intentionally not
## exercised; the threshold-Cox vignette only needs additive
## accumulation and we wire those bindings only when a future
## example actually needs them.]
library(openfhe.R)

cc <- fhe_context("BFV",
  plaintext_modulus = 65537,
  multiplicative_depth = 2,
  features = c(Feature$MULTIPARTY))

# Round 1: chain key generation across 5 parties.
# Each party's MultipartyKeyGen takes the *previous* party's public
# key. The final party's public key (kp5@public) is the joint key
# under which everyone encrypts; no single party holds the joint
# secret.
kp1 <- key_gen(cc)
kp2 <- multiparty_key_gen(cc, kp1@public)
kp3 <- multiparty_key_gen(cc, kp2@public)
kp4 <- multiparty_key_gen(cc, kp3@public)
kp5 <- multiparty_key_gen(cc, kp4@public)

joint_pk <- kp5@public
sks <- list(kp1@secret, kp2@secret, kp3@secret, kp4@secret, kp5@secret)

# Three plaintext vectors. Use 8 slots so we can validate every
# slot of the homomorphic sum against the cleartext sum.
v1 <- 1:8
v2 <- c(1L, 0L, 0L, 1L, 1L, 0L, 0L, 0L)
v3 <- c(2L, 2L, 3L, 4L, 5L, 6L, 7L, 8L)

ct1 <- encrypt(joint_pk, make_packed_plaintext(cc, v1), cc = cc)
ct2 <- encrypt(joint_pk, make_packed_plaintext(cc, v2), cc = cc)
ct3 <- encrypt(joint_pk, make_packed_plaintext(cc, v3), cc = cc)

# Homomorphic addition under the joint key.
ct_sum <- ct1 + ct2 + ct3

# Threshold decryption: every party must contribute a partial
# decryption — any single refusal aborts. The high-level helper
# wraps lead + main + fusion when all keys are colocated (this
# test). The cox-threshold vignette will exercise the same calls
# in their distributed form.
pt_sum <- threshold_decrypt(cc, sks, ct_sum)
set_length(pt_sum, 8L)
expect_identical(get_packed_value(pt_sum)[1:8], v1 + v2 + v3)

# Spot-check the lower-level lead/main/fusion API directly with
# all 5 partials assembled by hand — this is the API a real
# distributed deployment would use, where each call happens at a
# different site.
partial1 <- multiparty_decrypt_lead(cc, kp1@secret, ct_sum)
partial2 <- multiparty_decrypt_main(cc, kp2@secret, ct_sum)
partial3 <- multiparty_decrypt_main(cc, kp3@secret, ct_sum)
partial4 <- multiparty_decrypt_main(cc, kp4@secret, ct_sum)
partial5 <- multiparty_decrypt_main(cc, kp5@secret, ct_sum)

pt_sum2 <- multiparty_decrypt_fusion(cc, partial1, partial2, partial3,
                                     partial4, partial5)
set_length(pt_sum2, 8L)
expect_identical(get_packed_value(pt_sum2)[1:8], v1 + v2 + v3)

# threshold_decrypt with too few keys must error.
expect_error(threshold_decrypt(cc, list(kp1@secret), ct_sum),
             pattern = "at least two")

# multiparty_decrypt_fusion with a single partial must error.
expect_error(multiparty_decrypt_fusion(cc, partial1),
             pattern = "at least two")
