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
#' @param title Character string for diagram title (optional). The drawn
#'   title shows it as written, except when it contains a \code{<}: Mermaid
#'   then shows HTML entities such as \code{&lt;}, \code{&gt;} and
#'   \code{&amp;} in it and drops text that looks like an HTML tag, and
#'   \code{put_diagram()} warns. No escape avoids that in the drawn title.
#'   The \code{accTitle} line (see \code{accessibility}) shows it as
#'   written. (Measured with the security levels \code{strict},
#'   \code{antiscript} and \code{loose}; with \code{sandbox}, Mermaid
#'   before 11.17.2 writes entities into every title.)
#' @param direction Character string specifying diagram direction. Options:
#'   "TD" (top-down; "TB" is a synonym), "LR" (left-right), "BT" (bottom-top),
#'   "RL" (right-left)
#' @param node_labels Character string specifying what to show in nodes:
#'   "name" (node IDs), "label" (descriptions), "both" (ID: label)
#' @param show_files Logical indicating whether to show file connections
#' @param show_artifacts Logical indicating whether to show data files as nodes.
#'   When TRUE, every input and output file that is not itself one of the
#'   workflow's scripts gets a node, and each script connects to the files
#'   it writes and reads (\code{script --> file --> script}), so that the
#'   diagram also shows terminal outputs. Scripts that read another script
#'   (such as \code{utils.R}) stay connected directly. See
#'   \code{artifact_edges}.
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
#' @param palette Optional \code{putior_theme} object created by
#'   \code{\link{put_theme}()} for custom node colors. When provided, this
#'   overrides the \code{theme} parameter. Default is NULL (use \code{theme}).
#' @param show_source_info Logical indicating whether to display source file
#'   information in diagram nodes. When TRUE, each node shows its originating
#'   file name. Default is FALSE for backward compatibility.
#' @param source_info_style Character string specifying how to display source info:
#'   \itemize{
#'     \item "inline" - Append file name to node labels (default)
#'     \item "subgraph" - Group nodes by source file into Mermaid subgraphs
#'   }
#' @param enable_clicks Logical indicating whether to add click directives to nodes.
#'   When TRUE, nodes become clickable links that open the source file in an
#'   editor. The link uses the path the scan recorded (\code{file_path});
#'   a relative path is resolved against the working directory when the
#'   diagram is made. Default is FALSE. Mermaid
#'   keeps these links only with \code{securityLevel: "loose"}; with its
#'   default \code{"strict"} and GitHub's \code{"antiscript"}, the nodes are
#'   not clickable. So clicks do not work on GitHub, GitLab or in Quarto
#'   with their default settings, nor on putior's pkgdown site or in the
#'   sandbox, which stay \code{"strict"} because \code{"loose"} would also
#'   let click callbacks run JavaScript. They work where you render the
#'   diagram yourself with \code{mermaid.initialize(\{ securityLevel:
#'   "loose" \})}; browsers open \code{file://} links only from a page that
#'   is itself a local file.
#' @param click_protocol Character string specifying the URL protocol for clickable nodes:
#'   \itemize{
#'     \item "vscode" - VS Code editor (vscode://file/path:line) (default)
#'     \item "file" - Standard file:// protocol
#'     \item "rstudio" - RStudio IDE (rstudio://open-file?path=)
#'   }
#' @param artifact_edges With \code{show_artifacts = TRUE}, how two scripts
#'   that a data file connects are drawn: "replace" (default) draws only the
#'   path through the file's node; "both" also draws the direct
#'   script-to-script edge, as putior did before 0.2.0, which shows every
#'   hop twice. Has no effect with \code{show_artifacts = FALSE}.
#' @param mermaid_config Mermaid configuration to write into the diagram's
#'   frontmatter, next to the title:
#'   \itemize{
#'     \item "classic" - Mermaid 11's drawing on Mermaid 12 (default): the
#'       dagre layout, the classic look, labels wrapped at 200px and no
#'       minimum node width. Without it, Mermaid 12, which GitHub uses, draws
#'       the "neo" look and wraps labels at 120px. Where the page sets a
#'       theme, as GitHub does, the result matches Mermaid 11; without one,
#'       Mermaid 12's default font is smaller. Mermaid 9.3.0 and later read
#'       the frontmatter, which must be the first thing in the diagram code:
#'       to change the configuration, use this argument rather than a
#'       \code{\%\%\{init\}\%\%} line in front.
#'     \item "none" - No configuration; the renderer's defaults apply
#'     \item A named list, written as YAML (nested lists become nested
#'       keys), such as \code{list(look = "neo")}. A \code{theme} key is left
#'       out with a warning, because a theme in the diagram overrides the
#'       host's light or dark theme; use \code{theme} or \code{palette} for
#'       node colors.
#'   }
#' @param accessibility Logical. When TRUE (default), the diagram carries
#'   accessibility metadata that screen readers announce: \code{accTitle}
#'   with the \code{title} (if one is given) and \code{accDescr} with a
#'   one-line summary, such as "Workflow with 4 steps and 3 data files."
#'   Mermaid puts them into the SVG's \code{<title>} and \code{<desc>}; a
#'   frontmatter title alone does not (Mermaid 10.5.0 and later). Mermaid
#'   reads these lines from 9.1.0 on; for an older renderer, set
#'   \code{accessibility = FALSE} and \code{mermaid_config = "none"}.
#' @param log_level Character string specifying log verbosity for this call.
#'   Overrides the global option \code{putior.log_level} when specified.
#'   Options: "DEBUG", "INFO", "WARN", "ERROR". See \code{\link{set_putior_log_level}}.
#'
#' @section Labels and ids:
#' Labels are quoted, and double quotes, \code{|} and a \code{#} that Mermaid
#' would read as a character entity (as in \code{#35;}) are escaped. So is
#' text that Mermaid would read as syntax:
#' \itemize{
#'   \item the first \code{\%} of \code{\%\%\{}, which starts a directive
#'     that Mermaid removes from the diagram text;
#'   \item the space in \code{direction LR} (or \code{TB}, \code{BT},
#'     \code{RL}, \code{TD}), which Mermaid takes for a direction statement;
#'   \item on a line where \code{style} or \code{classDef} comes before it,
#'     a \code{:} followed by an escaped character, which would let Mermaid
#'     cut that entity short.
#' }
#' An edge to an id that ends in \code{direction} ends with \code{;}. The
#' escapes are Mermaid entities such as \code{#quot;}. Mermaid shows them as
#' the character in HTML labels.
#' Where Mermaid 11.17.2 and later draw SVG text instead
#' (\code{htmlLabels: false} for all labels, or
#' \code{flowchart.htmlLabels: false} for edge labels and subgraph titles),
#' they show the entity as written; Mermaid 11.12.0 can garble it there.
#' Mermaid still interprets HTML
#' tags such as \code{<br/>} and \code{$$...$$} (KaTeX math) inside labels.
#'
#' Node ids are reduced to letters, digits and underscores. An id that starts
#' with a digit or is a Mermaid keyword (such as \code{end} or \code{class})
#' gets a \code{node_} prefix. Ids that only differ in punctuation (\code{a-b}
#' and \code{a_b}) are kept apart with a numeric suffix and a warning; an id
#' that is already valid (\code{a_b}) keeps its form. With
#' \code{source_info_style = "subgraph"}, each source file becomes a subgraph
#' with the id \code{file_<name>}.
#'
#' @section Size limits:
#' Mermaid draws at most 500 edges and 50,000 characters (not counting the
#' frontmatter and \code{\%\%} comments) by default, and shows an error or a
#' placeholder instead. Only the page that renders the diagram can raise
#' these limits (\code{maxEdges}, \code{maxTextSize} in
#' \code{mermaid.initialize()}); GitHub, GitLab and Quarto keep the
#' defaults. \code{put_diagram()} warns when its output is over either
#' limit.
#'
#' @section Mermaid versions:
#' The output uses only classic Mermaid syntax, so that every current
#' renderer draws it. The frontmatter (title and \code{mermaid_config})
#' needs Mermaid 9.3.0 or later, \code{accTitle}/\code{accDescr} 9.1.0 or
#' later (measured). CI draws every diagram option on Mermaid 11.12.0, 11.17.2, 12.1.0
#' and 12.2.0; 10.9.8 was checked once. Renderers (2026-10-12): GitHub
#' 12.1.0 (measured), Quarto 1.10 and 1.11 11.12.0, GitLab 11.16.1, VS Code
#' 11.17.0, Positron 11.15.0; the pkgdown site and the sandbox load 12.2.0.
#' Newer syntax such as \code{@\{ shape: ... \}} needs Mermaid 11.3 or
#' later and is not used while Quarto ships 11.12.0.
#'
#' @return Character string containing the mermaid diagram code
#' @family core-workflow
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
#' # (sep = "": Mermaid reads the frontmatter only at the very start)
#' cat("```mermaid\n", put_diagram(workflow, output = "raw"), "\n```\n", sep = "")
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
#'
#' # Use a custom color palette
#' my_theme <- put_theme(base = "dark",
#'   input = c(fill = "#1a5276", stroke = "#2e86c1", color = "#ffffff"))
#' put_diagram(workflow, palette = my_theme)
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
                        palette = NULL,
                        show_source_info = FALSE,
                        source_info_style = "inline",
                        enable_clicks = FALSE,
                        click_protocol = "vscode",
                        artifact_edges = c("replace", "both"),
                        mermaid_config = "classic",
                        accessibility = TRUE,
                        log_level = NULL) {
  # Set log level for this call if specified
  restore_log_level <- with_log_level(log_level)
  on.exit(restore_log_level(), add = TRUE)

  putior_log("INFO", "Starting diagram generation")

  # Validate direction parameter
  # Mermaid treats TB as a synonym of TD (#79)
  direction <- match.arg(direction, c("TD", "TB", "LR", "BT", "RL"))
  artifact_edges <- match.arg(artifact_edges)

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

  # Validate palette
  if (!is.null(palette)) {
    if (!inherits(palette, "putior_theme")) {
      stop(
        "'palette' must be a putior_theme object created by put_theme().\n",
        "Example:\n",
        "  my_palette <- put_theme(base = \"dark\",\n",
        "    input = c(fill = \"#1a5276\", stroke = \"#2e86c1\", color = \"#ffffff\"))\n",
        "  put_diagram(workflow, palette = my_palette)",
        call. = FALSE
      )
    }
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

  config_lines <- mermaid_config_lines(mermaid_config)

  if (!is.null(title)) {
    if (length(title) != 1 || is.na(title)) {
      stop("title must be a single string or NULL", call. = FALSE)
    }
    # A number or factor worked before and still does
    title <- as.character(title)
    # Mermaid passes the title through DOMPurify, which turns a title with a
    # "<" into HTML that the drawn title then shows as written; no escape
    # avoids that. Measured on Mermaid 10.9.8 to 12.2.0 (#98).
    if (grepl("<", title, fixed = TRUE)) {
      warning(
        "The title contains \"<\", which Mermaid does not draw as written: ",
        "the drawn title shows HTML entities such as \"&lt;\", \"&gt;\" and ",
        "\"&amp;\" in it and drops text that looks like an HTML tag. Write ",
        "\"less than\" or leave the \"<\" out.",
        call. = FALSE
      )
    }
  }
  if (!(is.logical(accessibility) && length(accessibility) == 1 && !is.na(accessibility))) {
    stop("accessibility must be TRUE or FALSE", call. = FALSE)
  }

  # Clean the workflow data
  workflow <- workflow[!is.na(workflow$id) & workflow$id != "", ]
  if (nrow(workflow) == 0) {
    stop(
      "No valid workflow nodes found (all IDs are missing or empty).\n",
      "This can happen if:\n",
      "- PUT annotations set an empty id (id:\"\")\n",
      "- The data frame was built by hand without ids\n",
      "Solution: Give each annotation a unique id, or omit 'id' to have one generated:\n",
      "  # put id:\"my_node\", label:\"Description\"\n",
      "See putior_help(\"annotation\") for syntax details.",
      call. = FALSE
    )
  }

  putior_log("DEBUG", "Processing {nrow(workflow)} workflow node(s)")

  # Start building the mermaid diagram
  mermaid_lines <- character()

  # Frontmatter: the title, as a quoted YAML string (an unquoted title with
  # ": " or " #" does not parse, #45), and the Mermaid configuration (#54)
  frontmatter <- c(
    if (!is.null(title)) paste0("title: ", yaml_quote(title)),
    config_lines
  )
  if (length(frontmatter) > 0) {
    mermaid_lines <- c(mermaid_lines, paste(c("---", frontmatter, "---"), collapse = "\n"))
  }

  # Add flowchart declaration
  mermaid_lines <- c(mermaid_lines, paste0("flowchart ", direction))

  # Accessibility metadata for screen readers (#50)
  if (isTRUE(accessibility)) {
    mermaid_lines <- c(mermaid_lines, accessibility_lines(workflow, title))
  }

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

  # One Mermaid id per node, used by every line that names it (#46)
  combined_workflow <- assign_mermaid_ids(combined_workflow)

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
  connections <- generate_connections(combined_workflow, show_files, show_artifacts,
                                      artifact_edges)
  if (length(connections) > 0) {
    mermaid_lines <- c(mermaid_lines, "", "    %% Connections", connections)
    putior_log("DEBUG", "Created {length(connections)} connection(s)")
  }

  # Add styling based on theme (palette overrides theme when provided)
  if (style_nodes && "node_type" %in% names(combined_workflow)) {
    putior_log("DEBUG", "Applying '{theme}' theme styling")
    styling <- generate_node_styling(combined_workflow, theme, show_workflow_boundaries, palette)
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
  warn_about_mermaid_limits(mermaid_code, show_artifacts)

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
#' @param show_workflow_boundaries Whether to style start/end nodes
#' @param palette Optional putior_theme object that overrides theme
#' @return Character vector of styling definitions
#' @keywords internal
generate_node_styling <- function(workflow, theme = "light", show_workflow_boundaries = TRUE, palette = NULL) {
  styling <- character()
  workflow <- ensure_mermaid_ids(workflow)

  # Use palette if provided, otherwise use theme
  if (!is.null(palette) && inherits(palette, "putior_theme")) {
    color_schemes <- unclass(palette)
  } else {
    color_schemes <- get_theme_colors(theme)
  }

  # Group nodes by type and create styling
  for (node_type in names(color_schemes)) {
    # Skip start/end styling if workflow boundaries are disabled
    if (!show_workflow_boundaries && node_type %in% c("start", "end")) {
      next
    }
    
    nodes_of_type <- workflow[!is.na(workflow$node_type) & workflow$node_type == node_type, ]

    if (nrow(nodes_of_type) > 0) {
      node_ids <- unique(nodes_of_type$mermaid_id)
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

#' Get color schemes for different themes
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
#' @family utilities
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
  workflow <- ensure_mermaid_ids(workflow)

  for (i in seq_len(nrow(workflow))) {
    node <- workflow[i, ]
    node_id <- node$mermaid_id

    # Determine node shape based on type and workflow boundary settings
    node_shape <- get_node_shape(node$node_type, show_workflow_boundaries)

    # Build source file suffix if requested (skip for artifacts). Appended to the
    # raw label inside resolve_label() so the <br/> and (filename) land INSIDE the
    # quoted label -- otherwise Mermaid rejects `["label"<br/>(file)]` (#mermaid-01).
    is_artifact_node <- "is_artifact" %in% names(node) &&
                        !is.null(node$is_artifact) &&
                        !is.na(node$is_artifact) &&
                        node$is_artifact
    source_suffix <- NULL
    if (show_source_info &&
        !is.na(node$file_name) && node$file_name != "" &&
        !is_artifact_node) {
      source_suffix <- paste0("<br/>(", node$file_name, ")")
    }

    # Determine label text (source suffix folded in before quoting)
    label_text <- resolve_label(node, node_labels, suffix = source_suffix)

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
#' @param suffix Optional string appended to the raw label before sanitization
#'   (e.g. source-file info), so it lands inside the quoted label
#' @return Character string of the resolved label text
#' @keywords internal
resolve_label <- function(node, node_labels, suffix = NULL) {
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
  # Fold any suffix (e.g. source-file info) into the raw label BEFORE sanitizing,
  # so it lands inside the quoted label and any special chars are escaped (#mermaid-01).
  if (!is.null(suffix) && nzchar(suffix)) {
    raw_label <- paste0(raw_label, suffix)
  }
  sanitize_mermaid_label(raw_label, line_start = node$mermaid_id)
}

#' Quote a string as a double-quoted YAML scalar
#' @param text Character string
#' @return The string in double quotes, with backslashes and quotes escaped
#'   and line breaks and other control characters replaced by spaces
#' @noRd
yaml_quote <- function(text) {
  # Mermaid's frontmatter parser rejects control characters ("expected valid
  # JSON character"), and line breaks would end the YAML line
  text <- gsub(.CONTROL_CHARS, " ", as.character(text))
  text <- gsub("\\", "\\\\", text, fixed = TRUE)
  text <- gsub('"', '\\"', text, fixed = TRUE)
  paste0('"', text, '"')
}

# The configuration that put_diagram() writes by default (#54). Mermaid 12
# draws the "neo" look with the ELK layout, wraps labels at 120px and makes
# every node at least 120px wide; GitHub uses Mermaid 12.1.0 since
# 2026-10-07. These keys give Mermaid 11's drawing on Mermaid 12, and
# Mermaid 11.12.0 to 11.17.2 draw the same with or without them. They are
# not secure (host-only) keys, so hosts such as GitHub honour them. theme
# is left out on purpose: a theme in the diagram overrides the host's light
# or dark theme.
.MERMAID_CLASSIC_CONFIG <- list(
  layout = "dagre",
  look = "classic",
  flowchart = list(wrappingWidth = 200, minNodeWidth = 0)
)

#' The config: lines of a diagram's frontmatter
#' @param mermaid_config "classic", "none", NULL or a named list
#' @return Character vector of YAML lines, empty for no configuration
#' @noRd
mermaid_config_lines <- function(mermaid_config) {
  config_error <- paste0(
    'mermaid_config must be "classic", "none" or a named list such as ',
    'list(look = "neo")'
  )
  if (is.character(mermaid_config)) {
    if (length(mermaid_config) != 1 || !mermaid_config %in% c("classic", "none")) {
      stop(config_error, call. = FALSE)
    }
    mermaid_config <- if (mermaid_config == "classic") .MERMAID_CLASSIC_CONFIG else NULL
  } else if (!is.null(mermaid_config) && !is.list(mermaid_config)) {
    stop(config_error, call. = FALSE)
  }
  if (length(mermaid_config) == 0) {
    return(character())
  }
  if ("theme" %in% names(mermaid_config)) {
    warning(
      "mermaid_config: 'theme' is left out, because a theme in the diagram ",
      "overrides the light or dark theme of the page that shows it. ",
      "Use the theme or palette argument for node colors.",
      call. = FALSE
    )
    mermaid_config$theme <- NULL
    if (length(mermaid_config) == 0) {
      return(character())
    }
  }
  c("config:", yaml_mapping_lines(mermaid_config, "  ", config_error))
}

#' YAML lines for a named list of scalars and nested named lists
#' @noRd
yaml_mapping_lines <- function(mapping, indent, config_error) {
  keys <- names(mapping)
  if (length(mapping) > 0 &&
      (is.null(keys) || !all(grepl("^[A-Za-z_][A-Za-z0-9_-]*$", keys)))) {
    stop(config_error, call. = FALSE)
  }
  # Mermaid's YAML parser rejects a key that appears twice in a mapping
  if (anyDuplicated(keys)) {
    stop("mermaid_config: '", keys[anyDuplicated(keys)], "' is given more than once",
         call. = FALSE)
  }
  unlist(lapply(keys, function(key) {
    value <- mapping[[key]]
    if (is.list(value)) {
      # An empty list would be a key without a value; leave it out
      if (length(value) == 0) return(character())
      return(c(paste0(indent, key, ":"), yaml_mapping_lines(value, paste0(indent, "  "), config_error)))
    }
    if (length(value) != 1 || is.na(value) ||
        !(is.character(value) || is.numeric(value) || is.logical(value)) ||
        (is.numeric(value) && !is.finite(value))) {
      stop("mermaid_config: the value of '", key, "' must be one string, ",
           "number or logical value, or a named list", call. = FALSE)
    }
    scalar <- if (is.logical(value)) {
      if (value) "true" else "false"
    } else if (is.numeric(value)) {
      as.character(value)
    } else {
      yaml_quote(value)
    }
    paste0(indent, key, ": ", scalar)
  }), use.names = FALSE)
}

# Mermaid's default limits (#56). A host can raise them with
# mermaid.initialize(); a diagram cannot, because both are secure keys.
# Measured on Mermaid 10.9.8 to 12.2.0: 500 edges draw and 501 give "Edge
# limit exceeded"; 50,000 characters draw and 50,001 give the "Maximum
# text size in diagram exceeded" placeholder.
.MERMAID_MAX_EDGES <- 500
.MERMAID_MAX_TEXT_SIZE <- 50000

#' Size of a diagram as Mermaid measures it against maxTextSize
#'
#' Mermaid compares the length of the diagram text after it has removed the
#' frontmatter and the \code{\%\%} comment lines (with
#' \code{/^\\s*\%\%(?!\{)[^\\n]+\\n?/gm}, whose \code{\\s*} also takes the
#' blank line before a comment) and trimmed the start, in UTF-16 code units
#' (JavaScript string length). Read from the Mermaid 11.12.0 and 12.2.0
#' bundles and checked against \code{mermaid.render()} at 50,000 and 50,001
#' characters on 11.12.0 to 12.2.0.
#' @param mermaid_code Diagram code as put_diagram() writes it
#' @return Number of UTF-16 code units
#' @noRd
mermaid_text_size <- function(mermaid_code) {
  body <- sub("(?s)^-{3}\\s*[\n\r](.*?)[\n\r]-{3}\\s*[\n\r]+", "", mermaid_code, perl = TRUE)
  body <- gsub("(?m)^\\s*%%(?!\\{)[^\n]+\n?", "", body, perl = TRUE)
  body <- sub("^\\s+", "", body, perl = TRUE)
  # mermaid.run(), which pkgdown sites and the sandbox use, rewrites <br>
  # to <br/> before it counts; count that too, so that the warning is never
  # late (it can then be a few characters early with mermaid.render())
  body <- gsub("<br>", "<br/>", body, ignore.case = TRUE)
  code_points <- utf8ToInt(enc2utf8(body))
  length(code_points) + sum(code_points > 65535)
}

#' Warn when a diagram is over Mermaid's default limits
#' @param mermaid_code Diagram code
#' @param show_artifacts Whether the diagram draws artifact nodes
#' @return NULL, invisibly; called for its warnings
#' @noRd
warn_about_mermaid_limits <- function(mermaid_code, show_artifacts) {
  code_lines <- strsplit(mermaid_code, "\n", fixed = TRUE)[[1]]
  edge_count <- sum(grepl("^    [A-Za-z0-9_]+ -->", code_lines))
  # A Markdown code block or a .mmd file ends the diagram with a newline,
  # which Mermaid counts too
  text_size <- mermaid_text_size(paste0(mermaid_code, "\n"))
  options_text <- paste0(
    "Options: ",
    if (show_artifacts) "show_artifacts = FALSE, " else "",
    "a smaller workflow (the exclude argument of put(), or a subset of its rows), ",
    "or a page whose Mermaid setup raises the limit in mermaid.initialize(); ",
    "the diagram itself cannot raise it."
  )
  if (edge_count > .MERMAID_MAX_EDGES) {
    warning(
      "The diagram has ", edge_count, " edges, more than the ", .MERMAID_MAX_EDGES,
      " that Mermaid draws by default (maxEdges): GitHub, GitLab, Quarto and ",
      "VS Code show an error instead. ", options_text,
      call. = FALSE
    )
  }
  if (text_size > .MERMAID_MAX_TEXT_SIZE) {
    warning(
      "The diagram has ", text_size, " characters (without frontmatter and comments), ",
      "more than the ", format(.MERMAID_MAX_TEXT_SIZE, big.mark = ","),
      " that Mermaid draws by default (maxTextSize): it shows a placeholder ",
      "instead. Shorter labels (node_labels = \"name\") or style_nodes = FALSE ",
      "also help. ", options_text,
      call. = FALSE
    )
  }
  invisible(NULL)
}

#' Sanitize a label string for safe embedding in Mermaid syntax
#'
#' Quotes the label, so that brackets, braces, parentheses and arrows in it
#' are text, and escapes what Mermaid would still misread: line breaks,
#' double quotes, pipes, a \code{#} that starts an entity, the start of a
#' directive (\code{\%\%\{}), direction statements and colons that let
#' Mermaid cut an entity short.
#'
#' @param label Character string to sanitize
#' @param line_start The text in front of the label on its line (the node,
#'   edge source or subgraph id), or NULL if unknown. Colons are escaped only
#'   where Mermaid would need it, which depends on this text.
#' @param line_end The text after the label on its line, or NULL. A \code{;}
#'   in it can complete Mermaid's rule for colons.
#' @return Sanitized character string safe for Mermaid labels
#' @noRd
sanitize_mermaid_label <- function(label, line_start = NULL, line_end = NULL) {
  if (is_empty_string(label)) return(label)
  # Line breaks would end the Mermaid line, U+2028 and U+2029 included (#104)
  label <- gsub(.LINE_BREAKS, " ", label)
  # A # that Mermaid would read as an entity (#45); runs before the escapes
  # below, which write entities themselves
  label <- escape_entity_hashes(label)
  # Wrap in quotes and escape internal quotes using Mermaid's #quot; entity
  label <- gsub('"', "#quot;", label, fixed = TRUE)
  # Escape pipe characters using Mermaid's #124; entity (pipes delimit edge labels)
  label <- gsub("|", "#124;", label, fixed = TRUE)
  # These escapes write entities themselves, so they run last (#89)
  label <- escape_mermaid_syntax(label, line_start, line_end)
  paste0('"', label, '"')
}

#' Escape a # that Mermaid would read as the start of an entity
#'
#' Mermaid decodes #<name>; and #<digits>; as entities, so "Step #35;" would
#' show as "Step #" (#45). Only a # that starts such a sequence is escaped:
#' a plain "C#" stays as it is, because with htmlLabels turned off Mermaid
#' shows an escaped # as "&#35;". Runs before any escape that writes
#' entities itself.
#' @noRd
escape_entity_hashes <- function(text) {
  gsub("#(?=\\w+;)", "#35;", text, perl = TRUE)
}

#' Escape text that Mermaid would read as syntax (#89, #98)
#'
#' Mermaid removes "%%{...}%%" directives from the whole diagram text before
#' it parses it, so the start of one in a label cuts the label short and
#' can swallow the lines up to a later end of one; the first "%" of each
#' start becomes "#37;" (#98, measured on Mermaid 10.9.8 to 12.2.0). Then direction words and colons
#' that let Mermaid cut an entity short; see escape_direction_words() and
#' escape_style_colons(). All three write entities, and the colon escape
#' must see those of the other two.
#' @noRd
escape_mermaid_syntax <- function(text, line_start = NULL, line_end = NULL) {
  text <- gsub("%(?=%\\{)", "#37;", text, perl = TRUE)
  escape_style_colons(escape_direction_words(text), line_start, line_end)
}

#' Escape text that Mermaid shows outside a label (#50, #47)
#'
#' For accTitle text and click tooltips. Mermaid decodes entities there, as
#' in labels, and its lexer reads these lines like any other (see
#' escape_mermaid_syntax()). It also passes the text through DOMPurify,
#' which turns the text around a "<" into entities that are then shown as
#' written. Measured on Mermaid 10.9.8 to 12.2.0.
#' @param text Text without line breaks
#' @param line_start The text in front of it on its line
#' @param escape_quotes TRUE for text inside a quoted Mermaid string
#' @return The escaped text
#' @noRd
escape_mermaid_text <- function(text, line_start, escape_quotes = FALSE) {
  text <- escape_entity_hashes(text)
  if (escape_quotes) {
    text <- gsub('"', "#quot;", text, fixed = TRUE)
  }
  text <- gsub("<", "#60;", text, fixed = TRUE)
  # Runs last: the colon escape must see every ";" written above
  escape_mermaid_syntax(text, line_start)
}

#' Percent-encode a path for a click URL (#47)
#'
#' Keeps letters, digits, "-", ".", "_", "~", "/" and ":" (drive letters
#' and the ":line" suffix); every other byte of the UTF-8 path becomes
#' %XX. A space, "#", ";" or quote in a path then cannot end the URL,
#' start a fragment, or trigger Mermaid's direction and colon rules on the
#' click line. Editors decode the path.
#' @param path File path with forward slashes
#' @return Encoded path
#' @noRd
encode_url_path <- function(path) {
  bytes <- charToRaw(enc2utf8(path))
  codes <- as.integer(bytes)
  safe <- (codes >= 48L & codes <= 57L) | (codes >= 65L & codes <= 90L) |
    (codes >= 97L & codes <= 122L) | codes %in% utf8ToInt("-._~/:")
  parts <- ifelse(safe, vapply(codes, function(code) intToUtf8(code), character(1)),
                  sprintf("%%%02X", codes))
  paste(parts, collapse = "")
}

#' accTitle and accDescr lines for a diagram (#50)
#'
#' accTitle comes from the title, if there is one; accDescr summarises the
#' workflow. Mermaid decodes entities in both, as in labels, but quotes and
#' pipes need no escape there; "<" and "%%{...}%%" do. Measured on Mermaid
#' 10.9.8, 11.12.0, 11.17.2, 12.1.0 and 12.2.0.
#' @param workflow The workflow being drawn, without artifact nodes
#' @param title The diagram title, or NULL
#' @return Character vector of indented diagram lines
#' @noRd
accessibility_lines <- function(workflow, title) {
  lines <- character()
  if (!is_empty_string(title)) {
    title_text <- trimws(gsub(.CONTROL_CHARS, " ", as.character(title)))
    if (nzchar(title_text)) {
      title_text <- escape_mermaid_text(title_text, "    accTitle")
      lines <- c(lines, paste0("    accTitle: ", title_text))
    }
  }
  step_count <- length(unique(workflow$id))
  # The files that show_artifacts = TRUE draws, without .internal
  # variables, which are not files
  data_files <- create_artifact_nodes(workflow)$file_name
  file_count <- sum(!grepl("\\.internal$", data_files))
  summary_text <- paste0(
    "Workflow with ", step_count, if (step_count == 1) " step" else " steps",
    if (file_count > 0) {
      paste0(" and ", file_count, if (file_count == 1) " data file" else " data files")
    },
    "."
  )
  c(lines, paste0("    accDescr: ", summary_text))
}

# The characters that JavaScript's \s matches, for a regex character class.
# Mermaid's lexer uses \s; R's \s (PCRE without UCP) misses the Unicode
# spaces. The \u escapes make the pattern UTF-8, so PCRE runs in UTF mode.
.JS_WHITESPACE <- "\\t\\n\\x{0B}\\f\\r \u00a0\u1680\u2000-\u200a\u2028\u2029\u202f\u205f\u3000\ufeff"

# Line breaks for Mermaid. The JavaScript regex with which Mermaid removes
# comment lines treats U+2028 and U+2029 as line ends too, so a label with
# U+2028 followed by "%%" lost the rest of its line and the diagram failed
# to parse (#104). [[:cntrl:]] matches them only in a UTF-8 locale, so both
# patterns list them explicitly.
.LINE_BREAKS <- "[\r\n\u2028\u2029]"
.CONTROL_CHARS <- "[[:cntrl:]\u2028\u2029]+"

#' Escape words that Mermaid reads as a direction statement inside a label
#'
#' Mermaid's flowchart lexer reads any line that contains \code{direction},
#' whitespace and \code{TB}, \code{BT}, \code{RL}, \code{LR} or \code{TD}
#' as a \code{direction} statement and drops the whole line, so a node with
#' the label "Set direction LR" disappears (#89). The rule is case-sensitive
#' and has no word boundaries ("redirection TBD" also matches). Writing the
#' first whitespace character as an entity (\code{#32;} for a space) breaks
#' the match, and Mermaid shows the same character. Measured on Mermaid
#' 11.12.0, 11.17.2, 12.1.0 and 12.2.0.
#' @param label Label text, already escaped otherwise
#' @return The label with each such whitespace character written as an entity
#' @noRd
escape_direction_words <- function(label) {
  label <- enc2utf8(label)
  whitespace <- paste0("[", .JS_WHITESPACE, "]")
  pattern <- paste0("direction", whitespace, "(?=", whitespace, "*(?:TB|BT|RL|LR|TD))")
  matches <- gregexpr(pattern, label, perl = TRUE)
  regmatches(label, matches) <- lapply(regmatches(label, matches), function(found) {
    # "direction" has 9 characters; the 10th is the whitespace
    code_points <- vapply(found, function(match) utf8ToInt(substring(match, 10)), integer(1))
    # NA for text that is not valid UTF-8; leave such a match as it is
    ifelse(is.na(code_points), found, sprintf("direction#%d;", code_points))
  })
  label
}

#' Escape colons that let Mermaid cut the end off an entity
#'
#' Before it reads entities, Mermaid removes the last \code{;} of every line
#' that matches \code{style.*:\\S*#.*;} or \code{classDef.*:\\S*#.*;}. A
#' label \code{style:"bold"} is written as \code{style:#quot;bold#quot;} and
#' would show as \code{style:"bold#quot} (#89). So a \code{:} that is
#' followed by non-space characters up to a \code{#}, and later by a
#' \code{;}, is written as \code{#58;} when \code{style} or \code{classDef}
#' comes before it on the line: in \code{line_start} (the node id
#' \code{lifestyle}, for example) or earlier in the label. Without
#' \code{line_start}, every such colon is escaped. On node, edge and
#' subgraph lines, a \code{:} occurs only in the label. Measured on Mermaid
#' 11.12.0, 11.17.2, 12.1.0 and 12.2.0. The \code{;} can also come after the
#' label (\code{line_end}), as on an edge to an id that ends in
#' \code{direction}; then a colon followed by a \code{#} is escaped.
#' @param label Label text, already escaped otherwise
#' @param line_start Text in front of the label on its line, or NULL
#' @param line_end Text after the label on its line, or NULL
#' @return The label with those colons written as \code{#58;}
#' @noRd
escape_style_colons <- function(label, line_start = NULL, line_end = NULL) {
  label <- enc2utf8(label)
  not_whitespace <- paste0("[^", .JS_WHITESPACE, "]")
  semicolon_follows <- !is.null(line_end) && grepl(";", line_end, fixed = TRUE)
  colon_pattern <- paste0(":(?=", not_whitespace, "*#", if (semicolon_follows) "" else ".*;", ")")
  if (is.null(line_start)) {
    return(gsub(colon_pattern, "#58;", label, perl = TRUE))
  }
  # Only colons after the first "style" or "classDef" on the line count. A
  # space keeps the word from running across the id and the label.
  line_text <- paste0(line_start, " ", label)
  keyword <- regexpr("style|classDef", line_text, perl = TRUE)
  if (keyword < 0) {
    return(label)
  }
  keyword_end <- keyword + attr(keyword, "match.length") - 1L - nchar(line_start) - 1L
  split_at <- max(0L, keyword_end)
  paste0(
    substring(label, 1L, split_at),
    gsub(colon_pattern, "#58;", substring(label, split_at + 1L), perl = TRUE)
  )
}

# Words that Mermaid's flowchart parser rejects as a node id (case-sensitive:
# "End" and "END" work), including the link targets of click lines.
# Measured on Mermaid 11.12.0, 11.17.2, 12.1.0 and 12.2.0; "direction" and
# "default" parse, so they are not listed. (#45)
.MERMAID_KEYWORD_IDS <- c(
  "end", "graph", "flowchart", "subgraph", "style", "class", "classDef",
  "click", "linkStyle", "call", "href", "interpolate",
  "_self", "_blank", "_parent", "_top",
  # accDescr{...} starts an accDescr block, so a decision node with this id
  # lost its shape and label; measured on Mermaid 10.9.8 to 12.2.0, where
  # accTitle works as an id with every shape (#50)
  "accDescr"
)

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

  # Mermaid keywords cannot be node ids
  if (sanitized %in% .MERMAID_KEYWORD_IDS) {
    sanitized <- paste0("node_", sanitized)
  }

  return(sanitized)
}

#' Give every node of a workflow its Mermaid id
#'
#' Sanitizes each id once and stores it in a \code{mermaid_id} column, so
#' node definitions, edges, class lines and click directives all use the same
#' id. Distinct ids that become equal after sanitizing (\code{"a-b"} and
#' \code{"a_b"}) are kept apart with a numeric suffix (\code{a_b_2}); for
#' annotation ids this gives a warning. Rows with the same raw id share one
#' Mermaid id.
#'
#' Ids that are already valid Mermaid ids keep their form whatever the row
#' order; among the others, the first row keeps the plain form. Annotation ids
#' come before artifacts, so a script node is never renamed because of an
#' artifact.
#' @param workflow Workflow data frame, optionally with artifact rows
#'   (\code{is_artifact = TRUE})
#' @param warn Whether to warn when annotation ids collide
#' @return The workflow with a \code{mermaid_id} column
#' @noRd
assign_mermaid_ids <- function(workflow, warn = TRUE) {
  raw_ids <- as.character(workflow$id)
  unique_raw_ids <- unique(raw_ids)
  sanitized_ids <- vapply(unique_raw_ids, sanitize_node_id, character(1),
                          USE.NAMES = FALSE)

  is_artifact_id <- if ("is_artifact" %in% names(workflow)) {
    artifact_flags <- !is.na(workflow$is_artifact) & workflow$is_artifact
    unique_raw_ids %in% raw_ids[artifact_flags]
  } else {
    rep(FALSE, length(unique_raw_ids))
  }

  # Priority: valid annotation ids, other annotation ids, artifacts
  priority <- ifelse(is_artifact_id, 3L, ifelse(sanitized_ids == unique_raw_ids, 1L, 2L))
  processing_order <- order(priority, seq_along(unique_raw_ids))

  mermaid_ids <- rep(NA_character_, length(unique_raw_ids))
  collision_messages <- character()
  for (id_index in processing_order) {
    candidate <- sanitized_ids[id_index]
    if (candidate %in% mermaid_ids) {
      # Skip every id that is taken or that another node will want
      reserved_ids <- c(mermaid_ids[!is.na(mermaid_ids)], sanitized_ids)
      suffix_number <- 2L
      while (paste0(sanitized_ids[id_index], "_", suffix_number) %in% reserved_ids) {
        suffix_number <- suffix_number + 1L
      }
      candidate <- paste0(sanitized_ids[id_index], "_", suffix_number)
      if (!is_artifact_id[id_index]) {
        holder_raw_id <- unique_raw_ids[match(sanitized_ids[id_index], mermaid_ids)]
        collision_messages <- c(collision_messages, paste0(
          "'", unique_raw_ids[id_index], "' is drawn as '", candidate, "' ('",
          holder_raw_id, "' is already '", sanitized_ids[id_index], "')"
        ))
      }
    }
    mermaid_ids[id_index] <- candidate
  }

  if (warn && length(collision_messages) > 0) {
    warning(
      "Some node ids become the same Mermaid id and get a numeric suffix:\n",
      paste0("- ", collision_messages, collapse = "\n"), "\n",
      "Rename one id of each pair to choose the ids the diagram uses.",
      call. = FALSE
    )
  }

  workflow$mermaid_id <- mermaid_ids[match(raw_ids, unique_raw_ids)]
  workflow
}

#' Return the workflow with a mermaid_id column, adding one if missing
#' @param workflow Workflow data frame
#' @return The workflow with a \code{mermaid_id} column
#' @noRd
ensure_mermaid_ids <- function(workflow) {
  if ("mermaid_id" %in% names(workflow)) {
    return(workflow)
  }
  assign_mermaid_ids(workflow, warn = FALSE)
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

  # normalizePath() leaves a path to a file that does not exist relative;
  # a URL needs it absolute (#47)
  if (!grepl("^(/|[A-Za-z]:/)", normalized)) {
    working_dir <- sub("/$", "", gsub("\\\\", "/", getwd()))
    normalized <- paste0(working_dir, "/", sub("^\\./", "", normalized))
  }

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

  # Without one leading "/", so that "vscode://file/" and "file:///" get
  # exactly one slash in front of an absolute Unix path, as of a Windows
  # path (D:/...). A UNC path (//server/share/..., also WSL paths from
  # Windows R) keeps one of its two slashes: VS Code needs
  # vscode://file//server/..., and a file URL names the server as its host.
  # Percent-encoded (#47).
  is_unc_path <- startsWith(normalized_path, "//")
  url_path <- encode_url_path(sub("^/", "", normalized_path))

  url <- switch(protocol,
    "vscode" = {
      base_url <- paste0("vscode://file/", url_path)
      if (!is.null(line_number) && !is.na(line_number)) {
        paste0(base_url, ":", line_number)
      } else {
        base_url
      }
    },
    "file" = {
      # file:// URLs have no line number
      if (is_unc_path) paste0("file:", encode_url_path(normalized_path)) else paste0("file:///", url_path)
    },
    "rstudio" = {
      # RStudio URL scheme; the path is a query value, so "&", "=" and "?"
      # are encoded too
      base_url <- paste0("rstudio://open-file?path=", encode_url_path(normalized_path))
      if (!is.null(line_number) && !is.na(line_number)) {
        paste0(base_url, "&line=", line_number)
      } else {
        base_url
      }
    },
    # Default to vscode
    {
      base_url <- paste0("vscode://file/", url_path)
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
  workflow <- ensure_mermaid_ids(workflow)

  for (i in seq_len(nrow(workflow))) {
    node <- workflow[i, ]
    node_id <- node$mermaid_id

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

    # The path the scan recorded when the workflow has it: a file name
    # alone was resolved against the working directory at diagram time (#47)
    click_path <- node$file_name
    if ("file_path" %in% names(node) && !is_empty_string(node$file_path)) {
      click_path <- node$file_path
    }
    url <- generate_click_url(click_path, line_number, protocol)

    if (url != "") {
      # Mermaid click directive format: click nodeId "url" "tooltip"
      line_start <- paste0('    click ', node_id, ' "', url, '" ')
      tooltip <- escape_mermaid_text(click_tooltip(node$file_name, line_number),
                                     line_start, escape_quotes = TRUE)
      click_lines <- c(click_lines, paste0(line_start, '"', tooltip, '"'))
    }
  }

  return(click_lines)
}

#' Tooltip text of a click line
#' @param file_name The node's source file name
#' @param line_number The annotation's line number, or NULL
#' @return "Open <file>" or "Open <file> at line <n>", without line breaks
#' @noRd
click_tooltip <- function(file_name, line_number = NULL) {
  tooltip <- paste0("Open ", gsub(.CONTROL_CHARS, " ", file_name))
  if (!is.null(line_number) && !is.na(line_number)) {
    tooltip <- paste0(tooltip, " at line ", line_number)
  }
  tooltip
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
  workflow <- ensure_mermaid_ids(workflow)

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

  # Group nodes by file path when it is known, so that files with the same
  # name in different folders get one subgraph each (#46); fall back to the
  # file name for workflows without a file_path column
  file_keys <- workflow$file_name
  if ("file_path" %in% names(workflow)) {
    has_path <- !is.na(workflow$file_path) & workflow$file_path != ""
    file_keys[has_path] <- workflow$file_path[has_path]
  }
  script_file_keys <- unique(file_keys[!artifact_indicator])
  script_file_keys <- script_file_keys[!is.na(script_file_keys) & script_file_keys != ""]

  # Subgraph ids must differ from every node id and from each other, or
  # Mermaid nests a node in itself (#45)
  taken_ids <- unique(workflow$mermaid_id)

  # The file name shown for each file. Files with the same name in different
  # folders also show as much of their folder path as it takes to tell them
  # apart ("x/load.R" and "y/load.R", or "a/x/load.R" and "b/x/load.R")
  key_file_names <- vapply(script_file_keys, function(file_key) {
    key_rows <- which(!is.na(file_keys) & file_keys == file_key & !artifact_indicator)
    key_name <- workflow$file_name[key_rows[1]]
    if (is_empty_string(key_name)) basename(file_key) else key_name
  }, character(1), USE.NAMES = FALSE)
  file_labels <- key_file_names
  for (repeated_name in unique(key_file_names[duplicated(key_file_names)])) {
    group <- which(key_file_names == repeated_name)
    # Folder names from the innermost outwards
    folder_parts <- lapply(script_file_keys[group], function(file_key) {
      parts <- strsplit(gsub("\\\\", "/", dirname(file_key)), "/", fixed = TRUE)[[1]]
      rev(parts[nzchar(parts) & parts != "."])
    })
    for (depth in seq_len(max(lengths(folder_parts), 0L))) {
      file_labels[group] <- vapply(folder_parts, function(parts) {
        paste(c(rev(parts[seq_len(min(depth, length(parts)))]), repeated_name), collapse = "/")
      }, character(1))
      if (!anyDuplicated(file_labels[group])) break
    }
  }

  # Process artifact nodes first (they go outside subgraphs)
  artifact_nodes <- workflow[artifact_indicator, ]
  if (nrow(artifact_nodes) > 0) {
    for (i in seq_len(nrow(artifact_nodes))) {
      node <- artifact_nodes[i, ]
      node_id <- node$mermaid_id
      node_shape <- get_node_shape(node$node_type, show_workflow_boundaries)

      label_text <- resolve_label(node, node_labels)

      node_def <- paste0("    ", node_id, node_shape[1], label_text, node_shape[2])
      subgraph_lines <- c(subgraph_lines, node_def)
    }
    subgraph_lines <- c(subgraph_lines, "")
  }

  # Create subgraph for each file
  for (key_index in seq_along(script_file_keys)) {
    file_key <- script_file_keys[key_index]
    # Get nodes from this file
    file_nodes <- workflow[
      !is.na(file_keys) & file_keys == file_key & !artifact_indicator,
    ]

    if (nrow(file_nodes) == 0) next

    file_name <- key_file_names[key_index]
    file_label <- file_labels[key_index]

    # Subgraph id: file_<name>, with a suffix if that id is taken
    base_subgraph_id <- sanitize_node_id(
      paste0("file_", tools::file_path_sans_ext(basename(file_name)))
    )
    subgraph_id <- base_subgraph_id
    suffix_number <- 2L
    while (subgraph_id %in% taken_ids) {
      subgraph_id <- paste0(base_subgraph_id, "_", suffix_number)
      suffix_number <- suffix_number + 1L
    }
    taken_ids <- c(taken_ids, subgraph_id)

    # Start subgraph
    safe_file_label <- sanitize_mermaid_label(file_label, line_start = subgraph_id)
    subgraph_lines <- c(subgraph_lines,
                       paste0("    subgraph ", subgraph_id, " [", safe_file_label, "]"))

    # Add nodes within subgraph
    for (i in seq_len(nrow(file_nodes))) {
      node <- file_nodes[i, ]
      node_id <- node$mermaid_id
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
  
  # Create artifact node definitions. The id keeps the file path as it is, so
  # two files never share an id; assign_mermaid_ids() makes it Mermaid-safe.
  artifact_nodes <- data.frame(
    id = paste0("artifact_", data_files),
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
#' @param artifact_edges "replace" to leave out a direct script-to-script
#'   edge for a file that has an artifact node, "both" to keep it
#' @return Character vector of connection definitions
#' @keywords internal
generate_connections <- function(workflow, show_files = FALSE, show_artifacts = FALSE,
                                 artifact_edges = "replace") {
  connections <- character()
  workflow <- ensure_mermaid_ids(workflow)

  # Get script nodes (non-artifacts); handle missing is_artifact column
  has_artifact_col <- "is_artifact" %in% names(workflow)
  if (has_artifact_col) {
    is_artifact <- !is.na(workflow$is_artifact) & workflow$is_artifact
    script_nodes <- workflow[!is_artifact, ]
    artifact_nodes <- workflow[is_artifact, ]
  } else {
    script_nodes <- workflow
    artifact_nodes <- workflow[0, ]
  }

  # Mermaid id of the artifact node for a data file (character(0) if none)
  artifact_id_for <- function(file) {
    unique(artifact_nodes$mermaid_id[artifact_nodes$file_name == file])
  }

  # Script-to-script connections. With artifacts drawn, a file that has an
  # artifact node already connects the two scripts through it, and a direct
  # edge would draw that hop twice (#55); files without one, such as a
  # script that another script reads, keep the direct edge.
  source_pool <- if (show_artifacts) script_nodes else workflow
  # Rows of source_pool that write each file, built once: looking them up
  # for every input made large workflows quadratic (a 500-step chain took
  # about two minutes; #56)
  output_lists <- lapply(source_pool$output, parse_file_list)
  producer_rows <- split(rep(seq_along(output_lists), lengths(output_lists)),
                         unlist(output_lists))
  for (i in seq_len(nrow(script_nodes))) {
    node <- script_nodes[i, ]
    target_id <- node$mermaid_id

    for (input_file in parse_file_list(node$input)) {
      if (show_artifacts && artifact_edges == "replace" &&
          length(artifact_id_for(input_file)) > 0) {
        next
      }
      for (source_id in source_pool$mermaid_id[producer_rows[[input_file]]]) {
        connections <- c(connections,
                         make_edge(source_id, target_id, input_file, show_files))
      }
    }
  }

  # Artifact connections (only when show_artifacts is TRUE)
  if (show_artifacts) {
    for (i in seq_len(nrow(script_nodes))) {
      node <- script_nodes[i, ]
      node_id <- node$mermaid_id

      # Input: artifact --> script
      for (input_file in parse_file_list(node$input)) {
        for (artifact_id in artifact_id_for(input_file)) {
          connections <- c(connections,
                           make_edge(artifact_id, node_id, input_file, show_files))
        }
      }

      # Output: script --> artifact
      for (output_file in parse_file_list(node$output)) {
        for (artifact_id in artifact_id_for(output_file)) {
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

#' Create a Mermaid edge string between two nodes
#' @param from_id Sanitized source node ID
#' @param to_id Sanitized target node ID
#' @param label Edge label text
#' @param show_label Whether to include the label
#' @return Mermaid edge definition string
#' @noRd
make_edge <- function(from_id, to_id, label = "", show_label = FALSE) {
  # Mermaid's lexer reads "direction", whitespace and TB/BT/RL/LR/TD as a
  # direction statement, and its \s+ also spans line breaks. An edge line
  # that ends in an id such as "wind_direction" therefore ran into a next
  # line that starts with "LR_prep", and both edges vanished. A ";" ends
  # the statement without changing the diagram (#89).
  line_end <- if (grepl("direction$", to_id)) ";" else ""
  if (show_label && label != "") {
    # Quoted and escaped like node labels: an unquoted label with ( or |
    # does not parse (#45)
    label_text <- sanitize_mermaid_label(label, line_start = from_id,
                                         line_end = paste0(to_id, line_end))
    paste0("    ", from_id, " -->|", label_text, "| ", to_id, line_end)
  } else {
    paste0("    ", from_id, " --> ", to_id, line_end)
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
#'
#' Parses a comma-separated string of file names into a character vector,
#' trimming whitespace from each entry.
#'
#' @param file_string Comma-separated file names
#' @return Character vector of individual file names
#' @family utilities
#' @export
#'
#' @examples
#' split_file_list("data.csv, results.rds, plot.png")
#' split_file_list("")
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
