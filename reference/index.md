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

## Utilities

Helper and validation functions

- [`is_valid_put_annotation()`](https://pjt222.github.io/putior/reference/is_valid_put_annotation.md)
  : Validate PUT annotation syntax
- [`split_file_list()`](https://pjt222.github.io/putior/reference/split_file_list.md)
  : Split comma-separated file list
- [`get_diagram_themes()`](https://pjt222.github.io/putior/reference/get_diagram_themes.md)
  : Get available themes for put_diagram

## Internal Functions

Internal implementation details (not part of the public API)

- [`LANGUAGE_GROUPS`](https://pjt222.github.io/putior/reference/LANGUAGE_GROUPS.md)
  : Language Groups by Comment Syntax
- [`as_putior_workflow()`](https://pjt222.github.io/putior/reference/as_putior_workflow.md)
  : Add putior_workflow class to a data frame
- [`build_file_pattern()`](https://pjt222.github.io/putior/reference/build_file_pattern.md)
  : Build File Pattern for Supported Extensions
- [`convert_results_to_df()`](https://pjt222.github.io/putior/reference/convert_results_to_df.md)
  : Convert results list to data frame
- [`create_artifact_nodes()`](https://pjt222.github.io/putior/reference/create_artifact_nodes.md)
  : Create artifact nodes for data files
- [`detect_files_from_patterns()`](https://pjt222.github.io/putior/reference/detect_files_from_patterns.md)
  : Detect files from pattern list
- [`detect_workflow_elements()`](https://pjt222.github.io/putior/reference/detect_workflow_elements.md)
  : Detect workflow elements in a single file
- [`detection_patterns`](https://pjt222.github.io/putior/reference/detection_patterns.md)
  : Detection Pattern Definitions for Auto-Annotation
- [`empty_auto_result_df()`](https://pjt222.github.io/putior/reference/empty_auto_result_df.md)
  : Create empty result data frame for put_auto
- [`empty_result_df()`](https://pjt222.github.io/putior/reference/empty_result_df.md)
  : Create empty result data frame
- [`extract_file_path()`](https://pjt222.github.io/putior/reference/extract_file_path.md)
  : Extract file path from a matched string (legacy function)
- [`extract_file_path_from_line()`](https://pjt222.github.io/putior/reference/extract_file_path_from_line.md)
  : Extract file path from a line containing a matched function call
- [`generate_annotation_for_file()`](https://pjt222.github.io/putior/reference/generate_annotation_for_file.md)
  : Generate annotation text for a single file
- [`generate_click_directives()`](https://pjt222.github.io/putior/reference/generate_click_directives.md)
  : Generate Mermaid click directives
- [`generate_click_url()`](https://pjt222.github.io/putior/reference/generate_click_url.md)
  : Generate click URL based on protocol
- [`generate_connections()`](https://pjt222.github.io/putior/reference/generate_connections.md)
  : Generate connections between nodes
- [`generate_file_subgraphs()`](https://pjt222.github.io/putior/reference/generate_file_subgraphs.md)
  : Generate file-based subgraphs
- [`generate_node_definitions()`](https://pjt222.github.io/putior/reference/generate_node_definitions.md)
  : Generate node definitions for mermaid diagram
- [`generate_node_styling()`](https://pjt222.github.io/putior/reference/generate_node_styling.md)
  : Generate node styling based on node types and theme
- [`get_c_patterns()`](https://pjt222.github.io/putior/reference/get_c_patterns.md)
  : Get C Detection Patterns
- [`get_comment_group()`](https://pjt222.github.io/putior/reference/get_comment_group.md)
  : Get Comment Syntax Group for Extension
- [`get_cpp_patterns()`](https://pjt222.github.io/putior/reference/get_cpp_patterns.md)
  : Get C++ Detection Patterns
- [`get_dockerfile_patterns()`](https://pjt222.github.io/putior/reference/get_dockerfile_patterns.md)
  : Get Dockerfile Detection Patterns
- [`get_go_patterns()`](https://pjt222.github.io/putior/reference/get_go_patterns.md)
  : Get Go Detection Patterns
- [`get_java_patterns()`](https://pjt222.github.io/putior/reference/get_java_patterns.md)
  : Get Java Detection Patterns
- [`get_javascript_patterns()`](https://pjt222.github.io/putior/reference/get_javascript_patterns.md)
  : Get JavaScript Detection Patterns
- [`get_julia_patterns()`](https://pjt222.github.io/putior/reference/get_julia_patterns.md)
  : Get Julia Detection Patterns
- [`get_lua_patterns()`](https://pjt222.github.io/putior/reference/get_lua_patterns.md)
  : Get Lua Detection Patterns
- [`get_makefile_patterns()`](https://pjt222.github.io/putior/reference/get_makefile_patterns.md)
  : Get Makefile Detection Patterns
- [`get_matlab_patterns()`](https://pjt222.github.io/putior/reference/get_matlab_patterns.md)
  : Get MATLAB Detection Patterns
- [`get_node_shape()`](https://pjt222.github.io/putior/reference/get_node_shape.md)
  : Get node shape characters based on node type
- [`get_python_patterns()`](https://pjt222.github.io/putior/reference/get_python_patterns.md)
  : Get Python Detection Patterns
- [`get_r_patterns()`](https://pjt222.github.io/putior/reference/get_r_patterns.md)
  : Get R Detection Patterns
- [`get_ruby_patterns()`](https://pjt222.github.io/putior/reference/get_ruby_patterns.md)
  : Get Ruby Detection Patterns
- [`get_rust_patterns()`](https://pjt222.github.io/putior/reference/get_rust_patterns.md)
  : Get Rust Detection Patterns
- [`get_shell_patterns()`](https://pjt222.github.io/putior/reference/get_shell_patterns.md)
  : Get Shell Detection Patterns
- [`get_sql_patterns()`](https://pjt222.github.io/putior/reference/get_sql_patterns.md)
  : Get SQL Detection Patterns
- [`get_theme_colors()`](https://pjt222.github.io/putior/reference/get_theme_colors.md)
  : Get color schemes for different themes (FIXED VERSION)
- [`get_typescript_patterns()`](https://pjt222.github.io/putior/reference/get_typescript_patterns.md)
  : Get TypeScript Detection Patterns
- [`get_wgsl_patterns()`](https://pjt222.github.io/putior/reference/get_wgsl_patterns.md)
  : Get WGSL Detection Patterns
- [`handle_output()`](https://pjt222.github.io/putior/reference/handle_output.md)
  : Handle diagram output to different destinations
- [`has_logger()`](https://pjt222.github.io/putior/reference/has_logger.md)
  : Check if Logger is Available
- [`infer_node_type()`](https://pjt222.github.io/putior/reference/infer_node_type.md)
  : Infer node type from inputs and outputs
- [`insert_annotation_into_file()`](https://pjt222.github.io/putior/reference/insert_annotation_into_file.md)
  : Insert annotation at top of file
- [`is_likely_file_path()`](https://pjt222.github.io/putior/reference/is_likely_file_path.md)
  : Check if a string looks like a file path
- [`language_registry`](https://pjt222.github.io/putior/reference/language_registry.md)
  : Language Comment Syntax Registry
- [`merge_annotations()`](https://pjt222.github.io/putior/reference/merge_annotations.md)
  : Merge manual and auto-detected annotations
- [`normalize_path_for_url()`](https://pjt222.github.io/putior/reference/normalize_path_for_url.md)
  : Normalize file path for URL generation
- [`parse_comma_separated_pairs()`](https://pjt222.github.io/putior/reference/parse_comma_separated_pairs.md)
  : Parse comma-separated pairs while respecting quotes
- [`parse_put_annotation()`](https://pjt222.github.io/putior/reference/parse_put_annotation.md)
  : Extract PUT Annotation Properties
- [`process_single_file()`](https://pjt222.github.io/putior/reference/process_single_file.md)
  : Process a single file for PUT annotations
- [`putior-package`](https://pjt222.github.io/putior/reference/putior-package.md)
  : putior Package Initialization
- [`putior_acp`](https://pjt222.github.io/putior/reference/putior_acp.md)
  : ACP Server Integration for putior
- [`putior_log()`](https://pjt222.github.io/putior/reference/putior_log.md)
  : Internal Logging Function
- [`putior_logging`](https://pjt222.github.io/putior/reference/putior_logging.md)
  : Logging Infrastructure for putior
- [`putior_mcp`](https://pjt222.github.io/putior/reference/putior_mcp.md)
  : MCP Server Integration for putior
- [`resolve_label()`](https://pjt222.github.io/putior/reference/resolve_label.md)
  : Resolve label text for a workflow node
- [`sanitize_node_id()`](https://pjt222.github.io/putior/reference/sanitize_node_id.md)
  : Sanitize node ID for mermaid compatibility (IMPROVED VERSION)
- [`validate_annotation()`](https://pjt222.github.io/putior/reference/validate_annotation.md)
  : Validate PUT annotation for common issues
- [`with_log_level()`](https://pjt222.github.io/putior/reference/with_log_level.md)
  : Temporarily Set Log Level for a Code Block
