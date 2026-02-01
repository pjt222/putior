#!/usr/bin/env Rscript
# Demo GIF Generator for putior README
# Run: Rscript inst/examples/create-demo-gif.R

library(magick)

# Theme constants
DEFAULT_BG_COLOR <- "#1a1b26"

# Helper function to render Mermaid diagram using mmdc (Mermaid CLI)
# Produces high-quality crisp diagrams with custom background
# Handles Windows R + WSL mmdc cross-platform scenario
render_mermaid_diagram <- function(mmd_file, bg_color = DEFAULT_BG_COLOR, scale = 3) {
  output_png <- tempfile(fileext = ".png")

  # Detect platform and construct appropriate command
  is_windows <- .Platform$OS.type == "windows"

  if (is_windows) {
    # Convert Windows paths to WSL paths for mmdc running in WSL
    # Windows: D:/dev/p/putior/inst/examples/demo-diagram.mmd
    # WSL:     /mnt/d/dev/p/putior/inst/examples/demo-diagram.mmd
    mmd_abs <- normalizePath(mmd_file, winslash = "/")
    out_abs <- normalizePath(output_png, winslash = "/", mustWork = FALSE)

    # Convert drive letter paths to WSL mount paths
    convert_to_wsl <- function(path) {
      if (grepl("^[A-Za-z]:", path)) {
        drive <- tolower(substr(path, 1, 1))
        rest <- substr(path, 3, nchar(path))
        paste0("/mnt/", drive, rest)
      } else {
        path
      }
    }
    mmd_wsl <- convert_to_wsl(mmd_abs)
    out_wsl <- convert_to_wsl(out_abs)

    # Call mmdc through wsl.exe - source nvm to get node in PATH
    # Use bash -ic to get interactive shell initialization
    cmd <- sprintf(
      'wsl bash -ic "source ~/.nvm/nvm.sh && mmdc -i \\"%s\\" -o \\"%s\\" -b \\"%s\\" -s %d"',
      mmd_wsl, out_wsl, bg_color, scale
    )
  } else {
    # Native Unix/WSL - use mmdc directly
    cmd <- sprintf(
      'mmdc -i "%s" -o "%s" -b "%s" -s %d',
      mmd_file, output_png, bg_color, scale
    )
  }

  cat("Running:", cmd, "\n")
  result <- system(cmd, intern = FALSE)
  if (result != 0) {
    stop("Failed to render Mermaid diagram. Is mmdc installed? Run: npm install -g @mermaid-js/mermaid-cli")
  }

  img <- image_read(output_png)
  unlink(output_png)  # Clean up temp file
  img
}

# Output directory
output_dir <- "man/figures"
if (!dir.exists(output_dir)) dir.create(output_dir, recursive = TRUE)

# Colors (Tokyo Night theme)
bg <- "#1a1b26"
fg <- "#c0caf5"
green <- "#9ece6a"
blue <- "#7aa2f7"
purple <- "#bb9af7"
gray <- "#565f89"

# Frame dimensions - LARGER for higher DPI/crispness
# Using 1.5x scale factor for everything
scale <- 1.5
w <- round(800 * scale)  # 1200
h <- round(500 * scale)  # 750

# Font sizes (scaled)
title_size <- round(24 * scale)
code_size <- round(16 * scale)
small_size <- round(14 * scale)

# Positioning (scaled)
title_y <- round(25 * scale)
content_start_y <- round(75 * scale)
line_height <- round(25 * scale)
block_gap <- round(45 * scale)

# Create Frame 1: Annotated code
cat("Creating Frame 1 (", w, "x", h, ")...\n")
f1 <- image_blank(w, h, bg)
f1 <- image_annotate(f1, "  Step 1: Add annotations to your code",
                     size = title_size, color = purple,
                     location = paste0("+", round(30*scale), "+", title_y),
                     font = "mono", weight = 700)

y <- content_start_y
f1 <- image_annotate(f1, "# sales_pipeline.R",
                     size = code_size, color = gray,
                     location = paste0("+", round(50*scale), "+", y), font = "mono")
y <- y + line_height + 10
f1 <- image_annotate(f1, "#put label:\"Load Data\", node_type:\"input\",",
                     size = code_size, color = green,
                     location = paste0("+", round(50*scale), "+", y), font = "mono")
y <- y + line_height
f1 <- image_annotate(f1, "#     output:\"data.csv\"",
                     size = code_size, color = green,
                     location = paste0("+", round(50*scale), "+", y), font = "mono")
y <- y + block_gap
f1 <- image_annotate(f1, "data <- read.csv(\"raw.csv\")",
                     size = code_size, color = fg,
                     location = paste0("+", round(50*scale), "+", y), font = "mono")
y <- y + line_height
f1 <- image_annotate(f1, "write.csv(data, \"data.csv\")",
                     size = code_size, color = fg,
                     location = paste0("+", round(50*scale), "+", y), font = "mono")
y <- y + block_gap + 10
f1 <- image_annotate(f1, "#put label:\"Analyze\", input:\"data.csv\",",
                     size = code_size, color = green,
                     location = paste0("+", round(50*scale), "+", y), font = "mono")
