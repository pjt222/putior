# CRAN Submission Guide

## Overview

This guide provides a complete walkthrough of the CRAN submission process for the putior package.

## Current Status

### Completed Steps

✅ **Package structure and documentation**
- [x] DESCRIPTION file complete with all required fields
- [x] NEWS.md created with version history
- [x] All functions documented with roxygen2
- [x] Vignette created and properly built (getting-started.Rmd)
- [x] Examples use `\dontrun{}` appropriately

✅ **Code quality**
- [x] R CMD check passes locally (Status: OK - 0 errors, 0 warnings, 0 notes)
- [x] Tests have good coverage (338 tests)
- [x] No problematic files (.RData, .Rhistory removed)
- [x] .Rbuildignore properly configured to exclude renv/
- [x] Vignettes build correctly with inst/doc directory

✅ **Platform testing**
- [x] Local Windows 11, R 4.5.0: Status OK
- [x] GitHub Actions CI (Windows, macOS, Ubuntu): All passing
- [x] Win-builder R-devel (2025-06-15 r88316): ✅ 1 NOTE (new submission)
- [x] Win-builder R-release (4.5.0): ✅ 1 NOTE (new submission)
- [x] R-hub v2 multi-platform checks: ✅ COMPLETED (4/5 platforms PASS, nosuggests expected fail)

✅ **Additional checks**
- [x] Spell check passes (WORDLIST updated)
- [x] URL check passes
- [x] cran-comments.md updated with latest results

## Test Environments

### Local Testing

**Platform**: Windows 11, R 4.5.0
**Status**: ✅ OK
**Results**: 0 errors, 0 warnings, 1 note (new submission)

### Win-builder

**R-devel (2025-06-15 r88316)**:
- Status: ✅ 1 NOTE (new submission only)
- URL: https://win-builder.r-project.org/v75QSLo869S1

**R-release (R 4.5.0)**:
- Status: ✅ 1 NOTE (new submission only)
- URL: https://win-builder.r-project.org/EIZ5hHdOpuJm

### GitHub Actions

**All passing**:
- macOS-latest (release)
- windows-latest (release)
- ubuntu-latest (release)

### R-hub v2 Checks

**Results**: https://github.com/pjt222/putior/actions/runs/15684902318

**Status**: ✅ COMPLETED

**Platforms**:
- ✅ linux (R-devel): PASS
- ✅ macos (R-devel): PASS
- ✅ windows (R-devel): PASS
- ✅ ubuntu-release: PASS
- ❌ nosuggests: EXPECTED FAIL (vignettes require rmarkdown from Suggests)

### R-hub nosuggests Check

The nosuggests check fails as expected because the package vignettes require rmarkdown (listed in Suggests). The package functions correctly without suggested packages installed - only vignette building is affected. This is standard behavior for packages with vignettes and does not impact package functionality.

## CRAN Submission Checklist

### Pre-Submission Checks

#### 1. Package Metadata

- [ ] DESCRIPTION file complete
  - Package name
  - Title (Title Case)
  - Version number
  - Authors with roles
  - Description
  - License
  - URL and BugReports
  - Imports and Suggests

- [ ] LICENSE file present
- [ ] NEWS.md updated with changes
- [ ] README.md comprehensive

#### 2. Documentation

- [ ] All exported functions documented
- [ ] Examples run without errors
- [ ] Vignettes build successfully
- [ ] No broken links in documentation

#### 3. Code Quality

- [ ] R CMD check passes (0 errors, 0 warnings, acceptable notes)
- [ ] All tests pass
- [ ] Spell check passes
- [ ] No problematic files (.RData, .Rhistory)

#### 4. Platform Testing

- [ ] Local testing complete
- [ ] Win-builder checks complete (R-devel and R-release)
- [ ] R-hub multi-platform checks complete
- [ ] GitHub Actions passing

#### 5. CRAN Comments

- [ ] cran-comments.md created
- [ ] Test environments documented
- [ ] R CMD check results documented
- [ ] Notes explained
- [ ] Resubmission notes (if applicable)

### Running Pre-Submission Checks

```r
# 1. Full package check
devtools::check(manual = TRUE, cran = TRUE)

# 2. Build package
devtools::build()

# 3. Check built package
# R CMD check putior_X.X.X.tar.gz

# 4. Spell check
devtools::spell_check()

# 5. URL check
urlchecker::url_check()

# 6. Win-builder checks
devtools::check_win_devel()
devtools::check_win_release()

# 7. R-hub checks
rhub::rhub_check()
```

## Submission Process

### 1. Prepare Package

```r
# Update version number in DESCRIPTION
# Update NEWS.md with changes
# Update cran-comments.md

# Final check
devtools::check(manual = TRUE, cran = TRUE)
```

### 2. Build Package

```r
# Build source package
devtools::build()

# This creates putior_X.X.X.tar.gz
```

### 3. Submit to CRAN

```r
# Use devtools::release() for guided submission
devtools::release()
```

This will:
1. Run final checks
2. Build the source package
3. Upload to CRAN's submission portal
4. Create a git tag for the release

**Alternative**: Manual submission via https://cran.r-project.org/submit.html

### 4. Respond to CRAN Feedback

**Timeline**: Usually within 24-48 hours (first submissions may take up to 2 weeks)

**Common requests**:
- Fix documentation issues
- Address policy violations
- Clarify package purpose
- Fix platform-specific issues

