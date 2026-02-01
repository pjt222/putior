#' Access putior Skills for AI Assistants
#'
#' Provides structured skills documentation for AI coding assistants
#' (Claude Code, GitHub Copilot, etc.) to help users with putior.
#'
#' @param topic Character string specifying section. NULL for full content.
#'   Options: "quick-start", "syntax", "languages", "functions",
#'   "patterns", "examples", or NULL (all)
#' @param output Output format: "console" (default), "raw", or "clipboard"
#'
#' @return Invisibly returns content as character vector.
#'   With output="raw", returns as single string.
#'
#' @export
#'
#' @examples
#' # Show all skills
#' putior_skills()
#'
#' # Show specific topic
#' putior_skills("quick-start")
#'
#' # Get raw markdown for AI consumption
#' skills_md <- putior_skills(output = "raw")
putior_skills <- function(topic = NULL,
                          output = c("console", "raw", "clipboard")) {
  output <- match.arg(output)


  # Read skills file
  skills_path <- system.file("SKILLS.md", package = "putior")
  if (skills_path == "") {
    stop("SKILLS.md not found in package installation", call. = FALSE)
  }
  content <- readLines(skills_path, warn = FALSE)

  # Filter by topic if specified
  if (!is.null(topic)) {
    content <- extract_skills_topic(content, topic)
  }

  # Handle output
  switch(output,
    console = cat(content, sep = "\n"),
    raw = return(paste(content, collapse = "\n")),
    clipboard = {
      if (requireNamespace("clipr", quietly = TRUE)) {
        clipr::write_clip(paste(content, collapse = "\n"))
        message("Skills copied to clipboard")
      } else {
        stop("Install 'clipr' package for clipboard support", call. = FALSE)
      }
    }
  )

  invisible(content)
}

#' Extract a topic section from skills content
#' @noRd
extract_skills_topic <- function(content, topic) {
  topic <- tolower(trimws(topic))

  # Map topic names to section headers
  topic_map <- list(
    "quick-start" = "## Quick Start",
    "quick" = "## Quick Start",
    "syntax" = "## Annotation Syntax",
    "annotation" = "## Annotation Syntax",
    "languages" = "## Multi-Language",
    "language" = "## Multi-Language",
    "functions" = "## Core Functions",
    "function" = "## Core Functions",
    "patterns" = "## Auto-Detection",
    "pattern" = "## Auto-Detection",
    "examples" = "## Common Patterns",
    "example" = "## Common Patterns"
  )

  header <- topic_map[[topic]]
  if (is.null(header)) {
    warning("Unknown topic: '", topic, "'. Showing full content.", call. = FALSE)
    return(content)
  }

  # Find section boundaries
  h2_lines <- grep("^## ", content)
  start_idx <- grep(header, content, fixed = TRUE)

  if (length(start_idx) == 0) {
    warning("Topic section not found. Showing full content.", call. = FALSE)
    return(content)
  }

  start_idx <- start_idx[1]
  next_h2 <- h2_lines[h2_lines > start_idx]
  end_idx <- if (length(next_h2) > 0) next_h2[1] - 1 else length(content)

  content[start_idx:end_idx]
}

#' Show skills summary for putior_help integration
#' @noRd
show_skills_summary <- function() {
  cat("\n")
  cat("=== AI Assistant Skills Reference ===\n")
  cat("\n")

  cat("putior includes comprehensive skills documentation for AI coding assistants.\n")
  cat("\n")
  cat("ACCESS METHODS:\n")
  cat("  putior_skills()                    # Show full skills reference\n")
  cat("  putior_skills(\"quick-start\")       # Show quick start section\n")
  cat("  putior_skills(output = \"raw\")      # Get raw markdown\n")
  cat("  putior_skills(output = \"clipboard\") # Copy to clipboard\n")
  cat("\n")
  cat("AVAILABLE TOPICS:\n")
  cat("  quick-start  - Essential 3 commands\n")
  cat("  syntax       - PUT annotation format\n")
  cat("  languages    - 30+ language comment prefixes\n")
  cat("  functions    - Core function reference\n")
  cat("  patterns     - Auto-detection patterns\n")
  cat("  examples     - Common usage patterns\n")
  cat("\n")
  cat("RAW FILE ACCESS:\n")
  cat("  system.file(\"SKILLS.md\", package = \"putior\")\n")
  cat("\n")
}
