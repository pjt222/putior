# Putior UUID Auto-Generation Example
# ==============================================================================
# This example demonstrates how putior automatically generates UUIDs for nodes
# when the id field is omitted from annotations.
#
# To run this example:
#   source(system.file("examples", "uuid-example.R", package = "putior"))
# ==============================================================================

library(putior)

cat("🆔 Putior UUID Auto-Generation Example\n")
cat(paste(rep("=", 50), collapse = ""), "\n\n")

# Create a sample workflow demonstrating UUID generation
temp_dir <- file.path(tempdir(), "putior_uuid_example")
dir.create(temp_dir, showWarnings = FALSE)

cat("📁 Creating example files with and without explicit IDs...\n\n")

# File 1: Annotations without IDs (will get auto-generated UUIDs)
no_ids_script <- c(
  "# Script with annotations that omit the id field",
  "#put label:\"Load Configuration\", node_type:\"input\", output:\"config.json\"",
  "",
  "config <- load_config()",
  "save_json(config, 'config.json')",
  "",
  "#put label:\"Process Data\", node_type:\"process\", input:\"config.json\", output:\"processed.csv\"", 
  "",
  "data <- process_with_config('config.json')",
  "write.csv(data, 'processed.csv')"
)

# File 2: Mix of explicit IDs and omitted IDs
mixed_ids_script <- c(
  "# Script with some explicit IDs and some omitted",
  "#put id:\"fetch_data\", label:\"Fetch Raw Data\", node_type:\"input\", output:\"raw.csv\"",
  "",
  "raw_data <- fetch_from_api()",
  "write.csv(raw_data, 'raw.csv')",
  "",
  "# This annotation omits the id - will get UUID",
  "#put label:\"Validate Data\", node_type:\"process\", input:\"raw.csv\", output:\"validated.csv\"",
  "",
  "validated <- validate_data(read.csv('raw.csv'))",
  "write.csv(validated, 'validated.csv')",
  "",
  "#put id:\"generate_report\", label:\"Generate Report\", node_type:\"output\", input:\"validated.csv\""
)

# File 3: Example with empty ID (will generate warning)
empty_id_script <- c(
  "# Script demonstrating empty id warning",
  "#put id:\"\", label:\"This will warn\", node_type:\"process\"",
  "",
  "# Empty IDs generate validation warnings"
)

# Write files
writeLines(no_ids_script, file.path(temp_dir, "01_no_ids.R"))
writeLines(mixed_ids_script, file.path(temp_dir, "02_mixed_ids.R"))
writeLines(empty_id_script, file.path(temp_dir, "03_empty_id.R"))

cat("✅ Created example files\n\n")

# Extract workflow with UUID auto-generation
cat("🔍 Extracting workflow (UUIDs will be auto-generated)...\n")
cat(paste(rep("-", 50), collapse = ""), "\n")

# Capture the warning from empty ID
workflow <- suppressWarnings(put(temp_dir))

# Show results
cat("\n📊 Extracted nodes:\n")
cat(paste(rep("-", 50), collapse = ""), "\n")

for (i in seq_len(nrow(workflow))) {
  row <- workflow[i, ]
  cat(sprintf("%-20s: %s\n", "File", row$file_name))
  cat(sprintf("%-20s: %s\n", "ID", row$id))
  cat(sprintf("%-20s: %s\n", "Label", row$label))
  
  # Check if ID looks like a UUID
  is_uuid <- grepl("^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", 
                   row$id, ignore.case = TRUE)
  cat(sprintf("%-20s: %s\n", "Auto-generated?", ifelse(is_uuid, "Yes (UUID)", "No (explicit)")))
  cat(paste(rep("-", 50), collapse = ""), "\n")
}

# Now extract with validation to see the warning
cat("\n⚠️  Extracting with validation (to show empty ID warning):\n")
cat(paste(rep("-", 50), collapse = ""), "\n")
workflow_validated <- put(temp_dir, validate = TRUE)

# Generate diagram
cat("\n\n🎨 Generating diagram with auto-generated UUIDs:\n")
cat(paste(rep("-", 50), collapse = ""), "\n")
put_diagram(workflow[workflow$file_name != "03_empty_id.R", ],  # Exclude the empty ID example
            title = "Workflow with Auto-Generated UUIDs",
            node_labels = "label")  # Use labels since UUIDs are not human-friendly

cat("\n\n💡 KEY POINTS:\n")
cat(paste(rep("=", 50), collapse = ""), "\n")
cat("1. When 'id' is omitted → UUID is auto-generated\n")
cat("2. When 'id' is explicit → Your ID is used as-is\n")
cat("3. When 'id' is empty (\"\") → Validation warning\n")
cat("4. UUIDs ensure uniqueness across workflows\n")
cat("5. Use 'label' for human-readable node names\n\n")

cat("📝 BEST PRACTICES:\n")
cat("• Omit 'id' for quick prototyping\n")
cat("• Use explicit 'id' for stable references\n")
cat("• Always provide descriptive 'label' values\n")
cat("• Avoid empty 'id' values\n\n")

cat("🗂️ Example files created in:\n")
cat("   ", temp_dir, "\n\n")

# Clean up
cat("🧹 Cleaning up temporary files...\n")
unlink(temp_dir, recursive = TRUE)

cat("\n✅ UUID auto-generation example complete!\n")