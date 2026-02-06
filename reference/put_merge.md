# Merge Manual and Auto-Detected Annotations

Combines manually written PUT annotations with auto-detected workflow
elements, allowing flexible strategies for handling conflicts and
supplementing information.

## Usage

``` r
put_merge(
  path,
  pattern = NULL,
  recursive = FALSE,
  merge_strategy = "manual_priority",
  include_line_numbers = FALSE
)
```

## Arguments

- path:

  Character string specifying the path to a file or directory

- pattern:

  Character string specifying the file pattern to match. Default: all
  extensions with detection pattern support.

- recursive:

  Logical. Should subdirectories be searched recursively? Default: FALSE

- merge_strategy:

  Character string specifying how to merge:

  - "manual_priority" - Manual annotations override auto-detected
    (default)

  - "supplement" - Auto fills in missing input/output fields only

  - "union" - Combine all detected I/O from both sources

- include_line_numbers:

  Logical. Should line numbers be included? Default: FALSE

## Value

A data frame in the same format as
[`put()`](https://pjt222.github.io/putior/reference/put.md), containing
merged workflow information from both manual and auto-detected sources.

## See also

[`put`](https://pjt222.github.io/putior/reference/put.md) for manual
annotation extraction,
[`put_auto`](https://pjt222.github.io/putior/reference/put_auto.md) for
auto-detection

## Examples

``` r
if (FALSE) { # \dontrun{
# Merge with manual annotations taking priority
workflow <- put_merge("./src/")
put_diagram(workflow)

# Supplement manual annotations with auto-detected I/O
workflow <- put_merge("./scripts/", merge_strategy = "supplement")

# Combine all inputs/outputs from both sources
workflow <- put_merge("./analysis/", merge_strategy = "union")
} # }
```
