# putior

[![R CMD check](https://github.com/pjt222/putior/workflows/R-CMD-check/badge.svg)](https://github.com/pjt222/putior/actions) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT) [![lifecycle](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)

> **Extract beautiful workflow diagrams from your code annotations**

putior is an R package that extracts structured annotations from R and Python source files and creates beautiful Mermaid flowchart diagrams. Perfect for documenting data pipelines, workflows, and understanding complex codebases.

## 🌟 Key Features

-   **Simple annotations** - Add structured comments to your existing code
-   **Beautiful diagrams** - Generate professional Mermaid flowcharts
-   **File flow tracking** - Automatically connects scripts based on input/output files\
-   **Multiple themes** - 5 built-in themes including GitHub-optimized
-   **Cross-language support** - Works with R, Python, and more
-   **Flexible output** - Console, file, or clipboard export
-   **Customizable styling** - Control colors, direction, and node shapes

## 📦 Installation

``` r
# Install with devtools
devtools::install_github("pjt222/putior")

# Or with pak (faster)
pak::pkg_install("pjt222/putior")
```

## 🚀 Quick Start

### Step 1: Annotate Your Code

Add structured annotations to your R or Python scripts using `#'` comments:

**`01_fetch_data.R`**

``` r
#' @put name: fetch_sales
#' @put label: Fetch Sales Data
#' @put node_type: input
#' @put output: sales_data.csv

# Your actual code
library(readr)
sales_data <- fetch_sales_from_api()
write_csv(sales_data, "sales_data.csv")
```

**`02_clean_data.py`**

``` python
# @put name: clean_data  
# @put label: Clean and Process
# @put node_type: process
# @put input: sales_data.csv
# @put output: clean_sales.csv

import pandas as pd
df = pd.read_csv("sales_data.csv")
# ... data cleaning code ...
df.to_csv("clean_sales.csv")
```

### Step 2: Extract and Visualize

``` r
library(putior)

# Extract workflow from your scripts
workflow <- put("./scripts/")

# Generate diagram
put_diagram(workflow)
```

**Result:**

``` mermaid
flowchart TD
    fetch_sales([Fetch Sales Data])
    clean_data[Clean and Process]
    
    fetch_sales --> clean_data
    
    classDef inputStyle fill:#dbeafe,stroke:#2563eb,stroke-width:2px,color:#1e40af
    classDef processStyle fill:#ede9fe,stroke:#7c3aed,stroke-width:2px,color:#5b21b6
    class fetch_sales inputStyle
    class clean_data processStyle
```

## 📊 Visualization Examples

### Basic Workflow

``` r
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

``` mermaid
flowchart TD
    fetch_sales([Fetch Sales Data])
    fetch_customers([Fetch Customer Data])
    clean_sales[Clean Sales Data]
    merge_data[Merge Datasets]
    analyze[Statistical Analysis]
    report[[Generate Final Report]]

    fetch_sales --> clean_sales
    fetch_customers --> merge_data
    clean_sales --> merge_data
    merge_data --> analyze
    analyze --> report
    
    classDef inputStyle fill:#dbeafe,stroke:#2563eb,stroke-width:2px,color:#1e40af
    classDef processStyle fill:#ede9fe,stroke:#7c3aed,stroke-width:2px,color:#5b21b6
    classDef outputStyle fill:#dcfce7,stroke:#16a34a,stroke-width:2px,color:#15803d
    class fetch_sales,fetch_customers inputStyle
    class clean_sales,merge_data,analyze processStyle
    class report outputStyle
```

## 📋 Using the Diagrams

### Embedding in Documentation

The generated Mermaid code works perfectly in:

-   **GitHub README files** (native Mermaid support)
-   **GitLab documentation**
-   **Notion pages**
-   **Obsidian notes**
-   **Jupyter notebooks** (with extensions)
-   **Sphinx documentation** (with plugins)
-   **Any Markdown renderer** with Mermaid support

### Saving and Sharing

``` r
# Save to markdown file
put_diagram(workflow, output = "file", file = "workflow.md")

# Copy to clipboard for pasting
put_diagram(workflow, output = "clipboard")

# Include title for documentation
put_diagram(workflow, output = "file", file = "docs/pipeline.md", 
           title = "Data Processing Pipeline")
```

## 🎨 Theme System

putior provides 5 carefully designed themes optimized for different environments:

``` r
# Get list of available themes
get_diagram_themes()
```

### Theme Overview

| Theme | Best For | Description |
|------------------|------------------------|-------------------------------|
| `light` | Documentation sites, tutorials | Default light theme with bright colors |
| `dark` | Dark mode apps, terminals | Dark theme with muted colors |
| `auto` | GitHub README files | GitHub-adaptive theme that works in both modes |
| `minimal` | Business reports, presentations | Grayscale professional theme |
| `github` | **GitHub README (recommended)** | Optimized for maximum GitHub compatibility |

### Theme Examples

**Light Theme**

``` r
put_diagram(workflow, theme = "light")
```

``` mermaid
flowchart TD
    fetch_data([Fetch API Data])
    clean_data[Clean and Validate]
    generate_report[[Generate Final Report]]
    
    fetch_data --> clean_data
    clean_data --> generate_report
    
    classDef inputStyle fill:#e1f5fe,stroke:#01579b,stroke-width:2px,color:#000000
    classDef processStyle fill:#f3e5f5,stroke:#4a148c,stroke-width:2px,color:#000000
    classDef outputStyle fill:#e8f5e8,stroke:#1b5e20,stroke-width:2px,color:#000000
    class fetch_data inputStyle
    class clean_data processStyle  
    class generate_report outputStyle
```

**Dark Theme**

``` r
put_diagram(workflow, theme = "dark")
```

``` mermaid
flowchart TD
    fetch_data([Fetch API Data])
    clean_data[Clean and Validate]
    generate_report[[Generate Final Report]]
    
    fetch_data --> clean_data
    clean_data --> generate_report
    
    classDef inputStyle fill:#1a237e,stroke:#3f51b5,stroke-width:2px,color:#ffffff
    classDef processStyle fill:#4a148c,stroke:#9c27b0,stroke-width:2px,color:#ffffff
    classDef outputStyle fill:#1b5e20,stroke:#4caf50,stroke-width:2px,color:#ffffff
    class fetch_data inputStyle
    class clean_data processStyle
    class generate_report outputStyle
```

**Auto Theme (GitHub Adaptive)**

``` r
put_diagram(workflow, theme = "auto")  # Recommended for GitHub!
```

``` mermaid
flowchart TD
    fetch_data([Fetch API Data])
    clean_data[Clean and Validate]
    generate_report[[Generate Final Report]]
    
    fetch_data --> clean_data
    clean_data --> generate_report
    
    classDef inputStyle fill:#3b82f6,stroke:#1d4ed8,stroke-width:2px,color:#ffffff
    classDef processStyle fill:#8b5cf6,stroke:#6d28d9,stroke-width:2px,color:#ffffff
    classDef outputStyle fill:#10b981,stroke:#047857,stroke-width:2px,color:#ffffff
    class fetch_data inputStyle
    class clean_data processStyle
    class generate_report outputStyle
```

**GitHub Theme (Maximum Compatibility)**

``` r
put_diagram(workflow, theme = "github")  # Best for GitHub README
```

``` mermaid
flowchart TD
    fetch_data([Fetch API Data])
    clean_data[Clean and Validate]
    generate_report[[Generate Final Report]]
    
    fetch_data --> clean_data
    clean_data --> generate_report
    
    classDef inputStyle fill:#dbeafe,stroke:#2563eb,stroke-width:2px,color:#1e40af
    classDef processStyle fill:#ede9fe,stroke:#7c3aed,stroke-width:2px,color:#5b21b6
    classDef outputStyle fill:#dcfce7,stroke:#16a34a,stroke-width:2px,color:#15803d
    class fetch_data inputStyle
    class clean_data processStyle
    class generate_report outputStyle
```

**Minimal Theme**

``` r
put_diagram(workflow, theme = "minimal")  # Professional documents
```

``` mermaid
flowchart TD
    fetch_data([Fetch API Data])
    clean_data[Clean and Validate]
    generate_report[[Generate Final Report]]
    
    fetch_data --> clean_data
    clean_data --> generate_report
    
    classDef inputStyle fill:#f8fafc,stroke:#64748b,stroke-width:1px,color:#1e293b
    classDef processStyle fill:#f1f5f9,stroke:#64748b,stroke-width:1px,color:#1e293b
    classDef outputStyle fill:#f8fafc,stroke:#64748b,stroke-width:1px,color:#1e293b
    class fetch_data inputStyle
    class clean_data processStyle
    class generate_report outputStyle
```

### When to Use Each Theme

| Theme     | Use Case                        | Environment           |
|-----------|---------------------------------|-----------------------|
| `light`   | Documentation sites, tutorials  | Light backgrounds     |
| `dark`    | Dark mode apps, terminals       | Dark backgrounds      |
| `auto`    | GitHub README files             | Adapts automatically  |
| `github`  | **GitHub README (recommended)** | Maximum compatibility |
| `minimal` | Business reports, presentations | Print-friendly        |

### Pro Tips

-   **For GitHub**: Use `theme = "github"` for maximum compatibility, or `theme = "auto"` for adaptive colors
-   **For Documentation**: Use `theme = "light"` or `theme = "dark"` to match your site
-   **For Reports**: Use `theme = "minimal"` for professional, print-friendly diagrams
-   **For Demos**: Light theme usually shows colors best in presentations

### Theme Usage Examples

``` r
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

``` r
put_diagram(workflow, direction = "TD")  # Top to bottom (default)
put_diagram(workflow, direction = "LR")  # Left to right  
put_diagram(workflow, direction = "BT")  # Bottom to top
put_diagram(workflow, direction = "RL")  # Right to left
```

### Node Labels

``` r
put_diagram(workflow, node_labels = "name")   # Show function names
put_diagram(workflow, node_labels = "label")  # Show descriptions (default)
put_diagram(workflow, node_labels = "both")   # Show name: description
```

### File Connections

``` r
# Show file names on arrows
put_diagram(workflow, show_files = TRUE)

# Clean arrows without file names  
put_diagram(workflow, show_files = FALSE)
```

### Styling Control

``` r
# Include colored styling (default)
put_diagram(workflow, style_nodes = TRUE)

# Plain diagram without colors
put_diagram(workflow, style_nodes = FALSE)
```

### Output Options

``` r
# Console output (default)
put_diagram(workflow)

# Save to markdown file
put_diagram(workflow, output = "file", file = "my_workflow.md")

# Copy to clipboard for pasting
put_diagram(workflow, output = "clipboard")
```

## 📝 Annotation Reference

### Required Annotations

| Annotation | Description | Example |
|-------------------------|---------------------------|-------------------|
| `name` | Unique identifier for the node | `fetch_data`, `clean_sales` |
| `label` | Human-readable description | `Fetch Sales Data`, `Clean and Process` |

### Optional Annotations

| Annotation | Description | Example |
|-------------------------|---------------------------|-------------------|
| `node_type` | Visual shape of the node | `input`, `process`, `output`, `decision` |
| `input` | Input files (comma-separated) | `raw_data.csv, config.json` |
| `output` | Output files (comma-separated) | `processed_data.csv, summary.txt` |

### Node Types and Shapes

-   **`input`** - Data sources, APIs, file readers → Stadium shape `([text])`
-   **`process`** - Data transformation, analysis → Rectangle `[text]`\
-   **`output`** - Final results, reports, exports → Subroutine `[[text]]`
-   **`decision`** - Conditional logic, branching → Diamond `{text}`

### Example Annotations

``` r
#' @put name: load_sales_data
#' @put label: Load Sales Data from API
#' @put node_type: input
#' @put output: raw_sales.csv, metadata.json

#' @put name: validate_data
#' @put label: Validate and Clean Data  
#' @put node_type: process
#' @put input: raw_sales.csv
#' @put output: clean_sales.csv

#' @put name: generate_report
#' @put label: Generate Executive Summary
#' @put node_type: output
#' @put input: clean_sales.csv, metadata.json
#' @put output: executive_summary.pdf
```

## 🤝 Contributing

Contributions welcome! Please see our [contribution guidelines](CONTRIBUTING.md).

**Development Setup:**

``` bash
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

## 🙏 Acknowledgments

-   Built with [Mermaid](https://mermaid-js.github.io/) for beautiful diagram generation
-   Inspired by the need for better code documentation and workflow visualization
-   Thanks to the R community for excellent development tooling

------------------------------------------------------------------------

**Made with ❤️ for the R and Python communities**
