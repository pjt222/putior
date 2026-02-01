#!/usr/bin/env Rscript
# Generate Mermaid diagram images for cheatsheet using mmdc CLI
# Run: Rscript inst/cheatsheet/generate-diagrams.R
#
# Prerequisites: npm install -g @mermaid-js/mermaid-cli

library(putior)

output_dir <- "inst/cheatsheet/diagrams"
if (!dir.exists(output_dir)) dir.create(output_dir, recursive = TRUE)

# Helper function to render Mermaid diagram using mmdc (Mermaid CLI)
# Handles Windows R + WSL mmdc cross-platform scenario
render_mermaid_diagram <- function(mermaid_code, output_file, bg_color = "white", scale = 4) {
  # Write mermaid code to temp file
  mmd_file <- tempfile(fileext = ".mmd")
  writeLines(mermaid_code, mmd_file)

  # Detect platform and construct appropriate command
  is_windows <- .Platform$OS.type == "windows"

  if (is_windows) {
    # Convert Windows paths to WSL paths for mmdc running in WSL
    mmd_abs <- normalizePath(mmd_file, winslash = "/")
    out_abs <- normalizePath(output_file, winslash = "/", mustWork = FALSE)

    convert_to_wsl <- function(path) {
      if (grepl("^[A-Za-z]:", path)) {
        drive <- tolower(substr(path, 1, 1))
        rest <- substr(path, 3, nchar(path))
        paste0("/mnt/", drive, rest)
      } else {
        path
      }
    }
    mmd_wsl <- convert_to_wsl(mmd_abs)
    out_wsl <- convert_to_wsl(out_abs)

    # Call mmdc through wsl.exe - source nvm to get node in PATH
    cmd <- sprintf(
      'wsl bash -ic "source ~/.nvm/nvm.sh && mmdc -i \\"%s\\" -o \\"%s\\" -b \\"%s\\" -s %d 2>/dev/null"',
      mmd_wsl, out_wsl, bg_color, scale
    )
  } else {
    # Native Unix/WSL - use mmdc directly
    cmd <- sprintf(
      'mmdc -i "%s" -o "%s" -b "%s" -s %d 2>/dev/null',
      mmd_file, output_file, bg_color, scale
    )
  }

  cat("Rendering:", basename(output_file), "...\n")
  result <- system(cmd, intern = FALSE, ignore.stdout = TRUE, ignore.stderr = TRUE)

  if (result != 0 || !file.exists(output_file)) {
    # Clean up temp file on failure
    unlink(mmd_file)
    warning("Failed to render diagram. Is mmdc installed? Run: npm install -g @mermaid-js/mermaid-cli")
    return(FALSE)
  }

  # Clean up temp file on success
  unlink(mmd_file)

  cat("  Created:", output_file, "\n")
  TRUE
}

# =============================================================================
# Define workflows using inline data frames, then generate diagrams with put_diagram()
# =============================================================================

# Linear workflow: Fetch -> Clean -> Report
linear_workflow <- data.frame(
  file_name = c("01_fetch.R", "02_clean.R", "03_report.R"),
  id = c("fetch", "clean", "report"),
  label = c("Fetch Sales Data", "Clean Data", "Generate Report"),
  node_type = c("input", "process", "output"),
  input = c(NA, "raw_data.csv", "clean_data.csv"),
  output = c("raw_data.csv", "clean_data.csv", "report.html"),
  stringsAsFactors = FALSE
)

# Branching workflow: Multiple inputs merging
branching_workflow <- data.frame(
  file_name = c("fetch_sales.R", "fetch_customers.R", "merge.R", "analyze.R", "report.R"),
  id = c("sales", "customers", "merge", "analyze", "report"),
  label = c("Fetch Sales", "Fetch Customers", "Merge Datasets", "Analyze", "Report"),
  node_type = c("input", "input", "process", "process", "output"),
  input = c(NA, NA, "sales.csv,customers.csv", "merged.csv", "analysis.csv"),
  output = c("sales.csv", "customers.csv", "merged.csv", "analysis.csv", "report.html"),
  stringsAsFactors = FALSE
)

# Modular workflow: Script dependencies
modular_workflow <- data.frame(
  file_name = c("utils.R", "analysis.R", "main.R"),
  id = c("utils", "analysis", "main"),
  label = c("Data Utilities", "Analysis Functions", "Main Pipeline"),
  node_type = c("input", "process", "process"),
  input = c(NA, "utils.R", "utils.R,analysis.R"),
  output = c("utils.R", "analysis.R", "results.csv"),
  stringsAsFactors = FALSE
)

# Decision workflow: Start/end boundaries with processing
decision_workflow <- data.frame(
  file_name = c("config.R", "full_analysis.R", "quick_summary.R", "complete.R"),
  id = c("start", "full", "quick", "complete"),
  label = c("Load Config", "Full Analysis", "Quick Summary", "Complete"),
  node_type = c("start", "process", "process", "end"),
  input = c(NA, "config.json", "config.json", "results.csv"),
  output = c("config.json", "results.csv", "results.csv", NA),
  stringsAsFactors = FALSE
)

# Generate Mermaid code using put_diagram()
diagrams <- list(
  linear = put_diagram(linear_workflow, direction = "LR", theme = "github", output = "raw"),
  branching = put_diagram(branching_workflow, direction = "TD", theme = "github", output = "raw"),
  modular = put_diagram(modular_workflow, direction = "TD", theme = "github", output = "raw"),
  decision = put_diagram(decision_workflow, direction = "TD", theme = "github",
                         show_workflow_boundaries = TRUE, output = "raw")
)

# Generate all diagrams
cat("Generating cheatsheet diagrams with mmdc...\n")
cat("Using scale factor 4 for high resolution\n\n")

success_count <- 0
for (name in names(diagrams)) {
  output_file <- file.path(output_dir, paste0(name, ".png"))
  if (render_mermaid_diagram(diagrams[[name]], output_file, bg_color = "white", scale = 4)) {
    success_count <- success_count + 1
  }
}

cat("\nDone! Generated", success_count, "of", length(diagrams), "diagrams.\n")

# Show file sizes
cat("\nFile sizes:\n")
for (name in names(diagrams)) {
  f <- file.path(output_dir, paste0(name, ".png"))
  if (file.exists(f)) {
    cat(sprintf("  %s: %s KB\n", basename(f), round(file.size(f) / 1024, 1)))
  }
}
