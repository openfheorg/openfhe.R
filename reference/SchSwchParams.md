# Parameters of scheme switching

The parameter object
[`eval_ckks_to_fhew_setup()`](https://openfheorg.github.io/openfhe.R/reference/eval_ckks_to_fhew_setup.md)
and
[`eval_scheme_switching_setup()`](https://openfheorg.github.io/openfhe.R/reference/eval_scheme_switching_setup.md)
take. `SchSwchParams()` makes one with the library defaults; the `set_`
functions on this page change one field each and return the object
invisibly, so a parameter object is built step by step as in the OpenFHE
examples.

## Usage

``` r
SchSwchParams(ptr = NULL)

set_security_level_ckks(params, value)

set_security_level_fhew(params, value)

set_arbitrary_function_evaluation(params, value)

set_use_dynamic_mode_fhew(params, value)

set_compute_argmin(params, value)

set_one_hot_encoding(params, value)

set_use_alt_argmin(params, value)

set_num_slots_ckks(params, value)

set_num_values(params, value)

set_ctxt_mod_size_fhew_large_prec(params, value)

set_ctxt_mod_size_fhew_intermed_swch(params, value)

set_b_step_ltr_ckks_to_fhew(params, value)

set_b_step_ltr_fhew_to_ckks(params, value)

set_level_ltr_ckks_to_fhew(params, value)

set_level_ltr_fhew_to_ckks(params, value)

set_ring_dimension(params, value)

set_initial_ckks_modulus(params, value)

set_params_from_ckks_cryptocontext_called(params)

get_security_level_ckks(params)

get_security_level_fhew(params)

get_arbitrary_function_evaluation(params)

get_use_dynamic_mode_fhew(params)

get_compute_argmin(params)

get_one_hot_encoding(params)

get_use_alt_argmin(params)

get_num_slots_ckks(params)

get_num_values(params)

get_ctxt_mod_size_fhew_large_prec(params)

get_ctxt_mod_size_fhew_intermed_swch(params)

get_b_step_ltr_ckks_to_fhew(params)

get_b_step_ltr_fhew_to_ckks(params)

get_level_ltr_ckks_to_fhew(params)

get_level_ltr_fhew_to_ckks(params)

get_ring_dimension(params)

get_initial_ckks_modulus(params)
```

## Arguments

- ptr:

  External pointer (internal use). `NULL` (default) makes a new
  parameter object.

- params:

  A `SchSwchParams` object.

- value:

  The new value of the field: a logical for the five flags, an enum
  member for the two security levels, a string of decimal digits (or a
  whole number of at most 2^53) for `initial_ckks_modulus`, and a
  non-negative whole number otherwise.

## Value

`SchSwchParams()`: an S7 object of class `SchSwchParams`, inheriting
from
[OpenFHEObject](https://openfheorg.github.io/openfhe.R/reference/OpenFHEObject.md).
The `set_` functions: `params`, invisibly. The `get_` functions: the
value of the field, a string of decimal digits for
`initial_ckks_modulus`.

## Details

The three fields `initial_ckks_modulus`, `ring_dimension`,
`scaling_mod_size` and `batch_size` describe the CKKS context. The setup
functions fill them from the context, so they are not set by hand in
ordinary use;
[`set_params_from_ckks_cryptocontext()`](https://openfheorg.github.io/openfhe.R/reference/set_params_from_ckks_cryptocontext.md)
does the same on request.

The `get_` functions return the fields. The library refuses to read a
parameter object whose CKKS fields have not been filled, so they work
after a setup function or
[`set_params_from_ckks_cryptocontext()`](https://openfheorg.github.io/openfhe.R/reference/set_params_from_ckks_cryptocontext.md)
has been given the object;
[`format()`](https://rdrr.io/r/base/format.html) and
[`print()`](https://rdrr.io/r/base/print.html) show every field at any
time.

|  |  |  |
|----|----|----|
| Field | Meaning | Default |
| `security_level_ckks` | Security level of the CKKS context, an element of [SecurityLevel](https://openfheorg.github.io/openfhe.R/reference/SecurityLevel.md) | `HEStd_128_classic` |
| `security_level_fhew` | Parameter set of the FHEW context, an element of [BinFHEParamSet](https://openfheorg.github.io/openfhe.R/reference/BinFHEParamSet.md) | `STD128` |
| `arbitrary_function_evaluation` | Whether the FHEW context is for arbitrary function evaluation | `FALSE` |
| `use_dynamic_mode_fhew` | Whether the FHEW context uses dynamic gadget bases | `FALSE` |
| `compute_argmin` | Whether the argmin is computed with the minimum (or argmax with the maximum) | `FALSE` |
| `one_hot_encoding` | Whether the argmin is returned one-hot encoded | `TRUE` |
| `use_alt_argmin` | Whether the alternative argmin method is used | `FALSE` |
| `num_slots_ckks` | Number of CKKS slots to switch | `0` |
| `num_values` | Number of values to switch | `0` |
| `ctxt_mod_size_fhew_large_prec` | Bits of the large-precision FHEW ciphertext modulus | `25` |
| `ctxt_mod_size_fhew_intermed_swch` | Bits of the intermediate modulus of the switch | `27` |
| `b_step_ltr_ckks_to_fhew` | Baby-step of the linear transform from CKKS to FHEW | `0` |
| `b_step_ltr_fhew_to_ckks` | Baby-step of the linear transform from FHEW to CKKS | `0` |
| `level_ltr_ckks_to_fhew` | Level of the linear transform from CKKS to FHEW | `1` |
| `level_ltr_fhew_to_ckks` | Level of the linear transform from FHEW to CKKS | `0` |

## Examples

``` r
params <- SchSwchParams()
set_security_level_ckks(params, SecurityLevel$HEStd_NotSet)
set_security_level_fhew(params, BinFHEParamSet$TOY)
set_num_slots_ckks(params, 16L)
params
#> <SchSwchParams>
#> securityLevelCKKS: HEStd_NotSet; securityLevelFHEW: TOY; numSlotsCKKS: 16; numValues: 0; ctxtModSizeFHEWLargePrec: 25; ctxtModSizeFHEWIntermedSwch: 27; bStepLTrCKKStoFHEW: 0; bStepLTrFHEWtoCKKS: 0; levelLTrCKKStoFHEW: 1; levelLTrFHEWtoCKKS: 0; arbitraryFunctionEvaluation: 0; useDynamicModeFHEW:0; computeArgmin: 0; oneHotEncoding: 1; useAltArgmin: 0; PARAMS SET UP INTERNALLY FROM CRYPTOCONTEXT:  initialCKKSModulus: 0; ringDimension: 0; scalingModSize: 0; batchSize: 0
```
