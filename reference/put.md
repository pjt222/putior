# Scan Source Files for PUT Annotations

Scans source files in a directory for PUT annotations that define
workflow nodes, inputs, outputs, and metadata. Supports multiple
programming languages with their native comment syntax, including
single-line and multiline formats.

## Usage

``` r
put(
  path,
  pattern = NULL,
  recursive = TRUE,
  include_line_numbers = FALSE,
  validate = TRUE,
  log_level = NULL
)
```

## Arguments

- path:

  Character string specifying the path to the folder containing files,
  or path to a single file

- pattern:

  Character string specifying the file pattern to match. Default: all
  supported extensions (see
  [`get_supported_extensions`](https://pjt222.github.io/putior/reference/get_supported_extensions.md)).
  For a subset, specify a pattern (e.g., "\\js\$" for JavaScript only).

- recursive:

  Logical. Should subdirectories be searched recursively? Default: TRUE

- include_line_numbers:

  Logical. Should line numbers be included in output? Default: FALSE

- validate:

  Logical. Should annotations be validated for common issues? Default:
  TRUE

- log_level:

  Character string specifying log verbosity for this call. Overrides the
  global option `putior.log_level` when specified. Options: "DEBUG",
  "INFO", "WARN", "ERROR". See
  [`set_putior_log_level`](https://pjt222.github.io/putior/reference/set_putior_log_level.md).

## Value

A data frame containing file names and all properties found in
annotations. Always includes columns: file_name, file_type, and any
properties found in PUT annotations (typically: id, label, node_type,
input, output). If include_line_numbers is TRUE, also includes
line_number. Note: If output is not specified in an annotation, it
defaults to the file name.

## Supported Languages

PUT annotations work with any language by using the appropriate comment
prefix:

- **Hash (#)**: R, Python, Shell, Julia, Ruby, Perl, YAML

- **Dash (–)**: SQL, Lua, Haskell

- **Slash (//)**: JavaScript, TypeScript, C/C++, Java, Go, Rust, Swift,
  Kotlin, C#

- **Percent (%)**: MATLAB, LaTeX

## PUT Annotation Syntax

PUT annotations can be written in single-line or multiline format. The
comment prefix is determined automatically by file extension.

**Single-line format (various languages):**

    # put id:"node1", label:"Process"       # R/Python
    --put id:"node1", label:"Query"        -- SQL
    //put id:"node1", label:"Handler"      // JavaScript

**Multiline format:** Use backslash (\\ for line continuation

    # put id:"node1", label:"Process Data", \
    #    input:"data.csv", \
    #    output:"result.csv"

**Benefits of multiline format:**

- Compliance with code style guidelines (styler, lintr)

- Improved readability for complex workflows

- Easier maintenance of long file lists

- Better code organization and documentation

**Syntax rules:**

- End lines with backslash (\\ to continue

- Each continuation line must start with the appropriate comment marker

- Properties are automatically joined with proper comma separation

- Works with all PUT formats: prefix+put, prefix + put, prefix+put\|,
  prefix+put:

## Examples

``` r
if (FALSE) { # \dontrun{
# Scan a directory for workflow annotations (recursive by default)
workflow <- put("./src/")

# Scan top-level only (opt out of recursion)
workflow <- put("./project/", recursive = FALSE)

# Scan a single file
workflow <- put("./script.R")

# Include line numbers for debugging
workflow <- put("./src/", include_line_numbers = TRUE)

# Scan JavaScript/TypeScript files
workflow <- put("./frontend/", pattern = "\\.(js|ts|jsx|tsx)$")

# Scan SQL files
workflow <- put("./sql/", pattern = "\\.sql$")

# Single-line PUT annotations (various languages):
# R/Python: # put id:"load_data", label:"Load Dataset"
# SQL:      --put id:"query", label:"Execute Query"
# JS/TS:    //put id:"handler", label:"API Handler"
# MATLAB:   %put id:"compute", label:"Compute Results"
#
# Multiline PUT annotations work the same across languages:
# # put id:"complex_process", label:"Complex Processing", \
# #    input:"file1.csv,file2.csv", \
# #    output:"results.csv"
#
# --put id:"etl_job", label:"ETL Process", \
# --    input:"source_table", \
# --    output:"target_table"
} # }
```
