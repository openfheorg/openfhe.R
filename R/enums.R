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
#'
#' Mirrors the C++ enum `PKESchemeFeature` in `pke/constants-defs.h`.
#' The values are bit flags, so several may be combined with
#' [bitwOr()] to describe a set of capabilities.
#'
#' @return A named `list` of 8 integer scalars. Each element carries the
#'   integer value the OpenFHE C++ enumerator of the same name has, and
#'   names a capability of a crypto context: `PKE` (encryption and
#'   decryption), `KEYSWITCH`, `PRE` (proxy re-encryption),
#'   `LEVELEDSHE` (leveled homomorphic arithmetic), `ADVANCEDSHE`,
#'   `MULTIPARTY`, `FHE` (bootstrapping) and `SCHEMESWITCH`. Pass an
#'   element to [enable_feature()] to turn that capability on for a
#'   context.
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
#'
#' Mirrors the C++ enum `ScalingTechnique` in `pke/constants-defs.h`.
#'
#' @return A named `list` of 8 integer scalars, each the value of the
#'   OpenFHE C++ enumerator of the same name. The element chosen tells a
#'   CKKS context how to manage the scaling factor between
#'   multiplications: `FIXEDMANUAL` leaves rescaling to the caller,
#'   `FIXEDAUTO` and the `FLEXIBLE*` variants rescale automatically with
#'   increasing precision, the `COMPOSITESCALING*` variants split the
#'   scaling factor across several moduli, and `NORESCALE` disables
#'   rescaling. `INVALID_RS_TECHNIQUE` marks an unset value. Pass an
#'   element as the `scaling_technique` argument of [CKKSParams()],
#'   [BGVParams()] or [fhe_context()].
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
#'
#' Mirrors the C++ enum `KeySwitchTechnique` in `pke/constants-defs.h`.
#'
#' @return A named `list` of 3 integer scalars, each the value of the
#'   OpenFHE C++ enumerator of the same name. `BV` selects the
#'   Brakerski-Vaikuntanathan digit-decomposition key switch and
#'   `HYBRID` the hybrid variant, which is the usual choice;
#'   `INVALID_KS_TECH` marks an unset value. Pass an element as the
#'   `key_switch_technique` argument of [CKKSParams()], [BFVParams()],
#'   [BGVParams()] or [fhe_context()].
#' @export
KeySwitchTechnique <- list(
  INVALID_KS_TECH = 0L,
  BV              = 1L,
  HYBRID          = 2L
)

#' Security Levels
#'
#' Mirrors the C++ enum `SecurityLevel` in
#' `core/lattice/stdlatticeparms.h`.
#'
#' @return A named `list` of 7 integer scalars, each the value of the
#'   OpenFHE C++ enumerator of the same name. An element names the
#'   number of bits of security the ring dimension is chosen to provide
#'   against a classical (`HEStd_*_classic`) or quantum
#'   (`HEStd_*_quantum`) adversary, following the HomomorphicEncryption.org
#'   standard tables. `HEStd_NotSet` skips the table lookup, in which
#'   case the ring dimension must be set explicitly. Pass an element as the
#'   `security_level` argument of [CKKSParams()], [BFVParams()],
#'   [BGVParams()] or [fhe_context()].
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
#'
#' Mirrors the C++ enum `SecretKeyDist` in
#' `core/lattice/constants-lattice.h`.
#'
#' @return A named `list` of 4 integer scalars, each the value of the
#'   OpenFHE C++ enumerator of the same name, naming the distribution
#'   the secret key polynomial is drawn from: `GAUSSIAN`,
#'   `UNIFORM_TERNARY` (the default, coefficients uniform on
#'   -1, 0, 1), `SPARSE_TERNARY` (ternary with a fixed small Hamming
#'   weight) and `SPARSE_ENCAPSULATED`. Pass an element as the
#'   `secret_key_dist` argument of [CKKSParams()], [BFVParams()],
#'   [BGVParams()] or [fhe_context()].
#' @export
SecretKeyDist <- list(
  GAUSSIAN            = 0L,
  UNIFORM_TERNARY     = 1L,
  SPARSE_TERNARY      = 2L,
  SPARSE_ENCAPSULATED = 3L
)

# ── BinFHE enums ─────────────────────────────────────────

