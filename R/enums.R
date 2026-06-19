## OPENFHE PYTHON SOURCE: src/lib/bindings.cpp (enum definitions)
## ALL values taken directly from C++ headers. NEVER guess.
##
## Source files:
##   pke/constants-defs.h      — PKESchemeFeature, ScalingTechnique,
##                               ProxyReEncryptionMode, MultipartyMode,
##                               ExecutionMode, DecryptionNoiseMode,
##                               KeySwitchTechnique, EncryptionTechnique,
##                               MultiplicationTechnique, PlaintextEncodings,
##                               CKKSDataType, CompressionLevel
##   core/lattice/stdlatticeparms.h — SecurityLevel, DistributionType
##   core/lattice/constants-lattice.h — SecretKeyDist
##   binfhe/binfhe-constants.h — BINFHE_PARAMSET, BINFHE_METHOD,
##                               BINGATE, BINFHE_OUTPUT, KEYGEN_MODE

# ── PKE enums ────────────────────────────────────────────

#' PKE Scheme Features (bitmask)
#' Source: pke/constants-defs.h enum PKESchemeFeature
#' @export
Feature <- list(
  PKE          = 0x01L,
  KEYSWITCH    = 0x02L,
  PRE          = 0x04L,
  LEVELEDSHE   = 0x08L,
  ADVANCEDSHE  = 0x10L,
  MULTIPARTY   = 0x20L,
  FHE          = 0x40L,
  SCHEMESWITCH = 0x80L
)

#' Scaling Techniques (CKKS)
#' Source: pke/constants-defs.h enum ScalingTechnique
#' @export
ScalingTechnique <- list(
  FIXEDMANUAL            = 0L,
  FIXEDAUTO              = 1L,
  FLEXIBLEAUTO           = 2L,
  FLEXIBLEAUTOEXT        = 3L,
  COMPOSITESCALINGAUTO   = 4L,
  COMPOSITESCALINGMANUAL = 5L,
  NORESCALE              = 6L,
  INVALID_RS_TECHNIQUE   = 7L
)

#' Key Switching Techniques
#' Source: pke/constants-defs.h enum KeySwitchTechnique
#' @export
KeySwitchTechnique <- list(
  INVALID_KS_TECH = 0L,
  BV              = 1L,
  HYBRID          = 2L
)

#' Security Levels
#' Source: core/lattice/stdlatticeparms.h enum SecurityLevel
#' @export
SecurityLevel <- list(
  HEStd_128_classic = 0L,
  HEStd_192_classic = 1L,
  HEStd_256_classic = 2L,
  HEStd_128_quantum = 3L,
  HEStd_192_quantum = 4L,
  HEStd_256_quantum = 5L,
  HEStd_NotSet      = 6L
)

#' Secret Key Distribution
#' Source: core/lattice/constants-lattice.h enum SecretKeyDist
#' @export
SecretKeyDist <- list(
  GAUSSIAN            = 0L,
  UNIFORM_TERNARY     = 1L,
  SPARSE_TERNARY      = 2L,
  SPARSE_ENCAPSULATED = 3L
)

# ── BinFHE enums ─────────────────────────────────────────

#' Binary FHE Parameter Sets
#' Source: binfhe/binfhe-constants.h enum BINFHE_PARAMSET (sequential from 0)
#' @export
BinFHEParamSet <- list(
  TOY                = 0L,
  MEDIUM             = 1L,
  STD128_AP          = 2L,
  STD128             = 3L,
  STD128_3           = 4L,
  STD128_4           = 5L,
  STD128Q            = 6L,
  STD128Q_3          = 7L,
  STD128Q_4          = 8L,
  STD192             = 9L,
  STD192_3           = 10L,
  STD192_4           = 11L,
  STD192Q            = 12L,
  STD192Q_3          = 13L,
  STD192Q_4          = 14L,
  STD256             = 15L,
  STD256_3           = 16L,
  STD256_4           = 17L,
  STD256Q            = 18L,
  STD256Q_3          = 19L,
  STD256Q_4          = 20L,
  STD128_LMKCDEY     = 21L,
  STD128_3_LMKCDEY   = 22L,
  STD128_4_LMKCDEY   = 23L,
  STD128Q_LMKCDEY    = 24L,
  STD128Q_3_LMKCDEY  = 25L,
  STD128Q_4_LMKCDEY  = 26L,
  STD192_LMKCDEY     = 27L,
  STD192_3_LMKCDEY   = 28L,
  STD192_4_LMKCDEY   = 29L,
  STD192Q_LMKCDEY    = 30L,
  STD192Q_3_LMKCDEY  = 31L,
  STD192Q_4_LMKCDEY  = 32L,
  STD256_LMKCDEY     = 33L,
  STD256_3_LMKCDEY   = 34L,
  STD256_4_LMKCDEY   = 35L,
  STD256Q_LMKCDEY    = 36L,
  STD256Q_3_LMKCDEY  = 37L,
  STD256Q_4_LMKCDEY  = 38L,
  LPF_STD128         = 39L,
  LPF_STD128Q        = 40L,
  LPF_STD128_LMKCDEY  = 41L,
  LPF_STD128Q_LMKCDEY = 42L,
  SIGNED_MOD_TEST    = 43L
)