**Response guidelines**:
- Respond promptly (within 2 weeks)
- Be polite and professional
- Make requested changes
- Resubmit with explanation of changes

## Resubmission

### If Changes Required

1. **Make requested changes**
2. **Update version number** (if requested)
3. **Update cran-comments.md** with resubmission notes
4. **Run all checks again**
5. **Resubmit**

### Resubmission Template

Add to `cran-comments.md`:

```markdown
## Resubmission

This is a resubmission addressing reviewer feedback:

### Reviewer comments addressed:

1. **[Issue 1]**: [How you addressed it]
2. **[Issue 2]**: [How you addressed it]

### Changes made:

- [Change 1]
- [Change 2]
```

## Common CRAN Policy Requirements

### Title and Description

**Title**:
- Title Case
- No "package" or "R package"
- Descriptive and concise

**Description**:
- Complete sentences
- Software names in single quotes
- References with DOI if available

### Examples

**DO**:
- Use `\dontrun{}` for examples requiring user input
- Use `\donttest{}` for long-running examples
- Include working examples for all exported functions

**DON'T**:
- Write to user's home directory
- Modify user's R environment
- Require internet connection without checking

### Dependencies

**DO**:
- Minimize dependencies
- Use Imports for required packages
- Use Suggests for optional packages

**DON'T**:
- Include GitHub packages in Imports
- Add unnecessary dependencies

### File Management

**DO**:
- Write to tempdir() for temporary files
- Clean up after yourself
- Use proper file paths

**DON'T**:
- Write to user's home directory
- Leave temporary files
- Assume file paths

## Post-Submission

### After Acceptance

1. **Announce release**
   - Social media
   - R-bloggers
   - Package website

2. **Monitor feedback**
   - GitHub issues
   - Email feedback
   - CRAN checks

3. **Plan next release**
   - Feature requests
   - Bug fixes
   - Improvements

### Maintaining CRAN Package

**Regular checks**:
- Monitor CRAN check results
- Respond to CRAN emails promptly
- Update for R version changes
- Fix issues quickly

**Update frequency**:
- Bug fixes: As needed
- Minor updates: Every 3-6 months
- Major updates: Annually or as needed

**CRAN policies**:
- Respond to CRAN emails within 2 weeks
- Fix issues promptly
- Don't submit too frequently (wait at least 1-2 months between submissions)

## Troubleshooting

### Common Issues

#### 1. Vignette Build Failures

**Problem**: Vignettes don't build on CRAN

**Solution**:
- Ensure all vignette dependencies in Suggests
- Test with `devtools::build_vignettes()`
- Check Pandoc availability

#### 2. Platform-Specific Failures

**Problem**: Package fails on some platforms

**Solution**:
- Use `skip_on_os()` for platform-specific tests
- Avoid platform-specific code
- Test on multiple platforms

#### 3. Example Failures

**Problem**: Examples fail during check

**Solution**:
- Use `\dontrun{}` for examples requiring user input
- Use `\donttest{}` for long-running examples
- Test examples with `devtools::run_examples()`

#### 4. Dependency Issues

**Problem**: Missing or unavailable dependencies

**Solution**:
- Ensure all dependencies on CRAN
- Use `requireNamespace()` for optional dependencies
- Document system requirements

### Getting Help

**Resources**:
- CRAN Repository Policy: https://cran.r-project.org/web/packages/policies.html
- R Packages Book: https://r-pkgs.org/
- R-package-devel mailing list: https://stat.ethz.ch/mailman/listinfo/r-package-devel

**Community**:
- RStudio Community: https://community.rstudio.com/
- Stack Overflow: Tag `r-package`
- Twitter: #rstats

## Timeline

### First Submission

**Typical timeline**:
- Submission: Day 0
- Initial review: 1-3 days
- Feedback/acceptance: 3-14 days
- Publication: 1-2 days after acceptance

**Total**: 1-3 weeks for first submission

### Resubmission

**Typical timeline**:
- Resubmission: Day 0
- Review: 1-3 days
- Acceptance: 3-7 days
- Publication: 1-2 days after acceptance

**Total**: 1-2 weeks for resubmission

## Notes

### New Submission NOTE

```
* checking CRAN incoming feasibility ... NOTE
  Maintainer: 'Philipp Thoss <ph.thoss@gmx.de>'
  New submission
```

This NOTE is expected for first submissions and does not affect package functionality.

### Acceptable NOTEs

- New submission
- Package size (if reasonable)
- Examples with `\dontrun{}` (if necessary)

### Unacceptable NOTEs

- Misspelled words (fix with WORDLIST)
- Invalid URLs (fix or remove)
- Missing documentation
- Policy violations

## Package Purpose

putior helps users document and visualize workflows by extracting structured annotations from source code files and generating Mermaid diagrams. It supports multiple programming languages and is particularly useful for documenting data science pipelines.

## Dependencies

This package has minimal dependencies, requiring only base R and the tools package.

## Additional Resources

- **CRAN Repository Policy**: https://cran.r-project.org/web/packages/policies.html
- **Writing R Extensions**: https://cran.r-project.org/doc/manuals/r-release/R-exts.html
- **R Packages Book**: https://r-pkgs.org/
- **CRAN Submission Checklist**: https://github.com/ThinkR-open/prepare-for-cran
