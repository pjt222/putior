# Contributing to putior

Thank you for your interest in contributing to putior! This document
provides guidelines for contributing to the project.

## Reporting Bugs

Open an issue at
[github.com/pjt222/putior/issues](https://github.com/pjt222/putior/issues)
with:

- A minimal reproducible example
- Your R version
  ([`sessionInfo()`](https://rdrr.io/r/utils/sessionInfo.html))
- The putior version (`packageVersion("putior")`)
- Expected vs actual behavior

## Feature Proposals

Before starting work on a new feature, please open an issue to discuss
the idea. This helps avoid duplicate effort and ensures the feature fits
the package’s scope.

## Pull Request Guidelines

1.  **Fork and branch**: Create a feature branch from `main` (e.g.,
    `feature/my-improvement`)
2.  **Follow existing style**: Match the coding patterns in the existing
    codebase
3.  **Document**: Add roxygen2 documentation for any new exported
    functions
4.  **Test**: Add testthat tests for new functionality (aim for \>80%
    coverage)
5.  **Check**: Run `devtools::check()` and ensure 0 errors, 0 warnings
6.  **Describe**: Write a clear PR description explaining the “why”
    behind your changes

## Development Setup

``` bash
git clone https://github.com/pjt222/putior.git
cd putior
```

``` r
# Install development dependencies
devtools::install_dev_deps()

# Load package for development
devtools::load_all()

# Run tests
devtools::test()

# Full package check
devtools::check()
```

## Documentation

- Use roxygen2 for function documentation
- Update vignettes if your change affects user-facing behavior
- Run `devtools::document()` to regenerate man pages

## Code of Conduct

This project follows the [Contributor Covenant Code of
Conduct](https://pjt222.github.io/putior/CODE_OF_CONDUCT.md). By
participating, you agree to uphold this code.
