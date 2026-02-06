#' ACP Server Integration for putior
#'
#' Functions for exposing putior functionality as an ACP (Agent Communication
#' Protocol) agent, enabling other AI agents to discover and call putior
#' capabilities via REST API.
#'
#' @name putior_acp
#' @keywords internal
NULL

# =============================================================================
# Run Storage (in-memory for simplicity)
# =============================================================================

# Environment to store run results
.acp_runs <- new.env(parent = emptyenv())

#' Generate a unique run ID
#' @noRd
generate_run_id <- function() {
  if (requireNamespace("uuid", quietly = TRUE)) {
    uuid::UUIDgenerate()
  } else {
    # Fallback to timestamp-based ID
    paste0("run_", format(Sys.time(), "%Y%m%d%H%M%S"), "_", sample(1000:9999, 1))
  }
}

#' Store a run result
#' @noRd
store_run <- function(run_id, run_data) {
  assign(run_id, run_data, envir = .acp_runs)
}

#' Retrieve a run by ID
#' @noRd
get_run_by_id <- function(run_id) {
  if (exists(run_id, envir = .acp_runs)) {
    get(run_id, envir = .acp_runs)
  } else {
    NULL
  }
}

# =============================================================================
# Agent Manifest
# =============================================================================

#' Get putior ACP Agent Manifest
#'
#' Returns the agent definition for ACP discovery. This manifest describes
#' putior's capabilities to other AI agents.
#'
#' @return A list containing the agent manifest with name, description,
#'   and metadata about capabilities.
#'
#' @export
#'
#' @examples
#' # Get the agent manifest
#' manifest <- putior_acp_manifest()
#' print(manifest$name)
#' print(manifest$description)
putior_acp_manifest <- function() {
  list(
    name = "putior",
    description = paste0(
      "Workflow annotation and diagram generation agent. ",
      "Extracts PUT annotations from 30+ programming languages and ",
      "generates Mermaid flowchart diagrams for visualization."
    ),
    metadata = list(
      version = as.character(utils::packageVersion("putior")),
      capabilities = c("scan", "diagram", "auto-detect", "generate", "merge", "help"),
      supported_languages = list_supported_languages(),
      operations = list(
        scan = "Scan files for PUT workflow annotations",
        diagram = "Generate Mermaid flowchart from workflow data",
        auto = "Auto-detect workflow from code analysis",
        generate = "Generate annotation suggestions for files",
        merge = "Merge manual and auto-detected annotations",
        help = "Get help on putior usage",
        skills = "Get AI assistant skills documentation"
      )
    )
  )
}

# =============================================================================
# ACP Message Parsing
# =============================================================================

#' Extract text content from ACP message input
#' @noRd
extract_text_content <- function(input) {
  if (is.null(input) || length(input) == 0) {
    return("")
  }

  # ACP messages have structure: input: [{role, parts: [{content, content_type}]}]
  content_parts <- character(0)

  for (msg in input) {
    if (!is.null(msg$parts)) {
      for (part in msg$parts) {
        if (!is.null(part$content)) {
          content_parts <- c(content_parts, part$content)
        }
      }
    }
  }

  paste(content_parts, collapse = " ")
}

#' Detect operation from message content
#' @noRd
detect_operation <- function(content) {
  content_lower <- tolower(content)

  # Check for specific operation keywords
  if (grepl("\\b(diagram|visuali[sz]e|flowchart|mermaid)\\b", content_lower)) {
    return("diagram")
  }
  if (grepl("\\b(auto[- ]?detect|put_auto)\\b", content_lower)) {
    return("auto")
  }
  if (grepl("\\b(generate|suggest|annotation suggestion)\\b", content_lower)) {
    return("generate")
  }
  if (grepl("\\b(merge|combine)\\b", content_lower)) {
    return("merge")
  }
  if (grepl("\\b(scan|extract|put annotation|find annotation)\\b", content_lower)) {
    return("scan")
  }
  if (grepl("\\b(help|usage|how to)\\b", content_lower)) {
    return("help")
  }
  if (grepl("\\b(skills|capabilities|what can)\\b", content_lower)) {
    return("skills")
  }


  # Default to scan
  "scan"
}

