# Variable Reference Example for putior
# ==============================================================================
# This example demonstrates how to reference variables and objects within
# putior workflow diagrams using the "internal" file extension pattern.
# This technique allows tracking of non-persistent objects that exist only
# during script execution.
#
# Problem: How to reference a variable created by a process as a label in
# a put comment or track objects that don't persist to disk?
#
# Solution: Use the "internal" file extension to indicate non-persistent
# outputs that represent variables, objects, or temporary results.
#
# Source: GitHub issue #2 - Response by @pjt222 (package maintainer)
# To run this example:
#   source(system.file("examples", "variable-reference-example.R", package = "putior"))
# ==============================================================================

library(putior)

# Create temporary directory for example
temp_dir <- file.path(tempdir(), "putior_variable_reference")
dir.create(temp_dir, showWarnings = FALSE)

cat("Creating variable reference example in:", temp_dir, "\n")

# ==============================================================================
# EXAMPLE 1: BASIC VARIABLE TRACKING
# ==============================================================================

# Script 1: Create a variable and save it
script1_content <- c(
  "# Variable Creation Script",
  "# Demonstrates: Using 'internal' extension to track variables",
  "#put id:'create_var', label:'Create Variable', node_type:'start', output:'var.internal, var.RData'",
  "",
  "# Create a variable (exists in memory)",
  "var <- letters[1:5]",
  "print(paste('Variable created:', paste(var, collapse=', ')))",
  "",
  "# Also save to disk for persistence (optional)",
  "save(var, file = 'var.RData')",
  "",
  "# The .internal extension tells putior this represents a variable/object",
  "# that exists during execution, while .RData is the persistent file"
)

# Script 2: Use the variable from Script 1
script2_content <- c(
  "# Variable Processing Script", 
  "# Demonstrates: Loading persisted data and creating new variables",
  "#put id:'process_var', label:'Process Variable', node_type:'process', input:'var.RData', output:'processed_var.internal, result.txt'",
  "",
  "# Load the variable if working with persistent version",
  "load('var.RData')",
  "",
  "# Process the variable",
  "processed_var <- toupper(var)",
  "print(paste('Processed variable:', paste(processed_var, collapse=', ')))",
  "",
  "# Save result to file",
  "writeLines(processed_var, 'result.txt')",
  "",
  "# processed_var.internal represents the new variable created in this script",
  "# var.internal existed only in the previous script's memory"
)

# Write the scripts
writeLines(script1_content, file.path(temp_dir, "01_create_variable.R"))
writeLines(script2_content, file.path(temp_dir, "02_process_variable.R"))

# ==============================================================================
# EXAMPLE 2: EXTEND THE PIPELINE - BUILD ON PREVIOUS RESULTS
# ==============================================================================

# Script 3: Further processing using results from Script 2
script3_content <- c(
  "# Advanced Processing Script",
  "#put id:'advanced_process', label:'Advanced Data Processing', node_type:'process', input:'result.txt', output:'enhanced_data.internal, enhanced_results.csv'",
  "",
  "# Read results from previous script",
  "processed_text <- readLines('result.txt')",
  "",
  "# Create enhanced data based on previous results",
  "enhanced_data <- data.frame(",
  "  original = processed_text,",
  "  length = nchar(processed_text),",
  "  reversed = sapply(processed_text, function(x) paste(rev(strsplit(x, '')[[1]]), collapse = ''))",
  ")",
  "",
  "# Save enhanced results",
  "write.csv(enhanced_data, 'enhanced_results.csv', row.names = FALSE)",
  "",
  "print('Enhanced processing completed')"
)

# Script 4: Final analysis using all previous outputs
script4_content <- c(
  "# Final Analysis Script",
  "#put id:'final_analysis', label:'Final Analysis & Report', node_type:'output', input:'var.RData, enhanced_results.csv', output:'final_report.internal, complete_analysis.txt'",
  "",
  "# Load original variable",
  "load('var.RData')",
  "",
  "# Load enhanced results", 
  "enhanced_data <- read.csv('enhanced_results.csv')",
  "",
  "# Create comprehensive final report (in-memory object)",
  "final_report <- list(",
  "  original_var_length = length(var),",
  "  enhanced_data_rows = nrow(enhanced_data),",
  "  processing_summary = paste('Processed', length(var), 'original items into', nrow(enhanced_data), 'enhanced records')",
  ")",
  "",
  "# Save final analysis",
  "writeLines(capture.output(str(final_report)), 'complete_analysis.txt')",
  "",
  "print('Final analysis completed')"
)

writeLines(script3_content, file.path(temp_dir, "03_advanced_process.R"))
writeLines(script4_content, file.path(temp_dir, "04_final_analysis.R"))

cat("Created", length(list.files(temp_dir, pattern = "*.R")), "example scripts\n")

# ==============================================================================
# EXTRACT WORKFLOW WITH PUTIOR
# ==============================================================================

cat("\n=== Extracting workflow with putior::put() ===\n")
workflow <- put(temp_dir)

