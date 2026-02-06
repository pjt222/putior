# Package index

## Core Functions

Main functions for extracting annotations and creating diagrams

- [`put()`](https://pjt222.github.io/putior/reference/put.md) : Scan
  Source Files for PUT Annotations
- [`put_diagram()`](https://pjt222.github.io/putior/reference/put_diagram.md)
  : Create Mermaid Diagram from PUT Workflow
- [`print(`*`<putior_workflow>`*`)`](https://pjt222.github.io/putior/reference/print.putior_workflow.md)
  : Print a putior workflow
- [`summary(`*`<putior_workflow>`*`)`](https://pjt222.github.io/putior/reference/summary.putior_workflow.md)
  : Summarize a putior workflow

## Auto-Annotation

Automatic workflow detection and annotation generation

- [`put_auto()`](https://pjt222.github.io/putior/reference/put_auto.md)
  : Auto-Annotation Functions for putior
- [`put_generate()`](https://pjt222.github.io/putior/reference/put_generate.md)
  : Generate PUT Annotation Comments
- [`put_merge()`](https://pjt222.github.io/putior/reference/put_merge.md)
  : Merge Manual and Auto-Detected Annotations

## Language Support

Multi-language comment syntax and detection patterns

- [`get_comment_prefix()`](https://pjt222.github.io/putior/reference/get_comment_prefix.md)
  : Get Comment Prefix for File Extension
- [`get_supported_extensions()`](https://pjt222.github.io/putior/reference/get_supported_extensions.md)
  : Get All Supported File Extensions
- [`list_supported_languages()`](https://pjt222.github.io/putior/reference/list_supported_languages.md)
  : List All Supported Languages
- [`get_detection_patterns()`](https://pjt222.github.io/putior/reference/get_detection_patterns.md)
  : Get Detection Patterns for a Language
- [`ext_to_language()`](https://pjt222.github.io/putior/reference/ext_to_language.md)
  : Get Language Name from File Extension

## MCP/ACP Integration

AI assistant integration via Model Context Protocol and Agent
Communication Protocol

- [`putior_mcp_server()`](https://pjt222.github.io/putior/reference/putior_mcp_server.md)
  : Start putior MCP Server
- [`putior_mcp_tools()`](https://pjt222.github.io/putior/reference/putior_mcp_tools.md)
  : Get putior MCP Tool Definitions
- [`putior_acp_server()`](https://pjt222.github.io/putior/reference/putior_acp_server.md)
  : Start putior ACP Server
- [`putior_acp_manifest()`](https://pjt222.github.io/putior/reference/putior_acp_manifest.md)
  : Get putior ACP Agent Manifest
- [`putior_skills()`](https://pjt222.github.io/putior/reference/putior_skills.md)
  : Access putior Skills for AI Assistants
- [`putior_help()`](https://pjt222.github.io/putior/reference/putior_help.md)
  : Quick Reference Help for putior

## Interactive Tools

Interactive exploration and debugging

- [`run_sandbox()`](https://pjt222.github.io/putior/reference/run_sandbox.md)
  : Launch putior Interactive Sandbox
- [`set_putior_log_level()`](https://pjt222.github.io/putior/reference/set_putior_log_level.md)
  : Set putior Log Level

## Helper Functions

Supporting functions for processing annotations

- [`parse_put_annotation()`](https://pjt222.github.io/putior/reference/parse_put_annotation.md)
  : Extract PUT Annotation Properties
- [`validate_annotation()`](https://pjt222.github.io/putior/reference/validate_annotation.md)
  : Validate PUT annotation for common issues
- [`is_valid_put_annotation()`](https://pjt222.github.io/putior/reference/is_valid_put_annotation.md)
  : Validate PUT annotation syntax
- [`process_single_file()`](https://pjt222.github.io/putior/reference/process_single_file.md)
  : Process a single file for PUT annotations
- [`split_file_list()`](https://pjt222.github.io/putior/reference/split_file_list.md)
  : Split comma-separated file list

## Diagram Generation

Functions for creating Mermaid diagrams

- [`generate_node_definitions()`](https://pjt222.github.io/putior/reference/generate_node_definitions.md)
  : Generate node definitions for mermaid diagram
- [`generate_connections()`](https://pjt222.github.io/putior/reference/generate_connections.md)
  : Generate connections between nodes
- [`generate_node_styling()`](https://pjt222.github.io/putior/reference/generate_node_styling.md)
  : Generate node styling based on node types and theme
- [`create_artifact_nodes()`](https://pjt222.github.io/putior/reference/create_artifact_nodes.md)
  : Create artifact nodes for data files
- [`get_diagram_themes()`](https://pjt222.github.io/putior/reference/get_diagram_themes.md)
  : Get available themes for put_diagram
- [`get_theme_colors()`](https://pjt222.github.io/putior/reference/get_theme_colors.md)
  : Get color schemes for different themes (FIXED VERSION)
- [`get_node_shape()`](https://pjt222.github.io/putior/reference/get_node_shape.md)
  : Get node shape characters based on node type
- [`sanitize_node_id()`](https://pjt222.github.io/putior/reference/sanitize_node_id.md)
  : Sanitize node ID for mermaid compatibility (IMPROVED VERSION)

## Data Processing

Functions for handling results

- [`convert_results_to_df()`](https://pjt222.github.io/putior/reference/convert_results_to_df.md)
  : Convert results list to data frame
- [`empty_result_df()`](https://pjt222.github.io/putior/reference/empty_result_df.md)
  : Create empty result data frame
- [`handle_output()`](https://pjt222.github.io/putior/reference/handle_output.md)
  : Handle diagram output to different destinations
- [`parse_comma_separated_pairs()`](https://pjt222.github.io/putior/reference/parse_comma_separated_pairs.md)
  : Parse comma-separated pairs while respecting quotes
