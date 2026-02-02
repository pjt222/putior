# =============================================================================
# putior Auto-Annotation Feature Example
# =============================================================================
#
# This example demonstrates the auto-annotation feature that automatically
# detects workflow elements from code analysis - similar to how roxygen2
# generates documentation skeletons from code.
#
# Two primary modes:
# 1. Direct detection: put_auto() analyzes code and produces workflow data
# 2. Comment generation: put_generate() creates # put annotation text
#
# =============================================================================

library(putior)

# =============================================================================
# PART 1: Direct Workflow Detection with put_auto()
# =============================================================================

# Create a temporary directory with sample analysis scripts
temp_dir <- tempdir()
demo_dir <- file.path(temp_dir, "auto_annotation_demo")
dir.create(demo_dir, showWarnings = FALSE)

# Create sample R scripts that demonstrate various I/O patterns

# Script 1: Data Loading (input node - reads data, no processing output)
writeLines(c(
  "# Load raw data from various sources",
  "raw_sales <- read.csv('data/raw_sales.csv')",
  "raw_customers <- read_csv('data/raw_customers.csv')",
  "config <- readRDS('config/settings.rds')"
), file.path(demo_dir, "01_load_data.R"))

# Script 2: Data Cleaning (process node - reads and writes)
writeLines(c(
  "# Clean and validate the data",
  "sales <- read.csv('data/raw_sales.csv')",
  "customers <- read_csv('data/raw_customers.csv')",
  "",
  "# Clean operations...",
  "clean_sales <- clean_data(sales)",
  "clean_customers <- validate_customers(customers)",
  "",
  "# Save cleaned data",
  "write.csv(clean_sales, 'data/clean_sales.csv')",
  "write_csv(clean_customers, 'data/clean_customers.csv')"
), file.path(demo_dir, "02_clean_data.R"))

# Script 3: Analysis (process node)
writeLines(c(
  "# Perform analysis on cleaned data",
  "sales <- read.csv('data/clean_sales.csv')",
  "customers <- read_csv('data/clean_customers.csv')",
  "",
  "# Analysis...",
  "results <- analyze_sales(sales, customers)",
  "",
  "# Save results",
  "saveRDS(results, 'output/analysis_results.rds')"
), file.path(demo_dir, "03_analyze.R"))

# Script 4: Reporting (output node - creates final outputs)
writeLines(c(
  "# Generate final reports and visualizations",
  "results <- readRDS('output/analysis_results.rds')",
  "",
  "# Create visualizations",
  "p <- ggplot(results, aes(x, y)) + geom_point()",
  "ggsave('output/sales_plot.png', p)",
  "",
  "# Create report",
  "write.csv(summary(results), 'output/summary_report.csv')"
), file.path(demo_dir, "04_report.R"))

# -----------------------------------------------------------------------------
# Example 1: Basic auto-detection
# -----------------------------------------------------------------------------
cat("=== Example 1: Basic Auto-Detection ===\n\n")

# Automatically detect workflow from code
workflow <- put_auto(demo_dir)
print(workflow[, c("id", "label", "input", "output", "node_type")])

cat("\n")

# -----------------------------------------------------------------------------
# Example 2: Generate diagram from auto-detected workflow
# -----------------------------------------------------------------------------
cat("=== Example 2: Auto-Detected Workflow Diagram ===\n\n")

# This works seamlessly with put_diagram()
put_diagram(workflow, title = "Auto-Detected Data Pipeline")

cat("\n")

# -----------------------------------------------------------------------------
# Example 3: Show artifacts (data files) in diagram
# -----------------------------------------------------------------------------
cat("=== Example 3: With Data Artifacts ===\n\n")

put_diagram(workflow, show_artifacts = TRUE, show_files = TRUE,
            title = "Pipeline with Data Artifacts")

cat("\n")

# =============================================================================
# PART 2: Generating PUT Annotation Comments with put_generate()
# =============================================================================

cat("=== Example 4: Generate PUT Annotations (roxygen2-style) ===\n\n")

# Generate suggested annotations for manual review/insertion
# This is similar to how roxygen2 generates documentation skeletons
annotations <- put_generate(demo_dir, style = "multiline")

