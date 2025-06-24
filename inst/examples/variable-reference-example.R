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
  "# Demonstrates: Referencing variables from previous steps",
  "#put id:'process_var', label:'Process Variable', node_type:'process', input:'var.internal, var.RData', output:'processed_var.internal, result.txt'",
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
  "# Both var.internal and processed_var.internal represent variables",
  "# that exist in memory during execution"
)

# Write the scripts
writeLines(script1_content, file.path(temp_dir, "01_create_variable.R"))
writeLines(script2_content, file.path(temp_dir, "02_process_variable.R"))

# ==============================================================================
# EXAMPLE 2: COMPLEX OBJECT TRACKING
# ==============================================================================

# Script 3: Create multiple objects
script3_content <- c(
  "# Multiple Object Creation",
  "#put id:'create_objects', label:'Create Data Objects', node_type:'input', output:'data_frame.internal, model.internal, objects.RData'",
  "",
  "# Create multiple objects",
  "data_frame <- data.frame(",
  "  x = 1:10,",
  "  y = rnorm(10)",
  ")",
  "",
  "# Create a simple model object",
  "model <- lm(y ~ x, data = data_frame)",
  "",
  "# Save all objects",
  "save(data_frame, model, file = 'objects.RData')",
  "",
  "print('Created data frame and model objects')"
)

# Script 4: Use multiple objects  
script4_content <- c(
  "# Object Analysis Script",
  "#put id:'analyze_objects', label:'Analyze Objects', node_type:'process', input:'data_frame.internal, model.internal, objects.RData', output:'summary.internal, analysis.txt'",
  "",
  "# Load objects",
  "load('objects.RData')",
  "",
  "# Create analysis summary (in-memory object)",
  "summary <- list(",
  "  data_summary = summary(data_frame),",
  "  model_summary = summary(model),",
  "  r_squared = summary(model)$r.squared",
  ")",
  "",
  "# Save analysis to file",
  "writeLines(capture.output(print(summary)), 'analysis.txt')",
  "",
  "print('Analysis completed')"
)

writeLines(script3_content, file.path(temp_dir, "03_create_objects.R"))
writeLines(script4_content, file.path(temp_dir, "04_analyze_objects.R"))

# ==============================================================================
# EXAMPLE 3: PIPELINE WITH VARIABLE REFERENCES
# ==============================================================================

# Script 5: Data pipeline with multiple variable stages
script5_content <- c(
  "# Data Pipeline with Variable Tracking",
  "#put id:'load_data', label:'Load Raw Data', node_type:'input', output:'raw_data.internal, raw_data.csv'",
  "#put id:'clean_data', label:'Clean Data', node_type:'process', input:'raw_data.internal', output:'clean_data.internal'", 
  "#put id:'transform_data', label:'Transform Data', node_type:'process', input:'clean_data.internal', output:'final_data.internal, final_data.csv'",
  "",
  "# Step 1: Load raw data",
  "raw_data <- data.frame(",
  "  id = 1:100,",
  "  value = rnorm(100),",
  "  category = sample(c('A', 'B', 'C'), 100, replace = TRUE)",
  ")",
  "write.csv(raw_data, 'raw_data.csv', row.names = FALSE)",
  "",
  "# Step 2: Clean data (remove NAs, outliers)",
  "clean_data <- raw_data[!is.na(raw_data$value), ]",
  "clean_data <- clean_data[abs(clean_data$value) < 2, ]",
  "",
  "# Step 3: Transform data (add calculated columns)",
  "final_data <- clean_data",
  "final_data$value_squared <- final_data$value^2",
  "final_data$category_numeric <- as.numeric(factor(final_data$category))",
  "write.csv(final_data, 'final_data.csv', row.names = FALSE)",
  "",
  "print(paste('Pipeline completed. Final data has', nrow(final_data), 'rows'))"
)

writeLines(script5_content, file.path(temp_dir, "05_data_pipeline.R"))

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

cat("\n3. Chain Variables Through Pipeline:\n")
cat("   - Use .internal outputs as inputs to next step\n")
cat("   - Example: input:'data.internal' in the next script\n")
cat("   - This shows data flow through variables\n")

cat("\n4. Multiple Variables in One Step:\n")
cat("   - List multiple .internal items: 'var1.internal, var2.internal'\n")
cat("   - Useful for scripts that create multiple objects\n")

cat("\n5. Document Variable Purpose:\n")
cat("   - Use descriptive names: 'cleaned_data.internal'\n")
cat("   - The variable name (before .internal) becomes the reference\n")

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