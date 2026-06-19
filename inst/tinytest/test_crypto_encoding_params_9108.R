## R-SPECIFIC: CryptoParameters + EncodingParams S7 class scaffolding.
## This file ships the two class definitions only. Constructor
## paths (via get_crypto_parameters(cc) and get_encoding_params(cc))
## are part of the CryptoContext getter fleet.
library(openfhe.R)

# ── CryptoParameters class hierarchy ────────────────────
expect_true(S7::S7_inherits(CryptoParameters(ptr = NULL), CryptoParameters))
expect_true(S7::S7_inherits(CryptoParameters(ptr = NULL), OpenFHEObject))

cp_null <- CryptoParameters(ptr = NULL)
expect_false(openfhe.R:::ptr_is_valid(cp_null))
expect_silent(invisible(capture.output(print(cp_null))))
expect_identical(invisible(print(cp_null)), cp_null)

# ── EncodingParams class hierarchy ──────────────────────
expect_true(S7::S7_inherits(EncodingParams(ptr = NULL), EncodingParams))
expect_true(S7::S7_inherits(EncodingParams(ptr = NULL), OpenFHEObject))

ep_null <- EncodingParams(ptr = NULL)
expect_false(openfhe.R:::ptr_is_valid(ep_null))
expect_silent(invisible(capture.output(print(ep_null))))
expect_identical(invisible(print(ep_null)), ep_null)
