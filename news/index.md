# Changelog

## putior 0.2.0.9000 (development version)

### Breaking Changes

- [`put()`](https://pjt222.github.io/putior/reference/put.md),
  [`put_auto()`](https://pjt222.github.io/putior/reference/put_auto.md),
  [`put_generate()`](https://pjt222.github.io/putior/reference/put_generate.md),
  and
  [`put_merge()`](https://pjt222.github.io/putior/reference/put_merge.md)
  now default to `recursive = TRUE` (previously `FALSE`). Directory
  scans now include subdirectories by default. Pass `recursive = FALSE`
  for the old behavior.
  ([\#34](https://github.com/pjt222/putior/issues/34))

### Bug Fixes

- Fixed `show_source_info = TRUE` using `<small>` HTML tags that are
  unsupported by GitHub’s Mermaid renderer. Source file names are now
  shown without HTML formatting tags.
  ([\#32](https://github.com/pjt222/putior/issues/32))
- Fixed pipe characters (`|`) in node labels breaking Mermaid diagram
  parsing. Pipes are now escaped using the `#124;` entity.
  ([\#33](https://github.com/pjt222/putior/issues/33))

### New Features

#### MCP Server Integration

- Added
  [`putior_mcp_server()`](https://pjt222.github.io/putior/reference/putior_mcp_server.md)
  to expose putior functions as MCP tools for AI assistants
- Added
  [`putior_mcp_tools()`](https://pjt222.github.io/putior/reference/putior_mcp_tools.md)
  to get/filter tool definitions for custom MCP integrations
- 16 tools available: `put`, `put_diagram`, `put_auto`, `put_generate`,
  `put_merge`, `get_comment_prefix`, `get_supported_extensions`,
  `list_supported_languages`, `get_detection_patterns`,
  `get_diagram_themes`, `putior_skills`, `putior_help`,
  `set_putior_log_level`, `is_valid_put_annotation`, `split_file_list`,
  `ext_to_language`
- Supports Claude Code, Claude Desktop, and other MCP-compatible clients

#### ACP Server Integration

- Added
  [`putior_acp_server()`](https://pjt222.github.io/putior/reference/putior_acp_server.md)
  to expose putior as an ACP agent for inter-agent communication via
  REST API
- Added
  [`putior_acp_manifest()`](https://pjt222.github.io/putior/reference/putior_acp_manifest.md)
  for agent discovery
- Supports natural language requests for all core operations
- Input path sanitization to prevent directory traversal attacks

#### Multi-Language Comment Syntax (30+ Languages)

- Added support for 30+ programming languages with automatic comment
  prefix detection
- Comment styles: `#` (R, Python, Shell, etc.), `--` (SQL, Lua,
  Haskell), `//` (JavaScript, TypeScript, C/C++, Go, Rust, Java, etc.),
  `%` (MATLAB, LaTeX)
- Added
  [`get_comment_prefix()`](https://pjt222.github.io/putior/reference/get_comment_prefix.md),
  [`get_supported_extensions()`](https://pjt222.github.io/putior/reference/get_supported_extensions.md),
  [`ext_to_language()`](https://pjt222.github.io/putior/reference/ext_to_language.md)
- Added
  [`list_supported_languages()`](https://pjt222.github.io/putior/reference/list_supported_languages.md)
  to enumerate all supported languages

#### Auto-Detection Patterns (15 Languages, 862 Patterns)

- Full auto-detection for: R, Python, SQL, Shell, Julia, JavaScript,
  TypeScript, Go, Rust, Java, C, C++, MATLAB, Ruby, Lua
- Pattern inheritance: TypeScript extends JavaScript, C++ extends C
- Single authoritative language registry (`R/language_registry.R`)

#### LLM Detection Patterns

- 54 patterns for modern AI/ML libraries across R and Python
- R: ellmer, tidyllm, httr2 (API requests)
- Python: ollama, openai, anthropic, langchain, transformers, litellm,
  vllm, google generative AI, groq

#### Auto-Annotation Feature

- Added
  [`put_auto()`](https://pjt222.github.io/putior/reference/put_auto.md)
  for automatic workflow detection from code analysis
- Added
  [`put_generate()`](https://pjt222.github.io/putior/reference/put_generate.md)
  for generating PUT annotation comments (roxygen2-style)
  - Now supports `output = "raw"` for programmatic access
- Added
  [`put_merge()`](https://pjt222.github.io/putior/reference/put_merge.md)
  for combining manual and auto-detected annotations
  - Three merge strategies: “manual_priority”, “supplement”, “union”

#### Colorblind-Safe Themes

- Added 4 viridis family themes for accessibility:
  - `viridis`: Purple-blue-green-yellow (general accessibility)
  - `magma`: Purple-red-yellow (high contrast, print-friendly)
  - `plasma`: Purple-pink-orange-yellow (presentations)
  - `cividis`: Blue-gray-yellow (deuteranopia/protanopia optimized)
- All themes perceptually uniform and tested for color vision
  deficiencies

#### Metadata Display

- Added `show_source_info` parameter to
  [`put_diagram()`](https://pjt222.github.io/putior/reference/put_diagram.md)
  for displaying source file information in diagram nodes
- Added `source_info_style` parameter with “inline” and “subgraph”
  display options

#### Clickable Hyperlinks

- Added `enable_clicks` parameter to
  [`put_diagram()`](https://pjt222.github.io/putior/reference/put_diagram.md)
  for making nodes clickable
- Added `click_protocol` parameter: “vscode”, “file”, “rstudio”
- Click directives include line numbers when available

#### Structured Logging

- Optional `logger` package integration for debugging annotation parsing
- Log levels: DEBUG, INFO, WARN (default), ERROR
- Added
  [`set_putior_log_level()`](https://pjt222.github.io/putior/reference/set_putior_log_level.md)
  for configuration
- Per-call override via `log_level` parameter on core functions

#### S3 Workflow Class

- Workflow data frames now have `putior_workflow` S3 class
- Added
  [`print.putior_workflow()`](https://pjt222.github.io/putior/reference/print.putior_workflow.md)
  for concise workflow summaries
- Added
  [`summary.putior_workflow()`](https://pjt222.github.io/putior/reference/summary.putior_workflow.md)
  for structured summary information

#### Interactive Sandbox Enhancements

- Added copy-to-clipboard button for quick Mermaid code export
- Added optional shinyAce syntax highlighting (graceful degradation)

#### Documentation

- 8 comprehensive vignettes including quick-start, annotation guide,
  features tour, API reference, showcase, troubleshooting,
  quick-reference, and skills reference
- Professional cheat sheet (`inst/cheatsheet/putior-cheatsheet.qmd`)
- 20 example files in `inst/examples/`
- [`putior_skills()`](https://pjt222.github.io/putior/reference/putior_skills.md)
  and
  [`putior_help()`](https://pjt222.github.io/putior/reference/putior_help.md)
  for in-session reference

#### New Helper Functions

- [`resolve_label()`](https://pjt222.github.io/putior/reference/resolve_label.md)
  internal helper to reduce code duplication in diagram generation
- `sanitize_acp_path()` for ACP input validation
- [`normalize_path_for_url()`](https://pjt222.github.io/putior/reference/normalize_path_for_url.md)
  for cross-platform path handling
- [`generate_click_url()`](https://pjt222.github.io/putior/reference/generate_click_url.md)
  for creating protocol-specific URLs
- [`generate_click_directives()`](https://pjt222.github.io/putior/reference/generate_click_directives.md)
  for Mermaid click action generation
- [`generate_file_subgraphs()`](https://pjt222.github.io/putior/reference/generate_file_subgraphs.md)
  for file-based node grouping

### Bug Fixes

- Fixed ACP
  [`put_generate()`](https://pjt222.github.io/putior/reference/put_generate.md)
  called with invalid `output = "raw"` (now supported)
- Fixed MCP theme enum missing viridis family themes
- Fixed documentation using deprecated `name` instead of `id` in
  examples
- Fixed ACP theme extraction regex missing colorblind-safe themes
- Replaced unsafe `1:nrow()` loops with `seq_len(nrow())` to handle
  empty data frames
- Moved `%||%` operator from `acp.R` to `zzz.R` for shared access

### Improvements

- Consolidated language detection list into single authoritative
  registry (`.LANGUAGES_WITH_DETECTION` in `language_registry.R`)
- Standardized `output` parameter across
  [`put_diagram()`](https://pjt222.github.io/putior/reference/put_diagram.md),
  [`put_generate()`](https://pjt222.github.io/putior/reference/put_generate.md),
  and
  [`putior_skills()`](https://pjt222.github.io/putior/reference/putior_skills.md)
  – all now support “raw”
- Extracted duplicated label resolution into
  [`resolve_label()`](https://pjt222.github.io/putior/reference/resolve_label.md)
  helper
- Added input path sanitization to ACP server endpoints

### Backward Compatibility

- All new parameters default to FALSE/previous behavior
- Existing code continues to work unchanged
- `putior_workflow` class inherits from `data.frame`, preserving
  compatibility

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
