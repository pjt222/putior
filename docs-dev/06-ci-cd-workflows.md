# CI/CD Workflows

## Overview

This document describes the continuous integration and deployment workflows for the putior package using GitHub Actions.

## Workflow Files

All workflow files are located in `.github/workflows/`:

- `r.yml` - R CMD check on multiple platforms
- `pkgdown-gh-pages.yaml` - Documentation deployment
- `rhub.yaml` - R-hub platform checks
- `claude.yml` - Claude Code integration

## R CMD Check Workflow

### File: `r.yml`

**Purpose**: Run R CMD check on multiple platforms

**Triggers**:
- Push to main branch
- Pull requests
- Manual workflow dispatch

**Platforms tested**:
- macOS-latest (release)
- windows-latest (release)
- ubuntu-latest (release)

**Steps**:
1. Checkout repository
2. Setup R environment
3. Install dependencies
4. Run R CMD check
5. Upload check results

**Configuration**:
```yaml
name: R-CMD-check

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]
  workflow_dispatch:

jobs:
  R-CMD-check:
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        os: [macOS-latest, windows-latest, ubuntu-latest]
    
    steps:
      - uses: actions/checkout@v4
      - uses: r-lib/actions/setup-r@v2
      - uses: r-lib/actions/setup-r-dependencies@v2
      - uses: r-lib/actions/check-r-package@v2
```

**Status**: ✅ All platforms passing

## pkgdown GitHub Pages Deployment

### File: `pkgdown-gh-pages.yaml`

**Purpose**: Build and deploy package documentation website

**Triggers**:
- Push to main branch
- Manual workflow dispatch

**Deployment method**: Branch-based deployment from `gh-pages` branch

**Steps**:
1. Checkout repository
2. Setup R environment
3. Install dependencies
4. Build pkgdown site with `pkgdown::build_site_github_pages()`
5. Deploy to `gh-pages` branch using JamesIves/github-pages-deploy-action

**Configuration**:
```yaml
name: pkgdown

on:
  push:
    branches: [ main ]
  workflow_dispatch:

jobs:
  pkgdown:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      - uses: r-lib/actions/setup-r@v2
      - uses: r-lib/actions/setup-r-dependencies@v2
        with:
          extra-packages: any::pkgdown
      - name: Build site
        run: pkgdown::build_site_github_pages()
        shell: Rscript {0}
      - name: Deploy to GitHub Pages
        uses: JamesIves/github-pages-deploy-action@v4
        with:
          folder: docs
          branch: gh-pages
```

**Site URL**: https://pjt222.github.io/putior/

**Important settings**:

**_pkgdown.yml**:
```yaml
# Development mode must be disabled for proper root-level deployment
# development:
#   mode: auto
```

**GitHub Pages Settings**:
- Deploy from `gh-pages` branch (NOT GitHub Actions)
- Source: Deploy from a branch
- Branch: gh-pages
- Folder: / (root)

**Status**: ✅ Deployed and live

### Deployment Workflow

1. Changes pushed to main branch trigger `pkgdown-gh-pages` workflow
2. Workflow builds pkgdown site with `pkgdown::build_site_github_pages()`
3. JamesIves/github-pages-deploy-action deploys `docs/` folder to `gh-pages` branch
4. GitHub Pages serves the site from `gh-pages` branch root

### Troubleshooting

**404 Error**:
- Check if development mode is enabled in `_pkgdown.yml` (causes site to build in `dev/` subdirectory)
- Ensure GitHub Pages is set to deploy from `gh-pages` branch, not GitHub Actions

**Deployment Issues**:
- Ensure GitHub Pages is set to deploy from `gh-pages` branch
- Check workflow logs for pkgdown build errors

**Build Failures**:
- Check workflow logs for pkgdown build errors
- Verify all dependencies are available
- Test locally with `pkgdown::build_site()`

## R-hub Platform Checks

### File: `rhub.yaml`

**Purpose**: Run comprehensive platform checks using R-hub v2

**Triggers**:
- Manual workflow dispatch
- Can be triggered from R with `rhub::rhub_check()`

**Platforms tested**:
- linux (R-devel)
- macos (R-devel)
- windows (R-devel)
- ubuntu-release
- nosuggests (expected to fail for packages with vignettes)

**Configuration**:
```yaml
name: R-hub

on:
  workflow_dispatch:

jobs:
  rhub:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      - uses: r-lib/actions/setup-r@v2
      - name: Run R-hub checks
        run: |
          install.packages("rhub")
          rhub::rhub_check()
        shell: Rscript {0}
```

