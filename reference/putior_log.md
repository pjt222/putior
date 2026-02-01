# Internal Logging Function

Logs messages at specified levels when the logger package is available.
Silently does nothing if logger is not installed, ensuring the package
works without the optional dependency.

## Usage

``` r
putior_log(level, ..., .envir = parent.frame())
```

## Arguments

- level:

  Character string specifying log level: "DEBUG", "INFO", "WARN",
  "ERROR"

- ...:

  Message components passed to logger functions (supports glue-style
  interpolation)

- .envir:

  Environment for evaluating glue expressions (default: calling
  environment)

## Value

Invisible NULL
