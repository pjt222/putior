# Getting Started with putior

``` r
library(putior)
```

## Introduction

The `putior` package helps you document and visualize workflows by
extracting structured annotations from your R and Python source files.
This vignette shows you how to get started with PUT annotations and
workflow extraction.

**PUT** stands for **P**UT + **I**nput + **O**utput + **R**, reflecting
the package’s core purpose: tracking data inputs and outputs through
your analysis pipeline using special annotations.

## Why Use putior?

- **Automatic documentation**: Your workflow documentation stays in sync
  with your code
- **Multi-language support**: Works with R, Python, SQL, and other file
  types
- **Data lineage tracking**: See how data flows through your processing
  steps
- **Team collaboration**: Help colleagues understand complex workflows
- **Visual workflow creation**: Extract structured data ready for
  flowchart generation

## Quick Start

The fastest way to see putior in action is to run the built-in example:

``` r
# Run the complete example
source(system.file("examples", "reprex.R", package = "putior"))
```

This creates a sample multi-language workflow and demonstrates the
workflow extraction capabilities of putior.

### Live Example

Here’s a working example using putior’s own source code (the package
documents itself!):

``` r
library(putior)

# Extract workflow from putior's own R source files
workflow <- put(system.file("examples", "reprex.R", package = "putior"))

# View the extracted workflow nodes
print(workflow)
#> [1] file_name file_path file_type
#> <0 rows> (or 0-length row.names)
```

This demonstrates how putior extracts structured workflow data from
annotated source files.

## Basic Workflow

### Step 1: Add PUT Annotations to Your Code

PUT annotations are special comments that describe workflow nodes. Start
simple:

**Minimal annotation (just a label):**

    #put label:"Load Data"

That’s all you need! putior will: - Auto-generate a unique ID - Default
`node_type` to `"process"` - Default `output` to the filename

**Add more detail as needed:**

    #put label:"Load Data", node_type:"input", output:"data.csv"

**Full R script example:**

    # data_processing.R
    #put label:"Load Customer Data", node_type:"input", output:"raw_data.csv"

    # Your actual code
    data <- read.csv("customer_data.csv")
    write.csv(data, "raw_data.csv")

    #put label:"Clean and Validate", input:"raw_data.csv", output:"clean_data.csv"

    # Data cleaning code
    cleaned_data <- data %>%
      filter(!is.na(customer_id)) %>%
      mutate(purchase_date = as.Date(purchase_date))

    write.csv(cleaned_data, "clean_data.csv")

**Python script example:**

    # analysis.py
    #put id:"analyze_sales", label:"Sales Analysis", node_type:"process", input:"clean_data.csv", output:"sales_report.json"

    import pandas as pd
    import json

    # Load cleaned data
    data = pd.read_csv("clean_data.csv")

    # Perform analysis
    sales_summary = {
        "total_sales": data["amount"].sum(),
        "avg_order": data["amount"].mean(),
        "customer_count": data["customer_id"].nunique()
    }

    # Save results
    with open("sales_report.json", "w") as f:
        json.dump(sales_summary, f)

### Step 2: Extract the Workflow

