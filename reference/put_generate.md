# Generate PUT Annotation Comments

Analyzes source code files and generates suggested PUT annotation
comments based on detected inputs, outputs, and dependencies. This is
similar to how roxygen2 generates documentation skeletons.

## Usage

``` r
put_generate(
  path,
  pattern = NULL,
  recursive = TRUE,
  output = "console",
  insert = FALSE,
  style = "multiline",
  exclude = NULL,
  log_level = NULL
)
```

## Arguments

- path:

  Character string specifying the path to a file or directory

- pattern:

  Regex pattern for filtering files (e.g., `\\.R$` for R files only).

- recursive:

  Logical. Should subdirectories be searched recursively? Default: TRUE

- output:

  Character string specifying output destination:

  - "console" - Print to console (default)

  - "raw" - Return as string without printing

  - "clipboard" - Copy to clipboard (requires clipr package)

  - "file" - Write to files with .put suffix

- insert:

  Logical. If TRUE, insert annotations directly into source files at the
  top. Use with caution. Default: FALSE

- style:

  Character string specifying annotation style:

  - "single" - Single-line annotations

  - "multiline" - Multiline annotations with backslash continuation

  Default: "multiline"

- exclude:

  Character vector of regex patterns. Files whose full path matches any
  pattern are excluded. Default: NULL (no exclusion).

- log_level:

  Character string specifying log verbosity for this call. Overrides the
  global option `putior.log_level` when specified. Options: "DEBUG",
  "INFO", "WARN", "ERROR". See
  [`set_putior_log_level`](https://pjt222.github.io/putior/reference/set_putior_log_level.md).

## Value

Invisibly returns a character vector of generated annotations. Side
effects depend on the `output` parameter.

## See also

[`put_auto`](https://pjt222.github.io/putior/reference/put_auto.md) for
direct workflow detection,
[`put`](https://pjt222.github.io/putior/reference/put.md) for extracting
existing annotations

Other auto-annotation:
[`put_auto()`](https://pjt222.github.io/putior/reference/put_auto.md),
[`put_merge()`](https://pjt222.github.io/putior/reference/put_merge.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# Print suggested annotations to console
put_generate("./analysis.R")

# Copy to clipboard for easy pasting
put_generate("./scripts/", output = "clipboard")

# Generate multiline style annotations
put_generate("./src/", style = "multiline")

# Insert annotations directly into files (use with caution)
put_generate("./new_script.R", insert = TRUE)
} # }
```
