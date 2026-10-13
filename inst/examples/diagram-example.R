# Putior Diagram Example: Workflow Visualization with Mermaid
# ==============================================================================
# This example demonstrates putior's visualization capabilities by creating
# a sample workflow and generating elegant mermaid diagrams.
#
# To run this example:
#   source(system.file("examples", "diagram-example.R", package = "putior"))
# ==============================================================================

library(putior)

cat("🎨 Putior Diagram Example: Workflow Visualization\n")
cat(paste(rep("=", 50), collapse = ""), "\n\n")

# Create a sample workflow for demonstration
temp_dir <- file.path(tempdir(), "putior_diagram_example")
dir.create(temp_dir, showWarnings = FALSE)

cat("📁 Creating sample workflow files...\n")

# File 1: Data Collection (Python)
data_collection <- c(
  "# Data Collection from Multiple Sources",
  "# put id:\"fetch_sales\", label:\"Fetch Sales Data\", node_type:\"input\", output:\"raw_sales.csv\"",
  "# put id:\"fetch_customers\", label:\"Fetch Customer Data\", node_type:\"input\", output:\"raw_customers.csv\"",
  "",
  "import pandas as pd",
  "import requests",
  "",
  "# Fetch sales data",
  "sales_data = fetch_api_data('/sales')",
  "sales_data.to_csv('raw_sales.csv')",
  "",
  "# Fetch customer data", 
  "customer_data = fetch_api_data('/customers')",
  "customer_data.to_csv('raw_customers.csv')"
)

# File 2: Data Processing (R)
data_processing <- c(
  "# Data Cleaning and Integration", 
  "# put id:\"clean_sales\", label:\"Clean Sales Data\", node_type:\"process\", input:\"raw_sales.csv\", output:\"clean_sales.csv\"",
  "# put id:\"clean_customers\", label:\"Clean Customer Data\", node_type:\"process\", input:\"raw_customers.csv\", output:\"clean_customers.csv\"",
  "# put id:\"merge_data\", label:\"Merge Datasets\", node_type:\"process\", input:\"clean_sales.csv,clean_customers.csv\", output:\"merged_data.csv\"",
  "",
  "library(dplyr)",
  "library(readr)",
  "",
  "# Clean sales data",
  "sales <- read_csv('raw_sales.csv') %>%",
  "  filter(!is.na(amount)) %>%",
  "  mutate(date = as.Date(date))",
  "write_csv(sales, 'clean_sales.csv')",
  "",
  "# Clean customer data",
  "customers <- read_csv('raw_customers.csv') %>%",
  "  filter(!is.na(customer_id))",
  "write_csv(customers, 'clean_customers.csv')",
  "",
  "# Merge datasets",
  "merged <- sales %>%",
  "  left_join(customers, by = 'customer_id')",
  "write_csv(merged, 'merged_data.csv')"
)

# File 3: Analysis and Decision Making (R)
analysis <- c(
  "# Statistical Analysis and Decision Making",
  "# put id:\"analyze_trends\", label:\"Analyze Trends\", node_type:\"process\", input:\"merged_data.csv\", output:\"trend_analysis.rds\"",
  "# put id:\"quality_check\", label:\"Data Quality Check\", node_type:\"decision\", input:\"merged_data.csv\", output:\"quality_report.json\"",
  "# put id:\"generate_insights\", label:\"Generate Insights\", node_type:\"process\", input:\"trend_analysis.rds\", output:\"insights.rds\"",
  "",
  "library(dplyr)",
  "",
  "# Analyze trends",
  "data <- read_csv('merged_data.csv')",
  "trends <- analyze_time_series(data)",
  "saveRDS(trends, 'trend_analysis.rds')",
  "",
  "# Quality check",
  "quality <- check_data_quality(data)",
  "write_json(quality, 'quality_report.json')",
  "",
  "# Generate insights",
  "trends <- readRDS('trend_analysis.rds')",
  "insights <- generate_business_insights(trends)",
  "saveRDS(insights, 'insights.rds')"
)

# File 4: Reporting (R)
reporting <- c(
  "# Report Generation and Distribution",
  "# put id:\"create_dashboard\", label:\"Create Dashboard\", node_type:\"output\", input:\"insights.rds\", output:\"dashboard.html\"",
  "# put id:\"executive_summary\", label:\"Executive Summary\", node_type:\"output\", input:\"insights.rds\", output:\"executive_summary.pdf\"",
  "# put id:\"data_export\", label:\"Export Data\", node_type:\"output\", input:\"merged_data.csv\", output:\"final_dataset.xlsx\"",
  "",
  "library(rmarkdown)",
  "library(plotly)",
  "",
  "# Create interactive dashboard",
  "insights <- readRDS('insights.rds')",
  "render('dashboard_template.Rmd', output_file = 'dashboard.html')",
  "",
  "# Generate executive summary", 
  "render('executive_template.Rmd', output_file = 'executive_summary.pdf')",
  "",
  "# Export final dataset",
  "data <- read_csv('merged_data.csv')",
  "write_xlsx(data, 'final_dataset.xlsx')"
)

