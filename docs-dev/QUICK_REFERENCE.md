# Quick Reference Guide

## Essential Commands

### Package Development

```r
# Load package in development mode
devtools::load_all()

# Run all tests
devtools::test()

# Run R CMD check
devtools::check()

# Build package
devtools::build()

# Generate documentation
devtools::document()

# Build vignettes
devtools::build_vignettes()

# Spell check
devtools::spell_check()
```

### CRAN Submission

```r
# Win-builder checks
devtools::check_win_devel()
devtools::check_win_release()

# R-hub checks
rhub::rhub_check()

# Submit to CRAN
devtools::release()
```

### Documentation

```r
# Build pkgdown site
pkgdown::build_site()

# Build specific article
pkgdown::build_article("getting-started")

# Preview site
pkgdown::preview_site()
```

## Critical Files

### Never Delete

- `.Renviron` - Pandoc path for vignettes
- `.Rprofile` - Development session configuration
- `DESCRIPTION` - Package metadata
- `NAMESPACE` - Exported functions

### Safe to Remove

- `*.Rcheck/` - R CMD check directories
- `*.tar.gz` - Build artifacts
- `Meta/` - Package metadata (auto-generated)
- `doc/` - Vignette output (auto-generated)
- `.Rproj.user/` - RStudio cache

## Common Tasks

### Add New Function

1. Create function in `R/` directory
2. Add roxygen2 documentation
3. Run `devtools::document()`
4. Add tests in `tests/testthat/`
5. Run `devtools::test()`
6. Run `devtools::check()`

### Update Documentation

1. Edit roxygen2 comments in R files
2. Run `devtools::document()`
3. Build vignettes: `devtools::build_vignettes()`
4. Update NEWS.md
5. Rebuild pkgdown site: `pkgdown::build_site()`

### Fix Test Failures

1. Run specific test: `testthat::test_file("tests/testthat/test-putior.R")`
2. Debug with `browser()` in test
3. Fix code
4. Re-run test
5. Run full test suite: `devtools::test()`

### Update Dependencies

1. Edit DESCRIPTION file
2. Run `renv::snapshot()` to update renv.lock
3. Run `devtools::check()` to verify
4. Update documentation if needed

## File Locations

### Source Code

- `R/putior.R` - Main functions
- `R/put_diagram.R` - Diagram generation
- `R/utils.R` - Utility functions

### Documentation

- `man/` - Function documentation (auto-generated)
- `vignettes/` - Package vignettes
- `README.md` - User-facing documentation
- `NEWS.md` - Version history
- `docs-dev/` - Development documentation

### Tests

- `tests/testthat/` - Test files
- `tests/testthat.R` - Test runner

### Assets

- `inst/hex-sticker/handcrafted/` - Primary hex sticker
- `man/figures/` - Package logos
- `pkgdown/favicon/` - Website favicons

### Configuration

- `.Renviron` - Environment variables
- `.Rprofile` - Session configuration
- `_pkgdown.yml` - pkgdown configuration
- `.Rbuildignore` - Build exclusions
- `.gitignore` - Git exclusions

## Package Status

### Current Version

Check `DESCRIPTION` file for current version.

### Quality Metrics

- **R CMD check**: 0 errors, 0 warnings, 1 note (new submission)
- **Tests**: 338 tests passing
- **Documentation**: 9.2/10 rating
- **Platforms**: Windows, macOS, Linux all passing

### URLs

- **GitHub**: https://github.com/pjt222/putior
- **GitHub Pages**: https://pjt222.github.io/putior/
- **CRAN**: (pending submission)

## Troubleshooting

### Vignette Build Fails

```r
# Check Pandoc
rmarkdown::pandoc_version()

# Verify .Renviron
file.exists(".Renviron")

# Test vignette build
devtools::build_vignettes()
```

### Tests Fail

```r
# Run specific test file
testthat::test_file("tests/testthat/test-putior.R")

# Run with debugging
devtools::test(filter = "specific_test_name")
```

### R CMD Check Issues

```r
# Run with details
devtools::check(manual = TRUE, cran = TRUE)

# Check specific issues
devtools::spell_check()
urlchecker::url_check()
```

### GitHub Actions Fail

1. Check workflow logs in GitHub Actions tab
2. Verify all dependencies in DESCRIPTION
3. Check for platform-specific issues
4. Test locally on relevant platform

## Development Workflow

### Daily Development

1. Pull latest changes: `git pull`
2. Load package: `devtools::load_all()`
3. Make changes
4. Test changes: `devtools::test()`
5. Update documentation: `devtools::document()`
6. Commit changes: `git commit -am "message"`
7. Push changes: `git push`

### Before Commit

1. Run tests: `devtools::test()`
2. Run check: `devtools::check()`
3. Update NEWS.md if needed
4. Spell check: `devtools::spell_check()`

### Before Release

1. Update version in DESCRIPTION
2. Update NEWS.md
3. Run full check: `devtools::check(manual = TRUE, cran = TRUE)`
4. Build package: `devtools::build()`
5. Test built package: `R CMD check putior_X.X.X.tar.gz`
6. Win-builder checks
7. R-hub checks
8. Update cran-comments.md
9. Submit to CRAN: `devtools::release()`

## Key Concepts

### PUT Annotations

```r
# put id:"node_id", label:"Description", node_type:"process", input:"file.csv", output:"result.csv"
```

### Node Types

- `input` - Data sources
- `process` - Data transformation
- `output` - Final results
- `decision` - Conditional logic
- `start` - Workflow entry
- `end` - Workflow termination

### Themes

- `light` - Default light theme
- `dark` - Dark theme
- `auto` - GitHub-adaptive
- `github` - Maximum GitHub compatibility
- `minimal` - Grayscale professional

### Workflow Extraction

```r
# Extract from directory
workflow <- put("./src/")

# Generate diagram
put_diagram(workflow)

# With options
put_diagram(workflow, theme = "github", direction = "LR", show_artifacts = TRUE)
```

## Environment Variables

### RSTUDIO_PANDOC

```bash
RSTUDIO_PANDOC="C:/Program Files/RStudio/resources/app/bin/quarto/bin/tools"
```

Required for vignette building.

## Package Dependencies

### Runtime (in DESCRIPTION)

- Base R packages only
- uuid (Suggests)

### Development (NOT in renv.lock)

- mcptools - AI-assisted development
- btw - mcptools dependency

## Git Workflow

### Branches

- `main` - Production-ready code
- Feature branches for development

### Commits

```bash
# Stage changes
git add .

# Commit with message
git commit -m "Descriptive message"

# Push to GitHub
git push origin main
```

### Tags

```bash
# Create release tag
git tag -a v0.1.0 -m "Release version 0.1.0"

# Push tag
git push origin v0.1.0
```

## Additional Resources

### Documentation

- [Development Environment](01-development-environment.md)
- [Package Architecture](02-package-architecture.md)
- [Implementation Details](03-implementation-details.md)
- [Quality Assurance](04-quality-assurance.md)
- [CRAN Submission](05-cran-submission.md)
- [CI/CD Workflows](06-ci-cd-workflows.md)
- [Asset Management](07-asset-management.md)

### External Resources

- **R Packages Book**: https://r-pkgs.org/
- **devtools**: https://devtools.r-lib.org/
- **testthat**: https://testthat.r-lib.org/
- **pkgdown**: https://pkgdown.r-lib.org/
- **CRAN Policy**: https://cran.r-project.org/web/packages/policies.html
