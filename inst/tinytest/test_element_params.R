## R-SPECIFIC: ElementParams S7 class scaffolding.
## This file ships the class definition only. The full constructor
## path is via get_element_params(cc) and the params arg on
## make_ckks_packed_plaintext.
library(openfhe.R)

# ── Class hierarchy ─────────────────────────────────────
expect_true(S7::S7_inherits(ElementParams(ptr = NULL), ElementParams))
expect_true(S7::S7_inherits(ElementParams(ptr = NULL), OpenFHEObject))

# ── Null-pointer construction + print path ──────────────
## ElementParams has no constructor path from R when the
## get_element_params helper is unavailable. The scaffolding test
## confirms only that the class object constructs with ptr = NULL
## and that print does not error. Richer tests run once
## there is a real pointer source.
ep_null <- ElementParams(ptr = NULL)
expect_false(openfhe.R:::ptr_is_valid(ep_null))
## print returns the object invisibly; verify it does not throw
expect_silent(invisible(capture.output(print(ep_null))))
expect_identical(invisible(print(ep_null)), ep_null)
