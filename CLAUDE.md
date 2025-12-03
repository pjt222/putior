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