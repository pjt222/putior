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
  palette = NULL,
  show_source_info = FALSE,
  source_info_style = "inline",
  enable_clicks = FALSE,
  click_protocol = "vscode",
  artifact_edges = c("replace", "both"),
  mermaid_config = "classic",
  accessibility = TRUE,
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
  (top-down; "TB" is a synonym), "LR" (left-right), "BT" (bottom-top),
  "RL" (right-left)

- node_labels:

  Character string specifying what to show in nodes: "name" (node IDs),
  "label" (descriptions), "both" (ID: label)

- show_files:

  Logical indicating whether to show file connections

- show_artifacts:

  Logical indicating whether to show data files as nodes. When TRUE,
  every input and output file that is not itself one of the workflow's
  scripts gets a node, and each script connects to the files it writes
  and reads (`script --> file --> script`), so that the diagram also
  shows terminal outputs. Scripts that read another script (such as
  `utils.R`) stay connected directly. See `artifact_edges`.

- show_workflow_boundaries:

  Logical indicating whether to apply special styling to nodes with
  node_type "start" and "end". When TRUE, these nodes get distinctive
  workflow boundary styling (icons, colors). When FALSE, they render as
  regular nodes.

- style_nodes:

  Logical indicating whether to apply styling based on node_type

- theme:

  Character string specifying color theme. Options:

  - "light" - Default light theme with bright colors (default)

  - "dark" - Dark theme for dark mode environments

  - "auto" - GitHub-adaptive with solid colors for both modes

  - "minimal" - Grayscale professional, print-friendly

  - "github" - Optimized for GitHub README files

  - "viridis" - Colorblind-safe (purple-blue-green-yellow)

  - "magma" - Colorblind-safe warm (purple-red-yellow)

  - "plasma" - Colorblind-safe vibrant (purple-pink-yellow)

  - "cividis" - Colorblind-safe for deuteranopia/protanopia
    (blue-yellow)

  The viridis family themes are perceptually uniform and tested for
  accessibility.

