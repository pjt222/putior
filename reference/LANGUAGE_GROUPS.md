# Language Groups by Comment Syntax

A list defining programming languages grouped by their single-line
comment syntax. Each group contains the comment prefix, supported file
extensions, and language names.

## Usage

``` r
LANGUAGE_GROUPS
```

## Format

A named list with four groups:

- hash:

  Languages using `#` for comments (R, Python, Shell, etc.)

- dash:

  Languages using `--` for comments (SQL, Lua, Haskell)

- slash:

  Languages using `//` for comments (JavaScript, C, Go, etc.)

- percent:

  Languages using `%` for comments (MATLAB, LaTeX)
