# putior <img src="man/figures/logo.svg" align="right" height="139" alt="" />

**PUT + Input + Output + R**: Register In- and Outputs for Workflow Visualization

## Overview

putior is an R package that extracts structured annotations from R and Python source files and creates elegant workflow visualizations. Simply add PUT annotations to your code, and putior will automatically generate beautiful mermaid diagrams showing your data pipeline flow.

**Why putior?** Keep your workflow documentation in sync with your code. No more outdated flowcharts!

## ✨ Features

### 🔍 **Workflow Extraction**
- **Multi-language support**: R, Python, SQL, shell scripts, Julia
- **Flexible annotation syntax**: `#put`, `# put`, `#put|`
- **Smart file parsing**: Automatically detects data flow between scripts
- **Custom properties**: Add any metadata you need

### 🎨 **Beautiful Visualizations**
- **Elegant mermaid diagrams**: Professional, GitHub-ready flowcharts
- **Smart node shapes**: Different shapes for inputs, processes, outputs, decisions
- **Color-coded styling**: Visual distinction between node types
- **Multiple layouts**: Top-down, left-right, custom directions
- **File flow labels**: See exactly how data moves through your pipeline

### 🚀 **Production Ready**
- **Comprehensive testing**: 180+ tests ensure reliability
- **Extensive documentation**: Vignettes, examples, and detailed help
- **Validation system**: Catches common annotation mistakes
- **Export options**: Console, file, clipboard output

## Installation

### From GitHub

```r
# Install with devtools
devtools::install_github("username/putior")

# Or with pak (faster)
pak::pkg_install("username/putior")
```

## 🚀 Quick Start

### 1. **Try the Examples**

```r
# See putior in action with a complete workflow
source(system.file("examples", "reprex.R", package = "putior"))

# Try the visualization examples  
source(system.file("examples", "diagram-example.R", package = "putior"))
```

### 2. **Basic Usage**

**Annotate your code:**
```r
# data_collection.R
#put name:"fetch_api", label:"Fetch Sales Data", node_type:"input", output:"raw_sales.csv"
sales_data <- fetch_from_api("/sales")
write.csv(sales_data, "raw_sales.csv")
```

```python
# analysis.py  
#put name:"clean_data", label:"Clean and Process", node_type:"process", input:"raw_sales.csv", output:"clean_sales.csv"
import pandas as pd
data = pd.read_csv("raw_sales.csv")
clean_data = data.dropna()
clean_data.to_csv("clean_sales.csv")
```

**Extract and visualize:**
```r
library(putior)

# Extract workflow
workflow <- put("./src")

# Create diagram
put_diagram(workflow)
```

**Result:**
````mermaid
flowchart TD
    fetch_api([Fetch Sales Data])
    clean_data[Clean and Process]
    
    fetch_api --> clean_data
    
    classDef inputStyle fill:#e1f5fe,stroke:#01579b
    classDef processStyle fill:#f3e5f5,stroke:#4a148c
    class fetch_api inputStyle
    class clean_data processStyle
````

## 📊 Visualization Examples

### Basic Workflow
```r
workflow <- put("./src")
put_diagram(workflow)
```

### Horizontal Layout with File Labels
```r
put_diagram(workflow, 
           direction = "LR", 
           show_files = TRUE,
           title = "Data Processing Pipeline")
```

### Styled Diagram with Custom Labels
```r
put_diagram(workflow,
           node_labels = "both",  # Show names + descriptions
           style_nodes = TRUE,    # Color-code by type
           title = "Sales Analysis Workflow")
```

### Save to File
```r
put_diagram(workflow, 
           output = "file", 
           file = "workflow.md",
           title = "My Data Pipeline")
```

## 🎯 PUT Annotation Guide

### Basic Syntax
```r
#put property1:"value1", property2:"value2"
```

### Core Properties
- **`name`**: Unique identifier (required)
- **`label`**: Human-readable description  
- **`node_type`**: `"input"`, `"process"`, `"output"`, `"decision"`
- **`input`**: Input files consumed (comma-separated)
- **`output`**: Output files produced (comma-separated)

### Advanced Properties
```r
#put name:"train_model", label:"Train ML Model", node_type:"process", 
     input:"features.csv", output:"model.pkl", 
     duration:"30min", memory:"high", team:"data-science"
```

### Flexible Formats
```r
#put name:"node1", label:"Process Data"           # Standard
# put name:"node1", label:"Process Data"          # Space after #
#put| name:"node1", label:"Process Data"          # Pipe separator  
#put: name:"node1", label:"Process Data"          # Colon separator
```

## 🔄 Real-World Example

Here's how putior handles a complete data science workflow:

**Python Data Collection**
```python
# 01_collect.py
#put name:"fetch_sales", label:"Fetch Sales Data", node_type:"input", output:"raw_sales.csv"  
#put name:"fetch_customers", label:"Fetch Customer Data", node_type:"input", output:"raw_customers.csv"
```

**R Data Processing**  
```r
# 02_process.R
#put name:"clean_sales", label:"Clean Sales Data", node_type:"process", input:"raw_sales.csv", output:"clean_sales.csv"
#put name:"merge_data", label:"Merge Datasets", node_type:"process", input:"clean_sales.csv,raw_customers.csv", output:"merged_data.csv"
```

**R Analysis & Reporting**
```r
# 03_analyze.R  
#put name:"analyze", label:"Statistical Analysis", node_type:"process", input:"merged_data.csv", output:"results.rds"
#put name:"report", label:"Generate Report", node_type:"output", input:"results.rds", output:"final_report.html"
```

