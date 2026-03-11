# Set putior Log Level

Configure the logging verbosity for putior functions. Higher verbosity
levels provide more detailed information about internal operations,
which is useful for debugging annotation parsing, workflow detection,
and diagram generation.

## Usage

``` r
set_putior_log_level(level = "WARN")
```

## Arguments

- level:

  Character string specifying the log level:

  - "DEBUG" - Fine-grained internal operations (file-by-file, pattern
    matching)

  - "INFO" - Progress milestones (scan started, nodes found, diagram
    generated)

  - "WARN" - Issues that don't stop execution (validation issues,
    missing deps) - default

  - "ERROR" - Fatal issues (via existing stop() calls)

## Value

Invisibly returns the previous log level

## Examples

``` r
# Save current level, change, then restore
old_level <- set_putior_log_level("DEBUG")
getOption("putior.log_level")
#> [1] "DEBUG"
set_putior_log_level(old_level)
```
