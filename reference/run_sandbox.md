# Launch putior Interactive Sandbox

Opens an interactive Shiny application for experimenting with PUT
annotations and workflow diagrams. Users can paste or type annotated
code, adjust diagram settings, and see real-time diagram generation
without installing the package locally.

## Usage

``` r
run_sandbox()
```

## Value

Launches the Shiny app in the default browser. Returns invisibly.

## Details

The sandbox app allows you to:

- Enter annotated code with PUT comments

- Simulate multiple files using file markers

- Customize diagram appearance (theme, direction, etc.)

- View extracted workflow data

- Copy or download generated Mermaid code

## See also

[`put`](https://pjt222.github.io/putior/reference/put.md),
[`put_diagram`](https://pjt222.github.io/putior/reference/put_diagram.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# Launch the interactive sandbox
run_sandbox()
} # }
```