#' Extract parameters from message content
#' @noRd
extract_parameters <- function(content) {
  params <- list()

  # Extract path (look for quoted paths or common patterns)
  path_match <- regmatches(
    content,
    regexpr('["\']([^"\']+)["\']|(?:^|\\s)(\\.?/[^\\s]+)', content, perl = TRUE)
  )
  if (length(path_match) > 0 && nchar(path_match[1]) > 0) {
    # Clean up the path
    path <- gsub('^["\']|["\']$', '', path_match[1])
    params$path <- path
  }

  # Extract topic for help
  if (grepl("\\bhelp\\b", tolower(content))) {
    topic_patterns <- c(
      "annotation", "themes?", "languages?", "node.?types?",
      "patterns?", "examples?", "skills?"
    )
    for (pattern in topic_patterns) {
      if (grepl(pattern, tolower(content))) {
        params$topic <- gsub("s$", "", regmatches(
          tolower(content),
          regexpr(pattern, tolower(content))
        ))
        break
      }
    }
  }

  # Extract theme if mentioned
  theme_match <- regmatches(
    tolower(content),
    regexpr("theme[=: ]*['\"]?(light|dark|auto|minimal|github|viridis|magma|plasma|cividis)['\"]?", tolower(content))
  )
  if (length(theme_match) > 0 && nchar(theme_match[1]) > 0) {
    params$theme <- gsub(".*[=: ]+['\"]?([a-z]+)['\"]?$", "\\1", theme_match[1])
  }

  # Extract direction if mentioned (case insensitive)
  dir_match <- regmatches(
    content,
    regexpr("[Dd][Ii][Rr][Ee][Cc][Tt][Ii][Oo][Nn][=: ]*(TD|LR|BT|RL|td|lr|bt|rl)", content)
  )
  if (length(dir_match) > 0 && nchar(dir_match[1]) > 0) {
    # Extract just the direction value (TD, LR, BT, RL)
    params$direction <- toupper(gsub(".*[=: ]+", "", dir_match[1]))
  }

  # Check for flags
  if (grepl("\\b(recursive|recursively)\\b", tolower(content))) {
    params$recursive <- TRUE
  }
  if (grepl("\\bartifacts?\\b", tolower(content))) {
    params$show_artifacts <- TRUE
  }

  params
}

#' Parse ACP message into operation and parameters
#' @noRd
parse_acp_message <- function(input) {
  content <- extract_text_content(input)
  operation <- detect_operation(content)
  params <- extract_parameters(content)

  list(operation = operation, params = params, raw_content = content)
}

# =============================================================================
# Input Sanitization
# =============================================================================

#' Sanitize a file path from ACP network requests
#'
#' Validates and normalizes file paths to prevent directory traversal attacks
#' and other path injection issues. Rejects paths with control characters
#' or directory traversal components ("..").
#'
#' @param path Character string of the file path to sanitize
#' @return Sanitized path string, or "." if the path is invalid
#' @noRd
sanitize_acp_path <- function(path) {
  if (is.null(path) || !is.character(path) || length(path) != 1 || nchar(path) == 0) {
    return(".")
  }

  # Reject paths with control characters (including null bytes)
  if (grepl("[[:cntrl:]]", path)) {
    warning("ACP path rejected: contains control characters", call. = FALSE)
    return(".")
  }

  # Normalize path separators for traversal check
  normalized <- gsub("\\\\", "/", path)

  # Reject directory traversal attempts
  if (grepl("(^|/)\\.\\.(/|$)", normalized)) {
    warning("ACP path rejected: directory traversal not allowed: ", path, call. = FALSE)
    return(".")
  }

  path
}

# =============================================================================
# Request Execution
# =============================================================================

