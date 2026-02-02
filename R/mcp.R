#' MCP Server Integration for putior
#'
#' Functions for exposing putior functionality as MCP (Model Context Protocol)
#' tools, enabling AI assistants like Claude to directly interact with workflow
#' annotation and diagram generation capabilities.
#'
#' @name putior_mcp
#' @keywords internal
NULL

#' Start putior MCP Server
#'
#' Starts an MCP server that exposes putior functions as tools for AI assistants.
#' This enables AI coding assistants (Claude Code, Claude Desktop) to directly
#' call workflow annotation and diagram generation functions.
#'
#' @param type Character string specifying the transport type:
#'   \itemize{
#'     \item "stdio" (default) - Standard input/output transport
#'     \item "http" - HTTP transport
#'   }
#' @param host Character string specifying the host for HTTP transport.
#'   Default: "127.0.0.1"
#' @param port Integer specifying the port for HTTP transport.
#'   Default: 8080
#'
#' @details
#' The MCP server exposes the following putior functions as tools:
#' \itemize{
#'   \item \code{put} - Scan files for PUT annotations
#'   \item \code{put_diagram} - Generate Mermaid diagrams
#'   \item \code{put_auto} - Auto-detect workflow from code
#'   \item \code{put_generate} - Generate annotation suggestions
#'   \item \code{put_merge} - Merge manual + auto annotations
#'   \item \code{get_comment_prefix} - Get comment prefix for extension
#'   \item \code{get_supported_extensions} - List supported extensions
#'   \item \code{list_supported_languages} - List supported languages
#'   \item \code{get_detection_patterns} - Get auto-detection patterns
#'   \item \code{get_diagram_themes} - List available themes
#'   \item \code{putior_skills} - AI assistant documentation
#'   \item \code{putior_help} - Quick reference help
#'   \item \code{set_putior_log_level} - Configure logging
#'   \item \code{is_valid_put_annotation} - Validate annotation syntax
#'   \item \code{split_file_list} - Parse file lists
#'   \item \code{ext_to_language} - Extension to language name
#' }
#'
#' @section Configuration:
#'
#' \strong{Claude Code (WSL/Linux/macOS):}
#' \preformatted{
#' claude mcp add putior -- Rscript -e "putior::putior_mcp_server()"
#' }
#'
#' \strong{Claude Desktop (Windows):}
#' Add to \code{\%APPDATA\%\\Claude\\claude_desktop_config.json}:
#' \preformatted{
#' {
#'   "mcpServers": {
#'     "putior": {
#'       "command": "Rscript",
#'       "args": ["-e", "putior::putior_mcp_server()"]
#'     }
#'   }
#' }
#' }
#'
#' @return This function does not return; it runs the MCP server until terminated.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Start MCP server with default stdio transport
#' putior_mcp_server()
#'
#' # Start MCP server with HTTP transport
#' putior_mcp_server(type = "http", port = 8080)
#' }
#'
#' @seealso \code{\link{putior_mcp_tools}} for accessing the tool definitions
putior_mcp_server <- function(type = c("stdio", "http"),
                               host = "127.0.0.1",
                               port = 8080L) {
  type <- match.arg(type)

  # Check for required dependencies
  if (!requireNamespace("mcptools", quietly = TRUE)) {
    stop(
      "The 'mcptools' package is required for MCP server functionality.\n",
      "Install it with: remotes::install_github('posit-dev/mcptools')\n",
      "Or: pak::pak('posit-dev/mcptools')",
      call. = FALSE
    )
  }

  if (!requireNamespace("ellmer", quietly = TRUE)) {
    stop(
      "The 'ellmer' package is required for MCP server functionality.\n",
      "Install it with: install.packages('ellmer')\n",
      "Or: pak::pak('ellmer')",
      call. = FALSE
    )
  }

  # Get all putior tools
  tools <- putior_mcp_tools()

  # Start the MCP server
  mcptools::mcp_server(
    tools = tools,
    type = type,
    host = host,
    port = as.integer(port)
  )
}

