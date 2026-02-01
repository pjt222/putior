# Get Comment Syntax Group for Extension

Returns the name of the comment syntax group for a given file extension.

## Usage

``` r
get_comment_group(ext)
```

## Arguments

- ext:

  Character string of the file extension (without dot)

## Value

Character string of the group name ("hash", "dash", "slash", "percent"),
or "hash" if not found (default)
