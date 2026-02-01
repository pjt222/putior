# Access putior Skills for AI Assistants

Provides structured skills documentation for AI coding assistants
(Claude Code, GitHub Copilot, etc.) to help users with putior.

## Usage

``` r
putior_skills(topic = NULL, output = c("console", "raw", "clipboard"))
```

## Arguments

- topic:

  Character string specifying section. NULL for full content. Options:
  "quick-start", "syntax", "languages", "functions", "patterns",
  "examples", or NULL (all)

- output:

  Output format: "console" (default), "raw", or "clipboard"

## Value

Invisibly returns content as character vector. With output="raw",
returns as single string.

## Examples

``` r
# Show all skills
putior_skills()
#> ---
#> name: putior
#> description: Extract workflow annotations from source code and generate Mermaid diagrams
#> version: 0.2.0.9000
#> tags: [r, documentation, workflow, mermaid, visualization, multi-language, code-analysis]
#> languages: [R, Python, SQL, JavaScript, TypeScript, Go, Rust, Java, C, C++, MATLAB, Ruby, Lua, Julia, Shell]
#> repository: https://github.com/pjt222/putior
#> documentation: https://pjt222.github.io/putior/
#> ---
#> 
#> # putior Skills
#> 
#> Skills for AI coding assistants to help users document and visualize code workflows.
#> 
#> ## Direct Access (Non-R Environments)
#> 
#> Access these skills without running R:
#> 
#> | Method | URL |
#> |--------|-----|
#> | Web Page | https://pjt222.github.io/putior/articles/skills.html |
#> | Raw Markdown | https://raw.githubusercontent.com/pjt222/putior/main/inst/SKILLS.md |
#> | GitHub View | https://github.com/pjt222/putior/blob/main/inst/SKILLS.md |
#> 
#> For R users: `putior_skills(output = "raw")` returns this content as a string.
#> 
#> ## Quick Start
#> 
#> ```r
#> # 1. Extract annotations from source files
#> workflow <- put("./R/")
#> 
#> # 2. Generate Mermaid diagram
#> put_diagram(workflow)
#> 
#> # 3. Auto-detect workflow without annotations
#> workflow <- put_auto("./src/")
#> ```
#> 
#> ## Annotation Syntax
#> 
#> Add `#put` comments to source files to define workflow nodes:
#> 
#> ```r
#> #put id:"load", label:"Load Data", output:"raw_data.csv"
#> data <- read.csv("input.csv")
#> 
#> #put id:"transform", label:"Clean Data", input:"raw_data.csv", output:"clean.rds"
#> clean <- transform(data)
#> 
#> #put id:"analyze", label:"Run Analysis", input:"clean.rds", node_type:"decision"
#> results <- analyze(clean)
#> ```
#> 
#> ### Annotation Properties
#> 
#> | Property | Required | Description | Example |
#> |----------|----------|-------------|---------|
#> | `id` | Yes | Unique node identifier | `id:"load_data"` |
#> | `label` | No | Display text (defaults to id) | `label:"Load CSV"` |
#> | `input` | No | Input files/data (comma-separated) | `input:"a.csv, b.csv"` |
#> | `output` | No | Output files/data | `output:"result.rds"` |
#> | `node_type` | No | Shape: default, decision, database, io, subprocess | `node_type:"database"` |
#> 
#> ### Multiline Annotations
#> 
#> Use backslash for continuation:
#> 
#> ```r
#> #put id:"complex_step", \
#> #put   label:"Multi-step Process", \
#> #put   input:"file1.csv, file2.csv", \
#> #put   output:"combined.rds"
#> ```
#> 
#> ## Multi-Language Comment Syntax
#> 
#> putior automatically detects comment style by file extension:
#> 
#> | Prefix | Languages | Extensions |
#> |--------|-----------|------------|
#> | `#put` | R, Python, Shell, Julia, Ruby, Perl, YAML | `.R`, `.py`, `.sh`, `.jl`, `.rb`, `.pl`, `.yaml` |
#> | `--put` | SQL, Lua, Haskell | `.sql`, `.lua`, `.hs` |
#> | `//put` | JavaScript, TypeScript, C, C++, Java, Go, Rust, Swift, Kotlin, C#, PHP | `.js`, `.ts`, `.c`, `.cpp`, `.java`, `.go`, `.rs` |
#> | `%put` | MATLAB, LaTeX | `.m`, `.tex` |
#> 
#> ### Examples by Language
#> 
#> ```sql
#> -- query.sql
#> --put id:"fetch", label:"Fetch Customers", output:"customers"
#> SELECT * FROM customers;
#> ```
#> 
#> ```javascript
#> // transform.js
#> //put id:"process", label:"Transform JSON", input:"data.json", output:"output.json"
#> const result = data.map(transform);
#> ```
#> 
#> ```matlab
#> % analysis.m
#> %put id:"stats", label:"Statistical Analysis", input:"data.mat", output:"results.mat"
#> results = compute_statistics(data);
#> ```
#> 
#> ## Core Functions
#> 
#> ### `put()` - Extract Annotations
#> 
#> ```r
#> # Scan directory for annotations
#> workflow <- put("./R/")
#> 
#> # Scan specific file
#> workflow <- put("./scripts/pipeline.R")
#> 
#> # Custom file pattern
#> workflow <- put("./src/", pattern = "\\.py$")
#> 
#> # Enable debug logging
#> workflow <- put("./R/", log_level = "DEBUG")
#> ```
#> 
#> ### `put_diagram()` - Generate Diagrams
#> 
#> ```r
#> # Basic diagram
#> put_diagram(workflow)
#> 
#> # Customize appearance
#> put_diagram(workflow,
#>   direction = "LR",           # Left-to-right (default: TB top-bottom)
#>   theme = "forest",           # Theme: default, forest, dark, neutral
#>   show_artifacts = TRUE       # Show data files as nodes
#> )
#> 
#> # Interactive features
#> put_diagram(workflow,
#>   enable_clicks = TRUE,       # Make nodes clickable
#>   click_protocol = "vscode",  # vscode, rstudio, or file
#>   show_source_info = TRUE     # Show source file in nodes
#> )
#> 
#> # Output options
#> put_diagram(workflow, output = "clipboard")        # Copy to clipboard
#> put_diagram(workflow, output = "workflow.md")      # Save to file
#> mermaid_code <- put_diagram(workflow, output = "raw")  # Return as string
#> ```
#> 
#> ### `put_auto()` - Auto-Detect Workflow
#> 
#> Analyze code to detect inputs/outputs without annotations:
#> 
#> ```r
#> # Auto-detect from R files
#> workflow <- put_auto("./R/")
#> 
#> # Control what to detect
#> workflow <- put_auto("./src/",
#>   detect_inputs = TRUE,
#>   detect_outputs = TRUE,
#>   detect_dependencies = TRUE
#> )
#> 
#> # Combine with manual annotations
#> workflow <- put_merge("./src/", merge_strategy = "supplement")
#> ```
#> 
#> ### `put_generate()` - Generate Annotation Templates
#> 
#> ```r
#> # Print suggested annotations
#> put_generate("./R/")
#> 
#> # Copy to clipboard
#> put_generate("./R/", output = "clipboard")
#> 
#> # Multiline style
#> put_generate("./R/", style = "multiline")
#> ```
#> 
#> ## Auto-Detection Patterns
#> 
#> Languages with pattern-based detection (862 patterns total):
#> 
#> | Language | Patterns | Key Libraries |
#> |----------|----------|---------------|
#> | R | 124 | readr, data.table, DBI, arrow, ellmer |
#> | Python | 159 | pandas, numpy, sqlalchemy, transformers, langchain |
#> | JavaScript | 71 | Node.js fs, Express, mongoose, Prisma |
#> | TypeScript | 88 | All JS + NestJS, TypeORM |
#> | Java | 73 | NIO, JDBC, Jackson, Spring Boot |
#> | Ruby | 64 | File, CSV, Rails, ActiveRecord |
#> | Rust | 60 | std::fs, serde, sqlx, diesel |
#> | Go | 44 | os, bufio, database/sql, gorm |
#> | C++ | 44 | fstream, boost, std::filesystem |
#> | MATLAB | 44 | readtable, imread, h5read |
#> | Julia | 27 | CSV.jl, DataFrames, JLD2 |
#> | C | 24 | stdio.h, POSIX, mmap |
#> | Lua | 20 | io library, loadfile |
#> | Shell | 12 | cat, redirects, source |
#> | SQL | 8 | FROM, JOIN, COPY |
#> 
#> ### LLM Library Detection
#> 
#> Detects modern AI/ML libraries:
#> 
#> **R**: ellmer (`chat()`, `chat_openai()`, `chat_claude()`), tidyllm, httr2 API calls
#> 
#> **Python**: ollama, openai, anthropic, langchain, transformers, litellm, vllm, groq
#> 
#> ## Helper Functions
#> 
#> ```r
#> # Get comment prefix for extension
#> get_comment_prefix("sql")   # Returns "--"
#> get_comment_prefix("js")    # Returns "//"
#> 
#> # List supported extensions
#> get_supported_extensions()
#> 
#> # List supported languages
#> list_supported_languages()                    # All 30+ languages
#> list_supported_languages(detection_only = TRUE)  # 15 with auto-detection
#> 
#> # Get detection patterns
#> patterns <- get_detection_patterns("python")
#> patterns <- get_detection_patterns("r", type = "input")
#> 
#> # Available themes
#> list_themes()
#> 
#> # Interactive help
#> putior_help()
#> ```
#> 
#> ## Common Patterns
#> 
#> ### Document Existing Codebase
#> 
#> ```r
#> # 1. Auto-generate annotation suggestions
#> put_generate("./R/", output = "clipboard")
#> 
#> # 2. Paste into source files and customize
#> # 3. Extract and visualize
#> workflow <- put("./R/")
#> put_diagram(workflow)
#> ```
#> 
#> ### Quick Visualization Without Annotations
#> 
#> ```r
#> # Instant workflow diagram from code analysis
#> workflow <- put_auto("./src/")
#> put_diagram(workflow, show_artifacts = TRUE)
#> ```
#> 
#> ### Hybrid Approach
#> 
#> ```r
#> # Manual annotations for key files, auto-detect the rest
#> workflow <- put_merge("./src/", merge_strategy = "supplement")
#> put_diagram(workflow)
#> ```
#> 
#> ### Export for Documentation
#> 
#> ```r
#> # Save Mermaid diagram to markdown file
#> put_diagram(workflow, output = "docs/workflow.md")
#> 
#> # Get raw Mermaid code for embedding
#> mermaid_code <- put_diagram(workflow, output = "raw")
#> ```
#> 
#> ## Node Types
#> 
#> | Type | Shape | Use For |
#> |------|-------|---------|
#> | `default` | Rectangle | Standard processing steps |
#> | `decision` | Diamond | Conditional logic, branching |
#> | `database` | Cylinder | Database operations |
#> | `io` | Parallelogram | File I/O operations |
#> | `subprocess` | Double-bordered | Nested workflows, function calls |
#> 
#> ## Diagram Themes
#> 
#> - `default` - Standard Mermaid styling
#> - `forest` - Green color scheme
#> - `dark` - Dark mode friendly
#> - `neutral` - Minimal, grayscale
#> 
#> ## Interactive Sandbox
#> 
#> Launch browser-based annotation playground:
#> 
#> ```r
#> run_sandbox()  # Requires shiny package
#> ```
#> 
#> ## Quarto/RMarkdown Integration
#> 
#> ```r
#> # In R chunk
#> workflow <- put("./R/")
#> mermaid_code <- put_diagram(workflow, output = "raw")
#> ```
#> 
#> Then use `knitr::knit_child()` to embed as native Mermaid chunk.
#> 
#> ## Logging
#> 
#> Enable debug output for troubleshooting:
#> 
#> ```r
#> # Set globally
#> options(putior.log_level = "DEBUG")
#> set_putior_log_level("DEBUG")
#> 
#> # Per-call override
#> workflow <- put("./R/", log_level = "DEBUG")
#> ```
#> 
#> Levels: `DEBUG`, `INFO`, `WARN` (default), `ERROR`
#> 
#> ## Tips for AI Assistants
#> 
#> 1. **Start with `put_auto()`** for unfamiliar codebases to quickly understand data flow
#> 2. **Use `put_generate()`** to create annotation templates users can customize
#> 3. **Prefer `put_merge()`** when combining manual and auto-detected workflows
#> 4. **Check comment syntax** - use correct prefix for target language
#> 5. **Enable `show_artifacts = TRUE`** to visualize data file dependencies
#> 6. **Use `enable_clicks = TRUE`** for navigable documentation

# Show specific topic
putior_skills("quick-start")
#> ## Quick Start
#> 
#> ```r
#> # 1. Extract annotations from source files
#> workflow <- put("./R/")
#> 
#> # 2. Generate Mermaid diagram
#> put_diagram(workflow)
#> 
#> # 3. Auto-detect workflow without annotations
#> workflow <- put_auto("./src/")
#> ```
#> 

# Get raw markdown for AI consumption
skills_md <- putior_skills(output = "raw")
```
