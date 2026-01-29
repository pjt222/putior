#!/usr/bin/env Rscript
# Generate Mermaid diagram images for cheatsheet
# Run: Rscript inst/cheatsheet/generate-diagrams.R

output_dir <- "inst/cheatsheet/diagrams"
if (!dir.exists(output_dir)) dir.create(output_dir, recursive = TRUE)

# Helper function to fetch rendered Mermaid diagram from mermaid.ink
fetch_mermaid_diagram <- function(mermaid_code, output_file) {
  # Base64 encode the Mermaid code for the API (URL-safe base64)
  encoded <- jsonlite::base64_enc(charToRaw(mermaid_code))
  # Remove any newlines from base64 output
  encoded <- gsub("[\r\n]", "", encoded)
  # Make URL-safe: replace + with -, / with _, remove padding =
  encoded <- gsub("\\+", "-", encoded)
  encoded <- gsub("/", "_", encoded)
  encoded <- gsub("=", "", encoded)
  url <- paste0("https://mermaid.ink/img/", encoded)

  cat("Fetching:", basename(output_file), "...\n")
  tryCatch({
    download.file(url, output_file, mode = "wb", quiet = TRUE)
    cat("  Created:", output_file, "\n")
    TRUE
  }, error = function(e) {
    warning("Failed to fetch diagram: ", e$message)
    FALSE
  })
}

# Define diagrams
diagrams <- list(
  linear = 'flowchart LR
    fetch(["Fetch Sales Data"])
    clean["Clean Data"]
    report[["Generate Report"]]
    fetch --> clean --> report
    classDef inputStyle fill:#dbeafe,stroke:#2563eb,color:#1e40af
    classDef processStyle fill:#ede9fe,stroke:#7c3aed,color:#5b21b6
    classDef outputStyle fill:#dcfce7,stroke:#16a34a,color:#15803d
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
    classDef inputStyle fill:#dbeafe,stroke:#2563eb,color:#1e40af
    classDef processStyle fill:#ede9fe,stroke:#7c3aed,color:#5b21b6
    classDef outputStyle fill:#dcfce7,stroke:#16a34a,color:#15803d
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
    classDef inputStyle fill:#dbeafe,stroke:#2563eb,color:#1e40af
    classDef processStyle fill:#ede9fe,stroke:#7c3aed,color:#5b21b6
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
    classDef startStyle fill:#fef3c7,stroke:#d97706,color:#92400e
    classDef decisionStyle fill:#fef3c7,stroke:#d97706,color:#92400e
    classDef processStyle fill:#ede9fe,stroke:#7c3aed,color:#5b21b6
    classDef endStyle fill:#dcfce7,stroke:#16a34a,color:#15803d
    class start startStyle
    class check decisionStyle
    class full,quick processStyle
    class complete endStyle'
)

# Generate all diagrams
cat("Generating cheatsheet diagrams...\n")
for (name in names(diagrams)) {
  output_file <- file.path(output_dir, paste0(name, ".png"))
  fetch_mermaid_diagram(diagrams[[name]], output_file)
}

cat("\nDone! Generated", length(diagrams), "diagrams.\n")
