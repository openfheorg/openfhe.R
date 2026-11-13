## OPENFHE PYTHON SOURCE: src/lib/bindings.cpp (object accessors bound at OpenFHE 1.6.1)
##
## R wrappers for src/pke_object_accessors.cpp: accessors of
## ElementParams (Python: ParmType), EncodingParams, Ciphertext,
## Plaintext, the key classes and CryptoContext, with the two opaque
## handle classes they return (DCRTPoly, SchemeBase).

# ── Opaque handle classes ───────────────────────────────

#' A ring element of a ciphertext
#'
#' An element of the polynomial ring, in the double-CRT (RNS)
#' representation OpenFHE computes in. A ciphertext is a short list of
#' them. The class is an opaque handle, as in openfhe-python: it has
#' no methods of its own and exists so that the elements of one
#' ciphertext can be read with [get_elements()] and written to another
#' with [set_elements()].
#'
#' @param ptr External pointer (internal use)
#' @return An S7 object of class `DCRTPoly`, inheriting from
#'   [OpenFHEObject].
#' @export
DCRTPoly <- new_class("DCRTPoly",
  parent = OpenFHEObject,
  package = "openfhe.R"
)

method(print, DCRTPoly) <- function(x, ...) {
  cli::cli_text("{.cls DCRTPoly} [{if (ptr_is_valid(x)) 'active' else 'null'}]")
  invisible(x)
}

#' The scheme object of a CryptoContext
#'
#' The object that implements the operations of a context's scheme,
#' as returned by `get_scheme()` on a `CryptoContext`. It is an opaque
#' handle, as in openfhe-python, with no methods of its own.
#'
#' @param ptr External pointer (internal use)
#' @return An S7 object of class `SchemeBase`, inheriting from
#'   [OpenFHEObject].
#' @export
SchemeBase <- new_class("SchemeBase",
  parent = OpenFHEObject,
  package = "openfhe.R"
)

method(print, SchemeBase) <- function(x, ...) {
  cli::cli_text("{.cls SchemeBase} [{if (ptr_is_valid(x)) 'active' else 'null'}]")
  invisible(x)
}

# ── ElementParams and EncodingParams ────────────────────

#' The ciphertext modulus
#'
#' The modulus of an object, as a string of decimal digits, because it
#' normally exceeds what an R number holds exactly.
#'
#' For a `CryptoContext` or an `ElementParams` object it is the
#' composite ciphertext modulus `Q`, the product of the RNS moduli.
#' openfhe-python returns this value for a `CryptoContext` as a
#' floating-point number; R returns it exactly.
#'
#' @param x A `CryptoContext` or an `ElementParams` object.
#' @param ... Reserved for future method-specific arguments.
#' @return A character string of decimal digits.
#' @seealso [get_modulus_ckks()], [get_root_of_unity()],
#'   [get_element_modulus()]
#' @examples
#' cc <- fhe_context("BFV", plaintext_modulus = 65537, multiplicative_depth = 1)
#' get_modulus(cc)
#' @export
get_modulus <- new_generic("get_modulus", "x")

method(get_modulus, ElementParams) <- function(x) ElementParams__GetModulus(get_ptr(x))
method(get_modulus, CryptoContext) <- function(x) CryptoContext__GetModulus(get_ptr(x))

## Generics defined earlier, with their dispatch argument names.
method(get_cyclotomic_order, ElementParams) <- function(cc)
  ElementParams__GetCyclotomicOrder(get_ptr(cc))
method(ring_dimension, ElementParams) <- function(cc)
  ElementParams__GetRingDimension(get_ptr(cc))
method(get_batch_size, EncodingParams) <- function(params)
  EncodingParams__GetBatchSize(get_ptr(params))
method(get_plaintext_modulus, EncodingParams) <- function(params)
  EncodingParams__GetPlaintextModulus(get_ptr(params))

#' The plaintext generator of an encoding
#'
#' The generator of the cyclic group used to order the plaintext
#' slots, as recorded in an `EncodingParams` object.
#'
#' @param encoding_params An `EncodingParams` object, from
#'   [get_encoding_params()].
#' @return A number.
#' @export
get_plaintext_generator <- function(encoding_params) {
  EncodingParams__GetPlaintextGenerator(get_ptr(encoding_params))
}

