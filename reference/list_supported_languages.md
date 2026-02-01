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

## Examples

``` r
# All languages with annotation parsing support
list_supported_languages()
#>  [1] "r"          "python"     "shell"      "julia"      "ruby"      
#>  [6] "perl"       "yaml"       "toml"       "sql"        "lua"       
#> [11] "haskell"    "javascript" "typescript" "c"          "cpp"       
#> [16] "java"       "go"         "rust"       "swift"      "kotlin"    
#> [21] "csharp"     "php"        "scala"      "groovy"     "d"         
#> [26] "matlab"     "latex"     

# Only languages with auto-detection patterns
list_supported_languages(detection_only = TRUE)
#>  [1] "r"          "python"     "sql"        "shell"      "julia"     
#>  [6] "javascript" "typescript" "go"         "rust"       "java"      
#> [11] "c"          "cpp"        "matlab"     "ruby"       "lua"       
```
