# The FHEW side of a scheme-switching context

`get_bin_cc_for_scheme_switch()` returns the FHEW context that a
scheme-switching setup created inside the CKKS context `cc`, and
`set_bin_cc_for_scheme_switch()` puts one there. `get_swk_fc()` and
`set_swk_fc()` read and write the switching key from FHEW to CKKS, which
is a CKKS ciphertext. The setters are for restoring a context in another
session.

## Usage

``` r
get_bin_cc_for_scheme_switch(cc)

set_bin_cc_for_scheme_switch(cc, bin_fhe_context)

get_swk_fc(cc)

set_swk_fc(cc, switching_key)
```

## Arguments

- cc:

  A CKKS `CryptoContext`.

- bin_fhe_context:

  A `BinFHEContext`.

- switching_key:

  A `Ciphertext`.

## Value

`get_bin_cc_for_scheme_switch()`: a `BinFHEContext`, or `NULL` if `cc`
holds none. `get_swk_fc()`: a `Ciphertext`, or `NULL` if `cc` holds
none. The setters: `cc`, invisibly.
