# Quick Start

### Your First Diagram in 2 Minutes

#### Step 1: Install

``` r
install.packages("putior")
```

``` r
library(putior)
```

#### Step 2: Add Annotations to Your Code

Add `# put` comments to your R scripts:

``` r
# my_analysis.R
# put label:"Load Data", output:"raw_data"
data <- read.csv("sales.csv")

# put label:"Clean Data", input:"raw_data", output:"clean_data"
clean <- data[complete.cases(data), ]

# put label:"Generate Report", input:"clean_data", output:"report.html"
rmarkdown::render("report.Rmd")
```

#### Step 3: Generate Diagram

``` r
workflow <- put("my_analysis.R")
put_diagram(workflow)
```

That’s it! You’ll see a flowchart like this:

``` mermaid
flowchart TD
    load(["Load Data"])
    clean["Clean Data"]
    report[["Generate Report"]]

    %% Connections
    load --> clean
    clean --> report

    %% Styling
    classDef inputStyle fill:#dbeafe,stroke:#2563eb,stroke-width:2px,color:#1e40af
    class load inputStyle
    classDef processStyle fill:#ede9fe,stroke:#7c3aed,stroke-width:2px,color:#5b21b6
    class clean processStyle
    classDef outputStyle fill:#dcfce7,stroke:#16a34a,stroke-width:2px,color:#15803d
    class report outputStyle
```

------------------------------------------------------------------------

### Try It Now

``` r
# Create a temporary file with annotations
temp_file <- tempfile(fileext = ".R")
writeLines(c(
  '# put label:"Extract", output:"raw.csv"',
  'data <- read.csv("source.csv")',
  '',
  '# put label:"Transform", input:"raw.csv", output:"clean.csv"',
  'clean <- transform(data)',
  '',
  '# put label:"Load", input:"clean.csv", output:"database"',
  'write_to_db(clean)'
), temp_file)

# Scan and visualize
workflow <- put(temp_file)
#> Warning: Validation issues in file272042ab49e3.R line 7:
#> File reference missing extension: database
```

``` r
cat("```mermaid\n")
```

``` mermaid
``` r
cat(put_diagram(workflow, output = "raw"))
```

flowchart TD node_43d662c5_b1b9_4e27_80b7_699cae1edc3f\[“Extract”\]
b6bbfe5f_664a_488b_9648_8ff0bea5e1da\[“Transform”\]
node_76805014_7a61_46de_88fd_449a58083036\[“Load”\]

    %% Connections
    node_43d662c5_b1b9_4e27_80b7_699cae1edc3f --> b6bbfe5f_664a_488b_9648_8ff0bea5e1da
    b6bbfe5f_664a_488b_9648_8ff0bea5e1da --> node_76805014_7a61_46de_88fd_449a58083036

``` r
cat("\n```\n")
```

## Cleanup

unlink(temp_file)

    ---
    ## Annotation Syntax at a Glance

## put label:“Step Name”, input:“file.csv”, output:“result.csv”

    | Field | Purpose | Required |
    |-------|---------|----------|
    | `label` | Human-readable name | Yes |
    | `input` | Files/data consumed | No |
    | `output` | Files/data produced | No |
    | `id` | Unique identifier | No (auto-generated) |
    | `node_type` | `input`, `process`, `output`, `decision`, `start`, `end` | No (defaults to `process`) |

    **Multiple inputs/outputs:** Use commas: `input:"a.csv, b.csv"`

    ---

    ## Multi-Language Support

    putior works with 30+ languages. Comment prefix is auto-detected:

    | Language | Annotation |
    |----------|------------|
    | R, Python, Shell | `# put label:"..."` |
    | SQL, Lua | `-- put label:"..."` |
    | JavaScript, Go, Rust | `// put label:"..."` |
    | MATLAB | `% put label:"..."` |

    ---

    ## Common Patterns

    ### Scan a Directory

    ``` r
    workflow <- put("./src/")
    put_diagram(workflow)

#### Include Subdirectories

``` r
workflow <- put("./project/", recursive = TRUE)
```

#### Auto-Detect Workflow (No Annotations!)

``` r
# Automatically detect file I/O from code
workflow <- put_auto("./src/")
put_diagram(workflow)
```

#### Choose a Theme

``` r
put_diagram(workflow, theme = "github")  # or: light, dark, minimal, viridis
```

#### Save to File

``` r
put_diagram(workflow, output = "file", file = "workflow.md")
```

------------------------------------------------------------------------

### Interactive Sandbox

Experiment without creating files:

``` r
run_sandbox()  # Opens Shiny app
```

------------------------------------------------------------------------

### Quick Reference

``` r
# Core functions
put(path)                    # Extract annotations
put_diagram(workflow)        # Generate Mermaid diagram
put_auto(path)               # Auto-detect workflow (no annotations)
put_generate(path)           # Generate annotation suggestions

# Useful options
put("./", recursive = TRUE)  # Include subdirectories
put_diagram(wf, theme = "github", direction = "LR")
put_diagram(wf, show_artifacts = FALSE)  # Hide data files
```

**Need help?** Run
[`?put`](https://pjt222.github.io/putior/reference/put.md) or
[`?put_diagram`](https://pjt222.github.io/putior/reference/put_diagram.md)
for full documentation.

------------------------------------------------------------------------

### See Also

| Guide                                                                            | Description                     |
|----------------------------------------------------------------------------------|---------------------------------|
| [Annotation Guide](https://pjt222.github.io/putior/articles/annotation-guide.md) | Complete syntax reference       |
| [Features Tour](https://pjt222.github.io/putior/articles/features-tour.md)       | Auto-detection, themes, logging |
| [API Reference](https://pjt222.github.io/putior/articles/api-reference.md)       | Function documentation          |
| [Showcase](https://pjt222.github.io/putior/articles/showcase.md)                 | Real-world examples             |
| [Quick Reference](https://pjt222.github.io/putior/articles/quick-reference.md)   | At-a-glance reference card      |
| [Troubleshooting](https://pjt222.github.io/putior/articles/troubleshooting.md)   | Common issues and solutions     |
| [AI Integration](https://pjt222.github.io/putior/articles/ai-integration.md)     | MCP/ACP integration guide       |
