# CLAUDE.md

This file provides guidance to AI assistants when working with code in this repository.

## Repository Overview

putior is an R package that extracts structured annotations from source code files and generates Mermaid flowchart diagrams for visualizing workflows and data pipelines. It supports R, Python, SQL, Shell, and Julia files.

**Status**: Ready for CRAN submission (all checks passing)

## R Execution in WSL

When running R commands from WSL with this project:

1. **Use the correct R version**: This project requires R 4.5.0 (as specified in renv.lock)
2. **Source .Rprofile first**: The renv environment must be activated before running commands
3. **Windows R path**: R is typically installed at `C:/Program Files/R/R-{version}/`
4. **Pandoc requirement**: Vignette building requires pandoc (see below)

### Example R Execution from WSL
```bash
# Change to project directory
cd /path/to/putior

# Run R command with renv activation (without --vanilla to allow .Rprofile to run)
"/mnt/c/Program Files/R/R-{version}/bin/R.exe" --no-save --no-restore -e "devtools::check()"

# Alternative: Using Rscript (which also sources .Rprofile by default)
"/mnt/c/Program Files/R/R-{version}/bin/Rscript.exe" -e "devtools::check()"

# To verify renv is activated, check library paths:
"/mnt/c/Program Files/R/R-{version}/bin/Rscript.exe" -e ".libPaths()"
```

### Pandoc Configuration for WSL

When running R package checks from WSL, pandoc is required for building vignettes. The `.Renviron` file in the project root sets the `RSTUDIO_PANDOC` environment variable to point to the pandoc executable included with RStudio:

```bash
# .Renviron
RSTUDIO_PANDOC="C:/Program Files/RStudio/resources/app/bin/quarto/bin/tools"
```

This configuration:
- Uses the pandoc bundled with RStudio (no separate installation needed)
- Works when running R from WSL with Windows-installed RStudio
- Is automatically loaded when R starts in the project directory
- Allows vignette building during `devtools::check()` and CRAN submission

If RStudio is installed in a different location, update the path accordingly.

## Common Development Commands

### Build and Check
```bash
# Install development dependencies
Rscript -e "devtools::install_dev_deps()"

# Build and install the package
Rscript -e "devtools::install()"

# Full package check (includes examples, tests, documentation)
# Note: Requires pandoc for vignettes (set RSTUDIO_PANDOC environment variable if needed)
Rscript -e "devtools::check()"

# Quick check without rebuilding vignettes
Rscript -e "devtools::check(build_args = '--no-build-vignettes')"
```

### CRAN Submission Workflow
```bash
# Spell check (requires spelling package)
Rscript -e "devtools::spell_check()"

# Check on win-builder (most important for CRAN)
Rscript -e "devtools::check_win_devel()"
Rscript -e "devtools::check_win_release()"

# URL check (requires urlchecker package and pandoc)
Rscript -e "urlchecker::url_check()"

# Submit to CRAN (interactive process)
Rscript -e "devtools::release()"
```

### R-hub v2 Testing
```bash
# Setup R-hub v2 (one-time, creates .github/workflows/rhub.yaml)
Rscript -e "rhub::rhub_setup()"

# Check R-hub setup
Rscript -e "rhub::rhub_doctor()"

# Run checks on multiple platforms
Rscript -e "rhub::rhub_check()"
# Recommended platforms: 1,3,5,24,29 (linux, macos, windows, nosuggests, ubuntu-release)
```

### Testing
```bash
# Run all tests
Rscript -e "devtools::test()"

# Run a specific test file
Rscript -e "testthat::test_file('tests/testthat/test-put.R')"

# Run tests with coverage
Rscript -e "covr::package_coverage()"
```

### Documentation
```bash
# Generate/update documentation from roxygen2 comments
Rscript -e "devtools::document()"

# Build vignettes (requires pandoc)
Rscript -e "devtools::build_vignettes()"

# Preview package documentation
Rscript -e "pkgdown::build_site()"
```

### Development Workflow
```bash
# Load all package functions for interactive development
Rscript -e "devtools::load_all()"

# Run examples
Rscript inst/examples/reprex.R
Rscript inst/examples/diagram-example.R
Rscript inst/examples/theme-examples.R
```

## Code Architecture

### Core Components

1. **Annotation Parsing System** (`R/putior.R`)
   - `put()` - Main entry point that scans files for PUT annotations
   - `parse_put_annotation()` - Parses individual annotation strings into key-value pairs
   - `is_valid_put_annotation()` - Validates annotation syntax
   - Uses regex patterns to extract structured data from comments
   - **Fixed**: Regex pattern now includes colon separator for `#put:` format

