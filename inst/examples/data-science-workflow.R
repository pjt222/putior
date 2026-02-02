# Data Science Workflow Example: Modular Functions with source()
# ==============================================================================
# This example demonstrates the most common data science pattern: modularizing
# functions into separate scripts and orchestrating them in a main workflow.
#
# To run this example:
#   source(system.file("examples", "data-science-workflow.R", package = "putior"))
# ==============================================================================

library(putior)

cat("🔬 Data Science Workflow Example: Modular source() Pattern\n")
cat(paste(rep("=", 60), collapse = ""), "\n\n")

# Create example directory structure
temp_dir <- file.path(tempdir(), "putior_datascience_example")
dir.create(temp_dir, showWarnings = FALSE)

cat("📁 Creating modular data science workflow...\n")

# utils.R - Utility functions
utils_script <- c(
  "# Data utilities - sourced by main workflow",
  "# put label:\"Data Utilities\", node_type:\"input\"",
  "# output defaults to 'utils.R' - this script provides itself",
  "",
  "load_and_clean <- function(file_path) {",
  "  cat(\"Loading data from:\", file_path, \"\\n\")",
  "  # Simulate loading CSV data",
  "  data <- data.frame(",
  "    id = 1:100,",
  "    value = rnorm(100, 50, 10),",
  "    category = sample(c(\"A\", \"B\", \"C\"), 100, replace = TRUE),",
  "    date = seq.Date(as.Date(\"2024-01-01\"), by = \"day\", length.out = 100)",
  "  )",
  "  ",
  "  # Clean data",
  "  data <- data[complete.cases(data), ]",
  "  cat(\"Cleaned data:\", nrow(data), \"rows\\n\")",
  "  return(data)",
  "}",
  "",
  "validate_data <- function(data) {",
  "  cat(\"Validating data quality...\\n\")",
  "  stopifnot(nrow(data) > 0)",
  "  stopifnot(all(c(\"id\", \"value\", \"category\") %in% names(data)))",
  "  cat(\"Data validation passed\\n\")",
  "  return(data)",
  "}",
  "",
  "save_data <- function(data, file_path) {",
  "  write.csv(data, file_path, row.names = FALSE)",
  "  cat(\"Data saved to:\", file_path, \"\\n\")",
  "}"
)

# analysis.R - Analysis functions that depend on utils.R
analysis_script <- c(
  "# Analysis functions - sourced by main workflow, depends on utils.R",
  "# put label:\"Statistical Analysis\", node_type:\"process\", input:\"utils.R\"",
  "# input: utils.R because we use utility functions",
  "# output defaults to 'analysis.R'",
  "",
  "perform_descriptive_analysis <- function(data) {",
  "  cat(\"Performing descriptive analysis...\\n\")",
  "  # Uses validate_data() from utils.R",
  "  data <- validate_data(data)",
  "  ",
  "  summary_stats <- list(",
  "    mean_value = mean(data$value),",
  "    sd_value = sd(data$value),",
  "    n_categories = length(unique(data$category)),",
  "    date_range = range(data$date)",
  "  )",
  "  ",
  "  cat(\"Analysis complete:\\n\")",
  "  cat(\"  Mean value:\", round(summary_stats$mean_value, 2), \"\\n\")",
  "  cat(\"  Categories:\", summary_stats$n_categories, \"\\n\")",
  "  return(summary_stats)",
  "}",
  "",
  "perform_category_analysis <- function(data) {",
  "  cat(\"Analyzing by category...\\n\")",
  "  # Group analysis",
  "  category_stats <- aggregate(data$value, by = list(data$category), FUN = mean)",
  "  names(category_stats) <- c(\"category\", \"mean_value\")",
  "  return(category_stats)",
  "}"
)

# visualization.R - Plotting functions that depend on analysis.R
visualization_script <- c(
  "# Visualization functions - sourced by main workflow, depends on analysis.R",
  "# put label:\"Data Visualization\", node_type:\"process\", input:\"analysis.R\"",
  "# input: analysis.R because we use analysis results",
  "# output defaults to 'visualization.R'",
  "",
  "create_summary_plot <- function(data, output_dir) {",
  "  cat(\"Creating summary visualizations...\\n\")",
  "  ",
  "  # Create simple plots",
  "  png(file.path(output_dir, \"value_histogram.png\"))",
  "  hist(data$value, main = \"Distribution of Values\", col = \"lightblue\")",
  "  dev.off()",
  "  ",
  "  png(file.path(output_dir, \"category_boxplot.png\"))",
  "  boxplot(value ~ category, data = data, main = \"Values by Category\")",
  "  dev.off()",
  "  ",
  "  cat(\"Plots saved to:\", output_dir, \"\\n\")",
  "}",
  "",
  "create_analysis_report <- function(summary_stats, category_stats, output_file) {",
  "  cat(\"Generating analysis report...\\n\")",
  "  ",
  "  report <- c(",
  "    \"# Data Analysis Report\",",
  "    paste(\"Generated:\", Sys.time()),",
  "    \"\",",
  "    \"## Summary Statistics\",",
  "    paste(\"- Mean value:\", round(summary_stats$mean_value, 2)),",
  "    paste(\"- Standard deviation:\", round(summary_stats$sd_value, 2)),",
  "    paste(\"- Number of categories:\", summary_stats$n_categories),",
  "    \"\",",
  "    \"## Category Analysis\",",
  "    paste(capture.output(print(category_stats)), collapse = \"\\n\")",
  "  )",
  "  ",
  "  writeLines(report, output_file)",
  "  cat(\"Report saved to:\", output_file, \"\\n\")",
  "}"
)