Use the [`put()`](https://pjt222.github.io/putior/reference/put.md)
function to scan your files and extract workflow information:

``` r
# Scan all R and Python files in a directory
workflow <- put("./src/")

# View the extracted workflow
print(workflow)
```

Expected output:

    #>           file_name file_type          input              label            id
    #> 1 data_processing.R         r           <NA> Load Customer Data     load_data
    #> 2 data_processing.R         r   raw_data.csv Clean and Validate    clean_data
    #> 3       analysis.py        py clean_data.csv     Sales Analysis analyze_sales
    #>   node_type            output
    #> 1     input      raw_data.csv
    #> 2   process    clean_data.csv
    #> 3   process sales_report.json

### Step 3: Understand the Results

The output is a data frame where each row represents a workflow node.
The columns include:

- **file_name**: Which script contains this node
- **file_type**: Programming language (r, py, sql, etc.)
- **id**: Unique identifier for the node
- **label**: Human-readable description
- **node_type**: Type of operation (input, process, output)
- **input**: Files consumed by this step
- **output**: Files produced by this step
- **Custom properties**: Any additional metadata you defined

## PUT Annotation Syntax

### Basic Format

The general syntax for PUT annotations is:

    #put property1:"value1", property2:"value2", property3:"value3"

### Flexible Syntax Options

PUT annotations support several formats to fit different coding styles:

    #put id:"my_node", label:"My Process"           # Standard format
    # put id:"my_node", label:"My Process"          # Space after #
    #put| id:"my_node", label:"My Process"          # Pipe separator
    #put id:'my_node', label:'Single quotes'        # Single quotes
    #put id:"my_node", label:'Mixed quotes'         # Mixed quote styles

### Multi-Language Support

putior automatically uses the correct comment prefix based on file
extension:

| Comment Style | Languages                                 | Extensions                                |
|:--------------|:------------------------------------------|:------------------------------------------|
| `#put`        | R, Python, Shell, Julia, Ruby, YAML       | `.R`, `.py`, `.sh`, `.jl`, `.rb`, `.yaml` |
| `--put`       | SQL, Lua, Haskell                         | `.sql`, `.lua`, `.hs`                     |
| `//put`       | JavaScript, TypeScript, C, Java, Go, Rust | `.js`, `.ts`, `.c`, `.java`, `.go`, `.rs` |
| `%put`        | MATLAB, LaTeX                             | `.m`, `.tex`                              |

**SQL Example:**

    -- query.sql
    --put id:"load_data", label:"Load Customer Data", output:"customers"
    SELECT * FROM customers WHERE active = 1;

**JavaScript Example:**

    // process.js
    //put id:"transform", label:"Transform JSON", input:"data.json", output:"output.json"
    const transformed = data.map(item => process(item));

**MATLAB Example:**

    % analysis.m
    %put id:"compute", label:"Statistical Analysis", input:"data.mat", output:"results.mat"
    results = compute_statistics(data);

### Core Properties

While putior accepts any properties you define, these are commonly used:

| Property    | Purpose           | Example Values                     |
|-------------|-------------------|------------------------------------|
| `id`        | Unique identifier | `"load_data"`, `"process_sales"`   |
| `label`     | Human description | `"Load Customer Data"`             |
| `node_type` | Operation type    | `"input"`, `"process"`, `"output"` |
| `input`     | Input files       | `"raw_data.csv"`, `"data/*.json"`  |
| `output`    | Output files      | `"processed_data.csv"`             |

### Standard Node Types

For consistency across projects, consider using these standard node
types:

- **`input`**: Data collection, file loading, API calls
- **`process`**: Data transformation, analysis, computation
- **`output`**: Report generation, data export, visualization
- **`decision`**: Conditional logic, branching workflows

### Custom Properties

Add any properties you need for visualization or metadata:

    #put id:"train_model", label:"Train ML Model", node_type:"process", color:"green", group:"machine_learning", duration:"45min", priority:"high"

These custom properties can be used by visualization tools or workflow
management systems.

## Advanced Usage

### Processing Individual Files

You can process single files instead of entire directories:

``` r
# Process a single file
workflow <- put("./scripts/analysis.R")
```

### Recursive Directory Scanning

Include subdirectories in your scan:

``` r
# Search subdirectories recursively
workflow <- put("./project/", recursive = TRUE)
```

### Custom File Patterns

Control which files are processed:

``` r
# Only R files
workflow <- put("./src/", pattern = "\\.R$")

# R and SQL files only
workflow <- put("./src/", pattern = "\\.(R|sql)$")

# All supported file types (default)
workflow <- put("./src/", pattern = "\\.(R|r|py|sql|sh|jl)$")
```

### Including Line Numbers

For debugging annotation issues, include line numbers:

``` r
# Include line numbers for debugging
workflow <- put("./src/", include_line_numbers = TRUE)
```

### Validation Control

Control annotation validation:

``` r
# Enable validation (default) - provides helpful warnings
workflow <- put("./src/", validate = TRUE)

# Disable validation warnings
workflow <- put("./src/", validate = FALSE)
```

### Automatic ID Generation

If you omit the `id` field, putior will automatically generate a unique
UUID:

``` r
# Annotations without explicit IDs get auto-generated UUIDs
#put label:"Load Data", node_type:"input", output:"data.csv"
#put label:"Process Data", node_type:"process", input:"data.csv", output:"clean.csv"

# Extract workflow - IDs will be auto-generated
workflow <- put("./")
print(workflow$id)  # Will show UUIDs like "a1b2c3d4-e5f6-7890-abcd-ef1234567890"
```

Note: If you provide an empty `id` (e.g., `id:""`), you’ll get a
validation warning.

### Automatic Output Defaulting

If you omit the `output` field, putior automatically uses the file name
as the output:

``` r
# In process_data.R:
#put label:"Process Step", node_type:"process", input:"raw.csv"
# No output specified - will default to "process_data.R"

# In analyze_data.R:
#put label:"Analyze", node_type:"process", input:"process_data.R", output:"results.csv"
# This creates a connection from process_data.R to analyze_data.R
```

This feature ensures that scripts can be connected in workflows even
when explicit output files aren’t specified.

### Tracking Source Relationships

When you have scripts that source other scripts, use this annotation
pattern:

``` r
# In main.R (sources other scripts):
#put label:"Main Analysis", input:"load_data.R,process_data.R", output:"report.pdf"
source("load_data.R")    # Reading load_data.R into main.R
source("process_data.R") # Reading process_data.R into main.R

# In load_data.R (sourced by main.R):
#put label:"Data Loader", node_type:"input"
# output defaults to "load_data.R"

# In process_data.R (sourced by main.R, depends on load_data.R):
#put label:"Data Processor", input:"load_data.R"
# output defaults to "process_data.R"
```

This correctly shows the flow: sourced scripts are **inputs** to the
main script.

## Variable References with `.internal` Extension

putior supports tracking in-memory variables and objects using the
`.internal` extension. This is useful for documenting computational
steps within scripts while maintaining clear data flow between scripts.

### Key Concepts

**`.internal` variables:** - Represent in-memory objects during script
execution - Can only be **outputs**, never inputs between scripts - Help
document what variables are created within each script - Example:
`my_data.internal` represents a variable named `my_data`

**Persistent files:** - Enable actual data flow between scripts - Can be
both inputs and outputs - Required for connected workflows - Example:
`my_data.RData`, `results.csv`

### Correct Usage Pattern

``` r
# Script 1: Create variable and save it
#put id:"create_data", output:"dataset.internal, dataset.RData"
dataset <- data.frame(x = 1:100, y = rnorm(100))
save(dataset, file = "dataset.RData")

# Script 2: Load data and create new variables  
#put id:"analyze_data", input:"dataset.RData", output:"analysis.internal, summary.txt"
load("dataset.RData")  # Load the persistent file (NOT dataset.internal)
analysis <- summary(dataset)  # Create new in-memory variable
writeLines(capture.output(analysis), "summary.txt")
```

### What NOT to Do

``` r
# INCORRECT: Using .internal as input between scripts
#put input:"dataset.internal"  # This is wrong!

# CORRECT: Use persistent files as inputs
#put input:"dataset.RData"     # This is correct!
```

### Complete Example

Try the comprehensive variable reference example:

``` r
source(system.file("examples", "variable-reference-example.R", package = "putior"))
```

This creates a connected 4-script workflow demonstrating proper
`.internal` usage and file-based data flow.

## Real-World Example

Let’s walk through a complete data science workflow:

### 1. Data Collection (Python)

    # 01_collect_data.py
    #put id:"fetch_api_data", label:"Fetch Data from API", node_type:"input", output:"raw_api_data.json"

    import requests
    import json

    response = requests.get("https://api.example.com/sales")
    data = response.json()

    with open("raw_api_data.json", "w") as f:
        json.dump(data, f)

### 2. Data Processing (R)

    # 02_process_data.R  
    #put id:"clean_api_data", label:"Clean and Structure Data", node_type:"process", input:"raw_api_data.json", output:"processed_sales.csv"

    library(jsonlite)
    library(dplyr)

    # Load raw data
    raw_data <- fromJSON("raw_api_data.json")

    # Process and clean
    processed <- raw_data %>%
      filter(!is.na(sale_amount)) %>%
      mutate(
        sale_date = as.Date(sale_date),
        sale_amount = as.numeric(sale_amount)
      ) %>%
      arrange(sale_date)

    # Save processed data
    write.csv(processed, "processed_sales.csv", row.names = FALSE)

### 3. Analysis and Reporting (R)

    # 03_analyze_report.R
    #put id:"sales_analysis", label:"Perform Sales Analysis", node_type:"process", input:"processed_sales.csv", output:"analysis_results.rds"
    #put id:"generate_report", label:"Generate HTML Report", node_type:"output", input:"analysis_results.rds", output:"sales_report.html"

    library(dplyr)

    # Load processed data  
    sales_data <- read.csv("processed_sales.csv")

    # Perform analysis
    analysis_results <- list(
      total_sales = sum(sales_data$sale_amount),
      monthly_trends = sales_data %>% 
        group_by(month = format(sale_date, "%Y-%m")) %>%
        summarise(monthly_total = sum(sale_amount)),
      top_products = sales_data %>%
        group_by(product) %>%
        summarise(product_sales = sum(sale_amount)) %>%
        arrange(desc(product_sales)) %>%
        head(10)
    )

    # Save analysis
    saveRDS(analysis_results, "analysis_results.rds")

    # Generate report
    rmarkdown::render("report_template.Rmd", 
                      output_file = "sales_report.html")

### 4. Extract the Complete Workflow

``` r
# Extract workflow from all files
complete_workflow <- put("./sales_project/", recursive = TRUE)
print(complete_workflow)
```

This would show the complete data flow: API → JSON → CSV → Analysis →
Report

## Best Practices

### 1. Use Descriptive Names

Choose clear, descriptive names that explain what each step does:

    # Good
    #put name:"load_customer_transactions", label:"Load Customer Transaction Data"
    #put name:"calculate_monthly_revenue", label:"Calculate Monthly Revenue Totals"

    # Less descriptive
    #put name:"step1", label:"Load data"
    #put name:"process", label:"Do calculations"

### 2. Document Data Dependencies

Always specify inputs and outputs for data processing steps:

    #put name:"merge_datasets", label:"Merge Customer and Transaction Data", input:"customers.csv,transactions.csv", output:"merged_data.csv"

### 3. Use Consistent Node Types

Stick to a standard set of node types across your team:

    #put name:"load_raw_data", label:"Load Raw Sales Data", node_type:"input"
    #put name:"clean_data", label:"Clean and Validate", node_type:"process"  
    #put name:"export_results", label:"Export Final Results", node_type:"output"

### 4. Add Helpful Metadata

Include metadata that helps with workflow understanding:

    #put name:"train_model", label:"Train Random Forest Model", node_type:"process", estimated_time:"30min", requires:"tidymodels", memory_intensive:"true"

### 5. Group Related Operations

Use grouping properties to organize complex workflows:

    #put name:"feature_engineering", label:"Engineer Features", group:"preprocessing", stage:"1"
    #put name:"model_training", label:"Train Model", group:"modeling", stage:"2"
    #put name:"model_evaluation", label:"Evaluate Model", group:"modeling", stage:"3"

## Troubleshooting

### No Annotations Found

If [`put()`](https://pjt222.github.io/putior/reference/put.md) returns
an empty data frame:

1.  **Check file patterns**: Ensure your files match the pattern
    (default: R, Python, SQL, shell, Julia)
2.  **Verify annotation syntax**: Use
    [`is_valid_put_annotation()`](https://pjt222.github.io/putior/reference/is_valid_put_annotation.md)
    to test individual annotations
3.  **Check file paths**: Ensure the directory exists and contains the
    expected files

``` r
# Test annotation syntax
is_valid_put_annotation('#put name:"test", label:"Test Node"') # Should return TRUE
is_valid_put_annotation("#put invalid syntax") # Should return FALSE

# Check what files are found
list.files("./src/", pattern = "\\.(R|py)$")
```

### Validation Warnings

If you see validation warnings:

1.  **Missing name**: Add a `name` property to all annotations
2.  **Invalid node_type**: Use standard types (`input`, `process`,
    `output`)
3.  **File extensions**: Ensure file references include extensions

``` r
# Enable detailed validation output
workflow <- put("./src/", validate = TRUE, include_line_numbers = TRUE)
```

### Parsing Issues

If annotations aren’t parsed correctly:

1.  **Check quotes**: Ensure all values are properly quoted
2.  **Escape commas**: Values with commas should be in quotes
3.  **Avoid nested quotes**: Use consistent quote styles

Good example:

    #put name:"step1", description:"Process data, clean outliers", type:"process"

Problematic example:

    #put name:"step1", description:Process data, clean outliers, type:process

## Next Steps

Now that you understand the basics of putior:

1.  **Try the complete example**:
    `source(system.file("examples", "reprex.R", package = "putior"))`
2.  **Explore variable references**: See how to track variables and
    objects with
    `source(system.file("examples", "variable-reference-example.R", package = "putior"))`
3.  **Try interactive diagrams**:
    `source(system.file("examples", "interactive-diagrams-example.R", package = "putior"))`
4.  **Add annotations to your existing projects**: Start with key data
    processing scripts
5.  **Build visualization tools**: Use the extracted workflow data to
    create flowcharts
6.  **Integrate into CI/CD**: Automatically update workflow
    documentation

For more detailed information, see: -
[`?put`](https://pjt222.github.io/putior/reference/put.md) - Complete
function documentation -
[`?put_diagram`](https://pjt222.github.io/putior/reference/put_diagram.md) -
Diagram generation with interactive features -
[`?put_auto`](https://pjt222.github.io/putior/reference/put_auto.md) -
Automatic workflow detection from code analysis
