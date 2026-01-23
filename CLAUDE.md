# CLAUDE.md

This file provides guidance to AI assistants when working with code in this repository.

## Repository Overview

putior is an R package that extracts structured annotations from source code files and generates Mermaid flowchart diagrams for visualizing workflows and data pipelines. It supports R, Python, SQL, Shell, and Julia files.

**Status**: Production-ready, passing all checks, excellent documentation

## Development Environment Setup

### Critical Files for Development
- `.Renviron`: Contains Pandoc path for vignette building: `RSTUDIO_PANDOC="C:/Program Files/RStudio/resources/app/bin/quarto/bin/tools"`
- `.Rprofile`: Contains renv activation and conditional mcptools MCP session loading
- **NEVER delete these files** - they are essential for development workflow

### Key Commands
- `devtools::check()` - Full package check (requires Pandoc configured)
- `R CMD check putior_X.X.X.tar.gz` - Check built package tarball  
- `devtools::spell_check()` - Spell checking (uses inst/WORDLIST)

## Package Structure and Assets

### Hex Sticker Organization
- `inst/hex-sticker/handcrafted/` - Original Draw.io designs (primary display assets)
- `inst/hex-sticker/generated/` - R-generated stickers (development/comparison)
- Main package logos: `man/figures/logo.png|svg` (uses handcrafted versions)
- Favicon files: `pkgdown/favicon/` (all use handcrafted design)

### Self-Documentation Excellence
- Package uses its own PUT annotation system to document internal workflow
- `put('./R/')` extracts putior's own workflow (10 nodes)
- Demonstrates "eating your own dog food" principle
- Self-generated diagram shows: file scanning → annotation processing → validation → parsing → conversion → diagram generation

## File Management Best Practices

### Cleanup Guidelines
**Safe to remove (temporary/generated files):**
- R CMD check directories (`*.Rcheck/`)
- Build artifacts (`*.tar.gz`, `Meta/`, `doc/`)
- Generated sites (`docs/`)
- Cache files (`*.rds` in root)
- RStudio cache (`.Rproj.user/`)

**NEVER remove (critical development files):**
- `.Renviron` - Contains essential environment variables
- `.Rprofile` - Contains development session configuration
- User session data (`.RData`, `.Rhistory`) without explicit permission

### Ignore File Strategy
- `.gitignore`: Excludes user-specific files but preserves package assets
- `.Rbuildignore`: Excludes development files from package builds
- Important: Use specific patterns, avoid overly broad exclusions like `*.png`

## Quality Assurance

### R CMD Check Status
- **Local**: 0 errors, 0 warnings, 1 note (timing verification)
- **Win-builder R-devel**: ✅ 1 NOTE (new submission only) 
- **Win-builder R-release**: ✅ 1 NOTE (new submission only)
- **R-hub**: ✅ 4/5 platforms PASS (linux, macos, windows, ubuntu-release; nosuggests expected fail)
- All vignettes build successfully with Pandoc
- All tests pass (527+ tests including multiline annotation, auto-detection, and logging support)
- Comprehensive multiline PUT annotation support implemented

### Documentation Quality
- Vignette rating: **9.2/10** - Exceptional quality
- Comprehensive getting-started guide with real-world examples
- Complete self-documentation workflow
- README with auto-generated examples capability

### CI/CD Considerations
- GitHub Actions may fail if development dependencies (like `mcptools`) aren't available
- Solution: Use conditional loading with `requireNamespace()` in `.Rprofile`
- Spell check passes cleanly with comprehensive WORDLIST

## Development Dependencies vs Package Dependencies

### Package Dependencies (in DESCRIPTION & renv.lock)
- Only packages required for putior to function
- Listed in Imports/Suggests in DESCRIPTION  
- Included in renv.lock for reproducible installation
- All dependencies are from CRAN (no GitHub packages)

### Development-Only Tools (NOT in renv.lock)
- **mcptools**: MCP server for AI-assisted development
- **btw**: Dependency of mcptools
- Install separately when needed: `remotes::install_github("posit-dev/mcptools")`
- Loaded conditionally in .Rprofile if available
- Excluded from renv.lock to avoid GitHub credential warnings for users
- Configure renv to ignore: `renv::settings$ignored.packages(c("mcptools", "btw"))`

