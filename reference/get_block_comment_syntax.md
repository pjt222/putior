# Get Block Comment Syntax for File Extension

Returns the block comment delimiters for languages that support them.
Returns NULL for languages without block comment support.

## Usage

``` r
get_block_comment_syntax(ext)
```

## Arguments

- ext:

  Character string of the file extension (without dot)

## Value

Named list with `block_open`, `block_close`, and `block_line_prefix`, or
NULL if the language has no block comments.