# ── CryptoContext ───────────────────────────────────────

#' Moduli and root of unity of a CryptoContext
#'
#' `get_modulus_ckks()` returns the first RNS modulus `q_0` of a CKKS
#' context. `get_root_of_unity()` returns the root of unity recorded
#' in the context's element parameters, which is `"0"` for the
#' composite (double-CRT) parameters the RNS schemes use. Both are
#' strings of decimal digits.
#'
#' @param cc A `CryptoContext`.
#' @return A character string of decimal digits.
#' @seealso [get_modulus()]
#' @export
get_modulus_ckks <- function(cc) {
  CryptoContext__GetModulusCKKS(get_ptr(cc))
}

#' @rdname get_modulus_ckks
#' @export
get_root_of_unity <- function(cc) {
  CryptoContext__GetRootOfUnity(get_ptr(cc))
}

## get_scheme() on a context returns the scheme object; on a parameter
## object it returns the scheme identifier (R/params-getters.R). The
## two C++ methods share a name in the same way.
method(get_scheme, CryptoContext) <- function(params)
  ## >>> S7-FAST-NEW (RConsortium/S7#723): original
  ## SchemeBase(ptr = CryptoContext__GetScheme(get_ptr(params)))
  ## <<< S7-FAST-NEW
  .fast_new(SchemeBase, CryptoContext__GetScheme(get_ptr(params)))

#' Set the scheme identifier of a CryptoContext
#'
#' The counterpart of the C++ `setSchemeId()`. The identifier is set
#' when the context is generated; this function is for code that
#' assembles a context by hand.
#'
#' @param cc A `CryptoContext`.
#' @param scheme_tag A member of [SchemeId].
#' @return `cc`, invisibly.
#' @export
set_scheme_id <- function(cc, scheme_tag) {
  CryptoContext__setSchemeId(get_ptr(cc), as.integer(scheme_tag))
  invisible(cc)
}

#' Name and version of a serialized object
#'
#' The name under which OpenFHE writes an object of this class in its
#' serialized form, and the version number of that form.
#'
#' @param x A `CryptoContext` or a `BinFHEContext`.
#' @param ... Reserved for future method-specific arguments.
#' @return `serialized_object_name()`: a character string.
#'   `serialized_version()`: an integer.
#' @export
serialized_object_name <- new_generic("serialized_object_name", "x")

#' @rdname serialized_object_name
#' @export
serialized_version <- new_generic("serialized_version", "x")

method(serialized_object_name, CryptoContext) <- function(x)
  CryptoContext__SerializedObjectName(get_ptr(x))
method(serialized_version, CryptoContext) <- function(x) {
  get_ptr(x)
  CryptoContext__SerializedVersion()
}

#' Release the precomputations a CKKS context has cached
#'
#' CKKS bootstrapping and scheme switching keep precomputed tables in
#' the context. `clear_bootstrap_precom()` and
#' `clear_scheme_switch_precom()` release one kind each, and raise an
#' error on a context that is not CKKS. `clear_all_ckks_caches()`
#' releases both and does nothing on a context of another scheme.
#'
#' @param cc A `CryptoContext`.
#' @return `cc`, invisibly.
#' @export
clear_all_ckks_caches <- function(cc) {
  CryptoContext__ClearCaches(get_ptr(cc), 0L)
  invisible(cc)
}

#' @rdname clear_all_ckks_caches
#' @export
clear_bootstrap_precom <- function(cc) {
  CryptoContext__ClearCaches(get_ptr(cc), 1L)
  invisible(cc)
}

#' @rdname clear_all_ckks_caches
#' @export
clear_scheme_switch_precom <- function(cc) {
  CryptoContext__ClearCaches(get_ptr(cc), 2L)
  invisible(cc)
}

