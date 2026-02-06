# putior 0.2.0.9000 (development version)

## New Features

### MCP Server Integration
* Added `putior_mcp_server()` to expose putior functions as MCP tools for AI assistants
* Added `putior_mcp_tools()` to get/filter tool definitions for custom MCP integrations
* 16 tools available: `put`, `put_diagram`, `put_auto`, `put_generate`, `put_merge`,
  `get_comment_prefix`, `get_supported_extensions`, `list_supported_languages`,
  `get_detection_patterns`, `get_diagram_themes`, `putior_skills`, `putior_help`,
  `set_putior_log_level`, `is_valid_put_annotation`, `split_file_list`, `ext_to_language`
* Supports Claude Code, Claude Desktop, and other MCP-compatible clients

### ACP Server Integration
* Added `putior_acp_server()` to expose putior as an ACP agent for inter-agent
  communication via REST API
* Added `putior_acp_manifest()` for agent discovery
* Supports natural language requests for all core operations
* Input path sanitization to prevent directory traversal attacks

### Multi-Language Comment Syntax (30+ Languages)
* Added support for 30+ programming languages with automatic comment prefix detection
* Comment styles: `#` (R, Python, Shell, etc.), `--` (SQL, Lua, Haskell),
  `//` (JavaScript, TypeScript, C/C++, Go, Rust, Java, etc.), `%` (MATLAB, LaTeX)
* Added `get_comment_prefix()`, `get_supported_extensions()`, `ext_to_language()`
* Added `list_supported_languages()` to enumerate all supported languages

### Auto-Detection Patterns (15 Languages, 862 Patterns)
* Full auto-detection for: R, Python, SQL, Shell, Julia, JavaScript, TypeScript,
  Go, Rust, Java, C, C++, MATLAB, Ruby, Lua
* Pattern inheritance: TypeScript extends JavaScript, C++ extends C
* Single authoritative language registry (`R/language_registry.R`)

### LLM Detection Patterns
* 54 patterns for modern AI/ML libraries across R and Python
* R: ellmer, tidyllm, httr2 (API requests)
* Python: ollama, openai, anthropic, langchain, transformers, litellm, vllm,
  google generative AI, groq

### Auto-Annotation Feature
* Added `put_auto()` for automatic workflow detection from code analysis
* Added `put_generate()` for generating PUT annotation comments (roxygen2-style)
  - Now supports `output = "raw"` for programmatic access
* Added `put_merge()` for combining manual and auto-detected annotations
  - Three merge strategies: "manual_priority", "supplement", "union"

### Colorblind-Safe Themes
* Added 4 viridis family themes for accessibility:
  - `viridis`: Purple-blue-green-yellow (general accessibility)
  - `magma`: Purple-red-yellow (high contrast, print-friendly)
  - `plasma`: Purple-pink-orange-yellow (presentations)
  - `cividis`: Blue-gray-yellow (deuteranopia/protanopia optimized)
* All themes perceptually uniform and tested for color vision deficiencies

### Metadata Display
* Added `show_source_info` parameter to `put_diagram()` for displaying source file
  information in diagram nodes
* Added `source_info_style` parameter with "inline" and "subgraph" display options

### Clickable Hyperlinks
* Added `enable_clicks` parameter to `put_diagram()` for making nodes clickable
* Added `click_protocol` parameter: "vscode", "file", "rstudio"
* Click directives include line numbers when available

### Structured Logging
* Optional `logger` package integration for debugging annotation parsing
* Log levels: DEBUG, INFO, WARN (default), ERROR
* Added `set_putior_log_level()` for configuration
* Per-call override via `log_level` parameter on core functions

### S3 Workflow Class
* Workflow data frames now have `putior_workflow` S3 class
* Added `print.putior_workflow()` for concise workflow summaries
* Added `summary.putior_workflow()` for structured summary information

### Interactive Sandbox Enhancements
* Added copy-to-clipboard button for quick Mermaid code export
* Added optional shinyAce syntax highlighting (graceful degradation)

### Documentation
* 8 comprehensive vignettes including quick-start, annotation guide, features tour,
  API reference, showcase, troubleshooting, quick-reference, and skills reference
* Professional cheat sheet (`inst/cheatsheet/putior-cheatsheet.qmd`)
* 20 example files in `inst/examples/`
* `putior_skills()` and `putior_help()` for in-session reference

### New Helper Functions
* `resolve_label()` internal helper to reduce code duplication in diagram generation
* `sanitize_acp_path()` for ACP input validation
* `normalize_path_for_url()` for cross-platform path handling
* `generate_click_url()` for creating protocol-specific URLs
* `generate_click_directives()` for Mermaid click action generation
* `generate_file_subgraphs()` for file-based node grouping

## Bug Fixes
* Fixed ACP `put_generate()` called with invalid `output = "raw"` (now supported)
* Fixed MCP theme enum missing viridis family themes
* Fixed documentation using deprecated `name` instead of `id` in examples
* Fixed ACP theme extraction regex missing colorblind-safe themes
* Replaced unsafe `1:nrow()` loops with `seq_len(nrow())` to handle empty data frames
* Moved `%||%` operator from `acp.R` to `zzz.R` for shared access

## Improvements
* Consolidated language detection list into single authoritative registry
  (`.LANGUAGES_WITH_DETECTION` in `language_registry.R`)
* Standardized `output` parameter across `put_diagram()`, `put_generate()`, and
  `putior_skills()` -- all now support "raw"
* Extracted duplicated label resolution into `resolve_label()` helper
* Added input path sanitization to ACP server endpoints

## Backward Compatibility
* All new parameters default to FALSE/previous behavior
* Existing code continues to work unchanged
* `putior_workflow` class inherits from `data.frame`, preserving compatibility

# putior 0.1.0

* Initial CRAN submission
* Added `put()` function for extracting workflow annotations from source code files
* Added `put_diagram()` function for creating Mermaid flowchart diagrams
* Added `is_valid_put_annotation()` for validating annotation syntax
* Support for multiple programming languages: R, Python, SQL, Shell, and Julia
* Multiline annotation support with backslash continuation syntax for better code
  style compliance
* Automatic UUID generation when `id` field is omitted from annotations
* Automatic output defaulting to file name when `output` field is omitted
* Renamed annotation field from `name` to `id` for better graph theory alignment
* Five built-in themes for diagrams: light, dark, auto, minimal, and github
* Automatic file flow tracking between workflow steps
* Comprehensive vignette with examples
* Full test coverage for all major functions
