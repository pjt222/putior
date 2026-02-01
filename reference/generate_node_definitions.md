# Generate node definitions for mermaid diagram

Generate node definitions for mermaid diagram

## Usage

``` r
generate_node_definitions(
  workflow,
  node_labels = "label",
  show_workflow_boundaries = TRUE,
  show_source_info = FALSE
)
```

## Arguments

- workflow:

  Workflow data frame

- node_labels:

  What to show in node labels

- show_workflow_boundaries:

  Whether to apply special styling to start/end nodes

- show_source_info:

  Whether to append source file info to node labels

## Value

Character vector of node definitions
