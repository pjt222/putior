# Reproducible Hex Sticker Generation for putior
# 
# This script recreates the putior hex sticker design using pure ggplot2
# for maximum reproducibility and maintainability.

library(ggplot2)
library(grid)

#' Create the putior hex sticker
#' 
#' Generates the putior package hex sticker with all design elements:
#' - Purple gradient background
#' - Document icons with "# put" annotation
#' - Network visualization with connected nodes
#' - Package name typography
#' 
#' @param output_path Path where to save the hex sticker (PNG format)
#' @param width Width in pixels (default: 400)
#' @param height Height in pixels (default: 400) 
#' @param dpi DPI for output (default: 300)
#' @return Invisible ggplot object
create_putior_hex <- function(output_path = "putior-hex.png", 
                              width = 400, 
                              height = 400, 
                              dpi = 300) {
  
  # Hex sticker dimensions and positioning
  hex_size <- 1.0
  center_x <- 0
  center_y <- 0
  
  # Create hexagon coordinates
  create_hexagon <- function(center_x = 0, center_y = 0, size = 1) {
    angles <- seq(0, 2*pi, length.out = 7)
    data.frame(
      x = center_x + size * cos(angles),
      y = center_y + size * sin(angles)
    )
  }
  
  hex_coords <- create_hexagon(center_x, center_y, hex_size)
  
  # Color palette (from SVG: rgb(187, 173, 225) to rgb(0, 0, 0))
  colors <- list(
    bg_light = "#BBADE1",  # Light purple (top) - exact SVG color
    bg_dark = "#6B5B95",   # Mid purple 
    bg_black = "#000000",  # Black (bottom) - exact SVG color
    border = "#000000",    # Black border (exact SVG)
    white = "#FFFFFF",     # White for text and elements
    gray = "#8C8C8C"       # Gray for "# put" text (exact SVG)
  )
  
  # Create base plot
  p <- ggplot() +
    # Set coordinate system and limits
    coord_fixed(ratio = 1) +
    xlim(-1.3, 1.3) +
    ylim(-1.3, 1.3) +
    theme_void() +
    theme(
      plot.background = element_rect(fill = "transparent", color = NA),
      panel.background = element_rect(fill = "transparent", color = NA),
      plot.margin = margin(0, 0, 0, 0)
    )
  
  # Add gradient background using multiple layers
  gradient_layers <- 15
  for (i in 1:gradient_layers) {
    alpha_val <- 0.15
    y_offset <- (i - gradient_layers/2) * 0.15
    
    # Interpolate color from light to dark based on position
    color_mix <- i / gradient_layers
    if (color_mix < 0.3) {
      fill_color <- colors$bg_light
    } else if (color_mix < 0.7) {
      fill_color <- colors$bg_dark
    } else {
      fill_color <- colors$bg_black
    }
    
    p <- p + 
      geom_polygon(
        data = hex_coords,
        aes(x = x, y = y + y_offset * 0.1),
        fill = fill_color,
        alpha = alpha_val,
        color = NA
      )
  }
  
  # Add main hexagon border
  p <- p + 
    geom_polygon(
      data = hex_coords,
      aes(x = x, y = y),
      fill = NA,
      color = colors$border,
      linewidth = 2
    )
  
  # Document stack coordinates (based on SVG: x="150" y="206" width="100" height="120")
  # Converting SVG coordinates to our coordinate system
  doc_base_x <- -0.55
  doc_base_y <- -0.05
  doc_width <- 0.32
  doc_height <- 0.42
  
  # Create document icons (3 stacked papers with exact SVG positioning)
  # SVG has documents at relative positions: (0,20), (10,10), (20,0)
  docs_data <- data.frame(
    xmin = c(doc_base_x, doc_base_x + 0.04, doc_base_x + 0.08),
    xmax = c(doc_base_x + doc_width, doc_base_x + doc_width + 0.04, doc_base_x + doc_width + 0.08),
    ymin = c(doc_base_y + 0.08, doc_base_y + 0.04, doc_base_y),
    ymax = c(doc_base_y + doc_height + 0.08, doc_base_y + doc_height + 0.04, doc_base_y + doc_height),
    layer = c(1, 2, 3)
  )
  
  # Add document rectangles (back to front)
  for (i in 3:1) {
    doc <- docs_data[docs_data$layer == i, ]
    alpha_val <- c(0.7, 0.8, 1.0)[i]
    
    p <- p + 
      geom_rect(
        data = doc,
        aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax),
        fill = colors$white,
        color = colors$border,
        alpha = alpha_val,
        linewidth = 0.5
      )
  }
  
  # Add "# put" text on the front document (SVG: x="10" y="70" within group)
  p <- p + 
    annotate("text", 
             x = doc_base_x + 0.14, 
             y = doc_base_y + 0.27,
             label = "# put", 
             size = 2.0, 
             color = colors$gray,
             family = "mono",
             fontface = "bold")
  
  # Network visualization (right side - based on SVG group at x="196" y="136")
  # Converting SVG node positions to our coordinate system
  # Main large node at (0,10) 40x40, others positioned relative to this
  nodes <- data.frame(
    x = c(0.08, 0.28, 0.48, 0.43, 0.58, 0.35, 0.65, 0.5),
    y = c(0.35, 0.42, 0.17, 0.3, 0.1, 0.1, 0.0, -0.07),
    size = c(4.0, 2.0, 1.6, 3.0, 1.0, 1.8, 1.4, 2.2),
    id = 1:8
  )
  
  # Connection data for network edges (based on SVG edge definitions)
  edges <- data.frame(
    x1 = c(0.08, 0.08, 0.28, 0.48, 0.43, 0.43, 0.43),
    y1 = c(0.35, 0.35, 0.42, 0.17, 0.3, 0.3, 0.3),
    x2 = c(0.28, 0.35, 0.48, 0.35, 0.65, 0.58, 0.5),
    y2 = c(0.42, 0.1, 0.17, 0.1, 0.0, 0.1, -0.07)
  )
  
  # Add network edges
  p <- p + 
    geom_segment(
      data = edges,
      aes(x = x1, y = y1, xend = x2, yend = y2),
      color = colors$white,
      linewidth = 1.2,
      alpha = 0.8
    )
  
  # Add network nodes
  p <- p + 
    geom_point(
      data = nodes,
      aes(x = x, y = y, size = size),
      color = colors$white,
      fill = colors$white,
      shape = 21,
      stroke = 1.5,
      alpha = 0.9
    ) +
    scale_size_identity()
  
  # Add package name "putior" (SVG: x="250" y="306" rotation=330)
  p <- p + 
    annotate("text", 
             x = 0.15, 
             y = -0.55,
             label = "putior", 
             size = 11, 
             color = colors$white,
             family = "sans",
             fontface = "bold",
             angle = 330)
  
  # Save the plot
  ggsave(
    filename = output_path,
    plot = p,
    width = width/dpi,
    height = height/dpi,
    dpi = dpi,
    bg = "transparent"
  )
  
  # Also save as SVG for comparison (same dimensions as your original)
  svg_path <- sub("\\.png$", ".svg", output_path)
  ggsave(
    filename = svg_path,
    plot = p,
    width = 399/72,  # Convert pixels to inches (399px from your SVG)
    height = 384/72, # Convert pixels to inches (384px from your SVG)
    bg = "transparent",
    device = "svg"
  )
  
  cat("✨ Hex sticker saved to:", output_path, "\n")
  
  invisible(p)
}

#' Generate all hex sticker variants
#' 
#' Creates multiple versions of the hex sticker for different use cases
generate_hex_variants <- function(base_dir = ".") {
  
  # High-res version for print/packaging
  create_putior_hex(
    output_path = file.path(base_dir, "putior-hex-large.png"),
    width = 800,
    height = 800,
    dpi = 300
  )
  
  # Standard web version
  create_putior_hex(
    output_path = file.path(base_dir, "putior-hex.png"),
    width = 400,
    height = 400,
    dpi = 150
  )
  
  # Small version for badges/icons
  create_putior_hex(
    output_path = file.path(base_dir, "putior-hex-small.png"),
    width = 200,
    height = 200,
    dpi = 100
  )
  
  cat("🎨 Generated all hex sticker variants!\n")
}

# If script is run directly, generate the hex stickers
if (!interactive()) {
  generate_hex_variants()
}