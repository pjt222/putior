# Resolve label text for a workflow node

Resolve label text for a workflow node

## Usage

``` r
resolve_label(node, node_labels, suffix = NULL)
```

## Arguments

- node:

  A single row from the workflow data frame

- node_labels:

  Label display mode: "name", "label", or "both"

- suffix:

  Optional string appended to the raw label before sanitization (e.g.
  source-file info), so it lands inside the quoted label

## Value

Character string of the resolved label text
