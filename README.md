# putior <img src="man/figures/logo.svg" align="right" height="139" alt="" />

Register In- and Outputs for Workflow Visualization

## Overview

putior is an R package designed to extract and process structured annotations from R and Python source files, enabling workflow visualization in polyglot software environments. The package scans source code for special PUT annotations that define nodes, connections, and metadata within data processing workflows, making it easier to document and visualize complex data pipelines.

## Features

putior offers comprehensive annotation processing capabilities:

- Extracts structured annotations from both R and Python source files
- Supports flexible annotation formats (`#put`, `# put`, `#put|`)
- Captures arbitrary key-value properties for customizable metadata
- Returns results in a clean, tabular format ready for visualization
- Handles both single-file and directory-wide scanning

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

## Usage

### Basic Example

Add PUT annotations to your R or Python source files:

```r
# In your R script
#put name:"load_data", label:"Load Dataset", node_type:"input"
data <- read.csv("data.csv")

#put name:"process", label:"Transform Data", node_type:"process"
processed_data <- transform(data)
```

```python
# In your Python script
#put name:"train_model", label:"Train ML Model", node_type:"process"
model.fit(X_train, y_train)
```

Then use putior to extract these annotations:

```r
library(putior)

# Process a single directory
workflow_nodes <- put("./src")

# View the results
print(workflow_nodes)
```

### Custom Properties

PUT annotations support arbitrary properties for flexible metadata:

```r
#put name:"analyze", label:"Statistical Analysis", node_type:"process", node_color:"blue", node_group:"statistics", execution_time:"120"
```

## Documentation

Access the package documentation within R:

```r
?put
?parse_put_annotation
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Author

Philipp Thoss (ph.thoss@gmx.de)
ORCID: 0000-0002-4672-2792