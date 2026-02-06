#' putior Package Initialization
#'
#' Package load and attach hooks for putior. Sets up default options
#' and initializes the logging namespace when the logger package is available.
#'
#' @name putior-package
#' @keywords internal
NULL

# =============================================================================
# Internal Utilities
# =============================================================================

#' Null coalescing operator
#' @noRd
`%||%` <- function(x, y) {
  if (is.null(x)) y else x
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