# Display results
cat("\nVariable Reference Workflow Results:\n")
print(workflow)

# ==============================================================================
# ANALYZE VARIABLE TRACKING
# ==============================================================================

if (nrow(workflow) > 0) {
  
  cat("\n=== Variable Tracking Analysis ===\n")
  
  # Find .internal files (variables/objects)
  all_outputs <- unlist(strsplit(workflow$output[!is.na(workflow$output)], ", "))
  all_inputs <- unlist(strsplit(workflow$input[!is.na(workflow$input)], ", "))
  
  internal_outputs <- all_outputs[grepl("\\.internal$", all_outputs)]
  internal_inputs <- all_inputs[grepl("\\.internal$", all_inputs)]
  
  cat("\nVariable/Object Tracking:\n")
  cat("  Variables Created:", length(unique(internal_outputs)), "\n")
  cat("  Variables Used:", length(unique(internal_inputs)), "\n")
  
  if (length(internal_outputs) > 0) {
    cat("  \nVariables/Objects in Workflow:\n")
    for (var in unique(internal_outputs)) {
      var_name <- gsub("\\.internal$", "", var)
      cat("    -", var_name, "\n")
    }
  }
  
  # Find persistent files  
  persistent_outputs <- all_outputs[!grepl("\\.internal$", all_outputs)]
  persistent_inputs <- all_inputs[!grepl("\\.internal$", all_inputs)]
  
  cat("\nPersistent Files:\n")
  cat("  Files Created:", length(unique(persistent_outputs)), "\n")
  cat("  Files Consumed:", length(unique(persistent_inputs)), "\n")
  
  if (length(persistent_outputs) > 0) {
    cat("  \nPersistent Files in Workflow:\n")
    for (file in unique(persistent_outputs)) {
      cat("    -", file, "\n")
    }
  }
  
  # Show data flow
  cat("\n=== Data Flow Summary ===\n")
  for (i in 1:nrow(workflow)) {
    row <- workflow[i, ]
    cat("Step", i, ":", row$label, "\n")
    
    if (!is.na(row$input)) {
      inputs <- unlist(strsplit(row$input, ", "))
      var_inputs <- inputs[grepl("\\.internal$", inputs)]
      file_inputs <- inputs[!grepl("\\.internal$", inputs)]
      
      if (length(var_inputs) > 0) {
        cat("  Uses variables:", paste(gsub("\\.internal$", "", var_inputs), collapse = ", "), "\n")
      }
      if (length(file_inputs) > 0) {
        cat("  Reads files:", paste(file_inputs, collapse = ", "), "\n")
      }
    }
    
    if (!is.na(row$output)) {
      outputs <- unlist(strsplit(row$output, ", "))
      var_outputs <- outputs[grepl("\\.internal$", outputs)]
      file_outputs <- outputs[!grepl("\\.internal$", outputs)]
      
      if (length(var_outputs) > 0) {
        cat("  Creates variables:", paste(gsub("\\.internal$", "", var_outputs), collapse = ", "), "\n")
      }
      if (length(file_outputs) > 0) {
        cat("  Writes files:", paste(file_outputs, collapse = ", "), "\n")
      }
    }
    cat("\n")
  }
  
} else {
  cat("No workflow annotations found. Check PUT annotation syntax.\n")
}

# ==============================================================================
# KEY INSIGHTS AND BEST PRACTICES
# ==============================================================================

cat("=== Key Insights for Variable References ===\n")
cat("\n1. Use '.internal' Extension for Variables:\n")
cat("   - Append '.internal' to variable/object names\n") 
cat("   - Example: 'my_variable.internal'\n")
cat("   - This tells putior the item represents an in-memory object\n")

cat("\n2. Combine with Persistent Files:\n")
cat("   - Use both .internal and file outputs when appropriate\n")
cat("   - Example: output:'data.internal, data.RData'\n")
cat("   - .internal tracks the variable, .RData tracks the saved file\n")

cat("\n3. .internal Variables Are Script-Local:\n")
cat("   - .internal variables exist only during script execution\n")
cat("   - They CANNOT be used as inputs to other scripts\n")
cat("   - Use persistent files (RData, CSV, etc.) for inter-script data flow\n")

cat("\n4. Multiple Variables in One Step:\n")
cat("   - List multiple .internal items: 'var1.internal, var2.internal'\n")
cat("   - Useful for scripts that create multiple objects\n")

cat("\n5. Document Variable Purpose:\n")
cat("   - Use descriptive names: 'cleaned_data.internal'\n")
cat("   - The variable name (before .internal) shows what was created\n")
cat("   - Helps document the computational steps within each script\n")

# ==============================================================================
# CLEANUP
# ==============================================================================

cat("\n=== Example Complete ===\n")
cat("Example files location:", temp_dir, "\n")
cat("\nTo explore further:\n")
cat("1. Examine generated scripts to see .internal usage patterns\n")
cat("2. Modify scripts to track your own variables\n") 
cat("3. Try generating a diagram with put_diagram() to visualize\n")

# Optional cleanup
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