#' Get putior MCP Tool Definitions
#'
#' Returns a list of ellmer tool definitions for all putior functions that
#' can be exposed via MCP. This function is primarily used internally by
#' \code{\link{putior_mcp_server}}, but can also be used directly for
#' inspection or custom MCP server implementations.
#'
#' @param include Character vector of tool names to include. If NULL (default),
#'   all available tools are included.
#' @param exclude Character vector of tool names to exclude. Default excludes
#'   "run_sandbox" since Shiny apps cannot run via MCP.
#'
#' @return A list of ellmer tool definitions suitable for use with
#'   \code{mcptools::mcp_server()}.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Get all putior MCP tools
#' tools <- putior_mcp_tools()
#'
#' # Get specific tools only
#' tools <- putior_mcp_tools(include = c("put", "put_diagram"))
#'
#' # Exclude specific tools
#' tools <- putior_mcp_tools(exclude = c("run_sandbox", "putior_help"))
#' }
#'
#' @seealso \code{\link{putior_mcp_server}} for starting the MCP server
putior_mcp_tools <- function(include = NULL,
                              exclude = c("run_sandbox")) {
  # Check for ellmer package
  if (!requireNamespace("ellmer", quietly = TRUE)) {
    stop(
      "The 'ellmer' package is required for MCP tool definitions.\n",
      "Install it with: install.packages('ellmer')\n",
      "Or: pak::pak('ellmer')",
      call. = FALSE
    )
  }

  # Build all tool definitions
  all_tools <- list(
    # Core workflow functions
    make_tool_put(),
    make_tool_put_diagram(),
    make_tool_put_auto(),
    make_tool_put_generate(),
    make_tool_put_merge(),

    # Reference/discovery functions
    make_tool_get_comment_prefix(),
    make_tool_get_supported_extensions(),
    make_tool_list_supported_languages(),
    make_tool_get_detection_patterns(),
    make_tool_get_diagram_themes(),
    make_tool_putior_skills(),
    make_tool_putior_help(),
    make_tool_set_putior_log_level(),

    # Utility functions
    make_tool_is_valid_put_annotation(),
    make_tool_split_file_list(),
    make_tool_ext_to_language()
  )

  # Name the tools (using @ for S7 object access)
  names(all_tools) <- sapply(all_tools, function(t) t@name)

  # Filter by include
  if (!is.null(include)) {
    all_tools <- all_tools[names(all_tools) %in% include]
  }

  # Filter by exclude
  if (!is.null(exclude)) {
    all_tools <- all_tools[!names(all_tools) %in% exclude]
  }

  return(all_tools)
}

# =============================================================================
# Tool Definition Functions
# =============================================================================

#' @noRd
make_tool_put <- function() {
  ellmer::tool(
    fun = put,
    description = paste0(
      "Scan source files for PUT workflow annotations. ",
      "Extracts structured annotations that define workflow nodes, ",
      "inputs, outputs, and metadata from source code comments. ",
      "Supports 30+ programming languages with automatic comment syntax detection. ",
      "Returns a data frame that can be passed to put_diagram() for visualization."
    ),
    name = "put",
    annotations = list(
      title = "Scan Files for PUT Annotations",
      readOnlyHint = TRUE,
      openWorldHint = TRUE
    ),
    arguments = list(
      path = ellmer::type_string(
        description = "Path to directory or file to scan for PUT annotations"
      ),
      pattern = ellmer::type_string(
        description = "File pattern regex (default: R/Python/SQL/Shell/Julia files)",
        required = FALSE
      ),
      recursive = ellmer::type_boolean(
        description = "Search subdirectories recursively (default: FALSE)",
        required = FALSE
      ),
      include_line_numbers = ellmer::type_boolean(
        description = "Include line numbers in output (default: FALSE)",
        required = FALSE
      ),
      validate = ellmer::type_boolean(
        description = "Validate annotations for common issues (default: TRUE)",
        required = FALSE
      ),
      log_level = ellmer::type_enum(
        description = "Log level: DEBUG, INFO, WARN, or ERROR (default: from options)",
        values = c("DEBUG", "INFO", "WARN", "ERROR"),
        required = FALSE
      )
    )
  )
}

