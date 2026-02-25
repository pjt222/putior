#' Create a Custom Theme Palette for Workflow Diagrams
#'
#' Constructs a custom color palette for use with \code{\link{put_diagram}()}.
#' Specify colors for any subset of node types; unspecified types inherit
#' from the \code{base} theme.
#'
#' Each node type accepts a named character vector with keys \code{fill},
#' \code{stroke}, and \code{color} (text color). All values must be valid
#' hex colors (e.g., \code{"#1a5276"}).
#'
#' @param base Character string naming the base theme to inherit from.
#'   Must be one of the valid themes returned by \code{\link{get_diagram_themes}()}.
#'   Default: \code{"light"}.
#' @param input Named character vector \code{c(fill, stroke, color)} for input nodes.
#' @param process Named character vector \code{c(fill, stroke, color)} for process nodes.
#' @param output Named character vector \code{c(fill, stroke, color)} for output nodes.
#' @param decision Named character vector \code{c(fill, stroke, color)} for decision nodes.
#' @param artifact Named character vector \code{c(fill, stroke, color)} for artifact nodes.
#' @param start Named character vector \code{c(fill, stroke, color)} for start nodes.
#' @param end Named character vector \code{c(fill, stroke, color)} for end nodes.
#'
#' @return An object of class \code{putior_theme} (a named list of CSS style
#'   strings, one per node type), suitable for passing to
#'   \code{put_diagram(palette = ...)}.
#'
#' @export
#'
#' @examples
#' # Override only input node colors, inherit rest from dark theme
#' my_theme <- put_theme(base = "dark",
#'   input = c(fill = "#1a5276", stroke = "#2e86c1", color = "#ffffff"))
#'
#' # Full custom palette
#' custom <- put_theme(
#'   input   = c(fill = "#264653", stroke = "#2a9d8f", color = "#ffffff"),
#'   process = c(fill = "#e9c46a", stroke = "#f4a261", color = "#000000"),
#'   output  = c(fill = "#e76f51", stroke = "#264653", color = "#ffffff"))
#'
#' \dontrun{
#' workflow <- put("./src/")
#' put_diagram(workflow, palette = my_theme)
#' }
put_theme <- function(base = "light",
                      input = NULL,
                      process = NULL,
                      output = NULL,
                      decision = NULL,
                      artifact = NULL,
                      start = NULL,
                      end = NULL) {
  # Validate base theme

if (!base %in% .VALID_THEMES) {
    stop(
      "Invalid base theme '", base, "'.\n",
      "Valid themes: ", paste(.VALID_THEMES, collapse = ", "),
      call. = FALSE
    )
  }

  # Start from base theme colors
  colors <- get_theme_colors(base)

  # Apply overrides
  overrides <- list(
    input = input, process = process, output = output,
    decision = decision, artifact = artifact, start = start, end = end
  )

  for (node_type in names(overrides)) {
    override <- overrides[[node_type]]
    if (!is.null(override)) {
      colors[[node_type]] <- apply_color_override(override, node_type)
    }
  }

  structure(colors, class = c("putior_theme", "list"))
}

#' Apply a color override for a single node type
#'
#' Validates and converts a named character vector of hex colors into a
#' Mermaid CSS style string.
#'
#' @param override Named character vector with keys from \code{fill},
#'   \code{stroke}, \code{color}.
#' @param node_type Character string naming the node type (for error messages).
#' @return Single CSS style string.
#' @noRd
apply_color_override <- function(override, node_type) {
  if (!is.character(override) || is.null(names(override))) {
    stop(
      "'", node_type, "' must be a named character vector ",
      "with keys from: fill, stroke, color.\n",
      "Example: c(fill = \"#1a5276\", stroke = \"#2e86c1\", color = \"#ffffff\")",
      call. = FALSE
    )
  }

  valid_keys <- c("fill", "stroke", "color")
  bad_keys <- setdiff(names(override), valid_keys)
  if (length(bad_keys) > 0) {
    stop(
      "Unknown key(s) in '", node_type, "' override: ",
      paste(bad_keys, collapse = ", "), ".\n",
      "Valid keys: fill, stroke, color",
      call. = FALSE
    )
  }

  for (key in names(override)) {
    if (!is_valid_hex_color(override[[key]])) {
      stop(
        "Invalid hex color for ", node_type, "$", key, ": '",
        override[[key]], "'.\n",
        "Expected format: #RGB, #RRGGBB, or #RRGGBBAA (e.g., '#1a5276')",
        call. = FALSE
      )
    }
  }

  # Build CSS string
  parts <- character()
  if ("fill" %in% names(override)) {
    parts <- c(parts, paste0("fill:", override[["fill"]]))
  }
  if ("stroke" %in% names(override)) {
    parts <- c(parts, paste0("stroke:", override[["stroke"]]))
  }
  parts <- c(parts, "stroke-width:2px")
  if ("color" %in% names(override)) {
    parts <- c(parts, paste0("color:", override[["color"]]))
  }

  paste(parts, collapse = ",")
}

#' Print a putior_theme Object
#'
#' @param x A \code{putior_theme} object.
#' @param ... Additional arguments (ignored).
#' @return The object, invisibly.
#'
#' @export
print.putior_theme <- function(x, ...) {
  cat("putior custom theme palette\n")
  cat(strrep("-", 40), "\n")
  for (node_type in names(x)) {
    cat("  ", format(node_type, width = 10), ": ", x[[node_type]], "\n", sep = "")
  }
  invisible(x)
}