#' Binary FHE Parameter Sets
#'
#' Mirrors the C++ enum `BINFHE_PARAMSET` in `binfhe/binfhe-constants.h`,
#' whose enumerators are numbered sequentially from 0.
#'
#' @return A named `list` of 44 integer scalars, each the value of the
#'   OpenFHE C++ enumerator of the same name. An element names a
#'   pre-tabulated set of lattice parameters for the boolean-circuit
#'   (BinFHE) schemes: `TOY` and `MEDIUM` are insecure sizes for
#'   experimentation, and the `STD128`, `STD192` and `STD256` families
#'   give the corresponding bits of security, with the `Q` suffix
#'   denoting a larger ciphertext modulus, the `_3` and `_4` suffixes
#'   3- and 4-input gates, `LMKCDEY` the Lee-Micciancio-Kim-Choi-Deryabin-Eom-Yoo
#'   bootstrapping method and `LPF` a low-probability-of-failure
#'   variant. Pass an element as the `paramset` argument of
#'   [bin_fhe_context()].
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
#'
#' Mirrors the C++ enum `BINFHE_METHOD` in `binfhe/binfhe-constants.h`.
#'
#' @return A named `list` of 4 integer scalars, each the value of the
#'   OpenFHE C++ enumerator of the same name, selecting the
#'   bootstrapping method a boolean-circuit context uses: `AP`
#'   (Alperin-Sheriff-Peikert), `GINX` (Gama-Izabachene-Nguyen-Xie, the
#'   default) or `LMKCDEY`. `INVALID_METHOD` marks an unset value. Pass
#'   an element as the `method` argument of [bin_fhe_context()].
#' @export
BinFHEMethod <- list(
  INVALID_METHOD = 0L,
  AP             = 1L,
  GINX           = 2L,
  LMKCDEY        = 3L
)

#' Binary Gate Types
#'
#' Mirrors the C++ enum `BINGATE` in `binfhe/binfhe-constants.h`, whose
#' enumerators are numbered sequentially from 0.
#'
#' @return A named `list` of 14 integer scalars, each the value of the
#'   OpenFHE C++ enumerator of the same name, naming the boolean gate to
#'   evaluate on encrypted bits: the two-input gates `OR`, `AND`, `NOR`,
#'   `NAND`, `XOR`, `XNOR` and the faster `XOR_FAST`, `XNOR_FAST`; the
#'   three- and four-input `AND3`, `OR3`, `AND4`, `OR4`; and `MAJORITY`
#'   and `CMUX`. Pass an element as the `gate` argument of
#'   [eval_bin_gate()].
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
#'
#' Mirrors the C++ enum `BINFHE_OUTPUT` in `binfhe/binfhe-constants.h`.
#'
#' @return A named `list` of 5 integer scalars, each the value of the
#'   OpenFHE C++ enumerator of the same name, describing the form the
#'   ciphertext produced by a BinFHE operation should take: `FRESH`
#'   (noise reset to the level of a fresh encryption), `BOOTSTRAPPED`,
#'   `LARGE_DIM` and `SMALL_DIM` (the LWE dimension the result is
#'   expressed in). `INVALID_OUTPUT` marks an unset value. Pass an
#'   element as the `output` argument of [bin_encrypt()].
#' @export
BinFHEOutput <- list(
  INVALID_OUTPUT = 0L,
  FRESH          = 1L,
  BOOTSTRAPPED   = 2L,
  LARGE_DIM      = 3L,
  SMALL_DIM      = 4L
)

#' Key Generation Mode
#'
#' Mirrors the C++ enum `KEYGEN_MODE` in `binfhe/binfhe-constants.h`.
#'
#' @return A named `list` of 2 integer scalars, each the value of the
#'   OpenFHE C++ enumerator of the same name: `SYM_ENCRYPT` generates
#'   only the material needed for symmetric-key encryption, while
#'   `PUB_ENCRYPT` additionally generates a public key. Pass an element
#'   as the `keygen_mode` argument of [bin_bt_key_gen()].
#' @export
KeygenMode <- list(
  SYM_ENCRYPT = 0L,
  PUB_ENCRYPT = 1L
)

# ── Additional PKE enums ──────────────────

