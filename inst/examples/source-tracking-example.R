# Source Tracking Example: Demonstrating how to annotate source() relationships
# ==============================================================================
# This example shows how to properly annotate scripts that source other scripts
# to track the source() relationships in putior workflows.
#
# To run this example:
#   source(system.file("examples", "source-tracking-example.R", package = "putior"))
# ==============================================================================

library(putior)

cat("📜 Source Tracking Example: Proper source() Annotation\n")
cat(paste(rep("=", 55), collapse = ""), "\n\n")

# Create example directory structure
temp_dir <- file.path(tempdir(), "putior_source_example")
dir.create(temp_dir, showWarnings = FALSE)

cat("📁 Creating example workflow with source() relationships...\n")

# Main orchestrator script
main_script <- c(
  "# Main workflow script that sources utility modules",
  "# put label:\"Main Analysis Pipeline\", input:\"utils.R,analysis.R,plotting.R\", output:\"final_results.csv\"",
  "",
  "# Source utility modules (reading them INTO this script)",
  "source(\"utils.R\")     # Reading utils.R into main.R",
  "source(\"analysis.R\")  # Reading analysis.R into main.R", 
  "source(\"plotting.R\")  # Reading plotting.R into main.R",
  "",
  "# Execute the pipeline",
  "data <- load_and_clean(\"raw_data.csv\")",
  "results <- perform_analysis(data)",
  "create_plots(results)",
  "write.csv(results, \"final_results.csv\")"
)

# Utility functions script 
utils_script <- c(
  "# Utility functions - sourced BY main.R",
  "# put label:\"Data Utilities\", node_type:\"input\"",
  "# output defaults to 'utils.R' - this script provides itself",
  "",
  "load_and_clean <- function(file) {",
  "  # Load and clean data",
  "  data <- read.csv(file)",
  "  data[complete.cases(data), ]",
  "}"
)

# Analysis functions script
analysis_script <- c(
  "# Analysis functions - sourced BY main.R, depends on utils.R",
  "# put label:\"Statistical Analysis\", node_type:\"process\", input:\"utils.R\"",
  "# input: utils.R because we depend on functions from utils.R",
  "# output defaults to 'analysis.R'",
  "",
  "perform_analysis <- function(data) {",
  "  # Perform statistical analysis",
  "  # Uses load_and_clean() from utils.R",
  "  summary(data)",
  "}"
)

# Plotting functions script
plotting_script <- c(
  "# Plotting functions - sourced BY main.R, depends on analysis.R",
  "# put label:\"Data Visualization\", node_type:\"output\", input:\"analysis.R\"",
  "# input: analysis.R because we depend on analysis functions",
  "# output defaults to 'plotting.R'",
  "",
  "create_plots <- function(results) {",
  "  # Create visualizations",
  "  # Uses perform_analysis() results",
  "  plot(results)",
  "}"
)

# Write all files
writeLines(main_script, file.path(temp_dir, "main.R"))
writeLines(utils_script, file.path(temp_dir, "utils.R"))
writeLines(analysis_script, file.path(temp_dir, "analysis.R"))
writeLines(plotting_script, file.path(temp_dir, "plotting.R"))

cat("✅ Created source tracking example files\n\n")

# Extract workflow
cat("🔍 Extracting source() relationships...\n")
workflow <- put(temp_dir)

cat("\n📊 Source tracking results:\n")
cat(paste(rep("-", 50), collapse = ""), "\n")

# Display the relationships
for (i in seq_len(nrow(workflow))) {
  row <- workflow[i, ]
  cat(sprintf("%-15s: %s\n", "File", row$file_name))
  cat(sprintf("%-15s: %s\n", "Label", row$label))
  cat(sprintf("%-15s: %s\n", "Node Type", ifelse(is.na(row$node_type), "process", row$node_type)))
  cat(sprintf("%-15s: %s\n", "Input", ifelse(is.na(row$input), "none", row$input)))
  cat(sprintf("%-15s: %s\n", "Output", row$output))
  cat(paste(rep("-", 50), collapse = ""), "\n")
}

# Generate diagram
cat("\n🎨 Source relationship diagram:\n")
cat(paste(rep("-", 50), collapse = ""), "\n")
put_diagram(workflow, 
            theme = "github", 
            show_files = TRUE,
            title = "Source Tracking Example")

cat("\n\n💡 Key Insights:\n")
cat(paste(rep("=", 50), collapse = ""), "\n")
cat("1. Scripts being sourced are INPUTS to the main script\n")
cat("2. Flow direction: sourced scripts → main script\n") 
cat("3. main.R reads utils.R, analysis.R, and plotting.R\n")
cat("4. Dependencies: utils.R → analysis.R → plotting.R\n")
cat("5. Arrows with file names show the source() relationships\n\n")

cat("📝 Annotation Pattern Summary:\n")
cat("• Main script: input=\"script1.R,script2.R,script3.R\"\n")
cat("• Sourced scripts: output defaults to their filename\n")
cat("• Dependencies: input=\"dependency_script.R\"\n\n")

cat("🗂️ Example files created in:\n")
cat("   ", temp_dir, "\n\n")

cat("✅ Source tracking example complete!\n")

# Clean up
cat("🧹 Cleaning up...\n")
unlink(temp_dir, recursive = TRUE)