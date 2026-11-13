## R-SPECIFIC: fast internal constructor for the handle classes

## Every function that returns a handle used to end in a call of the S7
## constructor, `Ciphertext(ptr = <pointer>)`. With S7 0.2.2 that call
## takes about 45 microseconds (RConsortium/S7#723), which is a large
## share of a cheap operation such as an encrypted addition.
## `.fast_new()` returns the same object in about 1 microsecond. It is
## used only inside the package, at the places marked
##
##   ## >>> S7-FAST-NEW (RConsortium/S7#723): original
##   ## <the statement as it was>
##   ## <<< S7-FAST-NEW
##
## so that the original calls can be put back when the S7 constructor is
## fast enough. The exported constructors are unchanged and still go
## through S7 and the validator of `OpenFHEObject`.
##
## How it works: the first time a class is asked for, an empty handle is
## made with the S7 constructor and kept as a template. Each later call
## copies the template and sets `ptr` with S7's own
## `prop<-(check = FALSE)`. Nothing here depends on how S7 stores an
## object. Development S7 (0.2.2.9000) stores the class under different
## attribute names than 0.2.2, so an object assembled by hand from the
## 0.2.2 attributes is not identical to the one its constructor returns
## (D040). `test_fast_new.R` compares the result with the S7
## constructor's for every handle class.

.fast_new_cache <- new.env(parent = emptyenv())

## The template of a class and its full class name, made once.
.fast_new_register <- function(cls, name) {
  template <- cls()
  ## A class whose constructor builds a C++ object when called with no
  ## argument (PolyVector) gives a template that holds a pointer; drop it.
  if (!is.null(template@ptr)) S7::prop(template, "ptr", check = FALSE) <- NULL
  entry <- list(template = template, class = class(template)[[1L]])
  assign(name, entry, envir = .fast_new_cache)
  entry
}

#' Wrap an external pointer in a handle class without the S7 constructor
#'
#' @param cls A handle class, a child of `OpenFHEObject` whose only
#'   property is `ptr` and whose constructor can be called with no
#'   argument.
#' @param ptr An external pointer made by the C++ layer, or `NULL`.
#' @return An object identical to `cls(ptr = ptr)`.
#' @details The checks of the `OpenFHEObject` validator are kept: `ptr`
#'   must be an external pointer or `NULL`, and a pointer that carries
#'   the tag of another class is refused.
#' @keywords internal
#' @noRd
.fast_new <- function(cls, ptr) {
  name <- cls@name
  entry <- .fast_new_cache[[name]]
  if (is.null(entry)) entry <- .fast_new_register(cls, name)
  obj <- entry$template
  if (is.null(ptr)) return(obj)
  if (typeof(ptr) != "externalptr") {
    cli_abort("@ptr must be an external pointer or NULL")
  }
  tag <- xptr_type(ptr)
  if (nzchar(tag) && tag != entry$class) {
    want <- entry$class
    cli_abort("@ptr holds a <{tag}> handle, not a <{want}>")
  }
  S7::prop(obj, "ptr", check = FALSE) <- ptr
  obj
}