#' Execute an ACP request
#'
#' Routes the parsed ACP message to the appropriate putior function and
#' returns the result.
#'
#' @param input The input message array from ACP request
#' @param session_id Optional session ID for stateful operations
#'
#' @return The result from the putior operation
#'
#' @noRd
execute_acp_request <- function(input, session_id = NULL) {
  parsed <- parse_acp_message(input)

  # Sanitize path from network input
  if (!is.null(parsed$params$path)) {
    parsed$params$path <- sanitize_acp_path(parsed$params$path)
  }

  result <- tryCatch({
    switch(parsed$operation,
      "scan" = {
        path <- parsed$params$path
        if (is.null(path)) path <- "."
        put(
          path = path,
          recursive = isTRUE(parsed$params$recursive)
        )
      },
      "diagram" = {
        # For diagram, we need workflow data
        # If path provided, scan first
        path <- parsed$params$path
        if (!is.null(path)) {
          workflow <- put(path, recursive = isTRUE(parsed$params$recursive))
        } else {
          # Return instructions
          return(paste0(
            "To generate a diagram, please provide a path to scan.\n",
            "Example: 'Generate a diagram for ./R/'\n\n",
            "Or first scan files with: 'Scan ./R/ for annotations'\n",
            "Then: 'Create diagram from the scan results'"
          ))
        }
        put_diagram(
          workflow,
          output = "raw",
          theme = parsed$params$theme %||% "light",
          direction = parsed$params$direction %||% "TD",
          show_artifacts = isTRUE(parsed$params$show_artifacts)
        )
      },
      "auto" = {
        path <- parsed$params$path
        if (is.null(path)) path <- "."
        put_auto(
          path = path,
          recursive = isTRUE(parsed$params$recursive)
        )
      },
      "generate" = {
        path <- parsed$params$path
        if (is.null(path)) path <- "."
        annotations <- put_generate(
          path = path,
          output = "raw",
          recursive = isTRUE(parsed$params$recursive)
        )
        paste(annotations, collapse = "\n")
      },
      "merge" = {
        path <- parsed$params$path
        if (is.null(path)) path <- "."
        put_merge(
          path = path,
          recursive = isTRUE(parsed$params$recursive)
        )
      },
      "help" = {
        # Capture help output
        help_output <- utils::capture.output(
          putior_help(parsed$params$topic)
        )
        paste(help_output, collapse = "\n")
      },
      "skills" = {
        putior_skills(output = "raw")
      },
      # Default
      {
        paste0(
          "Unknown operation. Available operations:\n",
          "- scan: Scan files for PUT annotations\n",
          "- diagram: Generate Mermaid flowchart\n",
          "- auto: Auto-detect workflow from code\n",
          "- generate: Generate annotation suggestions\n",
          "- merge: Merge manual and auto annotations\n",
          "- help: Get help on putior usage\n",
          "- skills: Get AI assistant documentation"
        )
      }
    )
  }, error = function(e) {
    paste0("Error: ", conditionMessage(e))
  })

  result
}

# =============================================================================
# Output Formatting
# =============================================================================

#' Format result as text for ACP output
#' @noRd
format_result_as_text <- function(result) {

  if (is.data.frame(result)) {
    # Format data frame as readable text
    if (nrow(result) == 0) {
      return("No annotations found.")
    }

    lines <- character(0)
    lines <- c(lines, paste0("Found ", nrow(result), " workflow node(s):"))
    lines <- c(lines, "")

    for (i in seq_len(nrow(result))) {
      row <- result[i, ]
      lines <- c(lines, paste0("Node ", i, ": ", row$id))
      if (!is.na(row$label) && nchar(row$label) > 0) {
        lines <- c(lines, paste0("  Label: ", row$label))
      }
      if ("source_file" %in% names(row) && !is.na(row$source_file)) {
        lines <- c(lines, paste0("  Source: ", row$source_file))
      }
      if (!is.na(row$input) && nchar(row$input) > 0) {
        lines <- c(lines, paste0("  Input: ", row$input))
      }
      if (!is.na(row$output) && nchar(row$output) > 0) {
        lines <- c(lines, paste0("  Output: ", row$output))
      }
      lines <- c(lines, "")
    }

    return(paste(lines, collapse = "\n"))
  }

  if (is.character(result)) {
    return(paste(result, collapse = "\n"))
  }

  if (is.list(result)) {
    return(paste(utils::capture.output(print(result)), collapse = "\n"))
  }

  as.character(result)
}

#' Format putior result for ACP output message
#' @noRd
format_acp_output <- function(result) {
  list(
    list(
      role = "assistant",
      parts = list(
        list(
          content = format_result_as_text(result),
          content_type = "text/plain"
        )
      )
    )
  )
}

# =============================================================================
# ACP Endpoint Handlers
# =============================================================================

#' Handler for GET /agents endpoint
#' @noRd
acp_list_agents_handler <- function() {
  list(agents = list(putior_acp_manifest()))
}

#' Handler for POST /runs endpoint
#' @noRd
acp_create_run_handler <- function(body) {
  run_id <- generate_run_id()

  # Extract input and session_id from body
  input <- body$input
  session_id <- body$session_id

  # Execute the request
  result <- execute_acp_request(input, session_id)

  # Create run record
  run_data <- list(
    run_id = run_id,
    agent_name = "putior",
    session_id = session_id,
    status = "completed",
    output = format_acp_output(result),
    created_at = Sys.time()
  )

  # Store for later retrieval

store_run(run_id, run_data)

  run_data
}

