# List All Supported Languages

Returns a character vector of all programming languages that can have
PUT annotations parsed by putior. Note that detection patterns (for
`put_auto`) may only be available for a subset of these languages.

## Usage

``` r
list_supported_languages(detection_only = FALSE)
```

## Arguments

- detection_only:

  Logical. If TRUE, only return languages with detection pattern
  support. Default: FALSE

## Value

Character vector of supported language names

## See also

Other language-support:
[`ext_to_language()`](https://pjt222.github.io/putior/reference/ext_to_language.md),
[`get_comment_prefix()`](https://pjt222.github.io/putior/reference/get_comment_prefix.md),
[`get_detection_patterns()`](https://pjt222.github.io/putior/reference/get_detection_patterns.md),
[`get_supported_extensions()`](https://pjt222.github.io/putior/reference/get_supported_extensions.md)

## Examples

``` r
# All languages with annotation parsing support
list_supported_languages()
#>  [1] "r"          "python"     "shell"      "julia"      "ruby"      
#>  [6] "perl"       "yaml"       "toml"       "dockerfile" "makefile"  
#> [11] "sql"        "lua"        "haskell"    "javascript" "typescript"
#> [16] "c"          "cpp"        "java"       "go"         "rust"      
#> [21] "swift"      "kotlin"     "csharp"     "php"        "scala"     
#> [26] "groovy"     "d"          "wgsl"       "matlab"     "latex"     

# Only languages with auto-detection patterns
list_supported_languages(detection_only = TRUE)
#>  [1] "r"          "python"     "sql"        "shell"      "julia"     
#>  [6] "javascript" "typescript" "go"         "rust"       "java"      
#> [11] "c"          "cpp"        "matlab"     "ruby"       "lua"       
#> [16] "wgsl"       "dockerfile" "makefile"  
```
