# Asset Management

## Overview

This document describes the management of visual assets for the putior package, including hex stickers, logos, and favicons.

## Hex Sticker Organization

### Directory Structure

```
inst/hex-sticker/
├── handcrafted/          # Original Draw.io designs (PRIMARY)
│   ├── putior-hex.png
│   ├── putior-hex.svg
│   └── putior-hex.drawio
└── generated/            # R-generated stickers (DEVELOPMENT)
    ├── putior-hex-ggplot.png
    ├── putior-hex-ggplot.svg
    └── creation-scripts/
```

### Handcrafted Assets (Primary)

**Location**: `inst/hex-sticker/handcrafted/`

**Purpose**: Primary display assets for package

**Files**:
- `putior-hex.png` - PNG version for package logo
- `putior-hex.svg` - SVG version for scalability
- `putior-hex.drawio` - Original Draw.io design file

**Usage**:
- Main package logos: `man/figures/logo.png|svg`
- Favicon files: `pkgdown/favicon/`
- README header image
- Package website

**Design elements**:
- Hexagonal border with black outline
- Purple gradient background (darker at bottom, lighter at top)
- Network visualization with connected white nodes
- Document stack with "# put" annotations
- "putior" text in white at the bottom

**Why handcrafted**:
- Professional appearance
- Precise control over design
- Consistent with R package conventions
- Easy to edit and refine

### Generated Assets (Development)

**Location**: `inst/hex-sticker/generated/`

**Purpose**: Development and comparison purposes

**Files**:
- `putior-hex-ggplot.png` - ggplot2-generated version
- `putior-hex-ggplot.svg` - SVG version
- Creation scripts

**Usage**:
- Development experimentation
- Comparison with handcrafted version
- NOT used in production

**Generation method**: Pure ggplot2 approach

**Why not used in production**:
- Handcrafted version has better visual quality
- More control over fine details
- Easier to maintain consistency

## Package Logos

### Main Logo Files

**Location**: `man/figures/`

**Files**:
- `logo.png` - PNG version (139x160 pixels)
- `logo.svg` - SVG version (scalable)

**Source**: Uses handcrafted hex sticker design

**Usage**:
- README header: `<img src="man/figures/logo.png" align="right" height="139" alt="" />`
- Package documentation
- pkgdown website

**Specifications**:
- Format: PNG and SVG
- Dimensions: 139x160 pixels (PNG)
- Background: Transparent
- Colors: Match hex sticker design

### Favicon Files

**Location**: `pkgdown/favicon/`

**Files**:
- `favicon-16x16.png`
- `favicon-32x32.png`
- `apple-touch-icon.png`
- `favicon.ico`

**Source**: All use handcrafted hex sticker design

**Usage**: pkgdown website favicon

**Generation**:
```r
# Generate favicons from handcrafted hex sticker
pkgdown::build_favicons(pkg = ".", overwrite = TRUE)
```

## Hex Sticker Creation Methods

### Recommended Approach: Pure ggplot2

**Why ggplot2**:
- Complete control over all visual elements
- No additional dependencies beyond base ggplot2
- Can create gradient effects with layered polygons
- Easy to position multiple element types
- Familiar syntax for R users
- Version control friendly (pure R code)

**Implementation**: See `inst/examples/create-putior-hex.R`

### Alternative Approaches

#### hexSticker Package

**Pros**:
- Purpose-built for R package hex stickers
- Automatic hexagon shape and border handling
- Built-in font management
- Standard dimensions

**Cons**:
- Limited flexibility for complex custom layouts
- Gradient backgrounds require workarounds
- Additional dependency

**When to use**: Standard hex stickers with single central plot

#### Grid Graphics

**Pros**:
- Maximum low-level control
- True gradient support with `linearGradient()`
- Precise positioning

**Cons**:
- Steep learning curve
- Very verbose code
- Not familiar to most R users

**When to use**: Exact replications of complex designs

### Hybrid Approaches

**ggplot2 + hexSticker**:
```r
complex_plot <- create_putior_elements()  # ggplot2
sticker(complex_plot, package = "putior", ...)
```

**Multiple packages**:
- ggraph - Network visualization
- ggforce - Additional geometric shapes
- patchwork - Combine multiple plot elements

## Design Specifications

### Color Palette

**Background**:
- Primary: `#6B5B95` (purple)
- Gradient: Darker at bottom, lighter at top

**Border**:
- Color: `#000000` (black)
- Width: 2px

**Elements**:
- Nodes: `#FFFFFF` (white)
- Connections: `#FFFFFF` (white)
- Text: `#FFFFFF` (white)

### Typography

**Package name**: "putior"
- Font: Sans-serif
- Color: White
- Position: Bottom of hexagon

**Annotations**: "# put"
- Font: Monospace
- Color: White
- Position: On document icons

### Dimensions

**Hex sticker**:
- Standard size: 2" x 2"
- Resolution: 300 DPI minimum

**Package logo**:
- PNG: 139x160 pixels
- SVG: Scalable

**Favicons**:
- 16x16 pixels
- 32x32 pixels
- 180x180 pixels (Apple touch icon)

## Asset Creation Workflow

### Creating New Hex Sticker

1. **Design in Draw.io** (recommended):
   - Open `inst/hex-sticker/handcrafted/putior-hex.drawio`
   - Make design changes
   - Export as PNG and SVG
   - Save to `inst/hex-sticker/handcrafted/`

