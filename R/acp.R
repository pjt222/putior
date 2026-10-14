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

# Maximum number of runs to retain (prevents unbounded memory growth)
.ACP_MAX_RUNS <- 1000L

# A request is searched for its path in this many characters (#109)
.ACP_MAX_PATH_SEARCH <- 10000L

# The largest request body the server reads, in bytes (#111)
.ACP_MAX_REQUEST_BYTES <- 1e6

# A scan with more links out of the root than this is refused: each needs
# its own exclude pattern, and put() matches every pattern against every
# file (#111)
.ACP_MAX_OUTSIDE_LINKS <- 200L

# Counter for run IDs made without openssl or uuid
.acp_run_counter <- new.env(parent = emptyenv())

# The server's settings: the folder it scans (root) and its token (#111)
.acp_state <- new.env(parent = emptyenv())

#' Generate a unique run ID
#'
#' A run's result can be read by anyone who knows its ID (GET
#' /runs/<run_id>), so IDs must not be guessable (#111). openssl, which
#' plumber2 and so the server always has, gives 128 random bits without
#' touching the session's random-number stream (#67).
#' @noRd
generate_run_id <- function() {
  if (requireNamespace("openssl", quietly = TRUE)) {
    paste0("run_", paste(openssl::rand_bytes(16), collapse = ""))
  } else if (requireNamespace("uuid", quietly = TRUE)) {
    uuid::UUIDgenerate()
  } else {
    fallback_run_id()
  }
}

#' Run ID for when neither openssl nor uuid is installed
#'
#' A timestamp plus a counter that only increases, so IDs made in the same
#' second still differ, and the session's random-number stream is left alone.
#' Such IDs are guessable; the server itself always has openssl.
#' @noRd
fallback_run_id <- function() {
  .acp_run_counter$value <- (.acp_run_counter$value %||% 0L) + 1L
  paste0("run_", format(Sys.time(), "%Y%m%d%H%M%S"), "_", .acp_run_counter$value)
}

#' Store a run result, evicting oldest entries when at capacity
#' @noRd
store_run <- function(run_id, run_data) {
  run_data$stored_at <- Sys.time()
  assign(run_id, run_data, envir = .acp_runs)

  # Evict oldest runs when over capacity
  run_ids <- ls(envir = .acp_runs)
  if (length(run_ids) > .ACP_MAX_RUNS) {
    timestamps <- vapply(run_ids, function(id) {
      run <- get(id, envir = .acp_runs)
      as.numeric(run$stored_at %||% 0)
    }, numeric(1))
    n_to_evict <- length(run_ids) - .ACP_MAX_RUNS
    oldest_ids <- run_ids[order(timestamps)][seq_len(n_to_evict)]
    rm(list = oldest_ids, envir = .acp_runs)
  }
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
#' @family integration
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
        guide = "Get AI assistant guide documentation"
      )
    )
  )
}

# =============================================================================
# ACP Message Parsing
# =============================================================================

#' ACP records as a list of lists (#113)
#'
#' plumber2's JSON parser simplifies a request body: an array of objects
#' arrives as a data frame, whose list columns hold further data frames.
#' Every POST /runs then failed ("$ operator is invalid for atomic
#' vectors"). This turns such a data frame into a list of records, so that
#' the code sees the plain JSON shape either way.
#' @param records A data frame or a list of records
#' @return A list of records
#' @noRd
acp_records <- function(records) {
  if (!is.data.frame(records)) {
    return(records)
  }
  lapply(seq_len(nrow(records)), function(row_index) {
    lapply(records, function(column) column[[row_index]])
  })
}

