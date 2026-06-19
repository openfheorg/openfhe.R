## @openfhe-python: src/lib/bindings.cpp (enum definitions) [FULL]
## Verifies the 10 new enums and the ScalingTechnique fix
## for missing INVALID_RS_TECHNIQUE. Values cross-checked against
## temp/openfhe-rlibomp/include/openfhe/pke/constants-defs.h and
## core/lattice/stdlatticeparms.h per CLAUDE.md rule 10.
library(openfhe.R)

# ── ScalingTechnique completeness (D012 fix) ────────────
expect_equal(length(ScalingTechnique), 8L)
expect_equal(ScalingTechnique$INVALID_RS_TECHNIQUE, 7L)
expect_true("INVALID_RS_TECHNIQUE" %in% names(ScalingTechnique))

# ── PlaintextEncodings (pke/constants-defs.h line 104) ──
expect_equal(length(PlaintextEncodings), 5L)
expect_equal(PlaintextEncodings$INVALID_ENCODING,     0L)
expect_equal(PlaintextEncodings$COEF_PACKED_ENCODING, 1L)
expect_equal(PlaintextEncodings$PACKED_ENCODING,      2L)
expect_equal(PlaintextEncodings$STRING_ENCODING,      3L)
expect_equal(PlaintextEncodings$CKKS_PACKED_ENCODING, 4L)

# ── DistributionType (stdlatticeparms.h line 62) ────────
expect_equal(length(DistributionType), 3L)
expect_equal(DistributionType$HEStd_uniform, 0L)
expect_equal(DistributionType$HEStd_error,   1L)
expect_equal(DistributionType$HEStd_ternary, 2L)

# ── MultipartyMode (constants-defs.h line 70) ───────────
expect_equal(length(MultipartyMode), 3L)
expect_equal(MultipartyMode$INVALID_MULTIPARTY_MODE,   0L)
expect_equal(MultipartyMode$FIXED_NOISE_MULTIPARTY,    1L)
expect_equal(MultipartyMode$NOISE_FLOODING_MULTIPARTY, 2L)

# ── ExecutionMode (constants-defs.h line 76) ────────────
expect_equal(length(ExecutionMode), 2L)
expect_equal(ExecutionMode$EXEC_EVALUATION,       0L)
expect_equal(ExecutionMode$EXEC_NOISE_ESTIMATION, 1L)

# ── DecryptionNoiseMode (constants-defs.h line 81) ──────
expect_equal(length(DecryptionNoiseMode), 2L)
expect_equal(DecryptionNoiseMode$FIXED_NOISE_DECRYPT,    0L)
expect_equal(DecryptionNoiseMode$NOISE_FLOODING_DECRYPT, 1L)

# ── PREMode / ProxyReEncryptionMode (line 63) ───────────
expect_equal(length(PREMode), 4L)
expect_equal(PREMode$NOT_SET,            0L)
expect_equal(PREMode$INDCPA,             1L)
expect_equal(PREMode$FIXED_NOISE_HRA,    2L)
expect_equal(PREMode$NOISE_FLOODING_HRA, 3L)

# ── MultiplicationTechnique (line 97) ───────────────────
expect_equal(length(MultiplicationTechnique), 4L)
expect_equal(MultiplicationTechnique$BEHZ,             0L)
expect_equal(MultiplicationTechnique$HPS,              1L)
expect_equal(MultiplicationTechnique$HPSPOVERQ,        2L)
expect_equal(MultiplicationTechnique$HPSPOVERQLEVELED, 3L)

# ── EncryptionTechnique (line 92) ───────────────────────
expect_equal(length(EncryptionTechnique), 2L)
expect_equal(EncryptionTechnique$STANDARD, 0L)
expect_equal(EncryptionTechnique$EXTENDED, 1L)

# ── CKKSDataType (line 117) ─────────────────────────────
expect_equal(length(CKKSDataType), 2L)
expect_equal(CKKSDataType$REAL,    0L)
expect_equal(CKKSDataType$COMPLEX, 1L)

# ── CompressionLevel (line 148) — non-sequential! ───────
expect_equal(length(CompressionLevel), 2L)
expect_equal(CompressionLevel$COMPACT, 2L)
expect_equal(CompressionLevel$SLACK,   3L)
## COMPACT is 2, not 0: header comment explains that compression
## levels 0 and 1 are unsupported and not renumbered. A naive
## sequential-from-zero R list would silently misdispatch.
expect_true(CompressionLevel$COMPACT != 0L)
