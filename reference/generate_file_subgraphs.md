# Generate file-based subgraphs

Groups workflow nodes by their source file into Mermaid subgraphs,
providing a visual organization by file origin.

## Usage

``` r
generate_file_subgraphs(
  workflow,
  node_labels = "label",
  show_workflow_boundaries = TRUE
)
```

## Arguments

- workflow:

  Data frame containing workflow nodes

- node_labels:

  What to show in node labels ("name", "label", "both")

- show_workflow_boundaries:

  Whether to apply special styling to start/end nodes

## Value

Character vector of Mermaid subgraph definitions
