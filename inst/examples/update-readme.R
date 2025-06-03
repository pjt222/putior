#!/usr/bin/env Rscript
# Update README.md with current putior-generated examples
# This ensures documentation always reflects current styling and features

library(putior)

cat("📝 Updating README.md with current putior examples...\n")

# Read current README
readme_path <- "README.md"
if (!file.exists(readme_path)) {
  stop("README.md not found. Run from project root directory.")
}

readme_lines <- readLines(readme_path)

# =============================================================================
# Helper function to replace mermaid blocks
# =============================================================================
replace_mermaid_block <- function(lines, start_pattern, new_content, context = "") {
  # Find the start line
  start_idx <- grep(start_pattern, lines, fixed = TRUE)
  
  if (length(start_idx) == 0) {
    cat("⚠️  Could not find pattern:", start_pattern, "\n")
    return(lines)
  }
  
  if (length(start_idx) > 1) {
    cat("⚠️  Multiple matches for pattern. Using first:", start_pattern, "\n")
    start_idx <- start_idx[1]
  }
  
  # Find the mermaid block after the start pattern
  mermaid_start <- which(grepl("```mermaid", lines[start_idx:length(lines)]))[1]
  if (is.na(mermaid_start)) {
    cat("⚠️  No mermaid block found after pattern:", start_pattern, "\n")
    return(lines)
  }
  mermaid_start <- start_idx + mermaid_start - 1
  
  # Find the end of the mermaid block
  mermaid_end <- which(grepl("```$", lines[mermaid_start:length(lines)]))[1]
  if (is.na(mermaid_end)) {
    cat("⚠️  No mermaid block end found after start\n")
    return(lines)
  }
  mermaid_end <- mermaid_start + mermaid_end - 1
  
  cat("🔄 Updating", context, "at lines", mermaid_start, "-", mermaid_end, "\n")
  
  # Replace the content
  new_lines <- c(
    lines[1:(mermaid_start)],  # Keep up to and including ```mermaid
    new_content,               # Insert new mermaid content  
    lines[mermaid_end:length(lines)]  # Keep from ``` onward
  )
  
  return(new_lines)
}

# =============================================================================
# Generate updated examples
# =============================================================================

# 1. Basic Quick Start Example
cat("📊 Updating basic workflow example...\n")
basic_workflow <- data.frame(
  file_name = c("01_fetch_data.R", "02_clean_data.py"),
  id = c("fetch_sales", "clean_data"), 
  label = c("Fetch Sales Data", "Clean and Process"),
  node_type = c("input", "process"),
  input = c(NA, "sales_data.csv"),
  output = c("sales_data.csv", "clean_sales.csv"),
  stringsAsFactors = FALSE
)

basic_mermaid <- put_diagram(basic_workflow, theme = "github", output = "none")
readme_lines <- replace_mermaid_block(readme_lines, "**Result:**", basic_mermaid, "Quick Start example")

# 2. Workflow Boundaries Demo
cat("⚡ Updating workflow boundaries examples...\n")
boundary_workflow <- data.frame(
  file_name = c("start.R", "extract.R", "transform.R", "end.R"),
  id = c("pipeline_start", "extract_data", "transform_data", "pipeline_end"),
  label = c("Data Pipeline Start", "Extract Raw Data", "Transform Data", "Pipeline Complete"),
  node_type = c("start", "process", "process", "end"),
  input = c(NA, "raw_config.json", "raw_data.csv", "clean_data.csv"),
  output = c("raw_config.json", "raw_data.csv", "clean_data.csv", NA),
  stringsAsFactors = FALSE
)

# Update the workflow boundaries with boundaries example
boundary_with_mermaid <- put_diagram(boundary_workflow, 
                                   show_workflow_boundaries = TRUE, 
                                   theme = "github", 
                                   output = "none")
readme_lines <- replace_mermaid_block(readme_lines, "**Pipeline with Boundaries (Default):**", 
                                    boundary_with_mermaid, "Workflow boundaries enabled")

# Update the workflow boundaries without boundaries example  
boundary_without_mermaid <- put_diagram(boundary_workflow, 
                                      show_workflow_boundaries = FALSE, 
                                      theme = "github", 
                                      output = "none")
readme_lines <- replace_mermaid_block(readme_lines, "**Same Pipeline without Boundaries:**", 
                                    boundary_without_mermaid, "Workflow boundaries disabled")