2. **Diagram Generation** (`R/put_diagram.R`)
   - `put_diagram()` - Generates Mermaid flowchart code from parsed data
   - `generate_connections()` - Creates edges based on matching input/output files
   - Theme system with 5 built-in themes (light, dark, auto, github, minimal)
   - Supports multiple output modes (console, file, clipboard)
   - **NEW**: Artifact visualization mode for complete data flow

3. **Data Flow Architecture**
   - Annotations define nodes with `id`, `label`, `node_type`, `input`, and `output`
   - Automatic connection inference by matching output files to input files
   - Node types map to Mermaid shapes:
     - input/start/end → stadium `([text])`
     - process → rectangle `[text]`
     - output → subroutine `[[text]]`
     - decision → diamond `{text}`
     - **NEW**: artifact → cylinder `[(text)]`

### Key Design Patterns

- **Functional approach**: Pure functions with minimal side effects
- **Validation at parse time**: Early error detection with helpful messages
- **Flexible annotation syntax**: Supports multiple comment formats (#put, # put, #put|, #put:)
- **Theme abstraction**: Color schemes isolated from diagram logic
- **Output abstraction**: Single interface for console/file/clipboard output
- **Visualization modes**: Simple (script connections) vs. Artifact (complete data flow)
- **UUID auto-generation**: When `id` is omitted, automatically generates UUID v4
- **Empty vs missing distinction**: Missing `id` → auto-generate; empty `id:""` → validation warning

### Testing Strategy

- Unit tests for all parsing functions
- Integration tests for complete workflows
- Edge case handling (empty files, invalid syntax, missing properties)
- Theme validation tests
- File I/O testing with temporary directories
- **NEW**: Artifact functionality tests (91 total tests)
- **Coverage**: Comprehensive test coverage for all major functions (280 tests total)

## Recent Major Features

### Artifact Visualization System (NEW)

**Purpose**: Addresses the limitation where terminal outputs (files not consumed by other scripts) weren't shown in diagrams.

**Problem Solved**: Previously, workflows like `Load Data → Process Data → final_results.csv` would only show `Load Data → Process Data`, missing the terminal output `final_results.csv`.

**Implementation**: 
- `show_artifacts` parameter in `put_diagram()` function
- `create_artifact_nodes()` function identifies data files (non-script files)
- Extended `generate_connections()` for file-to-script and script-to-file relationships
- Artifact styling with cylindrical shape `[(filename)]` and subtle colors across all themes

**Usage**:
```r
# Simple mode (default) - script connections only
put_diagram(workflow)

# Artifact mode - complete data flow including terminal outputs
put_diagram(workflow, show_artifacts = TRUE)

# With file labels on connections for extra clarity
put_diagram(workflow, show_artifacts = TRUE, show_files = TRUE)
```

**Key Benefits**:
- Shows terminal outputs like `final_results.csv` that aren't consumed by other scripts
- Shows initial inputs that aren't produced by other scripts
- Provides complete data lineage visualization
- Maintains backward compatibility with simple mode as default
- Works with all existing themes and styling options

**Visualization Modes**:
| Mode | Parameter | Shows | Best For |
|------|-----------|-------|----------|
| **Simple** | `show_artifacts = FALSE` (default) | Script connections only | Code architecture, dependencies |
| **Artifact** | `show_artifacts = TRUE` | Scripts + data files | Data pipelines, complete data flow |

## Annotation Naming Implementation (Completed)

### Summary of Changes

The package has been updated to use `id` instead of `name` for node identifiers, aligning with graph theory conventions and improving semantic clarity.

### Current Annotation Structure

- **No longer mandatory**: `id` - unique node identifier (auto-generated if omitted)
- **Optional fields**: `label`, `node_type`, `input`, `output`
- **Validation**: 
  - Duplicate ID detection with warnings
  - Empty `id:""` generates validation warning
  - Missing `id` triggers UUID auto-generation

### UUID Auto-Generation Implementation

When `id` field is omitted from an annotation:
1. The `uuid` package (if available) generates a UUID v4
2. If `uuid` package is not installed, `id` remains NULL
3. Empty `id:""` is treated differently - it generates a validation warning

### Output Defaulting Implementation

When `output` field is omitted from an annotation:
1. The output automatically defaults to the current file name
2. This ensures nodes can be connected in workflows even without explicit output files
3. Enables natural file-based connections (e.g., script A outputs itself, script B can use script A as input)

### Source Relationship Tracking

For workflows where scripts source other scripts, the annotation pattern is:

**Main script (sources others):**
```r
# main.R - reads/sources other scripts
#put label:"Main Workflow", input:"utils.R,analysis.R,report.R", output:"results.csv"
source("utils.R")     # Reading utils.R INTO main.R
source("analysis.R")  # Reading analysis.R INTO main.R
source("report.R")    # Reading report.R INTO main.R
```

**Sourced scripts:**
```r
# utils.R - this script is read BY main.R
#put label:"Utility Functions", node_type:"input"
# output defaults to "utils.R" (the script outputs itself)

# analysis.R - read BY main.R, depends on utils.R
#put label:"Analysis Functions", input:"utils.R"
# output defaults to "analysis.R"

# report.R - read BY main.R, depends on analysis.R
#put label:"Report Functions", input:"analysis.R"
# output defaults to "report.R"
```

**Key principles:**
- Scripts being sourced are **inputs** to the main script
- Flow direction: sourced scripts → main script
- Dependencies between sourced scripts use their file names
- This correctly represents that `source("file.R")` reads file.R into the current environment

### Implementation Details

#### 1. Core Changes
- Renamed `name` to `id` throughout the codebase
- Added duplicate ID validation in `put()` function
- Updated error messages to reference `id` instead of `name`

#### 2. Example Syntax
```r
# Standard annotation:
#put id:"load_data", label:"Load Raw Data", node_type:"input", output:"raw_data.csv"

# All supported formats work with id:
#put id:"process", label:"Process Data"           # Standard
# put id:"process", label:"Process Data"          # Space after #
#put| id:"process", label:"Process Data"          # Pipe separator
#put: id:"process", label:"Process Data"          # Colon separator
```

#### 3. Duplicate ID Detection
The `put()` function now warns about duplicate IDs:
```r
workflow <- put("./src/")
# Warning: Duplicate node IDs found: process_1, analyze_data
# Each node must have a unique ID within the workflow.
```

#### 4. Graph Theory Alignment
- `id` clearly indicates a unique identifier (not a display name)
- Follows conventions from graph theory where nodes have IDs/vertices
- Enables future enhancements like explicit edge declarations

### Future Enhancements (Not Yet Implemented)

1. **Explicit Edge Support**: `edges_to` parameter for complex workflows
2. **Node Grouping**: `group` parameter for subgraph support
3. **Auto-generated IDs**: Option to use `label` as mandatory field with auto-generated IDs

### Testing
All tests have been updated to use `id` instead of `name`. The test suite includes:
- Parsing tests for all annotation formats
- Duplicate ID detection tests
- Workflow extraction tests
- Diagram generation tests

## CRAN Submission Status

### Files for CRAN
- `NEWS.md` - Version history and changes
- `cran-comments.md` - Submission notes for CRAN team
- `inst/WORDLIST` - Spell check dictionary for technical terms
- `.Rbuildignore` - Excludes development files from package build

### Current Status
- ✅ R CMD check: 0 errors, 0 warnings, 1 note (system time)
- ✅ Win-builder: Both R-release and R-devel passing
- ✅ Spell check: Clean (no spelling errors)
- ✅ GitHub Actions: Multi-platform CI passing
- ✅ R-hub v2: Configured and tested
- ✅ Tests: 280 tests passing (includes 91 artifact functionality tests)

### CI/CD
- GitHub Actions workflow (`.github/workflows/r.yml`) tests on Windows, macOS, Ubuntu
- R-hub v2 workflow (`.github/workflows/rhub.yaml`) for comprehensive CRAN-like testing

## Important Notes

- **Dependencies**: Minimal dependencies (only base R + tools package)
- **Pandoc**: Required for building vignettes and some checks
- **Clipboard**: Optional functionality requires `clipr` package
- **Mermaid**: Trailing spaces break GitHub rendering - package handles this
- **File extensions**: Required in input/output declarations for validation
- **Backwards compatibility**: Works with existing codebases (only annotations needed)
- **Language field**: Added to DESCRIPTION for proper spell checking
- **Artifact mode**: New feature for complete data flow visualization

## Development Tips

- Use `devtools::load_all()` for interactive development
- Run `devtools::check()` frequently during development
- Update `NEWS.md` for any user-facing changes
- Use the spell check regularly to catch typos early
- Test on multiple platforms before major releases
- Follow the existing code style and patterns
- Test both simple and artifact modes when making diagram changes