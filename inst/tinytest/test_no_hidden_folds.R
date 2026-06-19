## OPENFHE PYTHON SOURCE: (R-side static check; no Python source)
## R-SPECIFIC: harness improvement preventing convenience-fold parity gaps in the *KeyGen family.
##
## Pin the rule that every
## `CryptoContext__*KeyGen` cpp11 binding has a standalone
## R-level wrapper of matching name, even when the binding is
## *also* invoked as a side effect inside a folded convenience
## helper (e.g., `key_gen(cc, eval_mult, rotations)`).
##
## The gap-matrix
## (`notes/blocks/E-bindings-rewrite/gap-matrix.md` rows 236,
## 368, 369) recommended standalone exports for
## `EvalMultKeyGen`, `EvalRotateKeyGen`, and `EvalAtIndexKeyGen`
## but the original implementation landed only the convenience
## fold inside `key_gen()`. The folded form creates a *new*
## keypair as a side effect — the wrong semantics for any
## threshold or multi-party flow that already holds a
## secret-key share. `inventory-r.md:262` flagged this hazard
## explicitly ("opaque from a parity-projection perspective").
## This file enforces what the inventory comment foresaw.
##
## Implementation: namespace introspection. Listing the
## installed package's namespace gives every cpp11 binding
## (each binding is wrapped by an R function that calls .Call)
## without depending on R/cpp11.R as a source file — the latter
## is not preserved in the install tree under R CMD check.

library(openfhe.R)

## @openfhe-python: N/A FOR R [R-only static check; cross-stack parity is exercised by test_surface_parity.R]

if (!requireNamespace("tinytest", quietly = TRUE)) {
  return(invisible(NULL))
}

## ── Map cpp11 binding names to expected standalone R names ──
##
## CryptoContext__EvalRotateKeyGen → eval_rotate_key_gen
## CryptoContext__EvalMultKeyGen   → eval_mult_key_gen
## CryptoContext__EvalSumKeyGen    → eval_sum_key_gen
## CryptoContext__EvalAtIndexKeyGen → eval_at_index_key_gen
## MultiEvalAtIndexKeyGen__        → multi_eval_at_index_key_gen
## MultiEvalAutomorphismKeyGen__   → multi_eval_automorphism_key_gen
## MultiEvalSumKeyGen__            → multi_eval_sum_key_gen
## MultipartyKeyGen                → multiparty_key_gen
canon <- function(name) {
  s <- sub("^CryptoContext__", "", name)
  s <- sub("__.*$", "", s)
  ## Insert underscores at lower-to-upper transitions and
  ## upper-acronym-to-mixed transitions, then lowercase.
  s <- gsub("([a-z0-9])([A-Z])", "\\1_\\2", s)
  s <- gsub("([A-Z]+)([A-Z][a-z])", "\\1_\\2", s)
  tolower(s)
}

ns <- asNamespace("openfhe.R")
exports <- getNamespaceExports("openfhe.R")
all_fns <- ls(envir = ns, all.names = TRUE)
## DLL trampolines (`_openfhe_<lowercase>`) are not the cpp11
## binding wrappers — they are the C-level registration symbols
## that the wrapper functions trampoline through. Filter them
## out so canonicalization doesn't see them.
all_fns <- all_fns[!startsWith(all_fns, "_")]
key_gen_bindings <- grep("KeyGen(__|$)", all_fns, value = TRUE)

expected_r_name <- vapply(key_gen_bindings, canon, character(1),
                          USE.NAMES = FALSE)

## Allowlist: bindings whose canonical wrapper is intentionally
## not a one-line standalone. `CryptoContext__KeyGen` and
## `BinFHEContext__KeyGen` are constructor primitives whose
## sole user-facing wrappers are `key_gen()` and
## `bin_fhe_context()` respectively — both fold extra setup
## (eval-mult / rotation registration; arbFunc / non-arbFunc
## context selection) into a single user-friendly call. Adding
## thin standalone "create just the keypair" exports would
## duplicate functionality with no caller.
ALLOWED_FOLDED <- c("CryptoContext__KeyGen", "BinFHEContext__KeyGen")

drop <- key_gen_bindings %in% ALLOWED_FOLDED
key_gen_bindings <- key_gen_bindings[!drop]
expected_r_name  <- expected_r_name[!drop]

## ── Confirm each expected standalone wrapper exists and is exported ──

violations <- character()
for (i in seq_along(key_gen_bindings)) {
  fn <- expected_r_name[i]
  ok <- fn %in% exports && exists(fn, envir = ns, mode = "function")
  if (!ok) {
    violations <- c(violations,
                    sprintf("  %s (cpp11 binding %s) not exported",
                            fn, key_gen_bindings[i]))
  }
}

if (length(violations) > 0L) {
  cat("Missing standalone *KeyGen wrappers:\n",
      paste(violations, collapse = "\n"), "\n", sep = "")
}

expect_equal(length(violations), 0L,
             info = paste0(
               "Every CryptoContext__*KeyGen cpp11 binding must have ",
               "a standalone R export of matching snake_case name. ",
               "This package adds eval_mult_key_gen / ",
               "eval_rotate_key_gen / eval_at_index_key_gen for the ",
               "gap documented at gap-matrix.md rows 236/368/369. ",
               "If this fails on a new binding, add a thin wrapper ",
               "next to the existing eval_*_key_gen exports in ",
               "R/eval-key-map.R, or extend ALLOWED_FOLDED if the ",
               "binding is a deliberate constructor primitive."))
