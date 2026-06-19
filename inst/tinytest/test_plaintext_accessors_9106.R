## @openfhe-python: src/lib/bindings.cpp (Plaintext accessors) [PARTIAL]
##
## PlaintextImpl accessor surface.
##
## Coverage strategy:
##   (a) Construct a real BFV and a real CKKS plaintext and call
##       every getter that is meaningful for that scheme.
##   (b) For the four harness-unblockers (get_noise_scale_deg,
##       get_level, get_slots, plaintext_params_hash) verify they
##       return non-throwing values usable by the Signal 2 fixture.
##   (c) Exercise set_ckks_data_type and confirm the change is
##       visible via get_ckks_data_type.
##   (d) Verify that accessors declared virtual on the base class
##       with OPENFHE_THROW fallbacks do throw when called on the
##       wrong plaintext type (get_string_value on a CKKS plaintext).
library(openfhe.R)

# ── BFV plaintext accessors ─────────────────────────────
cc_bfv <- fhe_context("BFV", plaintext_modulus = 65537L, multiplicative_depth = 2L)
pt_bfv <- make_packed_plaintext(cc_bfv, c(1L, 2L, 3L, 4L, 5L))

expect_equal(get_encoding_type(pt_bfv),       PlaintextEncodings$PACKED_ENCODING)
expect_true(is_encoded(pt_bfv))
expect_equal(get_length(pt_bfv),              5L)
expect_equal(get_level(pt_bfv),               0L)
expect_equal(get_noise_scale_deg(pt_bfv),     1L)
expect_true(get_element_ring_dimension(pt_bfv) > 0L)
## LowBound / HighBound: derived from plaintext modulus 65537.
expect_equal(low_bound(pt_bfv),  -32769L)  ## -floor(65537/2) - 1
expect_equal(high_bound(pt_bfv),  32768L)  ## floor(65537/2)
## Integer accessor on a packed-integer plaintext: returns the
## underlying vector.
expect_equal(get_packed_value(pt_bfv), c(1L, 2L, 3L, 4L, 5L))

# ── CKKS plaintext accessors ────────────────────────────
cc_ckks <- fhe_context(
  "CKKS",
  multiplicative_depth = 2L,
  scaling_mod_size     = 50L,
  batch_size           = 8L,
  scaling_technique    = ScalingTechnique$FIXEDMANUAL
)
pt_ckks <- make_ckks_packed_plaintext(cc_ckks, c(0.1, 0.2, 0.3, 0.4))

expect_equal(get_encoding_type(pt_ckks), PlaintextEncodings$CKKS_PACKED_ENCODING)
expect_true(is_encoded(pt_ckks))
expect_equal(get_level(pt_ckks),          0L)
expect_equal(get_noise_scale_deg(pt_ckks), 1L)
expect_equal(get_ckks_data_type(pt_ckks), CKKSDataType$REAL)
expect_true(get_scaling_factor(pt_ckks) > 0)

## get_log_precision: meaningful only for CKKS; for a freshly
## encoded plaintext it may return 0 (no rescale yet), or a
## scheme-specific value. Just verify it does not throw.
expect_silent(get_log_precision(pt_ckks))

# ── The four harness unblockers (design.md §10) ──
expect_silent(get_noise_scale_deg(pt_ckks))
expect_silent(get_level(pt_ckks))
expect_silent(get_slots(pt_ckks))
expect_silent(plaintext_params_hash(pt_ckks))

## plaintext_params_hash: deterministic — identical plaintexts
## produce identical strings.
pt_ckks_copy <- make_ckks_packed_plaintext(cc_ckks, c(0.1, 0.2, 0.3, 0.4))
expect_equal(plaintext_params_hash(pt_ckks),
             plaintext_params_hash(pt_ckks_copy))

## plaintext_params_hash returns a non-empty string
expect_true(nchar(plaintext_params_hash(pt_ckks)) > 0L)
expect_true(is.character(plaintext_params_hash(pt_ckks)))