# main.R - Main workflow orchestrator
main_script <- c(
  "# Main data science workflow - orchestrates the entire analysis",
  "# put label:\"Data Science Pipeline\", node_type:\"process\", input:\"utils.R,analysis.R,visualization.R\", output:\"analysis_report.md,plots/\"",
  "",
  "# Source all function modules",
  "source(\"utils.R\")         # Load data utility functions",
  "source(\"analysis.R\")      # Load statistical analysis functions", 
  "source(\"visualization.R\") # Load visualization functions",
  "",
  "cat(\"🚀 Starting data science pipeline...\\n\\n\")",
  "",
  "# Step 1: Data loading and cleaning",
  "cat(\"Step 1: Data Loading & Cleaning\\n\")",
  "raw_data <- load_and_clean(\"input_data.csv\")  # Uses utils.R",
  "",
  "# Step 2: Statistical analysis",
  "cat(\"\\nStep 2: Statistical Analysis\\n\")",
  "summary_stats <- perform_descriptive_analysis(raw_data)  # Uses analysis.R",
  "category_stats <- perform_category_analysis(raw_data)    # Uses analysis.R",
  "",
  "# Step 3: Data visualization",
  "cat(\"\\nStep 3: Data Visualization\\n\")",
  "plots_dir <- \"plots\"",
  "dir.create(plots_dir, showWarnings = FALSE)",
  "create_summary_plot(raw_data, plots_dir)  # Uses visualization.R",
  "",
  "# Step 4: Report generation",
  "cat(\"\\nStep 4: Report Generation\\n\")",
  "create_analysis_report(summary_stats, category_stats, \"analysis_report.md\")  # Uses visualization.R",
  "",
  "cat(\"\\n✅ Data science pipeline complete!\\n\")",
  "cat(\"📊 Results available in: analysis_report.md and plots/\\n\")"
)

# Write all files
writeLines(utils_script, file.path(temp_dir, "utils.R"))
writeLines(analysis_script, file.path(temp_dir, "analysis.R"))
writeLines(visualization_script, file.path(temp_dir, "visualization.R"))
writeLines(main_script, file.path(temp_dir, "main.R"))

cat("✅ Created modular data science workflow files\n\n")

# Extract and visualize the workflow
cat("🔍 Extracting modular workflow structure...\n")
workflow <- put(temp_dir)

cat("\n📊 Workflow structure:\n")
cat(paste(rep("-", 55), collapse = ""), "\n")

# Display the relationships
for (i in seq_len(nrow(workflow))) {
  row <- workflow[i, ]
  cat(sprintf("%-20s: %s\n", "File", row$file_name))
  cat(sprintf("%-20s: %s\n", "Label", row$label))
  cat(sprintf("%-20s: %s\n", "Type", ifelse(is.na(row$node_type), "process", row$node_type)))
  cat(sprintf("%-20s: %s\n", "Dependencies", ifelse(is.na(row$input), "none", row$input)))
  cat(sprintf("%-20s: %s\n", "Provides", row$output))
  cat(paste(rep("-", 55), collapse = ""), "\n")
}

# Generate diagram
cat("\n🎨 Modular workflow diagram:\n")
cat(paste(rep("-", 55), collapse = ""), "\n")
put_diagram(workflow, 
            theme = "github", 
            show_files = TRUE,
            title = "Data Science Modular Workflow")

cat("\n\n💡 Data Science Pattern Insights:\n")
cat(paste(rep("=", 55), collapse = ""), "\n")
cat("1. 📦 MODULARITY: Functions organized by purpose (utils, analysis, viz)\n")
cat("2. 🔗 DEPENDENCIES: Clear dependency chain (utils → analysis → viz → main)\n")
cat("3. ♻️  REUSABILITY: Utility functions can be reused across projects\n")
cat("4. 🔄 SOURCE FLOW: Scripts are sourced INTO the main workflow\n")
cat("5. 📊 DATA + CODE: Main script handles data, modules provide functions\n\n")

cat("📝 Best Practices Demonstrated:\n")
cat("• Separate concerns: data handling vs. analysis vs. visualization\n")
cat("• Clear dependencies: each module declares what it needs\n")
cat("• Function encapsulation: reusable, testable code modules\n")
cat("• Orchestration: main script coordinates the entire pipeline\n\n")

cat("🗂️ Example files created in:\n")
cat("   ", temp_dir, "\n\n")

cat("🚀 Try running the workflow:\n")
cat("   setwd(\"", temp_dir, "\")\n", sep = "")
cat("   source(\"main.R\")\n\n")

cat("✅ Data science workflow example complete!\n")

# Clean up
cat("🧹 Cleaning up...\n")
unlink(temp_dir, recursive = TRUE)