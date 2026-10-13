# Write a corpus of put_diagram() outputs for the Mermaid check in
# tests/mermaid/validate.mjs. Run from the package root:
#
#   Rscript tests/mermaid/generate-corpus.R tests/mermaid/corpus
#
# Each case is one .mmd file plus an entry in manifest.json. The entry holds
# the number of distinct ids in the workflow (what the diagram must show) and
# the node, artifact and subgraph ids, plus the targets of class and click
# lines, read from the generated text. With these the check can tell phantom,
# merged or lost nodes from correct ones. A case whose generation fails in R
# is recorded with its error instead of a file.

stopifnot(
  "Run this script from the package root" =
    file.exists("DESCRIPTION") && file.exists("tests/mermaid/generate-corpus.R")
)

# Test the source tree when pkgload is available, the installed package otherwise
if (requireNamespace("pkgload", quietly = TRUE)) {
  pkgload::load_all(".", quiet = TRUE)
} else {
  library(putior)
}

output_dir <- commandArgs(trailingOnly = TRUE)[1]
if (is.na(output_dir)) output_dir <- "tests/mermaid/corpus"
unlink(output_dir, recursive = TRUE)
dir.create(output_dir, recursive = TRUE)

fixture_root <- file.path(tempdir(), "putior-mermaid-corpus")
unlink(fixture_root, recursive = TRUE)

# Write annotated source files into a fresh directory and scan it with put()
scan_fixture <- function(fixture_name, files) {
  fixture_dir <- file.path(fixture_root, fixture_name)
  for (relative_path in names(files)) {
    file_path <- file.path(fixture_dir, relative_path)
    dir.create(dirname(file_path), recursive = TRUE, showWarnings = FALSE)
    writeLines(files[[relative_path]], file_path)
  }
  # put() warns about file references without an extension; not relevant here
  suppressWarnings(put(fixture_dir))
}

# A pipeline that uses every node type, three languages and shared files
pipeline <- scan_fixture("pipeline", list(
  "01_extract.R" = c(
    '# put id:"start", label:"Start Run", node_type:"start"',
    '# put id:"extract", label:"Extract Sales Data", node_type:"input", input:"sales.csv", output:"raw.rds"'
  ),
  "02_transform.py" = c(
    '# put id:"transform", label:"Clean and Transform", node_type:"process", input:"raw.rds", output:"clean.parquet"',
    '# put id:"check", label:"Quality OK?", node_type:"decision", input:"clean.parquet", output:"checked.parquet"'
  ),
  "03_report.sql" = c(
    '-- put id:"report", label:"Build Report", node_type:"output", input:"checked.parquet", output:"report.html"',
    '-- put id:"finish", label:"Done", node_type:"end", input:"report.html"'
  )
))

# putior's own annotated source
self_workflow <- suppressWarnings(put("R"))

cases <- list()
add_case <- function(case_name, workflow, ...) {
  cases[[length(cases) + 1]] <<- list(name = case_name, workflow = workflow, args = list(...))
}

# Standard output, one option at a time
add_case("pipeline_default", pipeline)
for (theme_name in names(get_diagram_themes())) {
  add_case(paste0("theme_", theme_name), pipeline, theme = theme_name)
}
for (direction in c("LR", "BT", "RL", "TB")) {
  add_case(paste0("direction_", direction), pipeline, direction = direction)
}
add_case("node_labels_name", pipeline, node_labels = "name")
add_case("node_labels_both", pipeline, node_labels = "both")
add_case("show_files", pipeline, show_files = TRUE)
add_case("show_artifacts", pipeline, show_artifacts = TRUE)
add_case("show_artifacts_and_files", pipeline, show_artifacts = TRUE, show_files = TRUE)
add_case("no_workflow_boundaries", pipeline, show_workflow_boundaries = FALSE)
add_case("no_node_styles", pipeline, style_nodes = FALSE)
add_case("source_info_inline", pipeline, show_source_info = TRUE)
add_case("source_info_subgraph", pipeline, show_source_info = TRUE, source_info_style = "subgraph")
for (protocol in c("vscode", "file", "rstudio")) {
  add_case(paste0("clicks_", protocol), pipeline, enable_clicks = TRUE, click_protocol = protocol)
}
add_case("title", pipeline, title = "Sales Pipeline")
add_case("custom_palette", pipeline, palette = put_theme(
  base = "dark",
  input = c(fill = "#1b4332", stroke = "#95d5b2", color = "#ffffff"),
  process = c(fill = "#ffd166")
))
add_case("all_options", pipeline,
  title = "Sales Pipeline", direction = "LR", node_labels = "both",
  show_files = TRUE, show_artifacts = TRUE, show_source_info = TRUE,
  source_info_style = "subgraph", enable_clicks = TRUE, theme = "viridis"
)
add_case("self_default", self_workflow)
add_case("self_artifacts_subgraph", self_workflow,
  show_artifacts = TRUE, show_source_info = TRUE, source_info_style = "subgraph"
)

# A workflow detected by put_auto() from unannotated code
auto_dir <- file.path(fixture_root, "auto")
dir.create(auto_dir, recursive = TRUE)
writeLines(c('sales <- read.csv("sales.csv")', 'saveRDS(sales, "sales.rds")'),
           file.path(auto_dir, "01_load.R"))
writeLines(c("import pandas as pd", 'df = pd.read_pickle("sales.rds")', 'df.to_csv("summary.csv")'),
           file.path(auto_dir, "02_summarise.py"))
add_case("auto_detected", suppressWarnings(put_auto(auto_dir)), show_artifacts = TRUE)

