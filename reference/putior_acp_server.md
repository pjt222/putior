# Start putior ACP Server

Starts an ACP (Agent Communication Protocol) REST server that exposes
putior as an agent that other AI agents can discover and call.

## Usage

``` r
putior_acp_server(host = "127.0.0.1", port = 8080L)
```

## Arguments

- host:

  Character string specifying the host address. Default: "127.0.0.1"
  (localhost only)

- port:

  Integer specifying the port number. Default: 8080

## Value

This function does not return; it runs the server until terminated.

## Details

The ACP server exposes the following endpoints:

- GET /agents:

  Returns the agent manifest for discovery

- POST /runs:

  Execute a putior operation

- GET /runs/:run_id:

  Get the status/result of a previous run

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

- **skills**: "What are your capabilities?"

## Testing

Test the server with curl:

    # Discover agents
    curl http://localhost:8080/agents

    # Execute a scan
    curl -X POST http://localhost:8080/runs \
      -H "Content-Type: application/json" \
      -d '{"input": [{"role": "user", "parts": [{"content": "scan ./R/"}]}]}'

## See also

[`putior_acp_manifest`](https://pjt222.github.io/putior/reference/putior_acp_manifest.md)
for the agent definition,
[`putior_mcp_server`](https://pjt222.github.io/putior/reference/putior_mcp_server.md)
for MCP (Model-to-tool) integration

## Examples

``` r
if (FALSE) { # \dontrun{
# Start ACP server on default port
putior_acp_server()

# Start on custom host/port
putior_acp_server(host = "0.0.0.0", port = 9000)
} # }
```
