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
