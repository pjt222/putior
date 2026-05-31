## Submission type

This is a minor-version update from putior 0.1.0 (on CRAN since 2025-06-19) to
0.2.0. It is **not** a new submission.

## R CMD check results

Local (Windows 11, R 4.5.2), `R CMD check --as-cran` on a freshly built
`putior_0.2.0.tar.gz` with all Suggests installed:

0 errors | 0 warnings | 0 notes

All checks pass, including examples, the full test suite, and re-building of all
vignettes. (The PDF-manual rendering step requires a LaTeX installation that is
not present on this local machine; it is exercised on win-builder, below.)

## Test environments

* Local: Windows 11, R 4.5.2 — OK
* win-builder: R-devel and R-release — checked for this 0.2.0 cycle
* R-hub v2: linux (R-devel), windows (R-devel), ubuntu (R-release)

(Replace the win-builder / R-hub lines with the concrete results/URLs from the
0.2.0 check runs before submitting.)

## Reverse dependencies

There are no reverse dependencies
(`tools::package_dependencies("putior", reverse = TRUE)` returns none).

## Summary of changes since 0.1.0

See NEWS.md for the full list. Highlights:

* Breaking change: the `recursive` argument now defaults to `TRUE` (was `FALSE`)
  in `put()`, `put_auto()`, `put_generate()`, and `put_merge()`.
* Support for 30+ programming languages with automatic comment-syntax detection.
* Auto-annotation: `put_auto()`, `put_generate()`, `put_merge()`.
* 9 diagram themes, including 4 colorblind-safe viridis themes, plus a custom
  theme API (`put_theme()`).
* Block-comment annotation support (`/* */`, `/** */`).
* Optional MCP and ACP server integrations (all guarded by `requireNamespace()`).
* WGSL, Dockerfile, and Makefile language support.

## Dependencies

Imports only base R and the `tools` package. All packages in Suggests are used
conditionally via `requireNamespace()` and are available on CRAN.
