# Write a corpus of put_diagram() outputs for the Mermaid check in
# tests/mermaid/validate.mjs. Run from the package root:
#
#   Rscript tests/mermaid/generate-corpus.R tests/mermaid/corpus
#
# Each case is one .mmd file plus an entry in manifest.json. The entry holds
# the number of distinct ids in the workflow (what the diagram must show) and
# the node, artifact and subgraph ids, plus the targets of class and click
# lines, read from the generated text. With these the check can tell phantom,
# merged or lost nodes from correct ones; the number of edge lines lets it
# tell lost edges. A case can also list the texts its
# labels must show (expected_texts), for labels that Mermaid could misread.
# A case whose generation fails in R is recorded with its error instead of a
# file.

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
add_case <- function(case_name, workflow, ..., expected_texts = NULL, wide_texts = NULL,
                     must_fail = NULL, must_fail_message = NULL, expected_tooltips = NULL) {
  cases[[length(cases) + 1]] <<- list(
    name = case_name, workflow = workflow, args = list(...), expected_texts = expected_texts,
    wide_texts = wide_texts, must_fail = must_fail, must_fail_message = must_fail_message,
    expected_tooltips = expected_tooltips
  )
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
# The classic configuration is the default (#54); without it, or with
# another look
add_case("mermaid_config_none", pipeline, mermaid_config = "none")
add_case("mermaid_config_list", pipeline, title = "Sales Pipeline",
         mermaid_config = list(look = "neo", flowchart = list(curve = "basis")))
# Labels wider than Mermaid 12's 120px wrapping width, on a stadium, a
# rectangle and a diamond: the classic block's 200px must keep them on one
# line (#54, #50)
long_labels <- c(fetch = "Fetch the Monthly Sales", clean = "Clean and Validate Rows",
                 check = "Is the quality good enough?")
add_case("long_labels", scan_fixture("long_labels", list("a.R" = c(
  '# put id:"fetch", label:"Fetch the Monthly Sales", node_type:"input", output:"s.csv"',
  '# put id:"clean", label:"Clean and Validate Rows", input:"s.csv", output:"c.csv"',
  '# put id:"check", label:"Is the quality good enough?", node_type:"decision", input:"c.csv"'
))), expected_texts = unname(long_labels), wide_texts = unname(long_labels))
add_case("custom_palette", pipeline, palette = put_theme(
  base = "dark",
  input = c(fill = "#1b4332", stroke = "#95d5b2", color = "#ffffff"),
  process = c(fill = "#ffd166", color = "#000000")
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

# Chained steps in one file, one annotation each. The labels go in single
# quotes, so they may contain double quotes (#91).
chain_fixture <- function(fixture_name, labels) {
  scan_fixture(fixture_name, list("a.R" = sprintf(
    "# put id:\"%s\", label:'%s', input:\"%s.csv\", output:\"%s.csv\"",
    names(labels), labels, c("start", head(names(labels), -1)), names(labels)
  )))
}

# Labels with characters that need escaping (#33)
special_labels <- c(quote = 'Say "hi" | pipe', unicode = "Größe – naïve ✓",
                    hash = "Step #35; in C# at 100%")
add_case("label_special_characters", chain_fixture("special_labels", special_labels),
         expected_texts = unname(special_labels))

# Labels with words that Mermaid reads as syntax (#89): a direction
# statement drops the line, and "style"/"classDef" before ":...#...;" cuts
# the end off an entity. The id "lifestyle" carries the word for its label.
syntax_labels <- c(
  plot = "Change direction LR to TB", rotate = "redirection TBD",
  bold = 'style:"bold"', life = 'Lifestyle:"x"', cdef = 'classDef a:"x"',
  lifestyle = 'Note:"x"', keyed = "key:a|b", keep = "Direction LR stays"
)
add_case("labels_mermaid_reads_as_syntax", chain_fixture("syntax_labels", syntax_labels),
         expected_texts = unname(syntax_labels))
# "%%{" starts a directive, which Mermaid removes from the whole diagram
# text before it parses it: a label was cut short there, and with a later
# "}%%" the text in between was lost too (#98). The id "lifestyle" makes the
# colon escape see the ";" of the "#37;" that escapes the "%".
directive_labels <- c(
  open = "Budget 50%%{x: draft", swallow = "a %%{init: {theme: dark}", close = "b }%% c",
  triple = "Up 5%%%{y", single = "Only %{z}", lifestyle = "Note:50%%{x"
)
add_case("labels_with_directive_starts", chain_fixture("directive_labels", directive_labels),
         expected_texts = unname(directive_labels))
add_case("directive_starts_in_edge_and_subgraph_labels", scan_fixture("directive_file_names", list(
  "50%%{x.R" = '# put id:"make", label:"Make", output:"50%%{y.csv"',
  "use.R" = '# put id:"use", label:"Use", input:"50%%{y.csv"'
)), show_files = TRUE, show_source_info = TRUE, source_info_style = "subgraph",
   expected_texts = c("50%%{x.R", "50%%{y.csv"))
# Mermaid removes comment lines with a JavaScript regex whose "^" also
# matches after U+2028 and U+2029, so "%%" after one cut the line short and
# the diagram failed to parse (#104). Built by hand: such characters are
# awkward in file names on disk.
add_case("line_separators_in_labels", data.frame(
  id = c("a", "b"), label = c("a\u2028%% b", "B"),
  file_name = c("a\u2028%%x.R", "b.R"), file_path = c("a\u2028%%x.R", "b.R"),
  input = c(NA, "x\u2029%% y.csv"), output = c("x\u2029%% y.csv", NA),
  stringsAsFactors = FALSE
), title = "T\u2028%% u", show_files = TRUE, show_source_info = TRUE,
   source_info_style = "subgraph", enable_clicks = TRUE,
   expected_texts = c("a %% b", "x %% y.csv", "a %%x.R"), expected_tooltips = "Open a %%x.R")
add_case("direction_words_in_edge_and_subgraph_labels", scan_fixture("syntax_file_names", list(
  "direction LR.R" = '# put id:"make", label:"Make", output:"direction TB.csv"',
  "use.R" = '# put id:"use", label:"Use", input:"direction TB.csv"'
)), show_files = TRUE, show_source_info = TRUE, source_info_style = "subgraph",
   expected_texts = c("direction LR.R", "direction TB.csv"))
# Mermaid's direction rule also spans a line break: an edge line ending in
# an id such as "wind_direction" followed by a line starting with "LR_prep"
# lost both edges (#89)
add_case("edge_target_id_ending_in_direction", scan_fixture("direction_ids", list(
  "a.R" = c(
    '# put id:"LR_prep", label:"Prepare", output:"w.csv"',
    '# put id:"wind_direction", label:"Wind", input:"w.csv, k:#1.csv"',
    '# put id:"report", label:"Report", input:"w.csv"',
    '# put id:"lifestyle", label:"Life", output:"k:#1.csv"'
  )
)), show_files = TRUE)

# Click lines whose file names hold Mermaid syntax (#47): a space before
# LR, quotes, # and ;, and the id lifestyle for the colon rule. Each click
# line must still give its node a link, and the tooltip must read as
# written.
click_files <- data.frame(
  id = c("lifestyle", "turn", "hash", "mystyle"), label = c("Life", "Turn", "Hash", "Colon"),
  file_name = c('say "hi".R', "direction LR.R", "notes #1;.R", 'k:"v"#x;.R'),
  file_path = c('/proj/say "hi".R', "/proj/my dir/direction LR.R", "/proj/notes #1;.R",
                '/proj/k:"v"#x;.R'),
  line_number = c(3L, NA, 7L, 1L), input = c(NA, "a.csv", "b.csv", NA),
  output = c("a.csv", "b.csv", NA, NA),
  stringsAsFactors = FALSE
)
add_case("clicks_mermaid_syntax_in_paths", click_files, enable_clicks = TRUE,
         expected_tooltips = c('Open say "hi".R at line 3', "Open direction LR.R",
                               "Open notes #1;.R at line 7", 'Open k:"v"#x;.R at line 1'))

# Without artifacts nothing changes; with them, "both" adds the direct
# script-to-script edges again (#55)
add_case("artifact_edges_both", pipeline, show_artifacts = TRUE, artifact_edges = "both")

# Mermaid's default limits (#56): exactly at a limit the diagram must draw,
# one over it must fail (must_fail), where put_diagram() also warns. This
# pins put_diagram()'s counting against real Mermaid in both directions.
chain_steps <- function(step_count) {
  data.frame(
    id = paste0("s", seq_len(step_count)), label = paste("Step", seq_len(step_count)),
    file_name = paste0("s", seq_len(step_count), ".R"),
    input = c(NA, paste0("f", seq_len(step_count - 1), ".csv")),
    output = paste0("f", seq_len(step_count), ".csv"),
    stringsAsFactors = FALSE
  )
}
add_case("edges_at_limit", chain_steps(501))
add_case("edges_over_limit", chain_steps(502), must_fail = c("parse", "render"),
         must_fail_message = "Edge limit exceeded")
one_step <- function(label) {
  data.frame(id = "a", label = label, file_name = "a.R", stringsAsFactors = FALSE)
}
# The .mmd file ends with a newline, which Mermaid counts, as it does in a
# Markdown code block
text_size <- function(workflow) {
  get("mermaid_text_size", envir = asNamespace("putior"))(
    paste0(put_diagram(workflow, output = "raw"), "\n")
  )
}
size_label <- strrep("x", 50000 - text_size(one_step("x")) + 1)
stopifnot(text_size(one_step(size_label)) == 50000)
add_case("text_at_limit", one_step(size_label))
add_case("text_over_limit", one_step(paste0(size_label, "x")), must_fail = "render",
         must_fail_message = "over maxTextSize")

# Edge cases from the Mermaid gap analysis
add_case("keyword_node_id", scan_fixture("keyword_id", list(
  "a.R" = c(
    '# put id:"begin", label:"Begin", output:"a.csv"',
    '# put id:"end", label:"Finish", input:"a.csv"'
  )
)))
keyword_ids <- c("end", "graph", "flowchart", "subgraph", "style", "class",
                 "classDef", "click", "linkStyle", "call", "href", "interpolate",
                 "_self", "_blank", "_parent", "-top", "accDescr")
add_case("keyword_node_ids_all", scan_fixture("keyword_ids_all", list(
  "k.R" = sprintf('# put id:"%s", label:"Step %s", input:"%s.csv", output:"%s.csv"',
                  keyword_ids, keyword_ids, c("start", head(keyword_ids, -1)), keyword_ids)
)), enable_clicks = TRUE)
add_case("subgraph_id_equals_node_id", scan_fixture("subgraph_clash", list(
  "load.R" = '# put id:"load", label:"Load", output:"data.csv"',
  "use.R" = '# put id:"use", label:"Use", input:"data.csv"'
)), show_source_info = TRUE, source_info_style = "subgraph")
add_case("edge_label_parentheses", scan_fixture("edge_label_parens", list(
  "a.R" = '# put id:"load", label:"Load", output:"./raw data (v2).csv"',
  "b.R" = '# put id:"use", label:"Use", input:"./raw data (v2).csv"'
)), show_files = TRUE)
add_case("edge_labels_special_characters", scan_fixture("edge_label_chars", list(
  "a.R" = '# put id:"load", label:"Load", output:"a|b.csv, data #1.csv, x [y].csv"',
  "b.R" = '# put id:"use", label:"Use", input:"a|b.csv, data #1.csv, x [y].csv"'
)), show_files = TRUE, show_artifacts = TRUE)
add_case("title_with_colon", pipeline, title = "ETL: stage 1")
# A title with Mermaid syntax, for the accTitle line (#50)
add_case("title_mermaid_syntax", pipeline,
         title = 'Step #35; with direction LR, Lifestyle:#quot;x#quot; and "quotes" | pipes')
# "<" makes Mermaid's DOMPurify step write entities into the SVG title, and
# "%%{" starts a directive that can swallow the lines after it (#50). The
# drawn title garbles the "<" (put_diagram() warns, #98), so only accTitle
# is checked.
add_case("title_html_and_directive", pipeline, title = "Input < 5 MB & <draft> at 50%%{x: (y)")
# Without a "<", the drawn title shows "%%{", "&", ">" and entities as
# written: Mermaid reads the frontmatter before it removes directives (#98)
add_case("title_with_directive_start", pipeline, title = "Budget 50%%{x: draft} & #35; > less")
# A decision node whose id starts an accDescr block (#50)
add_case("accdescr_decision_id", scan_fixture("accdescr_id", list(
  "a.R" = c('# put id:"accDescr", label:"Decide", node_type:"decision", output:"x.csv"',
            '# put id:"next", label:"Next", input:"x.csv"')
)), expected_texts = c("Decide", "Next"))
add_case("title_special_characters", pipeline,
         title = 'Say "hi" # not a comment: C:\\data\\in [v2] | {x}\t\001end')
add_case("subgraph_keyword_and_digit_files", scan_fixture("subgraph_names", list(
  "end.R" = '# put id:"finish", label:"Finish", input:"x.csv"',
  "01_load.R" = '# put id:"load", label:"Load", output:"x.csv"'
)), show_source_info = TRUE, source_info_style = "subgraph")
add_case("artifact_path_special_characters", scan_fixture("artifact_paths", list(
  "a.R" = '# put id:"load", label:"Load", output:"./raw data (v2).csv"',
  "b.R" = '# put id:"use", label:"Use", input:"./raw data (v2).csv"'
)), show_artifacts = TRUE)
add_case("artifact_files_with_equal_ids", scan_fixture("artifact_collision", list(
  "w.R" = '# put id:"write_both", label:"Write", output:"a b.csv, a_b.csv"',
  "r.R" = c(
    '# put id:"read_space", label:"Read space", input:"a b.csv"',
    '# put id:"read_underscore", label:"Read underscore", input:"a_b.csv"'
  )
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
  clicks <- match_lines(code_lines, "^\\s+click\\s+(\\S+)")
  subgraphs <- match_lines(code_lines, "^\\s*subgraph\\s+([^\\s\\[]+)")
  list(
    defined_node_ids = I(definition_ids[!is_artifact]),
    defined_artifact_ids = I(definition_ids[is_artifact]),
    referenced_ids = I(vapply(references, function(match) match[2], character(1))),
    click_ids = I(vapply(clicks, function(match) match[2], character(1))),
    defined_subgraph_ids = I(vapply(subgraphs, function(match) match[2], character(1)))
  )
}

manifest <- lapply(cases, function(case) {
  # put_diagram() drops rows without an id; every other distinct id is a node
  workflow_ids <- case$workflow$id
  workflow_ids <- workflow_ids[!is.na(workflow_ids) & workflow_ids != ""]
  entry <- list(
    name = case$name,
    expected_node_count = length(unique(workflow_ids)),
    # With enable_clicks, every node drawn from a file gets a click line
    expects_clicks = isTRUE(case$args$enable_clicks)
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
  if (!is.null(case$expected_texts)) entry$expected_texts <- I(case$expected_texts)
  if (!is.null(case$must_fail)) entry$must_fail <- I(case$must_fail)
  if (!is.null(case$must_fail_message)) entry$must_fail_message <- case$must_fail_message
  if (!is.null(case$expected_tooltips)) entry$expected_tooltips <- I(case$expected_tooltips)
  if (!is.null(diagram)) {
    entry$file <- paste0(case$name, ".mmd")
    # A binary connection writes LF line endings on Windows too
    mmd_connection <- file(file.path(output_dir, entry$file), open = "wb")
    writeLines(diagram, mmd_connection)
    close(mmd_connection)
    code_lines <- strsplit(diagram, "\n", fixed = TRUE)[[1]]
    # Edge lines start with an id and " -->"; a label may contain "-->" too
    entry$expected_edge_count <- sum(grepl("^\\s+[A-Za-z0-9_]+ -->", code_lines))
    # Screen reader text (#50): the title as given, with control characters
    # as spaces, and the summary as written
    if (!is.null(case$args$title)) {
      # As putior writes them: [[:cntrl:]] matches U+2028 and U+2029 only
      # in a UTF-8 locale (#104)
      acc_title <- trimws(gsub("[[:cntrl:]\u2028\u2029]+", " ", case$args$title))
      if (nzchar(acc_title)) entry$expected_acc_title <- acc_title
      # The drawn title shows the title as written, unless it has a "<",
      # which no escape gets through Mermaid's DOMPurify step (#98)
      if (!grepl("<", case$args$title, fixed = TRUE)) {
        entry$expected_title <- gsub("[[:cntrl:]\u2028\u2029]+", " ", case$args$title)
      }
    }
    acc_descr <- sub("^    accDescr: ", "", grep("^    accDescr: ", code_lines, value = TRUE))
    if (length(acc_descr) == 1) entry$expected_acc_descr <- acc_descr
    # The look that the frontmatter sets, if any (#54)
    frontmatter_end <- if (code_lines[1] == "---") match("---", code_lines[-1]) else NA
    if (!is.na(frontmatter_end)) {
      # The top-level look; flowchart.look would override it on Mermaid 12
      frontmatter <- code_lines[seq_len(frontmatter_end)]
      look_line <- grep('^  look: "', frontmatter, value = TRUE)
      if (length(look_line) == 1 && !any(grepl('^    look: ', frontmatter))) {
        entry$expected_look <- sub('^  look: "([^"]*)".*$', "\\1", look_line)
      }
      # Labels that a 200px wrapping width keeps wider than 120px
      if (!is.null(case$wide_texts) && any(grepl("^    wrappingWidth: 200$", frontmatter))) {
        entry$wide_texts <- I(case$wide_texts)
      }
    }
    entry <- c(entry, describe_diagram(code_lines))
  }
  entry
})

jsonlite::write_json(manifest, file.path(output_dir, "manifest.json"),
                     auto_unbox = TRUE, pretty = TRUE)
generation_errors <- sum(vapply(manifest, function(entry) !is.null(entry$error), logical(1)))
cat(sprintf("Wrote %d cases to %s (%d failed to generate)\n",
            length(manifest), output_dir, generation_errors))