# 3. Data Science Pipeline
cat("📈 Updating data science pipeline example...\n")
datascience_workflow <- data.frame(
  file_name = c("01_fetch_sales.R", "02_fetch_customers.R", "03_clean_sales.py", 
                "04_merge_data.R", "05_analyze.py", "06_report.R"),
  id = c("fetch_sales", "fetch_customers", "clean_sales", "merge_data", "analyze", "report"),
  label = c("Fetch Sales Data", "Fetch Customer Data", "Clean Sales Data", 
            "Merge Datasets", "Statistical Analysis", "Generate Final Report"),
  node_type = c("input", "input", "process", "process", "process", "output"),
  input = c(NA, NA, "sales_data.csv", "customers.csv,clean_sales.csv", "merged_data.csv", "analysis_results.csv"),
  output = c("sales_data.csv", "customers.csv", "clean_sales.csv", "merged_data.csv", "analysis_results.csv", "final_report.pdf"),
  stringsAsFactors = FALSE
)

datascience_mermaid <- put_diagram(datascience_workflow, theme = "github", output = "none")
readme_lines <- replace_mermaid_block(readme_lines, "**Generated Workflow:**", 
                                    datascience_mermaid, "Data science pipeline")

# 4. Modular Workflow Examples
cat("📦 Updating modular workflow examples...\n")
modular_workflow <- data.frame(
  file_name = c("utils.R", "analysis.R", "main.R"),
  id = c("utils", "analysis", "main"),
  label = c("Data Utilities", "Statistical Analysis", "Main Analysis Pipeline"),
  node_type = c("input", "process", "process"),
  input = c(NA, "utils.R", "utils.R,analysis.R"),
  output = c("utils.R", "analysis.R", "results.csv"),
  stringsAsFactors = FALSE
)

# Simple modular workflow
modular_simple_mermaid <- put_diagram(modular_workflow, theme = "github", output = "none")
readme_lines <- replace_mermaid_block(readme_lines, "**Generated Workflow (Simple):**", 
                                    modular_simple_mermaid, "Modular workflow simple")

# Artifact modular workflow  
modular_artifacts_mermaid <- put_diagram(modular_workflow, 
                                       show_artifacts = TRUE, 
                                       theme = "github", 
                                       output = "none")
readme_lines <- replace_mermaid_block(readme_lines, "**Generated Workflow (With Data Artifacts):**", 
                                    modular_artifacts_mermaid, "Modular workflow with artifacts")

# 5. Theme Examples
cat("🎨 Updating theme examples...\n")
theme_workflow <- data.frame(
  file_name = c("fetch.R", "process.R", "report.R"),
  id = c("fetch_data", "clean_data", "generate_report"),
  label = c("Fetch API Data", "Clean and Validate", "Generate Final Report"),
  node_type = c("input", "process", "output"),
  input = c(NA, "raw_data.csv", "clean_data.csv"),
  output = c("raw_data.csv", "clean_data.csv", "final_report.html"),
  stringsAsFactors = FALSE
)

# Light theme
light_mermaid <- put_diagram(theme_workflow, theme = "light", output = "none")
readme_lines <- replace_mermaid_block(readme_lines, "**Light Theme**", 
                                    light_mermaid, "Light theme example")

# Dark theme
dark_mermaid <- put_diagram(theme_workflow, theme = "dark", output = "none")
readme_lines <- replace_mermaid_block(readme_lines, "**Dark Theme**", 
                                    dark_mermaid, "Dark theme example")

# Auto theme
auto_mermaid <- put_diagram(theme_workflow, theme = "auto", output = "none")
readme_lines <- replace_mermaid_block(readme_lines, "**Auto Theme (GitHub Adaptive)**", 
                                    auto_mermaid, "Auto theme example")

# GitHub theme
github_mermaid <- put_diagram(theme_workflow, theme = "github", output = "none")
readme_lines <- replace_mermaid_block(readme_lines, "**GitHub Theme (Maximum Compatibility)**", 
                                    github_mermaid, "GitHub theme example")

# Minimal theme
minimal_mermaid <- put_diagram(theme_workflow, theme = "minimal", output = "none")
readme_lines <- replace_mermaid_block(readme_lines, "**Minimal Theme**", 
                                    minimal_mermaid, "Minimal theme example")

# =============================================================================
# Write updated README
# =============================================================================
writeLines(readme_lines, readme_path)

cat("\n✅ README.md updated with current putior examples!\n")
cat("🎨 All Mermaid diagrams now show current theme colors and styling\n")
cat("⚡ Workflow boundaries show new orange start / green end scheme\n")
cat("📊 Examples generated with putior version:", as.character(packageVersion("putior")), "\n")