## @openfhe-python: src/lib/bindings.cpp (bind_parameters) [PARTIAL: surface exposure only]
## extended CCParams setter surface for BFV/BGV/CKKS.
## Per discovery D013 the tests only exercise the **enabled** setters
## for each scheme — the disabled-upstream setters are not exposed in
## the R constructors and therefore not testable here.
##
## Coverage strategy:
##   (a) every new arg on BFVParams/BGVParams/CKKSParams is called at
##       least once with a valid value that does not throw;
##   (b) one end-to-end round trip per scheme verifies the extended
##       setters still produce a usable context via fhe_context() + key
##       gen + encrypt/decrypt;
##   (c) disabled-upstream setters are verified unexposed by checking
##       formals() does not list them.
library(openfhe.R)

# ── BFV: exercise every new setter arg ─────────────────
p_bfv <- BFVParams(
  plaintext_modulus        = 65537L,
  multiplicative_depth     = 2L,
  scaling_mod_size         = 60L,
  batch_size               = 8L,
  security_level           = SecurityLevel$HEStd_128_classic,
  secret_key_dist          = SecretKeyDist$UNIFORM_TERNARY,
  key_switch_technique     = KeySwitchTechnique$BV,
  ring_dim                 = 16384L,
  digit_size               = 0L,
  num_large_digits         = 0L,
  standard_deviation       = 3.19,
  multiparty_mode          = MultipartyMode$FIXED_NOISE_MULTIPARTY,
  threshold_num_of_parties = 1L,
  multiplication_technique = MultiplicationTechnique$HPSPOVERQLEVELED,
  max_relin_sk_deg         = 2L,
  pre_mode                 = PREMode$INDCPA,
  eval_add_count           = 0L,
  key_switch_count         = 0L,
  encryption_technique     = EncryptionTechnique$STANDARD
)
expect_true(S7::S7_inherits(p_bfv, BFVParams))
expect_true(openfhe.R:::ptr_is_valid(p_bfv))

# ── BGV: exercise every new setter arg ─────────────────
p_bgv <- BGVParams(
  plaintext_modulus        = 65537L,
  multiplicative_depth     = 2L,
  scaling_mod_size         = 60L,
  scaling_technique        = ScalingTechnique$FLEXIBLEAUTO,
  batch_size               = 8L,
  first_mod_size            = 60L,
  security_level           = SecurityLevel$HEStd_128_classic,
  secret_key_dist          = SecretKeyDist$UNIFORM_TERNARY,
  key_switch_technique     = KeySwitchTechnique$HYBRID,
  ring_dim                 = 16384L,
  digit_size               = 0L,
  num_large_digits         = 3L,
  standard_deviation       = 3.19,
  multiparty_mode          = MultipartyMode$FIXED_NOISE_MULTIPARTY,
  threshold_num_of_parties = 1L,
  max_relin_sk_deg         = 2L,
  pre_mode                 = PREMode$INDCPA,
  statistical_security     = 30L,
  num_adversarial_queries  = 1L,
  eval_add_count           = 0L,
  key_switch_count         = 0L,
  pre_num_hops             = 1L
)
expect_true(S7::S7_inherits(p_bgv, BGVParams))
expect_true(openfhe.R:::ptr_is_valid(p_bgv))

# ── CKKS: exercise every new setter arg ────────────────
p_ckks <- CKKSParams(
  multiplicative_depth               = 4L,
  scaling_mod_size                   = 50L,
  scaling_technique                  = ScalingTechnique$FLEXIBLEAUTO,
  batch_size                         = 8L,
  first_mod_size                     = 60L,
  security_level                     = SecurityLevel$HEStd_128_classic,
  secret_key_dist                    = SecretKeyDist$UNIFORM_TERNARY,
  key_switch_technique               = KeySwitchTechnique$HYBRID,
  ring_dim                           = 16384L,
  digit_size                         = 0L,
  num_large_digits                   = 3L,
  interactive_boot_compression_level = CompressionLevel$COMPACT,
  standard_deviation                 = 3.19,
  register_word_size                 = 32L,
  ckks_data_type                     = CKKSDataType$REAL,
  max_relin_sk_deg                   = 2L,
  pre_mode                           = PREMode$INDCPA,
  execution_mode                     = ExecutionMode$EXEC_EVALUATION,
  decryption_noise_mode              = DecryptionNoiseMode$FIXED_NOISE_DECRYPT,
  noise_estimate                     = 0.0,
  desired_precision                  = 25.0,
  statistical_security               = 30L,
  num_adversarial_queries            = 1L,
  composite_degree                   = 0L
)
expect_true(S7::S7_inherits(p_ckks, CKKSParams))
expect_true(openfhe.R:::ptr_is_valid(p_ckks))

# ── Disabled setters are NOT exposed in R constructors ─
## D013: 13 BFV-disabled + 10 BGV-disabled + 8 CKKS-disabled setters.
## Any attempt to pass one via `...` reaches do.call on the param
## constructor and hits the R-level "unused argument" error.
bfv_args  <- names(formals(BFVParams))
bgv_args  <- names(formals(BGVParams))
ckks_args <- names(formals(CKKSParams))

