# Developer Guide

This file provides guidance for developers and AI assistants working with the `putior` repository.

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
- All tests pass (338 tests including multiline annotation support)
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

## Implementation Details

### Annotation System
- **Syntax**: `#put key:"value", key2:"value2"`
- **Alternative formats**: `# put`, `#put|`, `#put:`
- **Supported file types**: R, Python, SQL, Shell, Julia

### Field Changes and Defaults
- **Renamed**: `name` → `id` (better graph theory alignment)
- **UUID Auto-generation**: When `id` is omitted, automatically generates UUID
- **Output Defaulting**: When `output` is omitted, defaults to current file name
- **Validation**: Empty `id:""` generates warning; missing `id` gets UUID

### Diagram Generation
- **5 Themes**: light, dark, auto, github, minimal
- **Node Types**: input (stadium), process (rectangle), output (subroutine), decision (diamond)
- **Connections**: Automatic based on matching input/output files
- **Output Options**: console, file, clipboard

### Code Implementation Highlights

#### UUID Generation (parse_put_annotation in putior.R)
```r
# Generate UUID if id is missing (not if it's empty)
if (is.null(properties$id) && requireNamespace("uuid", quietly = TRUE)) {
  properties$id <- uuid::UUIDgenerate()
}
```

#### Output Defaulting (process_single_file in putior.R)
```r
# Default output to file_name if not specified
if (is.null(properties$output) || properties$output == "") {
  properties$output <- basename(file)
}
```

#### Source Relationship Tracking
**Pattern for scripts that source other scripts:**
- Main script: `input:"script1.R,script2.R"` (scripts being sourced)
- Sourced scripts: `output` defaults to their filename
- Dependencies between sourced scripts use filenames

**Correct flow direction:**
- `sourced_script.R` → `main_script.R` (sourced into)
- Represents that `source("file.R")` reads file.R into current environment

#### Theme System (get_theme_colors in put_diagram.R)
- Each theme defines colors for: input, process, output, decision node types
- Invalid themes trigger warning and fallback to light theme
- style_nodes parameter controls whether styling is applied

### Variable Reference Implementation (GitHub Issue #2)

#### Key Concepts for `.internal` Extension
- **Purpose**: Track in-memory variables and objects during script execution
- **Usage**: `.internal` variables are **outputs only**, never inputs between scripts
- **Data Flow**: Use persistent files (RData, CSV, etc.) for inter-script communication
- **Example**: `output:'my_variable.internal, my_data.RData'`

#### Critical Rules
1. **`.internal` variables exist only during script execution** → Cannot be inputs to other scripts
2. **Persistent files enable inter-script data flow** → Use saved files as inputs/outputs between scripts  
3. **Connected workflows require file-based dependencies** → Each script's file outputs become inputs to subsequent scripts
4. **Document computational steps** → Use `.internal` to show what variables are created within each script

#### Example Implementation
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