#' Binary FHE Methods
#' Source: binfhe/binfhe-constants.h enum BINFHE_METHOD
#' @export
BinFHEMethod <- list(
  INVALID_METHOD = 0L,
  AP             = 1L,
  GINX           = 2L,
  LMKCDEY        = 3L
)

#' Binary Gate Types
#' Source: binfhe/binfhe-constants.h enum BINGATE (sequential from 0)
#' @export
BinGate <- list(
  OR        = 0L,
  AND       = 1L,
  NOR       = 2L,
  NAND      = 3L,
  XOR       = 4L,
  XNOR      = 5L,
  MAJORITY  = 6L,
  AND3      = 7L,
  OR3       = 8L,
  AND4      = 9L,
  OR4       = 10L,
  XOR_FAST  = 11L,
  XNOR_FAST = 12L,
  CMUX      = 13L
)

#' Binary FHE Output Types
#' Source: binfhe/binfhe-constants.h enum BINFHE_OUTPUT
#' @export
BinFHEOutput <- list(
  INVALID_OUTPUT = 0L,
  FRESH          = 1L,
  BOOTSTRAPPED   = 2L,
  LARGE_DIM      = 3L,
  SMALL_DIM      = 4L
)

#' Key Generation Mode
#' Source: binfhe/binfhe-constants.h enum KEYGEN_MODE
#' @export
KeygenMode <- list(
  SYM_ENCRYPT = 0L,
  PUB_ENCRYPT = 1L
)

# ── Additional PKE enums ──────────────────

#' Plaintext Encoding Types
#' Source: pke/constants-defs.h enum PlaintextEncodings
#' @export
PlaintextEncodings <- list(
  INVALID_ENCODING     = 0L,
  COEF_PACKED_ENCODING = 1L,
  PACKED_ENCODING      = 2L,
  STRING_ENCODING      = 3L,
  CKKS_PACKED_ENCODING = 4L
)

#' Distribution Type (lattice parameters)
#' Source: core/lattice/stdlatticeparms.h enum DistributionType
#' @export
DistributionType <- list(
  HEStd_uniform = 0L,
  HEStd_error   = 1L,
  HEStd_ternary = 2L
)

#' Multiparty Mode
#' Source: pke/constants-defs.h enum MultipartyMode
#' @export
MultipartyMode <- list(
  INVALID_MULTIPARTY_MODE   = 0L,
  FIXED_NOISE_MULTIPARTY    = 1L,
  NOISE_FLOODING_MULTIPARTY = 2L
)

#' Execution Mode
#' Source: pke/constants-defs.h enum ExecutionMode
#' @export
ExecutionMode <- list(
  EXEC_EVALUATION       = 0L,
  EXEC_NOISE_ESTIMATION = 1L
)

#' Decryption Noise Mode
#' Source: pke/constants-defs.h enum DecryptionNoiseMode
#' @export
DecryptionNoiseMode <- list(
  FIXED_NOISE_DECRYPT    = 0L,
  NOISE_FLOODING_DECRYPT = 1L
)

#' Proxy Re-encryption Mode
#' Source: pke/constants-defs.h enum ProxyReEncryptionMode
#' R-side name `PREMode` is a shortened form (same pattern as
#' `Feature` for `PKESchemeFeature`).
#' @export
PREMode <- list(
  NOT_SET            = 0L,
  INDCPA             = 1L,
  FIXED_NOISE_HRA    = 2L,
  NOISE_FLOODING_HRA = 3L
)

#' Multiplication Technique (BFV)
#' Source: pke/constants-defs.h enum MultiplicationTechnique
#' @export
MultiplicationTechnique <- list(
  BEHZ             = 0L,
  HPS              = 1L,
  HPSPOVERQ        = 2L,
  HPSPOVERQLEVELED = 3L
)

#' Encryption Technique
#' Source: pke/constants-defs.h enum EncryptionTechnique
#' @export
EncryptionTechnique <- list(
  STANDARD = 0L,
  EXTENDED = 1L
)

#' CKKS Data Type
#' Source: pke/constants-defs.h enum CKKSDataType
#' @export
CKKSDataType <- list(
  REAL    = 0L,
  COMPLEX = 1L
)

#' Compression Level (interactive multi-party bootstrap)
#' Source: pke/constants-defs.h enum CompressionLevel
#' NOTE: values start at 2, not 0. The header comment explains that
#' compression levels 0 and 1 are not supported and the values are
#' not renumbered.
#' @export
CompressionLevel <- list(
  COMPACT = 2L,
  SLACK   = 3L
)

# ── Scheme identifier enum ────────────────

#' Scheme Identifier
#'
#' Returned by `get_scheme()` on any `CCParams` object. R-side name
#' `SchemeId` matches the upstream `pke/scheme/scheme-id.h` header
#' filename and avoids colliding with a potential future `Scheme` S7
#' class.
#'
#' Source: pke/scheme/scheme-id.h enum SCHEME
#' @export
SchemeId <- list(
  INVALID_SCHEME = 0L,
  CKKSRNS_SCHEME = 1L,
  BFVRNS_SCHEME  = 2L,
  BGVRNS_SCHEME  = 3L
)
