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

3. **Data Flow Architecture**
   - Annotations define nodes with `name`, `label`, `node_type`, `input`, and `output`
   - Automatic connection inference by matching output files to input files
   - Node types map to Mermaid shapes:
     - input/start/end → stadium `([text])`
     - process → rectangle `[text]`
     - output → subroutine `[[text]]`
     - decision → diamond `{text}`

### Key Design Patterns

- **Functional approach**: Pure functions with minimal side effects
- **Validation at parse time**: Early error detection with helpful messages
- **Flexible annotation syntax**: Supports multiple comment formats (#put, # put, #put|, #put:)
- **Theme abstraction**: Color schemes isolated from diagram logic
- **Output abstraction**: Single interface for console/file/clipboard output

### Testing Strategy

- Unit tests for all parsing functions
- Integration tests for complete workflows
- Edge case handling (empty files, invalid syntax, missing properties)
- Theme validation tests
- File I/O testing with temporary directories
- **Coverage**: Comprehensive test coverage for all major functions

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

## Development Tips

- Use `devtools::load_all()` for interactive development
- Run `devtools::check()` frequently during development
- Update `NEWS.md` for any user-facing changes
- Use the spell check regularly to catch typos early
- Test on multiple platforms before major releases
- Follow the existing code style and patterns