**Generated Workflow:**
````mermaid
flowchart TD
    fetch_sales([Fetch Sales Data])
    fetch_customers([Fetch Customer Data])
    clean_sales[Clean Sales Data]  
    merge_data[Merge Datasets]
    analyze[Statistical Analysis]
    report[[Generate Report]]
    
    fetch_sales --> clean_sales
    fetch_customers --> merge_data
    clean_sales --> merge_data
    merge_data --> analyze
    analyze --> report
````

## 📋 Using the Diagrams

The generated mermaid diagrams work everywhere:

### **GitHub/GitLab** (Native Rendering)
Just paste the mermaid code into any `.md` file - it renders automatically!

### **Documentation Sites**  
- R Markdown / Quarto documents
- Jupyter notebooks  
- GitBook, Docusaurus, etc.

### **Live Editing**
- **Mermaid Live Editor**: https://mermaid.live  
- **VS Code**: Install mermaid extensions
- **Export**: PNG, SVG, PDF formats

## 🛠️ Advanced Usage

### Directory Scanning
```r
# Recursive scanning  
workflow <- put("./project", recursive = TRUE)

# Custom file patterns
workflow <- put("./src", pattern = "\\.(R|py|sql)$")

# Single files
workflow <- put("./analysis.R")
```

### Debugging & Validation
```r
# Include line numbers for debugging
workflow <- put("./src", include_line_numbers = TRUE)

# Disable validation warnings
workflow <- put("./src", validate = FALSE)

# Test annotation syntax
is_valid_put_annotation('#put name:"test", label:"Test Node"')  # TRUE
```

### Filtering Workflows
```r
# Show only processing steps
process_nodes <- workflow[workflow$node_type == "process", ]
put_diagram(process_nodes, title = "Data Processing Steps")

# Show workflow by team/group
ml_nodes <- workflow[grepl("ml", workflow$team), ]
put_diagram(ml_nodes, title = "Machine Learning Pipeline")
```

## 📖 Documentation

```r
# Function help
?put
?put_diagram

# Package overview
help(package = "putior")

# Comprehensive guide
vignette("getting-started", package = "putior")

# Examples
example(put)
example(put_diagram)
```

## 🎯 Use Cases

- **📊 Data Science Teams**: Visualize ML pipelines and data flows
- **📈 Analytics Projects**: Document ETL processes and reporting workflows  
- **🔄 Process Documentation**: Keep workflow docs in sync with code
- **👥 Team Onboarding**: Help new members understand complex projects
- **🔍 Code Review**: Visualize changes to data processing logic
- **📋 Compliance**: Generate audit trails for data processing

## 🎨 Themes & Styling

putior supports multiple color themes to match your environment and preferences:

### Available Themes

```r
# See all available themes
get_diagram_themes()
```

- **`"light"`** (default): Bright colors with dark text - perfect for documentation
- **`"dark"`**: Muted colors with light text - ideal for dark mode environments  
- **`"auto"`**: GitHub adaptive theme - automatically works in both light/dark modes
- **`"minimal"`**: Grayscale professional theme - great for business documents

### Theme Examples

**Light Theme (Default)**
```r
put_diagram(workflow, theme = "light")
```
````mermaid
flowchart TD
    fetch_data([Fetch API Data])
    clean_data[Clean and Validate]
    generate_report[[Generate Final Report]]
    
    fetch_data --> clean_data
    clean_data --> generate_report
    
    classDef inputStyle fill:#e1f5fe,stroke:#01579b,color:#000
    classDef processStyle fill:#f3e5f5,stroke:#4a148c,color:#000
    classDef outputStyle fill:#e8f5e8,stroke:#1b5e20,color:#000
    class fetch_data inputStyle
    class clean_data processStyle  
    class generate_report outputStyle
````

**Dark Theme**
```r
put_diagram(workflow, theme = "dark")
```
````mermaid
flowchart TD
    fetch_data([Fetch API Data])
    clean_data[Clean and Validate]
    generate_report[[Generate Final Report]]
    
    fetch_data --> clean_data
    clean_data --> generate_report
    
    classDef inputStyle fill:#1a237e,stroke:#3f51b5,color:#fff
    classDef processStyle fill:#4a148c,stroke:#9c27b0,color:#fff
    classDef outputStyle fill:#1b5e20,stroke:#4caf50,color:#fff
    class fetch_data inputStyle
    class clean_data processStyle
    class generate_report outputStyle
````

**Auto Theme (GitHub Adaptive)**
```r
put_diagram(workflow, theme = "auto")  # Recommended for GitHub!
```

**Minimal Theme**
```r
put_diagram(workflow, theme = "minimal")  # Professional documents
```

### When to Use Each Theme

| Theme | Best For | Environment |
|-------|----------|-------------|
| `light` | Documentation sites, tutorials | Light backgrounds |
| `dark` | Dark mode apps, terminals | Dark backgrounds |
| `auto` | **GitHub README files** | Adapts automatically |
| `minimal` | Business reports, presentations | Print-friendly |

### Pro Tips

- **For GitHub**: Use `theme = "auto"` - it adapts to the viewer's theme preference
- **For Documentation**: Use `theme = "light"` or `theme = "dark"` to match your site
- **For Reports**: Use `theme = "minimal"` for professional, print-friendly diagrams
- **For Demos**: Light theme usually shows colors best in presentations

## 🤝 Contributing

Contributions welcome! Please see our [contribution guidelines](CONTRIBUTING.md).

**Development Setup:**
```r
# Clone and setup
git clone https://github.com/username/putior.git
cd putior

# Install dev dependencies  
renv::restore()

# Run tests
devtools::test()

# Check package
devtools::check()
```

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details.

## 👨‍💻 Author

**Philipp Thoss**  
🔗 ORCID: [0000-0002-4672-2792](https://orcid.org/0000-0002-4672-2792)

---

**putior**: Because workflow documentation should be as dynamic as your code! 🚀