# Get Language Name from File Extension

Converts a file extension to a standardized language name used
internally for detection pattern lookup.

## Usage

``` r
ext_to_language(ext)
```

## Arguments

- ext:

  Character string of the file extension (without dot)

## Value

Character string of the language name, or NULL if not supported

## See also

Other language-support:
[`get_comment_prefix()`](https://pjt222.github.io/putior/reference/get_comment_prefix.md),
[`get_detection_patterns()`](https://pjt222.github.io/putior/reference/get_detection_patterns.md),
[`get_supported_extensions()`](https://pjt222.github.io/putior/reference/get_supported_extensions.md),
[`list_supported_languages()`](https://pjt222.github.io/putior/reference/list_supported_languages.md)

## Examples

``` r
ext_to_language("r")     # Returns "r"
#> [1] "r"
ext_to_language("py")    # Returns "python"
#> [1] "python"
ext_to_language("sql")   # Returns "sql"
#> [1] "sql"
ext_to_language("js")    # Returns "javascript"
#> [1] "javascript"
ext_to_language("xyz")   # Returns NULL
#> NULL
```
