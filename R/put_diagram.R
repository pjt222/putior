#' Create Mermaid Diagram from PUT Workflow
#'
#' Generates a Mermaid flowchart diagram from putior workflow data, showing
#' the flow of data through your analysis pipeline.
#'
#' @param workflow Data frame returned by \code{\link{put}()} containing workflow nodes
#' @param output Character string specifying output format. Options:
#'   \itemize{
#'     \item "console" - Print to console (default)
#'     \item "file" - Save to file specified by \code{file} parameter
#'     \item "clipboard" - Copy to clipboard (if available)
#'   }
#' @param file Character string specifying output file path (used when output = "file")
#' @param title Character string for diagram title (optional)
#' @param direction Character string specifying diagram direction. Options:
#'   "TD" (top-down), "LR" (left-right), "BT" (bottom-top), "RL" (right-left)
#' @param node_labels Character string specifying what to show in nodes:
#'   "name" (node names), "label" (descriptions), "both" (name: label)
#' @param show_files Logical indicating whether to show file connections
#' @param style_nodes Logical indicating whether to apply styling based on node_type
#' @param theme Character string specifying color theme. Options:
#'   "light" (default), "dark", "auto" (GitHub adaptive), "minimal", "github"
#'
#' @return Character string containing the mermaid diagram code
#' @export
#'
#' @examples
#' \dontrun{
#' # Basic usage
#' workflow <- put("./src/")
#' put_diagram(workflow)
#'
#' # GitHub-optimized theme for README files
#' put_diagram(workflow, theme = "github")
#'
#' # Auto theme that adapts to GitHub's theme
#' put_diagram(workflow, theme = "auto")
#'
#' # Save to file with custom theme
#' put_diagram(workflow, output = "file", file = "workflow.md", theme = "dark")
#' }
put_diagram <- function(workflow,
                        output = "console",
                        file = "workflow_diagram.md",
                        title = NULL,
                        direction = "TD",
                        node_labels = "label",
                        show_files = FALSE,
                        style_nodes = TRUE,
                        theme = "light") {
  # Input validation
  if (!is.data.frame(workflow) || nrow(workflow) == 0) {
    stop("workflow must be a non-empty data frame returned by put()")
  }

  required_cols <- c("name", "file_name")
  if (!all(required_cols %in% names(workflow))) {
    stop("workflow must contain 'name' and 'file_name' columns")
  }

  # Validate theme
  valid_themes <- c("light", "dark", "auto", "minimal", "github")
  if (!theme %in% valid_themes) {
    warning(
      "Invalid theme '", theme, "'. Using 'light'. Valid themes: ",
      paste(valid_themes, collapse = ", ")
    )
    theme <- "light"
  }

  # Clean the workflow data
  workflow <- workflow[!is.na(workflow$name) & workflow$name != "", ]
  if (nrow(workflow) == 0) {
    stop("No valid workflow nodes found (all names are missing or empty)")
  }

  # Start building the mermaid diagram
  mermaid_lines <- character()

  # Add title if provided
  if (!is.null(title)) {
    mermaid_lines <- c(mermaid_lines, paste0("---\ntitle: ", title, "\n---"))
  }

  # Add flowchart declaration
  mermaid_lines <- c(mermaid_lines, paste0("flowchart ", direction))

  # Generate node definitions
  node_definitions <- generate_node_definitions(workflow, node_labels)
  mermaid_lines <- c(mermaid_lines, node_definitions)

  # Generate connections
  connections <- generate_connections(workflow, show_files)
  if (length(connections) > 0) {
    mermaid_lines <- c(mermaid_lines, "", "    %% Connections", connections)
  }

  # Add styling based on theme
  if (style_nodes && "node_type" %in% names(workflow)) {
    styling <- generate_node_styling(workflow, theme)
    if (length(styling) > 0) {
      mermaid_lines <- c(mermaid_lines, "", "    %% Styling", styling)
    }
  }

  # Combine into final diagram
  mermaid_code <- paste(mermaid_lines, collapse = "\n")

  # Handle output
  handle_output(mermaid_code, output, file, title)

  return(invisible(mermaid_code))
}

#' Generate node styling based on node types and theme
#' @param workflow Workflow data frame
#' @param theme Color theme ("light", "dark", "auto", "minimal", "github")
#' @return Character vector of styling definitions
#' @keywords internal
generate_node_styling <- function(workflow, theme = "light") {
  styling <- character()

  # Define color schemes for different themes
  color_schemes <- get_theme_colors(theme)

  # Group nodes by type and create styling
  for (node_type in names(color_schemes)) {
    nodes_of_type <- workflow[!is.na(workflow$node_type) & workflow$node_type == node_type, ]

    if (nrow(nodes_of_type) > 0) {
      node_ids <- sapply(nodes_of_type$name, sanitize_node_id)
      class_name <- paste0(node_type, "Style")

      # Create class definition
      style_def <- paste0("    classDef ", class_name, " ", color_schemes[[node_type]])

      # Apply class to each node individually to avoid line length issues
      class_applications <- sapply(node_ids, function(id) {
        paste0("    class ", id, " ", class_name)
      })

      styling <- c(styling, style_def, class_applications)
    }
  }

  return(styling)
}

