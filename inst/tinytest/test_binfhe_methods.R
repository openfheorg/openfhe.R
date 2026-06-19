## Phase 8: BinFHE with different methods (AP, LMKCDEY)
## @openfhe-python: boolean-ap.py [FULL]
## @openfhe-python: boolean-lmkcdey.py [FULL]
library(openfhe.R)

## Heavy bootstrapping (multiple STD128 bootstrap-key contexts) — skip on
## CRAN for time/memory, but run everywhere else: on CI (GitHub Actions
## sets CI=true) and locally via tinytest::test_all() (sets TT_AT_HOME).
if (!at_home() && Sys.getenv("CI") != "true")
  exit_file("skipped on CRAN: heavy bootstrapping (runs on CI and at_home)")

# ── AP method ────────────────────────────────────────────
## @openfhe-python: boolean-ap.py — AP bootstrapping method
ctx_ap <- bin_fhe_context(BinFHEParamSet$STD128_AP, BinFHEMethod$AP)
sk_ap <- bin_key_gen(ctx_ap)
bin_bt_key_gen(ctx_ap, sk_ap)

ct1_ap <- bin_encrypt(ctx_ap, sk_ap, 1L)
ct0_ap <- bin_encrypt(ctx_ap, sk_ap, 0L)

ct_and <- eval_bin_gate(ctx_ap, BinGate$AND, ct1_ap, ct0_ap)
expect_equal(bin_decrypt(ctx_ap, sk_ap, ct_and), 0L)

ct_or <- eval_bin_gate(ctx_ap, BinGate$OR, ct1_ap, ct0_ap)
expect_equal(bin_decrypt(ctx_ap, sk_ap, ct_or), 1L)

# ── LMKCDEY method ──────────────────────────────────────
## @openfhe-python: boolean-lmkcdey.py — LMKCDEY bootstrapping method
## @openfhe-python: boolean-lmkcdey.py — LMKCDEY needs _LMKCDEY param set
ctx_lm <- bin_fhe_context(BinFHEParamSet$STD128_LMKCDEY, BinFHEMethod$LMKCDEY)
sk_lm <- bin_key_gen(ctx_lm)
bin_bt_key_gen(ctx_lm, sk_lm)

ct1_lm <- bin_encrypt(ctx_lm, sk_lm, 1L)
ct0_lm <- bin_encrypt(ctx_lm, sk_lm, 0L)

ct_nand <- eval_bin_gate(ctx_lm, BinGate$NAND, ct1_lm, ct0_lm)
expect_equal(bin_decrypt(ctx_lm, sk_lm, ct_nand), 1L)  # NAND(1,0) = 1

ct_xor <- eval_bin_gate(ctx_lm, BinGate$XOR, ct1_lm, ct0_lm)
expect_equal(bin_decrypt(ctx_lm, sk_lm, ct_xor), 1L)  # XOR(1,0) = 1
