# Create putior hex sticker - Recommended ggplot2 approach
# This script recreates the putior hex sticker using pure ggplot2

library(ggplot2)
library(dplyr)

# Function to create hexagon coordinates
create_hexagon <- function(center_x = 0.5, center_y = 0.5, size = 0.45) {
  angles <- seq(30, 330, by = 60) * pi / 180
  data.frame(
    x = center_x + size * cos(angles),
    y = center_y + size * sin(angles)
  )
}

# Create network data (mimicking the original design)
create_network_data <- function() {
  set.seed(42)  # For reproducibility
  
  # Node positions (right side of hex)
  nodes <- data.frame(
    x = c(0.65, 0.75, 0.85, 0.7, 0.8, 0.6, 0.9),
    y = c(0.8, 0.7, 0.6, 0.5, 0.4, 0.6, 0.7),
    size = c(4, 3.5, 3, 3.5, 3, 2.5, 2.5),
    id = 1:7
  )
  
  # Connections between nodes
  edges <- data.frame(
    from = c(1, 1, 2, 3, 4, 6),
    to = c(2, 4, 3, 5, 5, 7)
  ) %>%
    left_join(nodes, by = c("from" = "id")) %>%
    rename(x_from = x, y_from = y) %>%
    select(-size) %>%
    left_join(nodes, by = c("to" = "id")) %>%
    rename(x_to = x, y_to = y) %>%
    select(-size)
  
  list(nodes = nodes, edges = edges)
}

# Create document stack data
create_document_data <- function() {
  # Three stacked documents (left side of hex)
  data.frame(
    x = c(0.25, 0.23, 0.27),      # Slightly offset x positions
    y = c(0.65, 0.62, 0.68),      # Slightly offset y positions  
    width = c(0.12, 0.12, 0.12),  # Document width
    height = c(0.15, 0.15, 0.15), # Document height
    layer = c(1, 2, 3)            # Stacking order
  )
}

# Main function to create the hex sticker
create_putior_hex <- function() {
  # Get data
  hex_shape <- create_hexagon()
  network_data <- create_network_data()
  doc_data <- create_document_data()
  
  # Color palette
  bg_color <- "#6B5B95"      # Main purple
  bg_light <- "#8B7BA5"      # Lighter purple for gradient
  border_color <- "#000000"   # Black border
  text_color <- "#FFFFFF"     # White text
  node_color <- "#FFFFFF"     # White nodes
  doc_color <- "#FFFFFF"      # White documents
  
  # Create the plot
  p <- ggplot() +
    
    # Background gradient effect (multiple layers for gradient simulation)
    geom_polygon(data = hex_shape, 
                 aes(x, y), 
                 fill = bg_light, 
                 color = NA,
                 alpha = 0.8) +
    
    geom_polygon(data = hex_shape, 
                 aes(x, y), 
                 fill = bg_color, 
                 color = NA,
                 alpha = 0.6) +
    
    # Hexagon border
    geom_polygon(data = hex_shape, 
                 aes(x, y), 
                 fill = NA, 
                 color = border_color, 
                 size = 1.5) +
    
    # Network edges
    geom_segment(data = network_data$edges,
                 aes(x = x_from, y = y_from, 
                     xend = x_to, yend = y_to),
                 color = text_color, 
                 alpha = 0.4, 
                 size = 0.8) +
    
    # Network nodes
    geom_point(data = network_data$nodes,
               aes(x, y, size = size),
               color = node_color, 
               alpha = 0.9) +
    
    # Document stack (back to front)
    geom_rect(data = arrange(doc_data, layer),
              aes(xmin = x - width/2, xmax = x + width/2,
                  ymin = y - height/2, ymax = y + height/2),
              fill = doc_color, 
              color = bg_color,
              alpha = 0.95,
              size = 0.5) +
    
    # Document text annotations
    annotate("text", 
             x = doc_data$x[1], 
             y = doc_data$y[1] + 0.02, 
             label = "# put", 
             size = 3, 
             color = bg_color,
             family = "mono",
             fontface = "bold") +
    
    # Package name
    annotate("text", 
             x = 0.5, 
             y = 0.15, 
             label = "putior", 
             size = 12, 
             color = text_color,
             fontface = "bold") +
    
    # Styling
    scale_size_identity() +
    coord_fixed(ratio = 1) +
    xlim(0, 1) +
    ylim(0, 1) +
    theme_void() +
    theme(
      plot.background = element_blank(),
      panel.background = element_blank(),
      plot.margin = margin(0, 0, 0, 0)
    )
  
  return(p)
}

# Alternative version with enhanced gradient effect
create_putior_hex_enhanced <- function() {
  # Similar to above but with more sophisticated gradient
  hex_shape <- create_hexagon()
  network_data <- create_network_data()
  doc_data <- create_document_data()
  
  # Create multiple gradient layers
  gradient_layers <- data.frame(
    layer = 1:5,
    alpha = c(0.2, 0.25, 0.3, 0.35, 0.4),
    color = c("#8B7BA5", "#7B6B95", "#6B5B95", "#5B4B85", "#4B3B75")
  )
  
  p <- ggplot()
  
  # Add gradient layers
  for(i in 1:nrow(gradient_layers)) {
    p <- p +
      geom_polygon(data = hex_shape, 
                   aes(x, y), 
                   fill = gradient_layers$color[i], 
                   color = NA,
                   alpha = gradient_layers$alpha[i])
  }
  
  # Add remaining elements (same as basic version)
  p <- p +
    geom_polygon(data = hex_shape, aes(x, y), 
                 fill = NA, color = "#000000", size = 1.5) +
    # ... (add other elements)
    
    theme_void() +
    coord_fixed()
  
  return(p)
}

# Function to save the hex sticker
save_putior_hex <- function(plot, filename = "putior_hex", 
                           width = 2, height = 2, dpi = 300) {
  
  # Save as PNG (for package use)
  ggsave(paste0(filename, ".png"), plot, 
         width = width, height = height, dpi = dpi,
         bg = "transparent")
  
  # Save as SVG (for scalability) 
  ggsave(paste0(filename, ".svg"), plot,
         width = width, height = height,
         bg = "transparent")
  
  cat("Hex sticker saved as:", paste0(filename, c(".png", ".svg")), "\n")
}

# Usage example:
if (FALSE) {  # Set to TRUE to run
  # Create the hex sticker
  hex_plot <- create_putior_hex()
  
  # Preview
  print(hex_plot)
  
  # Save to files
  save_putior_hex(hex_plot, "putior_hex_ggplot2")
}

# Notes for further customization:
# 1. Adjust node positions in create_network_data() to match original exactly
# 2. Fine-tune colors to match original purple gradient
# 3. Add more sophisticated document shapes if needed
# 4. Consider using ggraph for more complex network layouts
# 5. Use showtext package for custom fonts if required
# 6. Add drop shadow effects with additional polygon layers