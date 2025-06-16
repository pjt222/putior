## R CMD check results

0 errors | 0 warnings | 1 note

* checking CRAN incoming feasibility ... NOTE
  Maintainer: 'Philipp Thoss <ph.thoss@gmx.de>'
  New submission

This NOTE is expected for first submissions and does not affect package functionality.

## Test environments

* local: Windows 11, R 4.5.0 - Status: ✅ OK
* win-builder: R-devel (2025-06-15 r88316) - Status: ✅ 1 NOTE (new submission only) 
* win-builder: R-release (R 4.5.0) - Status: ✅ 1 NOTE (new submission only)
* GitHub Actions (all passing): 
  - macOS-latest (release)
  - windows-latest (release)  
  - ubuntu-latest (release)
* R-hub v2 checks (completed):
  - linux (R-devel): ✅ PASS
  - macos (R-devel): ✅ PASS  
  - windows (R-devel): ✅ PASS
  - ubuntu-release: ✅ PASS
  - nosuggests: ❌ EXPECTED FAIL (vignettes require rmarkdown from Suggests)

## R-hub nosuggests check

The nosuggests check fails as expected because the package vignettes require rmarkdown (listed in Suggests). The package functions correctly without suggested packages installed - only vignette building is affected. This is standard behavior for packages with vignettes and does not impact package functionality.

## Resubmission

This is a resubmission addressing reviewer feedback:

### Reviewer comments addressed:

1. **Title formatting**: Already correct with Title Case in quotes
2. **Package names**: All software names ('R', 'Python', 'PUT', 'Mermaid') properly formatted in single quotes
3. **References**: Academic references already included with proper DOI formatting
4. **Unexported function examples**: Removed examples from internal function `parse_put_annotation()` by regenerating documentation

### Changes made:
- Regenerated package documentation to remove examples from unexported functions
- Verified all CRAN policy requirements are met

## Package purpose

putior helps users document and visualize workflows by extracting structured annotations from source code files and generating Mermaid diagrams. It supports multiple programming languages and is particularly useful for documenting data science pipelines.

## Dependencies

This package has minimal dependencies, requiring only base R and the tools package.