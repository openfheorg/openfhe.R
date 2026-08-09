# Binary Gate Types

Mirrors the C++ enum `BINGATE` in `binfhe/binfhe-constants.h`, whose
enumerators are numbered sequentially from 0.

## Usage

``` r
BinGate
```

## Value

A named `list` of 14 integer scalars, each the value of the OpenFHE C++
enumerator of the same name, naming the boolean gate to evaluate on
encrypted bits: the two-input gates `OR`, `AND`, `NOR`, `NAND`, `XOR`,
`XNOR` and the faster `XOR_FAST`, `XNOR_FAST`; the three- and four-input
`AND3`, `OR3`, `AND4`, `OR4`; and `MAJORITY` and `CMUX`. Pass an element
as the `gate` argument of
[`eval_bin_gate()`](https://openfheorg.github.io/openfhe.R/reference/eval_bin_gate.md).
