## R-SPECIFIC: CKKS tolerance table regression guard
##
## Regression guard for the `fhe_ckks_tolerance()`
## per-level loss table. The Stage 1 numeric-dispatch form
## shipped with **placeholder** per-level loss values
## that were never empirically validated against CKKS circuits
## (empirical validation was deferred to a pre-release harness
## tightening pass). Several test files all noted this debt and
## worked around it by using a fixed `tol <- 1e-6` instead of
## the helper's own output.
##
## These values are **pinned** as they stand.
## The tightening pass — measuring actual CKKS noise against
## the model and updating the per-level loss table — is
## scoped to post-Block-E (pre-2.0.0 polish). This file's job
## is to catch accidental drift in the meantime: if the
## placeholder table values are edited without updating this
## test, the drift is visible on the next `R CMD check`.
##
## A future implementation agent that validates the table
## empirically should update the expected values here and
## leave a note in the commit message pointing at the
## measurement fixture.
library(openfhe.R)

## Relative tolerance pinning the placeholder values to their
## binary-exact double representation. 1e-15 is at the edge of
## double precision and is the tightest guard that avoids
## round-trip-format flakes.
tol_pin <- 1e-15

# ── Scaling-technique-specific baselines ────────────────

## FIXEDMANUAL: explicit rescale, no per-level loss
## (k=8 * 2^-50).
expect_equal(fhe_ckks_tolerance(4L, 50L, "FIXEDMANUAL"),
             8 * 2^-50, tolerance = tol_pin)

## FLEXIBLEAUTO: 1.0 per-level loss (k=8 * 2^(-50 + 4*1) =
## 8 * 2^-46).
expect_equal(fhe_ckks_tolerance(4L, 50L, "FLEXIBLEAUTO"),
             8 * 2^-46, tolerance = tol_pin)

## FLEXIBLEAUTOEXT: same per-level loss model as FLEXIBLEAUTO
## (1.0), at depth 8, 59-bit scaling:
## k=8 * 2^(-59 + 8*1) = 8 * 2^-51.
expect_equal(fhe_ckks_tolerance(8L, 59L, "FLEXIBLEAUTOEXT"),
             8 * 2^-51, tolerance = tol_pin)

## FIXEDAUTO: 0.5 per-level loss (k=8 * 2^(-50 + 6*0.5) =
## 8 * 2^-47).
expect_equal(fhe_ckks_tolerance(6L, 50L, "FIXEDAUTO"),
             8 * 2^-47, tolerance = tol_pin)

## NORESCALE: 0.0 per-level loss (depth irrelevant;
## k=8 * 2^-50).
expect_equal(fhe_ckks_tolerance(2L, 50L, "NORESCALE"),
             8 * 2^-50, tolerance = tol_pin)

# ── Integer enum dispatch equivalence ───────────────────

## The Stage 1 numeric method accepts either a character
## name or an integer `ScalingTechnique` value; the integer
## enum dispatch must produce the same output as the character
## form. Guarded as a regression check against the
## `scaling_technique_name()` reverse lookup.
expect_equal(
  fhe_ckks_tolerance(4L, 50L, ScalingTechnique$FIXEDMANUAL),
  fhe_ckks_tolerance(4L, 50L, "FIXEDMANUAL"),
  tolerance = tol_pin
)
expect_equal(
  fhe_ckks_tolerance(4L, 50L, ScalingTechnique$FLEXIBLEAUTO),
  fhe_ckks_tolerance(4L, 50L, "FLEXIBLEAUTO"),
  tolerance = tol_pin
)
