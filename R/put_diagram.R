# put id:"diagram_gen", label:"Generate Mermaid Diagram", node_type:"process", input:"workflow_data.rds", output:"diagram.md"
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
#'     \item "raw" - Return raw mermaid code without markdown fences (for knitr/pkgdown)
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
#' @param show_workflow_boundaries Logical indicating whether to apply special styling
#'   to nodes with node_type "start" and "end". When TRUE, these nodes get distinctive
#'   workflow boundary styling (icons, colors). When FALSE, they render as regular nodes.
#' @param style_nodes Logical indicating whether to apply styling based on node_type
#' @param theme Character string specifying color theme. Options:
#'   \itemize{
#'     \item "light" - Default light theme with bright colors (default)
#'     \item "dark" - Dark theme for dark mode environments
#'     \item "auto" - GitHub-adaptive with solid colors for both modes
#'     \item "minimal" - Grayscale professional, print-friendly
#'     \item "github" - Optimized for GitHub README files
#'     \item "viridis" - Colorblind-safe (purple-blue-green-yellow)
#'     \item "magma" - Colorblind-safe warm (purple-red-yellow)
#'     \item "plasma" - Colorblind-safe vibrant (purple-pink-yellow)
#'     \item "cividis" - Colorblind-safe for deuteranopia/protanopia (blue-yellow)
#'   }
#'   The viridis family themes are perceptually uniform and tested for accessibility.
#' @param show_source_info Logical indicating whether to display source file
#'   information in diagram nodes. When TRUE, each node shows its originating
#'   file name. Default is FALSE for backward compatibility.
#' @param source_info_style Character string specifying how to display source info:
#'   \itemize{
#'     \item "inline" - Append file name to node labels (default)
#'     \item "subgraph" - Group nodes by source file into Mermaid subgraphs
#'   }
#' @param enable_clicks Logical indicating whether to add click directives to nodes.
#'   When TRUE, nodes become clickable links that open the source file in an editor.
#'   Default is FALSE for backward compatibility.
#' @param click_protocol Character string specifying the URL protocol for clickable nodes:
#'   \itemize{
#'     \item "vscode" - VS Code editor (vscode://file/path:line) (default)
#'     \item "file" - Standard file:// protocol
#'     \item "rstudio" - RStudio IDE (rstudio://open-file?path=)
#'   }
#' @param log_level Character string specifying log verbosity for this call.
#'   Overrides the global option \code{putior.log_level} when specified.
#'   Options: "DEBUG", "INFO", "WARN", "ERROR". See \code{\link{set_putior_log_level}}.
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
#' # Show workflow boundaries with special start/end styling
#' put_diagram(workflow, show_workflow_boundaries = TRUE)
#'
#' # Disable workflow boundaries (start/end nodes render as regular)
#' put_diagram(workflow, show_workflow_boundaries = FALSE)
#'
#' # GitHub-optimized theme for README files
#' put_diagram(workflow, theme = "github")
#'
#' # Save to file with artifacts enabled
#' put_diagram(workflow, show_artifacts = TRUE, output = "file", file = "workflow.md")
#'
#' # For use in knitr/pkgdown - returns raw mermaid code
#' # Use within a code chunk with results='asis'
#' cat("```mermaid\n", put_diagram(workflow, output = "raw"), "\n```\n")
#'
#' # Show source file info inline in nodes
#' put_diagram(workflow, show_source_info = TRUE)
#'
#' # Group nodes by source file using subgraphs
#' put_diagram(workflow, show_source_info = TRUE, source_info_style = "subgraph")
#'
#' # Enable clickable nodes (opens in VS Code)
#' put_diagram(workflow, enable_clicks = TRUE)
#'
#' # Enable clickable nodes with RStudio protocol
#' put_diagram(workflow, enable_clicks = TRUE, click_protocol = "rstudio")
#' }
put_diagram <- function(workflow,
                        output = "console",
                        file = "workflow_diagram.md",
                        title = NULL,
                        direction = "TD",
                        node_labels = "label",
                        show_files = FALSE,
                        show_artifacts = FALSE,
                        show_workflow_boundaries = TRUE,
                        style_nodes = TRUE,
                        theme = "light",
                        show_source_info = FALSE,
                        source_info_style = "inline",
                        enable_clicks = FALSE,
                        click_protocol = "vscode",
                        log_level = NULL) {
  # Set log level for this call if specified
  restore_log_level <- with_log_level(log_level)
  on.exit(restore_log_level(), add = TRUE)

  putior_log("INFO", "Starting diagram generation")
  putior_log("DEBUG", "Diagram parameters: direction='{direction}', theme='{theme}', show_artifacts={show_artifacts}")


  # Input validation
  if (!is.data.frame(workflow)) {
    stop(
      "workflow must be a data frame returned by put() or put_auto().\n",
      "Received: ", class(workflow)[1], "\n",
      "Example usage:\n",
      "  workflow <- put(\"./src/\")\n",
      "  put_diagram(workflow)",
      call. = FALSE
    )
  }

  if (nrow(workflow) == 0) {
    stop(
      "workflow is empty (0 rows).\n",
      "No PUT annotations were found. Please check that:\n",
      "- Your source files contain PUT annotations\n",
      "- The file pattern matches your source files\n",
      "- The correct comment prefix is used for your language\n",
      "See putior_help(\"annotation\") for annotation syntax.",
      call. = FALSE
    )
  }

  required_cols <- c("id", "file_name")
  missing_cols <- required_cols[!required_cols %in% names(workflow)]
  if (length(missing_cols) > 0) {
    stop(
      "workflow is missing required column(s): ", paste(missing_cols, collapse = ", "), "\n",
      "Expected columns: ", paste(required_cols, collapse = ", "), "\n",
      "This typically means the data frame was not created by put() or put_auto().\n",
      "Example:\n",
      "  workflow <- put(\"./src/\")\n",
      "  put_diagram(workflow)",
      call. = FALSE
    )
  }

  # Validate theme
  if (!theme %in% .VALID_THEMES) {
    warning(
      "Invalid theme '", theme, "'. Using 'light'.\n",
      "Valid themes: ", paste(.VALID_THEMES, collapse = ", "), "\n",
      "See putior_help(\"themes\") or get_diagram_themes() for descriptions.",
      call. = FALSE
    )
    theme <- "light"
  }

  # Validate source_info_style
  valid_styles <- c("inline", "subgraph")
  if (!source_info_style %in% valid_styles) {
    warning(
      "Invalid source_info_style '", source_info_style, "'. Using 'inline'.\n",
      "Valid styles: ", paste(valid_styles, collapse = ", "), "\n",
      "- inline: Append file name to node labels\n",
      "- subgraph: Group nodes by source file",
      call. = FALSE
    )
    source_info_style <- "inline"
  }

  # Validate click_protocol
  valid_protocols <- c("vscode", "file", "rstudio")
  if (enable_clicks && !click_protocol %in% valid_protocols) {
    warning(
      "Invalid click_protocol '", click_protocol, "'. Using 'vscode'.\n",
      "Valid protocols: ", paste(valid_protocols, collapse = ", "), "\n",
      "- vscode: VS Code editor (vscode://file/path:line)\n",
      "- file: Standard file:// protocol\n",
      "- rstudio: RStudio IDE (rstudio://open-file?path=)",
      call. = FALSE
    )
    click_protocol <- "vscode"
  }

  # Clean the workflow data
  workflow <- workflow[!is.na(workflow$id) & workflow$id != "", ]
  if (nrow(workflow) == 0) {
    stop(
      "No valid workflow nodes found (all IDs are missing or empty).\n",
      "This can happen if:\n",
      "- PUT annotations don't include 'id' properties and uuid package is not installed\n",
      "- The annotation syntax is incorrect\n",
      "Solution: Either add explicit IDs to your annotations:\n",
      "  # put id:\"my_node\", label:\"Description\"\n",
      "Or install the uuid package for auto-generation:\n",
      "  install.packages(\"uuid\")\n",
      "See putior_help(\"annotation\") for syntax details.",
      call. = FALSE
    )
  }

  putior_log("DEBUG", "Processing {nrow(workflow)} workflow node(s)")

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
    putior_log("DEBUG", "Creating artifact nodes for data files")
    # Create artifact nodes for data files
    artifact_nodes <- create_artifact_nodes(workflow)

    # Combine workflow with artifact nodes
    if (nrow(artifact_nodes) > 0) {
      putior_log("DEBUG", "Created {nrow(artifact_nodes)} artifact node(s)")
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

  # Generate node definitions (use subgraphs if requested)
  putior_log("DEBUG", "Generating node definitions")
  if (show_source_info && source_info_style == "subgraph") {
    node_definitions <- generate_file_subgraphs(
      combined_workflow, node_labels, show_workflow_boundaries
    )
  } else {
    # Use inline source info if show_source_info is TRUE
    node_definitions <- generate_node_definitions(
      combined_workflow, node_labels, show_workflow_boundaries,
      show_source_info = show_source_info && source_info_style == "inline"
    )
  }
  mermaid_lines <- c(mermaid_lines, node_definitions)
  putior_log("DEBUG", "Created {length(node_definitions)} node definition line(s)")

  # Generate connections
  putior_log("DEBUG", "Generating connections between nodes")
  connections <- generate_connections(combined_workflow, show_files, show_artifacts)
  if (length(connections) > 0) {
    mermaid_lines <- c(mermaid_lines, "", "    %% Connections", connections)
    putior_log("DEBUG", "Created {length(connections)} connection(s)")
  }

  # Add styling based on theme
  if (style_nodes && "node_type" %in% names(combined_workflow)) {
    putior_log("DEBUG", "Applying '{theme}' theme styling")
    styling <- generate_node_styling(combined_workflow, theme, show_workflow_boundaries)
    if (length(styling) > 0) {
      mermaid_lines <- c(mermaid_lines, "", "    %% Styling", styling)
    }
  }

  # Add click directives if enabled
  if (enable_clicks) {
    click_lines <- generate_click_directives(combined_workflow, click_protocol)
    if (length(click_lines) > 0) {
      mermaid_lines <- c(mermaid_lines, "", "    %% Click Actions", click_lines)
    }
  }

  # Combine into final diagram
  mermaid_code <- paste(mermaid_lines, collapse = "\n")

  putior_log("INFO", "Diagram generation complete: {nrow(combined_workflow)} node(s), {length(connections)} connection(s)")
  putior_log("DEBUG", "Output format: '{output}'")

  # Handle output
  handle_output(mermaid_code, output, file, title)

  return(invisible(mermaid_code))
}

# put id:"styling", label:"Apply Theme Styling", node_type:"process", input:"nodes.rds", output:"styled_nodes.rds"
#' Generate node styling based on node types and theme
#' @param workflow Workflow data frame
#' @param theme Color theme ("light", "dark", "auto", "minimal", "github")
#' @return Character vector of styling definitions
#' @keywords internal
generate_node_styling <- function(workflow, theme = "light", show_workflow_boundaries = TRUE) {
  styling <- character()

  # Define color schemes for different themes
  color_schemes <- get_theme_colors(theme)

  # Group nodes by type and create styling
  for (node_type in names(color_schemes)) {
    # Skip start/end styling if workflow boundaries are disabled
    if (!show_workflow_boundaries && node_type %in% c("start", "end")) {
      next
    }
    
    nodes_of_type <- workflow[!is.na(workflow$node_type) & workflow$node_type == node_type, ]

    if (nrow(nodes_of_type) > 0) {
      node_ids <- vapply(nodes_of_type$id, sanitize_node_id, character(1))
      class_name <- paste0(node_type, "Style")

      # Create class definition
      style_def <- paste0("    classDef ", class_name, " ", color_schemes[[node_type]])

      # Apply class to each node individually to avoid line length issues
      class_applications <- vapply(node_ids, function(id) {
        paste0("    class ", id, " ", class_name)
      }, character(1))

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
      "artifact" = "fill:#f9f9f9,stroke:#666666,stroke-width:1px,color:#333333",
      "start" = "fill:#fff3e0,stroke:#f57c00,stroke-width:3px,color:#e65100",
      "end" = "fill:#e8f5e8,stroke:#2e7d32,stroke-width:3px,color:#1b5e20"
    ),
    "dark" = list(
      "input" = "fill:#1a237e,stroke:#3f51b5,stroke-width:2px,color:#ffffff",
      "process" = "fill:#4a148c,stroke:#9c27b0,stroke-width:2px,color:#ffffff",
      "output" = "fill:#1b5e20,stroke:#4caf50,stroke-width:2px,color:#ffffff",
      "decision" = "fill:#e65100,stroke:#ff9800,stroke-width:2px,color:#ffffff",
      "artifact" = "fill:#2d2d2d,stroke:#888888,stroke-width:1px,color:#ffffff",
      "start" = "fill:#ff6f00,stroke:#ff9800,stroke-width:3px,color:#ffffff",
      "end" = "fill:#2e7d32,stroke:#4caf50,stroke-width:3px,color:#ffffff"
    ),
    "auto" = list(
      # GitHub-compatible auto theme using solid colors that work in both modes
      "input" = "fill:#3b82f6,stroke:#1d4ed8,stroke-width:2px,color:#ffffff",
      "process" = "fill:#8b5cf6,stroke:#6d28d9,stroke-width:2px,color:#ffffff",
      "output" = "fill:#10b981,stroke:#047857,stroke-width:2px,color:#ffffff",
      "decision" = "fill:#f59e0b,stroke:#d97706,stroke-width:2px,color:#ffffff",
      "artifact" = "fill:#6b7280,stroke:#374151,stroke-width:1px,color:#ffffff",
      "start" = "fill:#f59e0b,stroke:#d97706,stroke-width:3px,color:#ffffff",
      "end" = "fill:#10b981,stroke:#047857,stroke-width:3px,color:#ffffff"
    ),
    "minimal" = list(
      "input" = "fill:#f8fafc,stroke:#64748b,stroke-width:1px,color:#1e293b",
      "process" = "fill:#f1f5f9,stroke:#64748b,stroke-width:1px,color:#1e293b",
      "output" = "fill:#f8fafc,stroke:#64748b,stroke-width:1px,color:#1e293b",
      "decision" = "fill:#fef3c7,stroke:#92400e,stroke-width:1px,color:#1e293b",
      "artifact" = "fill:#e2e8f0,stroke:#94a3b8,stroke-width:1px,color:#475569",
      "start" = "fill:#fef3c7,stroke:#d97706,stroke-width:2px,color:#92400e",
      "end" = "fill:#dcfce7,stroke:#15803d,stroke-width:2px,color:#14532d"
    ),
    "github" = list(
      # Optimized specifically for GitHub README files with maximum compatibility
      "input" = "fill:#dbeafe,stroke:#2563eb,stroke-width:2px,color:#1e40af",
      "process" = "fill:#ede9fe,stroke:#7c3aed,stroke-width:2px,color:#5b21b6",
      "output" = "fill:#dcfce7,stroke:#16a34a,stroke-width:2px,color:#15803d",
      "decision" = "fill:#fef3c7,stroke:#d97706,stroke-width:2px,color:#92400e",
      "artifact" = "fill:#f3f4f6,stroke:#6b7280,stroke-width:1px,color:#374151",
      "start" = "fill:#fef3c7,stroke:#d97706,stroke-width:3px,color:#92400e",
      "end" = "fill:#dcfce7,stroke:#16a34a,stroke-width:3px,color:#15803d"
    ),

    # VIRIDIS FAMILY - Colorblind-safe, perceptually uniform palettes
    # All tested for deuteranopia, protanopia, tritanopia, and grayscale

    "viridis" = list(
      # Classic colorblind-safe palette (purple -> blue -> green -> yellow)
      # Most widely tested and validated for accessibility
      "input" = "fill:#440154,stroke:#31688e,stroke-width:2px,color:#ffffff",
      "process" = "fill:#31688e,stroke:#21918c,stroke-width:2px,color:#ffffff",
      "output" = "fill:#35b779,stroke:#21918c,stroke-width:2px,color:#000000",
      "decision" = "fill:#fde725,stroke:#90d743,stroke-width:2px,color:#000000",
      "artifact" = "fill:#e8e8e8,stroke:#757575,stroke-width:1px,color:#333333",
      "start" = "fill:#b5de2b,stroke:#90d743,stroke-width:3px,color:#000000",
      "end" = "fill:#35b779,stroke:#21918c,stroke-width:3px,color:#000000"
    ),

    "magma" = list(
      # Warm colorblind-safe palette (black -> purple -> red -> yellow)
      # High contrast, excellent for print and presentations
      "input" = "fill:#3b0f70,stroke:#8c2981,stroke-width:2px,color:#ffffff",
      "process" = "fill:#b63679,stroke:#de4968,stroke-width:2px,color:#ffffff",
      "output" = "fill:#fe9f6d,stroke:#fcfdbf,stroke-width:2px,color:#000000",
      "decision" = "fill:#fcfdbf,stroke:#feb078,stroke-width:2px,color:#000000",
      "artifact" = "fill:#e8e8e8,stroke:#757575,stroke-width:1px,color:#333333",
      "start" = "fill:#feb078,stroke:#fe9f6d,stroke-width:3px,color:#000000",
      "end" = "fill:#fe9f6d,stroke:#de4968,stroke-width:3px,color:#000000"
    ),

    "plasma" = list(
      # Vibrant colorblind-safe palette (purple -> pink -> orange -> yellow)
      # Bold colors ideal for presentations and digital displays
      "input" = "fill:#0d0887,stroke:#5302a3,stroke-width:2px,color:#ffffff",
      "process" = "fill:#7e03a8,stroke:#b83289,stroke-width:2px,color:#ffffff",
      "output" = "fill:#f89540,stroke:#fdca26,stroke-width:2px,color:#000000",
      "decision" = "fill:#f0f921,stroke:#fdca26,stroke-width:2px,color:#000000",
      "artifact" = "fill:#e8e8e8,stroke:#757575,stroke-width:1px,color:#333333",
      "start" = "fill:#fdca26,stroke:#f89540,stroke-width:3px,color:#000000",
      "end" = "fill:#f89540,stroke:#cc4778,stroke-width:3px,color:#000000"
    ),

    "cividis" = list(
      # Optimized specifically for deuteranopia and protanopia (blue -> gray -> yellow)
      # Maximum colorblind safety with blue-yellow only palette
      "input" = "fill:#00204d,stroke:#355f8d,stroke-width:2px,color:#ffffff",
      "process" = "fill:#355f8d,stroke:#7d7c78,stroke-width:2px,color:#ffffff",
      "output" = "fill:#cae11f,stroke:#ffe945,stroke-width:2px,color:#000000",
      "decision" = "fill:#ffe945,stroke:#cae11f,stroke-width:2px,color:#000000",
      "artifact" = "fill:#e8e8e8,stroke:#757575,stroke-width:1px,color:#333333",
      "start" = "fill:#a69d75,stroke:#7d7c78,stroke-width:3px,color:#000000",
      "end" = "fill:#cae11f,stroke:#a69d75,stroke-width:3px,color:#000000"
    ),

    # Default to light theme
    list(
      "input" = "fill:#e1f5fe,stroke:#01579b,stroke-width:2px,color:#000000",
      "process" = "fill:#f3e5f5,stroke:#4a148c,stroke-width:2px,color:#000000",
      "output" = "fill:#e8f5e8,stroke:#1b5e20,stroke-width:2px,color:#000000",
      "decision" = "fill:#fff3e0,stroke:#e65100,stroke-width:2px,color:#000000",
      "artifact" = "fill:#f9f9f9,stroke:#666666,stroke-width:1px,color:#333333",
      "start" = "fill:#fff3e0,stroke:#f57c00,stroke-width:3px,color:#e65100",
      "end" = "fill:#e8f5e8,stroke:#2e7d32,stroke-width:3px,color:#1b5e20"
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
    "github" = "Optimized specifically for GitHub README files with maximum mermaid compatibility",
    "viridis" = "Colorblind-safe theme (purple-blue-green-yellow) - perceptually uniform, accessible",
    "magma" = "Colorblind-safe warm theme (purple-red-yellow) - high contrast, print-friendly",
    "plasma" = "Colorblind-safe vibrant theme (purple-pink-yellow) - bold colors for presentations",
    "cividis" = "Colorblind-safe theme optimized for deuteranopia/protanopia (blue-yellow only)"
  )
}

# put id:"node_defs", label:"Create Node Definitions", node_type:"process", input:"workflow_data.rds", output:"nodes.rds"
#' Generate node definitions for mermaid diagram
#' @param workflow Workflow data frame
#' @param node_labels What to show in node labels
#' @param show_workflow_boundaries Whether to apply special styling to start/end nodes
#' @param show_source_info Whether to append source file info to node labels
#' @return Character vector of node definitions
#' @keywords internal
generate_node_definitions <- function(workflow, node_labels = "label",
                                      show_workflow_boundaries = TRUE,
                                      show_source_info = FALSE) {
  node_defs <- character()

  for (i in seq_len(nrow(workflow))) {
    node <- workflow[i, ]
    node_id <- sanitize_node_id(node$id)

    # Determine node shape based on type and workflow boundary settings
    node_shape <- get_node_shape(node$node_type, show_workflow_boundaries)

    # Determine label text
    label_text <- resolve_label(node, node_labels)

    # Append source file info if requested (skip for artifacts)
    is_artifact_node <- "is_artifact" %in% names(node) &&
                        !is.null(node$is_artifact) &&
                        !is.na(node$is_artifact) &&
                        node$is_artifact
    if (show_source_info &&
        !is.na(node$file_name) && node$file_name != "" &&
        !is_artifact_node) {
      # Use HTML-style line break for Mermaid
      label_text <- paste0(label_text, "<br/><small>(", node$file_name, ")</small>")
    }

    # Create node definition using character vector format
    node_def <- paste0("    ", node_id, node_shape[1], label_text, node_shape[2])
    node_defs <- c(node_defs, node_def)
  }

  return(node_defs)
}

#' Get node shape characters based on node type
#' @param node_type Node type string
#' @param show_workflow_boundaries Whether to apply special workflow boundary styling
#' @return Character vector with opening and closing shape characters
#' @keywords internal
get_node_shape <- function(node_type, show_workflow_boundaries = TRUE) {
  # Handle NULL, NA, or missing values
  if (is.null(node_type) || length(node_type) == 0 || is.na(node_type)) {
    return(c("[", "]")) # Default rectangle
  }

  node_type_char <- as.character(node_type)
  
  # Handle workflow boundary nodes
  if (show_workflow_boundaries && node_type_char %in% c("start", "end")) {
    if (node_type_char == "start") {
      return(c("([", "])")) # Special start shape - orange styling is enough
    } else {
      return(c("([", "])")) # Special end shape - green styling is enough
    }
  }
  
  # Regular node types
  switch(node_type_char,
    "input" = c("([", "])"), # Stadium shape for inputs
    "process" = c("[", "]"), # Rectangle for processes
    "output" = c("[[", "]]"), # Subroutine shape for outputs
    "decision" = c("{", "}"), # Diamond for decisions
    "start" = c("([", "])"), # Stadium for start (when boundaries disabled)
    "end" = c("([", "])"), # Stadium for end (when boundaries disabled)
    "artifact" = c("[(", ")]"), # Cylindrical shape for data files
    c("[", "]") # Default rectangle
  )
}

#' Resolve label text for a workflow node
#' @param node A single row from the workflow data frame
#' @param node_labels Label display mode: "name", "label", or "both"
#' @return Character string of the resolved label text
#' @keywords internal
resolve_label <- function(node, node_labels) {
  raw_label <- switch(node_labels,
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
  sanitize_mermaid_label(raw_label)
}

#' Sanitize a label string for safe embedding in Mermaid syntax
#'
#' Escapes characters that would break Mermaid flowchart parsing:
#' quotes, brackets, braces, parentheses, pipes, and arrow syntax.
#'
#' @param label Character string to sanitize
#' @return Sanitized character string safe for Mermaid labels
#' @noRd
sanitize_mermaid_label <- function(label) {
  if (is_empty_string(label)) return(label)
  # Wrap in quotes and escape internal quotes using Mermaid's #quot; entity
  label <- gsub('"', "#quot;", label, fixed = TRUE)
  paste0('"', label, '"')
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

#' Normalize file path for URL generation
#'
#' Converts file paths to URL-friendly format, handling cross-platform differences.
#'
#' @param file_path Character string of the file path
#' @return Normalized path string suitable for URLs
#' @keywords internal
normalize_path_for_url <- function(file_path) {
  if (is.na(file_path) || is.null(file_path) || file_path == "") {
    return("")
  }

  # Convert to character if needed
  file_path <- as.character(file_path)

  # Try to get absolute path, but handle gracefully if file doesn't exist
  normalized <- tryCatch(
    normalizePath(file_path, winslash = "/", mustWork = FALSE),
    error = function(e) file_path
  )

  # Ensure forward slashes for URLs
  normalized <- gsub("\\\\", "/", normalized)

  return(normalized)
}

#' Generate click URL based on protocol
#'
#' Creates a clickable URL for opening files in various IDEs/editors.
#'
#' @param file_path Character string of the file path
#' @param line_number Optional line number to jump to
#' @param protocol Character string specifying the protocol:
#'   \itemize{
#'     \item "vscode" - VS Code editor (vscode://file/path:line)
#'     \item "file" - Standard file:// protocol
#'     \item "rstudio" - RStudio IDE (rstudio://open-file?path=)
#'   }
#' @return URL string for the specified protocol
#' @keywords internal
generate_click_url <- function(file_path, line_number = NULL, protocol = "vscode") {
  normalized_path <- normalize_path_for_url(file_path)

  if (normalized_path == "") {
    return("")
  }

  url <- switch(protocol,
    "vscode" = {
      base_url <- paste0("vscode://file/", normalized_path)
      if (!is.null(line_number) && !is.na(line_number)) {
        paste0(base_url, ":", line_number)
      } else {
        base_url
      }
    },
    "file" = {
      # File protocol with URL encoding
      encoded_path <- utils::URLencode(normalized_path, reserved = FALSE)
      paste0("file:///", encoded_path)
    },
    "rstudio" = {
      # RStudio URL scheme
      encoded_path <- utils::URLencode(normalized_path, reserved = TRUE)
      base_url <- paste0("rstudio://open-file?path=", encoded_path)
      if (!is.null(line_number) && !is.na(line_number)) {
        paste0(base_url, "&line=", line_number)
      } else {
        base_url
      }
    },
    # Default to vscode
    {
      base_url <- paste0("vscode://file/", normalized_path)
      if (!is.null(line_number) && !is.na(line_number)) {
        paste0(base_url, ":", line_number)
      } else {
        base_url
      }
    }
  )

  return(url)
}

#' Generate Mermaid click directives
#'
#' Creates click action directives for Mermaid diagrams, enabling nodes
#' to be clickable links that open files in the specified editor.
#'
#' @param workflow Data frame containing workflow nodes with file_name and
#'   optionally line_number columns
#' @param protocol Character string specifying the click protocol
#'   ("vscode", "file", "rstudio")
#' @return Character vector of Mermaid click directive lines
#' @keywords internal
generate_click_directives <- function(workflow, protocol = "vscode") {
  click_lines <- character()

  for (i in seq_len(nrow(workflow))) {
    node <- workflow[i, ]
    node_id <- sanitize_node_id(node$id)

    # Skip artifact nodes - they represent data files, not source files
    if (!is.null(node$is_artifact) && !is.na(node$is_artifact) && node$is_artifact) {
      next
    }

    # Get file path
    if (is_empty_string(node$file_name)) {
      next
    }

    # Get line number if available
    line_number <- NULL
    if ("line_number" %in% names(node) && !is.na(node$line_number)) {
      line_number <- node$line_number
    }

    # Generate URL
    url <- generate_click_url(node$file_name, line_number, protocol)

    if (url != "") {
      # Create tooltip
      tooltip <- paste0("Open ", node$file_name)
      if (!is.null(line_number)) {
        tooltip <- paste0(tooltip, " at line ", line_number)
      }

      # Mermaid click directive format: click nodeId "url" "tooltip"
      click_line <- paste0('    click ', node_id, ' "', url, '" "', tooltip, '"')
      click_lines <- c(click_lines, click_line)
    }
  }

  return(click_lines)
}

#' Generate file-based subgraphs
#'
#' Groups workflow nodes by their source file into Mermaid subgraphs,
#' providing a visual organization by file origin.
#'
#' @param workflow Data frame containing workflow nodes
#' @param node_labels What to show in node labels ("name", "label", "both")
#' @param show_workflow_boundaries Whether to apply special styling to start/end nodes
#' @return Character vector of Mermaid subgraph definitions
#' @keywords internal
generate_file_subgraphs <- function(workflow, node_labels = "label",
                                    show_workflow_boundaries = TRUE) {
  subgraph_lines <- character()

  # Helper function to check if a row is an artifact
  is_artifact_row <- function(wf) {
    if (!"is_artifact" %in% names(wf)) {
      return(rep(FALSE, nrow(wf)))
    }
    result <- !is.null(wf$is_artifact) & !is.na(wf$is_artifact) & wf$is_artifact
    # Handle any remaining NAs
    result[is.na(result)] <- FALSE
    return(result)
  }

  # Get artifact indicator for all rows
  artifact_indicator <- is_artifact_row(workflow)

  # Get unique file names (excluding artifacts)
  file_names <- unique(workflow$file_name[!artifact_indicator])
  file_names <- file_names[!is.na(file_names) & file_names != ""]

  # Process artifact nodes first (they go outside subgraphs)
  artifact_nodes <- workflow[artifact_indicator, ]
  if (nrow(artifact_nodes) > 0) {
    for (i in seq_len(nrow(artifact_nodes))) {
      node <- artifact_nodes[i, ]
      node_id <- sanitize_node_id(node$id)
      node_shape <- get_node_shape(node$node_type, show_workflow_boundaries)

      label_text <- resolve_label(node, node_labels)

      node_def <- paste0("    ", node_id, node_shape[1], label_text, node_shape[2])
      subgraph_lines <- c(subgraph_lines, node_def)
    }
    subgraph_lines <- c(subgraph_lines, "")
  }

  # Create subgraph for each file
  for (file_name in file_names) {
    # Get nodes from this file
    file_nodes <- workflow[
      !is.na(workflow$file_name) &
      workflow$file_name == file_name &
      !artifact_indicator,
    ]

    if (nrow(file_nodes) == 0) next

    # Create subgraph ID from file name
    subgraph_id <- gsub("[^a-zA-Z0-9_]", "_",
                        tools::file_path_sans_ext(basename(file_name)))

    # Start subgraph
    safe_file_label <- sanitize_mermaid_label(file_name)
    subgraph_lines <- c(subgraph_lines,
                       paste0("    subgraph ", subgraph_id, " [", safe_file_label, "]"))

    # Add nodes within subgraph
    for (i in seq_len(nrow(file_nodes))) {
      node <- file_nodes[i, ]
      node_id <- sanitize_node_id(node$id)
      node_shape <- get_node_shape(node$node_type, show_workflow_boundaries)

      label_text <- resolve_label(node, node_labels)

      node_def <- paste0("        ", node_id, node_shape[1], label_text, node_shape[2])
      subgraph_lines <- c(subgraph_lines, node_def)
    }

    # End subgraph
    subgraph_lines <- c(subgraph_lines, "    end")
    subgraph_lines <- c(subgraph_lines, "")
  }

  return(subgraph_lines)
}

#' Create artifact nodes for data files
#' @param workflow Workflow data frame
#' @return Data frame with artifact node definitions
#' @keywords internal
create_artifact_nodes <- function(workflow) {
  # Collect all unique input and output files
  all_inputs <- character()
  all_outputs <- character()

  for (i in seq_len(nrow(workflow))) {
    node <- workflow[i, ]

    # Process input files
    if (!is.null(node$input) && !is.na(node$input) && node$input != "") {
      input_files <- strsplit(trimws(node$input), ",")[[1]]
      input_files <- trimws(input_files)
      input_files <- input_files[input_files != ""]
      all_inputs <- c(all_inputs, input_files)
    }
    
    # Process output files
    if (!is.null(node$output) && !is.na(node$output) && node$output != "") {
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

# put id:"connections", label:"Generate Node Connections", node_type:"process", input:"nodes.rds", output:"edges.rds"
#' Generate connections between nodes
#' @param workflow Workflow data frame with combined script and artifact nodes
#' @param show_files Whether to show file-based connections
#' @param show_artifacts Whether artifacts are included in the workflow
#' @return Character vector of connection definitions
#' @keywords internal
generate_connections <- function(workflow, show_files = FALSE, show_artifacts = FALSE) {
  connections <- character()

  # Get script nodes (non-artifacts); handle missing is_artifact column
  has_artifact_col <- "is_artifact" %in% names(workflow)
  if (has_artifact_col) {
    is_artifact <- !is.na(workflow$is_artifact) & workflow$is_artifact
    script_nodes <- workflow[!is_artifact, ]
  } else {
    script_nodes <- workflow
  }

  # Script-to-script connections (always generated)
  source_pool <- if (show_artifacts) script_nodes else workflow
  for (i in seq_len(nrow(script_nodes))) {
    node <- script_nodes[i, ]
    target_id <- sanitize_node_id(node$id)

    for (input_file in parse_file_list(node$input)) {
      source_nodes <- find_nodes_outputting(source_pool, input_file)
      for (j in seq_len(nrow(source_nodes))) {
        source_id <- sanitize_node_id(source_nodes[j, ]$id)
        connections <- c(connections,
                         make_edge(source_id, target_id, input_file, show_files))
      }
    }
  }

  # Artifact connections (only when show_artifacts is TRUE)
  if (show_artifacts) {
    for (i in seq_len(nrow(script_nodes))) {
      node <- script_nodes[i, ]
      node_id <- sanitize_node_id(node$id)

      # Input: artifact --> script
      for (input_file in parse_file_list(node$input)) {
        artifact_id <- paste0("artifact_", gsub("[^a-zA-Z0-9_]", "_", input_file))
        if (any(workflow$id == artifact_id, na.rm = TRUE)) {
          connections <- c(connections,
                           make_edge(artifact_id, node_id, input_file, show_files))
        }
      }

      # Output: script --> artifact
      for (output_file in parse_file_list(node$output)) {
        artifact_id <- paste0("artifact_", gsub("[^a-zA-Z0-9_]", "_", output_file))
        if (any(workflow$id == artifact_id, na.rm = TRUE)) {
          connections <- c(connections,
                           make_edge(node_id, artifact_id, output_file, show_files))
        }
      }
    }
  }

  unique(connections)
}

#' Parse a comma-separated file list string into a trimmed character vector
#' @param file_string Comma-separated file list (or NA/NULL/"")
#' @return Character vector of non-empty file names
#' @noRd
parse_file_list <- function(file_string) {
  if (is_empty_string(file_string)) {
    return(character())
  }
  files <- strsplit(trimws(file_string), ",")[[1]]
  files <- trimws(files)
  files[files != ""]
}

#' Find nodes in a data frame whose output column contains a given file
#' @param nodes_df Data frame with an output column
#' @param target_file File name to search for
#' @return Subset of nodes_df where output contains target_file
#' @noRd
find_nodes_outputting <- function(nodes_df, target_file) {
  nodes_df[
    !is.na(nodes_df$output) &
      vapply(nodes_df$output, function(x) {
        target_file %in% parse_file_list(x)
      }, logical(1)),
  ]
}

#' Create a Mermaid edge string between two nodes
#' @param from_id Sanitized source node ID
#' @param to_id Sanitized target node ID
#' @param label Edge label text
#' @param show_label Whether to include the label
#' @return Mermaid edge definition string
#' @noRd
make_edge <- function(from_id, to_id, label = "", show_label = FALSE) {
  if (show_label && label != "") {
    safe_label <- gsub("|", "/", label, fixed = TRUE)
    paste0("    ", from_id, " -->|", safe_label, "| ", to_id)
  } else {
    paste0("    ", from_id, " --> ", to_id)
  }
}

# put id:"output_handler", label:"Output Final Diagram", node_type:"end", input:"diagram.md"
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
      copy_to_clipboard(
        content = paste0("```mermaid\n", mermaid_code, "\n```"),
        success_msg = "Diagram copied to clipboard",
        fallback_content = paste0("```mermaid\n", mermaid_code, "\n```")
      )
    },
    "raw" = {
      # Return just the raw mermaid code without any output
      # This is useful for knitr/pkgdown where markdown fences are handled externally
      # Do nothing - the invisible return in put_diagram() will handle it
    },
    {
      # Unrecognized output value - warn and fall back to console
      warning(
        "Unrecognized output value: '", output, "'.\n",
        "Valid options: \"console\", \"file\", \"clipboard\", \"raw\".\n",
        "Did you mean: put_diagram(workflow, output = \"file\", file = \"", output, "\")?",
        call. = FALSE
      )
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
