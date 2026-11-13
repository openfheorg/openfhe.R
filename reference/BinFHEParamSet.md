# Binary FHE Parameter Sets

Mirrors the C++ enum `BINFHE_PARAMSET` in `binfhe/binfhe-constants.h`,
whose enumerators are numbered sequentially from 0.

## Usage

``` r
BinFHEParamSet
```

## Value

A named `list` of 112 integer scalars, each the value of the OpenFHE C++
enumerator of the same name. An element names a pre-tabulated set of
lattice parameters for the boolean-circuit (BinFHE) schemes: `TOY` and
`MEDIUM` are insecure sizes for experimentation, and the `STD128`,
`STD192` and `STD256` families target the corresponding bits of security
against classical attacks, with the `Q` suffix targeting quantum attacks
and the `_3` and `_4` suffixes 3- and 4-input gates. The `LPF` prefix
marks a variant with a lower probability of failure. Sets without a
method suffix are tuned for the GINX bootstrapping method and may be
used with any method; the `_LMKCDEY` suffix marks a set for the
Lee-Micciancio-Kim-Choi-Deryabin-Eom-Yoo method only, and the `_AP`
suffix a set for the AP method only. `SIGNED_MOD_TEST` and
`TOY_MULTI_BASE` are test sets. Pass an element as the `paramset`
argument of
[`bin_fhe_context()`](https://openfheorg.github.io/openfhe.R/reference/bin_fhe_context.md).

## Details

The integer values belong to the vendored OpenFHE release. OpenFHE 1.6
reordered the list, so an integer saved from an earlier version of this
package names a different parameter set; always refer to an element by
name.