#' @noRd
make_tool_put_diagram <- function() {
  ellmer::tool(
    fun = put_diagram,
    description = paste0(
      "Generate a Mermaid flowchart diagram from PUT workflow data. ",
      "Creates visual representations of data flows and processing steps. ",
      "Supports multiple themes, node styling, and interactive features. ",
      "Output can be printed to console, saved to file, or returned as raw code."
    ),
    name = "put_diagram",
    annotations = list(
      title = "Generate Workflow Diagram",
      readOnlyHint = TRUE
    ),
    arguments = list(
      workflow = ellmer::type_ignore(),
      output = ellmer::type_enum(
        description = "Output format: console, file, clipboard, or raw (default: console)",
        values = c("console", "file", "clipboard", "raw"),
        required = FALSE
      ),
      file = ellmer::type_string(
        description = "Output file path when output='file' (default: workflow_diagram.md)",
        required = FALSE
      ),
      title = ellmer::type_string(
        description = "Optional title for the diagram",
        required = FALSE
      ),
      direction = ellmer::type_enum(
        description = "Diagram direction: TD, LR, BT, or RL (default: TD)",
        values = c("TD", "LR", "BT", "RL"),
        required = FALSE
      ),
      node_labels = ellmer::type_enum(
        description = "What to show in nodes: name, label, or both (default: label)",
        values = c("name", "label", "both"),
        required = FALSE
      ),
      show_files = ellmer::type_boolean(
        description = "Show file labels on connections (default: FALSE)",
        required = FALSE
      ),
      show_artifacts = ellmer::type_boolean(
        description = "Show data files as nodes (default: FALSE)",
        required = FALSE
      ),
      show_workflow_boundaries = ellmer::type_boolean(
        description = "Apply special styling to start/end nodes (default: TRUE)",
        required = FALSE
      ),
      style_nodes = ellmer::type_boolean(
        description = "Apply styling based on node_type (default: TRUE)",
        required = FALSE
      ),
      theme = ellmer::type_enum(
        description = "Color theme: light, dark, auto, minimal, github (default: light)",
        values = c("light", "dark", "auto", "minimal", "github"),
        required = FALSE
      ),
      show_source_info = ellmer::type_boolean(
        description = "Display source file info in nodes (default: FALSE)",
        required = FALSE
      ),
      source_info_style = ellmer::type_enum(
        description = "How to display source info: inline or subgraph (default: inline)",
        values = c("inline", "subgraph"),
        required = FALSE
      ),
      enable_clicks = ellmer::type_boolean(
        description = "Make nodes clickable (default: FALSE)",
        required = FALSE
      ),
      click_protocol = ellmer::type_enum(
        description = "URL protocol for clickable nodes: vscode, file, rstudio (default: vscode)",
        values = c("vscode", "file", "rstudio"),
        required = FALSE
      ),
      log_level = ellmer::type_enum(
        description = "Log level: DEBUG, INFO, WARN, or ERROR (default: from options)",
        values = c("DEBUG", "INFO", "WARN", "ERROR"),
        required = FALSE
      )
    )
  )
}

#' @noRd
make_tool_put_auto <- function() {
  ellmer::tool(
    fun = put_auto,
    description = paste0(
      "Auto-detect workflow elements from code analysis without requiring explicit annotations. ",
      "Analyzes source files to detect file inputs, outputs, and dependencies ",
      "based on function calls like read_csv(), write.csv(), etc. ",
      "Similar to how roxygen2 auto-generates documentation skeletons. ",
      "Returns a data frame compatible with put_diagram()."
    ),
    name = "put_auto",
    annotations = list(
      title = "Auto-Detect Workflow",
      readOnlyHint = TRUE,
      openWorldHint = TRUE
    ),
    arguments = list(
      path = ellmer::type_string(
        description = "Path to directory or file to analyze"
      ),
      pattern = ellmer::type_string(
        description = "File pattern regex (default: R/Python/SQL/Shell/Julia files)",
        required = FALSE
      ),
      recursive = ellmer::type_boolean(
        description = "Search subdirectories recursively (default: FALSE)",
        required = FALSE
      ),
      detect_inputs = ellmer::type_boolean(
        description = "Detect file inputs (default: TRUE)",
        required = FALSE
      ),
      detect_outputs = ellmer::type_boolean(
        description = "Detect file outputs (default: TRUE)",
        required = FALSE
      ),
      detect_dependencies = ellmer::type_boolean(
        description = "Detect script dependencies/source calls (default: TRUE)",
        required = FALSE
      ),
      include_line_numbers = ellmer::type_boolean(
        description = "Include line numbers (default: FALSE)",
        required = FALSE
      ),
      log_level = ellmer::type_enum(
        description = "Log level: DEBUG, INFO, WARN, or ERROR (default: from options)",
        values = c("DEBUG", "INFO", "WARN", "ERROR"),
        required = FALSE
      )
    )
  )
}