2. **Generate with R** (alternative):
   - Use `inst/examples/create-putior-hex.R`
   - Adjust colors and positions
   - Save to `inst/hex-sticker/generated/`

3. **Update package logos**:
   ```r
   # Copy to man/figures/
   file.copy("inst/hex-sticker/handcrafted/putior-hex.png", 
             "man/figures/logo.png", overwrite = TRUE)
   file.copy("inst/hex-sticker/handcrafted/putior-hex.svg", 
             "man/figures/logo.svg", overwrite = TRUE)
   ```

4. **Generate favicons**:
   ```r
   pkgdown::build_favicons(pkg = ".", overwrite = TRUE)
   ```

5. **Commit changes**:
   ```bash
   git add inst/hex-sticker/ man/figures/ pkgdown/favicon/
   git commit -m "Update hex sticker and logos"
   ```

### Updating Existing Assets

1. **Edit source file**:
   - Handcrafted: Edit `.drawio` file
   - Generated: Edit R script

2. **Export new versions**:
   - PNG for package use
   - SVG for scalability

3. **Update all locations**:
   - `inst/hex-sticker/`
   - `man/figures/`
   - `pkgdown/favicon/`

4. **Test appearance**:
   - README rendering
   - pkgdown website
   - Package documentation

## Asset Usage Guidelines

### README

```markdown
# putior <img src="man/figures/logo.png" align="right" height="139" alt="" />
```

**Best practices**:
- Use PNG for README
- Align right
- Set height to 139 pixels
- Include empty alt text for decorative image

### pkgdown Website

**Configuration** (`_pkgdown.yml`):
```yaml
home:
  title: putior
  description: Extract beautiful workflow diagrams from your code annotations
  
navbar:
  title: putior
  icon: man/figures/logo.png
```

**Favicon**: Automatically used from `pkgdown/favicon/`

### Package Documentation

**DESCRIPTION**:
```
URL: https://pjt222.github.io/putior/, https://github.com/pjt222/putior
BugReports: https://github.com/pjt222/putior/issues
```

**Logo display**: Automatically shown in pkgdown site

## Version Control

### Files to Commit

**DO commit**:
- Handcrafted source files (`.drawio`)
- Final PNG and SVG files
- Package logos (`man/figures/`)
- Favicons (`pkgdown/favicon/`)
- Creation scripts

**DON'T commit**:
- Temporary files
- Intermediate versions
- Large uncompressed files

### .gitignore

Ensure these patterns are NOT in `.gitignore`:
```
# Keep package assets
!man/figures/*.png
!man/figures/*.svg
!inst/hex-sticker/**/*.png
!inst/hex-sticker/**/*.svg
!pkgdown/favicon/*.png
!pkgdown/favicon/*.ico
```

### .Rbuildignore

Exclude development files from package builds:
```
^inst/hex-sticker/generated/
^inst/examples/create-putior-hex\.R$
^inst/examples/hex-sticker-.*\.R$
^inst/examples/hex-sticker-.*\.md$
```

## Documentation

### Hex Sticker Documentation

**Location**: `inst/examples/`

**Files**:
- `hex-sticker-comparison.md` - Method comparison
- `hex-sticker-recommendations.md` - Recommendations
- `hex-sticker-research.R` - Research and examples
- `create-putior-hex.R` - Production implementation

**Purpose**:
- Document design decisions
- Provide examples for future updates
- Compare different approaches
- Maintain institutional knowledge

### Design Rationale

**Why this design**:
- Represents workflow visualization (network)
- Shows code annotations (documents with "# put")
- Professional appearance
- Consistent with R package conventions
- Memorable and distinctive

**Color choices**:
- Purple: Professional, creative, technical
- White: Clean, clear, readable
- Black: Strong contrast, professional

## Best Practices

### Asset Management

**DO**:
- Keep source files in version control
- Document design decisions
- Use consistent file naming
- Maintain both PNG and SVG versions
- Test appearance in all contexts

**DON'T**:
- Delete source files
- Use inconsistent dimensions
- Forget to update all locations
- Skip documentation
- Commit temporary files

### Design Updates

**DO**:
- Make changes to source files first
- Export to all required formats
- Update all locations
- Test in all contexts
- Document changes

**DON'T**:
- Edit exported files directly
- Update only some locations
- Skip testing
- Forget to commit changes

### Quality Control

**Check**:
- Visual appearance in README
- pkgdown website rendering
- Favicon display in browsers
- Logo clarity at different sizes
- Color consistency across formats

## Additional Resources

### Hex Sticker Design

- **hexSticker package**: https://github.com/GuangchuangYu/hexSticker
- **R Package Hex Stickers**: https://github.com/rstudio/hex-stickers
- **Hex Sticker Guidelines**: http://hexb.in/sticker.html

### Design Tools

- **Draw.io**: https://www.drawio.com/
- **Inkscape**: https://inkscape.org/ (SVG editing)
- **GIMP**: https://www.gimp.org/ (PNG editing)

### Color Resources

- **Coolors**: https://coolors.co/ (color palette generator)
- **Adobe Color**: https://color.adobe.com/ (color wheel)
- **Material Design Colors**: https://materialui.co/colors

### R Graphics

- **ggplot2**: https://ggplot2.tidyverse.org/
- **grid graphics**: https://www.stat.auckland.ac.nz/~paul/RG2e/
- **R Graphics Cookbook**: https://r-graphics.org/