#' Get color schemes for different themes (FIXED VERSION)
#' @param theme Theme name
#' @return Named list of color definitions for each node type
#' @keywords internal
get_theme_colors <- function(theme) {
  switch(theme,
    "light" = list(
      "input" = "fill:#e1f5fe,stroke:#01579b,stroke-width:2px,color:#000000",
      "process" = "fill:#f3e5f5,stroke:#4a148c,stroke-width:2px,color:#000000",
      "output" = "fill:#e8f5e8,stroke:#1b5e20,stroke-width:2px,color:#000000",
      "decision" = "fill:#fff3e0,stroke:#e65100,stroke-width:2px,color:#000000"
    ),
    "dark" = list(
      "input" = "fill:#1a237e,stroke:#3f51b5,stroke-width:2px,color:#ffffff",
      "process" = "fill:#4a148c,stroke:#9c27b0,stroke-width:2px,color:#ffffff",
      "output" = "fill:#1b5e20,stroke:#4caf50,stroke-width:2px,color:#ffffff",
      "decision" = "fill:#e65100,stroke:#ff9800,stroke-width:2px,color:#ffffff"
    ),
    "auto" = list(
      # GitHub-compatible auto theme using solid colors that work in both modes
      "input" = "fill:#3b82f6,stroke:#1d4ed8,stroke-width:2px,color:#ffffff",
      "process" = "fill:#8b5cf6,stroke:#6d28d9,stroke-width:2px,color:#ffffff",
      "output" = "fill:#10b981,stroke:#047857,stroke-width:2px,color:#ffffff",
      "decision" = "fill:#f59e0b,stroke:#d97706,stroke-width:2px,color:#ffffff"
    ),
    "minimal" = list(
      "input" = "fill:#f8fafc,stroke:#64748b,stroke-width:1px,color:#1e293b",
      "process" = "fill:#f1f5f9,stroke:#64748b,stroke-width:1px,color:#1e293b",
      "output" = "fill:#f8fafc,stroke:#64748b,stroke-width:1px,color:#1e293b",
      "decision" = "fill:#fef3c7,stroke:#92400e,stroke-width:1px,color:#1e293b"
    ),
    "github" = list(
      # Optimized specifically for GitHub README files with maximum compatibility
      "input" = "fill:#dbeafe,stroke:#2563eb,stroke-width:2px,color:#1e40af",
      "process" = "fill:#ede9fe,stroke:#7c3aed,stroke-width:2px,color:#5b21b6",
      "output" = "fill:#dcfce7,stroke:#16a34a,stroke-width:2px,color:#15803d",
      "decision" = "fill:#fef3c7,stroke:#d97706,stroke-width:2px,color:#92400e"
    ),

    # Default to light theme
    list(
      "input" = "fill:#e1f5fe,stroke:#01579b,stroke-width:2px,color:#000000",
      "process" = "fill:#f3e5f5,stroke:#4a148c,stroke-width:2px,color:#000000",
      "output" = "fill:#e8f5e8,stroke:#1b5e20,stroke-width:2px,color:#000000",
      "decision" = "fill:#fff3e0,stroke:#e65100,stroke-width:2px,color:#000000"
    )
  )
}

#' Get available themes for put_diagram
#'
#' Returns information about available color themes for workflow diagrams.
#'
#' @return Named list describing available themes
#' @export
#'
#' @examples
#' # See available themes
#' get_diagram_themes()
#'
#' \dontrun{
#' # Use a specific theme (requires actual workflow data)
#' workflow <- put("./src")
#' put_diagram(workflow, theme = "github")
#' }
get_diagram_themes <- function() {
  list(
    "light" = "Default light theme with bright colors - perfect for documentation sites",
    "dark" = "Dark theme with muted colors - ideal for dark mode environments and terminals",
    "auto" = "GitHub-adaptive theme with solid colors that work in both light and dark modes",
    "minimal" = "Grayscale professional theme - print-friendly and great for business documents",
    "github" = "Optimized specifically for GitHub README files with maximum mermaid compatibility"
  )
}

