## @openfhe-python: NONE — SerializeEvalSumKey/DeserializeEvalSumKey are R-first [R-ONLY]
##
## sum-key file-based serialize/
## deserialize. The C++ SerializeEvalSumKey /
## DeserializeEvalSumKey entry points delegate to the
## automorphism-key backend (cryptocontext-ser.h lines 730/756),
## so sum-key and automorphism-key serialization produce
## identical bytes on disk and can be read through either
## entry point. Both are exposed so fixture authors can match
## whichever OpenFHE doc they are reading.
##
## openfhe-python v1.5.1.0 does not bind the sum-key serialize
## entry points — Python users reach for the automorphism form
## directly. This is an R-only surface extension logged in
## notes/upstream-defects.md.
library(openfhe.R)

# ── Clean slate ─────────────────────────────────────────

clear_eval_mult_keys()
clear_eval_automorphism_keys()

# ── BFV context with MULTIPARTY + ADVANCEDSHE ──────────

cc <- fhe_context("BFV",
  plaintext_modulus = 65537,
  multiplicative_depth = 2,
  batch_size = 16L,
  features = c(Feature$MULTIPARTY, Feature$ADVANCEDSHE)
)
kp <- key_gen(cc, eval_mult = TRUE)
eval_sum_key_gen(cc, kp@secret)
tag <- get_key_tag(kp@secret)

# ── serialize_eval_keys(type = "sum"): formals check ────

expect_identical(names(formals(serialize_eval_keys)),
                 c("filename", "type", "format", "key_tag"))
## Verify "sum" is accepted as a valid type (match.arg).
expect_equal(eval(formals(serialize_eval_keys)$type),
             c("mult", "automorphism", "sum"))
expect_equal(eval(formals(deserialize_eval_keys)$type),
             c("mult", "automorphism", "sum"))

# ── Serialize sum keys, clear, deserialize, verify ──────

sum_file <- tempfile(fileext = ".bin")
on.exit(unlink(sum_file), add = TRUE)

ok <- serialize_eval_keys(sum_file, type = "sum", key_tag = tag)
expect_true(ok)
expect_true(file.exists(sum_file))
expect_true(file.size(sum_file) > 0L)

## Clear the cc-internal sum-key registry and verify it is
## empty.
clear_eval_automorphism_keys()  # shared backing storage with sum
expect_equal(length(get_all_eval_sum_keys()), 0L)

## Deserialize via the sum-key entry point and verify the
## registry is repopulated.
ok_d <- deserialize_eval_keys(sum_file, type = "sum")
expect_true(ok_d)
all_sum_after <- get_all_eval_sum_keys()
expect_true(tag %in% names(all_sum_after))
expect_true(S7::S7_inherits(all_sum_after[[tag]], EvalKeyMap))

# ── Cross-entry equivalence: sum ↔ automorphism ─────────

## A file written with type = "sum" should deserialize via
## type = "automorphism" and vice versa — the sum-key
## serialization delegates to the automorphism backend on
## the C++ side, so the bytes are identical.
clear_eval_automorphism_keys()
expect_equal(length(get_all_eval_automorphism_keys()), 0L)

## Read the sum-written file via the automorphism entry point.
ok_x <- deserialize_eval_keys(sum_file, type = "automorphism")
expect_true(ok_x)
all_aut_after <- get_all_eval_automorphism_keys()
expect_true(tag %in% names(all_aut_after))

## Round-trip the other direction: write via automorphism,
## read via sum.
aut_file <- tempfile(fileext = ".bin")
on.exit(unlink(aut_file), add = TRUE)
serialize_eval_keys(aut_file, type = "automorphism", key_tag = tag)

clear_eval_automorphism_keys()
ok_r <- deserialize_eval_keys(aut_file, type = "sum")
expect_true(ok_r)
all_sum_via_aut <- get_all_eval_sum_keys()
expect_true(tag %in% names(all_sum_via_aut))

# ── JSON format path ────────────────────────────────────

json_file <- tempfile(fileext = ".json")
on.exit(unlink(json_file), add = TRUE)

clear_eval_automorphism_keys()
eval_sum_key_gen(cc, kp@secret)  # repopulate for serialization
ok_json <- serialize_eval_keys(json_file, type = "sum",
                               format = "json", key_tag = tag)
expect_true(ok_json)
expect_true(file.exists(json_file))

clear_eval_automorphism_keys()
ok_json_r <- deserialize_eval_keys(json_file, type = "sum",
                                    format = "json")
expect_true(ok_json_r)
expect_true(tag %in% names(get_all_eval_sum_keys()))

# ── End-to-end eval_sum round-trip after deserialize ────

## The deserialized sum keys must be usable by eval_sum on a
## fresh ciphertext. This is the audience-A checkpoint/resume
## acceptance criterion: serialize → clear → deserialize →
## compute should produce the same result as the pre-
## serialization cleartext.
x <- 1L:8L
pt <- make_packed_plaintext(cc, x)
ct <- encrypt(kp@public, pt, cc = cc)
ct_sum <- eval_sum(ct, batch_size = 8L)
pt_res <- decrypt(ct_sum, kp@secret, cc = cc)
set_length(pt_res, 8L)
## eval_sum places the total in slot 1.
expect_identical(get_packed_value(pt_res)[1], sum(x))