# Annotations without ids (uuid ids, or node_<n> without uuid)
add_case("missing_ids", scan_fixture("missing_ids", list(
  "etl.R" = c(
    '# put label:"Extract", output:"raw.csv"',
    '# put label:"Transform", input:"raw.csv", output:"clean.csv"',
    '# put id:"load", label:"Load", input:"clean.csv", output:"db.sqlite"'
  )
)))

# Labels with characters that need escaping (#33)
add_case("label_special_characters", scan_fixture("special_labels", list(
  "a.R" = c(
    '# put id:"quote", label:"Say \\"hi\\" | pipe", output:"x.csv"',
    '# put id:"unicode", label:"Größe – naïve ✓", input:"x.csv"'
  )
)))

# Edge cases from the Mermaid gap analysis
add_case("keyword_node_id", scan_fixture("keyword_id", list(
  "a.R" = c(
    '# put id:"begin", label:"Begin", output:"a.csv"',
    '# put id:"end", label:"Finish", input:"a.csv"'
  )
)))
add_case("subgraph_id_equals_node_id", scan_fixture("subgraph_clash", list(
  "load.R" = '# put id:"load", label:"Load", output:"data.csv"',
  "use.R" = '# put id:"use", label:"Use", input:"data.csv"'
)), show_source_info = TRUE, source_info_style = "subgraph")
add_case("edge_label_parentheses", scan_fixture("edge_label_parens", list(
  "a.R" = '# put id:"load", label:"Load", output:"./raw data (v2).csv"',
  "b.R" = '# put id:"use", label:"Use", input:"./raw data (v2).csv"'
)), show_files = TRUE)
add_case("title_with_colon", pipeline, title = "ETL: stage 1")
add_case("subgraph_keyword_and_digit_files", scan_fixture("subgraph_names", list(
  "end.R" = '# put id:"finish", label:"Finish", input:"x.csv"',
  "01_load.R" = '# put id:"load", label:"Load", output:"x.csv"'
)), show_source_info = TRUE, source_info_style = "subgraph")
add_case("artifact_path_special_characters", scan_fixture("artifact_paths", list(
  "a.R" = '# put id:"load", label:"Load", output:"./raw data (v2).csv"',
  "b.R" = '# put id:"use", label:"Use", input:"./raw data (v2).csv"'
)), show_artifacts = TRUE)
add_case("ids_equal_after_sanitizing", scan_fixture("id_collision", list(
  "a.R" = c(
    '# put id:"a-b", label:"Dash", output:"x.csv"',
    '# put id:"a_b", label:"Underscore", input:"x.csv"'
  )
)))
add_case("same_file_name_in_two_folders", scan_fixture("same_basename", list(
  "R/a.R" = '# put id:"r_step", label:"R step", output:"x.csv"',
  "py/a.py" = '# put id:"py_step", label:"Python step", input:"x.csv"'
)), show_source_info = TRUE, source_info_style = "subgraph")

# Capture groups of `pattern` for every line that matches it
match_lines <- function(code_lines, pattern) {
  matches <- regmatches(code_lines, regexec(pattern, code_lines, perl = TRUE))
  Filter(length, matches)
}

# Node definitions are lines such as `    id["label"]`, `    id(["label"])`
# or `    id{"label"}`; edges, class, click and subgraph lines never put a
# shape bracket right after the id. Artifacts, and only artifacts, use the
# cylinder `id[("file")]`.
describe_diagram <- function(code_lines) {
  definitions <- match_lines(code_lines, "^\\s+([A-Za-z0-9_]+)(\\[\\(|[\\[\\(\\{>])")
  definition_ids <- vapply(definitions, function(match) match[2], character(1))
  is_artifact <- vapply(definitions, function(match) match[3] == "[(", logical(1))
  references <- match_lines(code_lines, "^\\s+(?:class|click)\\s+(\\S+)")
  subgraphs <- match_lines(code_lines, "^\\s*subgraph\\s+([^\\s\\[]+)")
  list(
    defined_node_ids = I(definition_ids[!is_artifact]),
    defined_artifact_ids = I(definition_ids[is_artifact]),
    referenced_ids = I(vapply(references, function(match) match[2], character(1))),
    defined_subgraph_ids = I(vapply(subgraphs, function(match) match[2], character(1)))
  )
}

manifest <- lapply(cases, function(case) {
  entry <- list(
    name = case$name,
    expected_node_count = length(unique(case$workflow$id))
  )
  warning_messages <- character()
  diagram <- tryCatch(
    withCallingHandlers(
      do.call(put_diagram, c(list(case$workflow, output = "raw"), case$args)),
      warning = function(warning_condition) {
        warning_messages <<- c(warning_messages, conditionMessage(warning_condition))
        invokeRestart("muffleWarning")
      }
    ),
    error = function(error_condition) {
      entry$error <<- conditionMessage(error_condition)
      NULL
    }
  )
  if (length(warning_messages) > 0) entry$warnings <- warning_messages
  if (!is.null(diagram)) {
    entry$file <- paste0(case$name, ".mmd")
    # A binary connection writes LF line endings on Windows too
    mmd_connection <- file(file.path(output_dir, entry$file), open = "wb")
    writeLines(diagram, mmd_connection)
    close(mmd_connection)
    entry <- c(entry, describe_diagram(strsplit(diagram, "\n", fixed = TRUE)[[1]]))
  }
  entry
})

jsonlite::write_json(manifest, file.path(output_dir, "manifest.json"),
                     auto_unbox = TRUE, pretty = TRUE)
generation_errors <- sum(vapply(manifest, function(entry) !is.null(entry$error), logical(1)))
cat(sprintf("Wrote %d cases to %s (%d failed to generate)\n",
            length(manifest), output_dir, generation_errors))
