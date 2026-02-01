# Get available themes for put_diagram

Returns information about available color themes for workflow diagrams.

## Usage

``` r
get_diagram_themes()
```

## Value

Named list describing available themes

## Examples

``` r
# See available themes
get_diagram_themes()
#> $light
#> [1] "Default light theme with bright colors - perfect for documentation sites"
#> 
#> $dark
#> [1] "Dark theme with muted colors - ideal for dark mode environments and terminals"
#> 
#> $auto
#> [1] "GitHub-adaptive theme with solid colors that work in both light and dark modes"
#> 
#> $minimal
#> [1] "Grayscale professional theme - print-friendly and great for business documents"
#> 
#> $github
#> [1] "Optimized specifically for GitHub README files with maximum mermaid compatibility"
#> 

if (FALSE) { # \dontrun{
# Use a specific theme (requires actual workflow data)
workflow <- put("./src")
put_diagram(workflow, theme = "github")
} # }
```