# Write all files
writeLines(data_collection, file.path(temp_dir, "01_collect_data.py"))
writeLines(data_processing, file.path(temp_dir, "02_process_data.R"))
writeLines(analysis, file.path(temp_dir, "03_analyze_data.R"))
writeLines(reporting, file.path(temp_dir, "04_generate_reports.R"))

cat("✅ Created", length(list.files(temp_dir)), "workflow files\n\n")

# Extract workflow using putior
cat("🔍 Extracting workflow with putior...\n")
workflow <- put(temp_dir)

cat("📊 Found", nrow(workflow), "workflow nodes:\n")
for (i in seq_len(nrow(workflow))) {
  row <- workflow[i, ]
  cat("  -", row$id, "(", row$node_type, "): ", row$label, "\n")
}

cat("\n", paste(rep("=", 50), collapse = ""), "\n")
cat("🎨 DIAGRAM EXAMPLES\n")
cat(paste(rep("=", 50), collapse = ""), "\n\n")

# Example 1: Basic diagram
cat("📋 Example 1: Basic Top-Down Diagram\n")
cat(paste(rep("-", 40), collapse = ""), "\n")
put_diagram(workflow)

cat("\n📋 Example 2: Horizontal Layout with File Labels\n")
cat(paste(rep("-", 40), collapse = ""), "\n")
put_diagram(workflow, 
            direction = "LR", 
            show_files = TRUE, 
            title = "Data Processing Pipeline")

cat("\n📋 Example 3: Detailed Labels with Styling\n")
cat(paste(rep("-", 40), collapse = ""), "\n")
put_diagram(workflow, 
            node_labels = "both", 
            style_nodes = TRUE,
            title = "Complete Workflow Analysis")

cat("\n📋 Example 4: Process-Only View\n")
cat(paste(rep("-", 40), collapse = ""), "\n")
# Filter to show only process nodes
process_workflow <- workflow[workflow$node_type == "process", ]
put_diagram(process_workflow, 
            direction = "LR",
            title = "Data Processing Steps")

# Example 5: Save to file
cat("\n💾 Example 5: Saving Diagram to File\n")
cat(paste(rep("-", 40), collapse = ""), "\n")
output_file <- file.path(temp_dir, "workflow_diagram.md")
put_diagram(workflow, 
            output = "file", 
            file = output_file,
            title = "Sales Data Analysis Workflow",
            show_files = TRUE,
            style_nodes = TRUE)

cat("📄 Diagram saved to:", output_file, "\n")
cat("   You can view this in any markdown viewer or GitHub!\n\n")

# Show workflow statistics
cat("📈 Workflow Statistics:\n")
cat("   Total nodes:", nrow(workflow), "\n")
cat("   Input nodes:", sum(workflow$node_type == "input", na.rm = TRUE), "\n")
cat("   Process nodes:", sum(workflow$node_type == "process", na.rm = TRUE), "\n")
cat("   Output nodes:", sum(workflow$node_type == "output", na.rm = TRUE), "\n")
cat("   Decision nodes:", sum(workflow$node_type == "decision", na.rm = TRUE), "\n")

# Show file flow
cat("\n🔄 Data Flow:\n")
inputs <- unique(workflow$input[!is.na(workflow$input)])
outputs <- unique(workflow$output[!is.na(workflow$output)])
intermediate <- intersect(inputs, outputs)
external_inputs <- setdiff(inputs, outputs)
final_outputs <- setdiff(outputs, inputs)

if (length(external_inputs) > 0) {
  cat("   External inputs:", paste(external_inputs, collapse = ", "), "\n")
}
if (length(intermediate) > 0) {
  cat("   Intermediate files:", paste(intermediate, collapse = ", "), "\n")
}
if (length(final_outputs) > 0) {
  cat("   Final outputs:", paste(final_outputs, collapse = ", "), "\n")
}

cat("\n", paste(rep("=", 50), collapse = ""), "\n")
cat("🎯 USAGE TIPS\n")
cat(paste(rep("=", 50), collapse = ""), "\n\n")

cat("💡 The generated mermaid diagrams can be used in:\n")
cat("   • GitHub README files (native rendering)\n")
cat("   • GitLab documentation\n") 
cat("   • Jupyter notebooks\n")
cat("   • R Markdown documents\n")
cat("   • Quarto documents\n")
cat("   • Any markdown viewer that supports mermaid\n\n")

cat("🔧 Customization options:\n")
cat("   • direction: 'TD', 'LR', 'BT', 'RL'\n")
cat("   • node_labels: 'name', 'label', 'both'\n")
cat("   • show_files: TRUE/FALSE (show file names on arrows)\n")
cat("   • style_nodes: TRUE/FALSE (color-code by node type)\n")
cat("   • output: 'console', 'file', 'clipboard'\n\n")

cat("📋 Copy any diagram above and paste it into:\n")
cat("   • GitHub markdown files\n")
cat("   • Mermaid live editor: https://mermaid.live\n")
cat("   • VS Code with mermaid extension\n\n")

cat("🗂️ Example files created in:\n")
cat("   ", temp_dir, "\n\n")

cat("🎨 Happy workflow visualization with putior! 🚀\n")