#' Handler for GET /runs/:run_id endpoint
#' @noRd
acp_get_run_handler <- function(run_id, response) {
  run <- get_run_by_id(run_id)

  if (is.null(run)) {
    response$status <- 404L
    return(list(error = "Run not found", run_id = run_id))
  }

  run
}

# =============================================================================
# Server Function
# =============================================================================

#' Start putior ACP Server
#'
#' Starts an ACP (Agent Communication Protocol) REST server that exposes
#' putior as an agent that other AI agents can discover and call.
#'
#' @param host Character string specifying the host address.
#'   Default: "127.0.0.1" (localhost only)
#' @param port Integer specifying the port number.
#'   Default: 8080
#'
#' @details
#' The ACP server exposes the following endpoints:
#' \describe{
#'   \item{GET /agents}{Returns the agent manifest for discovery}
#'   \item{POST /runs}{Execute a putior operation}
#'   \item{GET /runs/:run_id}{Get the status/result of a previous run}
#' }
#'
#' @section Message Format:
#' POST /runs expects a JSON body with this structure:
#' \preformatted{
#' {
#'   "input": [
#'     {
#'       "role": "user",
#'       "parts": [
#'         {
#'           "content": "scan ./R/ for workflow annotations",
#'           "content_type": "text/plain"
#'         }
#'       ]
#'     }
#'   ],
#'   "session_id": "optional-session-id"
#' }
#' }
#'
#' @section Supported Operations:
#' The agent understands natural language requests for:
#' \itemize{
#'   \item \strong{scan}: "Scan ./R/ for PUT annotations"
#'   \item \strong{diagram}: "Generate a diagram for ./R/"
#'   \item \strong{auto}: "Auto-detect workflow from ./src/"
#'   \item \strong{generate}: "Generate annotation suggestions for ./R/"
#'   \item \strong{merge}: "Merge manual and auto annotations in ./R/"
#'   \item \strong{help}: "Help with annotation syntax"
#'   \item \strong{skills}: "What are your capabilities?"
#' }
#'
#' @section Testing:
#' Test the server with curl:
#' \preformatted{
#' # Discover agents
#' curl http://localhost:8080/agents
#'
#' # Execute a scan
#' curl -X POST http://localhost:8080/runs \\
#'   -H "Content-Type: application/json" \\
#'   -d '{"input": [{"role": "user", "parts": [{"content": "scan ./R/"}]}]}'
#' }
#'
#' @return This function does not return; it runs the server until terminated.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Start ACP server on default port
#' putior_acp_server()
#'
#' # Start on custom host/port
#' putior_acp_server(host = "0.0.0.0", port = 9000)
#' }
#'
#' @seealso
#' \code{\link{putior_acp_manifest}} for the agent definition,
#' \code{\link{putior_mcp_server}} for MCP (Model-to-tool) integration
putior_acp_server <- function(host = "127.0.0.1", port = 8080L) {
  # Check for plumber2 dependency
  if (!requireNamespace("plumber2", quietly = TRUE)) {
    stop(
      "The 'plumber2' package is required for ACP server functionality.\n",
      "Install it with: install.packages('plumber2')\n",
      "Or: pak::pak('plumber2')",
      call. = FALSE
    )
  }

  # Get JSON serializer
  json_serializer <- plumber2::get_serializers("json")

  # Create plumber2 API with ACP endpoints
  pa <- plumber2::api() |>
    plumber2::api_get("/agents", acp_list_agents_handler,
                      serializer = json_serializer) |>
    plumber2::api_post("/runs", acp_create_run_handler,
                       serializer = json_serializer) |>
    plumber2::api_get("/runs/:run_id", acp_get_run_handler,
                      serializer = json_serializer)

  message("Starting putior ACP server...")
  message("  Host: ", host)
  message("  Port: ", port)
  message("")
  message("Endpoints:")
  message("  GET  /agents       - Discover this agent")
  message("  POST /runs         - Execute an operation")
  message("  GET  /runs/:run_id - Get run status/results")
  message("")
  message("Press Ctrl+C to stop the server.")

  # Run the server
  plumber2::api_run(pa, host = host, port = as.integer(port))
}