#' Plaintext Encoding Types
#'
#' Mirrors the C++ enum `PlaintextEncodings` in
#' `pke/constants-defs.h`.
#'
#' @return A named `list` of 5 integer scalars, each the value of the
#'   OpenFHE C++ enumerator of the same name, naming how values are laid
#'   out inside a plaintext polynomial: `COEF_PACKED_ENCODING`,
#'   `PACKED_ENCODING` (integer SIMD slots), `STRING_ENCODING` and
#'   `CKKS_PACKED_ENCODING` (approximate real or complex slots).
#'   `INVALID_ENCODING` marks an unset value. This is the value reported
#'   by `get_encoding_type()` on a `Plaintext`.
#' @export
PlaintextEncodings <- list(
  INVALID_ENCODING     = 0L,
  COEF_PACKED_ENCODING = 1L,
  PACKED_ENCODING      = 2L,
  STRING_ENCODING      = 3L,
  CKKS_PACKED_ENCODING = 4L
)

#' Distribution Type (lattice parameters)
#'
#' Mirrors the C++ enum `DistributionType` in
#' `core/lattice/stdlatticeparms.h`.
#'
#' @return A named `list` of 3 integer scalars, each the value of the
#'   OpenFHE C++ enumerator of the same name, naming the secret
#'   distribution a row of the HomomorphicEncryption.org standard
#'   parameter tables applies to: `HEStd_uniform`, `HEStd_error` or
#'   `HEStd_ternary`.
#' @export
DistributionType <- list(
  HEStd_uniform = 0L,
  HEStd_error   = 1L,
  HEStd_ternary = 2L
)

#' Multiparty Mode
#'
#' Mirrors the C++ enum `MultipartyMode` in `pke/constants-defs.h`.
#'
#' @return A named `list` of 3 integer scalars, each the value of the
#'   OpenFHE C++ enumerator of the same name, selecting how a threshold
#'   context masks the secret shares: `FIXED_NOISE_MULTIPARTY` adds a
#'   fixed amount of noise, while `NOISE_FLOODING_MULTIPARTY` adds
#'   enough to give provable circuit privacy at a higher cost.
#'   `INVALID_MULTIPARTY_MODE` marks an unset value. Pass an element as the
#'   `multiparty_mode` argument of [BFVParams()], [BGVParams()] or
#'   [fhe_context()].
#' @export
MultipartyMode <- list(
  INVALID_MULTIPARTY_MODE   = 0L,
  FIXED_NOISE_MULTIPARTY    = 1L,
  NOISE_FLOODING_MULTIPARTY = 2L
)

#' Execution Mode
#'
#' Mirrors the C++ enum `ExecutionMode` in `pke/constants-defs.h`.
#'
#' @return A named `list` of 2 integer scalars, each the value of the
#'   OpenFHE C++ enumerator of the same name: `EXEC_EVALUATION` runs the
#'   computation normally, while `EXEC_NOISE_ESTIMATION` runs it only to
#'   measure the noise growth, which is the first of the two passes
#'   needed when decryption uses noise flooding. Pass an element as the
#'   `execution_mode` argument of [CKKSParams()] or [fhe_context()].
#' @export
ExecutionMode <- list(
  EXEC_EVALUATION       = 0L,
  EXEC_NOISE_ESTIMATION = 1L
)

#' Decryption Noise Mode
#'
#' Mirrors the C++ enum `DecryptionNoiseMode` in
#' `pke/constants-defs.h`.
#'
#' @return A named `list` of 2 integer scalars, each the value of the
#'   OpenFHE C++ enumerator of the same name: `FIXED_NOISE_DECRYPT`
#'   decrypts with a fixed noise estimate, while
#'   `NOISE_FLOODING_DECRYPT` floods the result with extra noise so that
#'   the decryption itself leaks nothing about the circuit. Pass an
#'   element as the `decryption_noise_mode` argument of [CKKSParams()]
#'   or [fhe_context()].
#' @export
DecryptionNoiseMode <- list(
  FIXED_NOISE_DECRYPT    = 0L,
  NOISE_FLOODING_DECRYPT = 1L
)

#' Proxy Re-encryption Mode
#'
#' Mirrors the C++ enum `ProxyReEncryptionMode` in
#' `pke/constants-defs.h`. The R-side name `PREMode` is a shortened
#' form, the same pattern as `Feature` for `PKESchemeFeature`.
#'
#' @return A named `list` of 4 integer scalars, each the value of the
#'   OpenFHE C++ enumerator of the same name, naming the security notion
#'   the re-encryption key should satisfy: `INDCPA`,
#'   `FIXED_NOISE_HRA` or `NOISE_FLOODING_HRA`, the last two being
#'   honest-re-encryption-attack secure. `NOT_SET` disables proxy
#'   re-encryption. Pass an element as the `pre_mode` argument of
#'   [CKKSParams()], [BFVParams()], [BGVParams()] or [fhe_context()].
#' @export
PREMode <- list(
  NOT_SET            = 0L,
  INDCPA             = 1L,
  FIXED_NOISE_HRA    = 2L,
  NOISE_FLOODING_HRA = 3L
)