#' Extract text content from ACP message input
#' @noRd
extract_text_content <- function(input) {
  if (is.null(input) || length(input) == 0) {
    return("")
  }

  # ACP messages have structure: input: [{role, parts: [{content, content_type}]}]
  content_parts <- character(0)

  for (msg in acp_records(input)) {
    if (!is.null(msg$parts)) {
      for (part in acp_records(msg$parts)) {
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
  if (grepl("\\b(guide|skills|capabilities|what can)\\b", content_lower)) {
    return("guide")
  }


  # Default to scan
  "scan"
}

#' Find the path in an ACP request (#109)
#'
#' Candidates, best first:
#' \enumerate{
#'   \item a quoted value that starts like a path: "/", "./", "../", "~/"
#'     or a Windows drive ("D:/", "C:\\"), with either slash;
#'   \item an unquoted word that starts like a path;
#'   \item an unquoted word with a slash that exists ("R/", "src/x.R"; not
#'     "and/or");
#'   \item a quoted value that exists ("'src'", "'R/x.R'");
#'   \item any other quoted value, so that a missing folder gives an error,
#'     except a theme or direction name ("theme 'dark'").
#' }
#' An unquoted root alone ("/", "\\", "~", "D:/", also with "/." after it)
#' is not a path: in prose ("R / Python files", "R \\ Python") it would
#' make the server scan a whole drive or home directory. "." alone is not
#' one either. Quotes may be straight, curly or backticks; an apostrophe
#' inside a word ("Let's") is not one. A plain word ("src") is not a path.
#' "../" paths are found so that sanitize_acp_path() rejects them. Each
#' candidate is looked for only if the ones before it found nothing; only
#' words with a slash and quoted values are looked up on disk, and only the
#' first .ACP_MAX_PATH_SEARCH characters are read.
#' @param content The request text
#' @return The path, or NULL
#' @noRd
extract_path <- function(content) {
  # A request names its path early; this bounds the work for a huge one.
  # The cut drops a word it splits, which could name a parent folder.
  if (nchar(content) > .ACP_MAX_PATH_SEARCH) {
    content <- sub("\\S*$", "", substr(content, 1L, .ACP_MAX_PATH_SEARCH + 1L))
  }
  content <- gsub("[\u2018\u2019]", "'", content)
  content <- gsub("[\u201c\u201d]", '"', content)
  starts_like_path <- function(x) {
    grepl("^(/|\\.{1,2}[/\\\\]|~[/\\\\]|[A-Za-z]:[/\\\\])", x) & !is_bare_root(x)
  }
  is_bare_root <- function(x) {
    grepl("^(/+(\\./*)*|~(/+(\\./*)*)?|[A-Za-z]:(/+(\\./*)*)?)$", gsub("\\\\", "/", x))
  }
  # Relative to the server's root, as the scan resolves them (#111); never
  # for network or device paths, which would contact another host
  root <- acp_root()
  path_exists <- function(x) {
    is_network <- grepl("^[/\\\\]{2}", x)
    is_absolute <- grepl("^([A-Za-z]:)?[/\\\\]", x) | startsWith(x, "~")
    full_paths <- x
    full_paths[!is_absolute] <- file.path(root, x[!is_absolute])
    exists_now <- logical(length(x))
    exists_now[!is_network] <- suppressWarnings(file.exists(full_paths[!is_network]))
    exists_now
  }
  parameter_values <- tolower(c(.VALID_THEMES, "td", "tb", "lr", "bt", "rl"))

  # (*UCP): an apostrophe after a non-ASCII letter is no quote either
  quoted_values <- regmatches(content, gregexpr(
    "(*UCP)(?<!\\w)(['\"`])((?:(?!\\1).)+)\\1", content, perl = TRUE
  ))[[1]]
  quoted_values <- substr(quoted_values, 2L, nchar(quoted_values) - 1L)
  quoted_path <- quoted_values[grepl("^(/|\\.{1,2}[/\\\\]|~[/\\\\]|[A-Za-z]:[/\\\\])", quoted_values)]
  if (length(quoted_path) > 0) return(quoted_path[1])

  words <- strip_word_punctuation(strsplit(trimws(content), "\\s+")[[1]])
  words <- words[nzchar(words)]
  path_words <- words[starts_like_path(words)]
  if (length(path_words) > 0) return(path_words[1])
  slash_words <- words[grepl("[/\\\\]", words) & !is_bare_root(words)]
  slash_words <- unique(slash_words)
  slash_words <- slash_words[path_exists(slash_words)]
  if (length(slash_words) > 0) return(slash_words[1])

  quoted_values <- unique(quoted_values[!tolower(quoted_values) %in% parameter_values])
  existing_values <- quoted_values[path_exists(quoted_values)]
  if (length(existing_values) > 0) return(existing_values[1])
  if (length(quoted_values) > 0) return(quoted_values[1])
  NULL
}

#' Drop the punctuation around the words of an ACP request
#'
#' Brackets before a word; after it, "?", "!", ",", ";", ":", a closing
#' bracket without its opening one ("./R/(old)" keeps it) and one
#' sentence-final period ("scan ./R.", "(./R/)."), in any order. A period
#' after "." or "/" stays ("./R/.", ".."). The trailing run is walked once,
#' so a word ending in many brackets costs no more than its length.
#' @param words Character vector of words
#' @return The words without that punctuation
#' @noRd
strip_word_punctuation <- function(words) {
  words <- sub("^[[({]+", "", words)
  closing_of <- c(")" = "(", "]" = "[", "}" = "{")
  for (index in which(grepl("[])}?!,;:.]$", words))) {
    word_chars <- strsplit(words[index], "", fixed = TRUE)[[1]]
    surplus <- vapply(names(closing_of), function(closing) {
      sum(word_chars == closing) - sum(word_chars == closing_of[[closing]])
    }, numeric(1))
    keep <- length(word_chars)
    period_dropped <- FALSE
    while (keep > 0) {
      last_char <- word_chars[keep]
      if (last_char %in% c("?", "!", ",", ";", ":")) {
        keep <- keep - 1L
      } else if (last_char %in% names(closing_of) && surplus[[last_char]] > 0) {
        surplus[[last_char]] <- surplus[[last_char]] - 1
        keep <- keep - 1L
      } else if (last_char == "." && !period_dropped && keep > 1 &&
                 !word_chars[keep - 1L] %in% c(".", "/")) {
        period_dropped <- TRUE
        keep <- keep - 1L
      } else {
        break
      }
    }
    words[index] <- paste(word_chars[seq_len(keep)], collapse = "")
  }
  words
}

#' The path a scan uses: the request's, or the root folder with a note
#'
#' Without a path in the request, a scan reads the server's root folder
#' (#109, #111). That used to happen without a word, so a request with a
#' path the parser did not recognize got results for another folder. The
#' note is a warning, which reaches the client as a second part of the
#' output.
#' @param path The path from the request, already confined, or NULL
#' @noRd
acp_scan_path <- function(path) {
  if (!is.null(path)) {
    return(path)
  }
  warning(
    "No path was found in the request (in its first ",
    format(.ACP_MAX_PATH_SEARCH, big.mark = ","), " characters), so the ",
    "server's root folder was scanned. Name the folder to scan another one, ",
    "in quotes if it contains spaces.",
    call. = FALSE
  )
  acp_root()
}

#' The folder the ACP server may scan (#111)
#' @return Its normalized path; the working directory if none was set
#' @noRd
acp_root <- function() {
  normalizePath(.acp_state$root %||% getwd(), winslash = "/", mustWork = TRUE)
}

#' Is a normalized path the folder or inside it?
#'
#' Compares whole path components ("D:/data2" is not inside "D:/data"), and
#' ignores case on Windows, whose file systems do.
#' @noRd
is_inside_folder <- function(path, folder) {
  if (.Platform$OS.type == "windows") {
    path <- tolower(path)
    folder <- tolower(folder)
  }
  folder <- sub("/+$", "", folder)
  identical(path, folder) || startsWith(path, paste0(folder, "/"))
}

#' Keep a request's path inside the server's root folder (#111)
#'
#' A relative path is taken from the root folder, "~" is expanded, and the
#' result is normalized, which also resolves symbolic links and Windows
#' junctions of existing folders, so that a link out of the root does not
#' get out. A path outside the root is an error: the server used to scan
#' any absolute path its R process could read.
#' @param path A path that passed sanitize_acp_path()
#' @param root The normalized root folder (also used by the MCP server
#'   over HTTP)
#' @return The normalized absolute path
#' @noRd
confine_acp_path <- function(path, root = acp_root()) {
  candidate <- path.expand(path)
  if (!grepl("^([A-Za-z]:)?[/\\\\]", candidate)) {
    candidate <- file.path(root, candidate)
  }
  resolved <- normalizePath(candidate, winslash = "/", mustWork = FALSE)
  if (!is_inside_folder(resolved, root)) {
    stop("Path rejected: outside the folder this server scans: ", path, call. = FALSE)
  }
  resolved
}

#' Exclude patterns for the files a scan would reach outside the root (#111)
#'
#' A recursive scan follows symbolic links and Windows junctions inside the
#' scanned folder (list.files() does), so a link inside the root could
#' expose files outside it. This lists what the scan could read, resolves
#' each file, finds the link each outside file is reached through (the
#' shortest part of its listed path that resolves outside the root), and
#' returns one exclude pattern per link for put() and its siblings, with a
#' warning that says how many files are skipped. One pattern per link, not
#' per file: put() matches every pattern against every file, and 5,000
#' files behind one link took 70 s with a pattern each. A folder with links
#' into a cache outside the root, such as an renv library, can still be
#' scanned.
#' @param path The confined path to scan
#' @param recursive Whether the scan is recursive
#' @param root The normalized root folder
#' @return Exclude patterns, or NULL when every file is inside the root
#' @noRd
acp_outside_excludes <- function(path, recursive = TRUE, root = acp_root()) {
  if (!dir.exists(path)) {
    return(NULL)
  }
  files <- list.files(path, full.names = TRUE, recursive = recursive)
  if (length(files) == 0) {
    return(NULL)
  }
  resolved <- normalizePath(files, winslash = "/", mustWork = FALSE)
  outside <- files[!vapply(resolved, is_inside_folder, logical(1), folder = root)]
  if (length(outside) == 0) {
    return(NULL)
  }
  warning(
    length(outside), if (length(outside) == 1) " file" else " files",
    " reached through links that lead outside the server's root folder ",
    if (length(outside) == 1) "was" else "were", " skipped.",
    call. = FALSE
  )
  # The listed path of the link that each outside file is reached through
  link_paths <- character()
  for (file in sort(outside)) {
    # paste0(character(0), "/") is "/", which every absolute path starts with
    if (length(link_paths) > 0 && any(startsWith(file, paste0(link_paths, "/")))) {
      next
    }
    relative_parts <- strsplit(substring(file, nchar(path) + 2L), "/", fixed = TRUE)[[1]]
    prefix <- path
    for (part in relative_parts) {
      prefix <- paste0(prefix, "/", part)
      if (!is_inside_folder(normalizePath(prefix, winslash = "/", mustWork = FALSE), root)) {
        break
      }
    }
    link_paths <- c(link_paths, prefix)
    if (length(link_paths) > .ACP_MAX_OUTSIDE_LINKS) {
      stop(
        "ACP scan refused: more than ", .ACP_MAX_OUTSIDE_LINKS, " links in this ",
        "folder lead outside the server's root folder; scan a subfolder.",
        call. = FALSE
      )
    }
  }
  # One pattern per link, escaped. "^$" matches no file; with it, put() does
  # not split a single pattern at its commas.
  escaped <- gsub("([.\\\\|()\\[\\]{}^$*+?])", "\\\\\\1", unique(link_paths), perl = TRUE)
  c(paste0("^", escaped, "(/|$)"), "^$")
}

#' Extract parameters from message content
#' @noRd
extract_parameters <- function(content) {
  params <- list()

  path <- extract_path(content)
  if (!is.null(path)) {
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
    regexpr("[Dd][Ii][Rr][Ee][Cc][Tt][Ii][Oo][Nn][=: ]*(TD|TB|LR|BT|RL|td|tb|lr|bt|rl)\\b", content, perl = TRUE)
  )
  if (length(dir_match) > 0 && nchar(dir_match[1]) > 0) {
    # Extract just the direction value (TD, TB, LR, BT, RL)
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
#' or directory traversal components (".."). A rejected path is an error:
#' it used to become "." with a warning that only the server log showed,
#' so the run scanned the server's working directory instead.
#'
#' @param path Character string of the file path to sanitize
#' @return The path, or "." when no path is given
#' @noRd
sanitize_acp_path <- function(path) {
  if (is.null(path) || !is.character(path) || length(path) != 1 || nchar(path) == 0) {
    return(".")
  }

  # Reject paths with control characters (including null bytes)
  if (grepl("[[:cntrl:]]", path)) {
    stop("Path rejected: contains control characters", call. = FALSE)
  }

  # Normalize path separators for traversal check
  normalized <- gsub("\\\\", "/", path)

  # Network and device paths (\\\\server\\share, //server/share, \\\\?\\): a
  # file system call on one would make the server contact that host (#111)
  if (startsWith(normalized, "//")) {
    stop("Path rejected: network and device paths are not allowed: ", path, call. = FALSE)
  }

  # Reject directory traversal attempts, also after a drive ("D:..\\x")
  if (grepl("(^|[/:])\\.\\.(/|$)", normalized)) {
    stop("Path rejected: directory traversal not allowed: ", path, call. = FALSE)
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
  result <- tryCatch({
    parsed <- parse_acp_message(input)
    # Sanitize path from network input; a rejected path ends the run with
    # an error message. Help and guide requests use no path.
    uses_path <- parsed$operation %in% c("scan", "diagram", "auto", "generate", "merge")
    if (uses_path && !is.null(parsed$params$path)) {
      parsed$params$path <- confine_acp_path(sanitize_acp_path(parsed$params$path))
    }
    switch(parsed$operation,
      "scan" = {
        path <- acp_scan_path(parsed$params$path)
        recursive <- !isFALSE(parsed$params$recursive)
        put(path = path, recursive = recursive,
            exclude = acp_outside_excludes(path, recursive))
      },
      "diagram" = {
        # For diagram, we need workflow data
        # If path provided, scan first
        path <- parsed$params$path
        if (!is.null(path)) {
          recursive <- !isFALSE(parsed$params$recursive)
          workflow <- put(path, recursive = recursive,
                          exclude = acp_outside_excludes(path, recursive))
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
        path <- acp_scan_path(parsed$params$path)
        recursive <- !isFALSE(parsed$params$recursive)
        put_auto(path = path, recursive = recursive,
                 exclude = acp_outside_excludes(path, recursive))
      },
      "generate" = {
        path <- acp_scan_path(parsed$params$path)
        recursive <- !isFALSE(parsed$params$recursive)
        annotations <- put_generate(path = path, output = "raw", recursive = recursive,
                                    exclude = acp_outside_excludes(path, recursive))
        paste(annotations, collapse = "\n")
      },
      "merge" = {
        path <- acp_scan_path(parsed$params$path)
        recursive <- !isFALSE(parsed$params$recursive)
        put_merge(path = path, recursive = recursive,
                  exclude = acp_outside_excludes(path, recursive))
      },
      "help" = {
        # Capture help output
        help_output <- utils::capture.output(
          putior_help(parsed$params$topic)
        )
        paste(help_output, collapse = "\n")
      },
      "guide" = {
        putior_guide(output = "raw")
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
          "- guide: Get AI assistant documentation"
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

    # A workflow has only the columns its annotations use: one without any
    # input has no input column, which stopped the run (row$input is NULL)
    field_text <- function(row, field) {
      value <- if (field %in% names(row)) row[[field]] else NA
      if (length(value) == 1 && !is.na(value) && nzchar(value)) as.character(value) else NULL
    }
    field_labels <- c(label = "Label", file_name = "Source", input = "Input", output = "Output")
    for (i in seq_len(nrow(result))) {
      row <- result[i, ]
      lines <- c(lines, paste0("Node ", i, ": ", row$id))
      for (field in names(field_labels)) {
        value <- field_text(row, field)
        if (!is.null(value)) lines <- c(lines, paste0("  ", field_labels[[field]], ": ", value))
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
#'
#' The warnings that R raised during the run follow as a second part: the
#' plumber2 server only logs them, so the client would never see them.
#' @param result The run's result
#' @param warning_messages Warnings collected with collect_warnings()
#' @noRd
format_acp_output <- function(result, warning_messages = character()) {
  parts <- list(
    list(
      content = format_result_as_text(result),
      content_type = "text/plain"
    )
  )
  if (length(warning_messages) > 0) {
    parts <- c(parts, list(list(
      content = sub("^\n+", "", format_warning_block(warning_messages)),
      content_type = "text/plain"
    )))
  }
  list(
    list(
      role = "assistant",
      parts = parts
    )
  )
}

# =============================================================================
# ACP Endpoint Handlers
# =============================================================================

#' The plumber2 API of the ACP server
#'
#' JSON with scalars unboxed (a name as a string, not an array of one
#' string), as ACP clients expect (#113).
#' @noRd
acp_api <- function() {
  json_serializer <- plumber2::get_serializers("unboxedJSON")
  plumber2::api() |>
    plumber2::api_get("/agents", acp_list_agents_handler,
                      serializers = json_serializer) |>
    # Refusals happen before the body is read (#111)
    plumber2::api_post_header("/runs", acp_runs_header_handler,
                              serializers = json_serializer) |>
    plumber2::api_post("/runs", acp_create_run_handler,
                       serializers = json_serializer) |>
    plumber2::api_get("/runs/<run_id>", acp_get_run_handler,
                      serializers = json_serializer)
}

#' Handler for GET /agents endpoint
#' @noRd
acp_list_agents_handler <- function(request = NULL, response = NULL) {
  if (!acp_host_allowed(request)) {
    if (!is.null(response)) response$status <- 403L
    return(list(error = "Forbidden: this server answers only requests to localhost"))
  }
  list(agents = list(putior_acp_manifest()))
}

#' Does a request carry the server's token? (#111)
#'
#' Without a token every request is allowed (a server on a loopback
#' address). With one, the request needs "Authorization: Bearer <token>".
#' The comparison is of SHA-256 digests, so that its time does not depend
#' on how much of the token a guess gets right.
#' @param request A reqres::Request, or NULL when a handler is called
#'   directly
#' @noRd
acp_authorized <- function(request) {
  token <- .acp_state$token
  if (is.null(token)) {
    return(TRUE)
  }
  header <- if (is.null(request)) NULL else request$get_header("Authorization")
  if (is.null(header) || length(header) != 1 || !grepl("^[Bb][Ee][Aa][Rr][Ee][Rr] ", header)) {
    return(FALSE)
  }
  # The scheme is case-insensitive (RFC 7235); the token is not
  given_token <- substring(header, 8L)
  if (requireNamespace("openssl", quietly = TRUE)) {
    identical(as.character(openssl::sha256(given_token)), as.character(openssl::sha256(token)))
  } else {
    identical(given_token, token)
  }
}

#' Is a request's Host one of this machine's loopback names? (#111)
#'
#' A server without a token answers only requests addressed to 127.x,
#' localhost or ::1. Otherwise a web page the user visits could reach it
#' through DNS rebinding (a name of the attacker's that resolves to
#' 127.0.0.1) and read scan results. With a token that is not needed: the
#' page does not know the token.
#' @noRd
acp_host_allowed <- function(request) {
  if (is.null(request) || !is.null(.acp_state$token)) {
    return(TRUE)
  }
  host <- tolower(request$get_header("Host") %||% "")
  host <- sub(":[0-9]+$", "", host)
  is_loopback_host(host) || host == "[::1]"
}

#' Is a host name or address a loopback one?
#' @noRd
is_loopback_host <- function(host) {
  host <- tolower(host)
  grepl("^127(\\.[0-9]{1,3}){3}$", host) || host %in% c("localhost", "::1")
}

#' Check a server's root folder and return it normalized (#111)
#' @noRd
check_server_root <- function(root) {
  if (!is.character(root) || length(root) != 1 || is.na(root) || !dir.exists(root)) {
    stop("'root' must be an existing folder.", call. = FALSE)
  }
  normalizePath(root, winslash = "/", mustWork = TRUE)
}

#' Check a server's token against its host (#111)
#'
#' A token is NULL or a string of at least 16 characters without spaces. A
#' server on an address other than a loopback one can be reached from
#' other machines and needs one.
#' @param header How clients send the token, for the error message
#' @noRd
check_server_token <- function(token, host, header) {
  if (!is.null(token) &&
      (!is.character(token) || length(token) != 1 || is.na(token) ||
         nchar(trimws(token)) < 16 || grepl("[[:space:]]", token))) {
    stop("'token' must be a string of at least 16 characters without spaces, or NULL.",
         call. = FALSE)
  }
  if (!is_loopback_host(host) && is.null(token)) {
    stop(
      "A server on ", host, " can be reached from other machines, so it needs ",
      "a token: token = \"<at least 16 random characters>\". Clients then send ",
      "'", header, "'.",
      call. = FALSE
    )
  }
  invisible(token)
}

#' A request that the server refuses before running it (#111)
#'
#' Sets the status and returns the body of the answer, or NULL when the
#' request may run. Called with request = NULL, as the tests call the
#' handlers directly, nothing is checked.
#' @noRd
acp_refuse_request <- function(request, response, needs_json = FALSE) {
  refusal <- function(status, message) {
    if (!is.null(response)) response$status <- status
    list(error = message)
  }
  if (!acp_host_allowed(request)) {
    return(refusal(403L, "Forbidden: this server answers only requests to localhost"))
  }
  if (!acp_authorized(request)) {
    return(acp_unauthorized(response))
  }
  # A browser can send a cross-site POST without a preflight only with a
  # "simple" content type, never application/json
  if (needs_json && !is.null(request)) {
    content_type <- tolower(request$get_header("Content-Type") %||% "")
    if (!startsWith(content_type, "application/json")) {
      return(refusal(415L, "Unsupported Media Type: send the request as application/json"))
    }
  }
  NULL
}

#' Replace the server's root folder in a message with "<root>" (#111)
#'
#' Error messages and warnings name absolute paths, which would tell a
#' client where the root lies and how the disk is laid out.
#' @noRd
redact_acp_root <- function(text, root = acp_root()) {
  # A drive or file system root would be every path's start
  if (grepl("^([A-Za-z]:)?/?$", root)) {
    return(text)
  }
  for (root_form in unique(c(root, gsub("/", "\\\\", root)))) {
    escaped <- gsub("([.\\\\|()\\[\\]{}^$*+?])", "\\\\\\1", root_form, perl = TRUE)
    # Only where the root ends at a path boundary ("<root>/x", not "<root>tra")
    text <- gsub(paste0(escaped, "(?=[/\\\\'\"\\s]|$)"), "<root>", text, perl = TRUE)
  }
  text
}

#' The answer to a request without the server's token (#111)
#' @noRd
acp_unauthorized <- function(response) {
  if (!is.null(response)) {
    response$status <- 401L
    response$set_header("WWW-Authenticate", "Bearer")
  }
  list(error = "Unauthorized: send the server's token as 'Authorization: Bearer <token>'")
}

#' Header handler for POST /runs: refuse before reading the body (#111)
#'
#' Checks the Host, the token, the content type and the size from the
#' Content-Length header, so that a refused request is answered before its
#' body is handled. plumber2's own max_request_size had no effect (plumber2
#' 0.2.0). The size limit is best-effort: a body sent in chunks has no
#' Content-Length, and the web server may buffer a body before this runs.
#' @noRd
acp_runs_header_handler <- function(request, response) {
  refusal <- acp_refuse_request(request, response, needs_json = TRUE)
  if (!is.null(refusal)) {
    return(refusal)
  }
  content_length <- suppressWarnings(as.numeric(request$get_header("Content-Length")))
  if (length(content_length) == 1 && !is.na(content_length) &&
      content_length > .ACP_MAX_REQUEST_BYTES) {
    response$status <- 413L
    return(list(error = paste0(
      "Payload Too Large: a request may have at most ",
      format(.ACP_MAX_REQUEST_BYTES, big.mark = ",", scientific = FALSE), " bytes"
    )))
  }
  plumber2::Next
}

#' Handler for POST /runs endpoint
#' @noRd
acp_create_run_handler <- function(body, request = NULL, response = NULL) {
  refusal <- acp_refuse_request(request, response, needs_json = TRUE)
  if (!is.null(refusal)) {
    return(refusal)
  }
  # A body that is not an object with an input array is the client's error
  input_valid <- is.list(body) && tryCatch({
    extract_text_content(body$input)
    TRUE
  }, error = function(e) FALSE)
  if (!input_valid) {
    if (!is.null(response)) response$status <- 400L
    return(list(error = "Bad Request: send a JSON object with an input array of messages"))
  }
  run_id <- generate_run_id()

  # Extract input and session_id from body
  input <- body$input
  # NA, so that a missing session id is sent as null rather than {}
  session_id <- body$session_id %||% NA_character_

  # Execute the request, keeping the warnings R raises for the output
  collected <- collect_warnings(execute_acp_request(input, session_id))
  if (is.character(collected$value)) collected$value <- redact_acp_root(collected$value)
  collected$warnings <- redact_acp_root(collected$warnings)

  # Create run record
  run_data <- list(
    run_id = run_id,
    agent_name = "putior",
    session_id = session_id,
    status = "completed",
    output = format_acp_output(collected$value, collected$warnings),
    created_at = Sys.time()
  )

  # Store for later retrieval
  store_run(run_id, run_data)

  run_data
}

#' Handler for GET /runs/:run_id endpoint
#' @noRd
acp_get_run_handler <- function(run_id, request = NULL, response = NULL) {
  refusal <- acp_refuse_request(request, response)
  if (!is.null(refusal)) {
    return(refusal)
  }
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
#' @param root The folder that requests may scan (default: the working
#'   directory). A request's relative path is taken from it, and a path
#'   outside it, also through a symbolic link, is rejected; a scan skips
#'   files that links inside it lead outside to. A request without a path
#'   scans this folder.
#' @param token \code{NULL} (default) or a string of at least 16
#'   characters. With a token, \code{POST /runs} and \code{GET /runs/<id>}
#'   need the header \code{Authorization: Bearer <token>}. A server on an
#'   address other than a loopback one (\code{127.0.0.1}, \code{localhost},
#'   \code{::1}) needs a token. Passing it from an environment variable,
#'   as \code{token = Sys.getenv("PUTIOR_ACP_TOKEN")}, keeps it out of
#'   scripts and the R history.
#'
#' @details
#' The ACP server exposes the following endpoints:
#' \describe{
#'   \item{GET /agents}{Returns the agent manifest for discovery}
#'   \item{POST /runs}{Execute a putior operation}
#'   \item{GET /runs/<run_id>}{Get the status/result of a previous run}
#' }
#'
#' @section Security:
#' \itemize{
#'   \item A request can scan only the \code{root} folder and what lies
#'     below it, and it sees the file names and labels found there. A path
#'     outside the root is rejected, also when a symbolic link or junction
#'     leads there; a recursive scan skips the files that links inside the
#'     root lead outside to, and refuses a folder with more than 200 such
#'     links. A path with a \code{..} component, control
#'     characters, or a network or device form (\code{\\\\server\\share},
#'     \code{//server/share}) is rejected before the disk is touched.
#'     Messages show the root as \code{<root>}.
#'   \item Without a token, the server runs only on a loopback \code{host}
#'     (\code{127.x.x.x}, \code{localhost}, \code{::1}) and answers only
#'     requests addressed to such a name, so that a web page cannot reach
#'     it through DNS rebinding. With \code{host = "0.0.0.0"} or another
#'     address, set \code{token}.
#'   \item \code{POST /runs} needs \code{Content-Type: application/json},
#'     which a web page cannot send to another site without the server's
#'     consent. A \code{Content-Length} over 1 MB is refused (a body sent
#'     in chunks is not limited); on a server that other machines can
#'     reach, use a proxy that limits the request size.
#'   \item Run IDs are 128 random bits (from the openssl package, which
#'     plumber2 needs), so a client cannot guess the ID of another
#'     client's run.
#'   \item The server does not use TLS: across a network, put it behind a
#'     proxy that does, or the token travels in clear text.
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
#'   \item \strong{guide}: "What are your capabilities?"
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
#'
#' # With a token
#' curl -X POST http://localhost:8080/runs \\
#'   -H "Authorization: Bearer $PUTIOR_ACP_TOKEN" \\
#'   -H "Content-Type: application/json" \\
#'   -d '{"input": [{"role": "user", "parts": [{"content": "scan ./R/"}]}]}'
#' }
#'
#' @return This function does not return; it runs the server until terminated.
#'
#' @family integration
#' @export
#'
#' @examples
#' \dontrun{
#' # Start ACP server on default port
#' putior_acp_server()
#'
#' # Start on custom host/port
#' # Reachable from other machines: needs a token, sent by clients as
#' # "Authorization: Bearer <token>"
#' putior_acp_server(host = "0.0.0.0", port = 9000, root = "~/projects",
#'                   token = Sys.getenv("PUTIOR_ACP_TOKEN"))
#' }
#'
#' @seealso
#' \code{\link{putior_acp_manifest}} for the agent definition,
#' \code{\link{putior_mcp_server}} for MCP (Model-to-tool) integration
putior_acp_server <- function(host = "127.0.0.1", port = 8080L, root = getwd(),
                              token = NULL) {
  # Check for plumber2 dependency
  if (!requireNamespace("plumber2", quietly = TRUE)) {
    stop(
      "The 'plumber2' package is required for ACP server functionality.\n",
      "Install it with: install.packages('plumber2')\n",
      "Or: pak::pak('plumber2')",
      call. = FALSE
    )
  }

  # Validate port range (1-65535), mirroring putior_mcp_server().
  # suppressWarnings avoids a spurious "NAs introduced by coercion" before the
  # clean error for non-numeric input.
  port <- suppressWarnings(as.integer(port))
  if (is.na(port) || port < 1L || port > 65535L) {
    stop("'port' must be an integer between 1 and 65535.", call. = FALSE)
  }

  # The folder the server may scan, and a token unless only this machine
  # can reach it (#111)
  root <- check_server_root(root)
  check_server_token(token, host, "Authorization: Bearer <token>")
  if (host == "0.0.0.0") {
    warning(
      "Binding to 0.0.0.0 exposes the ACP server to all network interfaces; ",
      "requests need the token. Use host = \"127.0.0.1\" for local-only access.",
      call. = FALSE
    )
  }
  .acp_state$root <- root
  .acp_state$token <- token
  on.exit({
    .acp_state$root <- NULL
    .acp_state$token <- NULL
  }, add = TRUE)

  pa <- acp_api()

  message("Starting putior ACP server...")
  message("  Host: ", host)
  message("  Port: ", port)
  message("  Root: ", root, " (requests may scan only this folder)")
  message("  Token: ", if (is.null(token)) "none (local requests only)" else "required")
  message("")
  message("Endpoints:")
  message("  GET  /agents       - Discover this agent")
  message("  POST /runs         - Execute an operation")
  message("  GET  /runs/<id>    - Get run status/results")
  message("")
  message("Press Ctrl+C to stop the server.")

  # Run the server (port already validated and coerced above)
  plumber2::api_run(pa, host = host, port = port)
}

