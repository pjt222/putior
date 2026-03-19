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

## See also

Other language-support:
[`ext_to_language()`](https://pjt222.github.io/putior/reference/ext_to_language.md),
[`get_detection_patterns()`](https://pjt222.github.io/putior/reference/get_detection_patterns.md),
[`get_supported_extensions()`](https://pjt222.github.io/putior/reference/get_supported_extensions.md),
[`list_supported_languages()`](https://pjt222.github.io/putior/reference/list_supported_languages.md)

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
