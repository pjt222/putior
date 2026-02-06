# Auto-Annotation Functions for putior

Functions for automatically detecting workflow elements from code
analysis, generating PUT annotation comments, and merging manual with
auto-detected annotations.

Analyzes source code files to automatically detect workflow elements
including inputs, outputs, and dependencies without requiring explicit
PUT annotations. This is similar to how roxygen2 auto-generates
documentation skeletons.

## Usage

``` r
put_auto(
  path,
  pattern = NULL,
  recursive = FALSE,
  detect_inputs = TRUE,
  detect_outputs = TRUE,
  detect_dependencies = TRUE,
  include_line_numbers = FALSE,
  log_level = NULL
)
```

## Arguments

- path:

  Character string specifying the path to the folder containing files,
  or path to a single file

- pattern:

  Character string specifying the file pattern to match. Default: all
  extensions with detection pattern support (see
  [`list_supported_languages`](https://pjt222.github.io/putior/reference/list_supported_languages.md)`(detection_only = TRUE)`).

- recursive:

  Logical. Should subdirectories be searched recursively? Default: FALSE

- detect_inputs:

  Logical. Should file inputs be detected? Default: TRUE

- detect_outputs:

  Logical. Should file outputs be detected? Default: TRUE

- detect_dependencies:

  Logical. Should script dependencies (source calls) be detected?
  Default: TRUE

- include_line_numbers:

  Logical. Should line numbers be included? Default: FALSE

- log_level:

  Character string specifying log verbosity for this call. Overrides the
  global option `putior.log_level` when specified. Options: "DEBUG",
  "INFO", "WARN", "ERROR". See
  [`set_putior_log_level`](https://pjt222.github.io/putior/reference/set_putior_log_level.md).

## Value

A data frame in the same format as
[`put()`](https://pjt222.github.io/putior/reference/put.md), containing:

- file_name: Name of the source file

- file_path: Full path to the file

- file_type: File extension (r, py, sql, etc.)

- id: Auto-generated node identifier (based on file name)

- label: Human-readable label (file name without extension)

- input: Comma-separated list of detected input files

- output: Comma-separated list of detected output files

- node_type: Inferred node type (input/process/output)

This format is directly compatible with
[`put_diagram()`](https://pjt222.github.io/putior/reference/put_diagram.md).

## See also

[`put`](https://pjt222.github.io/putior/reference/put.md) for manual
annotation extraction,
[`put_generate`](https://pjt222.github.io/putior/reference/put_generate.md)
for generating annotation comments,
[`put_merge`](https://pjt222.github.io/putior/reference/put_merge.md)
for combining manual and auto-detected annotations

## Examples

``` r
if (FALSE) { # \dontrun{
# Auto-detect workflow from a directory
workflow <- put_auto("./src/")
put_diagram(workflow)

# Auto-detect with line numbers
workflow <- put_auto("./scripts/", include_line_numbers = TRUE)

# Only detect outputs (useful for finding data products)
outputs_only <- put_auto("./analysis/", detect_inputs = FALSE)
} # }
```
