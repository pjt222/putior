# Create Mermaid Diagram from PUT Workflow

Generates a Mermaid flowchart diagram from putior workflow data, showing
the flow of data through your analysis pipeline.

## Usage

``` r
put_diagram(
  workflow,
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
  log_level = NULL
)
```

## Arguments

- workflow:

  Data frame returned by
  [`put()`](https://pjt222.github.io/putior/reference/put.md) containing
  workflow nodes

- output:

  Character string specifying output format. Options:

  - "console" - Print to console (default)

  - "file" - Save to file specified by `file` parameter

  - "clipboard" - Copy to clipboard (if available)

  - "raw" - Return raw mermaid code without markdown fences (for
    knitr/pkgdown)

- file:

  Character string specifying output file path (used when output =
  "file")

- title:

  Character string for diagram title (optional)

- direction:

  Character string specifying diagram direction. Options: "TD"
  (top-down), "LR" (left-right), "BT" (bottom-top), "RL" (right-left)

- node_labels:

  Character string specifying what to show in nodes: "name" (node IDs),
  "label" (descriptions), "both" (ID: label)

- show_files:

  Logical indicating whether to show file connections

- show_artifacts:

  Logical indicating whether to show data files as nodes. When TRUE,
  creates nodes for all input/output files, not just script connections.
  This provides a complete view of the data flow including terminal
  outputs.

- show_workflow_boundaries:

  Logical indicating whether to apply special styling to nodes with
  node_type "start" and "end". When TRUE, these nodes get distinctive
  workflow boundary styling (icons, colors). When FALSE, they render as
  regular nodes.

- style_nodes:

  Logical indicating whether to apply styling based on node_type

- theme:

  Character string specifying color theme. Options: "light" (default),
  "dark", "auto" (GitHub adaptive), "minimal", "github"

- show_source_info:

  Logical indicating whether to display source file information in
  diagram nodes. When TRUE, each node shows its originating file name.
  Default is FALSE for backward compatibility.

- source_info_style:

  Character string specifying how to display source info:

  - "inline" - Append file name to node labels (default)

  - "subgraph" - Group nodes by source file into Mermaid subgraphs

- enable_clicks:

  Logical indicating whether to add click directives to nodes. When
  TRUE, nodes become clickable links that open the source file in an
  editor. Default is FALSE for backward compatibility.

- click_protocol:

  Character string specifying the URL protocol for clickable nodes:

  - "vscode" - VS Code editor (vscode://file/path:line) (default)

  - "file" - Standard file:// protocol

  - "rstudio" - RStudio IDE (rstudio://open-file?path=)

- log_level:

  Character string specifying log verbosity for this call. Overrides the
  global option `putior.log_level` when specified. Options: "DEBUG",
  "INFO", "WARN", "ERROR". See
  [`set_putior_log_level`](https://pjt222.github.io/putior/reference/set_putior_log_level.md).

## Value

Character string containing the mermaid diagram code

## Examples

``` r
if (FALSE) { # \dontrun{
# Basic usage - shows only script connections
workflow <- put("./src/")
put_diagram(workflow)

# Show all data artifacts as nodes (complete data flow)
put_diagram(workflow, show_artifacts = TRUE)

# Show artifacts with file labels on connections
put_diagram(workflow, show_artifacts = TRUE, show_files = TRUE)

# Show workflow boundaries with special start/end styling
put_diagram(workflow, show_workflow_boundaries = TRUE)

# Disable workflow boundaries (start/end nodes render as regular)
put_diagram(workflow, show_workflow_boundaries = FALSE)

# GitHub-optimized theme for README files
put_diagram(workflow, theme = "github")

# Save to file with artifacts enabled
put_diagram(workflow, show_artifacts = TRUE, output = "file", file = "workflow.md")

# For use in knitr/pkgdown - returns raw mermaid code
# Use within a code chunk with results='asis'
cat("```mermaid\n", put_diagram(workflow, output = "raw"), "\n```\n")

# Show source file info inline in nodes
put_diagram(workflow, show_source_info = TRUE)

# Group nodes by source file using subgraphs
put_diagram(workflow, show_source_info = TRUE, source_info_style = "subgraph")

# Enable clickable nodes (opens in VS Code)
put_diagram(workflow, enable_clicks = TRUE)

# Enable clickable nodes with RStudio protocol
put_diagram(workflow, enable_clicks = TRUE, click_protocol = "rstudio")
} # }
```
