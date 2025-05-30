# putior <img src="man/figures/logo.svg" align="right" height="139" alt="" />

Register In- and Outputs for Workflow Visualization

## Overview

putior is an R package designed to extract and process structured annotations from R and Python source files, enabling workflow visualization in polyglot software environments. The package scans source code for special PUT annotations that define nodes, connections, and metadata within data processing workflows, making it easier to document and visualize complex data pipelines.

## Features

putior offers comprehensive annotation processing capabilities:

- **Multi-language support**: Extracts structured annotations from both R and Python source files
- **Flexible syntax**: Supports multiple annotation formats (`#put`, `# put`, `#put|`)
- **Arbitrary properties**: Captures custom key-value properties for flexible metadata
- **Clean output**: Returns results in tabular format ready for visualization
- **Batch processing**: Handles both single-file and directory-wide scanning

## Installation

### From GitHub with renv

If you're using renv for package management, you can install putior directly from GitHub:

```r
# Initialize renv if you haven't already
renv::init()

# Install putior
renv::install("pjt222/putior")

# Update renv.lock
renv::snapshot()
```

### From GitHub with devtools

Alternatively, you can install using devtools:

```r
# Install devtools if needed
if (!require("devtools")) install.packages("devtools")

# Install putior
devtools::install_github("pjt222/putior")
```

## Quick Start

See a complete working example:

```r
# Run the built-in example
source(system.file("examples", "reprex.R", package = "putior"))
```

This creates a sample multi-language workflow and demonstrates putior's workflow extraction capabilities.

## Usage

### Basic Workflow

**1. Add PUT annotations to your source files:**

**R script example:**
```r
# data_processing.R
#put name:"load_data", label:"Load Dataset", node_type:"input", output:"raw_data.csv"
data <- read.csv("raw_data.csv")

#put name:"clean_data", label:"Clean and Transform", node_type:"process", input:"raw_data.csv", output:"clean_data.csv"
cleaned <- clean_dataset(data)
write.csv(cleaned, "clean_data.csv")
```

**Python script example:**
```python
# analysis.py
#put name:"train_model", label:"Train ML Model", node_type:"process", input:"clean_data.csv", output:"model.pkl"
import pandas as pd
from sklearn.ensemble import RandomForestClassifier

data = pd.read_csv("clean_data.csv")
model = RandomForestClassifier()
model.fit(X_train, y_train)
```

**2. Extract the workflow:**

```r
library(putior)

# Process all R and Python files in a directory
workflow <- put("./src")

# View the extracted workflow
print(workflow)
#>            file_name file_type        input                label         name
#> 1 data_processing.R         r         <NA>         Load Dataset    load_data
#> 2 data_processing.R         r raw_data.csv   Clean and Transform   clean_data
#> 3        analysis.py        py clean_data.csv    Train ML Model  train_model
#>   node_type        output
#> 1     input   raw_data.csv
#> 2   process  clean_data.csv
#> 3   process     model.pkl
```

### Advanced Features

**Custom properties for visualization:**
```r
#put name:"analyze", label:"Statistical Analysis", node_type:"process", color:"blue", group:"stats", duration:"5min"
```

**Multiple annotations per file:**
```r
# reporting.R
#put name:"create_report", label:"Generate Report", node_type:"output", input:"results.csv", output:"report.html"
#put name:"send_email", label:"Email Results", node_type:"output", input:"report.html"
```

## PUT Annotation Syntax

```r
#put property1:"value1", property2:"value2", property3:"value3"
```

**Common properties:**
- `name`: Unique identifier for the node
- `label`: Human-readable description
- `node_type`: Type of operation (input, process, output)
- `input`: Input file(s) consumed
- `output`: Output file(s) produced

**Flexible format:**
- `#put name:"my_node", label:"My Process"`
- `# put name:"my_node", label:"My Process"` (space after #)
- `#put| name:"my_node", label:"My Process"` (pipe separator)

## Documentation

Access the package documentation:

```r
# Main function help
?put

# See all package functions
help(package = "putior")

# View examples
example(put)
```

## Use Cases

- **Workflow documentation**: Automatically generate documentation for data science pipelines
- **Code visualization**: Create flowcharts and diagrams from annotated code
- **Data lineage tracking**: Track how data flows through processing steps
- **Project onboarding**: Help new team members understand complex workflows
- **Quality assurance**: Verify that all workflow steps are properly documented

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

**Development setup:**
1. Fork the repository
2. Create your feature branch: `git checkout -b feature/AmazingFeature`
3. Make your changes and add tests
4. Commit your changes: `git commit -m 'Add some AmazingFeature'`
5. Push to the branch: `git push origin feature/AmazingFeature`
6. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Author

**Philipp Thoss**  
📧 ph.thoss@gmx.de  
🔗 ORCID: [0000-0002-4672-2792](https://orcid.org/0000-0002-4672-2792)