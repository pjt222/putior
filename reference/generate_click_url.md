# Generate click URL based on protocol

Creates a clickable URL for opening files in various IDEs/editors.

## Usage

``` r
generate_click_url(file_path, line_number = NULL, protocol = "vscode")
```

## Arguments

- file_path:

  Character string of the file path

- line_number:

  Optional line number to jump to

- protocol:

  Character string specifying the protocol:

  - "vscode" - VS Code editor (vscode://file/path:line)

  - "file" - Standard file:// protocol

  - "rstudio" - RStudio IDE (rstudio://open-file?path=)

## Value

URL string for the specified protocol
