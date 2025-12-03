# Implementation Details

## Overview

This document provides technical implementation details for the putior package, including key features, recent changes, and implementation patterns.

## Key Features Implemented

### 1. Annotation System

**Syntax**: `#put key:"value", key2:"value2"`

**Alternative formats**:
```r
#put property:"value"              # Standard
# put property:"value"             # Space after #
#put| property:"value"             # Pipe separator
#put: property:"value"             # Colon separator
```

**Supported file types**:
- R (`.R`, `.r`)
- Python (`.py`)
- SQL (`.sql`)
- Shell (`.sh`)
- Julia (`.jl`)

### 2. Field Changes and Defaults

#### Renamed Fields
- **`name` → `id`** - Better graph theory alignment

#### UUID Auto-generation
When `id` is omitted, automatically generates UUID:

```r
# In parse_put_annotation (putior.R)
if (is.null(properties$id) && requireNamespace("uuid", quietly = TRUE)) {
  properties$id <- uuid::UUIDgenerate()
}
```

**Validation**:
- Empty `id:""` generates warning
- Missing `id` gets UUID (if uuid package available)

#### Output Defaulting
When `output` is omitted, defaults to current file name:

```r
# In process_single_file (putior.R)
if (is.null(properties$output) || properties$output == "") {
  properties$output <- basename(file)
}
```

**Purpose**: Ensures nodes can be connected in workflows even when explicit output files aren't specified

### 3. Diagram Generation

**5 Themes**:
- `light` - Default light theme with bright colors
- `dark` - Dark theme with muted colors
- `auto` - GitHub-adaptive theme
- `github` - Optimized for maximum GitHub compatibility
- `minimal` - Grayscale professional theme

**Node Types**:
- `input` - Stadium shape `([text])`
- `process` - Rectangle `[text]`
- `output` - Subroutine `[[text]]`
- `decision` - Diamond `{text}`
- `start` - Stadium with orange styling (workflow boundary)
- `end` - Stadium with green styling (workflow boundary)

**Connections**: Automatic based on matching input/output files

**Output Options**: Console, file, clipboard

### 4. Multiline Annotation Support

Implemented backslash continuation syntax:

```r
#put id:"complex_node", \
     label:"This is a long description", \
     input:"file1.csv,file2.csv", \
     output:"result.csv"
```

**Implementation**:
- Detects backslash at end of line
- Continues reading next line
- Concatenates lines before parsing
- Comprehensive test coverage (338 tests include multiline support)

## Recent Implementation Details

### UUID Generation

**Location**: `parse_put_annotation` in `putior.R`

**Implementation**:
```r
# Generate UUID if id is missing (not if it's empty)
if (is.null(properties$id) && requireNamespace("uuid", quietly = TRUE)) {
  properties$id <- uuid::UUIDgenerate()
}
```

**Behavior**:
- Only generates UUID if `id` is completely omitted
- Requires uuid package (in Suggests)
- Falls back gracefully if uuid not available
- Empty `id:""` triggers validation warning

### Output Defaulting

**Location**: `process_single_file` in `putior.R`

**Implementation**:
```r
# Default output to file_name if not specified
if (is.null(properties$output) || properties$output == "") {
  properties$output <- basename(file)
}
```

**Use case**: Scripts that are sourced by other scripts

**Example**:
```r
# utils.R - sourced by main.R
#put label:"Utility Functions"
# output defaults to "utils.R"

# main.R - sources utils.R
#put label:"Main Script", input:"utils.R", output:"results.csv"
# Creates connection: utils.R → main.R
```

### Source Relationship Tracking

**Pattern for scripts that source other scripts**:

**Main script**:
```r
#put input:"script1.R,script2.R"  # Scripts being sourced
source("script1.R")
source("script2.R")
```

**Sourced scripts**:
```r
#put label:"Helper Functions"
# output defaults to filename
```

**Correct flow direction**:
- `sourced_script.R` → `main_script.R` (sourced into)
- Represents that `source("file.R")` reads file.R into current environment

### Theme System

**Location**: `get_theme_colors` in `put_diagram.R`

**Implementation**:
- Each theme defines colors for: input, process, output, decision node types
- Invalid themes trigger warning and fallback to light theme
- `style_nodes` parameter controls whether styling is applied

**Theme structure**:
```r
get_theme_colors <- function(theme = "light") {
  themes <- list(
    light = list(
      input = list(fill = "#e1f5fe", stroke = "#01579b", color = "#000000"),
      process = list(fill = "#f3e5f5", stroke = "#4a148c", color = "#000000"),
      output = list(fill = "#e8f5e8", stroke = "#1b5e20", color = "#000000"),
      decision = list(fill = "#fff3e0", stroke = "#e65100", color = "#000000")
    ),
    # ... other themes
  )
  
  if (!theme %in% names(themes)) {
    warning("Invalid theme. Using 'light' theme.")
    theme <- "light"
  }
  
  themes[[theme]]
}
```

### Workflow Boundaries

**Feature**: Control visualization of workflow start/end points

**Parameters**:
- `show_workflow_boundaries = TRUE` - Special styling for start/end nodes (default)
- `show_workflow_boundaries = FALSE` - Regular node styling

