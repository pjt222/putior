# putior 0.2.0

## Breaking Changes

* Renamed `putior_skills()` to `putior_guide()`. The function, its MCP tool
  (`putior_guide`), and its ACP operation (`guide`) all use the new name.
  `putior_help("skills")` still works as an alias for backward compatibility.
  The inst file was renamed from `SKILLS.md` to `GUIDE.md`, and the vignette
  from `skills.Rmd` to `ai-integration.Rmd`.

* `put()`, `put_auto()`, `put_generate()`, and `put_merge()` now default to
  `recursive = TRUE` (previously `FALSE`). Directory scans now include
  subdirectories by default. Pass `recursive = FALSE` for the old behavior.
  (#34)

## Bug Fixes

* Fixed `show_source_info = TRUE` using `<small>` HTML tags that are unsupported
  by GitHub's Mermaid renderer. Source file names are now shown without HTML
  formatting tags. (#32)
* Fixed pipe characters (`|`) in node labels breaking Mermaid diagram parsing.
  Pipes are now escaped using the `#124;` entity. (#33)
* `put()` now gives annotations without an `id` a fallback id (`node_1`,
  `node_2`, ...) when the uuid package is not installed. Before, such
  annotations had no id: if none had one, `put_diagram()` failed with a
  misleading "missing required column(s): id" error, and if only some had
  one, it silently dropped the others. This broke the quick-start example and
  the sandbox templates for anyone without uuid. The sandbox now also shows
  diagram errors in its status line instead of a blank preview. (#58)
* Fixed logging, which wrote nothing with logger 0.3 or later: every log call
  failed inside logger and the error was hidden. The `putior.log_level` option,
  set by `set_putior_log_level()` or for one call by the `log_level` argument,
  is now the only threshold, and an invalid `log_level` is an error. With
  logger installed, WARN-level messages now appear on stderr next to the
  matching R warnings. (#70)
* Fixed single-line block comment annotations (`/* put ... */`) silently
  losing their last property, which could drop an output and its edge.
  (#72)
* `put_merge()` no longer merges a manual annotation and an auto-detected
  file into one node when their ids meet: auto-detected rows get a suffix
  when their id (also in its Mermaid form, where `1` is `node_1`) is already
  used, so an unannotated `node_1.R` next to an annotation with the fallback
  id `node_1` stays separate. It also matches manual and auto-detected rows
  by file path, so an annotated `x/load.R` no longer hides an unannotated
  `y/load.R`, and with `merge_strategy = "supplement"` or `"union"` no
  longer takes the inputs and outputs detected in the other file. (#74)
* Annotation values may now contain the other kind of quote:
  `label:"Don't panic"` and `label:'Say "hi"'` keep their labels. Before,
  `put()` dropped any value with a quote character in it, without a warning,
  and the node showed its id instead; the troubleshooting vignette even
  recommended `label:"Load 'raw' data"`. There are still no escapes, so a
  value cannot contain its own kind of quote, and backslashes in Windows
  paths stay as they are. A property that `put()` cannot read is now named
  in its validation warning (with `validate = TRUE`, the default) instead
  of being dropped silently, and `is_valid_put_annotation()` returns
  `FALSE` for such a line. An annotation that ends with a continuation `\`
  (without a comma before it) on the last line of the file no longer loses
  its last property. `put_generate()` wraps a value that contains a double quote
  in single quotes, so that `put()` reads its suggestions back unchanged.
  (#91)
* A comment may now follow the values of an annotation, as the `put()` help
  page, the vignettes and the cheatsheet have always shown
  (`# put id:"a", label:"Load"   # first step`). Before, the comment made
  the last property unreadable, and it was dropped. Outside quotes,
  whitespace followed by `#`, `--`, `//` or `%` after a value starts the
  comment. In a multiline annotation, a comment may also come before the
  continuation `\` of a line. (#91)
* `put_diagram()` gives every node one Mermaid id and uses it in the node
  definition, edges, `class` lines and click directives. Before, edges to an
  artifact whose path has two punctuation characters in a row (such as
  `./raw data (v2).csv`) used a different id than the artifact node, so
  Mermaid drew an extra unlabeled node and left the artifact unconnected.
  Annotation ids that differ only in punctuation (`a-b` and `a_b`) were
  merged into one node with a self-loop; they now stay two nodes (`a_b`,
  `a_b_2`) and `put_diagram()` warns. Two data files whose names differ only
  in punctuation get two artifact nodes. `put_auto()` and `put_generate()`,
  which derive ids from file names, now give files that would share an id
  (`a-b.R` and `a_b.R`, `end.R` and `node_end.R`, or `load.R` in two
  folders) distinct ids (`load`, `load_2`). `put_generate(output = "file")`
  now writes each annotation next to the file it belongs to; when a file in
  between gave no annotation, the next one went into the wrong `.put` file.
  (#46)
* Node ids that are Mermaid keywords (`end`, `graph`, `flowchart`,
  `subgraph`, `style`, `class`, `classDef`, `click`, `linkStyle`, `call`,
  `href`, `interpolate`, and the link targets `_self`, `_blank`, `_parent`,
  `_top`) made the whole diagram fail to parse. They are now written as
  `node_end` and so on. `id:"end"` is a natural name for a
  pipeline's last step. (#45)
* With `source_info_style = "subgraph"`, subgraph ids are now `file_<name>`
  and never equal a node id. Before, a file `load.R` with a node `id:"load"`
  failed to render ("would create a cycle") on Mermaid 11, and on Mermaid 12,
  which GitHub uses, the node silently disappeared. Files with the same name
  in different folders now get one subgraph each instead of sharing one, and
  the subgraph label then includes as much of the folder path as it takes
  to tell them apart (`x/load.R`, `a/x/load.R`). (#45, #46)
* With `show_files = TRUE`, edge labels are now quoted and escaped like node
  labels (`-->|"raw data (v2).csv"|`). A file name with parentheses or other
  special characters made the diagram fail to parse. (#45)
* The `title` of `put_diagram()` is now written as a quoted YAML string.
  A title with `: ` (such as `"ETL: stage 1"`) made the diagram fail to
  parse, and text after ` #` was dropped as a YAML comment. (#45)
* A `#` in a label that Mermaid would read as a character entity is now
  escaped as `#35;`. Mermaid decodes `#<name>;` and `#<digits>;`, so a label
  such as `Step #35;` was shown as `Step #`. A plain `#` (`C#`, `item #1`)
  is left alone. `?put_diagram` now describes how labels and ids are
  written. (#45)
* `put_diagram()` and the MCP and ACP servers accept `direction = "TB"`,
  Mermaid's synonym for `"TD"`. GUIDE.md named `TB` as the default, but
  `"TB"` was rejected with an error. (#79)
* Labels that contain Mermaid syntax are now written so that Mermaid shows
  them as written. Mermaid read a line with `direction`, whitespace and
  `TB`, `BT`, `RL` or `LR` (and `TD` from Mermaid 11.17.2 on), as in
  "Change direction LR to TB", as a direction statement and dropped it:
  the node lost its label, and with `source_info_style = "subgraph"` a file
  named `direction LR.R` made the diagram fail to parse. That whitespace is
  now written as an entity (`direction#32;LR`). The same rule spans line
  breaks, so an edge to an id ending in `direction` (`wind_direction`)
  followed by an edge from an id starting with `LR` (`LR_prep`) lost both
  edges; such an edge now ends with `;`. On a line where `style` or
  `classDef` comes before it, in the label or in the node id, a `:`
  followed by an escaped character, as in `style:"bold"` (written
  `style:#quot;bold#quot;`), is now written as `#58;`: Mermaid removed the
  last `;` of such a line and showed `style:"bold#quot`. (#89)

## New Features

### MCP Server Integration
* Added `putior_mcp_server()` to expose putior functions as MCP tools for AI assistants
* Added `putior_mcp_tools()` to get/filter tool definitions for custom MCP integrations
* 16 tools available: `put`, `put_diagram`, `put_auto`, `put_generate`, `put_merge`,
  `get_comment_prefix`, `get_supported_extensions`, `list_supported_languages`,
  `get_detection_patterns`, `get_diagram_themes`, `putior_guide`, `putior_help`,
  `set_putior_log_level`, `is_valid_put_annotation`, `split_file_list`, `ext_to_language`
* Supports Claude Code, Claude Desktop, and other MCP-compatible clients
* Tools return JSON (workflow data as one object per node) or plain text.
  They print nothing, because with the stdio transport stdout is the protocol
  channel, and never write files or the clipboard, so every tool except
  `set_putior_log_level` is read-only. The `put_diagram` tool scans a `path`
  and returns the Mermaid code. (#65)
* The `put_diagram` tool takes a `source` argument: `annotations` (the
  default) scans with `put()`, `auto` draws the workflow that `put_auto()`
  detects, and `merge` combines both like `put_merge()`, with
  `merge_strategy`. When a scan finds nothing and R warned (the directory
  is empty, no file matches `pattern`, a file cannot be read), the scan
  tools now fail with R's warnings instead of returning `[]` or empty text:
  the warnings never reached the client. When nothing warned,
  `put_diagram` says what is missing for its `source`: no annotations
  (and it suggests `source = "auto"`), or no file that `put_auto()` can
  analyze. (#73)

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

### Auto-Detection Patterns (18 Languages, 902 Patterns)
* Full auto-detection for: R, Python, SQL, Shell, Julia, JavaScript, TypeScript,
  Go, Rust, Java, C, C++, MATLAB, Ruby, Lua, WGSL, Dockerfile, Makefile
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

### Custom Theme API
* Added `put_theme()` for creating custom color palettes (#39)
* New `palette` parameter on `put_diagram()` accepts `putior_theme` objects
* Override individual node types (input, process, output, decision, artifact, start, end)
* Base theme inheritance — customize only what you need. An override keeps
  every key it does not set from the `base` theme's style for that node type,
  including the text color and the border width (3px for start and end
  nodes, 1px for artifacts); earlier development versions dropped the unset
  keys and forced a 2px border (#61). If an override changes how light `fill`
  is, set `color` too, so the label stays readable

### Block Comment Annotations
* Added PUT annotation support inside `/* */` and `/** */` block comments (#37)
* Use `* put` as line prefix inside block bodies for all `//`-prefix languages
* Supports single-line block comments and JSDoc-style patterns

### File Exclusion
* Added `exclude` parameter to `put()`, `put_auto()`, `put_generate()`, and
  `put_merge()` for regex-based file exclusion (#38)

### WGSL Shader Language Support
* Registered `.wgsl` with `//` comment prefix (#31)
* 17 auto-detection patterns for GPU bindings, textures, samplers, and naga-oil imports

### Dockerfile Support
* Handle extensionless Dockerfile via `.FILENAME_MAP` (#35)
* 13 detection patterns for FROM, COPY, ADD, EXPOSE, VOLUME, CMD, RUN

### Makefile Support
* Handle Makefile and GNUmakefile via `.FILENAME_MAP` (#36)
* 10 detection patterns for include, wildcard, target rules, install, shell commands

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

### Interactive Sandbox
* New `run_sandbox()` opens an interactive Shiny app for trying PUT
  annotations: paste or type annotated code, simulate several files, and see
  the workflow diagram update as you edit (needs the shiny package)
* Added copy-to-clipboard button for quick Mermaid code export
* Added optional shinyAce syntax highlighting (graceful degradation)
* The sandbox loads Mermaid 12.2.0 from jsdelivr, pinned with a Subresource
  Integrity hash (#48). It draws diagrams in Mermaid 11's classic style (dagre
  layout, classic look, 200px label wrapping, no minimum node width), which
  putior's themes are made for and which GitLab, Quarto and VS Code show.
  GitHub moved to Mermaid 12 in October 2026 and draws putior diagrams in the
  neo look with labels wrapped at 120px (#54). A diagram with a syntax error
  shows Mermaid's error message. Mermaid 12 needs a current browser (ES2024;
  Safari 17.4 or later)
* File markers (`# ===== File: name.R =====`) are read one line at a time,
  with any spaces or tabs around them, at least three `=` and an optional
  closing run, so an unclosed marker no longer takes the next file with it
  and a name containing `=` is recognized. When two simulated files have the
  same name (ignoring case), both are kept, the later one in a `copy_2/`
  folder, and the status line says so; so does text before the first marker,
  which is ignored. File names are made safe to write on Windows (trailing
  dots dropped, characters such as `:` or `?` replaced), and a file that still
  cannot be written is left out with a note instead of emptying the whole
  diagram (#53)
* If Mermaid cannot be loaded from jsdelivr (no network, a blocked CDN), the
  preview says so instead of staying blank, and the copy button and the
  Mermaid Code tab still work. A diagram that changes while the preview is
  hidden is drawn as soon as the preview is visible again, whether its tab is
  shown or a collapsed pane is opened (#64)

### Documentation
* Documented all valid `node_type` values across vignettes and reference (#40)
* 8 comprehensive vignettes including quick-start, annotation guide, features tour,
  API reference, showcase, troubleshooting, quick-reference, and AI integration
* Professional cheat sheet (`inst/cheatsheet/putior-cheatsheet.qmd`)
* 20 example files in `inst/examples/`
* `putior_guide()` and `putior_help()` for in-session reference

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
  `putior_guide()` -- all now support "raw"
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