## Recent Major Accomplishments

1. **Multiline annotation support** - Implemented backslash continuation syntax
2. **Hex sticker organization** - Clean separation of handcrafted vs generated assets
3. **Development environment restoration** - Proper `.Renviron`/`.Rprofile` setup
4. **File structure cleanup** - Removed 4.2MB of temporary files while preserving essentials
5. **CI/CD fixes** - Resolved GitHub Actions failures with conditional package loading
6. **Documentation excellence** - High-quality vignettes and self-documentation
7. **Spelling compliance** - Complete WORDLIST for technical terms and proper names
8. **Clean renv.lock** - Removed development-only GitHub dependencies to eliminate credential warnings
9. **Variable reference feature** - Comprehensive example demonstrating `.internal` extension usage
10. **Metadata Display (Issue #3)** - Show source file info in diagram nodes with `show_source_info` parameter
11. **Clickable Hyperlinks (Issue #4)** - Make nodes clickable with `enable_clicks` and `click_protocol` parameters
12. **Auto-Annotation Feature (Issue #5)** - Automatic workflow detection from code analysis (roxygen2-style)
13. **Structured Logging** - Optional logger package integration for debugging annotation parsing and diagram generation

## Auto-Annotation Feature (GitHub Issue #5)

### Overview
Automatic detection of workflow elements from code analysis, similar to how roxygen2 auto-generates documentation skeletons. Two primary modes:

1. **Direct detection**: `put_auto()` analyzes code and produces workflow data without requiring annotations
2. **Comment generation**: `put_generate()` creates `#put` annotation text for persistent documentation

### Core Functions

#### `put_auto()` - Auto-detect workflow from code
```r
# Analyze code to detect inputs/outputs automatically
workflow <- put_auto("./src/")
put_diagram(workflow)

# Control what to detect
workflow <- put_auto("./src/",
                     detect_inputs = TRUE,
                     detect_outputs = TRUE,
                     detect_dependencies = TRUE)
```

#### `put_generate()` - Generate annotation comments (roxygen2-style)
```r
# Print suggested annotations to console
put_generate("./src/")

# Copy to clipboard for pasting
put_generate("./src/", output = "clipboard")

# Single-line or multiline style
put_generate("./src/", style = "multiline")
put_generate("./src/", style = "single")
```

#### `put_merge()` - Combine manual + auto annotations
```r
# Manual annotations override auto-detected
workflow <- put_merge("./src/", merge_strategy = "manual_priority")

# Auto fills in missing input/output fields
workflow <- put_merge("./src/", merge_strategy = "supplement")

# Combine all detected I/O from both sources
workflow <- put_merge("./src/", merge_strategy = "union")
```

#### `get_detection_patterns()` - View/customize patterns
```r
# Get all R patterns
patterns <- get_detection_patterns("r")

# Get only input patterns for Python
input_patterns <- get_detection_patterns("python", type = "input")
```

### Supported Detection Patterns

**R Language:**
- Inputs: `read.csv`, `read_csv`, `readRDS`, `load`, `fread`, `read_excel`, `fromJSON`, `read_parquet`, etc.
- Outputs: `write.csv`, `saveRDS`, `ggsave`, `pdf`, `png`, `write_parquet`, etc.
- Dependencies: `source()`, `sys.source()`

**Python:**
- Inputs: `pd.read_csv`, `pd.read_excel`, `json.load`, `pickle.load`, `np.load`, etc.
- Outputs: `.to_csv`, `.to_excel`, `json.dump`, `plt.savefig`, etc.

**Also supported:** SQL, Shell, Julia

### Workflow Integration
```
Source Files ──┬──> put()      ──> Manual Annotations ─┬─> put_merge() ──> put_diagram()
               │                                       │
               └──> put_auto() ──> Auto Annotations  ──┘
```

### Use Cases
1. **Quick Visualization**: `put_auto()` for instant workflow diagrams without any annotations
2. **Skeleton Generation**: `put_generate()` to create annotation templates for new files
3. **Hybrid Workflow**: `put_merge()` for manual control over key files with auto-fill for rest
4. **Project Onboarding**: Instantly understand data flow in unfamiliar codebases

### Reference
- **Example**: `inst/examples/auto-annotation-example.R`
- **Tests**: `tests/testthat/test-put_auto.R`, `tests/testthat/test-put_generate.R`

## Logging System

### Overview
putior includes optional structured logging via the `logger` package for debugging annotation parsing, workflow detection, and diagram generation.

### Key Characteristics
- **Optional dependency**: `logger` in Suggests, not Imports
- **Silent degradation**: Package works without logger installed
- **No user-facing errors** if logger is missing

### Log Levels
| Level | Purpose |
|-------|---------|
| DEBUG | Fine-grained operations (file-by-file, pattern matching) |
| INFO | Progress milestones (scan started, nodes found, diagram complete) |
| WARN | Issues that don't stop execution (validation issues) - **default** |
| ERROR | Fatal issues (via existing `stop()` calls) |

### Configuration

**Global option:**
```r
# Set for entire session
options(putior.log_level = "DEBUG")

# Or use the helper function
set_putior_log_level("DEBUG")
```

**Per-call override:**
```r
# Override for a single call
workflow <- put("./R/", log_level = "DEBUG")
put_diagram(workflow, log_level = "INFO")
```

### Key Files
- `R/logging.R` - Logging infrastructure
- `R/zzz.R` - Package initialization
- `tests/testthat/test-logging.R` - Logging tests

## Variable Reference Implementation (GitHub Issue #2)

### Key Concepts for `.internal` Extension
- **Purpose**: Track in-memory variables and objects during script execution
- **Usage**: `.internal` variables are **outputs only**, never inputs between scripts
- **Data Flow**: Use persistent files (RData, CSV, etc.) for inter-script communication
- **Example**: `output:'my_variable.internal, my_data.RData'`

### Critical Rules
1. **`.internal` variables exist only during script execution** → Cannot be inputs to other scripts
2. **Persistent files enable inter-script data flow** → Use saved files as inputs/outputs between scripts  
3. **Connected workflows require file-based dependencies** → Each script's file outputs become inputs to subsequent scripts
4. **Document computational steps** → Use `.internal` to show what variables are created within each script

### Example Implementation
```r
# Script 1: Creates variable and saves it
#put output:'data.internal, data.RData'
data <- process_something()
save(data, file = 'data.RData')

# Script 2: Uses saved file, creates new variable  
#put input:'data.RData', output:'results.internal, results.csv'
load('data.RData')  # NOT 'data.internal'
results <- analyze(data)
write.csv(results, 'results.csv')
```

### Reference
- **Example**: `inst/examples/variable-reference-example.R`
- **GitHub Issues**: #2 (original discussion), #3 (metadata), #4 (hyperlinks)

## Interactive Diagram Features (GitHub Issues #3 & #4)

### Metadata Display (show_source_info)
Displays source file information in diagram nodes to help users identify where each workflow step is defined.

**Parameters:**
- `show_source_info = TRUE/FALSE` (default: FALSE) - Enable/disable source info display
- `source_info_style = "inline"/"subgraph"` (default: "inline") - How to display the info

**Usage:**
```r
# Inline style - shows file name below node label
put_diagram(workflow, show_source_info = TRUE)

# Subgraph style - groups nodes by source file
put_diagram(workflow, show_source_info = TRUE, source_info_style = "subgraph")
```

### Clickable Hyperlinks (enable_clicks)
Makes diagram nodes clickable to open source files directly in your preferred editor.

**Parameters:**
- `enable_clicks = TRUE/FALSE` (default: FALSE) - Enable/disable clickable nodes
- `click_protocol = "vscode"/"file"/"rstudio"` (default: "vscode") - URL protocol

**Supported Protocols:**
- `"vscode"` - VS Code (vscode://file/path:line)
- `"file"` - Standard file:// protocol
- `"rstudio"` - RStudio (rstudio://open-file?path=)

**Usage:**
```r
# Enable VS Code clicks
put_diagram(workflow, enable_clicks = TRUE)

# Use RStudio protocol
put_diagram(workflow, enable_clicks = TRUE, click_protocol = "rstudio")

# Combine with source info
put_diagram(workflow, show_source_info = TRUE, enable_clicks = TRUE)
```

**Notes:**
- Line numbers are included when available from annotations
- Artifact nodes (data files) are excluded from click directives
- Both features are backward compatible (off by default)

### Reference
- **Example**: `inst/examples/interactive-diagrams-example.R`

## Quarto Integration

### Overview
putior diagrams can be embedded in Quarto (`.qmd`) documents for reproducible reports and dashboards using native Mermaid chunk support.

### Quarto Availability
Quarto is bundled with RStudio. To render `.qmd` files:
- **RStudio**: Use the "Render" button or `quarto::quarto_render()`
- **Command line (Windows/WSL)**: Use Quarto CLI from RStudio's bundled installation:
  ```bash
  # From WSL
  "/mnt/c/Program Files/RStudio/resources/app/bin/quarto/bin/quarto.exe" render file.qmd
  ```

### Key Technique: `knitr::knit_child()`

**Challenge**: Quarto's native `{mermaid}` chunks are static and cannot directly use dynamically generated R content.

**Solution**: Use `knitr::knit_child()` to dynamically generate a native `{mermaid}` chunk from R code:

1. **Visible chunk** (with code folding): Generates mermaid code and stores in variable
2. **Hidden chunk** (`output: asis`, `echo: false`): Uses `knit_child()` to process a dynamically created mermaid chunk

This approach:
- Uses Quarto's native Mermaid support (no CDN required)
- Maintains code folding for the R code
- Produces proper Mermaid diagrams with Quarto's built-in styling

### Usage Pattern
```r
# Chunk 1: Generate code (visible, foldable)
workflow <- put("./R/")
mermaid_code <- put_diagram(workflow, output = "raw")
```

```r
# Chunk 2: Output as native mermaid chunk (hidden)
#| output: asis
#| echo: false
mermaid_chunk <- paste0("```{mermaid}\n", mermaid_code, "\n```")
cat(knitr::knit_child(text = mermaid_chunk, quiet = TRUE))
```

### Reference
- **Example**: `inst/examples/quarto-example.qmd`

## GitHub Pages Deployment

### Current Configuration
- **Deployment Method**: Branch-based deployment from `gh-pages` branch
- **Workflow**: `.github/workflows/pkgdown-gh-pages.yaml` 
- **Important**: Development mode is disabled in `_pkgdown.yml` to ensure proper root-level deployment

### Key Settings
- `_pkgdown.yml`: Development mode must be disabled/commented out:
  ```yaml
  # development:
  #   mode: auto
  ```
- GitHub Pages Settings: Deploy from `gh-pages` branch (NOT GitHub Actions)
- Site URL: https://pjt222.github.io/putior/

### Deployment Workflow
1. Changes pushed to main branch trigger `pkgdown-gh-pages` workflow
2. Workflow builds pkgdown site with `pkgdown::build_site_github_pages()`
3. JamesIves/github-pages-deploy-action deploys `docs/` folder to `gh-pages` branch
4. GitHub Pages serves the site from `gh-pages` branch root

### Troubleshooting
- **404 Error**: Check if development mode is enabled in `_pkgdown.yml` (causes site to build in `dev/` subdirectory)
- **Deployment Issues**: Ensure GitHub Pages is set to deploy from `gh-pages` branch, not GitHub Actions
- **Build Failures**: Check workflow logs for pkgdown build errors

## Package Readiness
✅ **Production ready** - All checks passing  
✅ **CRAN submission ready** - Comprehensive documentation and testing  
✅ **Self-documenting** - Demonstrates own capabilities effectively  
✅ **Clean codebase** - Well-organized file structure and ignore patterns
✅ **GitHub Pages deployed** - Documentation site live at https://pjt222.github.io/putior/

## Development Best Practices References
@../development-guides/r-package-development-best-practices.md
@../development-guides/wsl-rstudio-claude-integration.md
@../development-guides/general-development-setup.md
@../development-guides/quick-reference.md
@../development-guides/pkgdown-github-pages-deployment.md