## Setters on the parameters of a live context. The generics are those
## of R/params-setters.R (dispatch argument `params`).
.cc_rns_setter <- function(field, real = FALSE) {
  function(params, value) {
    v <- .ccparams_value(value, if (real) "real" else "count")
    CryptoContext__SetRNS(get_ptr(params), field, as.double(v))
    invisible(params)
  }
}
method(set_noise_estimate, CryptoContext) <- .cc_rns_setter(0L, real = TRUE)
method(set_multiplicative_depth, CryptoContext) <- .cc_rns_setter(1L)
method(set_eval_add_count, CryptoContext) <- .cc_rns_setter(2L)
method(set_key_switch_count, CryptoContext) <- .cc_rns_setter(3L)
method(set_pre_num_hops, CryptoContext) <- .cc_rns_setter(4L)

#' An empty plaintext of the type a decryption will fill
#'
#' The counterpart of the C++ static `GetPlaintextForDecrypt()`: a
#' plaintext of the given encoding with no value yet, for code that
#' decrypts by hand.
#'
#' @param encoding_type A member of [PlaintextEncodings].
#' @param element_params An `ElementParams` object.
#' @param encoding_params An `EncodingParams` object.
#' @param ckks_data_type A member of [CKKSDataType]; default
#'   `CKKSDataType$REAL`.
#' @return A `Plaintext`.
#' @export
get_plaintext_for_decrypt <- function(encoding_type, element_params,
                                      encoding_params,
                                      ckks_data_type = CKKSDataType$REAL) {
  ## >>> S7-FAST-NEW (RConsortium/S7#723): original
  ## Plaintext(ptr = CryptoContext__GetPlaintextForDecrypt(
  ##   as.integer(encoding_type), get_ptr(element_params),
  ##   get_ptr(encoding_params), as.integer(ckks_data_type)))
  ## <<< S7-FAST-NEW
  .fast_new(Plaintext, CryptoContext__GetPlaintextForDecrypt(
    as.integer(encoding_type), get_ptr(element_params),
    get_ptr(encoding_params), as.integer(ckks_data_type)))
}

# ── Automorphism key indices ────────────────────────────

#' Which automorphism keys exist
#'
#' `get_existing_eval_automorphism_key_indices()` returns the
#' automorphism indices for which keys are registered under a key tag.
#' `get_eval_automorphism_no_key_indices()` returns those of a given
#' set of indices that have no key yet. `get_unique_values()` is the
#' set difference they are built on: the values of `new_values` that
#' are not in `old_values`.
#'
#' The indices are automorphism indices, as [find_automorphism_index()]
#' returns, not rotation amounts.
#'
#' @param key_tag Character string; the tag of the secret key the keys
#'   were generated for (see [get_key_tag()]).
#' @param indices,old_values,new_values Integer vectors.
#' @return An integer vector in increasing order.
#' @export
get_existing_eval_automorphism_key_indices <- function(key_tag) {
  CryptoContext__GetExistingEvalAutomorphismKeyIndices(as.character(key_tag))
}

#' @rdname get_existing_eval_automorphism_key_indices
#' @export
get_eval_automorphism_no_key_indices <- function(key_tag, indices) {
  CryptoContext__GetEvalAutomorphismNoKeyIndices(as.character(key_tag),
                                                 as.integer(indices))
}

#' @rdname get_existing_eval_automorphism_key_indices
#' @export
get_unique_values <- function(old_values, new_values) {
  CryptoContext__GetUniqueValues(as.integer(old_values), as.integer(new_values))
}

# ── Keys ────────────────────────────────────────────────

method(get_key_tag, EvalKey) <- function(key) EvalKey__GetKeyTag(get_ptr(key))
method(set_key_tag, EvalKey) <- function(key, value) {
  EvalKey__SetKeyTag(get_ptr(key), as.character(value))
  invisible(key)
}

method(get_crypto_context, PublicKey) <- function(ct)
  ## >>> S7-FAST-NEW (RConsortium/S7#723): original
  ## CryptoContext(ptr = PublicKey__GetCryptoContext(get_ptr(ct)))
  ## <<< S7-FAST-NEW
  .fast_new(CryptoContext, PublicKey__GetCryptoContext(get_ptr(ct)))
