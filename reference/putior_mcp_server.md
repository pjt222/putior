# Start putior MCP Server

Starts an MCP server that exposes putior functions as tools for AI
assistants. This enables AI coding assistants (Claude Code, Claude
Desktop) to directly call workflow annotation and diagram generation
functions.

## Usage

``` r
putior_mcp_server(
  type = c("stdio", "http"),
  host = "127.0.0.1",
  port = 8080L,
  root = getwd(),
  token = NULL
)
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

- root:

  For HTTP transport: the folder that the tools may scan (default: the
  working directory). A relative path is taken from it, a path outside
  it is an error, and a recursive scan skips the files that links inside
  it lead outside to. Over stdio the client is the local program that
  started the server, and paths are not limited.

- token:

  For HTTP transport: `NULL` (default) or a string of at least 16
  characters without spaces that clients must send as the header
  `Plumber-Shared-Secret: <token>`. A server on an address other than a
  loopback one (`127.0.0.1`, `localhost`, `::1`) needs a token. Without
  one, only requests addressed to a loopback name are answered.

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

- `putior_guide` - AI assistant documentation

- `putior_help` - Quick reference help

- `set_putior_log_level` - Configure logging

- `is_valid_put_annotation` - Validate annotation syntax

- `split_file_list` - Parse file lists

- `ext_to_language` - Extension to language name

Only these tools are served: mcptools' tools for choosing a running R
session (`list_r_sessions`, `select_r_session`) are turned off, so every
call runs in the server's own R process.

Over stdio, R warnings would never reach the client. When R warns while
a tool runs (invalid annotations, a `<` in a title or label, a diagram
over Mermaid's size limits, ...), the tool returns the warnings as a
second text item after its result, at most 20 of them, each cut to 1,000
characters. For `put_diagram` they are Mermaid comment lines, so the
diagram still renders when a client joins the two items; the first item
is always exactly the Mermaid code. When a call fails, the warnings
raised before the error follow its message.

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

## Security

Over stdio nothing below applies: the client is the program that started
the server. Over HTTP:

- A tool can scan only the `root` folder and what lies below it, and
  returns the file names, labels and annotations found there, with the
  same rules as
  [`putior_acp_server`](https://pjt222.github.io/putior/reference/putior_acp_server.md):
  a path outside the root is an error, also through a symbolic link or
  junction; a recursive scan skips the files that links inside the root
  lead outside to; a path with a `..` component, control characters or a
  network or device form is rejected. Results and messages show the root
  as `<root>`, and `put_diagram` refuses `enable_clicks`, whose links
  name files by their path on the server.

- Without a token, the server runs only on a loopback `host` and answers
  only requests addressed to a loopback name, so that a web page cannot
  reach it through DNS rebinding; mcptools also rejects requests from
  web pages of other origins.

- mcptools' own settings stay in force: hosts trusted through the option
  `mcptools.http_trusted_hosts` or the environment variable
  `MCPTOOLS_HTTP_TRUSTED_HOSTS` are answered too, and a secret set
  through `mcptools.http_shared_secret` or `plumber2.sharedSecret` is
  required when `token` is `NULL`.

- To serve other machines, set `token`; mcptools then answers only
  requests that send it:


      # R
      putior_mcp_server(type = "http", host = "0.0.0.0", port = 8080,
                        root = "path/to/project",
                        token = Sys.getenv("PUTIOR_MCP_TOKEN"))

      # Claude Code
      claude mcp add --transport http putior http://<server>:8080/ \
        --header "Plumber-Shared-Secret: <token>"

- The server does not use TLS and mcptools does not limit the request
  size: across a network, put it behind a proxy that serves HTTPS and
  limits the size, or the token travels in clear text.

## See also

[`putior_mcp_tools`](https://pjt222.github.io/putior/reference/putior_mcp_tools.md)
for accessing the tool definitions

Other integration:
[`putior_acp_manifest()`](https://pjt222.github.io/putior/reference/putior_acp_manifest.md),
[`putior_acp_server()`](https://pjt222.github.io/putior/reference/putior_acp_server.md),
[`putior_guide()`](https://pjt222.github.io/putior/reference/putior_guide.md),
[`putior_help()`](https://pjt222.github.io/putior/reference/putior_help.md),
[`putior_mcp_tools()`](https://pjt222.github.io/putior/reference/putior_mcp_tools.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# Start MCP server with default stdio transport
putior_mcp_server()

# Start MCP server with HTTP transport, scanning only the current folder
putior_mcp_server(type = "http", port = 8080)
} # }
```
