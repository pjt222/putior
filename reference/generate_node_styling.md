# Generate node styling based on node types and theme

Generate node styling based on node types and theme

## Usage

``` r
generate_node_styling(
  workflow,
  theme = "light",
  show_workflow_boundaries = TRUE,
  palette = NULL
)
```

## Arguments

- workflow:

  Workflow data frame

- theme:

  Color theme ("light", "dark", "auto", "minimal", "github")

- show_workflow_boundaries:

  Whether to style start/end nodes

- palette:

  Optional putior_theme object that overrides theme

## Value

Character vector of styling definitions
