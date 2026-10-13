#!/usr/bin/env Rscript
# Regenerate the Mermaid diagrams in README.md from current putior output.
#
# Run from the package root: Rscript inst/examples/update-readme.R
# The update-readme workflow runs it on every push to main that changes R/.
#
# Each diagram in README.md is marked by an HTML comment on the line right
# before its ```mermaid fence:
#
#   <!-- putior-diagram: tldr -->
#   <!-- putior-diagram: pipeline -->
#   <!-- putior-diagram: self-documentation -->
#
# The script replaces the fenced block after each marker. A missing marker, or
# a marker that is not followed by a ```mermaid block, stops the script with an
# error, so the workflow fails instead of silently leaving a diagram stale.

library(putior)

readme_path <- "README.md"
if (!file.exists(readme_path) || !file.exists("DESCRIPTION")) {
  stop("Run this script from the package root (README.md not found).", call. = FALSE)
}
readme_lines <- readLines(readme_path, encoding = "UTF-8")

# Write files into a fresh directory and scan it with put()
scan_files <- function(files) {
  fixture_dir <- tempfile("putior_readme_")
  dir.create(fixture_dir)
  for (file_name in names(files)) {
    writeLines(files[[file_name]], file.path(fixture_dir, file_name))
  }
  workflow <- put(fixture_dir, validate = FALSE)
  unlink(fixture_dir, recursive = TRUE)
  workflow
}

# Annotations without an id get a random UUID when the uuid package is
# installed. Use putior's own fallback ids (node_1, node_2, ...) instead, so
# the README only changes when the diagram itself changes.
stable_ids <- function(workflow) {
  uuid_pattern <- "^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$"
  is_uuid <- grepl(uuid_pattern, workflow$id)
  workflow$id[is_uuid] <- paste0("node_", seq_len(sum(is_uuid)))
  workflow
}

# The code blocks of the README's pipeline example: a line such as
# **`01_fetch.R`** followed by a fenced code block with the file's content.
readme_example_files <- function(lines) {
  heading_rows <- grep("^\\*\\*`[^`]+`\\*\\*$", lines)
  files <- list()
  for (heading_row in heading_rows) {
    fence_start <- heading_row + 1
    if (fence_start > length(lines) || !grepl("^```[a-z]+$", lines[fence_start])) next
    fence_end <- fence_start + match(TRUE, lines[(fence_start + 1):length(lines)] == "```")
    file_name <- sub("^\\*\\*`([^`]+)`\\*\\*$", "\\1", lines[heading_row])
    files[[file_name]] <- lines[(fence_start + 1):(fence_end - 1)]
  }
  if (length(files) == 0) {
    stop("README.md: no example files (**`name`** followed by a code block) found.", call. = FALSE)
  }
  files
}

# Replace the ```mermaid block that follows the marker line
replace_diagram <- function(lines, marker_name, diagram) {
  marker <- paste0("<!-- putior-diagram: ", marker_name, " -->")
  marker_row <- which(lines == marker)
  if (length(marker_row) != 1) {
    stop("README.md: expected one '", marker, "' line, found ", length(marker_row), ".",
         call. = FALSE)
  }
  if (marker_row == length(lines) || lines[marker_row + 1] != "```mermaid") {
    stop("README.md: '", marker, "' must be followed by a ```mermaid line.", call. = FALSE)
  }
  fence_end <- marker_row + 1 + match(TRUE, lines[(marker_row + 2):length(lines)] == "```")
  if (is.na(fence_end)) {
    stop("README.md: the ```mermaid block after '", marker, "' is not closed.", call. = FALSE)
  }
  c(lines[seq_len(marker_row + 1)], strsplit(diagram, "\n", fixed = TRUE)[[1]],
    lines[fence_end:length(lines)])
}

# TL;DR: the one-line annotation shown above the diagram
tldr_workflow <- stable_ids(scan_files(list(
  "script.R" = '# put label:"Load Data", output:"clean.csv"'
)))
readme_lines <- replace_diagram(readme_lines, "tldr",
  put_diagram(tldr_workflow, show_artifacts = TRUE, output = "raw"))

# Multi-language pipeline: the example files shown in the README itself
pipeline_workflow <- stable_ids(scan_files(readme_example_files(readme_lines)))
readme_lines <- replace_diagram(readme_lines, "pipeline",
  put_diagram(pipeline_workflow, theme = "github", output = "raw"))

# Self-documentation: putior's own annotated source
self_workflow <- put("R/", validate = FALSE)
readme_lines <- replace_diagram(readme_lines, "self-documentation",
  put_diagram(self_workflow, theme = "github", title = "putior Package Internals",
              output = "raw"))

# A binary connection writes LF line endings on Windows too
readme_connection <- file(readme_path, open = "wb")
writeLines(enc2utf8(readme_lines), readme_connection, useBytes = TRUE)
close(readme_connection)
cat("README.md diagrams regenerated: tldr, pipeline, self-documentation\n")
