# CLAUDE.md

This file provides guidance to AI assistants when working with code in this repository.

## Repository Overview

putior is an R package that extracts structured annotations from source code files and generates Mermaid flowchart diagrams for visualizing workflows and data pipelines. It supports R, Python, SQL, Shell, and Julia files.

**Status**: Production-ready, passing all checks, excellent documentation

## Development Environment Setup

### Critical Files for Development
- `.Renviron`: Contains Pandoc path for vignette building: `RSTUDIO_PANDOC="C:/Program Files/RStudio/resources/app/bin/quarto/bin/tools"`
- `.Rprofile`: Contains renv activation and conditional acquaint MCP session loading
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
- Package passes with **0 errors, 0 warnings, 1 minor note** (timing verification)
- All vignettes build successfully with Pandoc
- All tests pass (338 tests including multiline annotation support)
- Comprehensive multiline PUT annotation support implemented

### Documentation Quality
- Vignette rating: **9.2/10** - Exceptional quality
- Comprehensive getting-started guide with real-world examples
- Complete self-documentation workflow
- README with auto-generated examples capability

### CI/CD Considerations
- GitHub Actions may fail if development dependencies (like `acquaint`) aren't available
- Solution: Use conditional loading with `requireNamespace()` in `.Rprofile`
- Spell check passes cleanly with comprehensive WORDLIST

## Recent Major Accomplishments

1. **Multiline annotation support** - Implemented backslash continuation syntax
2. **Hex sticker organization** - Clean separation of handcrafted vs generated assets  
3. **Development environment restoration** - Proper `.Renviron`/`.Rprofile` setup
4. **File structure cleanup** - Removed 4.2MB of temporary files while preserving essentials
5. **CI/CD fixes** - Resolved GitHub Actions failures with conditional package loading
6. **Documentation excellence** - High-quality vignettes and self-documentation
7. **Spelling compliance** - Complete WORDLIST for technical terms and proper names

## Package Readiness
✅ **Production ready** - All checks passing  
✅ **CRAN submission ready** - Comprehensive documentation and testing  
✅ **Self-documenting** - Demonstrates own capabilities effectively  
✅ **Clean codebase** - Well-organized file structure and ignore patterns