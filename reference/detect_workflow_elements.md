# Detect workflow elements in a single file

Detect workflow elements in a single file

## Usage

``` r
detect_workflow_elements(
  file,
  detect_inputs = TRUE,
  detect_outputs = TRUE,
  detect_dependencies = TRUE,
  include_line_numbers = FALSE
)
```

## Arguments

- file:

  Path to source file

- detect_inputs:

  Whether to detect inputs

- detect_outputs:

  Whether to detect outputs

- detect_dependencies:

  Whether to detect dependencies

- include_line_numbers:

  Whether to include line numbers

## Value

Named list with workflow elements