cat("\nThese annotations can be copied into your source files.\n\n")

# -----------------------------------------------------------------------------
# Example 5: Single-line annotation style
# -----------------------------------------------------------------------------
cat("=== Example 5: Single-Line Annotation Style ===\n\n")

put_generate(file.path(demo_dir, "03_analyze.R"), style = "single")

cat("\n")

# =============================================================================
# PART 3: Merging Manual and Auto-Detected Annotations
# =============================================================================

# Add a manual annotation to one of the files
writeLines(c(
  '# put id:"custom_loader", label:"Custom Data Loader", node_type:"input"',
  "# Load raw data from various sources",
  "raw_sales <- read.csv('data/raw_sales.csv')",
  "raw_customers <- read_csv('data/raw_customers.csv')"
), file.path(demo_dir, "01_load_data.R"))

cat("=== Example 6: Merge Manual + Auto-Detected (Manual Priority) ===\n\n")

merged <- put_merge(demo_dir, merge_strategy = "manual_priority")
print(merged[, c("id", "label", "node_type", "auto_detected")])

cat("\nNotice the first file uses the manual annotation (custom_loader)\n")
cat("while other files use auto-detected annotations.\n\n")

# -----------------------------------------------------------------------------
# Example 7: Supplement strategy (fill in missing fields)
# -----------------------------------------------------------------------------
cat("=== Example 7: Supplement Strategy ===\n\n")

# Modify file to have partial manual annotation
writeLines(c(
  '# put id:"analyzer", label:"Sales Analyzer"',
  "# Note: input/output not specified - will be auto-detected",
  "sales <- read.csv('data/clean_sales.csv')",
  "saveRDS(results, 'output/analysis_results.rds')"
), file.path(demo_dir, "03_analyze.R"))

supplemented <- put_merge(demo_dir, merge_strategy = "supplement")
analyzer_row <- supplemented[supplemented$id == "analyzer", ]
cat("Analyzer node with supplemented I/O:\n")
cat("  ID:", analyzer_row$id, "\n")
cat("  Label:", analyzer_row$label, "\n")
cat("  Input:", analyzer_row$input, "(auto-detected)\n")
cat("  Output:", analyzer_row$output, "(auto-detected)\n\n")

# =============================================================================
# PART 4: Detection Pattern Exploration
# =============================================================================

cat("=== Example 8: Explore Detection Patterns ===\n\n")

# View available languages
cat("Supported languages:", paste(list_supported_languages(), collapse = ", "), "\n\n")

# View R input patterns
cat("Sample R input detection patterns:\n")
r_inputs <- get_detection_patterns("r", type = "input")[1:5]
for (p in r_inputs) {
  cat("  -", p$func, ":", p$description, "\n")
}

cat("\nSample Python output detection patterns:\n")
py_outputs <- get_detection_patterns("python", type = "output")[1:5]
for (p in py_outputs) {
  cat("  -", p$func, ":", p$description, "\n")
}

# =============================================================================
# PART 5: Practical Use Cases
# =============================================================================

cat("\n=== Practical Use Cases ===\n\n")

cat("1. Quick Visualization (no annotations needed):\n")
cat("   workflow <- put_auto('./src/')\n")
cat("   put_diagram(workflow)\n\n")

cat("2. Generate Annotation Skeletons (like roxygen2):\n")
cat("   put_generate('./scripts/', output = 'clipboard')\n")
cat("   # Paste into your files and customize\n\n")

cat("3. Hybrid Workflow (manual control + auto-detection):\n")
cat("   # Add # put annotations to key files\n")
cat("   # Let put_merge() handle the rest\n")
cat("   workflow <- put_merge('./project/', merge_strategy = 'supplement')\n\n")

cat("4. Project Onboarding (understand new codebase):\n")
cat("   # Instantly see data flow in unfamiliar project\n")
cat("   put_auto('./new_project/', recursive = TRUE) |>\n")
cat("     put_diagram(show_artifacts = TRUE)\n\n")

# Cleanup
unlink(demo_dir, recursive = TRUE)

cat("=== Demo Complete ===\n")
