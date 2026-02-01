# Get Detection Patterns for a Language

Returns the detection patterns for identifying inputs, outputs, and
dependencies in source code files for a specific programming language.

## Usage

``` r
get_detection_patterns(language = "r", type = NULL)
```

## Arguments

- language:

  Character string specifying the language. Options: "r", "python",
  "sql", "shell", "julia"

- type:

  Optional character string to filter by detection type. Options:
  "input", "output", "dependency". If NULL (default), returns all.

## Value

A list of patterns with the following structure:

- input: List of patterns for detecting file inputs

- output: List of patterns for detecting file outputs

- dependency: List of patterns for detecting script dependencies

Each pattern contains:

- regex: Regular expression to match the function call

- arg_position: Position of the file path argument (1-indexed)

- arg_name: Named argument for file path (alternative to position)

- description: Human-readable description

## Examples

``` r
# Get all R patterns
patterns <- get_detection_patterns("r")

# Get only input patterns for Python
input_patterns <- get_detection_patterns("python", type = "input")

# Get dependency patterns for R
dep_patterns <- get_detection_patterns("r", type = "dependency")
```
