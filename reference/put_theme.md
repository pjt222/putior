# Create a Custom Theme Palette for Workflow Diagrams

Constructs a custom color palette for use with
[`put_diagram()`](https://pjt222.github.io/putior/reference/put_diagram.md).
Specify colors for any subset of node types; unspecified types inherit
from the `base` theme.

## Usage

``` r
put_theme(
  base = "light",
  input = NULL,
  process = NULL,
  output = NULL,
  decision = NULL,
  artifact = NULL,
  start = NULL,
  end = NULL
)
```

## Arguments

- base:

  Character string naming the base theme to inherit from. Must be one of
  the valid themes returned by
  [`get_diagram_themes()`](https://pjt222.github.io/putior/reference/get_diagram_themes.md).
  Default: `"light"`.

- input:

  Named character vector `c(fill, stroke, color)` for input nodes.

- process:

  Named character vector `c(fill, stroke, color)` for process nodes.

- output:

  Named character vector `c(fill, stroke, color)` for output nodes.

- decision:

  Named character vector `c(fill, stroke, color)` for decision nodes.

- artifact:

  Named character vector `c(fill, stroke, color)` for artifact nodes.

- start:

  Named character vector `c(fill, stroke, color)` for start nodes.

- end:

  Named character vector `c(fill, stroke, color)` for end nodes.

## Value

An object of class `putior_theme` (a named list of CSS style strings,
one per node type), suitable for passing to
`put_diagram(palette = ...)`.

## Details

Each node type accepts a named character vector with keys `fill`,
`stroke`, and `color` (text color). All values must be valid hex colors
(e.g., `"#1a5276"`).

## Examples

``` r
# Override only input node colors, inherit rest from dark theme
my_theme <- put_theme(base = "dark",
  input = c(fill = "#1a5276", stroke = "#2e86c1", color = "#ffffff"))

# Full custom palette
custom <- put_theme(
  input   = c(fill = "#264653", stroke = "#2a9d8f", color = "#ffffff"),
  process = c(fill = "#e9c46a", stroke = "#f4a261", color = "#000000"),
  output  = c(fill = "#e76f51", stroke = "#264653", color = "#ffffff"))

if (FALSE) { # \dontrun{
workflow <- put("./src/")
put_diagram(workflow, palette = my_theme)
} # }
```
