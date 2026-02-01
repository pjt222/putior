# Get putior MCP Tool Definitions

Returns a list of ellmer tool definitions for all putior functions that
can be exposed via MCP. This function is primarily used internally by
[`putior_mcp_server`](https://pjt222.github.io/putior/reference/putior_mcp_server.md),
but can also be used directly for inspection or custom MCP server
implementations.

## Usage

``` r
putior_mcp_tools(include = NULL, exclude = c("run_sandbox"))
```

## Arguments

- include:

  Character vector of tool names to include. If NULL (default), all
  available tools are included.

- exclude:

  Character vector of tool names to exclude. Default excludes
  "run_sandbox" since Shiny apps cannot run via MCP.

## Value

A list of ellmer tool definitions suitable for use with
[`mcptools::mcp_server()`](https://posit-dev.github.io/mcptools/reference/server.html).

## See also

[`putior_mcp_server`](https://pjt222.github.io/putior/reference/putior_mcp_server.md)
for starting the MCP server

## Examples

``` r
if (FALSE) { # \dontrun{
# Get all putior MCP tools
tools <- putior_mcp_tools()

# Get specific tools only
tools <- putior_mcp_tools(include = c("put", "put_diagram"))

# Exclude specific tools
tools <- putior_mcp_tools(exclude = c("run_sandbox", "putior_help"))
} # }
```
