#!/usr/bin/env Rscript
# Generate Mermaid diagram images for cheatsheet using mmdc CLI
# Run: Rscript inst/cheatsheet/generate-diagrams.R
#
# Prerequisites: npm install -g @mermaid-js/mermaid-cli

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

  # Clean up temp file
  unlink(mmd_file)

  if (result != 0 || !file.exists(output_file)) {
    warning("Failed to render diagram. Is mmdc installed? Run: npm install -g @mermaid-js/mermaid-cli")
    return(FALSE)
  }

  cat("  Created:", output_file, "\n")
  TRUE
}

# Define diagrams with transparent background-friendly colors
diagrams <- list(
  linear = 'flowchart LR
    fetch(["Fetch Sales Data"])
    clean["Clean Data"]
    report[["Generate Report"]]
    fetch --> clean --> report
    classDef inputStyle fill:#dbeafe,stroke:#2563eb,stroke-width:2px,color:#1e40af
    classDef processStyle fill:#ede9fe,stroke:#7c3aed,stroke-width:2px,color:#5b21b6
    classDef outputStyle fill:#dcfce7,stroke:#16a34a,stroke-width:2px,color:#15803d
    class fetch inputStyle
    class clean processStyle
    class report outputStyle',

  branching = 'flowchart TD
    sales(["Fetch Sales"])
    customers(["Fetch Customers"])
    merge["Merge Datasets"]
    analyze["Analyze"]
    report[["Report"]]
    sales --> merge
    customers --> merge
    merge --> analyze --> report
    classDef inputStyle fill:#dbeafe,stroke:#2563eb,stroke-width:2px,color:#1e40af
    classDef processStyle fill:#ede9fe,stroke:#7c3aed,stroke-width:2px,color:#5b21b6
    classDef outputStyle fill:#dcfce7,stroke:#16a34a,stroke-width:2px,color:#15803d
    class sales,customers inputStyle
    class merge,analyze processStyle
    class report outputStyle',

  modular = 'flowchart TD
    utils(["Data Utilities"])
    analysis["Analysis Functions"]
    main["Main Pipeline"]
    utils --> analysis
    utils --> main
    analysis --> main
    classDef inputStyle fill:#dbeafe,stroke:#2563eb,stroke-width:2px,color:#1e40af
    classDef processStyle fill:#ede9fe,stroke:#7c3aed,stroke-width:2px,color:#5b21b6
    class utils inputStyle
    class analysis,main processStyle',

  decision = 'flowchart TD
    start(["Load Config"])
    check{"Validate Data?"}
    full["Full Analysis"]
    quick["Quick Summary"]
    complete(["Complete"])
    start --> check
    check -->|Yes| full
    check -->|No| quick
    full --> complete
    quick --> complete
    classDef startStyle fill:#fef3c7,stroke:#d97706,stroke-width:2px,color:#92400e
    classDef decisionStyle fill:#fef3c7,stroke:#d97706,stroke-width:2px,color:#92400e
    classDef processStyle fill:#ede9fe,stroke:#7c3aed,stroke-width:2px,color:#5b21b6
    classDef endStyle fill:#dcfce7,stroke:#16a34a,stroke-width:2px,color:#15803d
    class start startStyle
    class check decisionStyle
    class full,quick processStyle
    class complete endStyle'
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
