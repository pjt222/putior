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

## Details

An annotation is valid when every property in it can be read; one that
[`put()`](https://pjt222.github.io/putior/reference/put.md) would partly
ignore (and warn about) is not.

## See also

Other utilities:
[`get_diagram_themes()`](https://pjt222.github.io/putior/reference/get_diagram_themes.md),
[`split_file_list()`](https://pjt222.github.io/putior/reference/split_file_list.md)

## Examples

``` r
is_valid_put_annotation('# put id:"test", label:"Test"') # TRUE
#> [1] TRUE
is_valid_put_annotation("# put invalid syntax") # FALSE
#> [1] FALSE
```
