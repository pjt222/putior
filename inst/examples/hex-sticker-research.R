# Research on creating reproducible hex stickers for putior
# Comparing different approaches for creating complex hex stickers

# Required libraries
library(ggplot2)
library(grid)
library(ggraph)
library(igraph)
library(showtext)

# Approach 1: hexSticker package (requires installation)
# The hexSticker package is the standard tool for creating hex stickers
# Pros:
# - Purpose-built for hex stickers
# - Handles fonts, borders, and positioning automatically
# - Supports both ggplot2 plots and images as input
# - Built-in hexagon shape
# Cons:
# - Limited customization for complex designs
# - May need workarounds for multiple elements
# - Package not currently installed

# Example structure (would work if hexSticker was installed):
# library(hexSticker)
# # Create a base plot with network visualization
# g <- make_graph(~ 1-2-3-4-5, 1-3, 1-4, 2-5)
# p <- ggraph(g, layout = 'fr') +
#   geom_edge_link(color = "white", alpha = 0.5) +
#   geom_node_point(color = "white", size = 3) +
#   theme_void()
# 
# sticker(p, 
#         package = "putior",
#         p_size = 20,
#         s_x = 1,
#         s_y = 0.8,
#         s_width = 1.3,
#         s_height = 1,
#         h_fill = "#6B5B95",
#         h_color = "#000000",
#         filename = "hex_hexsticker.png")

# Approach 2: Pure ggplot2 with custom hexagon
# Pros:
# - Full control over every element
# - No additional dependencies beyond ggplot2
# - Can layer multiple elements easily
# - Supports gradients via scale_fill_gradient
# Cons:
# - More code required
# - Need to manually create hexagon shape
# - Font handling more complex

create_hexagon <- function(center_x = 0, center_y = 0, size = 1) {
  angles <- seq(30, 330, by = 60) * pi / 180
  data.frame(
    x = center_x + size * cos(angles),
    y = center_y + size * sin(angles)
  )
}

# Create network data
set.seed(42)
nodes <- data.frame(
  x = c(0.3, 0.7, 0.5, 0.2, 0.8, 0.4, 0.6),
  y = c(0.7, 0.7, 0.5, 0.3, 0.3, 0.4, 0.6),
  size = c(3, 3, 2, 2, 2, 1.5, 1.5)
)

edges <- data.frame(
  x = c(0.3, 0.3, 0.7, 0.5, 0.2, 0.4),
  y = c(0.7, 0.7, 0.7, 0.5, 0.3, 0.4),
  xend = c(0.5, 0.2, 0.8, 0.4, 0.4, 0.6),
  yend = c(0.5, 0.3, 0.3, 0.4, 0.4, 0.6)
)

# Create document icons data
docs <- data.frame(
  x = c(0.15, 0.12, 0.18),
  y = c(0.75, 0.72, 0.78),
  label = c("# put", "# put", "# put"),
  size = c(4, 3.5, 3)
)

# Create ggplot2 hex sticker
hex_ggplot <- ggplot() +
  # Hexagon background with gradient effect
  geom_polygon(data = create_hexagon(0.5, 0.5, 0.48),
               aes(x, y), fill = "#6B5B95", color = NA) +
  geom_polygon(data = create_hexagon(0.5, 0.5, 0.5),
               aes(x, y), fill = NA, color = "black", size = 2) +
  # Network edges
  geom_segment(data = edges,
               aes(x = x, y = y, xend = xend, yend = yend),
               color = "white", alpha = 0.3, size = 0.5) +
  # Network nodes
  geom_point(data = nodes,
             aes(x, y, size = size),
             color = "white", alpha = 0.8) +
  # Document icons (simplified as rectangles with text)
  geom_rect(data = docs,
            aes(xmin = x - 0.03, xmax = x + 0.03,
                ymin = y - 0.02, ymax = y + 0.02),
            fill = "white", alpha = 0.9) +
  geom_text(data = docs,
            aes(x, y, label = label, size = size),
            color = "#6B5B95", family = "mono") +
  # Package name
  annotate("text", x = 0.5, y = 0.1, label = "putior",
           size = 8, color = "white", fontface = "bold") +
  # Styling
  scale_size_identity() +
  coord_fixed() +
  theme_void() +
  theme(plot.margin = margin(0, 0, 0, 0))

# Approach 3: Grid graphics
# Pros:
# - Low-level control
# - Can create exact shapes and gradients
# - Efficient for complex custom graphics
# Cons:
# - Steeper learning curve
# - More verbose code
# - Less integration with data visualization tools

create_hex_grid <- function() {
  grid.newpage()
  
  # Define hexagon vertices
  angles <- seq(30, 330, by = 60) * pi / 180
  hex_x <- 0.5 + 0.4 * cos(angles)
  hex_y <- 0.5 + 0.4 * sin(angles)
  
  # Create gradient background
  gradient <- linearGradient(
    colours = c("#4B4B6B", "#6B5B95", "#8B7BA5"),
    x1 = 0, y1 = 1, x2 = 0, y2 = 0
  )
  
  # Draw hexagon with gradient
  grid.polygon(x = hex_x, y = hex_y,
               gp = gpar(fill = "#6B5B95", col = "black", lwd = 3))
  
  # Add network elements
  # ... (would add circles, lines, text using grid functions)
  
  # Add text
  grid.text("putior", x = 0.5, y = 0.1,
            gp = gpar(col = "white", fontsize = 24, fontface = "bold"))
}

# Approach 4: Hybrid approach - ggplot2 + hexSticker
# Pros:
# - Best of both worlds
# - Create complex plot in ggplot2, use hexSticker for final formatting
# - Handles fonts and borders well
# Cons:
# - Requires hexSticker package

# Approach 5: Using additional packages
# - ggraph: Excellent for network visualizations
# - patchwork: Combine multiple plots
# - ggforce: Additional geoms for complex shapes
# - gganimate: For animated hex stickers

# Recommendation for putior hex sticker:
# 
# Given the requirements:
# 1. Multiple document/file icons
# 2. Network/graph visualization
# 3. Gradient background
# 4. Text elements
# 
# Best approach: Pure ggplot2 or ggplot2 + hexSticker
# 
# Pure ggplot2 advantages:
# - No additional dependencies
# - Full control over all elements
# - Can create gradient effects with multiple polygons
# - Easy to maintain and modify
# 
# Implementation strategy:
# 1. Create hexagon shape as polygon
# 2. Layer gradient effect with multiple semi-transparent polygons
# 3. Use ggraph or manual positioning for network elements
# 4. Add document shapes as rectangles or custom polygons
# 5. Use annotate() or geom_text() for text elements
# 6. Export with ggsave() at appropriate resolution

# Example implementation starter:
create_putior_hex <- function() {
  # This would be the full implementation
  # combining all elements shown above
  # with proper styling and positioning
}

# Save examples
# ggsave("hex_ggplot.png", hex_ggplot, width = 2, height = 2, dpi = 300)