#' Generate node definitions for mermaid diagram
#' @param workflow Workflow data frame
#' @param node_labels What to show in node labels
#' @return Character vector of node definitions
#' @keywords internal
generate_node_definitions <- function(workflow, node_labels = "label") {
  node_defs <- character()

  for (i in 1:nrow(workflow)) {
    node <- workflow[i, ]
    node_id <- sanitize_node_id(node$name)

    # Determine node shape based on type
    node_shape <- get_node_shape(node$node_type)

    # Determine label text
    label_text <- switch(node_labels,
      "name" = node$name,
      "label" = if (!is.na(node$label) && node$label != "") node$label else node$name,
      "both" = if (!is.na(node$label) && node$label != "") {
        paste0(node$name, ": ", node$label)
      } else {
        node$name
      },
      # Default to label
      if (!is.na(node$label) && node$label != "") node$label else node$name
    )

    # Create node definition
    node_def <- paste0("    ", node_id, node_shape$start, label_text, node_shape$end)
    node_defs <- c(node_defs, node_def)
  }

  return(node_defs)
}

#' Get node shape based on type
#' @param node_type Type of node
#' @return List with start and end shape markers
#' @keywords internal
get_node_shape <- function(node_type) {
  if (is.na(node_type)) {
    node_type <- "process"
  }

  switch(node_type,
    "input" = list(start = "([", end = "])"),
    "output" = list(start = "[[", end = "]]"),
    "decision" = list(start = "{", end = "}"),
    "process" = list(start = "[", end = "]"),
    # Default to process
    list(start = "[", end = "]")
  )
}

#' Sanitize node ID for mermaid compatibility (IMPROVED VERSION)
#' @param node_id Raw node identifier
#' @return Sanitized identifier safe for mermaid
#' @keywords internal
sanitize_node_id <- function(node_id) {
  if (is.na(node_id) || node_id == "") {
    return("unknown_node")
  }

  # Replace any non-alphanumeric characters with underscores
  sanitized <- gsub("[^a-zA-Z0-9_]", "_", as.character(node_id))

  # Ensure it starts with a letter or underscore
  if (grepl("^[0-9]", sanitized)) {
    sanitized <- paste0("node_", sanitized)
  }

  # Remove multiple consecutive underscores
  sanitized <- gsub("_{2,}", "_", sanitized)

  # Remove trailing underscores
  sanitized <- gsub("_+$", "", sanitized)

  # Ensure it's not empty after cleaning
  if (sanitized == "" || sanitized == "_") {
    sanitized <- "unnamed_node"
  }

  return(sanitized)
}

#' Generate connections between nodes
#' @param workflow Workflow data frame
#' @param show_files Whether to show file-based connections
#' @return Character vector of connection definitions
#' @keywords internal
generate_connections <- function(workflow, show_files = FALSE) {
  connections <- character()

  for (i in 1:nrow(workflow)) {
    node <- workflow[i, ]
    target_id <- sanitize_node_id(node$name)

    if (!is.na(node$input) && node$input != "") {
      input_files <- strsplit(trimws(node$input), ",")[[1]]
      input_files <- trimws(input_files)

      for (input_file in input_files) {
        if (input_file != "") {
          # Find nodes that output this file
          source_nodes <- workflow[
            !is.na(workflow$output) &
              sapply(workflow$output, function(x) {
                if (is.na(x) || x == "") {
                  return(FALSE)
                }
                output_files <- strsplit(trimws(x), ",")[[1]]
                output_files <- trimws(output_files)
                input_file %in% output_files
              }),
          ]

          if (nrow(source_nodes) > 0) {
            for (j in 1:nrow(source_nodes)) {
              source_id <- sanitize_node_id(source_nodes[j, ]$name)

              # Create connection with optional file label
              if (show_files && input_file != "") {
                connection <- paste0("    ", source_id, " -->|", input_file, "| ", target_id)
              } else {
                connection <- paste0("    ", source_id, " --> ", target_id)
              }

              connections <- c(connections, connection)
            }
          }
        }
      }
    }
  }

  # Remove duplicate connections
  connections <- unique(connections)
  return(connections)
}

#' Handle diagram output to different destinations
#' @param mermaid_code Generated mermaid code
#' @param output Output format
#' @param file File path for file output
#' @param title Diagram title
#' @keywords internal
handle_output <- function(mermaid_code, output = "console", file = NULL, title = NULL) {
  switch(output,
    "console" = {
      cat(mermaid_code, "\n")
    },
    "file" = {
      if (is.null(file)) {
        file <- "workflow_diagram.md"
      }

      # Create markdown file with mermaid code block
      md_content <- c(
        if (!is.null(title)) paste0("# ", title, "\n") else "",
        "```mermaid",
        mermaid_code,
        "```"
      )

      writeLines(md_content, file)
      cat("Diagram saved to:", file, "\n")
    },
    "clipboard" = {
      if (requireNamespace("clipr", quietly = TRUE)) {
        clipr::write_clip(mermaid_code)
        cat("Diagram copied to clipboard\n")
      } else {
        warning("clipr package not available. Install with: install.packages('clipr')")
        cat(mermaid_code, "\n")
      }
    },
    {
      # Default to console
      cat(mermaid_code, "\n")
    }
  )
}
