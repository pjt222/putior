# Get All Supported File Extensions

Returns a character vector of all file extensions supported by putior's
annotation parsing system.

## Usage

``` r
get_supported_extensions()
```

## Value

Character vector of supported file extensions (without dots)

## Examples

``` r
get_supported_extensions()
#>  [1] "r"          "py"         "sh"         "bash"       "jl"        
#>  [6] "rb"         "pl"         "yaml"       "yml"        "toml"      
#> [11] "dockerfile" "makefile"   "sql"        "lua"        "hs"        
#> [16] "js"         "ts"         "jsx"        "tsx"        "c"         
#> [21] "cpp"        "h"          "hpp"        "java"       "go"        
#> [26] "rs"         "swift"      "kt"         "cs"         "php"       
#> [31] "scala"      "groovy"     "d"          "wgsl"       "m"         
#> [36] "tex"       
```
