# putior Implementation Summary

## Overview

putior is an R package that extracts structured annotations from source
code files and generates Mermaid flowchart diagrams for visualizing
workflows and data pipelines.

## Key Features Implemented

### 1. Annotation System

- **Syntax**: `# put key:"value", key2:"value2"` (standard format,
  matches logo)
- **Alternative formats**: `#put` (no space), `#put|`, `#put:`
- **Supported file types**: R, Python, SQL, Shell, Julia

### 2. Field Changes and Defaults

- **Renamed**: `name` → `id` (better graph theory alignment)
- **UUID Auto-generation**: When `id` is omitted, automatically
  generates UUID
- **Output Defaulting**: When `output` is omitted, defaults to current
  file name
- **Validation**: Empty `id:""` generates warning; missing `id` gets
  UUID

### 3. Diagram Generation

- **5 Themes**: light, dark, auto, github, minimal
- **Node Types**: input (stadium), process (rectangle), output
  (subroutine), decision (diamond)
- **Connections**: Automatic based on matching input/output files
- **Output Options**: console, file, clipboard

### 4. Development Environment

- **WSL Configuration**:
  - R path: `/mnt/c/Program Files/R/R-4.5.0/bin/Rscript.exe`
  - Pandoc via `.Renviron`:
    `RSTUDIO_PANDOC="C:/Program Files/RStudio/resources/app/bin/quarto/bin/tools"`
- **Dependencies**: Minimal (base R + tools), uuid in Suggests

## Recent Implementation Details

### UUID Generation (parse_put_annotation in putior.R)

``` r
# Generate UUID if id is missing (not if it's empty)
if (is.null(properties$id) && requireNamespace("uuid", quietly = TRUE)) {
  properties$id <- uuid::UUIDgenerate()
}
```

### Output Defaulting (process_single_file in putior.R)

``` r
# Default output to file_name if not specified
if (is.null(properties$output) || properties$output == "") {
  properties$output <- basename(file)
}
```

### Source Relationship Tracking

**Pattern for scripts that source other scripts:** - Main script:
`input:"script1.R,script2.R"` (scripts being sourced) - Sourced scripts:
`output` defaults to their filename - Dependencies between sourced
scripts use filenames

**Correct flow direction:** - `sourced_script.R` → `main_script.R`
(sourced into) - Represents that `source("file.R")` reads file.R into
current environment

### Theme System (get_theme_colors in put_diagram.R)

- Each theme defines colors for: input, process, output, decision node
  types
- Invalid themes trigger warning and fallback to light theme
- style_nodes parameter controls whether styling is applied

## Testing

- Comprehensive test coverage for all features
- UUID generation tests (when uuid package available)
- Output defaulting tests
- Theme validation tests
- All tests passing: 0 errors, 0 warnings, 0 notes

## Documentation

- README.md: Updated with examples showing optional id, output
  defaulting
- Vignette: Includes sections on auto-generation features
- NEWS.md: Documents all changes for CRAN submission
- CLAUDE.md: Technical implementation details for AI assistants

## Package Status

- Ready for CRAN submission
- All checks passing
- Documentation complete
- Examples working
