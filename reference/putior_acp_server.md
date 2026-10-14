# Start putior ACP Server

Starts an ACP (Agent Communication Protocol) REST server that exposes
putior as an agent that other AI agents can discover and call.

## Usage

``` r
putior_acp_server(
  host = "127.0.0.1",
  port = 8080L,
  root = getwd(),
  token = NULL
)
```

## Arguments

- host:

  Character string specifying the host address. Default: "127.0.0.1"
  (localhost only)

- port:

  Integer specifying the port number. Default: 8080

- root:

  The folder that requests may scan (default: the working directory). A
  request's relative path is taken from it, and a path outside it, also
  through a symbolic link, is rejected; a scan skips files that links
  inside it lead outside to. A request without a path scans this folder.

- token:

  `NULL` (default) or a string of at least 16 characters. With a token,
  `POST /runs` and `GET /runs/<id>` need the header
  `Authorization: Bearer <token>`. A server on an address other than a
  loopback one (`127.0.0.1`, `localhost`, `::1`) needs a token. Passing
  it from an environment variable, as
  `token = Sys.getenv("PUTIOR_ACP_TOKEN")`, keeps it out of scripts and
  the R history.

## Value

This function does not return; it runs the server until terminated.

## Details

The ACP server exposes the following endpoints:

- GET /agents:

  Returns the agent manifest for discovery

- POST /runs:

  Execute a putior operation

- GET /runs/\<run_id\>:

  Get the status/result of a previous run

## Security

- A request can scan only the `root` folder and what lies below it, and
  it sees the file names and labels found there. A path outside the root
  is rejected, also when a symbolic link or junction leads there; a
  recursive scan skips the files that links inside the root lead outside
  to, and refuses a folder with more than 200 such links. A path with a
  `..` component, control characters, or a network or device form
  (`\\server\share`, `//server/share`) is rejected before the disk is
  touched. Messages show the root as `<root>`.

- Without a token, the server runs only on a loopback `host`
  (`127.x.x.x`, `localhost`, `::1`) and answers only requests addressed
  to such a name, so that a web page cannot reach it through DNS
  rebinding. With `host = "0.0.0.0"` or another address, set `token`.

- `POST /runs` needs `Content-Type: application/json`, which a web page
  cannot send to another site without the server's consent. A
  `Content-Length` over 1 MB is refused (a body sent in chunks is not
  limited); on a server that other machines can reach, use a proxy that
  limits the request size.

- Run IDs are 128 random bits (from the openssl package, which plumber2
  needs), so a client cannot guess the ID of another client's run.

- The server does not use TLS: across a network, put it behind a proxy
  that does, or the token travels in clear text.

## Message Format

POST /runs expects a JSON body with this structure:


    {
      "input": [
        {
          "role": "user",
          "parts": [
            {
              "content": "scan ./R/ for workflow annotations",
              "content_type": "text/plain"
            }
          ]
        }
      ],
      "session_id": "optional-session-id"
    }

## Supported Operations

The agent understands natural language requests for:

- **scan**: "Scan ./R/ for PUT annotations"

- **diagram**: "Generate a diagram for ./R/"

- **auto**: "Auto-detect workflow from ./src/"

- **generate**: "Generate annotation suggestions for ./R/"

- **merge**: "Merge manual and auto annotations in ./R/"

- **help**: "Help with annotation syntax"

- **guide**: "What are your capabilities?"

## Testing

Test the server with curl:


    # Discover agents
    curl http://localhost:8080/agents

    # Execute a scan
    curl -X POST http://localhost:8080/runs \
      -H "Content-Type: application/json" \
      -d '{"input": [{"role": "user", "parts": [{"content": "scan ./R/"}]}]}'

    # With a token
    curl -X POST http://localhost:8080/runs \
      -H "Authorization: Bearer $PUTIOR_ACP_TOKEN" \
      -H "Content-Type: application/json" \
      -d '{"input": [{"role": "user", "parts": [{"content": "scan ./R/"}]}]}'

## See also

[`putior_acp_manifest`](https://pjt222.github.io/putior/reference/putior_acp_manifest.md)
for the agent definition,
[`putior_mcp_server`](https://pjt222.github.io/putior/reference/putior_mcp_server.md)
for MCP (Model-to-tool) integration

Other integration:
[`putior_acp_manifest()`](https://pjt222.github.io/putior/reference/putior_acp_manifest.md),
[`putior_guide()`](https://pjt222.github.io/putior/reference/putior_guide.md),
[`putior_help()`](https://pjt222.github.io/putior/reference/putior_help.md),
[`putior_mcp_server()`](https://pjt222.github.io/putior/reference/putior_mcp_server.md),
[`putior_mcp_tools()`](https://pjt222.github.io/putior/reference/putior_mcp_tools.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# Start ACP server on default port
putior_acp_server()

# Start on custom host/port
# Reachable from other machines: needs a token, sent by clients as
# "Authorization: Bearer <token>"
putior_acp_server(host = "0.0.0.0", port = 9000, root = "~/projects",
                  token = Sys.getenv("PUTIOR_ACP_TOKEN"))
} # }
```
