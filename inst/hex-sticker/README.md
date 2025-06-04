# putior Hex Sticker

This directory contains both handcrafted and programmatically generated hex sticker assets for the putior package.

## Directory Structure

- `generated/` - Programmatically generated stickers using R/ggplot2
  - `create-hex.R` - Main script for generating hex stickers
  - `putior-hex-large.png` - High-resolution version (800x800, 300 DPI)
  - `putior-hex.png` - Standard web version (400x400, 150 DPI)  
  - `putior-hex-small.png` - Small badges/icons (200x200, 100 DPI)
- `handcrafted/` - Original hand-designed versions
  - `putior.drawio` - Draw.io source file
  - `putior.drawio.png` - PNG export from Draw.io
  - `putior.drawio.svg` - SVG export from Draw.io
- `README.md` - This documentation file

## Usage

### Generate all variants

```r
source("generated/create-hex.R")
```

This creates three versions:
- `putior-hex-large.png` (800x800, 300 DPI) - High-res for print
- `putior-hex.png` (400x400, 150 DPI) - Standard web version  
- `putior-hex-small.png` (200x200, 100 DPI) - Small badges/icons

### Generate custom version

```r
source("generated/create-hex.R")

create_putior_hex(
  output_path = "my-custom-hex.png",
  width = 600,
  height = 600,
  dpi = 200
)
```

## Design Elements

The hex sticker includes:

- **Hexagonal shape** with black border
- **Purple gradient background** (light to dark)
- **Document stack** with "# put" annotation text
- **Network visualization** with connected white nodes
- **"putior" typography** in white

## Dependencies

- `ggplot2` - Main plotting engine
- `grid` - For advanced graphics operations

## Reproducibility

This script uses only base R and ggplot2 to ensure maximum reproducibility. No external fonts, images, or specialized packages are required beyond standard ggplot2.

All design elements are created programmatically using geometric shapes and built-in graphics functions.