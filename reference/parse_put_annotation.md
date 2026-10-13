# Extract PUT Annotation Properties

Parses a single line containing a PUT annotation and extracts key-value
pairs. Supports flexible syntax with optional spaces and pipe
separators. Handles multiple comment prefix styles: \# (hash), – (dash),
// (slash), % (percent). A value is in double or single quotes and may
contain the other kind of quote, but not its own; there are no escapes.

## Usage

``` r
parse_put_annotation(line)
```

## Arguments

- line:

  Character string containing a PUT annotation

## Value

Named list containing all extracted properties, or NULL if invalid.
Pairs that could not be read are listed in its attribute `unparsed`.
