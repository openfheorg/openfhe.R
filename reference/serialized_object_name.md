# Name and version of a serialized object

The name under which OpenFHE writes an object of this class in its
serialized form, and the version number of that form.

## Usage

``` r
serialized_object_name(x, ...)

serialized_version(x, ...)
```

## Arguments

- x:

  A `CryptoContext` or a `BinFHEContext`.

- ...:

  Reserved for future method-specific arguments.

## Value

`serialized_object_name()`: a character string. `serialized_version()`:
an integer.
