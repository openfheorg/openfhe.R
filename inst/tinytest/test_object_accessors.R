## OPENFHE PYTHON SOURCE: src/lib/bindings.cpp (object accessors bound at OpenFHE 1.6.1)
##
## @openfhe-python: src/lib/bindings.cpp [FULL: ParmType and EncodingParams getters; CryptoContext GetModulus, GetModulusCKKS, GetRootOfUnity, GetScheme, setSchemeId, SerializedObjectName, SerializedVersion, the Clear* caches, the five parameter setters, GetPlaintextForDecrypt, GetUniqueValues and the automorphism key index queries; EvalKey key tag; key GetCryptoContext; Ciphertext Clone, CloneEmpty, elements, hop level, SetEncodingType; Plaintext Encode, Decode, GetElementModulus, GetEncodingParams, SetFormat]
library(openfhe.R)

digits <- function(s) is.character(s) && length(s) == 1L && grepl("^[0-9]+$", s)
## Compare two non-negative integers written as digit strings.
less_than <- function(a, b) nchar(a) < nchar(b) || (nchar(a) == nchar(b) && a < b)

clear_eval_mult_keys()
clear_eval_automorphism_keys()

# ══ BFV context ══════════════════════════════════════════
cc <- fhe_context("BFV", plaintext_modulus = 65537, multiplicative_depth = 2,
                  features = c(Feature$PRE))
kp <- key_gen(cc, eval_mult = TRUE)
v <- c(1L, 2L, 3L, 4L, 5L, 6L)
enc <- function(x = v) encrypt(kp@public, make_packed_plaintext(cc, x), cc = cc)
dec <- function(ct) {
  pt <- decrypt(ct, kp@secret, cc = cc)
  set_length(pt, length(v))
  as.integer(get_packed_value(pt))
}

# ── ElementParams (Python: ParmType) ─────────────────────
ep <- get_element_params(cc)
expect_identical(ring_dimension(ep), ring_dimension(cc))
expect_identical(get_cyclotomic_order(ep), get_cyclotomic_order(cc))
expect_identical(get_cyclotomic_order(ep), 2L * ring_dimension(ep))
q <- get_modulus(ep)
expect_true(digits(q))
expect_identical(get_modulus(cc), q)
## The modulus is far beyond 2^53: only the string holds it.
expect_true(nchar(q) > 16L)

## A deeper context has a larger modulus.
cc_deep <- fhe_context("BFV", plaintext_modulus = 65537, multiplicative_depth = 6)
expect_true(less_than(q, get_modulus(cc_deep)))

# ── EncodingParams ───────────────────────────────────────
encp <- get_encoding_params(cc)
expect_identical(get_plaintext_modulus(encp), 65537)
expect_identical(get_batch_size(encp), get_batch_size(cc))
expect_true(is.numeric(get_plaintext_generator(encp)))

# ── Root of unity ────────────────────────────────────────
## The composite (double-CRT) parameters of a context carry no single
## root of unity; the library reports 0.
r <- get_root_of_unity(cc)
expect_true(digits(r))
expect_true(less_than(r, q))

# ── Scheme object and identifier ─────────────────────────
sch <- get_scheme(cc)
expect_true(S7::S7_inherits(sch, SchemeBase))
expect_true(openfhe.R:::ptr_is_valid(sch))
## On a parameter object get_scheme() is the identifier.
expect_identical(get_scheme(BFVParams()), SchemeId$BFVRNS_SCHEME)

expect_identical(get_scheme_id(cc), SchemeId$BFVRNS_SCHEME)
set_scheme_id(cc, SchemeId$BGVRNS_SCHEME)
expect_identical(get_scheme_id(cc), SchemeId$BGVRNS_SCHEME)
set_scheme_id(cc, SchemeId$BFVRNS_SCHEME)
expect_identical(get_scheme_id(cc), SchemeId$BFVRNS_SCHEME)

# ── Serialized name and version ──────────────────────────
expect_identical(serialized_object_name(cc), "CryptoContext")
sv <- serialized_version(cc)
expect_true(is.integer(sv) && sv >= 1L)

# ── Parameter setters on a live context ──────────────────
old_depth <- get_multiplicative_depth(cc)
set_multiplicative_depth(cc, old_depth + 3L)
expect_equal(get_multiplicative_depth(cc), old_depth + 3L)
set_multiplicative_depth(cc, old_depth)
expect_equal(get_multiplicative_depth(cc), old_depth)