#' @noRd
make_tool_put_generate <- function() {
  ellmer::tool(
    fun = put_generate,
    description = paste0(
      "Generate suggested PUT annotation comments based on code analysis. ",
      "Analyzes source files and produces annotation text that can be copied ",
      "into source files. Similar to how roxygen2 generates documentation skeletons. ",
      "Supports single-line and multiline annotation styles."
    ),
    name = "put_generate",
    annotations = list(
      title = "Generate Annotation Suggestions",
      readOnlyHint = TRUE,
      openWorldHint = TRUE
    ),
    arguments = list(
      path = ellmer::type_string(
        description = "Path to file or directory to analyze"
      ),
      pattern = ellmer::type_string(
        description = "File pattern regex (default: R/Python/SQL/Shell/Julia files)",
        required = FALSE
      ),
      recursive = ellmer::type_boolean(
        description = "Search subdirectories recursively (default: FALSE)",
        required = FALSE
      ),
      output = ellmer::type_enum(
        description = "Output: console, clipboard, or file (default: console)",
        values = c("console", "clipboard", "file"),
        required = FALSE
      ),
      insert = ellmer::type_boolean(
        description = "Insert annotations directly into source files (default: FALSE)",
        required = FALSE
      ),
      style = ellmer::type_enum(
        description = "Annotation style: single or multiline (default: multiline)",
        values = c("single", "multiline"),
        required = FALSE
      )
    )
  )
}

#' @noRd
make_tool_put_merge <- function() {
  ellmer::tool(
    fun = put_merge,
    description = paste0(
      "Combine manually written PUT annotations with auto-detected workflow elements. ",
      "Supports flexible strategies: manual_priority (manual overrides auto), ",
      "supplement (auto fills in missing fields), union (combine all detected I/O). ",
      "Returns a merged data frame compatible with put_diagram()."
    ),
    name = "put_merge",
    annotations = list(
      title = "Merge Manual and Auto Annotations",
      readOnlyHint = TRUE,
      openWorldHint = TRUE
    ),
    arguments = list(
      path = ellmer::type_string(
        description = "Path to file or directory"
      ),
      pattern = ellmer::type_string(
        description = "File pattern regex (default: R/Python/SQL/Shell/Julia files)",
        required = FALSE
      ),
      recursive = ellmer::type_boolean(
        description = "Search subdirectories recursively (default: FALSE)",
        required = FALSE
      ),
      merge_strategy = ellmer::type_enum(
        description = "Merge strategy: manual_priority, supplement, or union (default: manual_priority)",
        values = c("manual_priority", "supplement", "union"),
        required = FALSE
      ),
      include_line_numbers = ellmer::type_boolean(
        description = "Include line numbers (default: FALSE)",
        required = FALSE
      )
    )
  )
}

#' @noRd
make_tool_get_comment_prefix <- function() {
  ellmer::tool(
    fun = get_comment_prefix,
    description = paste0(
      "Get the single-line comment prefix for a given file extension. ",
      "Returns '#' for R/Python, '--' for SQL, '//' for JavaScript, etc. ",
      "Falls back to '#' for unknown extensions."
    ),
    name = "get_comment_prefix",
    annotations = list(
      title = "Get Comment Prefix",
      readOnlyHint = TRUE
    ),
    arguments = list(
      ext = ellmer::type_string(
        description = "File extension without dot (e.g., 'r', 'sql', 'js')"
      )
    )
  )
}

#' @noRd
make_tool_get_supported_extensions <- function() {
  ellmer::tool(
    fun = get_supported_extensions,
    description = paste0(
      "Get all file extensions supported by putior's annotation parsing system. ",
      "Returns a character vector of extensions like c('r', 'py', 'sql', 'js', ...)."
    ),
    name = "get_supported_extensions",
    annotations = list(
      title = "List Supported Extensions",
      readOnlyHint = TRUE
    )
  )
}

#' @noRd
make_tool_list_supported_languages <- function() {
  ellmer::tool(
    fun = list_supported_languages,
    description = paste0(
      "Get all programming languages supported by putior. ",
      "Set detection_only=TRUE to get only languages with auto-detection patterns."
    ),
    name = "list_supported_languages",
    annotations = list(
      title = "List Supported Languages",
      readOnlyHint = TRUE
    ),
    arguments = list(
      detection_only = ellmer::type_boolean(
        description = "Return only languages with auto-detection pattern support (default: FALSE)",
        required = FALSE
      )
    )
  )
}

#' @noRd
make_tool_get_detection_patterns <- function() {
  ellmer::tool(
    fun = get_detection_patterns,
    description = paste0(
      "Get auto-detection patterns for a programming language. ",
      "Returns patterns used to detect file inputs, outputs, and dependencies. ",
      "Supports 15 languages including R, Python, JavaScript, Go, Rust, etc."
    ),
    name = "get_detection_patterns",
    annotations = list(
      title = "Get Detection Patterns",
      readOnlyHint = TRUE
    ),
    arguments = list(
      language = ellmer::type_string(
        description = "Language name (e.g., 'r', 'python', 'javascript')"
      ),
      type = ellmer::type_enum(
        description = "Pattern type: all, input, output, or dependency (default: all)",
        values = c("all", "input", "output", "dependency"),
        required = FALSE
      )
    )
  )
}

