# Evaluate a binary gate on encrypted values

Evaluate a binary gate on encrypted values

## Usage

``` r
eval_bin_gate(ctx, gate, ct1, ct2 = NULL)
```

## Arguments

- ctx:

  A BinFHE context

- gate:

  A [BinGate](https://bnaras.github.io/openfhe.R/reference/BinGate.md)
  value. Two-input gates: `OR`, `AND`, `NOR`, `NAND`, `XOR`, `XNOR`,
  `XOR_FAST`, `XNOR_FAST`. Three or more input gates (vector form):
  `MAJORITY`, `AND3`, `OR3`, `AND4`, `OR4`, `CMUX`.

- ct1:

  An `LWECiphertext`, OR a list of `LWECiphertext` objects for the
  3+-input vector form. When a list is supplied, `ct2` must be left at
  its default (`NULL`).

- ct2:

  An `LWECiphertext` for the 2-input form, or `NULL` (the default) when
  `ct1` is a list. The vector dispatch follows `binfhecontext.h` line
  322.

## Value

An `LWECiphertext`
