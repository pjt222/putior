# Multiline PUT Annotation Example
# 
# This example demonstrates how to use multiline annotations 
# for better code style compliance when dealing with long lists
# of input/output files.

library(putior)

# Create temporary directory for example
temp_dir <- tempdir()
example_dir <- file.path(temp_dir, "multiline_example")
dir.create(example_dir, showWarnings = FALSE)

# Example 1: Traditional single-line annotation (can get very long)
single_line_content <- c(
  "# Traditional approach - can be very long and violate style guidelines",
  "#put id:\"data_merger\", label:\"Merge Multiple Data Sources\", node_type:\"process\", input:\"sales_data.csv,customer_data.csv,product_data.csv,inventory_data.csv,returns_data.csv\", output:\"merged_dataset.csv\"",
  "",
  "# Simulate data merging code",
  "cat(\"Merging multiple data sources...\\n\")"
)

# Example 2: Multiline annotation (more readable and style-compliant)
multiline_content <- c(
  "# Multiline approach - readable and follows style guidelines",
  "#put id:\"data_processor\", \\",
  "#    label:\"Advanced Data Processing Pipeline\", \\",
  "#    node_type:\"process\", \\",
  "#    input:\"raw_sales.csv,customer_profiles.csv,product_catalog.csv,inventory_status.csv,returns_log.csv\", \\",
  "#    output:\"processed_dataset.csv,summary_report.csv\"",
  "",
  "# Simulate advanced processing code",
  "cat(\"Processing data with complex transformations...\\n\")",
  "",
  "# Another multiline example",
  "#put id:\"visualization_generator\", \\",
  "#    label:\"Generate Comprehensive Visualizations\", \\",
  "#    node_type:\"output\", \\",
  "#    input:\"processed_dataset.csv,summary_report.csv\", \\",
  "#    output:\"dashboard.html,charts.png,summary_plots.pdf\"",
  "",
  "cat(\"Generating visualizations...\\n\")"
)

# Write example files
writeLines(single_line_content, file.path(example_dir, "01_single_line.R"))
writeLines(multiline_content, file.path(example_dir, "02_multiline.R"))

# Extract workflow from both approaches
cat("\\n=== Extracting PUT annotations ===\\n")
workflow <- put(example_dir)

# Display results
cat("\\nFound", nrow(workflow), "annotations:\\n")
for (i in 1:nrow(workflow)) {
  cat("\\n", i, ". ID:", workflow$id[i], "\\n")
  cat("   Label:", workflow$label[i], "\\n")
  cat("   Input:", workflow$input[i], "\\n")
  cat("   Output:", workflow$output[i], "\\n")
}

# Generate diagram
cat("\\n=== Generated Mermaid Diagram ===\\n")
diagram <- put_diagram(workflow, theme = "minimal")
cat(diagram)

# Key benefits of multiline annotations:
cat("\\n\\n=== Benefits of Multiline Annotations ===\\n")
cat("1. Better code readability\\n")
cat("2. Compliance with style guidelines (e.g., styler)\\n")
cat("3. Easier maintenance of long parameter lists\\n")
cat("4. Consistent indentation with surrounding code\\n")
cat("5. No change to existing functionality\\n")

# Cleanup
unlink(example_dir, recursive = TRUE)
cat("\\nExample completed! Temporary files cleaned up.\\n")