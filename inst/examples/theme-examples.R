# Putior Theme Examples: Standard and Colorblind-Safe Themes
# ==============================================================================
# This example demonstrates putior's 9 themes including colorblind-safe options.
#
# Standard themes: light, dark, auto, minimal, github
# Colorblind-safe (viridis family): viridis, magma, plasma, cividis
#
# To run this example:
#   source(system.file("examples", "theme-examples.R", package = "putior"))
# ==============================================================================

library(putior)

cat("🎨 Putior Theme Examples\n")
cat(paste(rep("=", 40), collapse = ""), "\n\n")

# Create a sample workflow for theme demonstration
temp_dir <- file.path(tempdir(), "putior_themes")
dir.create(temp_dir, showWarnings = FALSE)

cat("📁 Creating sample workflow...\n")

# Simple but representative workflow
workflow_files <- list(
  "collect.py" = c(
    "# put id:\"fetch_data\", label:\"Fetch API Data\", node_type:\"input\", output:\"raw_data.json\"",
    "import requests",
    "data = requests.get('/api/data').json()",
    "with open('raw_data.json', 'w') as f:",
    "    json.dump(data, f)"
  ),
  
  "process.R" = c(
    "# put id:\"clean_data\", label:\"Clean and Validate\", node_type:\"process\", input:\"raw_data.json\", output:\"clean_data.csv\"",
    "library(jsonlite)",
    "raw <- fromJSON('raw_data.json')",
    "clean <- clean_dataset(raw)",
    "write.csv(clean, 'clean_data.csv')"
  ),
  
  "analyze.R" = c(
    "# put id:\"statistical_analysis\", label:\"Statistical Analysis\", node_type:\"process\", input:\"clean_data.csv\", output:\"results.rds\"",
    "# put id:\"quality_check\", label:\"Data Quality Check\", node_type:\"decision\", input:\"clean_data.csv\", output:\"quality_report.json\"",
    "data <- read.csv('clean_data.csv')",
    "results <- perform_analysis(data)",
    "saveRDS(results, 'results.rds')"
  ),
  
  "report.R" = c(
    "# put id:\"generate_report\", label:\"Generate Final Report\", node_type:\"output\", input:\"results.rds\", output:\"final_report.html\"",
    "results <- readRDS('results.rds')",
    "rmarkdown::render('report_template.Rmd', output_file = 'final_report.html')"
  )
)

# Write workflow files
for (filename in names(workflow_files)) {
  writeLines(workflow_files[[filename]], file.path(temp_dir, filename))
}

# Extract workflow
workflow <- put(temp_dir)
cat("✅ Found", nrow(workflow), "workflow nodes\n\n")

# Show available themes
cat("🎨 Available Themes:\n")
themes <- get_diagram_themes()
for (theme_name in names(themes)) {
  cat("  ", theme_name, ":", themes[[theme_name]], "\n")
}
cat("\n")

cat(paste(rep("=", 50), collapse = ""), "\n")
cat("🌅 LIGHT THEME (Default)\n")
cat("Perfect for: Documentation sites, light mode environments\n")
cat(paste(rep("-", 50), collapse = ""), "\n")
put_diagram(workflow, 
            title = "Data Processing Pipeline - Light Theme",
            theme = "light")

cat("\n", paste(rep("=", 50), collapse = ""), "\n")
cat("🌙 DARK THEME\n") 
cat("Perfect for: Dark mode environments, terminal displays\n")
cat(paste(rep("-", 50), collapse = ""), "\n")
put_diagram(workflow,
            title = "Data Processing Pipeline - Dark Theme", 
            theme = "dark",
            direction = "LR")

cat("\n", paste(rep("=", 50), collapse = ""), "\n")
cat("🔄 AUTO THEME (GitHub Adaptive)\n")
cat("Perfect for: GitHub README files, automatically adapts to user's theme\n")
cat(paste(rep("-", 50), collapse = ""), "\n")
put_diagram(workflow,
            title = "Data Processing Pipeline - Auto Theme",
            theme = "auto",
            show_files = TRUE)

cat("\n", paste(rep("=", 50), collapse = ""), "\n")
cat("⚪ MINIMAL THEME\n")
cat("Perfect for: Professional documents, print-friendly diagrams\n")
cat(paste(rep("-", 50), collapse = ""), "\n")
put_diagram(workflow,
            title = "Data Processing Pipeline - Minimal Theme",
            theme = "minimal",
            node_labels = "both")

cat("\n", paste(rep("=", 50), collapse = ""), "\n")
cat("🎯 VIRIDIS THEME (Colorblind-Safe)\n")
cat("Perfect for: Accessibility, general use, perceptually uniform\n")
cat(paste(rep("-", 50), collapse = ""), "\n")
put_diagram(workflow,
            title = "Data Processing Pipeline - Viridis Theme",
            theme = "viridis")

