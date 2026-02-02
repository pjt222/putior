# Package Architecture

## Repository Overview

putior is an R package that extracts structured annotations from source code files and generates Mermaid flowchart diagrams for visualizing workflows and data pipelines. It supports R, Python, SQL, Shell, and Julia files.

**Status**: Production-ready, passing all checks, excellent documentation

## Directory Structure

```
putior/
├── .github/              # GitHub-specific files
│   └── workflows/        # CI/CD workflows
│       ├── claude.yml    # Claude Code integration
│       ├── pkgdown-gh-pages.yaml  # Documentation deployment
│       ├── r.yml         # R CMD check workflow
│       └── rhub.yaml     # R-hub platform checks
├── .Rproj.user/         # RStudio project cache (gitignored)
├── docs-dev/            # Development documentation (this folder)
├── inst/                # Installed files
│   ├── examples/        # Example scripts and demonstrations
│   ├── hex-sticker/     # Logo and hex sticker assets
│   │   ├── handcrafted/ # Original Draw.io designs (primary)
│   │   └── generated/   # R-generated stickers (development)
│   └── WORDLIST         # Spell check dictionary
├── man/                 # Function documentation (auto-generated)
│   └── figures/         # Documentation figures
│       ├── logo.png     # Package logo (handcrafted)
│       └── logo.svg     # Package logo SVG (handcrafted)
├── Meta/                # Package metadata (auto-generated, gitignored)
├── pkgdown/             # pkgdown site configuration
│   └── favicon/         # Website favicon files
├── R/                   # R source code
│   ├── putior.R         # Main package functions
│   ├── put_diagram.R    # Diagram generation functions
│   └── utils.R          # Utility functions
├── renv/                # renv dependency management
│   ├── activate.R       # renv activation script
│   ├── library/         # Package library (gitignored)
│   └── settings.json    # renv settings
├── test/                # Development test files
├── tests/               # Package tests
│   ├── testthat/        # testthat test files
│   └── testthat.R       # Test runner
├── vignettes/           # Package vignettes
│   └── getting-started.Rmd  # Getting started guide
├── .Rbuildignore        # Files to exclude from package build
├── .Renviron            # Environment variables (Pandoc path)
├── .Rprofile            # Development session configuration
├── .gitignore           # Git ignore patterns
├── DESCRIPTION          # Package metadata
├── LICENSE              # License file
├── LICENSE.md           # License details
├── NAMESPACE            # Exported functions (auto-generated)
├── NEWS.md              # Version history and changes
├── README.md            # User-facing documentation
├── _pkgdown.yml         # pkgdown configuration
├── putior.Rproj         # RStudio project file
└── renv.lock            # renv dependency lock file
```

## Core Components

### R Source Code (`R/`)

**putior.R** - Main package functions:
- `put()` - Extract workflow from files
- `process_single_file()` - Process individual files
- `parse_put_annotation()` - Parse PUT annotations
- `validate_put_annotation()` - Validate annotations
- `is_valid_put_annotation()` - Check annotation validity

**put_diagram.R** - Diagram generation:
- `put_diagram()` - Generate Mermaid diagrams
- `get_theme_colors()` - Theme color definitions
- `get_diagram_themes()` - List available themes
- Helper functions for node styling and connections

**utils.R** - Utility functions:
- File handling utilities
- String processing functions
- Validation helpers

### Package Assets (`inst/`)

#### Hex Sticker Organization