# ── set_ckks_data_type round trip ───────────────────────
## The setter mutates the plaintext in place via external pointer
## semantics. Set to COMPLEX and read back to verify.
set_ckks_data_type(pt_ckks, CKKSDataType$COMPLEX)
expect_equal(get_ckks_data_type(pt_ckks), CKKSDataType$COMPLEX)
## Restore to default for any other tests that look at this pt.
set_ckks_data_type(pt_ckks, CKKSDataType$REAL)
expect_equal(get_ckks_data_type(pt_ckks), CKKSDataType$REAL)

# ── set_level round trip on BFV plaintext ───────────────
set_level(pt_bfv, 1L)
expect_equal(get_level(pt_bfv), 1L)
set_level(pt_bfv, 0L)  ## restore

set_noise_scale_deg(pt_bfv, 2L)
expect_equal(get_noise_scale_deg(pt_bfv), 2L)
set_noise_scale_deg(pt_bfv, 1L)  ## restore

# ── get_formatted_values ────────────────────────────────
## The CKKS packed plaintext subclass overrides GetFormattedValues;
## the BFV packed subclass does not and throws "not implemented"
## via the base-class default. This is the per-subclass override
## model CLAUDE.md rule 10 warns about — the accessor binding is
## correct; runtime behavior depends on the concrete plaintext
## type.
expect_error(get_formatted_values(pt_bfv, precision = 2L),
             pattern = "OpenFHE error")
fv_ckks <- get_formatted_values(pt_ckks, precision = 3L)
expect_true(is.character(fv_ckks))
expect_true(nchar(fv_ckks) > 0L)

# ── Virtual-throw surface: wrong-type accessor raises cli_abort ──
## get_string_value on a CKKS plaintext: the base class throws
## OPENFHE_THROW("not a string"). catch_openfhe surfaces this as a
## cpp11::stop condition. The R wrapper does not currently catch and
## re-emit via cli_abort, so the error message is the raw cpp11 one.
expect_error(get_string_value(pt_ckks), pattern = "OpenFHE error")
expect_error(get_coef_packed_value(pt_ckks), pattern = "OpenFHE error")

# ── get_scheme_id on a Plaintext ────────────────────────
## Returns the plaintext's scheme tag. Caveat: the packed-encoding
## factory does not set this field, so it may return
## SchemeId$INVALID_SCHEME (0) on a freshly constructed plaintext
## regardless of the crypto context's scheme. The accessor is
## bound; its return value is advisory.
expect_silent(get_scheme_id(pt_bfv))
expect_silent(get_scheme_id(pt_ckks))

# ── Signal 2 fixture end-to-end (harness activation) ──
## Source the differential fixture for MakeCKKSPackedPlaintext and
## verify that with the live accessors in place, the probes
## for noiseScaleDeg / level / slots return real values (not the
## "probe_not_available" sentinel they returned in framework-
## validation mode). This is the "harness Signal 2 goes
## live for MakeCKKSPackedPlaintext" deliverable named in
## design.md §10.
fixture_path <- system.file(
  "tinytest", "fixtures", "differential",
  "MakeCKKSPackedPlaintext.R",
  package = "openfhe.R"
)
expect_true(nchar(fixture_path) > 0L && file.exists(fixture_path))

fixture <- source(fixture_path, local = TRUE)$value
expect_equal(fixture$method, "MakeCKKSPackedPlaintext")
expect_equal(fixture$mode, "live")

## Run the setup block in a fresh environment and build the
## default and perturbed plaintexts for each probe. The probes
## themselves take a Plaintext and return the metadata value they
## read.
fx_env <- new.env(parent = globalenv())
fx_env$cc_bundle <- eval(fixture$setup, envir = fx_env)
cc_fx     <- fx_env$cc_bundle$cc
values_fx <- fx_env$cc_bundle$values

