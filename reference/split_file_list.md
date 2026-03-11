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

## Examples

``` r
split_file_list("data.csv, results.rds, plot.png")
#> [1] "data.csv"    "results.rds" "plot.png"   
split_file_list("")
#> character(0)
```
