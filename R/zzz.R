#' putior Package Initialization
#'
#' Package load and attach hooks for putior. Sets up default options
#' and initializes the logging namespace when the logger package is available.
#'
#' @name putior-package
#' @keywords internal
NULL

# =============================================================================
# Internal Constants
# =============================================================================

#' Valid diagram themes (single source of truth)
#' @noRd
.VALID_THEMES <- c("light", "dark", "auto", "minimal", "github",
                    "viridis", "magma", "plasma", "cividis")

#' Valid click protocols (single source of truth; "rstudio" was removed, #101)
#' @noRd
.VALID_CLICK_PROTOCOLS <- c("vscode", "file")

#' Valid node types (single source of truth)
#' @noRd
.VALID_NODE_TYPES <- c("input", "process", "output", "decision", "start", "end")

# =============================================================================
# Internal Utilities
# =============================================================================

#' Null coalescing operator
#' @noRd
`%||%` <- function(x, y) {
  if (is.null(x)) y else x
}

#' Validate a file/directory path argument
#'
#' Shared validation for path arguments across put(), put_auto(), put_generate().
#' Checks type, existence, and rejects directory traversal.
#'
#' @param path The path argument to validate
#' @param caller Name of the calling function (for error messages)
#' @return The validated path (invisibly), or stops with an informative error
#' @noRd
validate_path_arg <- function(path, caller) {
  if (!is.character(path) || length(path) != 1) {
    stop(
      "'path' must be a single character string.\n",
      "Received: ", class(path)[1],
      if (length(path) > 1) paste0(" with ", length(path), " elements") else "",
      ".\n",
      "Example: ", caller, "(\"./src/\") or ", caller, "(\"script.R\")",
      call. = FALSE
    )
  }

  # Reject directory traversal attempts (defense-in-depth)
  normalized <- gsub("\\\\", "/", path)
  if (grepl("(^|/)\\.\\.(/|$)", normalized)) {
    stop(
      "Path rejected: directory traversal ('..') not allowed: '", path, "'",
      call. = FALSE
    )
  }

  if (!file.exists(path)) {
    stop(
      "Path does not exist: '", path, "'\n",
      "Please check:\n",
      "- The path is spelled correctly\n",
      "- The directory or file exists\n",
      "- You have read permissions for this location",
      call. = FALSE
    )
  }

  invisible(path)
}

#' Copy content to clipboard with graceful fallback
#'
#' Attempts to use clipr for clipboard access. Falls back to console output
#' with a warning if clipr is not available.
#'
#' @param content Character string to copy
#' @param success_msg Message to display on successful copy
#' @param fallback_content Optional alternative content to print on fallback
#'   (e.g., with markdown fences). If NULL, prints \code{content} directly.
#' @return Invisible NULL
#' @noRd
copy_to_clipboard <- function(content, success_msg, fallback_content = NULL) {
  if (requireNamespace("clipr", quietly = TRUE)) {
    clipr::write_clip(content)
    message(success_msg)
  } else {
    warning(
      "clipr package not available for clipboard access.\n",
      "The content has been printed to console instead.\n",
      "To enable clipboard support, install with: install.packages(\"clipr\")",
      call. = FALSE
    )
    cat(fallback_content %||% content, "\n")
  }
  invisible(NULL)
}

#' Check if a value is empty (NULL, NA, or "")
#'
#' @param x Value to check
#' @return TRUE if x is NULL, NA, or an empty string
#' @noRd
is_empty_string <- function(x) {
  is.null(x) || is.na(x) || x == ""
}

#' Filter files by exclusion patterns
#'
#' Removes files whose full path matches any of the given regex patterns.
#'
#' @param files Character vector of file paths
#' @param exclude Character vector of regex patterns to exclude, or NULL
#' @return Filtered character vector of file paths
#' @noRd
filter_excluded_files <- function(files, exclude) {
  if (is.null(exclude) || length(files) == 0) {
    return(files)
  }
  if (!is.character(exclude)) {
    stop("'exclude' must be a character vector of regex patterns", call. = FALSE)
  }
  # Support comma-separated string (e.g. from MCP)
  if (length(exclude) == 1 && grepl(",", exclude)) {
    exclude <- trimws(strsplit(exclude, ",")[[1]])
  }
  exclude <- exclude[nchar(exclude) > 0]
  if (length(exclude) == 0) return(files)
  keep <- rep(TRUE, length(files))
  for (pattern in exclude) {
    keep <- keep & !grepl(pattern, files)
  }
  files[keep]
}

#' Validate a hex color string
#'
#' @param x Character string to check
#' @return TRUE if x is a valid hex color (#RGB, #RRGGBB, or #RRGGBBAA)
#' @noRd
is_valid_hex_color <- function(x) {
  is.character(x) && length(x) == 1 && grepl("^#([0-9a-fA-F]{3}|[0-9a-fA-F]{6}|[0-9a-fA-F]{8})$", x)
}

# =============================================================================
# Warnings for the MCP and ACP servers
# =============================================================================
#
# Clients of the MCP (stdio) and ACP servers never see R warnings: mcptools'
# server loop never returns to the top level, where deferred warnings would
# print, and plumber2 only logs them. Several problems are reported only as
# warnings (a "<" in a title or label, a diagram over Mermaid's limits, id
# collisions, invalid annotations), so the servers collect them and return
# them with the result.

# At most this many warnings are listed in a reply, each cut to at most
# .MAX_WARNING_CHARACTERS characters: one per invalid annotation can be
# many, one warning can list every unreadable file, and a client may cut
# long tool output short.
.MAX_REPORTED_WARNINGS <- 20L
.MAX_WARNING_CHARACTERS <- 1000L

