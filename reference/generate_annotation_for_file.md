# Generate annotation text for a single file

Generate annotation text for a single file

## Usage

``` r
generate_annotation_for_file(
  file,
  style = "multiline",
  node_id = NULL,
  elements = NULL
)
```

## Arguments

- file:

  Path to source file

- style:

  Annotation style ("single" or "multiline")

- node_id:

  Id to use instead of the one derived from the file name

- elements:

  Result of
  [`detect_workflow_elements()`](https://pjt222.github.io/putior/reference/detect_workflow_elements.md)
  for the file, if already known; detected here when `NULL`

## Value

Annotation string
