## R-SPECIFIC: S3 Ops group handler for Ciphertext arithmetic
##
## Uses S3 (not S7 Ops.S7_object) because S7's built-in Ops handler
## evaluates both e1 and e2, which fails for unary operators (-x, +x).
## Discovered in CVXR project (D0.1). This handler covers all Expression
## subclasses via S3 class vector walking.

.openfhe_Ops_handler <- function(e1, e2) {
  if (missing(e2)) {
    # Unary operators
    switch(.Generic,
      "-" = eval_negate(e1),
      "+" = e1,
      cli_abort("Unary {(.Generic)} not supported on {.cls Ciphertext}")
    )
  } else {
    # Binary operators — coerce non-Ciphertext operands
    switch(.Generic,
      "+" = eval_add(e1, e2),
      "-" = eval_sub(e1, e2),
      "*" = eval_mult(e1, e2),
      cli_abort("{(.Generic)} not supported on {.cls Ciphertext}")
    )
  }
}

# chooseOpsMethod registered in .onLoad() — see zzz.R
.openfhe_chooseOpsMethod <- function(x, y, mx, my, cl, reverse) TRUE
