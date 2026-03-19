# AI Integration Guide

### About This Vignette

This vignette documents putior’s capabilities for **AI assistants**
(like Claude, ChatGPT, or GitHub Copilot). It’s designed to be read by
language models to understand how to use putior effectively.

#### For Humans

If you’re a human reader, you probably want one of these instead:

| Guide                                                                            | Description                            |
|----------------------------------------------------------------------------------|----------------------------------------|
| [Quick Start](https://pjt222.github.io/putior/articles/quick-start.md)           | Create your first diagram in 2 minutes |
| [Annotation Guide](https://pjt222.github.io/putior/articles/annotation-guide.md) | Complete syntax reference              |
| [Quick Reference](https://pjt222.github.io/putior/articles/quick-reference.md)   | Printable cheat sheet                  |
| [API Reference](https://pjt222.github.io/putior/articles/api-reference.md)       | Full function documentation            |
| [Troubleshooting](https://pjt222.github.io/putior/articles/troubleshooting.md)   | Common issues and solutions            |

#### For AI Assistants

This content is automatically available via:

- **[`putior_guide()`](https://pjt222.github.io/putior/reference/putior_guide.md)** -
  Returns this documentation as a string
- **MCP server** - Exposed as a tool via
  [`putior_mcp_server()`](https://pjt222.github.io/putior/reference/putior_mcp_server.md)
- **ACP server** - Available via `/runs` endpoint from
  [`putior_acp_server()`](https://pjt222.github.io/putior/reference/putior_acp_server.md)

#### Programmatic Access

``` r
# Get guide documentation as a string
guide_text <- putior_guide()

# Use in prompt engineering
prompt <- paste("You have access to putior:", guide_text)

# Or access via MCP tools
tools <- putior_mcp_tools()
```

#### MCP/ACP Integration

When running as an MCP or ACP server, AI assistants can:

1.  **Discover capabilities** via `putior_guide` tool
2.  **Extract annotations** via `put` tool
3.  **Generate diagrams** via `put_diagram` tool
4.  **Auto-detect workflows** via `put_auto` tool

See the [MCP Server section in
CLAUDE.md](https://github.com/pjt222/putior/blob/main/CLAUDE.md#mcp-server-integration)
for setup instructions.

### Agent-Almanac Integration

putior’s procedural documentation lives in the
[agent-almanac](https://github.com/pjt222/agent-almanac) repository,
which provides 6 skills for the complete putior workflow:

| Skill                                                                                                                      | Purpose                                       |
|----------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------|
| [`install-putior`](https://github.com/pjt222/agent-almanac/blob/main/skills/install-putior/SKILL.md)                       | Installation and dependency setup             |
| [`analyze-codebase-workflow`](https://github.com/pjt222/agent-almanac/blob/main/skills/analyze-codebase-workflow/SKILL.md) | Auto-detect workflows in arbitrary codebases  |
| [`annotate-source-files`](https://github.com/pjt222/agent-almanac/blob/main/skills/annotate-source-files/SKILL.md)         | Add PUT annotations to source files           |
| [`generate-workflow-diagram`](https://github.com/pjt222/agent-almanac/blob/main/skills/generate-workflow-diagram/SKILL.md) | Generate themed Mermaid diagrams              |
| [`configure-putior-mcp`](https://github.com/pjt222/agent-almanac/blob/main/skills/configure-putior-mcp/SKILL.md)           | Set up MCP/ACP server for AI assistants       |
| [`setup-putior-ci`](https://github.com/pjt222/agent-almanac/blob/main/skills/setup-putior-ci/SKILL.md)                     | GitHub Actions CI/CD for diagram auto-refresh |

------------------------------------------------------------------------

### Guide Documentation

The content below is the same as returned by
[`putior_guide()`](https://pjt222.github.io/putior/reference/putior_guide.md):

## putior Quick Reference

> For step-by-step procedures, see the
> [agent-almanac](https://github.com/pjt222/agent-almanac) putior
> skills:
> [install-putior](https://github.com/pjt222/agent-almanac/blob/main/skills/install-putior/SKILL.md),
> [analyze-codebase-workflow](https://github.com/pjt222/agent-almanac/blob/main/skills/analyze-codebase-workflow/SKILL.md),
> [annotate-source-files](https://github.com/pjt222/agent-almanac/blob/main/skills/annotate-source-files/SKILL.md),
> [generate-workflow-diagram](https://github.com/pjt222/agent-almanac/blob/main/skills/generate-workflow-diagram/SKILL.md),
> [configure-putior-mcp](https://github.com/pjt222/agent-almanac/blob/main/skills/configure-putior-mcp/SKILL.md),
> [setup-putior-ci](https://github.com/pjt222/agent-almanac/blob/main/skills/setup-putior-ci/SKILL.md)

### Direct Access (Non-R Environments)

Access this guide without running R:

| Method       | URL                                                                  |
|--------------|----------------------------------------------------------------------|
| Web Page     | <https://pjt222.github.io/putior/articles/ai-integration.html>       |
| Raw Markdown | <https://raw.githubusercontent.com/pjt222/putior/main/inst/GUIDE.md> |
| GitHub View  | <https://github.com/pjt222/putior/blob/main/inst/GUIDE.md>           |

For R users: `putior_guide(output = "raw")` returns this content as a
string.

### Quick Start

``` r
# 1. Extract annotations from source files
workflow <- put("./R/")

# 2. Generate Mermaid diagram
put_diagram(workflow)

# 3. Auto-detect workflow without annotations
workflow <- put_auto("./src/")
```

### Annotation Syntax

Add `# put` comments to source files to define workflow nodes:

``` r
# put id:"load", label:"Load Data", output:"raw_data.csv"
data <- read.csv("input.csv")

# put id:"transform", label:"Clean Data", input:"raw_data.csv", output:"clean.rds"
clean <- transform(data)

# put id:"analyze", label:"Run Analysis", input:"clean.rds", node_type:"decision"
results <- analyze(clean)
```

#### Annotation Properties

| Property    | Required | Description                                                   | Example                |
|-------------|----------|---------------------------------------------------------------|------------------------|
| `id`        | Yes      | Unique node identifier                                        | `id:"load_data"`       |
| `label`     | No       | Display text (defaults to id)                                 | `label:"Load CSV"`     |
| `input`     | No       | Input files/data (comma-separated)                            | `input:"a.csv, b.csv"` |
| `output`    | No       | Output files/data                                             | `output:"result.rds"`  |
| `node_type` | No       | Shape: input, process (default), output, decision, start, end | `node_type:"decision"` |

#### Multiline Annotations

Use backslash for continuation:

``` r
# put id:"complex_step", \
#     label:"Multi-step Process", \
#     input:"file1.csv, file2.csv", \
#     output:"combined.rds"
```

#### Block Comment Annotations

Languages using `//` comments also support PUT annotations inside
`/* */` and `/** */` blocks:

``` javascript
/**
 * put id:"handler", label:"Request Handler", \
 *     input:"request.json", output:"response.json"
 */
function handleRequest(req, res) { ... }
```

Use `* put` as the line prefix inside block comment bodies.

### Multi-Language Comment Syntax

putior automatically detects comment style by file extension (18
languages with auto-detection, 30+ total):

| Prefix   | Languages                                                                    | Extensions                                                                 |
|----------|------------------------------------------------------------------------------|----------------------------------------------------------------------------|
| `# put`  | R, Python, Shell, Julia, Ruby, Perl, YAML, Dockerfile, Makefile              | `.R`, `.py`, `.sh`, `.jl`, `.rb`, `.pl`, `.yaml`, `Dockerfile`, `Makefile` |
| `-- put` | SQL, Lua, Haskell                                                            | `.sql`, `.lua`, `.hs`                                                      |
| `// put` | JavaScript, TypeScript, C, C++, Java, Go, Rust, Swift, Kotlin, C#, PHP, WGSL | `.js`, `.ts`, `.c`, `.cpp`, `.java`, `.go`, `.rs`, `.wgsl`                 |
| `% put`  | MATLAB, LaTeX                                                                | `.m`, `.tex`                                                               |

#### Examples by Language

``` sql
-- query.sql
-- put id:"fetch", label:"Fetch Customers", output:"customers"
SELECT * FROM customers;
```

``` javascript
// transform.js
// put id:"process", label:"Transform JSON", input:"data.json", output:"output.json"
const result = data.map(transform);
```

``` matlab
% analysis.m
% put id:"stats", label:"Statistical Analysis", input:"data.mat", output:"results.mat"
results = compute_statistics(data);
```

### Core Functions

#### `put()` - Extract Annotations

``` r
# Scan directory for annotations
workflow <- put("./R/")

# Scan specific file
workflow <- put("./scripts/pipeline.R")

# Custom file pattern
workflow <- put("./src/", pattern = "\\.py$")

# Enable debug logging
workflow <- put("./R/", log_level = "DEBUG")

# Exclude test files
workflow <- put("./R/", exclude = "test")
```

#### `put_diagram()` - Generate Diagrams

``` r
# Basic diagram
put_diagram(workflow)

# Customize appearance
put_diagram(workflow,
  direction = "LR",           # Left-to-right (default: TB top-bottom)
  theme = "github",           # Theme: github, light, dark, auto, minimal
  show_artifacts = TRUE       # Show data files as nodes
)

# Colorblind-safe themes (viridis family)
put_diagram(workflow, theme = "viridis")  # Purple-blue-green-yellow
put_diagram(workflow, theme = "magma")    # Warm: purple-red-yellow
put_diagram(workflow, theme = "plasma")   # Vibrant: purple-pink-yellow
put_diagram(workflow, theme = "cividis")  # Blue-yellow (max accessibility)

# Interactive features
put_diagram(workflow,
  enable_clicks = TRUE,       # Make nodes clickable
  click_protocol = "vscode",  # vscode, rstudio, or file
  show_source_info = TRUE     # Show source file in nodes
)

# Output options
put_diagram(workflow, output = "clipboard")        # Copy to clipboard
put_diagram(workflow, output = "workflow.md")      # Save to file
mermaid_code <- put_diagram(workflow, output = "raw")  # Return as string
```

#### `put_auto()` - Auto-Detect Workflow

Analyze code to detect inputs/outputs without annotations:

``` r
# Auto-detect from R files
workflow <- put_auto("./R/")

# Control what to detect
workflow <- put_auto("./src/",
  detect_inputs = TRUE,
  detect_outputs = TRUE,
  detect_dependencies = TRUE
)

# Combine with manual annotations
workflow <- put_merge("./src/", merge_strategy = "supplement")

# Exclude vendor/test directories
workflow <- put_auto("./src/", exclude = c("vendor", "test"))
```

#### `put_generate()` - Generate Annotation Templates

``` r
# Print suggested annotations
put_generate("./R/")

# Copy to clipboard
put_generate("./R/", output = "clipboard")

# Multiline style
put_generate("./R/", style = "multiline")
```

### Auto-Detection Patterns

Languages with pattern-based detection (902 patterns total):

| Language   | Patterns | Key Libraries                                      |
|------------|----------|----------------------------------------------------|
| R          | 124      | readr, data.table, DBI, arrow, ellmer              |
| Python     | 159      | pandas, numpy, sqlalchemy, transformers, langchain |
| JavaScript | 71       | Node.js fs, Express, mongoose, Prisma              |
| TypeScript | 88       | All JS + NestJS, TypeORM                           |
| Java       | 73       | NIO, JDBC, Jackson, Spring Boot                    |
| Ruby       | 64       | File, CSV, Rails, ActiveRecord                     |
| Rust       | 60       | std::fs, serde, sqlx, diesel                       |
| Go         | 44       | os, bufio, database/sql, gorm                      |
| C++        | 44       | fstream, boost, std::filesystem                    |
| MATLAB     | 44       | readtable, imread, h5read                          |
| Julia      | 27       | CSV.jl, DataFrames, JLD2                           |
| C          | 24       | stdio.h, POSIX, mmap                               |
| Lua        | 20       | io library, loadfile                               |
| WGSL       | 17       | GPU bindings, textures, samplers, naga-oil         |
| Dockerfile | 13       | FROM, COPY, ADD, EXPOSE, VOLUME, CMD, RUN          |
| Shell      | 12       | cat, redirects, source                             |
| Makefile   | 10       | include, wildcard, target rules, install           |
| SQL        | 8        | FROM, JOIN, COPY                                   |

#### LLM Library Detection

Detects modern AI/ML libraries:

**R**: ellmer (`chat()`, `chat_openai()`, `chat_claude()`), tidyllm,
httr2 API calls

**Python**: ollama, openai, anthropic, langchain, transformers, litellm,
vllm, groq

### Helper Functions

``` r
# Get comment prefix for extension
get_comment_prefix("sql")   # Returns "--"
get_comment_prefix("js")    # Returns "//"

# List supported extensions
get_supported_extensions()

# List supported languages
list_supported_languages()                    # All 30+ languages
list_supported_languages(detection_only = TRUE)  # 18 with auto-detection

# Get detection patterns
patterns <- get_detection_patterns("python")
patterns <- get_detection_patterns("r", type = "input")

# Available themes
get_diagram_themes()

# Interactive help
putior_help()
```

### Common Patterns

#### Document Existing Codebase

``` r
# 1. Auto-generate annotation suggestions
put_generate("./R/", output = "clipboard")

# 2. Paste into source files and customize
# 3. Extract and visualize
workflow <- put("./R/")
put_diagram(workflow)
```

#### Quick Visualization Without Annotations

``` r
# Instant workflow diagram from code analysis
workflow <- put_auto("./src/")
put_diagram(workflow, show_artifacts = TRUE)
```

#### Hybrid Approach

``` r
# Manual annotations for key files, auto-detect the rest
workflow <- put_merge("./src/", merge_strategy = "supplement")
put_diagram(workflow)
```

#### Export for Documentation

``` r
# Save Mermaid diagram to markdown file
put_diagram(workflow, output = "docs/workflow.md")

# Get raw Mermaid code for embedding
mermaid_code <- put_diagram(workflow, output = "raw")
```

### Node Types

| Type       | Mermaid Shape               | Use For                                                |
|------------|-----------------------------|--------------------------------------------------------|
| `input`    | Stadium `([...])`           | Data sources, file loading, API inputs                 |
| `process`  | Rectangle `[...]` (default) | Data processing, transformations                       |
| `output`   | Subroutine `[[...]]`        | Report generation, exports, final outputs              |
| `decision` | Diamond `{...}`             | Conditional logic, branching workflows                 |
| `start`    | Stadium `([...])`           | Workflow entry point (special boundary styling)        |
| `end`      | Stadium `([...])`           | Workflow exit point (special boundary styling)         |
| `artifact` | Cylinder `[(...)]`          | Data files (auto-created with `show_artifacts = TRUE`) |

> **Note**: `artifact` nodes are automatically created by
> [`put_diagram()`](https://pjt222.github.io/putior/reference/put_diagram.md)
> when `show_artifacts = TRUE`. They are not set manually via
> `node_type`.

### Diagram Themes

| Theme     | Use Case                                   |
|-----------|--------------------------------------------|
| `light`   | Bright colors (default)                    |
| `dark`    | Dark mode environments                     |
| `auto`    | GitHub-adaptive with solid colors          |
| `minimal` | Print-friendly, grayscale                  |
| `github`  | Optimized for README files                 |
| `viridis` | Colorblind-safe (purple-blue-green-yellow) |
| `magma`   | Colorblind-safe (purple-red-yellow)        |
| `plasma`  | Colorblind-safe (purple-pink-yellow)       |
| `cividis` | Maximum accessibility (blue-yellow)        |

### Interactive Sandbox

Launch browser-based annotation playground:

``` r
run_sandbox()  # Requires shiny package
```

### Quarto/RMarkdown Integration

``` r
# In R chunk
workflow <- put("./R/")
mermaid_code <- put_diagram(workflow, output = "raw")
```

Then use
[`knitr::knit_child()`](https://rdrr.io/pkg/knitr/man/knit_child.html)
to embed as native Mermaid chunk.

### Logging

Enable debug output for troubleshooting:

``` r
# Set globally
options(putior.log_level = "DEBUG")
set_putior_log_level("DEBUG")

# Per-call override
workflow <- put("./R/", log_level = "DEBUG")
```

Levels: `DEBUG`, `INFO`, `WARN` (default), `ERROR`

### Tips for AI Assistants

1.  **Start with
    [`put_auto()`](https://pjt222.github.io/putior/reference/put_auto.md)**
    for unfamiliar codebases to quickly understand data flow
2.  **Use
    [`put_generate()`](https://pjt222.github.io/putior/reference/put_generate.md)**
    to create annotation templates users can customize
3.  **Prefer
    [`put_merge()`](https://pjt222.github.io/putior/reference/put_merge.md)**
    when combining manual and auto-detected workflows
4.  **Check comment syntax** - use correct prefix for target language
5.  **Enable `show_artifacts = TRUE`** to visualize data file
    dependencies
6.  **Use `enable_clicks = TRUE`** for navigable documentation

------------------------------------------------------------------------

### See Also

| Guide                                                                            | Description                     |
|----------------------------------------------------------------------------------|---------------------------------|
| [Quick Start](https://pjt222.github.io/putior/articles/quick-start.md)           | First diagram in 2 minutes      |
| [Annotation Guide](https://pjt222.github.io/putior/articles/annotation-guide.md) | Complete syntax reference       |
| [Features Tour](https://pjt222.github.io/putior/articles/features-tour.md)       | Auto-detection, themes, logging |
| [API Reference](https://pjt222.github.io/putior/articles/api-reference.md)       | Function documentation          |
| [Showcase](https://pjt222.github.io/putior/articles/showcase.md)                 | Real-world examples             |
| [Quick Reference](https://pjt222.github.io/putior/articles/quick-reference.md)   | At-a-glance reference card      |
| [Troubleshooting](https://pjt222.github.io/putior/articles/troubleshooting.md)   | Common issues and solutions     |