#' @noRd
make_tool_get_diagram_themes <- function() {
  ellmer::tool(
    fun = get_diagram_themes,
    description = paste0(
      "Get information about available color themes for workflow diagrams. ",
      "Returns a named list describing light, dark, auto, minimal, and github themes."
    ),
    name = "get_diagram_themes",
    annotations = list(
      title = "List Diagram Themes",
      readOnlyHint = TRUE
    )
  )
}

#' @noRd
make_tool_putior_skills <- function() {
  ellmer::tool(
    fun = putior_skills,
    description = paste0(
      "Access putior skills documentation for AI assistants. ",
      "Provides structured information about annotation syntax, supported languages, ",
      "core functions, detection patterns, and usage examples. ",
      "Use output='raw' to get markdown content."
    ),
    name = "putior_skills",
    annotations = list(
      title = "AI Assistant Skills Reference",
      readOnlyHint = TRUE
    ),
    arguments = list(
      topic = ellmer::type_enum(
        description = "Topic section: quick-start, syntax, languages, functions, patterns, or examples",
        values = c("quick-start", "syntax", "languages", "functions", "patterns", "examples"),
        required = FALSE
      ),
      output = ellmer::type_enum(
        description = "Output format: console, raw, or clipboard (default: raw for MCP)",
        values = c("console", "raw", "clipboard"),
        required = FALSE
      )
    )
  )
}

#' @noRd
make_tool_putior_help <- function() {
  ellmer::tool(
    fun = putior_help,
    description = paste0(
      "Get quick-reference help for putior tasks and syntax. ",
      "Topics include: annotation (syntax), themes, languages, node_types, patterns, examples, skills."
    ),
    name = "putior_help",
    annotations = list(
      title = "Quick Reference Help",
      readOnlyHint = TRUE
    ),
    arguments = list(
      topic = ellmer::type_enum(
        description = "Help topic to display",
        values = c("annotation", "themes", "languages", "node_types", "patterns", "examples", "skills"),
        required = FALSE
      )
    )
  )
}

#' @noRd
make_tool_set_putior_log_level <- function() {
  ellmer::tool(
    fun = set_putior_log_level,
    description = paste0(
      "Configure logging verbosity for putior functions. ",
      "DEBUG shows fine-grained operations, INFO shows progress milestones, ",
      "WARN shows issues (default), ERROR shows only fatal issues."
    ),
    name = "set_putior_log_level",
    annotations = list(
      title = "Set Log Level",
      readOnlyHint = FALSE
    ),
    arguments = list(
      level = ellmer::type_enum(
        description = "Log level: DEBUG, INFO, WARN, or ERROR (default: WARN)",
        values = c("DEBUG", "INFO", "WARN", "ERROR"),
        required = FALSE
      )
    )
  )
}

#' @noRd
make_tool_is_valid_put_annotation <- function() {
  ellmer::tool(
    fun = is_valid_put_annotation,
    description = paste0(
      "Validate PUT annotation syntax. ",
      "Returns TRUE if the annotation is valid, FALSE otherwise. ",
      "Useful for testing annotation syntax before adding to source files."
    ),
    name = "is_valid_put_annotation",
    annotations = list(
      title = "Validate Annotation Syntax",
      readOnlyHint = TRUE
    ),
    arguments = list(
      line = ellmer::type_string(
        description = "PUT annotation line to validate (e.g., '# put id:\"test\", label:\"Test\"')"
      )
    )
  )
}

#' @noRd
make_tool_split_file_list <- function() {
  ellmer::tool(
    fun = split_file_list,
    description = paste0(
      "Parse a comma-separated file list into individual file names. ",
      "Handles whitespace and returns a character vector of file names."
    ),
    name = "split_file_list",
    annotations = list(
      title = "Split File List",
      readOnlyHint = TRUE
    ),
    arguments = list(
      file_string = ellmer::type_string(
        description = "Comma-separated file names (e.g., 'file1.csv, file2.csv')"
      )
    )
  )
}

#' @noRd
make_tool_ext_to_language <- function() {
  ellmer::tool(
    fun = ext_to_language,
    description = paste0(
      "Convert a file extension to a standardized language name. ",
      "Used for detection pattern lookup. Returns NULL for unsupported extensions."
    ),
    name = "ext_to_language",
    annotations = list(
      title = "Extension to Language",
      readOnlyHint = TRUE
    ),
    arguments = list(
      ext = ellmer::type_string(
        description = "File extension without dot (e.g., 'py', 'js', 'sql')"
      )
    )
  )
}
