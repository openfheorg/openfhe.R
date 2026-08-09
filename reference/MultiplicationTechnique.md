# Multiplication Technique (BFV)

Mirrors the C++ enum `MultiplicationTechnique` in
`pke/constants-defs.h`.

## Usage

``` r
MultiplicationTechnique
```

## Value

A named `list` of 4 integer scalars, each the value of the OpenFHE C++
enumerator of the same name, selecting the algorithm BFV uses for
homomorphic multiplication: `BEHZ` (Bajard-Eynard-Hasan-Zucca) or the
Halevi-Polyakov-Shoup variants `HPS`, `HPSPOVERQ` and
`HPSPOVERQLEVELED`. Pass an element as the `multiplication_technique`
argument of
[`BFVParams()`](https://openfheorg.github.io/openfhe.R/reference/BFVParams.md)
or
[`fhe_context()`](https://openfheorg.github.io/openfhe.R/reference/fhe_context.md).