y <- y + line_height
f1 <- image_annotate(f1, "#     output:\"results.csv\"",
                     size = code_size, color = green,
                     location = paste0("+", round(50*scale), "+", y), font = "mono")
y <- y + block_gap
f1 <- image_annotate(f1, "results <- analyze(data)",
                     size = code_size, color = fg,
                     location = paste0("+", round(50*scale), "+", y), font = "mono")
y <- y + line_height
f1 <- image_annotate(f1, "write.csv(results, \"results.csv\")",
                     size = code_size, color = fg,
                     location = paste0("+", round(50*scale), "+", y), font = "mono")

# Create Frame 2: Run putior
cat("Creating Frame 2...\n")
f2 <- image_blank(w, h, bg)
f2 <- image_annotate(f2, "  Step 2: Extract workflow",
                     size = title_size, color = purple,
                     location = paste0("+", round(30*scale), "+", title_y),
                     font = "mono", weight = 700)

y <- content_start_y
f2 <- image_annotate(f2, "> library(putior)",
                     size = code_size, color = blue,
                     location = paste0("+", round(50*scale), "+", y), font = "mono")
y <- y + line_height + 5
f2 <- image_annotate(f2, "> workflow <- put(\"./\")",
                     size = code_size, color = blue,
                     location = paste0("+", round(50*scale), "+", y), font = "mono")
y <- y + block_gap
f2 <- image_annotate(f2, "# Scanning: sales_pipeline.R",
                     size = code_size, color = gray,
                     location = paste0("+", round(50*scale), "+", y), font = "mono")
y <- y + line_height
f2 <- image_annotate(f2, "# Found 2 annotations",
                     size = code_size, color = green,
                     location = paste0("+", round(50*scale), "+", y), font = "mono")
y <- y + block_gap + 20
f2 <- image_annotate(f2, "> put_diagram(workflow)",
                     size = code_size, color = blue,
                     location = paste0("+", round(50*scale), "+", y), font = "mono")
y <- y + block_gap + 20
f2 <- image_annotate(f2, "flowchart TD",
                     size = code_size, color = fg,
                     location = paste0("+", round(50*scale), "+", y), font = "mono")
y <- y + line_height
f2 <- image_annotate(f2, "    load([Load Data]) --> analyze[Analyze]",
                     size = code_size, color = fg,
                     location = paste0("+", round(50*scale), "+", y), font = "mono")
y <- y + line_height
f2 <- image_annotate(f2, "    classDef inputStyle fill:#dbeafe,stroke:#2563eb...",
                     size = small_size, color = gray,
                     location = paste0("+", round(50*scale), "+", y), font = "mono")

# Create Frame 3: Result diagram
cat("Creating Frame 3...\n")
f3 <- image_blank(w, h, bg)
f3 <- image_annotate(f3, "  Step 3: Beautiful diagram!",
                     size = title_size, color = purple,
                     location = paste0("+", round(30*scale), "+", title_y),
                     font = "mono", weight = 700)

# Render crisp Mermaid diagram using mmdc CLI
cat("Rendering Mermaid diagram with mmdc...\n")
mmd_file <- "inst/examples/demo-diagram.mmd"
if (!file.exists(mmd_file)) {
  stop("Mermaid diagram file not found: ", mmd_file,
       "\nRun this script from the package root directory.")
}

diagram_img <- render_mermaid_diagram(mmd_file, bg_color = bg, scale = 3)

# Calculate available space for diagram
diagram_area_top <- content_start_y
diagram_area_bottom <- h - round(60 * scale)
diagram_area_height <- diagram_area_bottom - diagram_area_top

# Scale diagram to fit available height while maintaining aspect ratio
diagram_info <- image_info(diagram_img)
target_height <- min(diagram_area_height, round(400 * scale))
diagram_scaled <- image_scale(diagram_img, paste0("x", target_height))
diagram_info <- image_info(diagram_scaled)

# Center the diagram horizontally and vertically in available space
offset_x <- (w - diagram_info$width) / 2
offset_y <- diagram_area_top + (diagram_area_height - diagram_info$height) / 2

f3 <- image_composite(f3, diagram_scaled,
                      offset = paste0("+", round(offset_x), "+", round(offset_y)))

# Footer
f3 <- image_annotate(f3, "Ready for GitHub README, docs, wikis!",
                     size = code_size, color = purple,
                     location = paste0("+", (w - round(450*scale)) / 2, "+", h - round(40*scale)),
                     font = "mono")

# Combine into animation
cat("Creating animation frames...\n")
frames <- c(rep(list(f1), 25), rep(list(f2), 25), rep(list(f3), 30))
animation <- image_animate(image_join(frames), fps = 10, dispose = "previous")

# Save
output_path <- file.path(output_dir, "demo.gif")
image_write(animation, output_path, format = "gif")

cat("\n=== GIF Created ===\n")
cat("File:", output_path, "\n")
cat("Size:", round(file.size(output_path) / 1024), "KB\n")
cat("Dimensions:", w, "x", h, "\n")
cat("Scale factor:", scale, "x\n")