for (k in c(3L, 5L)) {
  set_eval_add_count(cc, k)
  expect_equal(get_eval_add_count(cc), k)
  set_key_switch_count(cc, k)
  expect_equal(get_key_switch_count(cc), k)
}
set_eval_add_count(cc, 0L); set_key_switch_count(cc, 0L)
expect_error(set_eval_add_count(cc, -1L), "non-negative whole number")
## The noise estimate is a CKKS parameter (set and read back below).
## On BFV the library accepts the setter and refuses the getter.
expect_silent(set_noise_estimate(cc, 1.5))
expect_error(get_noise_estimate(cc), "not available for BFVRNS")
## The hop count is a BGV parameter; on BFV the getter is refused.
expect_error(get_pre_num_hops(cc), "not available for BFVRNS")
cg <-fhe_context("BGV", plaintext_modulus = 65537, multiplicative_depth = 1)
for (k in c(1L, 2L)) {
  set_pre_num_hops(cg, k)
  expect_equal(get_pre_num_hops(cg), k)
}
set_pre_num_hops(cg, 0L)

# ── Caches ───────────────────────────────────────────────
## Nothing to clear on a BFV context: the combined form is a no-op,
## the specific ones are refused.
expect_silent(clear_all_ckks_caches(cc))
expect_error(clear_bootstrap_precom(cc))
expect_error(clear_scheme_switch_precom(cc))

# ── An empty plaintext for decryption ────────────────────
pt_empty <- get_plaintext_for_decrypt(PlaintextEncodings$PACKED_ENCODING, ep, encp)
expect_true(S7::S7_inherits(pt_empty, Plaintext))
expect_identical(get_encoding_type(pt_empty), PlaintextEncodings$PACKED_ENCODING)
pt_coef <- get_plaintext_for_decrypt(PlaintextEncodings$COEF_PACKED_ENCODING, ep, encp)
expect_identical(get_encoding_type(pt_coef), PlaintextEncodings$COEF_PACKED_ENCODING)
expect_error(get_plaintext_for_decrypt(PlaintextEncodings$PACKED_ENCODING, encp, ep),
             "ElementParams")

# ── Automorphism key indices ─────────────────────────────
expect_identical(get_unique_values(c(1L, 2L, 3L), c(5L, 2L, 4L, 3L)), c(4L, 5L))
expect_identical(get_unique_values(integer(0), c(2L, 1L)), c(1L, 2L))

tag <- get_key_tag(kp@secret)
expect_identical(get_existing_eval_automorphism_key_indices(tag), integer(0))
eval_at_index_key_gen(cc, kp@secret, c(1L, 2L))
have <- sort(find_automorphism_indices(cc, c(1L, 2L)))
expect_identical(get_existing_eval_automorphism_key_indices(tag), have)
other <- find_automorphism_index(cc, 3L)
expect_identical(get_eval_automorphism_no_key_indices(tag, c(have, other)), other)
## For a tag with no keys every index asked about is missing.
expect_identical(get_eval_automorphism_no_key_indices("no-such-tag", c(7L, 5L)),
                 c(5L, 7L))

# ── Keys ─────────────────────────────────────────────────
ek <- get_eval_mult_key_vector(tag)[[1L]]
expect_identical(get_key_tag(ek), tag)
set_key_tag(ek, "renamed")
expect_identical(get_key_tag(ek), "renamed")
set_key_tag(ek, tag)
expect_error(get_key_tag(EvalKey()), "EvalKey")

for (key in list(kp@public, kp@secret)) {
  kcc <- get_crypto_context(key)
  expect_true(S7::S7_inherits(kcc, CryptoContext))
  expect_identical(ring_dimension(kcc), ring_dimension(cc))
  expect_identical(get_modulus(kcc), q)
}

# ── Ciphertext: clone ────────────────────────────────────
ct <- enc()
copy <- clone(ct)
alias <- ct
eval_add_in_place(ct, ct)
## The clone keeps the old value; a second name for the same object
## does not.
expect_identical(dec(copy), v)
expect_identical(dec(alias), 2L * v)

empty <- clone_empty(ct)
expect_identical(number_ciphertext_elements(empty), 0L)
expect_identical(get_key_tag(empty), get_key_tag(ct))

# ── Ciphertext: elements ─────────────────────────────────
ct <- enc()
expect_identical(number_ciphertext_elements(ct), 2L)
prod3 <- eval_mult_no_relin(enc(), enc())
expect_identical(number_ciphertext_elements(prod3), 3L)

els <- get_elements(ct)
expect_identical(length(els), 2L)
expect_true(all(vapply(els, function(e) S7::S7_inherits(e, DCRTPoly), logical(1))))
expect_identical(length(get_elements_mutable(ct)), 2L)

