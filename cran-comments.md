## R CMD check results

0 errors | 0 warnings | 1 note

* checking CRAN incoming feasibility ... NOTE
  Maintainer: 'Philipp Thoss <ph.thoss@gmx.de>'
  New submission.

## Test environments

* local: Windows 11, R 4.5.2 — 0 errors, 0 warnings, 1 note
* win-builder: R-devel (2026-03-10 r89593 ucrt) — 0 errors, 0 warnings, 1 note (new submission)
* win-builder: R-release (4.5.2 Patched, 2026-02-13 r89426 ucrt) — 0 errors, 0 warnings, 1 note (new submission)
* R-hub v2:
  - linux (R-devel) — Status: OK
  - windows (R-devel) — Status: OK
  - ubuntu-release (R 4.5.2) — Status: OK
  - macos (R-devel) — cancelled (runner unavailability, not a package issue)
* GitHub Actions (R-CMD-check):
  - macOS-latest (release) — PASS
  - windows-latest (release) — PASS
  - ubuntu-latest (release) — PASS

## Update notes

This is an update from version 0.1.0 to 0.2.0.

### Major changes since 0.1.0

* **Breaking change**: `recursive` parameter now defaults to `TRUE` (was `FALSE`)
* Added support for 30+ programming languages with automatic comment syntax detection
* Added auto-annotation feature (`put_auto()`, `put_generate()`, `put_merge()`)
* Added 9 diagram themes including 4 colorblind-safe viridis themes
* Added custom theme API (`put_theme()`)
* Added block comment annotation support (`/* */`, `/** */`)
* Added MCP server integration for AI assistant tool exposure
* Added ACP server integration for inter-agent communication
* Added WGSL, Dockerfile, and Makefile language support

## Dependencies

This package has minimal dependencies, requiring only base R and the `tools` package.
All packages listed in Suggests are used conditionally with `requireNamespace()`.
