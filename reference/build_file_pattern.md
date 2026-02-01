# Build File Pattern for Supported Extensions

Builds a regular expression pattern to match all supported file
extensions. Useful for the default pattern parameter in
[`put`](https://pjt222.github.io/putior/reference/put.md) and
[`put_auto`](https://pjt222.github.io/putior/reference/put_auto.md).

## Usage

``` r
build_file_pattern(detection_only = FALSE)
```

## Arguments

- detection_only:

  Logical. If TRUE, only include extensions with detection pattern
  support (R, Python, SQL, Shell, Julia). Default: FALSE

## Value

Character string regular expression pattern