method(get_crypto_context, PrivateKey) <- function(ct)
  ## >>> S7-FAST-NEW (RConsortium/S7#723): original
  ## CryptoContext(ptr = PrivateKey__GetCryptoContext(get_ptr(ct)))
  ## <<< S7-FAST-NEW
  .fast_new(CryptoContext, PrivateKey__GetCryptoContext(get_ptr(ct)))

# ── Ciphertext ──────────────────────────────────────────

#' Copy a ciphertext
#'
#' `clone()` returns a deep copy: a new ciphertext with its own
#' elements, which later in-place operations on the original do not
#' change. `clone_empty()` returns a ciphertext with the same context,
#' key tag and encoding but no elements.
#'
#' Assigning a ciphertext to another name in R does not copy it; both
#' names refer to one C++ object.
#'
#' @param x A `Ciphertext`.
#' @param ... Reserved for future method-specific arguments.
#' @return A `Ciphertext`.
#' @export
clone <- new_generic("clone", "x")

method(clone, Ciphertext) <- function(x)
  ## >>> S7-FAST-NEW (RConsortium/S7#723): original
  ## Ciphertext(ptr = Ciphertext__Clone(get_ptr(x), FALSE))
  ## <<< S7-FAST-NEW
  .fast_new(Ciphertext, Ciphertext__Clone(get_ptr(x), FALSE))

#' @rdname clone
#' @export
clone_empty <- function(x) {
  ## >>> S7-FAST-NEW (RConsortium/S7#723): original
  ## Ciphertext(ptr = Ciphertext__Clone(get_ptr(x), TRUE))
  ## <<< S7-FAST-NEW
  .fast_new(Ciphertext, Ciphertext__Clone(get_ptr(x), TRUE))
}

#' The ring elements of a ciphertext
#'
#' A ciphertext is a list of ring elements: two when fresh, three
#' after a multiplication that has not been relinearized.
#'
#' `number_ciphertext_elements()` counts them. `get_elements()`
#' returns copies of them as a list of [DCRTPoly] handles, and
#' `set_elements()` replaces the elements of a ciphertext with copies
#' of the ones given. `remove_element()` deletes one.
#' `get_elements_mutable()` and `set_elements_move()` are the names
#' openfhe-python gives to the same two operations; in R, as in
#' Python, they exchange copies.
#'
#' @param ct A `Ciphertext`.
#' @param elements A list of [DCRTPoly] objects.
#' @param index Integer; which element to remove, counting from 1.
#' @return `number_ciphertext_elements()`: an integer.
#'   `get_elements()` and `get_elements_mutable()`: a list of
#'   `DCRTPoly` objects. The others return `ct`, invisibly.
#' @export
number_ciphertext_elements <- function(ct) {
  Ciphertext__NumberCiphertextElements(get_ptr(ct))
}

#' @rdname number_ciphertext_elements
#' @export
get_elements <- function(ct) {
  ## >>> S7-FAST-NEW (RConsortium/S7#723): original
  ## lapply(Ciphertext__GetElements(get_ptr(ct)), function(p) DCRTPoly(ptr = p))
  ## <<< S7-FAST-NEW
  lapply(Ciphertext__GetElements(get_ptr(ct)), function(p) .fast_new(DCRTPoly, p))
}

#' @rdname number_ciphertext_elements
#' @export
get_elements_mutable <- function(ct) {
  get_elements(ct)
}

#' @rdname number_ciphertext_elements
#' @export
set_elements <- function(ct, elements) {
  ok <- is.list(elements) &&
    all(vapply(elements, function(e) S7::S7_inherits(e, DCRTPoly), logical(1)))
  if (!ok) {
    cli_abort("{.arg elements} must be a list of {.cls DCRTPoly} objects.")
  }
  Ciphertext__SetElements(get_ptr(ct), lapply(elements, get_ptr))
  invisible(ct)
}

#' @rdname number_ciphertext_elements
#' @export
set_elements_move <- function(ct, elements) {
  set_elements(ct, elements)
}

#' @rdname number_ciphertext_elements
#' @export
remove_element <- function(ct, index) {
  index <- as.integer(index)
  if (length(index) != 1L || is.na(index) || index < 1L) {
    cli_abort("{.arg index} must be a single positive integer.")
  }
  ## C++ and Python count the elements from 0.
  Ciphertext__RemoveElement(get_ptr(ct), index - 1L)
  invisible(ct)
}

