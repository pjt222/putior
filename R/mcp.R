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
#' @param root For HTTP transport: the folder that the tools may scan
#'   (default: the working directory). A relative path is taken from it, a
#'   path outside it is an error, and a recursive scan skips the files that
#'   links inside it lead outside to. Over stdio the client is the local
#'   program that started the server, and paths are not limited.
#' @param token For HTTP transport: \code{NULL} (default) or a string of
#'   at least 16 characters without spaces that clients must send as the
#'   header \code{Plumber-Shared-Secret: <token>}. A server on an address
#'   other than a loopback one (\code{127.0.0.1}, \code{localhost},
#'   \code{::1}) needs a token. Without one, only requests addressed to a
#'   loopback name are answered.
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
#'   \item \code{putior_guide} - AI assistant documentation
#'   \item \code{putior_help} - Quick reference help
#'   \item \code{set_putior_log_level} - Configure logging
#'   \item \code{is_valid_put_annotation} - Validate annotation syntax
#'   \item \code{split_file_list} - Parse file lists
#'   \item \code{ext_to_language} - Extension to language name
#' }
#'
#' Only these tools are served: mcptools' tools for choosing a running R
#' session (\code{list_r_sessions}, \code{select_r_session}) are turned off,
#' so every call runs in the server's own R process.
#'
#' Over stdio, R warnings would never reach the client. When R warns while
#' a tool runs (invalid annotations, a \code{<} in a title or label, a
#' diagram over Mermaid's size limits, ...), the tool returns the warnings
#' as a second text item after its result, at most 20 of them, each cut to
#' 1,000 characters. For \code{put_diagram} they are Mermaid comment lines,
#' so the diagram still renders when a client joins the two items; the
#' first item is always exactly the Mermaid code. When a call fails, the warnings raised before
#' the error follow its message.
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
#' @section Security:
#' Over stdio nothing below applies: the client is the program that started
#' the server. Over HTTP:
#' \itemize{
#'   \item A tool can scan only the \code{root} folder and what lies below
#'     it, and returns the file names, labels and annotations found there,
#'     with the same rules as \code{\link{putior_acp_server}}: a path
#'     outside the root is an error, also through a symbolic link or
#'     junction; a recursive scan skips the files that links inside the
#'     root lead outside to; a path with a \code{..} component, control
#'     characters or a network or device form is rejected. Results and
#'     messages show the root as \code{<root>}, and \code{put_diagram}
#'     refuses \code{enable_clicks}, whose links name files by their path
#'     on the server.
#'   \item Without a token, the server runs only on a loopback \code{host}
#'     and answers only requests addressed to a loopback name, so that a
#'     web page cannot reach it through DNS rebinding; mcptools also
#'     rejects requests from web pages of other origins.
#'   \item mcptools checks the token and the Host, through options that
#'     putior sets. Before serving, the server tests that mcptools refuses
#'     requests without the token or from an untrusted Host; if it does not
#'     (a version that reads other settings), the server does not start.
#'   \item mcptools' own settings stay in force: hosts trusted through the
#'     option \code{mcptools.http_trusted_hosts} or the environment
#'     variable \code{MCPTOOLS_HTTP_TRUSTED_HOSTS} are answered too, and a
#'     secret set through \code{mcptools.http_shared_secret} or
#'     \code{plumber2.sharedSecret} is required when \code{token} is
#'     \code{NULL}.
#'   \item To serve other machines, set \code{token}; mcptools then answers
#'     only requests that send it:
#' \preformatted{
#' # R
#' putior_mcp_server(type = "http", host = "0.0.0.0", port = 8080,
#'                   root = "path/to/project",
#'                   token = Sys.getenv("PUTIOR_MCP_TOKEN"))
#'
#' # Claude Code
#' claude mcp add --transport http putior http://<server>:8080/ \\
#'   --header "Plumber-Shared-Secret: <token>"
#' }
#'   \item The server does not use TLS and mcptools does not limit the
#'     request size: across a network, put it behind a proxy that serves
#'     HTTPS and limits the size, or the token travels in clear text.
#' }
#'
#' @return This function does not return; it runs the MCP server until terminated.
#'
#' @family integration
#' @export
#'
#' @examples
#' \dontrun{
#' # Start MCP server with default stdio transport
#' putior_mcp_server()
#'
#' # Start MCP server with HTTP transport, scanning only the current folder
#' putior_mcp_server(type = "http", port = 8080)
#' }
#'
#' @seealso \code{\link{putior_mcp_tools}} for accessing the tool definitions
putior_mcp_server <- function(type = c("stdio", "http"),
                               host = "127.0.0.1",
                               port = 8080L,
                               root = getwd(),
                               token = NULL) {
  type <- match.arg(type)

  # Check for required dependencies
  if (!requireNamespace("mcptools", quietly = TRUE)) {
    stop(
      "The 'mcptools' package is required for MCP server functionality.\n",
      "Install it with: install.packages('mcptools')",
      call. = FALSE
    )
  }

  # Older mcptools turned a list of content items, as a tool returns when
  # R warned, into "<object>" text and lost the result
  if (utils::packageVersion("mcptools") < "1.0.0") {
    stop(
      "putior's MCP server needs mcptools 1.0.0 or later; installed: ",
      utils::packageVersion("mcptools"), ".\n",
      "Update it with: install.packages('mcptools')",
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

  # Validate port for HTTP transport
  if (type == "http") {
    port <- as.integer(port)
    if (is.na(port) || port < 1L || port > 65535L) {
      stop("'port' must be an integer between 1 and 65535. Received: ", port,
           call. = FALSE)
    }
  }

  # Over HTTP, other programs (or machines) can call the tools: confine
  # scans to root, and use mcptools' shared secret and trusted hosts (#111)
  if (type == "http") {
    root <- check_server_root(root)
    check_server_token(token, host, "Plumber-Shared-Secret: <token>")
    mcp_check_http_security()
    # With a token, mcptools answers only requests that send it. Without
    # one, only requests addressed to this machine by a loopback name (no
    # DNS rebinding), next to the hosts mcptools is told to trust;
    # mcptools also rejects browser pages from other origins. Settings of
    # mcptools' own stay in force.
    old_options <- if (is.null(token)) {
      options(mcptools.http_trusted_hosts = unique(c(
        getOption("mcptools.http_trusted_hosts"), mcp_loopback_hosts(host, port)
      )))
    } else {
      options(mcptools.http_shared_secret = token)
    }
    on.exit(options(old_options), add = TRUE)
    .mcp_state$root <- root
    on.exit(.mcp_state$root <- NULL, add = TRUE)
    if (host == "0.0.0.0") {
      warning(
        "Binding to 0.0.0.0 exposes the MCP server to all network interfaces; ",
        "requests need the token. Use host = \"127.0.0.1\" for local-only access.",
        call. = FALSE
      )
    }
  }

  # Get all putior tools
  tools <- putior_mcp_tools()

  # Start the MCP server
  # Without mcptools' session tools: clients saw 18 tools, and a call could
  # run in a user's live R session (another working directory, another
  # putior version) instead of the server's own process
  mcptools::mcp_server(
    tools = tools,
    type = type,
    host = host,
    port = as.integer(port),
    session_tools = FALSE
  )
}

#' Get putior MCP Tool Definitions
#'
#' Returns a list of ellmer tool definitions for all putior functions that
#' can be exposed via MCP. This function is primarily used internally by
#' \code{\link{putior_mcp_server}}, but can also be used directly for
#' inspection or custom MCP server implementations.
#'
#' The tools confine scans to a folder only in a server started by
#' \code{putior_mcp_server(type = "http")} (see its Security section). In
#' a custom server that other programs can reach, they scan any folder
#' that the R process can read.
#'
#' @param include Character vector of tool names to include. If NULL (default),
#'   all available tools are included.
#' @param exclude Character vector of tool names to exclude. Default excludes
#'   "run_sandbox" since Shiny apps cannot run via MCP.
#'
#' @return A list of ellmer tool definitions suitable for use with
#'   \code{mcptools::mcp_server()}. A tool returns its result as text (JSON,
#'   Mermaid code or Markdown); when R warned, it returns a list of two
#'   \code{ellmer::ContentText} objects instead: the result and the
#'   warnings.
#'
#' @family integration
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
    make_tool_putior_guide(),
    make_tool_putior_help(),
    make_tool_set_putior_log_level(),

    # Utility functions
    make_tool_is_valid_put_annotation(),
    make_tool_split_file_list(),
    make_tool_ext_to_language()
  )

  # Name the tools (using @ for S7 object access)
  names(all_tools) <- vapply(all_tools, function(t) t@name, character(1))

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
# Tool Functions
# =============================================================================
#
# MCP clients need text. mcptools formats a data frame or list that a tool
# returns as deparsed R, one column per line and without names, and ellmer
# 0.5.0 deprecates converting such results itself. Tools must also not print:
# with the stdio transport, stdout is the JSON-RPC channel. The wrappers below
# therefore return JSON or plain text and never write to stdout, the console,
# the clipboard or files, which keeps every tool honestly read-only.

#' Convert a tool result to JSON text, a data frame as one object per row
#' @noRd
mcp_json <- function(x) {
  if (is.data.frame(x)) {
    class(x) <- "data.frame"
  }
  jsonlite::toJSON(x, dataframe = "rows", auto_unbox = TRUE, na = "null", null = "null")
}

#' Run a scan and turn its warnings into an error when it finds nothing
#'
#' A scan of an empty directory, or with a pattern that matches no file,
#' returned \code{[]} with no hint why (#73). This runs the scan with its
#' warnings held back. If the result is empty and R warned (no file
#' matches, a file cannot be read, an annotation is invalid, ...), the
#' warnings become an error, which mcptools sends to the client. Otherwise
#' the warnings are raised again, and mcp_reply() returns them.
#' @param scan A call that returns a data frame or a character vector
#' @return The value of \code{scan}
#' @noRd
mcp_scan <- function(scan) {
  warning_messages <- character()
  result <- withCallingHandlers(scan, warning = function(warning_condition) {
    warning_messages <<- c(warning_messages, conditionMessage(warning_condition))
    invokeRestart("muffleWarning")
  })
  warning_messages <- drop_redundant_warnings(warning_messages)
  is_empty <- if (is.data.frame(result)) nrow(result) == 0 else !any(nzchar(result))
  if (is_empty && length(warning_messages) > 0) {
    stop(paste(c("The scan found nothing.", warning_messages), collapse = "\n"), call. = FALSE)
  }
  for (warning_message in warning_messages) {
    warning(warning_message, call. = FALSE)
  }
  result
}

#' A tool's reply: its result, and the warnings R raised as a second item
#'
#' R warnings never reach an MCP client over stdio (see collect_warnings()),
#' so a tool that can warn returns them as a second text item. The first
#' item is the result as before: for put_diagram exactly the Mermaid code of
#' put_diagram(output = "raw"). Its warnings are Mermaid comment lines, so
#' the diagram still renders when a client joins the two items. Without
#' warnings the reply is the result alone, as before.
#' @param code Code that returns the tool's result as text
#' @param style "text", or "mermaid" for the put_diagram tool
#' @return The result, or a list of two ellmer::ContentText items
#' @noRd
mcp_reply <- function(code, style = "text") {
  root <- .mcp_state$root
  if (is.null(root)) {
    collected <- collect_warnings(code)
  } else {
    # Over HTTP, results and messages show the root as <root>, as the ACP
    # server's do (#111)
    collected <- tryCatch(collect_warnings(code), error = function(error_condition) {
      stop(redact_acp_root(conditionMessage(error_condition), root), call. = FALSE)
    })
    if (is.character(collected$value)) {
      collected$value <- redact_acp_root(collected$value, root)
    }
    collected$warnings <- redact_acp_root(collected$warnings, root)
  }
  if (length(collected$warnings) == 0) {
    return(collected$value)
  }
  list(
    ellmer::ContentText(paste(collected$value, collapse = "\n")),
    ellmer::ContentText(format_warning_block(collected$warnings, style))
  )
}

# For the descriptions of the tools that can warn
.MCP_WARNINGS_NOTE <- paste0(
  " If putior warned, a second text part lists the warnings; ",
  "tell the user about them."
)

#' Check that mcptools enforces the token and trusted hosts (#111)
#'
#' Over HTTP, mcptools checks each request's token and Host, reading the
#' options mcptools.http_shared_secret and mcptools.http_trusted_hosts that
#' putior_mcp_server() sets. These options are not part of mcptools'
#' documented interface: a version that read other ones would serve every
#' request, with no error. So before serving, this sends mcptools' request
#' handler test requests under test settings: it must refuse a request
#' without the token, with a wrong one and with an untrusted Host, and let
#' a valid one through to the method check. An unknown method is used, so
#' no request reaches a tool. If mcptools answers otherwise, or has no such
#' handler, the server does not start.
#' @return NULL, invisibly; an error if mcptools does not enforce the settings
#' @noRd
mcp_check_http_security <- function() {
  request_handler <- tryCatch(
    utils::getFromNamespace("handle_http_request", "mcptools"),
    error = function(error_condition) NULL
  )
  test_secret <- "putior-self-check-secret"
  test_host <- "putior-self-check.invalid"
  old_options <- options(mcptools.http_shared_secret = test_secret,
                         mcptools.http_trusted_hosts = test_host)
  on.exit(options(old_options), add = TRUE)
  status_of <- function(host, secret = NULL) {
    request <- list(REQUEST_METHOD = "PUTIOR-SELF-CHECK", HTTP_HOST = host)
    request$HTTP_PLUMBER_SHARED_SECRET <- secret
    tryCatch(as.integer(request_handler(request)$status)[1],
             error = function(error_condition) NA_integer_)
  }
  refused <- function(status) isTRUE(status %in% c(401L, 403L))
  enforced <- is.function(request_handler) &&
    !is.na(status_of(test_host, test_secret)) &&
    !refused(status_of(test_host, test_secret)) &&
    refused(status_of(test_host)) &&
    refused(status_of(test_host, "wrong-secret")) &&
    refused(status_of("putior-untrusted.invalid", test_secret))
  if (!enforced) {
    stop(
      "putior's MCP server over HTTP needs mcptools to check the token and ",
      "the Host of each request, and mcptools ", utils::packageVersion("mcptools"),
      " did not refuse putior's test requests: it may read other settings ",
      "than mcptools 1.0. The server was not started. Use the stdio ",
      "transport, or a putior version that supports this mcptools.",
      call. = FALSE
    )
  }
  invisible(NULL)
}

#' The Host headers that an MCP server without a token answers (#111)
#'
#' mcptools compares a request's Host header with this list as written:
#' the loopback names, and the address the server listens on, with and
#' without the port.
#' @noRd
mcp_loopback_hosts <- function(host, port) {
  host <- tolower(host)
  if (grepl(":", host, fixed = TRUE)) {
    host <- paste0("[", host, "]")
  }
  host_names <- unique(c("127.0.0.1", "localhost", "[::1]", host))
  c(paste0(host_names, ":", port), host_names)
}

# The folder that an MCP server over HTTP may scan; NULL over stdio, where
# the client is the local program that started the server (#111)
.mcp_state <- new.env(parent = emptyenv())

#' Confine a scan of an MCP server over HTTP to its root folder (#111)
#'
#' Over HTTP, other programs (and, with a token, other machines) can call
#' the tools, so a path must lie in the root folder, as for the ACP server:
#' a relative path is taken from the root, a path outside it is an error,
#' and a recursive scan skips the files that links inside it lead outside
#' to. Over stdio nothing changes.
#' @param path,recursive,exclude The tool's arguments
#' @return A list with the path and exclude to scan with
#' @noRd
mcp_confine_scan <- function(path, recursive, exclude) {
  root <- .mcp_state$root
  if (is.null(root)) {
    return(list(path = path, exclude = exclude))
  }
  confined <- confine_acp_path(sanitize_acp_path(path), root)
  outside_patterns <- acp_outside_excludes(confined, recursive, root)
  if (!is.null(outside_patterns) && !is.null(exclude)) {
    # put() splits a single pattern at its commas only if it is the only one
    if (length(exclude) == 1 && grepl(",", exclude)) {
      exclude <- trimws(strsplit(exclude, ",")[[1]])
    }
  }
  list(path = confined, exclude = c(exclude, outside_patterns))
}

#' Give null arguments their defaults
#'
#' MCP clients may send null for an argument they leave out, and ellmer
#' passes it on as NULL, which most putior arguments reject ("argument is
#' of length zero"). In the calling wrapper, every argument that is NULL
#' but has a non-NULL default gets that default.
#' @param env The wrapper's environment
#' @return NULL, invisibly; called for its effect on env
#' @noRd
use_defaults_for_null <- function(env = parent.frame()) {
  argument_defaults <- formals(sys.function(sys.parent()))
  for (argument_name in names(argument_defaults)) {
    # Arguments without a default (path; not assigned to a variable, which
    # would then count as missing) and those that default to NULL
    if (is.symbol(argument_defaults[[argument_name]]) ||
        is.null(argument_defaults[[argument_name]])) {
      next
    }
    if (is.null(get(argument_name, envir = env))) {
      assign(argument_name, eval(argument_defaults[[argument_name]], env), envir = env)
    }
  }
  invisible(NULL)
}

#' @noRd
mcp_put <- function(path, pattern = NULL, recursive = TRUE,
                    include_line_numbers = FALSE, validate = TRUE,
                    exclude = NULL, log_level = NULL) {
  use_defaults_for_null()
  mcp_reply({
    scan <- mcp_confine_scan(path, recursive, exclude)
    mcp_json(mcp_scan(put(
      scan$path, pattern = pattern, recursive = recursive,
      include_line_numbers = include_line_numbers, validate = validate,
      exclude = scan$exclude, log_level = log_level
    )))
  })
}

#' Scan a path and return the Mermaid code of its diagram
#'
#' \code{source} picks the scan: \code{put()} for annotations,
#' \code{put_auto()} for a workflow detected from the code, or
#' \code{put_merge()} for both (#73).
#' @noRd
mcp_put_diagram <- function(path, source = "annotations",
                            merge_strategy = "manual_priority",
                            pattern = NULL, recursive = TRUE,
                            exclude = NULL, title = NULL, direction = "TD",
                            node_labels = "label", show_files = FALSE,
                            show_artifacts = FALSE,
                            show_workflow_boundaries = TRUE,
                            style_nodes = TRUE, theme = "light",
                            show_source_info = FALSE,
                            source_info_style = "inline",
                            enable_clicks = FALSE, click_protocol = "vscode",
                            artifact_edges = "replace",
                            mermaid_config = "classic",
                            accessibility = TRUE,
                            log_level = NULL) {
  use_defaults_for_null()
  if (length(source) != 1 || !source %in% c("annotations", "auto", "merge")) {
    stop('source must be "annotations", "auto" or "merge", not ',
         deparse(source), call. = FALSE)
  }
  # Click links name the files by their full path on the server (#111)
  if (!is.null(.mcp_state$root) && !isFALSE(enable_clicks)) {
    stop("enable_clicks is not available over HTTP: its links would name ",
         "files by their path on the server.", call. = FALSE)
  }
  mcp_reply(style = "mermaid", {
    scan <- mcp_confine_scan(path, recursive, exclude)
    path <- scan$path
    exclude <- scan$exclude
    # Click links include line numbers when the workflow has them
    include_line_numbers <- isTRUE(enable_clicks)
    workflow <- mcp_scan(switch(source,
      annotations = put(
        path, pattern = pattern, recursive = recursive,
        include_line_numbers = include_line_numbers, exclude = exclude,
        log_level = log_level
      ),
      auto = put_auto(
        path, pattern = pattern, recursive = recursive,
        include_line_numbers = include_line_numbers, exclude = exclude,
        log_level = log_level
      ),
      merge = put_merge(
        path, pattern = pattern, recursive = recursive,
        merge_strategy = merge_strategy,
        include_line_numbers = include_line_numbers, exclude = exclude,
        log_level = log_level
      )
    ))
    # Files were found, but the scan made no nodes and raised no warning:
    # put_diagram() would only say that the workflow is empty
    if (nrow(workflow) == 0) {
      auto_detection_note <- paste0(
        "put_auto() reads only files in languages with auto-detection ",
        "(see list_supported_languages(detection_only = TRUE)); check pattern and exclude."
      )
      stop(switch(source,
        annotations = paste0(
          "No PUT annotations were found in '", path, "'. ",
          "To draw the workflow detected from the code instead, use ",
          "source = \"auto\", or source = \"merge\" to combine both."
        ),
        auto = paste0(
          "put_auto() found no file to analyze in '", path, "'. ", auto_detection_note
        ),
        merge = paste0(
          "No workflow was found in '", path, "': the files hold no PUT ",
          "annotations, and put_auto() found no file to analyze. ", auto_detection_note
        )
      ), call. = FALSE)
    }
    put_diagram(
      workflow, output = "raw", title = title, direction = direction,
      node_labels = node_labels, show_files = show_files,
      show_artifacts = show_artifacts,
      show_workflow_boundaries = show_workflow_boundaries,
      style_nodes = style_nodes, theme = theme,
      show_source_info = show_source_info,
      source_info_style = source_info_style, enable_clicks = enable_clicks,
      click_protocol = click_protocol, artifact_edges = artifact_edges,
      mermaid_config = mermaid_config,
      accessibility = !isFALSE(accessibility), log_level = log_level
    )
  })
}

#' @noRd
mcp_put_auto <- function(path, pattern = NULL, recursive = TRUE,
                         detect_inputs = TRUE, detect_outputs = TRUE,
                         detect_dependencies = TRUE,
                         include_line_numbers = FALSE, exclude = NULL,
                         log_level = NULL) {
  use_defaults_for_null()
  mcp_reply({
    scan <- mcp_confine_scan(path, recursive, exclude)
    mcp_json(mcp_scan(put_auto(
      scan$path, pattern = pattern, recursive = recursive,
      detect_inputs = detect_inputs, detect_outputs = detect_outputs,
      detect_dependencies = detect_dependencies,
      include_line_numbers = include_line_numbers, exclude = scan$exclude,
      log_level = log_level
    )))
  })
}

#' @noRd
mcp_put_generate <- function(path, pattern = NULL, recursive = TRUE,
                             style = "multiline", exclude = NULL,
                             log_level = NULL) {
  use_defaults_for_null()
  mcp_reply({
    scan <- mcp_confine_scan(path, recursive, exclude)
    annotations <- mcp_scan(put_generate(
      scan$path, pattern = pattern, recursive = recursive, output = "raw",
      insert = FALSE, style = style, exclude = scan$exclude, log_level = log_level
    ))
    paste(annotations, collapse = "\n\n")
  })
}

#' @noRd
mcp_put_merge <- function(path, pattern = NULL, recursive = TRUE,
                          merge_strategy = "manual_priority",
                          include_line_numbers = FALSE, exclude = NULL,
                          log_level = NULL) {
  use_defaults_for_null()
  mcp_reply({
    scan <- mcp_confine_scan(path, recursive, exclude)
    mcp_json(mcp_scan(put_merge(
      scan$path, pattern = pattern, recursive = recursive,
      merge_strategy = merge_strategy,
      include_line_numbers = include_line_numbers, exclude = scan$exclude,
      log_level = log_level
    )))
  })
}

#' @noRd
mcp_get_detection_patterns <- function(language, type = NULL) {
  mcp_json(get_detection_patterns(language = language, type = type))
}

#' @noRd
mcp_get_diagram_themes <- function() {
  mcp_json(get_diagram_themes())
}

#' @noRd
mcp_putior_guide <- function(topic = NULL) {
  mcp_reply(putior_guide(topic = topic, output = "raw"))
}

#' putior_help() prints its text; capture it instead
#' @noRd
mcp_putior_help <- function(topic = NULL) {
  paste(utils::capture.output(putior_help(topic)), collapse = "\n")
}

#' set_putior_log_level() returns the previous level; say what changed
#' @noRd
mcp_set_putior_log_level <- function(level = "WARN") {
  use_defaults_for_null()
  previous_level <- set_putior_log_level(level)
  paste0("Log level set to ", toupper(level), " (was ", previous_level, ")")
}

#' @noRd
mcp_list_supported_languages <- function(detection_only = FALSE) {
  use_defaults_for_null()
  list_supported_languages(detection_only = detection_only)
}

#' ext_to_language() returns NULL for unknown extensions, which reaches the
#' client as empty text
#' @noRd
mcp_ext_to_language <- function(ext) {
  language <- ext_to_language(ext)
  if (is.null(language)) {
    return(paste0("No language is registered for the extension '", ext, "'"))
  }
  language
}

# =============================================================================
# Tool Definition Functions
# =============================================================================

#' @noRd
make_tool_put <- function() {
  ellmer::tool(
    fun = mcp_put,
    description = paste0(
      "Scan source files for PUT workflow annotations. ",
      "Extracts structured annotations that define workflow nodes, ",
      "inputs, outputs, and metadata from source code comments. ",
      "Supports 30+ programming languages with automatic comment syntax detection. ",
      "Returns the nodes as JSON, one object per node, or [] when the scanned ",
      "files hold no annotations. When the scan finds nothing and R warned ",
      "(for example, no file matches the pattern), the call fails with the warnings. ",
      "To draw them, call put_diagram with the same path.",
      .MCP_WARNINGS_NOTE
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
        description = "File pattern regex (default: all supported extensions)",
        required = FALSE
      ),
      recursive = ellmer::type_boolean(
        description = "Search subdirectories recursively (default: TRUE)",
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
      exclude = ellmer::type_string(
        description = "Comma-separated regex patterns to exclude files (default: none)",
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
    fun = mcp_put_diagram,
    description = paste0(
      "Scan source files and return the Mermaid flowchart code of the workflow. ",
      "With source = annotations (the default) the workflow comes from PUT annotations, ",
      "with auto it is detected from the code (as by put_auto), and with merge ",
      "both are combined (as by put_merge). Shows data flows and processing steps. ",
      "Supports multiple themes, node styling, and interactive features. ",
      "If putior warned, a second text part lists the warnings as Mermaid comment ",
      "lines: the first part is the complete diagram; tell the user about the warnings."
    ),
    name = "put_diagram",
    annotations = list(
      title = "Generate Workflow Diagram",
      readOnlyHint = TRUE
    ),
    arguments = list(
      path = ellmer::type_string(
        description = "Path to directory or file to scan"
      ),
      source = ellmer::type_enum(
        description = paste0(
          "Where the workflow comes from: annotations (PUT annotations), ",
          "auto (detected from the code), or merge (both) (default: annotations)"
        ),
        values = c("annotations", "auto", "merge"),
        required = FALSE
      ),
      merge_strategy = ellmer::type_enum(
        description = paste0(
          "With source = merge: manual_priority, supplement, or union ",
          "(default: manual_priority)"
        ),
        values = c("manual_priority", "supplement", "union"),
        required = FALSE
      ),
      pattern = ellmer::type_string(
        description = paste0(
          "File pattern regex (default: all supported extensions; with auto ",
          "or merge, the languages with auto-detection)"
        ),
        required = FALSE
      ),
      recursive = ellmer::type_boolean(
        description = "Search subdirectories recursively (default: TRUE)",
        required = FALSE
      ),
      exclude = ellmer::type_string(
        description = "Comma-separated regex patterns to exclude files (default: none)",
        required = FALSE
      ),
      title = ellmer::type_string(
        description = paste0(
          "Optional title for the diagram. Leave out \"<\": Mermaid garbles ",
          "the drawn title when it contains one"
        ),
        required = FALSE
      ),
      direction = ellmer::type_enum(
        description = "Diagram direction: TD (or its synonym TB), LR, BT, or RL (default: TD)",
        values = c("TD", "TB", "LR", "BT", "RL"),
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
        description = "Color theme: light, dark, auto, minimal, github, viridis, magma, plasma, cividis (default: light)",
        values = .VALID_THEMES,
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
        description = "Make nodes clickable (default: FALSE; not over HTTP)",
        required = FALSE
      ),
      click_protocol = ellmer::type_enum(
        description = "URL protocol for clickable nodes: vscode or file (default: vscode)",
        values = .VALID_CLICK_PROTOCOLS,
        required = FALSE
      ),
      artifact_edges = ellmer::type_enum(
        description = paste0(
          "With show_artifacts: replace draws scripts connected only through the ",
          "data file's node, both also draws the direct edge (default: replace)"
        ),
        values = c("replace", "both"),
        required = FALSE
      ),
      mermaid_config = ellmer::type_enum(
        description = paste0(
          "Mermaid configuration in the diagram's frontmatter: classic keeps ",
          "Mermaid 11's look on Mermaid 12 renderers such as GitHub, none writes ",
          "no configuration (default: classic)"
        ),
        values = c("classic", "none"),
        required = FALSE
      ),
      accessibility = ellmer::type_boolean(
        description = paste0(
          "Add accTitle (from the title) and accDescr (a summary) for screen ",
          "readers (default: TRUE)"
        ),
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
    fun = mcp_put_auto,
    description = paste0(
      "Auto-detect workflow elements from code analysis without requiring explicit annotations. ",
      "Analyzes source files to detect file inputs, outputs, and dependencies ",
      "based on function calls like read_csv(), write.csv(), etc. ",
      "Similar to how roxygen2 auto-generates documentation skeletons. ",
      "Returns the detected nodes as JSON, one object per node. ",
      "When the scan finds nothing and R warned (for example, no file matches ",
      "the pattern), the call fails with the warnings.",
      .MCP_WARNINGS_NOTE
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
        description = "File pattern regex (default: all supported extensions)",
        required = FALSE
      ),
      recursive = ellmer::type_boolean(
        description = "Search subdirectories recursively (default: TRUE)",
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
      exclude = ellmer::type_string(
        description = "Comma-separated regex patterns to exclude files (default: none)",
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
    fun = mcp_put_generate,
    description = paste0(
      "Generate suggested PUT annotation comments based on code analysis. ",
      "Analyzes source files and returns annotation text that can be copied ",
      "into source files; the files themselves are not changed. ",
      "When the scan finds nothing and R warned (for example, no file matches ",
      "the pattern), the call fails with the warnings. ",
      "Similar to how roxygen2 generates documentation skeletons. ",
      "Supports single-line and multiline annotation styles.",
      .MCP_WARNINGS_NOTE
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
        description = "File pattern regex (default: all supported extensions)",
        required = FALSE
      ),
      recursive = ellmer::type_boolean(
        description = "Search subdirectories recursively (default: TRUE)",
        required = FALSE
      ),
      style = ellmer::type_enum(
        description = "Annotation style: single or multiline (default: multiline)",
        values = c("single", "multiline"),
        required = FALSE
      ),
      exclude = ellmer::type_string(
        description = "Comma-separated regex patterns to exclude files (default: none)",
        required = FALSE
      ),
      log_level = ellmer::type_enum(
        description = "Log verbosity: DEBUG, INFO, WARN, or ERROR (default: global setting)",
        values = c("DEBUG", "INFO", "WARN", "ERROR"),
        required = FALSE
      )
    )
  )
}

#' @noRd
make_tool_put_merge <- function() {
  ellmer::tool(
    fun = mcp_put_merge,
    description = paste0(
      "Combine manually written PUT annotations with auto-detected workflow elements. ",
      "Supports flexible strategies: manual_priority (manual overrides auto), ",
      "supplement (auto fills in missing fields), union (combine all detected I/O). ",
      "Returns the merged nodes as JSON, one object per node. ",
      "When the scan finds nothing and R warned (for example, no file matches ",
      "the pattern), the call fails with the warnings.",
      .MCP_WARNINGS_NOTE
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
        description = "File pattern regex (default: all supported extensions)",
        required = FALSE
      ),
      recursive = ellmer::type_boolean(
        description = "Search subdirectories recursively (default: TRUE)",
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
      ),
      exclude = ellmer::type_string(
        description = "Comma-separated regex patterns to exclude files (default: none)",
        required = FALSE
      ),
      log_level = ellmer::type_enum(
        description = "Log verbosity: DEBUG, INFO, WARN, or ERROR (default: global setting)",
        values = c("DEBUG", "INFO", "WARN", "ERROR"),
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
    fun = mcp_list_supported_languages,
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
    fun = mcp_get_detection_patterns,
    description = paste0(
      "Get auto-detection patterns for a programming language. ",
      "Returns the patterns used to detect file inputs, outputs, and dependencies, as JSON. ",
      "Supports 18 languages including R, Python, JavaScript, Go, Rust, WGSL, Dockerfile, Makefile, etc."
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
        description = "Pattern type: input, output, or dependency. Omit to get all types.",
        values = c("input", "output", "dependency"),
        required = FALSE
      )
    )
  )
}

#' @noRd
make_tool_get_diagram_themes <- function() {
  ellmer::tool(
    fun = mcp_get_diagram_themes,
    description = paste0(
      "Get information about available color themes for workflow diagrams. ",
      "Returns a JSON object describing 9 themes: light, dark, auto, minimal, github, ",
      "and 4 colorblind-safe viridis family themes (viridis, magma, plasma, cividis)."
    ),
    name = "get_diagram_themes",
    annotations = list(
      title = "List Diagram Themes",
      readOnlyHint = TRUE
    )
  )
}

#' @noRd
make_tool_putior_guide <- function() {
  ellmer::tool(
    fun = mcp_putior_guide,
    description = paste0(
      "Access putior guide documentation for AI assistants. ",
      "Provides structured information about annotation syntax, supported languages, ",
      "core functions, detection patterns, and usage examples, as markdown.",
      .MCP_WARNINGS_NOTE
    ),
    name = "putior_guide",
    annotations = list(
      title = "AI Assistant Guide Reference",
      readOnlyHint = TRUE
    ),
    arguments = list(
      topic = ellmer::type_enum(
        description = "Topic section: quick-start, syntax, languages, functions, patterns, or examples",
        values = c("quick-start", "syntax", "languages", "functions", "patterns", "examples"),
        required = FALSE
      )
    )
  )
}

#' @noRd
make_tool_putior_help <- function() {
  ellmer::tool(
    fun = mcp_putior_help,
    description = paste0(
      "Get quick-reference help for putior tasks and syntax. ",
      "Topics include: annotation (syntax), themes, languages, node_types, patterns, examples, guide."
    ),
    name = "putior_help",
    annotations = list(
      title = "Quick Reference Help",
      readOnlyHint = TRUE
    ),
    arguments = list(
      topic = ellmer::type_enum(
        description = "Help topic to display",
        values = c("annotation", "themes", "languages", "node_types", "patterns", "examples", "guide"),
        required = FALSE
      )
    )
  )
}

#' @noRd
make_tool_set_putior_log_level <- function() {
  ellmer::tool(
    fun = mcp_set_putior_log_level,
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
    fun = mcp_ext_to_language,
    description = paste0(
      "Convert a file extension to a standardized language name. ",
      "Used for detection pattern lookup. For an unsupported extension, says so."
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
