# Get Comment Prefix for File Extension

Returns the single-line comment prefix for a given file extension. Falls
back to `#` for unknown extensions.

## Usage

``` r
get_comment_prefix(ext)
```

## Arguments

- ext:

  Character string of the file extension (without dot)

## Value

Character string of the comment prefix

## Examples

``` r
get_comment_prefix("r")    # Returns "#"
#> [1] "#"
get_comment_prefix("sql")  # Returns "--"
#> [1] "--"
get_comment_prefix("js")   # Returns "//"
#> [1] "//"
get_comment_prefix("tex")  # Returns "%"
#> [1] "%"
get_comment_prefix("xyz")  # Returns "#" (fallback)
#> [1] "#"
```
