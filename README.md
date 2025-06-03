# putior

[![R CMD check](https://github.com/pjt222/putior/workflows/R-CMD-check/badge.svg)](https://github.com/pjt222/putior/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![lifecycle](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)

> **Extract beautiful workflow diagrams from your code annotations**

**putior** (PUT + Input + Output + R) is an R package that extracts structured annotations from source code files and creates beautiful Mermaid flowchart diagrams. Perfect for documenting data pipelines, workflows, and understanding complex codebases.

## 🌟 Key Features

- **Simple annotations** - Add structured comments to your existing code
- **Beautiful diagrams** - Generate professional Mermaid flowcharts
- **File flow tracking** - Automatically connects scripts based on input/output files  
- **Multiple themes** - 5 built-in themes including GitHub-optimized
- **Cross-language support** - Works with R, Python, SQL, shell scripts, and Julia
- **Flexible output** - Console, file, or clipboard export
- **Customizable styling** - Control colors, direction, and node shapes

## 📦 Installation

```r
# Install with devtools
devtools::install_github("pjt222/putior")

# Or with pak (faster)
pak::pkg_install("pjt222/putior")
```

## 🚀 Quick Start

### Step 1: Annotate Your Code

Add structured annotations to your R or Python scripts using `#put` comments:

**`01_fetch_data.R`**
```r
#put label:"Fetch Sales Data", node_type:"input", output:"sales_data.csv"

# Your actual code
library(readr)
sales_data <- fetch_sales_from_api()
write_csv(sales_data, "sales_data.csv")
```

**`02_clean_data.py`**
```python
#put label:"Clean and Process", node_type:"process", input:"sales_data.csv", output:"clean_sales.csv"

import pandas as pd
df = pd.read_csv("sales_data.csv")
# ... data cleaning code ...
df.to_csv("clean_sales.csv")
```

### Step 2: Extract and Visualize

```r
library(putior)

# Extract workflow from your scripts
workflow <- put("./scripts/")

# Generate diagram
put_diagram(workflow)
```

**Result:**
```mermaid
flowchart TD
    fetch_sales([Fetch Sales Data])
    clean_data[Clean and Process]

    %% Connections
    fetch_sales --> clean_data

    %% Styling
    classDef inputStyle fill:#dbeafe,stroke:#2563eb,stroke-width:2px,color:#1e40af
    class fetch_sales inputStyle
    classDef processStyle fill:#ede9fe,stroke:#7c3aed,stroke-width:2px,color:#5b21b6
    class clean_data processStyle
```

## 📈 Common Data Science Pattern

### Modular Workflow with source()

The most common data science pattern: modularize functions into separate scripts and orchestrate them in a main workflow:

**`utils.R` - Utility functions**
```r
#put label:"Data Utilities", node_type:"input"

load_and_clean <- function(file) {
  data <- read.csv(file)
  data[complete.cases(data), ]
}

validate_data <- function(data) {
  stopifnot(nrow(data) > 0)
  return(data)
}
```

**`analysis.R` - Analysis functions** 
```r
#put label:"Statistical Analysis", input:"utils.R"

perform_analysis <- function(data) {
  # Uses utility functions from utils.R
  cleaned <- validate_data(data)
  summary(cleaned)
}
```

**`main.R` - Workflow orchestrator**
```r
#put label:"Main Analysis Pipeline", input:"utils.R,analysis.R", output:"results.csv"

source("utils.R")     # Load utility functions
source("analysis.R")  # Load analysis functions

# Execute the pipeline
data <- load_and_clean("raw_data.csv")
results <- perform_analysis(data)
write.csv(results, "results.csv")
```

**Generated Workflow (Simple):**
```mermaid
flowchart TD
    utils([Data Utilities])
    analysis[Statistical Analysis]
    main[Main Analysis Pipeline]

    %% Connections
    utils --> analysis
    utils --> main
    analysis --> main

    %% Styling
    classDef inputStyle fill:#dbeafe,stroke:#2563eb,stroke-width:2px,color:#1e40af
    class utils inputStyle
    classDef processStyle fill:#ede9fe,stroke:#7c3aed,stroke-width:2px,color:#5b21b6
    class analysis processStyle
    class main processStyle
```

**Generated Workflow (With Data Artifacts):**
```r
# Show complete data flow including all files
put_diagram(workflow, show_artifacts = TRUE)
```

```mermaid
flowchart TD
    utils([Data Utilities])
    analysis[Statistical Analysis]
    main[Main Analysis Pipeline]
    artifact_results_csv[(results.csv)]

    %% Connections
    utils --> analysis
    utils --> main
    analysis --> main
    main --> artifact_results_csv

    %% Styling
    classDef inputStyle fill:#dbeafe,stroke:#2563eb,stroke-width:2px,color:#1e40af
    class utils inputStyle
    classDef processStyle fill:#ede9fe,stroke:#7c3aed,stroke-width:2px,color:#5b21b6
    class analysis processStyle
    class main processStyle
    classDef artifactStyle fill:#f3f4f6,stroke:#6b7280,stroke-width:1px,color:#374151
    class artifact_results_csv artifactStyle
```

This pattern clearly shows:
- **Function modules** (`utils.R`, `analysis.R`) are sourced into the main script
- **Dependencies** between modules (analysis depends on utils)  
- **Complete data flow** with artifacts showing terminal outputs like `results.csv`
- **Two visualization modes**: simple (script connections only) vs. complete (with data artifacts)

## 📊 Visualization Examples

### Basic Workflow

```r
# Simple three-step process
workflow <- put("./data_pipeline/")
put_diagram(workflow)
```

### Advanced Data Science Pipeline

Here's how putior handles a complete data science workflow:

**File Structure:**
```
data_pipeline/
├── 01_fetch_sales.R      # Fetch sales data
├── 02_fetch_customers.R  # Fetch customer data  
├── 03_clean_sales.py     # Clean sales data
├── 04_merge_data.R       # Merge datasets
├── 05_analyze.py         # Statistical analysis
└── 06_report.R           # Generate final report
```

**Generated Workflow:**
```mermaid
flowchart TD
    fetch_sales([Fetch Sales Data])
    fetch_customers([Fetch Customer Data])
    clean_sales[Clean Sales Data]
    merge_data[Merge Datasets]
    analyze[Statistical Analysis]
    report[[Generate Final Report]]

    %% Connections
    fetch_sales --> clean_sales
    fetch_customers --> merge_data
    clean_sales --> merge_data
    merge_data --> analyze
    analyze --> report

    %% Styling
    classDef inputStyle fill:#dbeafe,stroke:#2563eb,stroke-width:2px,color:#1e40af
    class fetch_sales inputStyle
    class fetch_customers inputStyle
    classDef processStyle fill:#ede9fe,stroke:#7c3aed,stroke-width:2px,color:#5b21b6
    class clean_sales processStyle
    class merge_data processStyle
    class analyze processStyle
    classDef outputStyle fill:#dcfce7,stroke:#16a34a,stroke-width:2px,color:#15803d
    class report outputStyle
```

## 📋 Using the Diagrams

### Embedding in Documentation

The generated Mermaid code works perfectly in:

- **GitHub README files** (native Mermaid support)
- **GitLab documentation** 
- **Notion pages**
- **Obsidian notes**
- **Jupyter notebooks** (with extensions)
- **Sphinx documentation** (with plugins)
- **Any Markdown renderer** with Mermaid support

### Saving and Sharing

```r
# Save to markdown file
put_diagram(workflow, output = "file", file = "workflow.md")

# Copy to clipboard for pasting
put_diagram(workflow, output = "clipboard")

# Include title for documentation
put_diagram(workflow, output = "file", file = "docs/pipeline.md", 
           title = "Data Processing Pipeline")
```

## 🔧 Visualization Modes

putior offers two visualization modes to suit different needs:

### Workflow Boundaries Demo

First, let's see how workflow boundaries enhance pipeline visualization:

**Pipeline with Boundaries (Default):**
```r
# Complete ETL pipeline with clear start/end boundaries
put_diagram(workflow, show_workflow_boundaries = TRUE)
```

```mermaid
flowchart TD
    pipeline_start([Data Pipeline Start])
    extract_data[Extract Raw Data]
    transform_data[Transform Data]
    pipeline_end([Pipeline Complete])

    %% Connections
    pipeline_start --> extract_data
    extract_data --> transform_data
    transform_data --> pipeline_end

    %% Styling
    classDef processStyle fill:#ede9fe,stroke:#7c3aed,stroke-width:2px,color:#5b21b6
    class extract_data processStyle
    class transform_data processStyle
    classDef startStyle fill:#fef3c7,stroke:#d97706,stroke-width:3px,color:#92400e
    class pipeline_start startStyle
    classDef endStyle fill:#dcfce7,stroke:#16a34a,stroke-width:3px,color:#15803d
    class pipeline_end endStyle
```

**Same Pipeline without Boundaries:**
```r
# Clean diagram without workflow control styling
put_diagram(workflow, show_workflow_boundaries = FALSE)
```

```mermaid
flowchart TD
    pipeline_start([Data Pipeline Start])
    extract_data[Extract Raw Data]
    transform_data[Transform Data]
    pipeline_end([Pipeline Complete])

    %% Connections
    pipeline_start --> extract_data
    extract_data --> transform_data
    transform_data --> pipeline_end

    %% Styling
    classDef processStyle fill:#ede9fe,stroke:#7c3aed,stroke-width:2px,color:#5b21b6
    class extract_data processStyle
    class transform_data processStyle
```

### Simple Mode (Default)
Shows only **script-to-script connections** - perfect for understanding code dependencies:
```r
put_diagram(workflow)  # Default: simple mode
```

**Use when:**
- Documenting code architecture
- Showing function dependencies
- Clean, simple workflow diagrams

### Artifact Mode (Complete Data Flow)
Shows **all data files as nodes** - provides complete picture of data flow including terminal outputs:
```r
put_diagram(workflow, show_artifacts = TRUE)
```

**Use when:**
- Documenting data pipelines
- Tracking data lineage
- Showing complete input/output flow
- Understanding data dependencies

### Comparison Example

**Simple Mode:**
```mermaid
flowchart TD
    load[Load Data] --> process[Process Data]
    process --> analyze[Analyze]
```

**Artifact Mode:**
```mermaid
flowchart TD
    load[Load Data]
    raw_data[(raw_data.csv)]
    process[Process Data]
    clean_data[(clean_data.csv)]
    analyze[Analyze]
    results[(results.json)]
    
    load --> raw_data
    raw_data --> process
    process --> clean_data
    clean_data --> analyze
    analyze --> results
```

### Key Differences

| Mode | Shows | Best For |
|------|-------|----------|
| **Simple** | Script connections only | Code architecture, dependencies |
| **Artifact** | Scripts + data files | Data pipelines, complete data flow |

### File Labeling

Add file names to connections for extra clarity:
```r
# Show file names on arrows
put_diagram(workflow, show_artifacts = TRUE, show_files = TRUE)
```

## 🎨 Theme System

putior provides 5 carefully designed themes optimized for different environments:

```r
# Get list of available themes
get_diagram_themes()
```

### Theme Overview

| Theme | Best For | Description |
|-------|----------|-------------|
| `light` | Documentation sites, tutorials | Default light theme with bright colors |
| `dark` | Dark mode apps, terminals | Dark theme with muted colors |
| `auto` | GitHub README files | GitHub-adaptive theme that works in both modes |
| `minimal` | Business reports, presentations | Grayscale professional theme |
| `github` | **GitHub README (recommended)** | Optimized for maximum GitHub compatibility |

### Theme Examples

**Light Theme**
```r
put_diagram(workflow, theme = "light")
```
```mermaid
flowchart TD
    fetch_data([Fetch API Data])
    clean_data[Clean and Validate]
    generate_report[[Generate Final Report]]

    %% Connections
    fetch_data --> clean_data
    clean_data --> generate_report

    %% Styling
    classDef inputStyle fill:#e1f5fe,stroke:#01579b,stroke-width:2px,color:#000000
    class fetch_data inputStyle
    classDef processStyle fill:#f3e5f5,stroke:#4a148c,stroke-width:2px,color:#000000
    class clean_data processStyle
    classDef outputStyle fill:#e8f5e8,stroke:#1b5e20,stroke-width:2px,color:#000000
    class generate_report outputStyle
```

**Dark Theme**
```r
put_diagram(workflow, theme = "dark")
```
```mermaid
flowchart TD
    fetch_data([Fetch API Data])
    clean_data[Clean and Validate]
    generate_report[[Generate Final Report]]

    %% Connections
    fetch_data --> clean_data
    clean_data --> generate_report

    %% Styling
    classDef inputStyle fill:#1a237e,stroke:#3f51b5,stroke-width:2px,color:#ffffff
    class fetch_data inputStyle
    classDef processStyle fill:#4a148c,stroke:#9c27b0,stroke-width:2px,color:#ffffff
    class clean_data processStyle
    classDef outputStyle fill:#1b5e20,stroke:#4caf50,stroke-width:2px,color:#ffffff
    class generate_report outputStyle
```

**Auto Theme (GitHub Adaptive)**
```r
put_diagram(workflow, theme = "auto")  # Recommended for GitHub!
```
```mermaid
flowchart TD
    fetch_data([Fetch API Data])
    clean_data[Clean and Validate]
    generate_report[[Generate Final Report]]

    %% Connections
    fetch_data --> clean_data
    clean_data --> generate_report

    %% Styling
    classDef inputStyle fill:#3b82f6,stroke:#1d4ed8,stroke-width:2px,color:#ffffff
    class fetch_data inputStyle
    classDef processStyle fill:#8b5cf6,stroke:#6d28d9,stroke-width:2px,color:#ffffff
    class clean_data processStyle
    classDef outputStyle fill:#10b981,stroke:#047857,stroke-width:2px,color:#ffffff
    class generate_report outputStyle
```

**GitHub Theme (Maximum Compatibility)**
```r
put_diagram(workflow, theme = "github")  # Best for GitHub README
```
```mermaid
flowchart TD
    fetch_data([Fetch API Data])
    clean_data[Clean and Validate]
    generate_report[[Generate Final Report]]

    %% Connections
    fetch_data --> clean_data
    clean_data --> generate_report

    %% Styling
    classDef inputStyle fill:#dbeafe,stroke:#2563eb,stroke-width:2px,color:#1e40af
    class fetch_data inputStyle
    classDef processStyle fill:#ede9fe,stroke:#7c3aed,stroke-width:2px,color:#5b21b6
    class clean_data processStyle
    classDef outputStyle fill:#dcfce7,stroke:#16a34a,stroke-width:2px,color:#15803d
    class generate_report outputStyle
```

**Minimal Theme**
```r
put_diagram(workflow, theme = "minimal")  # Professional documents
```
```mermaid
flowchart TD
    fetch_data([Fetch API Data])
    clean_data[Clean and Validate]
    generate_report[[Generate Final Report]]

    %% Connections
    fetch_data --> clean_data
    clean_data --> generate_report

    %% Styling
    classDef inputStyle fill:#f8fafc,stroke:#64748b,stroke-width:1px,color:#1e293b
    class fetch_data inputStyle
    classDef processStyle fill:#f1f5f9,stroke:#64748b,stroke-width:1px,color:#1e293b
    class clean_data processStyle
    classDef outputStyle fill:#f8fafc,stroke:#64748b,stroke-width:1px,color:#1e293b
    class generate_report outputStyle
```

### When to Use Each Theme

| Theme | Use Case | Environment |
|-------|----------|-------------|
| `light` | Documentation sites, tutorials | Light backgrounds |
| `dark` | Dark mode apps, terminals | Dark backgrounds |
| `auto` | GitHub README files | Adapts automatically |
| `github` | **GitHub README (recommended)** | Maximum compatibility |
| `minimal` | Business reports, presentations | Print-friendly |

### Pro Tips

- **For GitHub**: Use `theme = "github"` for maximum compatibility, or `theme = "auto"` for adaptive colors
- **For Documentation**: Use `theme = "light"` or `theme = "dark"` to match your site
- **For Reports**: Use `theme = "minimal"` for professional, print-friendly diagrams
- **For Demos**: Light theme usually shows colors best in presentations

### Theme Usage Examples

```r
# For GitHub README (recommended)
put_diagram(workflow, theme = "github")

# For GitHub README (adaptive)  
put_diagram(workflow, theme = "auto")

# For dark documentation sites
put_diagram(workflow, theme = "dark", direction = "LR")

# For professional reports
put_diagram(workflow, theme = "minimal", output = "file", file = "report.md")

# Save all themes for comparison
themes <- c("light", "dark", "auto", "github", "minimal")
for(theme in themes) {
  put_diagram(workflow, 
             theme = theme,
             output = "file", 
             file = paste0("workflow_", theme, ".md"),
             title = paste("Workflow -", stringr::str_to_title(theme), "Theme"))
}
```

## 🔧 Customization Options

### Flow Direction

```r
put_diagram(workflow, direction = "TD")  # Top to bottom (default)
put_diagram(workflow, direction = "LR")  # Left to right  
put_diagram(workflow, direction = "BT")  # Bottom to top
put_diagram(workflow, direction = "RL")  # Right to left
```

### Node Labels

```r
put_diagram(workflow, node_labels = "name")   # Show node IDs
put_diagram(workflow, node_labels = "label")  # Show descriptions (default)
put_diagram(workflow, node_labels = "both")   # Show name: description
```

### File Connections

```r
# Show file names on arrows
put_diagram(workflow, show_files = TRUE)

# Clean arrows without file names  
put_diagram(workflow, show_files = FALSE)
```

### Styling Control

```r
# Include colored styling (default)
put_diagram(workflow, style_nodes = TRUE)

# Plain diagram without colors
put_diagram(workflow, style_nodes = FALSE)

# Control workflow boundary styling
put_diagram(workflow, show_workflow_boundaries = TRUE)   # Special start/end styling (default)
put_diagram(workflow, show_workflow_boundaries = FALSE)  # Regular node styling
```

### Workflow Boundaries

```r
# Enable workflow boundaries (default) - start/end get special styling
put_diagram(workflow, show_workflow_boundaries = TRUE)

# Disable workflow boundaries - start/end render as regular nodes
put_diagram(workflow, show_workflow_boundaries = FALSE)
```

### Output Options

```r
# Console output (default)
put_diagram(workflow)

# Save to markdown file
put_diagram(workflow, output = "file", file = "my_workflow.md")

# Copy to clipboard for pasting
put_diagram(workflow, output = "clipboard")
```

## 📝 Annotation Reference

### Basic Syntax

All PUT annotations follow this format:
```r
#put property1:"value1", property2:"value2", property3:"value3"
```

### Alternative Formats (All Valid)

```r
#put id:"node_id", label:"Description"              # Standard
# put id:"node_id", label:"Description"             # Space after #
#put| id:"node_id", label:"Description"             # Pipe separator
#put: id:"node_id", label:"Description"             # Colon separator
```

### Annotations

| Annotation | Description | Example | Required |
|------------|-------------|---------|----------|
| `id` | Unique identifier for the node (auto-generated if omitted) | `"fetch_data"`, `"clean_sales"` | Optional* |
| `label` | Human-readable description | `"Fetch Sales Data"`, `"Clean and Process"` | Recommended |

*Note: If `id` is omitted, a UUID will be automatically generated. If you provide an empty `id` (e.g., `id:""`), you'll get a validation warning.

### Optional Annotations

| Annotation | Description | Example | Default |
|------------|-------------|---------|---------|
| `node_type` | Visual shape of the node | `"input"`, `"process"`, `"output"`, `"decision"`, `"start"`, `"end"` | `"process"` |
| `input` | Input files (comma-separated) | `"raw_data.csv, config.json"` | None |
| `output` | Output files (comma-separated) | `"processed_data.csv, summary.txt"` | Current file name* |

*Note: If `output` is omitted, it defaults to the name of the file containing the annotation. This ensures nodes can be connected in workflows.

### Node Types and Shapes

putior uses a **data-centric approach** with workflow boundaries as special control elements:

**Data Processing Nodes:**
- **`"input"`** - Data sources, APIs, file readers → Stadium shape `([text])`
- **`"process"`** - Data transformation, analysis → Rectangle `[text]`  
- **`"output"`** - Final results, reports, exports → Subroutine `[[text]]`
- **`"decision"`** - Conditional logic, branching → Diamond `{text}`

**Workflow Control Nodes:**
- **`"start"`** - Workflow entry point → Stadium shape with orange styling
- **`"end"`** - Workflow termination → Stadium shape with green styling

### Workflow Boundaries

Control the visualization of workflow start/end points with `show_workflow_boundaries`:

```r
# Special workflow boundary styling (default)
put_diagram(workflow, show_workflow_boundaries = TRUE)

# Regular nodes without special workflow styling
put_diagram(workflow, show_workflow_boundaries = FALSE)
```

**With boundaries enabled** (default):
- `node_type:"start"` gets distinctive orange styling with thicker borders
- `node_type:"end"` gets distinctive green styling with thicker borders

**With boundaries disabled**:
- Start/end nodes render as regular stadium shapes without special colors

### Example Annotations

**R Scripts:**
```r
#put id:"load_sales_data", label:"Load Sales Data from API", node_type:"input", output:"raw_sales.csv, metadata.json"

#put id:"validate_data", label:"Validate and Clean Data", node_type:"process", input:"raw_sales.csv", output:"clean_sales.csv"

#put id:"generate_report", label:"Generate Executive Summary", node_type:"output", input:"clean_sales.csv, metadata.json", output:"executive_summary.pdf"
```

**Python Scripts:**
```python
#put id:"collect_data", label:"Collect Raw Data", node_type:"input", output:"raw_data.csv"

#put id:"train_model", label:"Train ML Model", node_type:"process", input:"features.csv", output:"model.pkl"

#put id:"predict", label:"Generate Predictions", node_type:"output", input:"model.pkl, test_data.csv", output:"predictions.csv"
```

**Multiple Annotations Per File:**
```r
# analysis.R
#put id:"create_summary", label:"Calculate Summary Stats", node_type:"process", input:"processed_data.csv", output:"summary_stats.json"
#put id:"create_report", label:"Generate Sales Report", node_type:"output", input:"processed_data.csv", output:"sales_report.html"

# Your R code here...
```

**Workflow Entry and Exit Points:**
```r
# main_workflow.R
#put id:"workflow_start", label:"Start Analysis Pipeline", node_type:"start", output:"config.json"

#put id:"workflow_end", label:"Pipeline Complete", node_type:"end", input:"final_report.pdf"
```

**Workflow Boundary Examples:**
```r
# Complete pipeline with boundaries
#put id:"pipeline_start", label:"Data Pipeline Start", node_type:"start", output:"raw_config.json"
#put id:"extract_data", label:"Extract Raw Data", node_type:"process", input:"raw_config.json", output:"raw_data.csv"
#put id:"transform_data", label:"Transform Data", node_type:"process", input:"raw_data.csv", output:"clean_data.csv"
#put id:"pipeline_end", label:"Pipeline Complete", node_type:"end", input:"clean_data.csv"
```

**Generated Workflow with Boundaries:**
```mermaid
flowchart TD
    pipeline_start([Data Pipeline Start])
    extract_data[Extract Raw Data]
    transform_data[Transform Data]
    pipeline_end([Pipeline Complete])
    
    pipeline_start --> extract_data
    extract_data --> transform_data
    transform_data --> pipeline_end
    
    classDef startStyle fill:#e8f5e8,stroke:#2e7d32,stroke-width:3px,color:#1b5e20
    classDef processStyle fill:#ede9fe,stroke:#7c3aed,stroke-width:2px,color:#5b21b6
    classDef endStyle fill:#ffebee,stroke:#c62828,stroke-width:3px,color:#b71c1c
    class pipeline_start startStyle
    class extract_data,transform_data processStyle
    class pipeline_end endStyle
```

### Supported File Types

putior automatically detects and processes these file types:
- **R**: `.R`, `.r`
- **Python**: `.py`
- **SQL**: `.sql`
- **Shell**: `.sh`
- **Julia**: `.jl`

## 🛠️ Advanced Usage

### Directory Scanning

```r
# Scan current directory
workflow <- put(".")

# Scan specific directory
workflow <- put("./src/")

# Recursive scanning (include subdirectories)
workflow <- put("./project/", recursive = TRUE)

# Custom file patterns
workflow <- put("./analysis/", pattern = "\\.(R|py)$")

# Single file
workflow <- put("./script.R")
```

### Debugging and Validation

```r
# Include line numbers for debugging
workflow <- put("./src/", include_line_numbers = TRUE)

# Disable validation warnings  
workflow <- put("./src/", validate = FALSE)

# Test annotation syntax
is_valid_put_annotation('#put id:"test", label:"Test Node"')  # TRUE
is_valid_put_annotation("#put invalid syntax")                 # FALSE
```

### UUID Auto-Generation

When you omit the `id` field, putior automatically generates a unique UUID:

```r
# Annotations without explicit IDs
#put label:"Load Data", node_type:"input", output:"data.csv"
#put label:"Process Data", node_type:"process", input:"data.csv"

# Extract workflow - IDs will be auto-generated
workflow <- put("./")
print(workflow$id)
# [1] "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
# [2] "b2c3d4e5-f6a7-8901-bcde-f23456789012"
```

This feature is perfect for:
- Quick prototyping without worrying about unique IDs
- Temporary workflows where IDs don't matter
- Ensuring uniqueness across large codebases

Note: If you provide an empty `id` (e.g., `id:""`), you'll get a validation warning.

### Tracking Source Relationships

When you have a main script that sources other scripts, annotate them to show the sourcing relationships:

```r
# main.R - sources other scripts
#put label:"Main Workflow", input:"utils.R,analysis.R", output:"results.csv"
source("utils.R")     # Reading utils.R into main.R
source("analysis.R")  # Reading analysis.R into main.R

# utils.R - sourced by main.R  
#put label:"Utility Functions", node_type:"input"
# output defaults to "utils.R"

# analysis.R - sourced by main.R, depends on utils.R
#put label:"Analysis Functions", input:"utils.R"  
# output defaults to "analysis.R"
```

This creates a diagram showing:
- `utils.R` → `main.R` (sourced into)
- `analysis.R` → `main.R` (sourced into)
- `utils.R` → `analysis.R` (dependency)

## 🔄 Self-Documentation: putior Documents Itself!

As a demonstration of putior's capabilities, we've added PUT annotations to putior's own source code. This creates a beautiful visualization of how the package works internally:

```r
# Extract putior's own workflow
workflow <- put("./R/")
put_diagram(workflow, theme = "github", title = "putior Package Internals")
```

**Result:**
```mermaid
---
title: putior Package Internals
---
flowchart TD
    put_entry([Entry Point - Scan Files])
    process_file[Process Single File]
    parser[Parse Annotation Syntax]
    convert_df[Convert to Data Frame]
    diagram_gen[Generate Mermaid Diagram]
    node_defs[Create Node Definitions]
    connections[Generate Node Connections]
    output_handler([Output Final Diagram])

    %% Connections
    put_entry --> process_file
    process_file --> parser
    parser --> convert_df
    convert_df --> diagram_gen
    diagram_gen --> node_defs
    node_defs --> connections
    connections --> output_handler

    %% Styling
    classDef processStyle fill:#ede9fe,stroke:#7c3aed,stroke-width:2px,color:#5b21b6
    class process_file processStyle
    class parser processStyle
    class convert_df processStyle
    class diagram_gen processStyle
    class node_defs processStyle
    class connections processStyle
    classDef startStyle fill:#fef3c7,stroke:#d97706,stroke-width:3px,color:#92400e
    class put_entry startStyle
    classDef endStyle fill:#dcfce7,stroke:#16a34a,stroke-width:3px,color:#15803d
    class output_handler endStyle
```

This self-documentation shows the two main phases of putior:
1. **Parsing Phase**: Scanning files → extracting annotations → converting to workflow data
2. **Diagram Generation Phase**: Taking workflow data → creating nodes/connections → outputting diagram

To see the complete data flow with intermediate files, run:
```r
put_diagram(workflow, show_artifacts = TRUE, theme = "github")
```

## 🤝 Contributing

Contributions welcome! Please open an issue or pull request on [GitHub](https://github.com/pjt222/putior).

**Development Setup:**
```bash
git clone https://github.com/pjt222/putior.git
cd putior

# Install dev dependencies  
Rscript -e "devtools::install_dev_deps()"

# Run tests
Rscript -e "devtools::test()"

# Check package
Rscript -e "devtools::check()"
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📊 How putior Compares to Other R Packages

putior fills a unique niche in the R ecosystem by combining annotation-based workflow extraction with beautiful diagram generation:

| Package | Focus | Approach | Output | Best For |
|---------|-------|----------|--------|----------|
| **putior** | **Data workflow visualization** | **Code annotations** | **Mermaid diagrams** | **Pipeline documentation** |
| [CodeDepends](https://cran.r-project.org/package=CodeDepends) | Code dependency analysis | Static analysis | Variable graphs | Understanding code structure |
| [DiagrammeR](https://cran.r-project.org/package=DiagrammeR) | General diagramming | Manual diagram code | Interactive graphs | Custom diagrams |
| [visNetwork](https://cran.r-project.org/package=visNetwork) | Interactive networks | Manual network definition | Interactive vis.js | Complex network exploration |
| [dm](https://cran.r-project.org/package=dm) | Database relationships | Schema analysis | ER diagrams | Database documentation |
| [flowchart](https://cran.r-project.org/package=flowchart) | Study flow diagrams | Dataframe input | ggplot2 charts | Clinical trials |

### Key Advantages of putior

- **📝 Annotation-Based**: Workflow documentation lives in your code comments
- **🔄 Multi-Language**: Works across R, Python, SQL, Shell, and Julia
- **📁 File Flow Tracking**: Automatically connects scripts based on input/output files
- **🎨 Beautiful Output**: GitHub-ready Mermaid diagrams with multiple themes
- **📦 Lightweight**: Minimal dependencies (only requires `tools` package)
- **🔍 Two Views**: Simple script connections + complete data artifact flow

## 🙏 Acknowledgments

- Built with [Mermaid](https://mermaid-js.github.io/) for beautiful diagram generation
- Inspired by the need for better code documentation and workflow visualization
- Thanks to the R community for excellent development tooling

### 🌟 Shoutout to Related R Packages

putior stands on the shoulders of giants in the R visualization and workflow ecosystem:

- **[CodeDepends](https://cran.r-project.org/package=CodeDepends)** by Duncan Temple Lang - pioneering work in R code dependency analysis
- **[DiagrammeR](https://cran.r-project.org/package=DiagrammeR)** by Richard Iannone - bringing beautiful graph visualization to R
- **[visNetwork](https://cran.r-project.org/package=visNetwork)** by Almende B.V. - interactive network visualization excellence
- **[networkD3](https://cran.r-project.org/package=networkD3)** by Christopher Gandrud - D3.js network graphs in R
- **[dm](https://cran.r-project.org/package=dm)** by energie360° AG - relational data model visualization
- **[flowchart](https://cran.r-project.org/package=flowchart)** by Adrian Antico - participant flow diagrams
- **[igraph](https://cran.r-project.org/package=igraph)** by Gábor Csárdi & Tamás Nepusz - the foundation of network analysis in R

Each of these packages excels in their domain, and putior complements them by focusing specifically on code workflow documentation through annotations.

---

**Made with ❤️ for polyglot data science workflows across R, Python, Julia, SQL, Shell, and beyond**