## The elements of one ciphertext, put into an empty clone, decrypt to
## the same value.
rebuilt <- clone_empty(ct)
r <- set_elements(rebuilt, els)
expect_identical(r, rebuilt)
expect_identical(number_ciphertext_elements(rebuilt), 2L)
expect_identical(dec(rebuilt), v)
rebuilt2 <- set_elements_move(clone_empty(ct), get_elements_mutable(ct))
expect_identical(dec(rebuilt2), v)
## The elements are copies: changing the source afterwards does not
## change the rebuilt ciphertext.
eval_add_in_place(ct, ct)
expect_identical(dec(rebuilt), v)

expect_error(set_elements(rebuilt, list(ct)), "DCRTPoly")
expect_error(set_elements(rebuilt, els[[1L]]), "DCRTPoly")

remove_element(prod3, 3L)
expect_identical(number_ciphertext_elements(prod3), 2L)
expect_error(remove_element(prod3, 3L), "out of range")
expect_error(remove_element(prod3, 0L), "positive integer")

# ── Ciphertext: hop level and encoding type ──────────────
ct <- enc()
expect_identical(get_hop_level(ct), 0L)
set_hop_level(ct, 2L)
expect_identical(get_hop_level(ct), 2L)
set_hop_level(ct, 5L)
expect_identical(get_hop_level(ct), 5L)

expect_identical(get_encoding_type(ct), PlaintextEncodings$PACKED_ENCODING)
set_encoding_type(ct, PlaintextEncodings$COEF_PACKED_ENCODING)
expect_identical(get_encoding_type(ct), PlaintextEncodings$COEF_PACKED_ENCODING)

# ── Plaintext ────────────────────────────────────────────
pt <- make_packed_plaintext(cc, v)
expect_true(digits(get_element_modulus(pt)))
pt_encp <- get_encoding_params(pt)
expect_true(S7::S7_inherits(pt_encp, EncodingParams))
expect_identical(get_plaintext_modulus(pt_encp), 65537)
## encode() recomputes the element from the value and leaves the
## value as it was.
expect_true(encode(pt))
expect_identical(as.integer(get_packed_value(pt))[seq_along(v)], v)
expect_identical(set_format(pt, Format$COEFFICIENT), pt)
set_format(pt, Format$EVALUATION)
expect_error(decode(pt, depth = 1L), "all of")

# ══ CKKS context ═════════════════════════════════════════
ck <- fhe_context("CKKS", multiplicative_depth = 2L, scaling_mod_size = 50L,
                  first_mod_size = 60L, batch_size = 8L)
ck55 <- fhe_context("CKKS", multiplicative_depth = 2L, scaling_mod_size = 50L,
                    first_mod_size = 55L, batch_size = 8L)
q0 <- get_modulus_ckks(ck)
expect_true(digits(q0))
## q_0 has first_mod_size bits: 60 bits is beyond what a double holds.
expect_true(less_than("576460752303423488", q0))      # 2^59
expect_true(less_than(q0, "1152921504606846976"))      # 2^60
expect_true(less_than(get_modulus_ckks(ck55), "36028797018963968"))  # 2^55
expect_error(get_modulus_ckks(cc), "not a CKKS context")

for (ne in c(3.5, 5.5)) {
  set_noise_estimate(ck, ne)
  expect_equal(get_noise_estimate(ck), ne)
}
set_noise_estimate(ck, 0)

expect_silent(clear_all_ckks_caches(ck))
expect_silent(clear_bootstrap_precom(ck))
expect_silent(clear_scheme_switch_precom(ck))

## decode(), both forms. Each reads the plaintext's ring element and
## overwrites the value; decrypt() has already decoded its result, so
## these calls are checked for running and for changing the value, not
## for a value.
kk <- key_gen(ck)
x <- c(0.5, 1.5, 2.5, 3.5)
ctk <- encrypt(kk@public, make_ckks_packed_plaintext(ck, x), cc = ck)
ptk <- decrypt(ctk, kk@secret, cc = ck)
expect_equal(get_real_packed_value(ptk)[seq_along(x)], x, tolerance = 1e-6)
expect_true(decode(ptk, depth = get_noise_scale_deg(ctk),
                   scaling_factor = get_scaling_factor(ctk),
                   scal_tech = get_scaling_technique(ck),
                   execution_mode = ExecutionMode$EXEC_EVALUATION))
expect_false(isTRUE(all.equal(get_real_packed_value(ptk)[seq_along(x)], x,
                              tolerance = 1e-6)))
ptb <- decrypt(enc(), kp@secret, cc = cc)
expect_true(decode(ptb))
