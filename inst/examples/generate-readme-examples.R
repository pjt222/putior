#!/usr/bin/env Rscript
# Generate README.md examples using putior itself
# This ensures examples always show current themes and styling

library(putior)

cat("🔧 Generating README examples with putior...\n")

# =============================================================================
# Example 1: Basic Quick Start Workflow
# =============================================================================
cat("📊 Generating basic workflow example...\n")

basic_workflow <- data.frame(
  file_name = c("01_fetch_data.R", "02_clean_data.py"),
  id = c("fetch_sales", "clean_data"),
  label = c("Fetch Sales Data", "Clean and Process"),
  node_type = c("input", "process"),
  input = c(NA, "sales_data.csv"),
  output = c("sales_data.csv", "clean_sales.csv"),
  stringsAsFactors = FALSE
)

basic_example <- put_diagram(basic_workflow, theme = "github", output = "none")

# =============================================================================
# Example 2: Workflow Boundaries Demo  
# =============================================================================
cat("⚡ Generating workflow boundaries examples...\n")

boundary_workflow <- data.frame(
  file_name = c("start.R", "extract.R", "transform.R", "end.R"),
  id = c("pipeline_start", "extract_data", "transform_data", "pipeline_end"),
  label = c("Data Pipeline Start", "Extract Raw Data", "Transform Data", "Pipeline Complete"),
  node_type = c("start", "process", "process", "end"),
  input = c(NA, "raw_config.json", "raw_data.csv", "clean_data.csv"),
  output = c("raw_config.json", "raw_data.csv", "clean_data.csv", NA),
  stringsAsFactors = FALSE
)

# With boundaries (default)
boundary_with <- put_diagram(boundary_workflow, 
                           show_workflow_boundaries = TRUE, 
                           theme = "github", 
                           output = "none")

# Without boundaries  
boundary_without <- put_diagram(boundary_workflow, 
                              show_workflow_boundaries = FALSE, 
                              theme = "github", 
                              output = "none")

# =============================================================================
# Example 3: Data Science Pipeline
# =============================================================================
cat("📈 Generating data science pipeline example...\n")

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

datascience_example <- put_diagram(datascience_workflow, theme = "github", output = "none")

# =============================================================================
# Example 4: Theme Showcase
# =============================================================================
cat("🎨 Generating theme examples...\n")

theme_workflow <- data.frame(
  file_name = c("fetch.R", "process.R", "report.R"),
  id = c("fetch_data", "clean_data", "generate_report"),
  label = c("Fetch API Data", "Clean and Validate", "Generate Final Report"),
  node_type = c("input", "process", "output"),
  input = c(NA, "raw_data.csv", "clean_data.csv"),
  output = c("raw_data.csv", "clean_data.csv", "final_report.html"),
  stringsAsFactors = FALSE
)

# Generate all theme examples
themes <- c("light", "dark", "auto", "github", "minimal")
theme_examples <- list()

for (theme in themes) {
  cat("  🎨 Generating", theme, "theme...\n")
  theme_examples[[theme]] <- put_diagram(theme_workflow, 
                                        theme = theme, 
                                        output = "none")
}

# =============================================================================
# Example 5: Modular Source Workflow
# =============================================================================
cat("📦 Generating modular source workflow...\n")

modular_workflow <- data.frame(
  file_name = c("utils.R", "analysis.R", "main.R"),
  id = c("utils", "analysis", "main"),
  label = c("Data Utilities", "Statistical Analysis", "Main Analysis Pipeline"),
  node_type = c("input", "process", "process"),
  input = c(NA, "utils.R", "utils.R,analysis.R"),
  output = c("utils.R", "analysis.R", "results.csv"),
  stringsAsFactors = FALSE
)

# Simple mode
modular_simple <- put_diagram(modular_workflow, theme = "github", output = "none")

# Artifact mode
modular_artifacts <- put_diagram(modular_workflow, 
                                show_artifacts = TRUE, 
                                theme = "github", 
                                output = "none")

# =============================================================================
# Example 6: Simple vs Artifact Comparison
# =============================================================================
cat("🔄 Generating simple vs artifact comparison...\n")

comparison_workflow <- data.frame(
  file_name = c("load.R", "process.R", "analyze.R"),
  id = c("load", "process", "analyze"),
  label = c("Load Data", "Process Data", "Analyze"),
  node_type = c("input", "process", "output"),
  input = c(NA, "raw_data.csv", "clean_data.csv"),
  output = c("raw_data.csv", "clean_data.csv", "results.json"),
  stringsAsFactors = FALSE
)

# Simple mode
comparison_simple <- put_diagram(comparison_workflow, 
                                show_artifacts = FALSE, 
                                theme = "github", 
                                output = "none")

# Artifact mode
comparison_artifacts <- put_diagram(comparison_workflow, 
                                   show_artifacts = TRUE, 
                                   theme = "github", 
                                   output = "none")

# =============================================================================
# Output Results
# =============================================================================
cat("\n✅ Generated all examples!\n\n")

cat("📋 Example outputs:\n")
cat("==================\n")

examples <- list(
  "Basic Workflow" = basic_example,
  "Boundaries Enabled" = boundary_with,
  "Boundaries Disabled" = boundary_without,
  "Data Science Pipeline" = datascience_example,
  "Modular Simple" = modular_simple,
  "Modular Artifacts" = modular_artifacts,
  "Comparison Simple" = comparison_simple,
  "Comparison Artifacts" = comparison_artifacts
)

# Add theme examples
for (theme in themes) {
  examples[[paste("Theme:", theme)]] <- theme_examples[[theme]]
}

# Save examples to a structured list for potential README integration
saveRDS(examples, "readme_examples.rds")

cat("💾 Saved examples to readme_examples.rds\n")
cat("🎯 Ready for README integration!\n")

# Print first example as demonstration
cat("\n📖 Sample output (Basic Workflow):\n")
cat("```mermaid\n")
cat(basic_example)
cat("\n```\n")