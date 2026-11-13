## Phase 6: Binary FHE tests
## @openfhe-python: boolean.py [PARTIAL: steps omitted: the example's compound circuit (1 AND 1) OR (1 AND (NOT 1))]
library(openfhe.R)

# ── Setup ────────────────────────────────────────────────
ctx <- bin_fhe_context(BinFHEParamSet$STD128, BinFHEMethod$GINX)
sk <- bin_key_gen(ctx)
bin_bt_key_gen(ctx, sk)

# ── Encrypt Boolean values ───────────────────────────────
# Each ciphertext must be independently encrypted (OpenFHE requirement)
ct1a <- bin_encrypt(ctx, sk, 1L)
ct1b <- bin_encrypt(ctx, sk, 1L)
ct0a <- bin_encrypt(ctx, sk, 0L)
ct0b <- bin_encrypt(ctx, sk, 0L)

expect_equal(bin_decrypt(ctx, sk, ct1a), 1L)
expect_equal(bin_decrypt(ctx, sk, ct0a), 0L)

# ── AND gate ─────────────────────────────────────────────
ct_and_11 <- eval_bin_gate(ctx, BinGate$AND, ct1a, ct1b)
expect_equal(bin_decrypt(ctx, sk, ct_and_11), 1L)  # 1 AND 1 = 1

ct_and_10 <- eval_bin_gate(ctx, BinGate$AND, ct1a, ct0a)
expect_equal(bin_decrypt(ctx, sk, ct_and_10), 0L)  # 1 AND 0 = 0

# ── OR gate ──────────────────────────────────────────────
ct_or_10 <- eval_bin_gate(ctx, BinGate$OR, bin_encrypt(ctx, sk, 1L), bin_encrypt(ctx, sk, 0L))
expect_equal(bin_decrypt(ctx, sk, ct_or_10), 1L)  # 1 OR 0 = 1

ct_or_00 <- eval_bin_gate(ctx, BinGate$OR, bin_encrypt(ctx, sk, 0L), bin_encrypt(ctx, sk, 0L))
expect_equal(bin_decrypt(ctx, sk, ct_or_00), 0L)  # 0 OR 0 = 0

# ── NAND gate ────────────────────────────────────────────
ct_nand_11 <- eval_bin_gate(ctx, BinGate$NAND, bin_encrypt(ctx, sk, 1L), bin_encrypt(ctx, sk, 1L))
expect_equal(bin_decrypt(ctx, sk, ct_nand_11), 0L)  # NOT(1 AND 1) = 0

# ── NOR gate ─────────────────────────────────────────────
ct_nor_00 <- eval_bin_gate(ctx, BinGate$NOR, bin_encrypt(ctx, sk, 0L), bin_encrypt(ctx, sk, 0L))
expect_equal(bin_decrypt(ctx, sk, ct_nor_00), 1L)  # NOT(0 OR 0) = 1

# ── XOR gate ─────────────────────────────────────────────
ct_xor_10 <- eval_bin_gate(ctx, BinGate$XOR, bin_encrypt(ctx, sk, 1L), bin_encrypt(ctx, sk, 0L))
expect_equal(bin_decrypt(ctx, sk, ct_xor_10), 1L)  # 1 XOR 0 = 1

ct_xor_11 <- eval_bin_gate(ctx, BinGate$XOR, bin_encrypt(ctx, sk, 1L), bin_encrypt(ctx, sk, 1L))
expect_equal(bin_decrypt(ctx, sk, ct_xor_11), 0L)  # 1 XOR 1 = 0

# ── NOT gate ─────────────────────────────────────────────
ct_not1 <- eval_not(ctx, bin_encrypt(ctx, sk, 1L))
expect_equal(bin_decrypt(ctx, sk, ct_not1), 0L)  # NOT 1 = 0

ct_not0 <- eval_not(ctx, bin_encrypt(ctx, sk, 0L))
expect_equal(bin_decrypt(ctx, sk, ct_not0), 1L)  # NOT 0 = 1

# ── Compound: (1 AND 1) OR (NOT 1) = 1 OR 0 = 1 ────────
ct_compound <- eval_bin_gate(ctx, BinGate$OR,
  eval_bin_gate(ctx, BinGate$AND, bin_encrypt(ctx, sk, 1L), bin_encrypt(ctx, sk, 1L)),
  eval_not(ctx, bin_encrypt(ctx, sk, 1L)))
expect_equal(bin_decrypt(ctx, sk, ct_compound), 1L)

## Release the bootstrapping keys now: R's collector does not see the
## memory behind a context, so the keys would otherwise stay until a
## collection happens to run (notes/discoveries/D043).
bin_clear_bt_keys(ctx)
