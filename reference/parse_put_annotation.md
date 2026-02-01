# Extract PUT Annotation Properties

Parses a single line containing a PUT annotation and extracts key-value
pairs. Supports flexible syntax with optional spaces and pipe
separators. Handles multiple comment prefix styles: \# (hash), – (dash),
// (slash), % (percent).

## Usage

``` r
parse_put_annotation(line)
```

## Arguments

- line:

  Character string containing a PUT annotation

## Value

Named list containing all extracted properties, or NULL if invalid
