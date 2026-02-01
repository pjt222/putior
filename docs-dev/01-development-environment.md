# Development Environment Setup

## Overview

This guide covers setting up your development environment for working on the putior R package.

## Critical Files for Development

### .Renviron

Contains essential environment variables for the development workflow:

```bash
RSTUDIO_PANDOC="C:/Program Files/RStudio/resources/app/bin/quarto/bin/tools"
```

**Purpose**: Configures Pandoc path for vignette building

**⚠️ NEVER delete this file** - It is essential for:
- Building vignettes
- Running R CMD check successfully
- Ensuring reproducible builds

### .Rprofile

Contains renv activation and conditional development tool loading:

```r
if (file.exists("renv/activate.R")) {
  source("renv/activate.R")
}

# Load acquaint MCP session if package is available (for development)
if (requireNamespace("acquaint", quietly = TRUE)) {
  acquaint::mcp_session()
}
```

**Purpose**: 
- Activates renv for dependency management
- Conditionally loads MCP tools for AI-assisted development
- Does not fail if development tools are unavailable (CI/CD friendly)

**⚠️ NEVER delete this file** - It is essential for:
- Development workflow
- Dependency management with renv
- Consistent development environment

## System Requirements

### R Version
- **Minimum**: R 4.0.0
- **Recommended**: R 4.5.0 or later
- **Tested on**: R 4.5.0

### Operating Systems

**Windows** (Primary development platform):
- Windows 11
- R 4.5.0
- RStudio (optional but recommended)

**Linux/WSL**:
- R path: `/mnt/c/Program Files/R/R-4.5.0/bin/Rscript.exe`
- Pandoc via `.Renviron` configuration

**macOS**:
- Tested via GitHub Actions
- Standard R installation

## Package Dependencies

### Runtime Dependencies (in DESCRIPTION)

**Imports**:
- Base R packages only
- tools package (standard library)

**Suggests**:
- uuid - For UUID generation (optional)
- rmarkdown - For vignettes
- knitr - For vignettes
- testthat - For testing

### Development-Only Tools (NOT in renv.lock)

**mcptools**:
- MCP server for AI-assisted development
- Install: `remotes::install_github("posit-dev/mcptools")`
- Loaded conditionally in `.Rprofile`
- Excluded from renv.lock to avoid GitHub credential warnings

**btw**:
- Dependency of mcptools
- Automatically installed with mcptools

**Configure renv to ignore**:
```r
renv::settings$ignored.packages(c("mcptools", "btw"))
```

## Development Environment Setup Steps

### 1. Clone Repository

```bash
git clone https://github.com/pjt222/putior.git
cd putior
```

### 2. Restore renv Environment

```r
# Open R in the project directory
renv::restore()
```

This will install all package dependencies specified in `renv.lock`.

### 3. Verify Critical Files

Ensure these files exist and are properly configured:
- `.Renviron` - Contains Pandoc path
- `.Rprofile` - Contains renv activation
- `DESCRIPTION` - Package metadata
- `NAMESPACE` - Exported functions

### 4. Install Development Tools (Optional)

```r
# Install mcptools for AI-assisted development
remotes::install_github("posit-dev/mcptools")

# Configure renv to ignore development tools
renv::settings$ignored.packages(c("mcptools", "btw"))
```

### 5. Verify Setup

```r
# Load package in development mode
devtools::load_all()

# Run basic checks
devtools::check()

# Run tests
devtools::test()
```

## Key Development Commands

### Package Checks

```r
# Full package check (requires Pandoc)
devtools::check()

# Check built package tarball
# R CMD check putior_X.X.X.tar.gz

# Spell checking (uses inst/WORDLIST)
devtools::spell_check()
```

### Building and Testing

```r
# Build package
devtools::build()

# Run tests
devtools::test()

# Build vignettes
devtools::build_vignettes()

# Generate documentation
devtools::document()
```

### Development Workflow

```r
# 1. Load package in development mode
devtools::load_all()

# 2. Make changes to code

# 3. Test changes
devtools::test()

# 4. Update documentation
devtools::document()

# 5. Run full check
devtools::check()
```

## Environment Variables

### RSTUDIO_PANDOC

**Purpose**: Specifies Pandoc installation path for vignette building

**Configuration** (in `.Renviron`):
```bash
RSTUDIO_PANDOC="C:/Program Files/RStudio/resources/app/bin/quarto/bin/tools"
```

**Why needed**:
- Vignettes require Pandoc to build
- R CMD check requires vignettes to build successfully
- Without this, package checks will fail

### Other Environment Variables

No other environment variables are required for development.

## Troubleshooting

### Vignette Build Failures

**Problem**: Vignettes fail to build during R CMD check

**Solution**: 
1. Verify `.Renviron` exists and contains correct Pandoc path
2. Check Pandoc installation: `rmarkdown::pandoc_version()`
3. Manually test vignette build: `devtools::build_vignettes()`

### renv Restore Issues

**Problem**: `renv::restore()` fails or shows warnings

**Solution**:
1. Update renv: `install.packages("renv")`
2. Clear renv cache: `renv::purge()`
3. Restore again: `renv::restore()`

### GitHub Actions Failures

**Problem**: CI/CD fails due to missing development dependencies

**Solution**:
- Use conditional loading in `.Rprofile` with `requireNamespace()`
- Don't include development-only tools in DESCRIPTION or renv.lock
- Example: mcptools is loaded conditionally and won't fail if unavailable

### Missing Dependencies

**Problem**: Package functions fail due to missing dependencies

**Solution**:
1. Check DESCRIPTION for required packages
2. Restore renv environment: `renv::restore()`
3. Install missing packages manually if needed

## Best Practices

### File Management

**DO**:
- Keep `.Renviron` and `.Rprofile` in version control
- Document any environment-specific configurations
- Use renv for dependency management
- Keep development tools separate from package dependencies

**DON'T**:
- Delete `.Renviron` or `.Rprofile` without understanding impact
- Include development-only tools in DESCRIPTION
- Commit user-specific session files (`.RData`, `.Rhistory`)
- Include temporary build artifacts in version control

### Dependency Management

**DO**:
- Use renv for reproducible environments
- Keep package dependencies minimal
- Document all dependencies in DESCRIPTION
- Use Suggests for optional dependencies

**DON'T**:
- Include GitHub packages in renv.lock (causes credential warnings)
- Add unnecessary dependencies
- Mix development tools with package dependencies

### Development Workflow

**DO**:
- Run `devtools::check()` before committing
- Update documentation with `devtools::document()`
- Write tests for new features
- Update NEWS.md with changes

**DON'T**:
- Commit code that doesn't pass R CMD check
- Skip documentation updates
- Ignore test failures
- Forget to update version numbers

## Additional Resources

- **R Packages Book**: https://r-pkgs.org/
- **devtools Documentation**: https://devtools.r-lib.org/
- **renv Documentation**: https://rstudio.github.io/renv/
- **Writing R Extensions**: https://cran.r-project.org/doc/manuals/r-release/R-exts.html
