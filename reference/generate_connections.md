# Generate connections between nodes

Generate connections between nodes

## Usage

``` r
generate_connections(
  workflow,
  show_files = FALSE,
  show_artifacts = FALSE,
  artifact_edges = "replace"
)
```

## Arguments

- workflow:

  Workflow data frame with combined script and artifact nodes

- show_files:

  Whether to show file-based connections

- show_artifacts:

  Whether artifacts are included in the workflow

- artifact_edges:

  "replace" to leave out a direct script-to-script edge for a file that
  has an artifact node, "both" to keep it

## Value

Character vector of connection definitions
