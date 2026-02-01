# Validate PUT annotation syntax

Test helper function to validate PUT annotation syntax

## Usage

``` r
is_valid_put_annotation(line)
```

## Arguments

- line:

  Character string containing a PUT annotation

## Value

Logical indicating if the annotation is valid

## Examples

``` r
is_valid_put_annotation('#put name:"test", label:"Test"') # TRUE
#> [1] TRUE
is_valid_put_annotation("#put invalid syntax") # FALSE
#> [1] FALSE
```