#' Multiplication Technique (BFV)
#'
#' Mirrors the C++ enum `MultiplicationTechnique` in
#' `pke/constants-defs.h`.
#'
#' @return A named `list` of 4 integer scalars, each the value of the
#'   OpenFHE C++ enumerator of the same name, selecting the algorithm
#'   BFV uses for homomorphic multiplication: `BEHZ`
#'   (Bajard-Eynard-Hasan-Zucca) or the Halevi-Polyakov-Shoup variants
#'   `HPS`, `HPSPOVERQ` and `HPSPOVERQLEVELED`. Pass an element as the
#'   `multiplication_technique` argument of [BFVParams()] or
#'   [fhe_context()].
#' @export
MultiplicationTechnique <- list(
  BEHZ             = 0L,
  HPS              = 1L,
  HPSPOVERQ        = 2L,
  HPSPOVERQLEVELED = 3L
)

#' Encryption Technique
#'
#' Mirrors the C++ enum `EncryptionTechnique` in
#' `pke/constants-defs.h`.
#'
#' @return A named `list` of 2 integer scalars, each the value of the
#'   OpenFHE C++ enumerator of the same name: `STANDARD` encrypts in the
#'   ciphertext modulus, while `EXTENDED` encrypts in an enlarged
#'   modulus, which lowers the noise BFV multiplication starts from.
#'   Pass an element as the `encryption_technique` argument of
#'   [BFVParams()] or [fhe_context()].
#' @export
EncryptionTechnique <- list(
  STANDARD = 0L,
  EXTENDED = 1L
)

#' CKKS Data Type
#'
#' Mirrors the C++ enum `CKKSDataType` in `pke/constants-defs.h`.
#'
#' @return A named `list` of 2 integer scalars, each the value of the
#'   OpenFHE C++ enumerator of the same name, declaring whether the
#'   slots of a CKKS ciphertext hold `REAL` or `COMPLEX` numbers.
#' @export
CKKSDataType <- list(
  REAL    = 0L,
  COMPLEX = 1L
)

#' Compression Level (interactive multi-party bootstrap)
#'
#' Mirrors the C++ enum `CompressionLevel` in `pke/constants-defs.h`.
#' Note that the values start at 2, not 0: the header explains that
#' compression levels 0 and 1 are not supported and that the remaining
#' values are deliberately not renumbered.
#'
#' @return A named `list` of 2 integer scalars, each the value of the
#'   OpenFHE C++ enumerator of the same name, naming how far a
#'   ciphertext is compressed before the interactive bootstrapping
#'   round-trip: `COMPACT` (2) sends the least data but is only safe
#'   when the result is decrypted immediately, while `SLACK` (3) leaves
#'   room for further computation on the result. Pass an element as the
#'   `interactive_boot_compression_level` argument of [CKKSParams()] or
#'   [fhe_context()].
#' @export
CompressionLevel <- list(
  COMPACT = 2L,
  SLACK   = 3L
)

# ── Scheme identifier enum ────────────────

#' Scheme Identifier
#'
#' Mirrors the C++ enum `SCHEME` in `pke/scheme/scheme-id.h`. The R-side
#' name `SchemeId` matches the upstream header filename and avoids
#' colliding with a potential future `Scheme` S7 class.
#'
#' @return A named `list` of 4 integer scalars, each the value of the
#'   OpenFHE C++ enumerator of the same name, identifying the encryption
#'   scheme a context implements: `CKKSRNS_SCHEME`, `BFVRNS_SCHEME` or
#'   `BGVRNS_SCHEME`, with `INVALID_SCHEME` for an unset value. This is
#'   the value reported by `get_scheme()` on any `CCParams` object.
#' @export
SchemeId <- list(
  INVALID_SCHEME = 0L,
  CKKSRNS_SCHEME = 1L,
  BFVRNS_SCHEME  = 2L,
  BGVRNS_SCHEME  = 3L
)
