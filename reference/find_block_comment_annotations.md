# Find PUT annotations inside block comments

Scans lines for PUT annotations that appear inside block comment regions
(e.g., `/* ... */` or `/** ... */`). Returns line indices of annotation
lines found inside blocks. Existing single-line annotations (found by
Pass 1) should be deduplicated by the caller.

## Usage

``` r
find_block_comment_annotations(lines, block_syntax)
```

## Arguments

- lines:

  Character vector of file lines

- block_syntax:

  Named list from
  [`get_block_comment_syntax()`](https://pjt222.github.io/putior/reference/get_block_comment_syntax.md)

## Value

Integer vector of line indices containing block PUT annotations