**Results**: https://github.com/pjt222/putior/actions/runs/15684902318

**Status**: ✅ 4/5 platforms PASS (nosuggests expected fail)

### Running R-hub Checks

**From R**:
```r
# Install rhub
install.packages("rhub")

# Run checks
rhub::rhub_check()
```

**From GitHub**:
1. Go to Actions tab
2. Select "R-hub" workflow
3. Click "Run workflow"

## Claude Code Integration

### File: `claude.yml`

**Purpose**: Enable Claude Code integration for AI-assisted development

**Triggers**:
- Issue comments containing `@claude`
- Pull request review comments containing `@claude`
- Pull request reviews containing `@claude`
- Issues opened or assigned containing `@claude`

**Configuration**:
```yaml
name: Claude Code

on:
  issue_comment:
    types: [created]
  pull_request_review_comment:
    types: [created]
  issues:
    types: [opened, assigned]
  pull_request_review:
    types: [submitted]

jobs:
  claude:
    if: |
      (github.event_name == 'issue_comment' && contains(github.event.comment.body, '@claude')) ||
      (github.event_name == 'pull_request_review_comment' && contains(github.event.comment.body, '@claude')) ||
      (github.event_name == 'pull_request_review' && contains(github.event.review.body, '@claude')) ||
      (github.event_name == 'issues' && (contains(github.event.issue.body, '@claude') || contains(github.event.issue.title, '@claude')))
    runs-on: ubuntu-latest
    permissions:
      contents: read
      pull-requests: write
      issues: write
      id-token: write
    
    steps:
      - name: Checkout repository
        uses: actions/checkout@v4
        with:
          fetch-depth: 1
      
      - name: Run Claude Code
        id: claude
        uses: anthropics/claude-code-action@beta
        with:
          anthropic_api_key: ${{ secrets.ANTHROPIC_API_KEY }}
          github_token: ${{ secrets.GITHUB_TOKEN }}
```

**Required secrets**:
- `ANTHROPIC_API_KEY` - Anthropic API key for Claude
- `GITHUB_TOKEN` - Automatically provided by GitHub

**Status**: ✅ Configured and active

## Conditional Package Loading

### Problem

GitHub Actions may fail if development dependencies (like mcptools) aren't available.

### Solution

Use conditional loading with `requireNamespace()` in `.Rprofile`:

```r
if (file.exists("renv/activate.R")) {
  source("renv/activate.R")
}

# Load acquaint MCP session if package is available (for development)
if (requireNamespace("acquaint", quietly = TRUE)) {
  acquaint::mcp_session()
}
```

**Benefits**:
- Doesn't fail if package unavailable
- Works in CI/CD environments
- Allows development tools without breaking builds

### Best Practices

**DO**:
- Use `requireNamespace()` for optional dependencies
- Fail gracefully if dependencies unavailable
- Keep development tools separate from package dependencies

**DON'T**:
- Include development-only tools in DESCRIPTION
- Assume all dependencies available in CI/CD
- Use `library()` for optional dependencies

## Secrets Management

### Required Secrets

**ANTHROPIC_API_KEY**:
- Purpose: Claude Code integration
- Setup: GitHub repository settings → Secrets and variables → Actions → New repository secret

**GITHUB_TOKEN**:
- Purpose: GitHub API access
- Setup: Automatically provided by GitHub (no setup needed)

### Adding Secrets

1. Go to repository settings
2. Navigate to "Secrets and variables" → "Actions"
3. Click "New repository secret"
4. Add secret name and value
5. Click "Add secret"

## Workflow Status Badges

Add to README.md:

```markdown
[![R CMD check](https://github.com/pjt222/putior/workflows/R-CMD-check/badge.svg)](https://github.com/pjt222/putior/actions)
[![pkgdown](https://github.com/pjt222/putior/workflows/pkgdown/badge.svg)](https://github.com/pjt222/putior/actions)
```

## Monitoring Workflows

### GitHub Actions Dashboard

1. Go to repository
2. Click "Actions" tab
3. View workflow runs
4. Click on individual runs for details

### Email Notifications

GitHub sends email notifications for:
- Workflow failures
- First workflow run
- Workflow re-enabled after being disabled

### Status Checks

**Required status checks** (recommended):
- R-CMD-check
- pkgdown (optional)

**Setup**:
1. Go to repository settings
2. Navigate to "Branches"
3. Add branch protection rule for main
4. Enable "Require status checks to pass before merging"
5. Select required checks

## Troubleshooting

### Workflow Failures

