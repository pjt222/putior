## Submission type

This is a minor-version update from putior 0.1.0 (on CRAN since 2025-06-19) to
0.2.0. It is **not** a new submission.

## R CMD check results

Local (Windows 11, R 4.6.1), `R CMD check --as-cran` on a freshly built
`putior_0.2.0.tar.gz` with all Suggests installed, including the PDF manual,
without the remote incoming checks (`_R_CHECK_CRAN_INCOMING_REMOTE_=FALSE`):

0 errors | 0 warnings | 0 notes (2026-10-14, at e051eba)

## Test environments

* Local: Windows 11, R 4.6.1 — 0 errors | 0 warnings | 0 notes
* win-builder: R-devel and R-release (TODO: results and URLs; submitted only
  after the maintainer's go)
* GitHub Actions: ubuntu-latest (R-devel, R-release), macos-latest
  (R-release), windows-latest (R-release): OK

## URL check

README.md links to https://deepwiki.com/pjt222/putior (an "Ask DeepWiki"
badge). The site answers automated requests with a bot challenge (HTTP 429),
so the URL check may report "429 Too Many Requests" for it; the link works in
a browser.

## Reverse dependencies

There are no reverse dependencies
(`tools::package_dependencies("putior", reverse = TRUE)` returns none).

## Summary of changes since 0.1.0

See NEWS.md for the full list. Highlights:

* Breaking changes: the `recursive` argument now defaults to `TRUE` (was
  `FALSE`) in `put()`, `put_auto()`, `put_generate()` and `put_merge()`.
  `put_diagram()` output starts with a Mermaid frontmatter block that keeps
  the classic look on Mermaid 12 renderers, carries `accTitle`/`accDescr`
  for screen readers, and draws each data hop once with
  `show_artifacts = TRUE`. Each change has an argument for the old output.
* Support for 30+ programming languages with automatic comment-syntax
  detection, and auto-annotation: `put_auto()`, `put_generate()`,
  `put_merge()`.
* Diagram labels, titles and click links are escaped so that Mermaid shows
  them as written; `put_diagram()` warns where Mermaid cannot (a `<` in the
  title, a `<` that starts an HTML tag in a label, diagrams over Mermaid's
  size limits).
* 9 diagram themes, including 4 colorblind-safe viridis themes, plus a custom
  theme API (`put_theme()`).
* Optional MCP and ACP server integrations (all guarded by
  `requireNamespace()`). Over HTTP, both servers scan only a given root
  folder, and a server that other machines can reach needs a token.

## Dependencies

Imports only base R and the `tools` package. All packages in Suggests are on
CRAN:

* The package code uses clipr, uuid, logger, shiny, shinyAce, mcptools,
  ellmer, plumber2 and openssl only after `requireNamespace()`. jsonlite is
  used by the MCP tools, which need ellmer, which imports jsonlite.
* knitr and rmarkdown build the vignettes.
* testthat, curl and later are used by the tests only.
* pkgdown builds the package website; the package code does not use it.