## BFV must not expose any CKKS/BGV-only knobs
expect_false("scaling_technique"              %in% bfv_args)
expect_false("first_mod_size"                 %in% bfv_args)
expect_false("pre_num_hops"                   %in% bfv_args)
expect_false("execution_mode"                 %in% bfv_args)
expect_false("decryption_noise_mode"          %in% bfv_args)
expect_false("noise_estimate"                 %in% bfv_args)
expect_false("desired_precision"              %in% bfv_args)
expect_false("statistical_security"           %in% bfv_args)
expect_false("num_adversarial_queries"        %in% bfv_args)
expect_false("interactive_boot_compression_level" %in% bfv_args)
expect_false("composite_degree"               %in% bfv_args)
expect_false("register_word_size"             %in% bfv_args)
expect_false("ckks_data_type"                 %in% bfv_args)

## BGV must not expose BFV-only or CKKS-only knobs
expect_false("encryption_technique"           %in% bgv_args)
expect_false("multiplication_technique"       %in% bgv_args)
expect_false("execution_mode"                 %in% bgv_args)
expect_false("decryption_noise_mode"          %in% bgv_args)
expect_false("noise_estimate"                 %in% bgv_args)
expect_false("desired_precision"              %in% bgv_args)
expect_false("interactive_boot_compression_level" %in% bgv_args)
expect_false("composite_degree"               %in% bgv_args)
expect_false("register_word_size"             %in% bgv_args)
expect_false("ckks_data_type"                 %in% bgv_args)

## CKKS must not expose plaintext_modulus, eval_add_count,
## key_switch_count, encryption_technique, multiplication_technique,
## pre_num_hops, multiparty_mode, threshold_num_of_parties
expect_false("plaintext_modulus"              %in% ckks_args)
expect_false("eval_add_count"                 %in% ckks_args)
expect_false("key_switch_count"               %in% ckks_args)
expect_false("encryption_technique"           %in% ckks_args)
expect_false("multiplication_technique"       %in% ckks_args)
expect_false("pre_num_hops"                   %in% ckks_args)
expect_false("multiparty_mode"                %in% ckks_args)
expect_false("threshold_num_of_parties"       %in% ckks_args)

# ── Constructor arg counts match D013 enabled-setter counts ───
## Each count is (enabled setters) + 1 (the invisible S7 arg handling)
## Actually formals() on an S7 constructor returns only the user args,
## not the S7 plumbing. The raw count is the D013 enabled-setter count.
expect_equal(length(bfv_args),  19L)  ## D013: 19 enabled on BFV
expect_equal(length(bgv_args),  22L)  ## D013: 22 enabled on BGV
expect_equal(length(ckks_args), 24L)  ## D013: 24 enabled on CKKS

# ── End-to-end round trip: BFV with the new setters ────
cc_bfv <- fhe_context(
  "BFV",
  plaintext_modulus    = 65537L,
  multiplicative_depth = 2L,
  security_level       = SecurityLevel$HEStd_128_classic,
  secret_key_dist      = SecretKeyDist$UNIFORM_TERNARY,
  standard_deviation   = 3.19
)
kp_bfv  <- key_gen(cc_bfv, eval_mult = TRUE)
pt_bfv  <- make_packed_plaintext(cc_bfv, c(1L, 2L, 3L, 4L))
ct_bfv  <- encrypt(kp_bfv@public, pt_bfv, cc_bfv)
out_bfv <- decrypt(ct_bfv, kp_bfv@secret, cc_bfv)
set_length(out_bfv, 4L)
expect_equal(get_packed_value(out_bfv), c(1L, 2L, 3L, 4L))

# ── End-to-end round trip: BGV with the new setters ────
cc_bgv <- fhe_context(
  "BGV",
  plaintext_modulus    = 65537L,
  multiplicative_depth = 2L,
  scaling_technique    = ScalingTechnique$FLEXIBLEAUTO,
  secret_key_dist      = SecretKeyDist$UNIFORM_TERNARY
)
kp_bgv  <- key_gen(cc_bgv, eval_mult = TRUE)
pt_bgv  <- make_packed_plaintext(cc_bgv, c(10L, 20L, 30L))
ct_bgv  <- encrypt(kp_bgv@public, pt_bgv, cc_bgv)
out_bgv <- decrypt(ct_bgv, kp_bgv@secret, cc_bgv)
set_length(out_bgv, 3L)
expect_equal(get_packed_value(out_bgv), c(10L, 20L, 30L))

# ── End-to-end round trip: CKKS with the new setters ───
cc_ckks <- fhe_context(
  "CKKS",
  multiplicative_depth = 2L,
  scaling_mod_size     = 50L,
  batch_size           = 8L,
  scaling_technique    = ScalingTechnique$FLEXIBLEAUTO,
  secret_key_dist      = SecretKeyDist$UNIFORM_TERNARY,
  ckks_data_type       = CKKSDataType$REAL
)
kp_ckks  <- key_gen(cc_ckks, eval_mult = TRUE)
pt_ckks  <- make_ckks_packed_plaintext(cc_ckks, c(0.1, 0.2, 0.3, 0.4))
ct_ckks  <- encrypt(kp_ckks@public, pt_ckks, cc_ckks)
out_ckks <- decrypt(ct_ckks, kp_ckks@secret, cc_ckks)
set_length(out_ckks, 4L)
dec_ckks <- get_real_packed_value(out_ckks)
expect_true(max(abs(dec_ckks - c(0.1, 0.2, 0.3, 0.4))) < 1e-3)

# ── Unused arg rejection: CKKS should reject BFV-only setters ──
expect_error(
  CKKSParams(plaintext_modulus = 65537L),
  pattern = "unused argument"
)
expect_error(
  BFVParams(scaling_technique = ScalingTechnique$FLEXIBLEAUTO),
  pattern = "unused argument"
)
