# Putior Package Example: Workflow Extraction
# ==============================================================================
# This example demonstrates putior's core functionality by creating a sample
# multi-language data workflow and extracting its structure using PUT annotations.
#
# To run this example:
#   source(system.file("examples", "reprex.R", package = "putior"))
# ==============================================================================

library(putior)

# Create temporary directory for example files
temp_dir <- file.path(tempdir(), "putior_workflow_example")
dir.create(temp_dir, showWarnings = FALSE)

cat("Creating example workflow in:", temp_dir, "\n")

# ==============================================================================
# CREATE SAMPLE WORKFLOW FILES
# ==============================================================================

# File 1: Data Collection (Python script)
# Demonstrates: input node with output annotation
file1_lines <- c(
  "# Data Collection Script",
  "#put id:\"collect_data\", label:\"Collect Raw Data\", node_type:\"input\", output:\"raw_data.csv\"",
  "",
  "import pandas as pd",
  "import requests",
  "",
  "def collect_sales_data():",
  "    \"\"\"Collect sales data from API\"\"\"",
  "    # Simulate API call",
  "    data = pd.DataFrame({",
  "        \"date\": [\"2024-01-01\", \"2024-01-02\", \"2024-01-03\"],",
  "        \"sales\": [100, 150, 120],",
  "        \"region\": [\"North\", \"South\", \"East\"]",
  "    })",
  "    data.to_csv(\"raw_data.csv\", index=False)",
  "    return data",
  "",
  "if __name__ == \"__main__\":",
  "    collect_sales_data()"
)

# File 2: Data Processing (R script)
# Demonstrates: process node with input and output annotations
file2_lines <- c(
  "# Data Processing Script",
  "#put id:\"process_data\", label:\"Clean and Transform Data\", node_type:\"process\", input:\"raw_data.csv\", output:\"processed_data.csv\"",
  "",
  "library(dplyr)",
  "library(readr)",
  "",
  "# Read raw data",
  "raw_data <- read_csv(\"raw_data.csv\")",
  "",
  "# Clean and process data",
  "processed_data <- raw_data %>%",
  "  mutate(",
  "    date = as.Date(date),",
  "    sales_category = case_when(",
  "      sales < 110 ~ \"Low\",",
  "      sales < 140 ~ \"Medium\",",
  "      TRUE ~ \"High\"",
  "    )",
  "  ) %>%",
  "  arrange(date)",
  "",
  "# Save processed data",
  "write_csv(processed_data, \"processed_data.csv\")"
)

# File 3: Analysis and Reporting (R script)
# Demonstrates: multiple PUT annotations in one file
file3_lines <- c(
  "# Analysis and Reporting Script",
  "#put id:\"create_report\", label:\"Generate Sales Report\", node_type:\"output\", input:\"processed_data.csv\", output:\"sales_report.html\"",
  "#put id:\"create_summary\", label:\"Calculate Summary Stats\", node_type:\"process\", input:\"processed_data.csv\", output:\"summary_stats.json\"",
  "",
  "library(dplyr)",
  "library(readr)",
  "library(jsonlite)",
  "",
  "# Read processed data",
  "data <- read_csv(\"processed_data.csv\")",
  "",
  "# Create summary statistics",
  "summary_stats <- list(",
  "  total_sales = sum(data$sales),",
  "  avg_sales = mean(data$sales),",
  "  sales_by_category = data %>%",
  "    count(sales_category) %>%",
  "    setNames(c(\"category\", \"count\"))",
  ")",
  "",
  "# Save summary as JSON",
  "write_json(summary_stats, \"summary_stats.json\", pretty = TRUE)",
  "",
  "# Generate HTML report (simplified)",
  "report_html <- paste0(",
  "  \"<html><body>\",",
  "  \"<h1>Sales Report</h1>\",",
  "  \"<p>Total Sales: \", summary_stats$total_sales, \"</p>\",",
  "  \"<p>Average Sales: \", round(summary_stats$avg_sales, 2), \"</p>\",",
  "  \"</body></html>\"",
  ")",
  "",
  "writeLines(report_html, \"sales_report.html\")"
)

# Write example files
writeLines(file1_lines, file.path(temp_dir, "01_collect_data.py"))
writeLines(file2_lines, file.path(temp_dir, "02_process_data.R"))
writeLines(file3_lines, file.path(temp_dir, "03_analyze_report.R"))

cat("Created", length(list.files(temp_dir)), "example files\n")

# ==============================================================================
# EXTRACT WORKFLOW USING PUTIOR
# ==============================================================================

cat("\n=== Extracting workflow with putior::put() ===\n")
workflow <- put(temp_dir)

# Display results
cat("\nWorkflow extraction results:\n")
print(workflow)

# ==============================================================================
# ANALYZE WORKFLOW STRUCTURE
# ==============================================================================

if (nrow(workflow) > 0) {
  
  cat("\n=== Workflow Analysis ===\n")
  
  # Data lineage summary
  cat("\nData Flow Summary:\n")
  inputs <- unique(workflow$input[!is.na(workflow$input)])
  outputs <- unique(workflow$output[!is.na(workflow$output)])
  
  cat("  External Inputs:", setdiff(inputs, outputs), "\n")
  cat("  Intermediate Files:", intersect(inputs, outputs), "\n") 
  cat("  Final Outputs:", setdiff(outputs, inputs), "\n")
  
  # Node types
  cat("\nNode Types:\n")
  node_types <- table(workflow$node_type)
  for (i in seq_along(node_types)) {
    cat("  ", names(node_types)[i], ":", node_types[i], "nodes\n")
  }
  
  # File types
  cat("\nFile Types:\n")
  file_types <- table(workflow$file_type)
  for (i in seq_along(file_types)) {
    cat("  ", toupper(names(file_types)[i]), ":", file_types[i], "files\n")
  }
  
  # Detailed workflow steps
  cat("\nDetailed Workflow Steps:\n")
  for (i in 1:nrow(workflow)) {
    row <- workflow[i, ]
    cat("  Step", i, ":", row$id, "\n")
    cat("    File:", row$file_name, "(", row$file_type, ")\n")
    cat("    Action:", row$label, "\n")
    cat("    Type:", row$node_type, "\n")
    if (!is.na(row$input)) cat("    Consumes:", row$input, "\n")
    if (!is.na(row$output)) cat("    Produces:", row$output, "\n")
    cat("\n")
  }
  
} else {
  cat("No workflow annotations found. Check PUT annotation syntax.\n")
}

# ==============================================================================
# CLEANUP AND NEXT STEPS
# ==============================================================================

cat("=== Example Complete ===\n")
cat("Example files location:", temp_dir, "\n")
cat("\nTo explore further:\n")
cat("1. Examine the generated files to see PUT annotation syntax\n")
cat("2. Try modifying annotations and re-running put()\n")
cat("3. Add your own workflow files with PUT annotations\n")

# Optional: Clean up temporary files
cat("\nClean up temporary files? (y/n): ")
if (interactive()) {
  response <- readline()
  if (tolower(response) == "y") {
    unlink(temp_dir, recursive = TRUE)
    cat("Temporary files removed.\n")
  } else {
    cat("Temporary files preserved for inspection.\n")
  }
} else {
  cat("(Running non-interactively - files preserved)\n")
}