**inst/hex-sticker/handcrafted/** - Original Draw.io designs:
- Primary display assets
- Used for package logos and favicons
- Manually created and refined

**inst/hex-sticker/generated/** - R-generated stickers:
- Development and comparison purposes
- Created with ggplot2
- Not used in production

**Main package logos**:
- `man/figures/logo.png` - Uses handcrafted version
- `man/figures/logo.svg` - Uses handcrafted version

**Favicon files**:
- `pkgdown/favicon/` - All use handcrafted design

#### Examples (`inst/examples/`)

Comprehensive example scripts demonstrating package features:

- `create-putior-hex.R` - Hex sticker creation
- `data-science-workflow.R` - Data science pipeline example
- `diagram-example.R` - Diagram generation examples
- `generate-readme-examples.R` - README example generation
- `hex-sticker-comparison.md` - Hex sticker method comparison
- `hex-sticker-recommendations.md` - Hex sticker recommendations
- `hex-sticker-research.R` - Hex sticker research
- `multiline-example.R` - Multiline annotation examples
- `reprex.R` - Reproducible example
- `self-documentation.R` - Self-documentation example
- `source-tracking-example.R` - Source tracking demonstration
- `theme-examples.R` - Theme system examples
- `update-readme.R` - README update script
- `uuid-example.R` - UUID generation examples
- `variable-reference-example.R` - Variable reference demonstration

### Documentation

#### User Documentation

**README.md** - User-facing documentation:
- Installation instructions
- Quick start guide
- Feature overview
- Usage examples
- Theme system documentation
- Annotation reference

**vignettes/getting-started.Rmd** - Comprehensive tutorial:
- Introduction to PUT annotations
- Basic workflow
- Advanced usage
- Real-world examples
- Best practices
- Troubleshooting

**man/** - Function documentation:
- Auto-generated from roxygen2 comments
- One file per exported function
- Includes examples and parameter descriptions

#### Development Documentation

**docs-dev/** - Development guides (this folder):
- Development environment setup
- Package architecture
- Implementation details
- Quality assurance procedures
- CRAN submission guide
- CI/CD workflows
- Asset management

**CLAUDE.md** - AI assistant guidance:
- Repository overview
- Development environment setup
- File management best practices
- Quality assurance status
- Recent accomplishments
- Variable reference implementation
- GitHub Pages deployment

**IMPLEMENTATION_SUMMARY.md** - Technical implementation:
- Key features implemented
- Field changes and defaults
- Diagram generation details
- Development environment
- Recent implementation details
- Testing status

### Tests (`tests/`)

**testthat/** - Test files:
- Comprehensive test coverage (338 tests)
- Tests for all major functions
- Edge case handling
- Multiline annotation support
- UUID generation tests
- Output defaulting tests
- Theme validation tests

**Test organization**:
- One test file per source file
- Descriptive test names
- Good coverage of edge cases

## Self-Documentation Excellence

The package uses its own PUT annotation system to document internal workflow:

```r
# Extract putior's own workflow
put('./R/')
```

This demonstrates "eating your own dog food" principle and shows:
- File scanning → annotation processing → validation → parsing → conversion → diagram generation
- 10 nodes in putior's internal workflow
- Complete self-documentation capability

## File Management Best Practices

### Safe to Remove (Temporary/Generated Files)

- R CMD check directories (`*.Rcheck/`)
- Build artifacts (`*.tar.gz`, `Meta/`, `doc/`)
- Generated sites (`docs/`)
- Cache files (`*.rds` in root)
- RStudio cache (`.Rproj.user/`)

### NEVER Remove (Critical Development Files)

- `.Renviron` - Contains essential environment variables
- `.Rprofile` - Contains development session configuration
- User session data (`.RData`, `.Rhistory`) without explicit permission

### Ignore File Strategy

**.gitignore**:
- Excludes user-specific files
- Preserves package assets
- Ignores temporary build artifacts
- Keeps development environment clean

**.Rbuildignore**:
- Excludes development files from package builds
- Uses specific patterns
- Avoids overly broad exclusions like `*.png`
- Ensures all necessary assets are included in package

## Design Patterns

### Annotation System

**Flexible syntax support**:
```r
# put property:\"value\"             # Standard (matches logo)
#put property:\"value\"              # Also valid (no space)
#put| property:\"value\"             # Pipe separator
#put: property:\"value\"             # Colon separator
```

**Auto-generation features**:
- UUID generation when `id` is omitted
- Output defaulting to current file name when `output` is omitted
- Validation warnings for empty values

### Theme System

**5 carefully designed themes**:
- `light` - Default light theme with bright colors
- `dark` - Dark theme with muted colors
- `auto` - GitHub-adaptive theme
- `github` - Optimized for maximum GitHub compatibility
- `minimal` - Grayscale professional theme

**Theme implementation**:
- Centralized color definitions in `get_theme_colors()`
- Invalid themes trigger warning and fallback to light theme
- `style_nodes` parameter controls whether styling is applied

### Workflow Boundaries

**Control visualization of start/end points**:
- `show_workflow_boundaries = TRUE` - Special styling for start/end nodes
- `show_workflow_boundaries = FALSE` - Regular node styling

**Node types**:
- Data processing: `input`, `process`, `output`, `decision`
- Workflow control: `start`, `end`

### Variable Reference Implementation

**`.internal` extension for in-memory variables**:
- Outputs only, never inputs between scripts
- Documents computational steps within scripts
- Persistent files enable inter-script data flow
- Example: `output:'my_variable.internal, my_data.RData'`

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

**All dependencies are from CRAN** - No GitHub packages

### Development-Only Tools (NOT in renv.lock)

**mcptools**:
- MCP server for AI-assisted development
- Install separately: `remotes::install_github("posit-dev/mcptools")`
- Loaded conditionally in `.Rprofile`
- Excluded from renv.lock to avoid GitHub credential warnings

**btw**:
- Dependency of mcptools
- Automatically installed with mcptools

## GitHub Pages Deployment

### Current Configuration

**Deployment Method**: Branch-based deployment from `gh-pages` branch

**Workflow**: `.github/workflows/pkgdown-gh-pages.yaml`

**Important**: Development mode is disabled in `_pkgdown.yml` to ensure proper root-level deployment

### Key Settings

**_pkgdown.yml**:
```yaml
# development:
#   mode: auto
```

**GitHub Pages Settings**: Deploy from `gh-pages` branch (NOT GitHub Actions)

**Site URL**: https://pjt222.github.io/putior/

### Deployment Workflow

1. Changes pushed to main branch trigger `pkgdown-gh-pages` workflow
2. Workflow builds pkgdown site with `pkgdown::build_site_github_pages()`
3. JamesIves/github-pages-deploy-action deploys `docs/` folder to `gh-pages` branch
4. GitHub Pages serves the site from `gh-pages` branch root

## CI/CD Considerations

### GitHub Actions

**Workflows**:
- `r.yml` - R CMD check on multiple platforms
- `pkgdown-gh-pages.yaml` - Documentation deployment
- `rhub.yaml` - R-hub platform checks
- `claude.yml` - Claude Code integration

**Important**: 
- May fail if development dependencies (like mcptools) aren't available
- Solution: Use conditional loading with `requireNamespace()` in `.Rprofile`
- Spell check passes cleanly with comprehensive WORDLIST

### Platform Testing

**Local**: Windows 11, R 4.5.0 - Status OK

**GitHub Actions**: Windows, macOS, Ubuntu - All passing

**Win-builder**: R-devel and R-release - 1 NOTE (new submission only)

**R-hub**: 4/5 platforms PASS (linux, macos, windows, ubuntu-release; nosuggests expected fail)

## Additional Resources

- **R Packages Book**: https://r-pkgs.org/
- **Writing R Extensions**: https://cran.r-project.org/doc/manuals/r-release/R-exts.html
- **pkgdown Documentation**: https://pkgdown.r-lib.org/
- **GitHub Actions for R**: https://github.com/r-lib/actions
