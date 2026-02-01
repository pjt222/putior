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

## Examples

``` r
# Get the agent manifest
manifest <- putior_acp_manifest()
print(manifest$name)
#> [1] "putior"
print(manifest$description)
#> [1] "Workflow annotation and diagram generation agent. Extracts PUT annotations from 30+ programming languages and generates Mermaid flowchart diagrams for visualization."
```