#' Hop level and encoding type of a ciphertext
#'
#' The hop level is the number of proxy re-encryptions recorded on a
#' ciphertext. The encoding type records which plaintext encoding the
#' ciphertext carries (see [get_encoding_type()]).
#'
#' @param ct A `Ciphertext`.
#' @param hop_level Integer.
#' @param encoding_type A member of [PlaintextEncodings].
#' @return `get_hop_level()`: an integer. The setters return `ct`,
#'   invisibly.
#' @export
get_hop_level <- function(ct) {
  Ciphertext__GetHopLevel(get_ptr(ct))
}

#' @rdname get_hop_level
#' @export
set_hop_level <- function(ct, hop_level) {
  Ciphertext__SetHopLevel(get_ptr(ct), as.integer(hop_level))
  invisible(ct)
}

#' @rdname get_hop_level
#' @export
set_encoding_type <- function(ct, encoding_type) {
  Ciphertext__SetEncodingType(get_ptr(ct), as.integer(encoding_type))
  invisible(ct)
}

# ── Plaintext ───────────────────────────────────────────

#' Encode or decode a plaintext
#'
#' A plaintext holds a value and its encoding as a ring element. The
#' functions that make plaintexts encode them, and [decrypt()] decodes
#' its result, so these are for code that manipulates the element
#' directly.
#'
#' `encode()` computes the element from the value and `decode()` the
#' value from the element. The CKKS form of `decode()` takes what the
#' decoder needs to know about the ciphertext the plaintext came from;
#' give all four arguments or none. The result of [decrypt()] is
#' already decoded, and decoding it again does not reproduce its
#' value.
#'
#' @param pt A `Plaintext`.
#' @param depth Integer; the noise scale degree of the ciphertext.
#' @param scaling_factor Numeric; its scaling factor.
#' @param scal_tech A member of [ScalingTechnique].
#' @param execution_mode A member of [ExecutionMode].
#' @return `TRUE` on success.
#' @export
encode <- function(pt) {
  Plaintext__Encode(get_ptr(pt))
}

#' @rdname encode
#' @export
decode <- function(pt, depth = NULL, scaling_factor = NULL, scal_tech = NULL,
                   execution_mode = NULL) {
  given <- !c(is.null(depth), is.null(scaling_factor), is.null(scal_tech),
              is.null(execution_mode))
  if (!any(given)) return(Plaintext__Decode(get_ptr(pt)))
  if (!all(given)) {
    cli_abort("Give all of {.arg depth}, {.arg scaling_factor}, {.arg scal_tech} and {.arg execution_mode}, or none of them.")
  }
  Plaintext__Decode__ckks(get_ptr(pt), as.integer(depth),
                          as.double(scaling_factor), as.integer(scal_tech),
                          as.integer(execution_mode))
}

#' Modulus and representation of a plaintext's element
#'
#' `get_element_modulus()` returns the modulus of the ring element
#' that encodes the plaintext, as a string of decimal digits.
#' `set_format()` converts that element between the evaluation and
#' coefficient representations.
#'
#' @param pt A `Plaintext`.
#' @param format A member of [Format].
#' @return `get_element_modulus()`: a character string of decimal
#'   digits. `set_format()`: `pt`, invisibly.
#' @seealso [get_modulus()]
#' @export
get_element_modulus <- function(pt) {
  Plaintext__GetElementModulus(get_ptr(pt))
}

#' @rdname get_element_modulus
#' @export
set_format <- function(pt, format) {
  Plaintext__SetFormat(get_ptr(pt), as.integer(format))
  invisible(pt)
}

method(get_encoding_params, Plaintext) <- function(cc)
  ## >>> S7-FAST-NEW (RConsortium/S7#723): original
  ## EncodingParams(ptr = Plaintext__GetEncodingParams(get_ptr(cc)))
  ## <<< S7-FAST-NEW
  .fast_new(EncodingParams, Plaintext__GetEncodingParams(get_ptr(cc)))