**Implementation**:
```r
# In put_diagram.R
if (show_workflow_boundaries && node_type %in% c("start", "end")) {
  # Apply special styling
  if (node_type == "start") {
    # Orange styling with thicker borders
  } else if (node_type == "end") {
    # Green styling with thicker borders
  }
} else {
  # Regular node styling based on node_type
}
```

### Variable Reference Implementation

**Feature**: Track in-memory variables with `.internal` extension

**Key concepts**:
- `.internal` variables are **outputs only**, never inputs between scripts
- Persistent files (RData, CSV, etc.) enable inter-script data flow
- Documents computational steps within scripts

**Example**:
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

**Reference**: `inst/examples/variable-reference-example.R`

**GitHub Issues**: #2 (original discussion), #3 (metadata), #4 (hyperlinks)

## Development Environment

### WSL Configuration

**R path**: `/mnt/c/Program Files/R/R-4.5.0/bin/Rscript.exe`

**Pandoc**: Via `.Renviron`:
```bash
RSTUDIO_PANDOC="C:/Program Files/RStudio/resources/app/bin/quarto/bin/tools"
```

### Dependencies

**Minimal runtime dependencies**:
- Base R + tools package
- uuid in Suggests (optional)

**Development dependencies**:
- devtools - Package development
- testthat - Testing
- rmarkdown - Vignettes
- knitr - Vignettes
- pkgdown - Documentation site

## Testing

### Test Coverage

**Total tests**: 338 tests

**Test areas**:
- Annotation parsing
- UUID generation (when uuid package available)
- Output defaulting
- Theme validation
- Multiline annotation support
- File scanning
- Workflow extraction
- Diagram generation

**Test status**: All tests passing - 0 errors, 0 warnings, 0 notes

### Test Organization

**Location**: `tests/testthat/`

**Structure**:
- One test file per source file
- Descriptive test names using `test_that()`
- Edge case coverage
- Integration tests for complete workflows

**Example test**:
```r
test_that("UUID generation works when id is missing", {
  skip_if_not_installed("uuid")
  
  annotation <- '#put label:"Test Node"'
  result <- parse_put_annotation(annotation)
  
  expect_true(!is.null(result$id))
  expect_match(result$id, "^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$")
})
```

## Documentation

### README.md

**Updated with**:
- Examples showing optional id
- Output defaulting examples
- Theme system documentation
- Workflow boundary examples
- Variable reference patterns

### Vignette

**Sections**:
- Auto-generation features
- UUID generation
- Output defaulting
- Source tracking
- Variable references with `.internal`
- Best practices

### NEWS.md

**Documents all changes** for CRAN submission:
- Version history
- New features
- Bug fixes
- Breaking changes

### CLAUDE.md

**Technical implementation details** for AI assistants:
- Development environment
- File management
- Quality assurance
- Recent accomplishments
- Variable reference implementation
- GitHub Pages deployment

## Package Status

### Production Ready

✅ All checks passing
✅ CRAN submission ready
✅ Comprehensive documentation and testing
✅ Self-documenting (demonstrates own capabilities)
✅ Clean codebase
✅ GitHub Pages deployed

### Quality Metrics

**R CMD check**: 0 errors, 0 warnings, 1 note (new submission)

**Test coverage**: 338 tests passing

**Documentation quality**: 9.2/10 (exceptional)

**Vignette rating**: Comprehensive getting-started guide with real-world examples

**Platform testing**:
- Local: Windows 11, R 4.5.0 - OK
- GitHub Actions: Windows, macOS, Ubuntu - All passing
- Win-builder: R-devel and R-release - 1 NOTE (new submission only)
- R-hub: 4/5 platforms PASS

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

## Implementation Best Practices

### Code Organization

**DO**:
- Keep functions focused and single-purpose
- Use descriptive function and variable names
- Document all exported functions with roxygen2
- Include examples in documentation
- Write tests for all features

**DON'T**:
- Create overly complex functions
- Use cryptic variable names
- Skip documentation
- Ignore edge cases in tests

### Error Handling

**DO**:
- Validate inputs early
- Provide helpful error messages
- Use warnings for non-fatal issues
- Fail gracefully when optional dependencies unavailable

**Example**:
```r
if (!requireNamespace("uuid", quietly = TRUE)) {
  warning("uuid package not available. Cannot generate UUIDs.")
  return(NULL)
}
```

### Performance

**DO**:
- Use vectorized operations when possible
- Avoid unnecessary loops
- Cache expensive computations
- Profile code for bottlenecks

**DON'T**:
- Premature optimization
- Sacrifice readability for minor performance gains

## Future Enhancements

### Potential Features

1. **Interactive diagrams** - Add interactivity to Mermaid diagrams
2. **More themes** - Additional color schemes
3. **Custom node shapes** - User-defined shapes
4. **Export formats** - PNG, SVG, PDF export
5. **Workflow validation** - Check for circular dependencies
6. **Metadata extraction** - Extract more metadata from code

### Backward Compatibility

**Commitment**: Maintain backward compatibility for all public APIs

**Deprecation process**:
1. Mark as deprecated with `.Deprecated()`
2. Document in NEWS.md
3. Provide migration path
4. Remove in next major version

## Additional Resources

- **R Packages Book**: https://r-pkgs.org/
- **Advanced R**: https://adv-r.hadley.nz/
- **Mermaid Documentation**: https://mermaid.js.org/
- **GitHub Issues**: https://github.com/pjt222/putior/issues
