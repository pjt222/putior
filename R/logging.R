#' Logging Infrastructure for putior
#'
#' Internal logging wrapper functions that provide structured logging throughout
#' the putior package. Uses the logger package when available, silently degrades
#' when logger is not installed.
#'
#' @name putior_logging
#' @keywords internal
NULL

#' Internal Logging Function
#'
#' Logs messages at specified levels when the logger package is available.
#' Silently does nothing if logger is not installed, ensuring the package
#' works without the optional dependency.
#'
#' @param level Character string specifying log level: "DEBUG", "INFO", "WARN", "ERROR"
#' @param ... Message components passed to logger functions (supports glue-style interpolation)
#' @param .envir Environment for evaluating glue expressions (default: calling environment)
#'
#' @return Invisible NULL
#' @keywords internal
putior_log <- function(level, ..., .envir = parent.frame()) {
  # Silent return if logger not installed

if (!requireNamespace("logger", quietly = TRUE)) {
    return(invisible(NULL))
  }

  # Get current threshold level
  threshold <- getOption("putior.log_level", "WARN")

  # Define level hierarchy (lower number = more verbose)
  levels <- c("DEBUG" = 1L, "INFO" = 2L, "WARN" = 3L, "ERROR" = 4L)

  # Validate level
  if (!level %in% names(levels)) {
    return(invisible(NULL))
  }

  # Check if this message should be logged based on threshold
  if (levels[[level]] < levels[[threshold]]) {
    return(invisible(NULL))
  }

  # Get the appropriate logger function
  log_fn <- switch(level,
    "DEBUG" = logger::log_debug,
    "INFO" = logger::log_info,
    "WARN" = logger::log_warn,
    "ERROR" = logger::log_error,
    logger::log_info  # Default fallback
  )

  # Call the logger function with the message
  tryCatch(
    log_fn(..., .envir = .envir),
    error = function(e) invisible(NULL)
  )

  invisible(NULL)
}

#' Set putior Log Level
#'
#' Configure the logging verbosity for putior functions. Higher verbosity levels
#' provide more detailed information about internal operations, which is useful
#' for debugging annotation parsing, workflow detection, and diagram generation.
#'
#' @param level Character string specifying the log level:
#'   \itemize{
#'     \item "DEBUG" - Fine-grained internal operations (file-by-file, pattern matching)
#'     \item "INFO" - Progress milestones (scan started, nodes found, diagram generated)
#'     \item "WARN" - Issues that don't stop execution (validation issues, missing deps) - default
#'     \item "ERROR" - Fatal issues (via existing stop() calls)
#'   }
#'
#' @return Invisibly returns the previous log level
#' @export
#'
#' @examples
#' # Set to DEBUG for maximum verbosity
#' set_putior_log_level("DEBUG")
#'
#' # Set to INFO for progress updates
#' set_putior_log_level("INFO")
#'
#' # Set to WARN (default) for minimal output
#' set_putior_log_level("WARN")
#'
#' # Check current log level
#' getOption("putior.log_level")
set_putior_log_level <- function(level = "WARN") {
  valid_levels <- c("DEBUG", "INFO", "WARN", "ERROR")
  level <- toupper(level)

  if (!level %in% valid_levels) {
    stop(
      "Invalid log level: '", level, "'\n",
      "Valid levels: ", paste(valid_levels, collapse = ", "), "\n",
      "- DEBUG: Fine-grained internal operations\n",
      "- INFO: Progress milestones\n",
      "- WARN: Issues that don't stop execution (default)\n",
      "- ERROR: Fatal issues",
      call. = FALSE
    )
  }

  old_level <- getOption("putior.log_level", "WARN")
  options(putior.log_level = level)

  # Also configure logger namespace if available
  if (requireNamespace("logger", quietly = TRUE)) {
    logger_level <- switch(level,
      "DEBUG" = logger::DEBUG,
      "INFO" = logger::INFO,
      "WARN" = logger::WARN,
      "ERROR" = logger::ERROR,
      logger::WARN
    )
    tryCatch(
      logger::log_threshold(logger_level, namespace = "putior"),
      error = function(e) invisible(NULL)
    )
  }

  invisible(old_level)
}

#' Check if Logger is Available
#'
#' Internal helper to check if the logger package is installed and available.
#'
#' @return Logical indicating if logger is available
#' @keywords internal
has_logger <- function() {
  requireNamespace("logger", quietly = TRUE)
}

#' Temporarily Set Log Level for a Code Block
#'
#' Internal helper for temporarily setting log level during function execution.
#' Restores the previous level when done.
#'
#' @param level Character string specifying the temporary log level
#' @return A function that restores the original level when called
#' @seealso \code{\link{set_putior_log_level}} for the public interface
#' @examples
#' \dontrun{
#' # Temporarily increase log level
#' reset_level <- with_log_level("DEBUG")
#' on.exit(reset_level(), add = TRUE)
#' # ... code with DEBUG logging ...
#' }
#' @keywords internal
with_log_level <- function(level) {
  if (is.null(level)) {
    return(function() invisible(NULL))
  }

  old_level <- getOption("putior.log_level", "WARN")
  options(putior.log_level = toupper(level))

  # Return cleanup function
  function() {
    options(putior.log_level = old_level)
  }
}
