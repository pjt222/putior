# Split comma-separated file list

Parses a comma-separated string of file names into a character vector,
trimming whitespace from each entry.

## Usage

``` r
split_file_list(file_string)
```

## Arguments

- file_string:

  Comma-separated file names

## Value

Character vector of individual file names

## See also

Other utilities:
[`get_diagram_themes()`](https://pjt222.github.io/putior/reference/get_diagram_themes.md),
[`is_valid_put_annotation()`](https://pjt222.github.io/putior/reference/is_valid_put_annotation.md)

## Examples

``` r
split_file_list("data.csv, results.rds, plot.png")
#> [1] "data.csv"    "results.rds" "plot.png"   
split_file_list("")
#> character(0)
```
