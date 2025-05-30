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
#' # Save to file
#' put_diagram(workflow, output = "file", file = "workflow.md")
#'
#' # Horizontal layout with custom title
#' put_diagram(workflow, direction = "LR", title = "Data Pipeline")
#'
#' # Show detailed labels
#' put_diagram(workflow, node_labels = "both", show_files = TRUE)
#' }
put_diagram <- function(workflow,
                        output = "console",
                        file = "workflow_diagram.md",
                        title = NULL,
                        direction = "TD",
                        node_labels = "label",
                        show_files = FALSE,
                        style_nodes = TRUE) {
  # Input validation
  if (!is.data.frame(workflow) || nrow(workflow) == 0) {
    stop("workflow must be a non-empty data frame returned by put()")
  }

  required_cols <- c("name", "file_name")
  if (!all(required_cols %in% names(workflow))) {
    stop("workflow must contain 'name' and 'file_name' columns")
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

  # Add styling
  if (style_nodes && "node_type" %in% names(workflow)) {
    styling <- generate_node_styling(workflow)
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

#' Generate node definitions for mermaid diagram
#' @param workflow Workflow data frame
#' @param node_labels What to show in node labels
#' @return Character vector of node definitions
#' @keywords internal
generate_node_definitions <- function(workflow, node_labels) {
  definitions <- character()

  for (i in seq_len(nrow(workflow))) {
    row <- workflow[i, ]
    node_id <- sanitize_node_id(row$name)

    # Determine node label
    node_label <- switch(node_labels,
      "name" = row$name,
      "label" = if ("label" %in% names(row) && !is.na(row$label) && row$label != "") row$label else row$name,
      "both" = if ("label" %in% names(row) && !is.na(row$label) && row$label != "") {
        paste0(row$name, ": ", row$label)
      } else {
        row$name
      },
      row$name # fallback
    )

    # Determine node shape based on node_type (handle missing column)
    node_type_value <- if ("node_type" %in% names(row)) row$node_type else NA
    shape <- get_node_shape(node_type_value)
    node_def <- paste0("    ", node_id, shape[1], node_label, shape[2])

    definitions <- c(definitions, node_def)
  }

  return(definitions)
}

#' Generate connections between nodes based on file flow
#' @param workflow Workflow data frame
#' @param show_files Whether to show file names on connections
#' @return Character vector of connection definitions
#' @keywords internal
generate_connections <- function(workflow, show_files) {
  connections <- character()

  # Check if input/output columns exist
  if (!"input" %in% names(workflow) && !"output" %in% names(workflow)) {
    return(connections) # No file flow information available
  }

  # Create mapping of files to nodes
  file_producers <- list()
  file_consumers <- list()

  # Build file mappings
  for (i in seq_len(nrow(workflow))) {
    row <- workflow[i, ]
    node_id <- sanitize_node_id(row$name)

    # Track outputs
    if ("output" %in% names(row) && !is.na(row$output) && row$output != "") {
      outputs <- split_file_list(row$output)
      for (output_file in outputs) {
        file_producers[[output_file]] <- node_id
      }
    }

    # Track inputs
    if ("input" %in% names(row) && !is.na(row$input) && row$input != "") {
      inputs <- split_file_list(row$input)
      for (input_file in inputs) {
        if (!input_file %in% names(file_consumers)) {
          file_consumers[[input_file]] <- character()
        }
        file_consumers[[input_file]] <- c(file_consumers[[input_file]], node_id)
      }
    }
  }

  # Generate connections
  for (file_name in names(file_consumers)) {
    if (file_name %in% names(file_producers)) {
      producer <- file_producers[[file_name]]
      consumers <- file_consumers[[file_name]]

      for (consumer in consumers) {
        if (show_files) {
          connection <- paste0("    ", producer, " -->|", file_name, "| ", consumer)
        } else {
          connection <- paste0("    ", producer, " --> ", consumer)
        }
        connections <- c(connections, connection)
      }
    }
  }

  return(connections)
}

#' Generate node styling based on node types
#' @param workflow Workflow data frame
#' @return Character vector of styling definitions
#' @keywords internal
generate_node_styling <- function(workflow) {
  styling <- character()

  # Define colors for different node types
  type_colors <- list(
    "input" = "fill:#e1f5fe,stroke:#01579b,stroke-width:2px",
    "process" = "fill:#f3e5f5,stroke:#4a148c,stroke-width:2px",
    "output" = "fill:#e8f5e8,stroke:#1b5e20,stroke-width:2px",
    "decision" = "fill:#fff3e0,stroke:#e65100,stroke-width:2px"
  )

  # Group nodes by type
  for (node_type in names(type_colors)) {
    nodes_of_type <- workflow[!is.na(workflow$node_type) & workflow$node_type == node_type, ]

    if (nrow(nodes_of_type) > 0) {
      node_ids <- sapply(nodes_of_type$name, sanitize_node_id)
      class_name <- paste0("class ", paste(node_ids, collapse = ","), " ", node_type, "Style")
      style_def <- paste0("    classDef ", node_type, "Style ", type_colors[[node_type]])

      styling <- c(styling, style_def, paste0("    ", class_name))
    }
  }

  return(styling)
}

#' Get node shape characters based on node type
#' @param node_type Node type string
#' @return Character vector with opening and closing shape characters
#' @keywords internal
get_node_shape <- function(node_type) {
  # Handle NULL, NA, or missing values
  if (is.null(node_type) || length(node_type) == 0 || is.na(node_type)) {
    return(c("[", "]")) # Default rectangle
  }

  switch(as.character(node_type),
    "input" = c("([", "])"), # Stadium shape for inputs
    "process" = c("[", "]"), # Rectangle for processes
    "output" = c("[[", "]]"), # Subroutine shape for outputs
    "decision" = c("{", "}"), # Diamond for decisions
    "start" = c("([", "])"), # Stadium for start
    "end" = c("([", "])"), # Stadium for end
    c("[", "]") # Default rectangle
  )
}

#' Sanitize node ID for mermaid compatibility
#' @param name Node name
#' @return Sanitized node ID
#' @keywords internal
sanitize_node_id <- function(name) {
  # Replace problematic characters with underscores
  sanitized <- gsub("[^a-zA-Z0-9_]", "_", name)

  # Ensure it starts with a letter
  if (!grepl("^[a-zA-Z]", sanitized)) {
    sanitized <- paste0("node_", sanitized)
  }

  return(sanitized)
}

#' Split comma-separated file list
#' @param file_string Comma-separated file names
#' @return Character vector of individual file names
#' @keywords internal
split_file_list <- function(file_string) {
  if (is.na(file_string) || file_string == "") {
    return(character(0))
  }

  # Split on commas and clean whitespace
  files <- strsplit(file_string, ",")[[1]]
  files <- trimws(files)
  files <- files[files != ""]

  return(files)
}

#' Handle output of mermaid diagram
#' @param mermaid_code Generated mermaid code
#' @param output Output method
#' @param file File path for file output
#' @param title Diagram title
#' @keywords internal
handle_output <- function(mermaid_code, output, file, title) {
  switch(output,
    "console" = {
      cat("```mermaid\n")
      cat(mermaid_code)
      cat("\n```\n")
    },
    "file" = {
      # Create markdown file with mermaid code block
      if (!is.null(title)) {
        content <- paste0("# ", title, "\n\n```mermaid\n", mermaid_code, "\n```\n")
      } else {
        content <- paste0("```mermaid\n", mermaid_code, "\n```\n")
      }

      writeLines(content, file)
      message("Diagram saved to: ", file)
    },
    "clipboard" = {
      if (requireNamespace("clipr", quietly = TRUE)) {
        clipr::write_clip(paste0("```mermaid\n", mermaid_code, "\n```"))
        message("Diagram copied to clipboard")
      } else {
        warning("clipr package not available. Install with: install.packages('clipr')")
        cat("```mermaid\n")
        cat(mermaid_code)
        cat("\n```\n")
      }
    },
    {
      # Default to console
      cat("```mermaid\n")
      cat(mermaid_code)
      cat("\n```\n")
    }
  )
}
