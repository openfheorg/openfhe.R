## R-SPECIFIC: package load hooks

.onLoad <- function(libname, pkgname) {
  S7::methods_register()

  ns <- parent.env(environment())

  # S3 Ops handler for Ciphertext (and subclasses via class vector)
  registerS3method("Ops", "openfhe.R::Ciphertext", .openfhe_Ops_handler,
                   envir = ns)

  # Ensure openfhe.R wins Ops dispatch against Matrix and other S3 classes
  if (getRversion() >= "4.3.0") {
    registerS3method("chooseOpsMethod", "openfhe.R::Ciphertext",
                     .openfhe_chooseOpsMethod, envir = ns)
  }

  # Under R CMD check, cap OpenFHE at CRAN's two threads. --as-cran sets
  # _R_CHECK_LIMIT_CORES_; the "set and not false" rule below is the one
  # parallel:::.check_ncores() applies to that variable before mclapply()
  # or makeCluster() spawn workers. This is the package's only thread cap:
  # it runs before any example, test, or vignette, here and in every
  # package that imports openfhe.R, so none of them need one of their own.
  # Without it OpenFHE starts a team of every hardware thread for each
  # region, and LLVM libomp's workers keep spinning afterward long enough
  # to make a small example's CPU time many times its elapsed time.
  # Interactive use stays uncapped.
  chk <- tolower(Sys.getenv("_R_CHECK_LIMIT_CORES_", ""))
  if (nzchar(chk) && chk != "false") {
    set_num_threads(2L)
  }
}