- palette:

  Optional `putior_theme` object created by
  [`put_theme()`](https://pjt222.github.io/putior/reference/put_theme.md)
  for custom node colors. When provided, this overrides the `theme`
  parameter. Default is NULL (use `theme`).

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

- artifact_edges:

  With `show_artifacts = TRUE`, how two scripts that a data file
  connects are drawn: "replace" (default) draws only the path through
  the file's node; "both" also draws the direct script-to-script edge,
  as putior did before 0.2.0, which shows every hop twice. Has no effect
  with `show_artifacts = FALSE`.

- mermaid_config:

  Mermaid configuration to write into the diagram's frontmatter, next to
  the title:

  - "classic" - Mermaid 11's drawing on Mermaid 12 (default): the dagre
    layout, the classic look, labels wrapped at 200px and no minimum
    node width. Without it, Mermaid 12, which GitHub uses, draws the
    "neo" look and wraps labels at 120px. Where the page sets a theme,
    as GitHub does, the result matches Mermaid 11; without one, Mermaid
    12's default font is smaller. Mermaid 9.3.0 and later read the
    frontmatter, which must be the first thing in the diagram code: to
    change the configuration, use this argument rather than a
    `%%{init}%%` line in front.

  - "none" - No configuration; the renderer's defaults apply

  - A named list, written as YAML (nested lists become nested keys),
    such as `list(look = "neo")`. A `theme` key is left out with a
    warning, because a theme in the diagram overrides the host's light
    or dark theme; use `theme` or `palette` for node colors.

- accessibility:

  Logical. When TRUE (default), the diagram carries accessibility
  metadata that screen readers announce: `accTitle` with the `title` (if
  one is given) and `accDescr` with a one-line summary, such as
  "Workflow with 4 steps and 3 data files." Mermaid puts them into the
  SVG's `<title>` and `<desc>`; a frontmatter title alone does not
  (Mermaid 10.5.0 and later). Mermaid reads these lines from 9.1.0 on;
  for an older renderer, set `accessibility = FALSE` and
  `mermaid_config = "none"`.

- log_level:

  Character string specifying log verbosity for this call. Overrides the
  global option `putior.log_level` when specified. Options: "DEBUG",
  "INFO", "WARN", "ERROR". See
  [`set_putior_log_level`](https://pjt222.github.io/putior/reference/set_putior_log_level.md).

## Value

Character string containing the mermaid diagram code

## Labels and ids

Labels are quoted, and double quotes, `|` and a `#` that Mermaid would
read as a character entity (as in `#35;`) are escaped. So is text that
Mermaid would read as syntax: the space in `direction LR` (or `TB`,
`BT`, `RL`, `TD`), which Mermaid takes for a direction statement, and,
on a line where `style` or `classDef` comes before it, a `:` followed by
an escaped character, which would let Mermaid cut that entity short. An
edge to an id that ends in `direction` ends with `;`. The escapes are
Mermaid entities such as `#quot;`. Mermaid shows them as the character
in HTML labels. Where Mermaid 11.17.2 and later draw SVG text instead
(`htmlLabels: false` for all labels, or `flowchart.htmlLabels: false`
for edge labels and subgraph titles), they show the entity as written;
Mermaid 11.12.0 can garble it there. Mermaid still interprets HTML tags
such as `<br/>` and `$$...$$` (KaTeX math) inside labels.

Node ids are reduced to letters, digits and underscores. An id that
starts with a digit or is a Mermaid keyword (such as `end` or `class`)
gets a `node_` prefix. Ids that only differ in punctuation (`a-b` and
`a_b`) are kept apart with a numeric suffix and a warning; an id that is
already valid (`a_b`) keeps its form. With
`source_info_style = "subgraph"`, each source file becomes a subgraph
with the id `file_<name>`.

## Size limits

Mermaid draws at most 500 edges and 50,000 characters (not counting the
frontmatter and `%%` comments) by default, and shows an error or a
placeholder instead. Only the page that renders the diagram can raise
these limits (`maxEdges`, `maxTextSize` in `mermaid.initialize()`);
GitHub, GitLab and Quarto keep the defaults. `put_diagram()` warns when
its output is over either limit.

## Mermaid versions

The output uses only classic Mermaid syntax, so that every current
renderer draws it. The frontmatter (title and `mermaid_config`) needs
Mermaid 9.3.0 or later, `accTitle`/`accDescr` 9.1.0 or later (measured).
CI draws every diagram option on Mermaid 11.12.0, 11.17.2, 12.1.0 and
12.2.0; 10.9.8 was checked once. Renderers (2026-10-12): GitHub 12.1.0
(measured), Quarto 1.10 and 1.11 11.12.0, GitLab 11.16.1, VS Code
11.17.0, Positron 11.15.0; the pkgdown site and the sandbox load 12.2.0.
Newer syntax such as `@{ shape: ... }` needs Mermaid 11.3 or later and
is not used while Quarto ships 11.12.0.

## See also

Other core-workflow:
[`print.putior_theme()`](https://pjt222.github.io/putior/reference/print.putior_theme.md),
[`print.putior_workflow()`](https://pjt222.github.io/putior/reference/print.putior_workflow.md),
[`put()`](https://pjt222.github.io/putior/reference/put.md),
[`put_theme()`](https://pjt222.github.io/putior/reference/put_theme.md),
[`summary.putior_workflow()`](https://pjt222.github.io/putior/reference/summary.putior_workflow.md)

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
# (sep = "": Mermaid reads the frontmatter only at the very start)
cat("```mermaid\n", put_diagram(workflow, output = "raw"), "\n```\n", sep = "")

# Show source file info inline in nodes
put_diagram(workflow, show_source_info = TRUE)

# Group nodes by source file using subgraphs
put_diagram(workflow, show_source_info = TRUE, source_info_style = "subgraph")

# Enable clickable nodes (opens in VS Code)
put_diagram(workflow, enable_clicks = TRUE)

# Enable clickable nodes with RStudio protocol
put_diagram(workflow, enable_clicks = TRUE, click_protocol = "rstudio")

# Use a custom color palette
my_theme <- put_theme(base = "dark",
  input = c(fill = "#1a5276", stroke = "#2e86c1", color = "#ffffff"))
put_diagram(workflow, palette = my_theme)
} # }
```
