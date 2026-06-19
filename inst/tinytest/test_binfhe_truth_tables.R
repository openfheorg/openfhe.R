## Phase 8: BinFHE truth tables — all 2x2 gate outputs
## @openfhe-python: boolean-truth-tables.py [FULL]
library(openfhe.R)

# ── Setup (same as boolean-truth-tables.py: default STD128 + GINX) ──
ctx <- bin_fhe_context(BinFHEParamSet$STD128, BinFHEMethod$GINX)
sk  <- bin_key_gen(ctx)
bin_bt_key_gen(ctx, sk)

# Helper: evaluate `gate` on all four (a,b) ∈ {0,1}² with fresh
# ciphertexts each time (OpenFHE requires independent ciphertexts per
# EvalBinGate call — see agent_checklist.md).
truth_table <- function(gate) {
  bits <- expand.grid(a = c(0L, 1L), b = c(0L, 1L))
  vapply(seq_len(nrow(bits)), function(i) {
    ct_a <- bin_encrypt(ctx, sk, bits$a[i])
    ct_b <- bin_encrypt(ctx, sk, bits$b[i])
    bin_decrypt(ctx, sk, eval_bin_gate(ctx, gate, ct_a, ct_b))
  }, integer(1))
}

# Reference truth tables over the row order (0,0), (1,0), (0,1), (1,1)
expected <- list(
  AND  = c(0L, 0L, 0L, 1L),
  OR   = c(0L, 1L, 1L, 1L),
  NAND = c(1L, 1L, 1L, 0L),
  NOR  = c(1L, 0L, 0L, 0L),
  XOR  = c(0L, 1L, 1L, 0L),
  XNOR = c(1L, 0L, 0L, 1L)
)

## @openfhe-python: boolean-truth-tables.py — AND
expect_equal(truth_table(BinGate$AND),  expected$AND)

## @openfhe-python: boolean-truth-tables.py — OR
expect_equal(truth_table(BinGate$OR),   expected$OR)

## @openfhe-python: boolean-truth-tables.py — NAND
expect_equal(truth_table(BinGate$NAND), expected$NAND)

## @openfhe-python: boolean-truth-tables.py — NOR
expect_equal(truth_table(BinGate$NOR),  expected$NOR)

## @openfhe-python: boolean-truth-tables.py — XOR
expect_equal(truth_table(BinGate$XOR),  expected$XOR)

## @openfhe-python: boolean-truth-tables.py — XNOR
expect_equal(truth_table(BinGate$XNOR), expected$XNOR)

## @openfhe-python: boolean-truth-tables.py — XOR_FAST (same table as XOR)
expect_equal(truth_table(BinGate$XOR_FAST),  expected$XOR)

## @openfhe-python: boolean-truth-tables.py — XNOR_FAST (same table as XNOR)
expect_equal(truth_table(BinGate$XNOR_FAST), expected$XNOR)
