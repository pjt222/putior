#!/usr/bin/env Rscript
# Example: How putior documents its own workflow
# This demonstrates how to add PUT annotations to your own R package

library(putior)

# Scan the putior package itself for PUT annotations
cat("Scanning putior package for workflow annotations...\n\n")
workflow <- put('./R/')

# Show the extracted workflow data
cat("Extracted workflow data:\n")
print(workflow)

cat("\n\n=== Simple Script-to-Script View ===\n")
# Generate a simple diagram showing only script connections
put_diagram(workflow, 
            title = "Putior Package Workflow", 
            show_workflow_boundaries = TRUE)

cat("\n\n=== Complete Data Flow View ===\n")
# Generate a complete diagram showing all data artifacts
put_diagram(workflow, 
            title = "Putior Data Flow with Artifacts",
            show_artifacts = TRUE,
            show_workflow_boundaries = TRUE)

cat("\n\n=== GitHub-optimized Diagram ===\n")
# Generate a GitHub-friendly diagram
put_diagram(workflow,
            title = "Putior Workflow (GitHub Theme)",
            theme = "github",
            show_workflow_boundaries = TRUE)

# Explanation of the workflow
cat("\n\nWorkflow Explanation:\n")
cat("1. put() function (start) - Entry point that scans files for annotations\n")
cat("2. process_file() - Processes each file to extract annotations\n")
cat("3. parse_put_annotation() - Parses the PUT syntax into properties\n")
cat("4. validate_annotation() - Validates annotation syntax and values\n")
cat("5. convert_results_to_df() - Converts results to a data frame\n")
cat("6. put_diagram() - Generates Mermaid diagram from workflow data\n")
cat("7. generate_node_definitions() - Creates node definitions\n")
cat("8. generate_connections() - Creates edges between nodes\n")
cat("9. generate_node_styling() - Applies theme styling\n")
cat("10. handle_output() (end) - Outputs the final diagram\n")