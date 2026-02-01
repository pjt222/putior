# Temporarily Set Log Level for a Code Block

Internal helper for temporarily setting log level during function
execution. Restores the previous level when done.

## Usage

``` r
with_log_level(level)
```

## Arguments

- level:

  Character string specifying the temporary log level

## Value

A function that restores the original level when called

## See also

[`set_putior_log_level`](https://pjt222.github.io/putior/reference/set_putior_log_level.md)
for the public interface

## Examples

``` r
if (FALSE) { # \dontrun{
# Temporarily increase log level
reset_level <- with_log_level("DEBUG")
on.exit(reset_level(), add = TRUE)
# ... code with DEBUG logging ...
} # }
```
