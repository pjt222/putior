# Generate Mermaid click directives

Creates click action directives for Mermaid diagrams, enabling nodes to
be clickable links that open files in the specified editor.

## Usage

``` r
generate_click_directives(workflow, protocol = "vscode")
```

## Arguments

- workflow:

  Data frame containing workflow nodes with file_name and optionally
  line_number columns

- protocol:

  Character string specifying the click protocol ("vscode", "file",
  "rstudio")

## Value

Character vector of Mermaid click directive lines
