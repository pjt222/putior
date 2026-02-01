# =============================================================================
# Interactive Diagrams Example - Metadata Display and Clickable Hyperlinks
# =============================================================================
#
# This example demonstrates the new interactive diagram features added in putior:
# 1. Metadata Display (show_source_info) - Shows source file information in nodes
# 2. Clickable Hyperlinks (enable_clicks) - Makes nodes clickable to open files
#
# These features address GitHub Issues #3 and #4.
#
# =============================================================================

library(putior)

# -----------------------------------------------------------------------------
# Sample Workflow Setup
# -----------------------------------------------------------------------------

# Create a sample workflow with multiple files
# In real usage, you would use: workflow <- put("./your-project/")

sample_workflow <- data.frame(
  file_name = c(
    "scripts/01_load_data.R",
    "scripts/02_clean_data.py",
    "scripts/03_analyze.R",
    "scripts/04_visualize.R",
    "scripts/05_report.R"
  ),
  id = c("load", "clean", "analyze", "visualize", "report"),
  label = c(
    "Load Raw Data",
    "Clean and Transform",
    "Statistical Analysis",
    "Create Visualizations",
    "Generate Report"
  ),
  node_type = c("input", "process", "process", "process", "output"),
  input = c(NA, "raw_data.csv", "clean_data.csv", "analysis.rds", "plots.rds"),
  output = c("raw_data.csv", "clean_data.csv", "analysis.rds", "plots.rds", "report.html"),
  line_number = c(5, 12, 8, 15, 22),  # Line numbers where annotations appear
  stringsAsFactors = FALSE
)

# -----------------------------------------------------------------------------
# Feature 1: Metadata Display (show_source_info)
# -----------------------------------------------------------------------------

cat("\n=== Metadata Display Examples ===\n\n")

# Basic usage - inline source file info
cat("1. Inline source info (default style):\n")
cat("   Shows file name in small text below the node label\n\n")
put_diagram(
  sample_workflow,
  show_source_info = TRUE,
  source_info_style = "inline"  # default
)

cat("\n\n2. Subgraph style - groups nodes by source file:\n")
cat("   Creates visual containers for nodes from the same file\n\n")
put_diagram(
  sample_workflow,
  show_source_info = TRUE,
  source_info_style = "subgraph"
)

# -----------------------------------------------------------------------------
# Feature 2: Clickable Hyperlinks (enable_clicks)
# -----------------------------------------------------------------------------

cat("\n\n=== Clickable Hyperlinks Examples ===\n\n")

# VS Code (default protocol)
cat("3. VS Code clickable nodes:\n")
cat("   Clicking a node opens the file in VS Code at the specified line\n\n")
put_diagram(
  sample_workflow,
  enable_clicks = TRUE,
  click_protocol = "vscode"  # default
)

# RStudio protocol
cat("\n\n4. RStudio clickable nodes:\n")
cat("   Clicking a node opens the file in RStudio\n\n")
put_diagram(
  sample_workflow,
  enable_clicks = TRUE,
  click_protocol = "rstudio"
)

# File protocol (browser/system default)
cat("\n\n5. Standard file:// protocol:\n")
cat("   Opens files using the system's default handler\n\n")
put_diagram(
  sample_workflow,
  enable_clicks = TRUE,
  click_protocol = "file"
)

# -----------------------------------------------------------------------------
# Combined Features
# -----------------------------------------------------------------------------

cat("\n\n=== Combined Features ===\n\n")

cat("6. Full interactive diagram with source info and clicks:\n")
cat("   Shows file info inline AND makes nodes clickable\n\n")
put_diagram(
  sample_workflow,
  show_source_info = TRUE,
  enable_clicks = TRUE,
  click_protocol = "vscode"
)

# -----------------------------------------------------------------------------
# Saving Interactive Diagrams
# -----------------------------------------------------------------------------

cat("\n\n=== Saving Interactive Diagrams ===\n\n")

# Save to file for embedding in documentation
temp_file <- tempfile(fileext = ".md")
put_diagram(
  sample_workflow,
  show_source_info = TRUE,
  enable_clicks = TRUE,
  output = "file",
  file = temp_file,
  title = "Interactive Project Workflow"
)

cat("Diagram saved to:", temp_file, "\n")
cat("Content preview:\n")
cat(readLines(temp_file, n = 20), sep = "\n")
cat("\n...\n")

# Clean up
unlink(temp_file)

# -----------------------------------------------------------------------------
# Tips for Using Interactive Features
# -----------------------------------------------------------------------------

cat("\n\n=== Tips ===\n\n")
cat("1. Mermaid click directives work in many viewers:\n")
cat("   - GitHub README files\n")
cat("   - GitLab wikis\n")
cat("   - Obsidian notes\n")
cat("   - Some Markdown editors\n\n")

cat("2. For VS Code to handle vscode:// URLs, ensure:\n")
cat("   - VS Code is your registered protocol handler\n")
cat("   - The file paths are accessible from your system\n\n")

cat("3. Line numbers are included when available:\n")
cat("   - The put() function extracts line_number from annotations\n")
cat("   - Click URLs will jump to the specific line\n\n")

cat("4. For subgraph style, nodes are grouped by file:\n")
cat("   - Useful for large workflows spanning many files\n")
cat("   - Each subgraph is labeled with the file name\n\n")

cat("5. Both features are backward compatible:\n")
cat("   - show_source_info defaults to FALSE\n")
cat("   - enable_clicks defaults to FALSE\n")
cat("   - Existing code continues to work unchanged\n")
