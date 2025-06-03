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
#'   "name" (node IDs), "label" (descriptions), "both" (ID: label)
#' @param show_files Logical indicating whether to show file connections
#' @param show_artifacts Logical indicating whether to show data files as nodes.
#'   When TRUE, creates nodes for all input/output files, not just script connections.
#'   This provides a complete view of the data flow including terminal outputs.
#' @param style_nodes Logical indicating whether to apply styling based on node_type
#' @param theme Character string specifying color theme. Options:
#'   "light" (default), "dark", "auto" (GitHub adaptive), "minimal", "github"
#'
#' @return Character string containing the mermaid diagram code
#' @export
#'
#' @examples
#' \dontrun{
#' # Basic usage - shows only script connections
#' workflow <- put("./src/")
#' put_diagram(workflow)
#'
#' # Show all data artifacts as nodes (complete data flow)
#' put_diagram(workflow, show_artifacts = TRUE)
#'
#' # Show artifacts with file labels on connections
#' put_diagram(workflow, show_artifacts = TRUE, show_files = TRUE)
#'
#' # GitHub-optimized theme for README files
#' put_diagram(workflow, theme = "github")
#'
#' # Save to file with artifacts enabled
#' put_diagram(workflow, show_artifacts = TRUE, output = "file", file = "workflow.md")
#' }
put_diagram <- function(workflow,
                        output = "console",
                        file = "workflow_diagram.md",
                        title = NULL,
                        direction = "TD",
                        node_labels = "label",
                        show_files = FALSE,
                        show_artifacts = FALSE,
                        style_nodes = TRUE,
                        theme = "light") {
  # Input validation
  if (!is.data.frame(workflow) || nrow(workflow) == 0) {
    stop("workflow must be a non-empty data frame returned by put()")
  }

  required_cols <- c("id", "file_name")
  if (!all(required_cols %in% names(workflow))) {
    stop("workflow must contain 'id' and 'file_name' columns")
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
  workflow <- workflow[!is.na(workflow$id) & workflow$id != "", ]
  if (nrow(workflow) == 0) {
    stop("No valid workflow nodes found (all IDs are missing or empty)")
  }

  # Start building the mermaid diagram
  mermaid_lines <- character()

  # Add title if provided
  if (!is.null(title)) {
    mermaid_lines <- c(mermaid_lines, paste0("---\ntitle: ", title, "\n---"))
  }

  # Add flowchart declaration
  mermaid_lines <- c(mermaid_lines, paste0("flowchart ", direction))

  # Handle artifacts if requested
  if (show_artifacts) {
    # Create artifact nodes for data files
    artifact_nodes <- create_artifact_nodes(workflow)
    
    # Combine workflow with artifact nodes
    if (nrow(artifact_nodes) > 0) {
      # Add is_artifact column to original workflow if it doesn't exist
      if (!"is_artifact" %in% names(workflow)) {
        workflow$is_artifact <- FALSE
      }
      
      # Ensure both data frames have the same columns
      # Add missing columns to workflow
      missing_in_workflow <- setdiff(names(artifact_nodes), names(workflow))
      for (col in missing_in_workflow) {
        workflow[[col]] <- NA
      }
      
      # Add missing columns to artifact_nodes
      missing_in_artifacts <- setdiff(names(workflow), names(artifact_nodes))
      for (col in missing_in_artifacts) {
        artifact_nodes[[col]] <- NA
      }
      
      # Combine the data frames
      combined_workflow <- rbind(workflow, artifact_nodes)
    } else {
      combined_workflow <- workflow
      if (!"is_artifact" %in% names(combined_workflow)) {
        combined_workflow$is_artifact <- FALSE
      }
    }
  } else {
    combined_workflow <- workflow
  }

  # Generate node definitions
  node_definitions <- generate_node_definitions(combined_workflow, node_labels)
  mermaid_lines <- c(mermaid_lines, node_definitions)

  # Generate connections
  connections <- generate_connections(combined_workflow, show_files, show_artifacts)
  if (length(connections) > 0) {
    mermaid_lines <- c(mermaid_lines, "", "    %% Connections", connections)
  }

  # Add styling based on theme
  if (style_nodes && "node_type" %in% names(combined_workflow)) {
    styling <- generate_node_styling(combined_workflow, theme)
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
      node_ids <- sapply(nodes_of_type$id, sanitize_node_id)
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
      "decision" = "fill:#fff3e0,stroke:#e65100,stroke-width:2px,color:#000000",
      "artifact" = "fill:#f9f9f9,stroke:#666666,stroke-width:1px,color:#333333"
    ),
    "dark" = list(
      "input" = "fill:#1a237e,stroke:#3f51b5,stroke-width:2px,color:#ffffff",
      "process" = "fill:#4a148c,stroke:#9c27b0,stroke-width:2px,color:#ffffff",
      "output" = "fill:#1b5e20,stroke:#4caf50,stroke-width:2px,color:#ffffff",
      "decision" = "fill:#e65100,stroke:#ff9800,stroke-width:2px,color:#ffffff",
      "artifact" = "fill:#2d2d2d,stroke:#888888,stroke-width:1px,color:#ffffff"
    ),
    "auto" = list(
      # GitHub-compatible auto theme using solid colors that work in both modes
      "input" = "fill:#3b82f6,stroke:#1d4ed8,stroke-width:2px,color:#ffffff",
      "process" = "fill:#8b5cf6,stroke:#6d28d9,stroke-width:2px,color:#ffffff",
      "output" = "fill:#10b981,stroke:#047857,stroke-width:2px,color:#ffffff",
      "decision" = "fill:#f59e0b,stroke:#d97706,stroke-width:2px,color:#ffffff",
      "artifact" = "fill:#6b7280,stroke:#374151,stroke-width:1px,color:#ffffff"
    ),
    "minimal" = list(
      "input" = "fill:#f8fafc,stroke:#64748b,stroke-width:1px,color:#1e293b",
      "process" = "fill:#f1f5f9,stroke:#64748b,stroke-width:1px,color:#1e293b",
      "output" = "fill:#f8fafc,stroke:#64748b,stroke-width:1px,color:#1e293b",
      "decision" = "fill:#fef3c7,stroke:#92400e,stroke-width:1px,color:#1e293b",
      "artifact" = "fill:#e2e8f0,stroke:#94a3b8,stroke-width:1px,color:#475569"
    ),
    "github" = list(
      # Optimized specifically for GitHub README files with maximum compatibility
      "input" = "fill:#dbeafe,stroke:#2563eb,stroke-width:2px,color:#1e40af",
      "process" = "fill:#ede9fe,stroke:#7c3aed,stroke-width:2px,color:#5b21b6",
      "output" = "fill:#dcfce7,stroke:#16a34a,stroke-width:2px,color:#15803d",
      "decision" = "fill:#fef3c7,stroke:#d97706,stroke-width:2px,color:#92400e",
      "artifact" = "fill:#f3f4f6,stroke:#6b7280,stroke-width:1px,color:#374151"
    ),

    # Default to light theme
    list(
      "input" = "fill:#e1f5fe,stroke:#01579b,stroke-width:2px,color:#000000",
      "process" = "fill:#f3e5f5,stroke:#4a148c,stroke-width:2px,color:#000000",
      "output" = "fill:#e8f5e8,stroke:#1b5e20,stroke-width:2px,color:#000000",
      "decision" = "fill:#fff3e0,stroke:#e65100,stroke-width:2px,color:#000000",
      "artifact" = "fill:#f9f9f9,stroke:#666666,stroke-width:1px,color:#333333"
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
    node_id <- sanitize_node_id(node$id)

    # Determine node shape based on type
    node_shape <- get_node_shape(node$node_type)

    # Determine label text
    label_text <- switch(node_labels,
      "name" = node$id,
      "label" = if (!is.na(node$label) && node$label != "") node$label else node$id,
      "both" = if (!is.na(node$label) && node$label != "") {
        paste0(node$id, ": ", node$label)
      } else {
        node$id
      },
      # Default to label
      if (!is.na(node$label) && node$label != "") node$label else node$id
    )

    # Create node definition using character vector format
    node_def <- paste0("    ", node_id, node_shape[1], label_text, node_shape[2])
    node_defs <- c(node_defs, node_def)
  }

  return(node_defs)
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
    "artifact" = c("[(", ")]"), # Cylindrical shape for data files
    c("[", "]") # Default rectangle
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

#' Create artifact nodes for data files
#' @param workflow Workflow data frame
#' @return Data frame with artifact node definitions
#' @keywords internal
create_artifact_nodes <- function(workflow) {
  # Collect all unique input and output files
  all_inputs <- character()
  all_outputs <- character()
  
  for (i in 1:nrow(workflow)) {
    node <- workflow[i, ]
    
    # Process input files
    if (!is.na(node$input) && node$input != "") {
      input_files <- strsplit(trimws(node$input), ",")[[1]]
      input_files <- trimws(input_files)
      input_files <- input_files[input_files != ""]
      all_inputs <- c(all_inputs, input_files)
    }
    
    # Process output files
    if (!is.na(node$output) && node$output != "") {
      output_files <- strsplit(trimws(node$output), ",")[[1]]
      output_files <- trimws(output_files)
      output_files <- output_files[output_files != ""]
      all_outputs <- c(all_outputs, output_files)
    }
  }
  
  # Get unique files (input or output)
  all_files <- unique(c(all_inputs, all_outputs))
  
  # Remove script files (files that appear as file_name in workflow)
  script_files <- workflow$file_name
  data_files <- all_files[!all_files %in% script_files]
  
  if (length(data_files) == 0) {
    return(data.frame(
      id = character(),
      label = character(),
      node_type = character(),
      file_name = character(),
      is_artifact = logical(),
      stringsAsFactors = FALSE
    ))
  }
  
  # Create artifact node definitions
  artifact_nodes <- data.frame(
    id = paste0("artifact_", gsub("[^a-zA-Z0-9_]", "_", data_files)),
    label = data_files,
    node_type = "artifact",
    file_name = data_files,
    is_artifact = TRUE,
    stringsAsFactors = FALSE
  )
  
  return(artifact_nodes)
}

#' Generate connections between nodes
#' @param workflow Workflow data frame with combined script and artifact nodes
#' @param show_files Whether to show file-based connections
#' @param show_artifacts Whether artifacts are included in the workflow
#' @return Character vector of connection definitions
#' @keywords internal
generate_connections <- function(workflow, show_files = FALSE, show_artifacts = FALSE) {
  connections <- character()
  
  if (show_artifacts) {
    # With artifacts: create file-to-node and node-to-file connections
    
    # Get script nodes (non-artifacts)
    script_nodes <- workflow[is.na(workflow$is_artifact) | !workflow$is_artifact, ]
    
    for (i in 1:nrow(script_nodes)) {
      node <- script_nodes[i, ]
      target_id <- sanitize_node_id(node$id)
      
      # Input connections: artifact → script
      if (!is.na(node$input) && node$input != "") {
        input_files <- strsplit(trimws(node$input), ",")[[1]]
        input_files <- trimws(input_files[input_files != ""])
        
        for (input_file in input_files) {
          # Find the artifact node for this input file
          artifact_id <- paste0("artifact_", gsub("[^a-zA-Z0-9_]", "_", input_file))
          artifact_exists <- any(workflow$id == artifact_id, na.rm = TRUE)
          
          if (artifact_exists) {
            if (show_files) {
              connection <- paste0("    ", artifact_id, " -->|", input_file, "| ", target_id)
            } else {
              connection <- paste0("    ", artifact_id, " --> ", target_id)
            }
            connections <- c(connections, connection)
          }
        }
      }
      
      # Output connections: script → artifact
      if (!is.na(node$output) && node$output != "") {
        output_files <- strsplit(trimws(node$output), ",")[[1]]
        output_files <- trimws(output_files[output_files != ""])
        
        for (output_file in output_files) {
          # Find the artifact node for this output file
          artifact_id <- paste0("artifact_", gsub("[^a-zA-Z0-9_]", "_", output_file))
          artifact_exists <- any(workflow$id == artifact_id, na.rm = TRUE)
          
          if (artifact_exists) {
            if (show_files) {
              connection <- paste0("    ", target_id, " -->|", output_file, "| ", artifact_id)
            } else {
              connection <- paste0("    ", target_id, " --> ", artifact_id)
            }
            connections <- c(connections, connection)
          }
        }
      }
    }
    
  } else {
    # Without artifacts: original logic (script-to-script connections only)
    
    for (i in 1:nrow(workflow)) {
      node <- workflow[i, ]
      target_id <- sanitize_node_id(node$id)

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
                source_id <- sanitize_node_id(source_nodes[j, ]$id)

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
      # Include mermaid code blocks for console output
      cat("```mermaid\n")
      cat(mermaid_code)
      cat("\n```\n")
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
      # Use message() instead of cat() so expect_message() can catch it
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
      # Default to console with mermaid blocks
      cat("```mermaid\n")
      cat(mermaid_code)
      cat("\n```\n")
    }
  )
}

#' Split comma-separated file list
#' @param file_string Comma-separated file names
#' @return Character vector of individual file names
#' @export
split_file_list <- function(file_string) {
  if (is.na(file_string) || file_string == "" || is.null(file_string)) {
    return(character(0))
  }

  # Split on commas and clean whitespace
  files <- strsplit(as.character(file_string), ",")[[1]]
  files <- trimws(files)
  files <- files[files != ""]

  return(files)
}
