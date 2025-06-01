# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

putior is an R package that extracts structured annotations from source code files and generates Mermaid flowchart diagrams for visualizing workflows and data pipelines. It supports R, Python, SQL, Shell, and Julia files.

## Common Development Commands

### Build and Check
```bash
# Install development dependencies
Rscript -e "devtools::install_dev_deps()"

# Build and install the package
Rscript -e "devtools::install()"

# Full package check (includes examples, tests, documentation)
Rscript -e "devtools::check()"

# Quick check without rebuilding vignettes
Rscript -e "devtools::check(build_args = '--no-build-vignettes')"
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

# Build vignettes
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

2. **Diagram Generation** (`R/put_diagram.R`)
   - `put_diagram()` - Generates Mermaid flowchart code from parsed data
   - `generate_connections()` - Creates edges based on matching input/output files
   - Theme system with 5 built-in themes (light, dark, auto, github, minimal)
   - Supports multiple output modes (console, file, clipboard)

3. **Data Flow Architecture**
   - Annotations define nodes with `name`, `label`, `node_type`, `input`, and `output`
   - Automatic connection inference by matching output files to input files
   - Node types map to Mermaid shapes (input→stadium, process→rectangle, output→subroutine)

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

## Important Notes

- The package uses base R functions where possible, only importing `tools` package
- Clipboard functionality requires `clipr` package (suggested, not required)
- Mermaid diagram syntax must be carefully formatted (trailing spaces break GitHub rendering)
- File extensions are required in input/output declarations for proper validation
- The package is designed to work with existing codebases without modification (only annotations needed)