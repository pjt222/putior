# Get putior ACP Agent Manifest

Returns the agent definition for ACP discovery. This manifest describes
putior's capabilities to other AI agents.

## Usage

``` r
putior_acp_manifest()
```

## Value

A list containing the agent manifest with name, description, and
metadata about capabilities.

## See also

Other integration:
[`putior_acp_server()`](https://pjt222.github.io/putior/reference/putior_acp_server.md),
[`putior_guide()`](https://pjt222.github.io/putior/reference/putior_guide.md),
[`putior_help()`](https://pjt222.github.io/putior/reference/putior_help.md),
[`putior_mcp_server()`](https://pjt222.github.io/putior/reference/putior_mcp_server.md),
[`putior_mcp_tools()`](https://pjt222.github.io/putior/reference/putior_mcp_tools.md)

## Examples

``` r
# Get the agent manifest
manifest <- putior_acp_manifest()
print(manifest$name)
#> [1] "putior"
print(manifest$description)
#> [1] "Workflow annotation and diagram generation agent. Extracts PUT annotations from 30+ programming languages and generates Mermaid flowchart diagrams for visualization."
```