#' Drop warnings that repeat another one
#'
#' put_merge() runs put() and put_auto(), which both warn about missing
#' files; put_auto()'s one-line warning is the first line of put()'s. Drops
#' exact repeats and one-line warnings that another warning starts with.
#' @param warning_messages Character vector of warning messages
#' @return The messages without the redundant ones, in their order
#' @noRd
drop_redundant_warnings <- function(warning_messages) {
  multi_line <- grepl("\n", warning_messages, fixed = TRUE)
  first_lines <- sub("(?s)\n.*", "", warning_messages[multi_line], perl = TRUE)
  is_redundant <- duplicated(warning_messages) |
    (!multi_line & warning_messages %in% first_lines)
  warning_messages[!is_redundant]
}

#' Run code and collect the warnings it raises
#'
#' The warnings are held back and returned with the value. An error keeps
#' its message, with the warnings raised before it appended, because a
#' server reports only the error's message.
#' @param code Code to run
#' @return A list with \code{value} and \code{warnings} (character)
#' @noRd
collect_warnings <- function(code) {
  warning_messages <- character()
  failure <- NULL
  value <- withCallingHandlers(
    tryCatch(code, error = function(error_condition) {
      failure <<- error_condition
      NULL
    }),
    warning = function(warning_condition) {
      warning_messages <<- c(warning_messages, conditionMessage(warning_condition))
      invokeRestart("muffleWarning")
    }
  )
  warning_messages <- drop_redundant_warnings(warning_messages)
  if (!is.null(failure)) {
    error_message <- conditionMessage(failure)
    if (length(warning_messages) > 0) {
      error_message <- paste0(
        error_message, format_warning_block(warning_messages, before_error = TRUE)
      )
    }
    stop(error_message, call. = FALSE)
  }
  list(value = value, warnings = warning_messages)
}

#' The warnings as a block of text for a server reply
#'
#' A header line and one "- " item per warning, continuation lines indented,
#' at most .MAX_REPORTED_WARNINGS of them. Control characters and the line
#' separators U+2028 and U+2029 become spaces.
#'
#' With \code{style = "mermaid"}, every line is a Mermaid comment ("\%\% "),
#' so that the diagram still renders when a client joins the block to it
#' (Claude Code joins content items without a separator). "\%\%\{" in a
#' warning, such as a label it quotes, is written "\%\% \{": Mermaid applies
#' a "\%\%\{...\}\%\%" directive even inside a comment line (measured: one in
#' a comment line changed the theme on Mermaid 11.12.0 and 12.2.0).
#' @param warning_messages Character vector of warning messages
#' @param style "text" or "mermaid"
#' @param before_error TRUE when the block follows an error message
#' @return The block, starting with a line break
#' @noRd
format_warning_block <- function(warning_messages, style = c("text", "mermaid"),
                                 before_error = FALSE) {
  style <- match.arg(style)
  shown_messages <- warning_messages[seq_len(min(length(warning_messages), .MAX_REPORTED_WARNINGS))]
  # allowNA: a warning with invalid UTF-8 is listed, not an error
  message_lengths <- nchar(shown_messages, allowNA = TRUE)
  is_long <- !is.na(message_lengths) & message_lengths > .MAX_WARNING_CHARACTERS
  shown_messages[is_long] <- paste0(
    substr(shown_messages[is_long], 1L, .MAX_WARNING_CHARACTERS), " ... (",
    message_lengths[is_long] - .MAX_WARNING_CHARACTERS, " more characters)"
  )
  item_lines <- unlist(lapply(shown_messages, function(warning_message) {
    message_lines <- strsplit(warning_message, "\n", fixed = TRUE)[[1]]
    message_lines <- sub("\\s+$", "", replace_control_chars(message_lines))
    message_lines <- message_lines[nzchar(trimws(message_lines))]
    if (length(message_lines) == 0) message_lines <- "(no message)"
    continuation_lines <- if (length(message_lines) > 1) paste0("  ", message_lines[-1])
    c(paste0("- ", message_lines[1]), continuation_lines)
  }))
  hidden_count <- length(warning_messages) - length(shown_messages)
  if (hidden_count > 0) {
    item_lines <- c(item_lines, paste0("- ... and ", hidden_count, " more"))
  }
  header <- paste0(
    "putior warnings (", length(warning_messages), "), ",
    if (before_error) {
      "raised before the error:"
    } else {
      paste0("not part of the ", if (style == "mermaid") "diagram" else "result", " above:")
    }
  )
  block_lines <- c(header, item_lines)
  if (style == "mermaid") {
    block_lines <- gsub("%%{", "%% {", block_lines, fixed = TRUE)
    return(paste0("\n", paste0("%% ", block_lines, collapse = "\n"), "\n"))
  }
  paste0("\n\n", paste(block_lines, collapse = "\n"))
}

.onLoad <- function(libname, pkgname) {
  # Set default package options
  op <- options()
  op_putior <- list(
    putior.log_level = "WARN"
  )

  # Only set options that aren't already set
  toset <- !(names(op_putior) %in% names(op))
  if (any(toset)) {
    options(op_putior[toset])
  }

  # Initialize logger namespace if logger package is available
  if (requireNamespace("logger", quietly = TRUE)) {
    tryCatch({
      # Let every putior message through logger's own filter: putior_log()
      # already filters by getOption("putior.log_level"), so that option is
      # the only threshold users need to set (#70).
      logger::log_threshold(logger::DEBUG, namespace = pkgname)
    }, error = function(e) {
      # Silently ignore errors during logger setup
    })
  }

  invisible()
}
