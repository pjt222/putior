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

### Simplified R Command Access (Optional)

For convenience, you can create wrapper scripts to avoid typing the full Windows path:

```bash
# Create wrapper script for easier access
mkdir -p ~/bin
cat > ~/bin/Rscript << 'EOF'
#!/bin/bash
exec "/mnt/c/Program Files/R/R-{version}/bin/Rscript.exe" "$@"
EOF
chmod +x ~/bin/Rscript

# Add to PATH in ~/.bashrc
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.bashrc

# Usage (after restarting terminal or sourcing ~/.bashrc)
Rscript -e "devtools::check()"
```

**Benefits:**
- Shorter commands for development workflow
- Consistent across different R versions
- Maintains full compatibility with Windows R installation

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
   - **Artifact Visualization**: `show_artifacts=TRUE` creates nodes for all data files, providing complete data flow view
   - **Workflow Boundaries**: `show_workflow_boundaries=TRUE` applies special styling to start/end nodes with icons and colors

3. **Data Flow Architecture**
   - Annotations define nodes with `id`, `label`, `node_type`, `input`, and `output`
   - Automatic connection inference by matching output files to input files
   - **Data-centric node types** for processing: input (stadium), process (rectangle), output (subroutine), decision (diamond)
   - **Workflow control nodes**: start/end with special boundary styling when `show_workflow_boundaries=TRUE`
   - **Artifact nodes**: cylinder shape `[(text)]` for data files in artifact mode
   - **Dual visualization modes**: Simple (script-to-script) vs Artifact (complete data flow)
   - **Connection preservation**: Artifact mode maintains both script-to-script AND script-to-artifact connections

### Key Design Patterns

- **Functional approach**: Pure functions with minimal side effects
- **Validation at parse time**: Early error detection with helpful messages
- **Flexible annotation syntax**: Supports multiple comment formats (#put, # put, #put|, #put:)
- **Theme abstraction**: Color schemes isolated from diagram logic
- **Output abstraction**: Single interface for console/file/clipboard output
- **Conditional styling**: Workflow boundaries and artifact styling applied based on parameters
- **Data-centric design**: Clear separation between data processing and workflow control elements
- **UUID auto-generation**: When `id` is omitted, automatically generates UUID v4
- **Empty vs missing distinction**: Missing `id` → auto-generate; empty `id:""` → validation warning

### Testing Strategy

- Unit tests for all parsing functions
- Integration tests for complete workflows
- Edge case handling (empty files, invalid syntax, missing properties)
- Theme validation tests
- File I/O testing with temporary directories
- **Artifact visualization tests**: Complete test coverage for show_artifacts functionality
- **Workflow boundary tests**: Comprehensive testing of show_workflow_boundaries parameter and styling
- **Coverage**: Comprehensive test coverage for all major functions including new features

## Recent Major Features

### Workflow Boundaries System (NEW)

**Purpose**: Provides special visual styling for workflow control nodes (`start` and `end`) to clearly distinguish pipeline boundaries from data processing steps.

**Problem Solved**: Previously, `start` and `end` nodes looked identical to regular `input` nodes, making it hard to identify workflow entry/exit points in complex pipelines.

**Implementation**:
- `show_workflow_boundaries` parameter in `put_diagram()` function (default TRUE)
- Enhanced `get_node_shape()` function with conditional boundary styling
- Special icons: ⚡ for start nodes, 🏁 for end nodes
- Distinctive colors: green for start, red for end (across all themes)
- Enhanced `generate_node_styling()` to apply start/end styling conditionally

**Design Philosophy**:
- **Data-centric approach**: Regular node types (input, process, output, decision) represent data processing
- **Workflow control elements**: start/end represent pipeline boundaries, not data transformations
- **Conditional styling**: Users can disable boundaries for clean diagrams without workflow control styling

**Usage**:
```r
# Workflow boundaries enabled (default) - special start/end styling
put_diagram(workflow, show_workflow_boundaries = TRUE)

# Workflow boundaries disabled - start/end render as regular nodes
put_diagram(workflow, show_workflow_boundaries = FALSE)
```

**Testing**: Comprehensive test coverage with 7 dedicated workflow boundary tests covering parameter acceptance, icon display, styling application, and theme compatibility.

**CRAN Compliance**: Fixed non-ASCII character issues by converting emoji icons to Unicode escapes (`\u26a1`, `\ud83c\udfc1`) and enhanced null checking for missing data frame columns.

### Artifact Visualization System

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

## Evolution Timeline

### Phase 1: Foundation (Original Implementation)
- **Core annotation parsing system**: Extract structured comments from source files
- **Basic diagram generation**: Simple script-to-script connections
- **Multi-language support**: R, Python, SQL, Shell, Julia
- **Theme system**: 5 built-in themes for different environments
- **Output flexibility**: Console, file, clipboard support

### Phase 2: Data Flow Enhancement (Artifact System)
- **Problem identified**: Terminal outputs (like `final_results.csv`) missing from diagrams
- **Solution implemented**: `show_artifacts=TRUE` parameter
- **Architecture**: `create_artifact_nodes()` function identifies data files
- **Connection preservation**: Maintains BOTH script-to-script AND script-to-artifact connections
- **Visual distinction**: Cylindrical shape `[(filename)]` for data artifacts
- **Impact**: Complete data lineage visualization for complex pipelines

### Phase 3: Workflow Control Enhancement (Boundary System)
- **Problem identified**: Start/end nodes looked identical to regular input nodes
- **User feedback**: "there seems to be some redundancy" in node types
- **Design decision**: Data-centric approach with workflow boundaries as special control elements
- **Solution implemented**: `show_workflow_boundaries=TRUE` parameter (default)
- **Visual enhancement**: ⚡ lightning for start, 🏁 flag for end nodes
- **Conditional styling**: Green/red colors for start/end with option to disable
- **Philosophy**: Clear separation between data processing and workflow control

### Phase 4: CRAN Compliance & Robustness
- **CRAN readiness**: Fixed non-ASCII characters using Unicode escapes
- **Error handling**: Enhanced null checking for missing data frame columns
- **Test coverage**: Comprehensive testing for all visualization modes
- **Documentation**: Complete README.md and CLAUDE.md updates
- **Backward compatibility**: All existing functionality preserved

### Current State: Production Ready
- **Status**: Ready for CRAN submission (all checks passing)
- **Features**: Three visualization modes (Simple, Artifact, Workflow Boundaries)
- **Robustness**: Handles edge cases, missing columns, and invalid data gracefully
- **Documentation**: Comprehensive user guides and developer memory
- **Testing**: 300+ tests covering all functionality
- **Standards**: CRAN-compliant code and documentation

### Future Evolution Potential
- **Advanced layouts**: Network layouts for complex dependency graphs
- **Interactive features**: Clickable nodes for code navigation
- **Integration**: Direct IDE integration for live workflow visualization
- **Export formats**: SVG, PNG, HTML interactive diagrams
- **AI assistance**: Automatic workflow optimization suggestions

### Development Journey Insights
- **Iterative enhancement**: Each phase built upon previous foundation without breaking changes
- **User-driven evolution**: Features developed in response to real workflow visualization needs
- **Design philosophy**: Data-centric approach with clear separation of concerns
- **Quality focus**: Comprehensive testing and documentation at each evolution phase
- **CRAN standards**: Maintained compliance throughout development lifecycle
- The memory system in this file captures key details about the project's development
- Always document major changes, implementation details, and reasoning behind design decisions