## noiseScaleDeg probe: default=1, perturbed=2
pt_nsd_default   <- make_ckks_packed_plaintext(cc_fx, values_fx)
pt_nsd_perturbed <- make_ckks_packed_plaintext(cc_fx, values_fx)
set_noise_scale_deg(pt_nsd_perturbed, 2L)
nsd_probe <- fixture$perturbations$noiseScaleDeg$probe
expect_equal(nsd_probe(pt_nsd_default),   1L)
expect_equal(nsd_probe(pt_nsd_perturbed), 2L)
expect_true(nsd_probe(pt_nsd_perturbed) > nsd_probe(pt_nsd_default))  ## "increases"

## level probe: default=0, perturbed=1
pt_lvl_default   <- make_ckks_packed_plaintext(cc_fx, values_fx)
pt_lvl_perturbed <- make_ckks_packed_plaintext(cc_fx, values_fx)
set_level(pt_lvl_perturbed, 1L)
lvl_probe <- fixture$perturbations$level$probe
expect_equal(lvl_probe(pt_lvl_default),   0L)
expect_equal(lvl_probe(pt_lvl_perturbed), 1L)
expect_true(lvl_probe(pt_lvl_perturbed) > lvl_probe(pt_lvl_default))  ## "increases"

## slots probe: default=0 (→ BatchSize=8), perturbed=4
pt_slots_default   <- make_ckks_packed_plaintext(cc_fx, values_fx)
pt_slots_perturbed <- make_ckks_packed_plaintext(cc_fx, values_fx)
set_slots(pt_slots_perturbed, 4L)
slots_probe <- fixture$perturbations$slots$probe
expect_equal(slots_probe(pt_slots_default),   8L)  ## BatchSize
expect_equal(slots_probe(pt_slots_perturbed), 4L)
expect_true(slots_probe(pt_slots_perturbed) != slots_probe(pt_slots_default))  ## "changes"

## params probe: activated now that get_element_params(cc)
## exists. The probe reads plaintext slot count as a proxy for
## the params pointer-identity difference. Both nullptr and an
## explicit ElementParams produce identical observable metadata
## on current OpenFHE, so the probe is a no-op (deliberate).
pt_params_default   <- make_ckks_packed_plaintext(cc_fx, values_fx)
pt_params_perturbed <- make_ckks_packed_plaintext(
  cc_fx, values_fx, params = get_element_params(cc_fx)
)
params_probe <- fixture$perturbations$params$probe
expect_silent(params_probe(pt_params_default))
expect_silent(params_probe(pt_params_perturbed))
## Equal metadata, so the "changes" direction label is a
## deliberate no-op — see the fixture's params rationale.
expect_equal(params_probe(pt_params_default),
             params_probe(pt_params_perturbed))

# ── plaintext_params_hash discriminates different plaintexts ─
## Two plaintexts with different slot values should produce
## different hash strings (BFV packed values of different length
## → different GetLength).
pt_bfv_short <- make_packed_plaintext(cc_bfv, c(1L, 2L))
pt_bfv_long  <- make_packed_plaintext(cc_bfv, c(1L, 2L, 3L, 4L))
## Same level/noise/slots, so params_hash may actually match for
## BFV where slot count is fixed. The sensitive test is CKKS with
## different slots.
pt_ckks_4slot <- make_ckks_packed_plaintext(cc_ckks, c(0.1, 0.2, 0.3, 0.4))
## Default slots = 0 (full batch), so different values don't
## change params_hash for CKKS either. What WILL change is the
## level after a rescale or a set_level call.
pt_ckks_lvl1 <- make_ckks_packed_plaintext(cc_ckks, c(0.1, 0.2, 0.3, 0.4))
set_level(pt_ckks_lvl1, 1L)
expect_true(plaintext_params_hash(pt_ckks_4slot) !=
            plaintext_params_hash(pt_ckks_lvl1))