**Check logs**:
1. Go to Actions tab
2. Click on failed workflow run
3. Expand failed step
4. Review error messages

**Common issues**:
- Missing dependencies
- Platform-specific failures
- Timeout issues
- Permission issues

### Dependency Issues

**Problem**: Dependencies fail to install

**Solution**:
- Check DESCRIPTION for correct dependencies
- Verify dependencies available on CRAN
- Use `r-lib/actions/setup-r-dependencies@v2`

### Platform-Specific Failures

**Problem**: Tests pass locally but fail on CI/CD

**Solution**:
- Use `skip_on_os()` for platform-specific tests
- Check file path handling (Windows vs Unix)
- Verify platform-specific code

### Timeout Issues

**Problem**: Workflow times out

**Solution**:
- Reduce test complexity
- Use caching for dependencies
- Split into multiple workflows

## Best Practices

### Workflow Design

**DO**:
- Use official GitHub Actions when available
- Cache dependencies to speed up builds
- Run checks on multiple platforms
- Use matrix builds for efficiency

**DON'T**:
- Run unnecessary steps
- Install dependencies manually
- Ignore workflow failures
- Skip platform testing

### Security

**DO**:
- Use secrets for sensitive data
- Limit workflow permissions
- Review third-party actions
- Keep actions up to date

**DON'T**:
- Commit secrets to repository
- Use overly broad permissions
- Trust unverified actions
- Ignore security warnings

### Maintenance

**Regular tasks**:
- Update action versions
- Review workflow logs
- Monitor build times
- Update dependencies

**When to update**:
- Security vulnerabilities
- New R versions
- Breaking changes in actions
- Performance improvements

## GitHub Pages Deployment Review (January 2026)

### Verification Checklist

| Check | Command | Expected Result |
|-------|---------|-----------------|
| gh-pages branch exists | `git branch -r \| grep gh-pages` | `origin/gh-pages` |
| Workflow succeeds | `gh run list --workflow=pkgdown-gh-pages` | All runs show `success` |
| Site returns HTTP 200 | `curl -sI https://pjt222.github.io/putior/ \| head -1` | `HTTP/2 200` |
| Development mode disabled | Check `_pkgdown.yml` lines 217-219 | Commented out |

### Critical Success Factors

1. **Development Mode Must Be Disabled**
   ```yaml
   # _pkgdown.yml - This MUST be commented out
   # development:
   #   mode: auto
   ```
   When enabled, pkgdown builds the site in a `/dev/` subdirectory, causing 404 errors for root-level GitHub Pages deployment.

2. **Branch-Based Deployment**
   - Uses `JamesIves/github-pages-deploy-action@v4`
   - Deploys to `gh-pages` branch (not GitHub Actions deployment)
   - `clean: true` ensures fresh deployments without stale files

3. **GitHub Pages Settings**
   - Source: "Deploy from a branch"
   - Branch: `gh-pages`
   - Folder: `/ (root)`

### Configuration Files Summary

| File | Purpose | Key Setting |
|------|---------|-------------|
| `_pkgdown.yml` | Site configuration | Development mode disabled |
| `.github/workflows/pkgdown-gh-pages.yaml` | CI/CD workflow | Branch deployment to gh-pages |
| `.Rbuildignore` | Package build exclusions | `^docs$` excluded |
| `.github/workflows/pkgdown.yaml.disabled` | Archived workflow | Preserved for reference |

### Deployment Flow

```
Push to main → pkgdown-gh-pages workflow triggers
    ↓
Build site with pkgdown::build_site_github_pages()
    ↓
Deploy docs/ to gh-pages branch
    ↓
GitHub Pages serves from gh-pages root
    ↓
Site live at https://pjt222.github.io/putior/
```

### Why Branch-Based Over Actions Deployment?

| Aspect | Branch-Based | Actions Deployment |
|--------|-------------|-------------------|
| Reliability | More predictable | Can have config conflicts |
| Debugging | Easy to inspect gh-pages branch | Artifacts less accessible |
| Rollback | `git revert` on gh-pages | Re-run previous workflow |
| Setup | Slightly more steps | Newer, fewer steps |

Branch-based deployment was chosen for this package due to its reliability and ease of troubleshooting.

## Additional Resources

- **GitHub Actions Documentation**: https://docs.github.com/en/actions
- **r-lib/actions**: https://github.com/r-lib/actions
- **pkgdown**: https://pkgdown.r-lib.org/
- **R-hub**: https://r-hub.github.io/rhub/
- **GitHub Pages Troubleshooting**: See `development-guides/pkgdown-github-pages-deployment.md`