cat("\n", paste(rep("=", 50), collapse = ""), "\n")
cat("🔥 MAGMA THEME (Colorblind-Safe, Warm)\n")
cat("Perfect for: High contrast, print materials\n")
cat(paste(rep("-", 50), collapse = ""), "\n")
put_diagram(workflow,
            title = "Data Processing Pipeline - Magma Theme",
            theme = "magma")

cat("\n", paste(rep("=", 50), collapse = ""), "\n")
cat("🌈 PLASMA THEME (Colorblind-Safe, Vibrant)\n")
cat("Perfect for: Presentations, digital displays\n")
cat(paste(rep("-", 50), collapse = ""), "\n")
put_diagram(workflow,
            title = "Data Processing Pipeline - Plasma Theme",
            theme = "plasma",
            direction = "LR")

cat("\n", paste(rep("=", 50), collapse = ""), "\n")
cat("👁️ CIVIDIS THEME (Maximum Colorblind Accessibility)\n")
cat("Perfect for: Red-green colorblindness (deuteranopia/protanopia)\n")
cat(paste(rep("-", 50), collapse = ""), "\n")
put_diagram(workflow,
            title = "Data Processing Pipeline - Cividis Theme",
            theme = "cividis")

cat("\n", paste(rep("=", 50), collapse = ""), "\n")
cat("💡 USAGE RECOMMENDATIONS\n")
cat(paste(rep("=", 50), collapse = ""), "\n\n")

cat("🌅 Light Theme:\n")
cat("  • Default theme with bright, friendly colors\n")
cat("  • Best for documentation websites and light backgrounds\n")
cat("  • High contrast and readability\n\n")

cat("🌙 Dark Theme:\n") 
cat("  • Muted colors with light text\n")
cat("  • Perfect for dark mode applications and terminals\n")
cat("  • Easy on the eyes for extended viewing\n\n")

cat("🔄 Auto Theme:\n")
cat("  • Uses GitHub's adaptive color system\n")
cat("  • Automatically looks good in both light and dark modes\n")
cat("  • Recommended for GitHub README files\n\n")

cat("⚪ Minimal Theme:\n")
cat("  • Grayscale with subtle borders\n")
cat("  • Professional appearance for business documents\n")
cat("  • Print-friendly and accessible\n\n")

cat("🎯 Viridis Theme (Colorblind-Safe):\n")
cat("  • Purple → Blue → Green → Yellow palette\n")
cat("  • Most widely tested colorblind-safe palette\n")
cat("  • Perceptually uniform - equal steps appear equally different\n\n")

cat("🔥 Magma Theme (Colorblind-Safe):\n")
cat("  • Purple → Red → Yellow warm palette\n")
cat("  • High contrast for print and presentations\n")
cat("  • Works well in grayscale\n\n")

cat("🌈 Plasma Theme (Colorblind-Safe):\n")
cat("  • Purple → Pink → Orange → Yellow vibrant palette\n")
cat("  • Bold colors ideal for digital displays\n")
cat("  • Great for presentations\n\n")

cat("👁️ Cividis Theme (Maximum Accessibility):\n")
cat("  • Blue → Gray → Yellow palette\n")
cat("  • Specifically optimized for deuteranopia and protanopia\n")
cat("  • Avoids red-green entirely\n\n")

cat("📋 Example Usage:\n")
cat("  # For GitHub README (adapts to user's theme)\n")
cat("  put_diagram(workflow, theme = 'auto')\n\n")
cat("  # For dark documentation sites\n")
cat("  put_diagram(workflow, theme = 'dark', direction = 'LR')\n\n")
cat("  # For professional reports\n")
cat("  put_diagram(workflow, theme = 'minimal', output = 'file')\n\n")
cat("  # For colorblind-safe diagrams\n")
cat("  put_diagram(workflow, theme = 'viridis')  # General accessibility\n")
cat("  put_diagram(workflow, theme = 'cividis')  # Red-green colorblindness\n\n")

# Save examples to files for comparison
cat("💾 Saving theme examples to files...\n")

themes_to_save <- c("light", "dark", "auto", "minimal", "github",
                    "viridis", "magma", "plasma", "cividis")
for (theme in themes_to_save) {
  filename <- file.path(temp_dir, paste0("workflow_", theme, "_theme.md"))
  put_diagram(workflow,
              output = "file",
              file = filename,
              title = paste("Workflow -", stringr::str_to_title(theme), "Theme"),
              theme = theme,
              show_files = TRUE)
}

cat("✅ Saved theme examples:\n")
for (theme in themes_to_save) {
  filename <- paste0("workflow_", theme, "_theme.md")
  cat("  •", filename, "\n")
}

cat("\n📂 All files saved to:", temp_dir, "\n")
cat("💡 Try opening these files in different environments to see the themes!\n\n")

cat("🎨 Happy theming with putior! 🚀\n")