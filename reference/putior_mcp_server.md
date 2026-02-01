# Start putior MCP Server

Starts an MCP server that exposes putior functions as tools for AI
assistants. This enables AI coding assistants (Claude Code, Claude
Desktop) to directly call workflow annotation and diagram generation
functions.

## Usage

``` r
putior_mcp_server(type = c("stdio", "http"), host = "127.0.0.1", port = 8080L)
```

## Arguments

- type:

  Character string specifying the transport type:

  - "stdio" (default) - Standard input/output transport

  - "http" - HTTP transport

- host:

  Character string specifying the host for HTTP transport. Default:
  "127.0.0.1"

- port:

  Integer specifying the port for HTTP transport. Default: 8080

## Value

This function does not return; it runs the MCP server until terminated.

## Details

The MCP server exposes the following putior functions as tools:

- `put` - Scan files for PUT annotations

- `put_diagram` - Generate Mermaid diagrams

- `put_auto` - Auto-detect workflow from code

- `put_generate` - Generate annotation suggestions

- `put_merge` - Merge manual + auto annotations

- `get_comment_prefix` - Get comment prefix for extension

- `get_supported_extensions` - List supported extensions

- `list_supported_languages` - List supported languages

- `get_detection_patterns` - Get auto-detection patterns

- `get_diagram_themes` - List available themes

- `putior_skills` - AI assistant documentation

- `putior_help` - Quick reference help

- `set_putior_log_level` - Configure logging

- `is_valid_put_annotation` - Validate annotation syntax

- `split_file_list` - Parse file lists

- `ext_to_language` - Extension to language name

## Configuration

**Claude Code (WSL/Linux/macOS):**

    claude mcp add putior -- Rscript -e "putior::putior_mcp_server()"

**Claude Desktop (Windows):** Add to
`%APPDATA%\Claude\claude_desktop_config.json`:

    {
      "mcpServers": {
        "putior": {
          "command": "Rscript",
          "args": ["-e", "putior::putior_mcp_server()"]
        }
      }
    }

## See also

[`putior_mcp_tools`](https://pjt222.github.io/putior/reference/putior_mcp_tools.md)
for accessing the tool definitions

## Examples

``` r
if (FALSE) { # \dontrun{
# Start MCP server with default stdio transport
putior_mcp_server()

# Start MCP server with HTTP transport
putior_mcp_server(type = "http", port = 8080)
} # }
```
