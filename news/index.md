# Changelog

## putior 0.2.0.9000 (development version)

### New Features

#### Auto-Annotation Feature (GitHub Issue [\#5](https://github.com/pjt222/putior/issues/5))

- Added
  [`put_auto()`](https://pjt222.github.io/putior/reference/put_auto.md)
  function for automatic workflow detection from code analysis
  - Analyzes source code to detect file inputs, outputs, and
    dependencies
  - Returns data frame compatible with
    [`put_diagram()`](https://pjt222.github.io/putior/reference/put_diagram.md)
    for instant visualization
  - Works without requiring explicit PUT annotations in code
  - Supports R, Python, SQL, Shell, and Julia files
- Added
  [`put_generate()`](https://pjt222.github.io/putior/reference/put_generate.md)
  function for generating PUT annotation comments
  - Creates suggested `#put` annotation text based on code analysis
    (roxygen2-style)
  - Supports both single-line and multiline annotation styles
  - Can output to console, clipboard, or file
  - Optional direct insertion into source files
- Added
  [`put_merge()`](https://pjt222.github.io/putior/reference/put_merge.md)
  function for combining manual and auto-detected annotations
  - Three merge strategies: “manual_priority”, “supplement”, “union”
  - Allows hybrid workflows with manual control over key files
- Added
  [`get_detection_patterns()`](https://pjt222.github.io/putior/reference/get_detection_patterns.md)
  for viewing/customizing detection patterns
- Added
  [`list_supported_languages()`](https://pjt222.github.io/putior/reference/list_supported_languages.md)
  to show supported programming languages

#### Detection Patterns

- Comprehensive pattern library for file I/O detection:
  - **R**: Base R, readr, data.table, readxl, jsonlite, arrow, haven,
    yaml, graphics
  - **Python**: pandas, numpy, json, pickle, yaml, matplotlib, PIL, cv2,
    polars
  - **SQL**: FROM/JOIN tables, LOAD DATA, COPY commands
  - **Shell**: cat, redirections, source, tee
  - **Julia**: CSV.jl, DataFrames, JSON.jl, JLD2, Arrow.jl, Plots.jl

#### Examples

- Added `inst/examples/auto-annotation-example.R` demonstrating all
  auto-annotation features

#### Metadata Display (GitHub Issue [\#3](https://github.com/pjt222/putior/issues/3))

- Added `show_source_info` parameter to
  [`put_diagram()`](https://pjt222.github.io/putior/reference/put_diagram.md)
  for displaying source file information in diagram nodes
- Added `source_info_style` parameter with two display options:
  - `"inline"` (default): Appends file name as small text below node
    labels
  - `"subgraph"`: Groups nodes by source file into Mermaid subgraphs

#### Clickable Hyperlinks (GitHub Issue [\#4](https://github.com/pjt222/putior/issues/4))

- Added `enable_clicks` parameter to
  [`put_diagram()`](https://pjt222.github.io/putior/reference/put_diagram.md)
  for making nodes clickable
- Added `click_protocol` parameter with three protocol options:
  - `"vscode"` (default): Opens files in VS Code
    (vscode://file/path:line)
  - `"file"`: Standard <file://> protocol for system default handler
  - `"rstudio"`: Opens files in RStudio (rstudio://open-file?path=)
- Click directives include line numbers when available from annotations
- Tooltips are generated automatically for each clickable node

#### New Helper Functions

- Added
  [`normalize_path_for_url()`](https://pjt222.github.io/putior/reference/normalize_path_for_url.md)
  for cross-platform path handling
- Added
  [`generate_click_url()`](https://pjt222.github.io/putior/reference/generate_click_url.md)
  for creating protocol-specific URLs
- Added
  [`generate_click_directives()`](https://pjt222.github.io/putior/reference/generate_click_directives.md)
  for Mermaid click action generation
- Added
  [`generate_file_subgraphs()`](https://pjt222.github.io/putior/reference/generate_file_subgraphs.md)
  for file-based node grouping

#### Examples

- Added `inst/examples/interactive-diagrams-example.R` demonstrating
  both features

### Backward Compatibility

- All new parameters default to FALSE/previous behavior
- Existing code continues to work unchanged

## putior 0.1.0

CRAN release: 2025-06-19

- Initial CRAN submission
- Added [`put()`](https://pjt222.github.io/putior/reference/put.md)
  function for extracting workflow annotations from source code files
- Added
  [`put_diagram()`](https://pjt222.github.io/putior/reference/put_diagram.md)
  function for creating Mermaid flowchart diagrams
- Added
  [`is_valid_put_annotation()`](https://pjt222.github.io/putior/reference/is_valid_put_annotation.md)
  for validating annotation syntax
- Support for multiple programming languages: R, Python, SQL, Shell, and
  Julia
- Multiline annotation support with backslash continuation syntax for
  better code style compliance
- Automatic UUID generation when `id` field is omitted from annotations
- Automatic output defaulting to file name when `output` field is
  omitted
- Renamed annotation field from `name` to `id` for better graph theory
  alignment
- Five built-in themes for diagrams: light, dark, auto, minimal, and
  github
- Automatic file flow tracking between workflow steps
- Comprehensive vignette with examples
- Full test coverage for all major functions
