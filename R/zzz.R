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
      # Create a putior-specific logging namespace
      logger::log_threshold(logger::WARN, namespace = pkgname)
    }, error = function(e) {
      # Silently ignore errors during logger setup
    })
  }

  invisible()
}
