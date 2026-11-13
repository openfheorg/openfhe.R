## R-SPECIFIC: every enum mirrored in R/enums.R against the values the
## compiler assigned from the vendored OpenFHE headers.
## @openfhe-python: src/lib/bindings.cpp (enum definitions) [FULL]
##
## R/enums.R holds literal integers. A literal that is out of step with
## the headers still names some enumerator, and the library accepts it
## without error, so no behavioral test is certain to notice. This test
## compares names and values with what the wrapper was compiled against.
library(openfhe.R)

compiled <- openfhe.R:::openfhe_enum_values()

mirrored <- c(
  "BinFHEParamSet", "Feature", "ScalingTechnique", "KeySwitchTechnique",
  "SecurityLevel", "SecretKeyDist", "BinFHEMethod", "BinGate",
  "BinFHEOutput", "KeygenMode", "PlaintextEncodings", "DistributionType",
  "MultipartyMode", "ExecutionMode", "DecryptionNoiseMode", "PREMode",
  "MultiplicationTechnique", "EncryptionTechnique", "CKKSDataType",
  "CompressionLevel", "SchemeId", "Format"
)

## The compiled report covers exactly the mirrored enums.
expect_identical(sort(names(compiled)), sort(mirrored))

ns <- asNamespace("openfhe.R")
for (enum in mirrored) {
  r_side <- unlist(get(enum, envir = ns))
  cpp_side <- compiled[[enum]]

  ## Same members: nothing missing from R, nothing R invented.
  expect_identical(sort(names(r_side)), sort(names(cpp_side)),
                   info = paste(enum, "member names"))

  ## Same value for every member, matched by name.
  common <- intersect(names(r_side), names(cpp_side))
  expect_identical(unname(r_side[common]), unname(cpp_side[common]),
                   info = paste(enum, "member values"))

  ## R stores integers.
  expect_true(is.integer(r_side), info = paste(enum, "storage type"))
}

## BINFHE_PARAMSET comes from the header's own list, so its size here
## is the header's.
expect_identical(length(BinFHEParamSet), length(compiled$BinFHEParamSet))
