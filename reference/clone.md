# Copy a ciphertext

`clone()` returns a deep copy: a new ciphertext with its own elements,
which later in-place operations on the original do not change.
`clone_empty()` returns a ciphertext with the same context, key tag and
encoding but no elements.

## Usage

``` r
clone(x, ...)

clone_empty(x)
```

## Arguments

- x:

  A `Ciphertext`.

- ...:

  Reserved for future method-specific arguments.

## Value

A `Ciphertext`.

## Details

Assigning a ciphertext to another name in R does not copy it; both names
refer to one C++ object.
