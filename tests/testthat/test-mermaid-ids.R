# Tests for the ids put_diagram() writes into Mermaid code (#45, #46).
# tests/mermaid/ checks the same cases with a real Mermaid parser.

# Ids defined by node lines such as `    id["label"]`, and ids used by edges,
# class and click lines
diagram_ids <- function(diagram) {
  code_lines <- strsplit(diagram, "\n", fixed = TRUE)[[1]]
  defined <- sub("^\\s+([A-Za-z0-9_]+)[\\[\\(\\{>].*$", "\\1",
                 grep("^\\s+[A-Za-z0-9_]+[\\[\\(\\{>]", code_lines, value = TRUE))
  edge_lines <- grep("-->", code_lines, value = TRUE, fixed = TRUE)
  edge_ends <- unlist(lapply(edge_lines, function(edge_line) {
    edge_line <- sub("\\|.*\\|", "", edge_line)
    trimws(strsplit(edge_line, "-->", fixed = TRUE)[[1]])
  }))
  referenced <- sub("^\\s+(class|click)\\s+(\\S+).*$", "\\2",
                    grep("^\\s+(class|click)\\s", code_lines, value = TRUE))
  list(defined = defined, used = unique(c(edge_ends, referenced)))
}

test_that("assign_mermaid_ids() keeps ids apart that sanitize to the same id", {
  workflow <- data.frame(id = c("a-b", "a_b", "load.data"), stringsAsFactors = FALSE)

  expect_warning(
    result <- assign_mermaid_ids(workflow),
    "'a-b' is drawn as 'a_b_2' ('a_b' is already 'a_b')", fixed = TRUE
  )

  # The id that is already valid keeps its form, whatever the row order
  expect_equal(result$mermaid_id, c("a_b_2", "a_b", "load_data"))
  reversed <- suppressWarnings(assign_mermaid_ids(workflow[c(2, 1, 3), , drop = FALSE]))
  expect_equal(reversed$mermaid_id, c("a_b", "a_b_2", "load_data"))
})

test_that("assign_mermaid_ids() gives rows with the same raw id one Mermaid id", {
  workflow <- data.frame(id = c("load", "load", "use"), stringsAsFactors = FALSE)

  expect_no_warning(result <- assign_mermaid_ids(workflow))

  expect_equal(result$mermaid_id, c("load", "load", "use"))
})

test_that("assign_mermaid_ids() suffixes skip ids that other nodes need", {
  workflow <- data.frame(id = c("a-b", "a_b", "a_b_2"), stringsAsFactors = FALSE)

  result <- suppressWarnings(assign_mermaid_ids(workflow))

  expect_equal(result$mermaid_id, c("a_b_3", "a_b", "a_b_2"))
  expect_false(anyDuplicated(result$mermaid_id) > 0)
})

test_that("assign_mermaid_ids() renames artifacts without a warning", {
  workflow <- data.frame(
    id = c("artifact_x_csv", "artifact_x.csv"),
    is_artifact = c(FALSE, TRUE),
    stringsAsFactors = FALSE
  )

  expect_no_warning(result <- assign_mermaid_ids(workflow))

  expect_equal(result$mermaid_id, c("artifact_x_csv", "artifact_x_csv_2"))
})

test_that("artifact edges use the artifact node's id for any file path (#46)", {
  workflow <- data.frame(
    id = c("load", "use"),
    label = c("Load", "Use"),
    input = c(NA, "./raw data (v2).csv"),
    output = c("./raw data (v2).csv", NA),
    file_name = c("a.R", "b.R"),
    stringsAsFactors = FALSE
  )

  diagram <- put_diagram(workflow, show_artifacts = TRUE, output = "raw")
  ids <- diagram_ids(diagram)

  expect_true("artifact_raw_data_v2_csv" %in% ids$defined)
  expect_match(diagram, "load --> artifact_raw_data_v2_csv", fixed = TRUE)
  expect_match(diagram, "artifact_raw_data_v2_csv --> use", fixed = TRUE)
  expect_true(all(ids$used %in% ids$defined))
})

test_that("two data files with the same sanitized name get two artifact nodes", {
  workflow <- data.frame(
    id = c("write_both", "read_space", "read_underscore"),
    label = c("Write", "Read space", "Read underscore"),
    input = c(NA, "a b.csv", "a_b.csv"),
    output = c("a b.csv, a_b.csv", NA, NA),
    file_name = c("w.R", "r1.R", "r2.R"),
    stringsAsFactors = FALSE
  )

  diagram <- put_diagram(workflow, show_artifacts = TRUE, output = "raw")
  ids <- diagram_ids(diagram)

  expect_true(all(c("artifact_a_b_csv", "artifact_a_b_csv_2") %in% ids$defined))
  expect_match(diagram, "artifact_a_b_csv --> read_space", fixed = TRUE)
  expect_match(diagram, "artifact_a_b_csv_2 --> read_underscore", fixed = TRUE)
  expect_true(all(ids$used %in% ids$defined))
})

test_that("ids that sanitize to the same id stay two nodes in the diagram (#46)", {
  workflow <- data.frame(
    id = c("a-b", "a_b"),
    label = c("Dash", "Underscore"),
    node_type = c("input", "process"),
    input = c(NA, "x.csv"),
    output = c("x.csv", NA),
    file_name = c("a.R", "a.R"),
    line_number = c(1, 2),
    stringsAsFactors = FALSE
  )

  expect_warning(
    diagram <- put_diagram(workflow, enable_clicks = TRUE, output = "raw"),
    "'a-b' is drawn as 'a_b_2'", fixed = TRUE
  )
  ids <- diagram_ids(diagram)

  expect_equal(sort(ids$defined), c("a_b", "a_b_2"))
  expect_match(diagram, "a_b_2 --> a_b", fixed = TRUE)
  expect_match(diagram, "class a_b processStyle", fixed = TRUE)
  expect_match(diagram, "class a_b_2 inputStyle", fixed = TRUE)
  expect_match(diagram, "click a_b_2 ", fixed = TRUE)
  expect_match(diagram, "click a_b ", fixed = TRUE)
  expect_true(all(ids$used %in% ids$defined))
})

test_that("a Mermaid keyword as id is written as node_<keyword> everywhere (#45)", {
  workflow <- data.frame(
    id = c("begin", "end"),
    label = c("Begin", "Finish"),
    node_type = c("start", "end"),
    input = c(NA, "a.csv"),
    output = c("a.csv", NA),
    file_name = c("a.R", "a.R"),
    line_number = c(1, 2),
    stringsAsFactors = FALSE
  )

  diagram <- put_diagram(workflow, enable_clicks = TRUE, output = "raw")
  ids <- diagram_ids(diagram)

  expect_true("node_end" %in% ids$defined)
  expect_false("end" %in% ids$defined)
  expect_match(diagram, "begin --> node_end", fixed = TRUE)
  expect_match(diagram, "class node_end endStyle", fixed = TRUE)
  expect_match(diagram, "click node_end ", fixed = TRUE)
  expect_true(all(ids$used %in% ids$defined))
})

# A workflow as put() returns it, for subgraph tests
subgraph_workflow <- function(ids, file_paths) {
  data.frame(
    id = ids,
    label = toupper(ids),
    node_type = "process",
    input = c(NA, rep("x.csv", length(ids) - 1)),
    output = c("x.csv", rep(NA, length(ids) - 1)),
    file_name = basename(file_paths),
    file_path = file_paths,
    stringsAsFactors = FALSE
  )
}

subgraph_ids_of <- function(diagram) {
  code_lines <- strsplit(diagram, "\n", fixed = TRUE)[[1]]
  sub("^\\s*subgraph\\s+(\\S+)\\s.*$", "\\1", grep("^\\s*subgraph\\s", code_lines, value = TRUE))
}

test_that("a subgraph id never equals a node id (#45)", {
  workflow <- subgraph_workflow(c("load", "use"), c("/p/load.R", "/p/use.R"))

  diagram <- put_diagram(workflow, show_source_info = TRUE,
                         source_info_style = "subgraph", output = "raw")

  expect_equal(subgraph_ids_of(diagram), c("file_load", "file_use"))
  expect_true(all(c("load", "use") %in% diagram_ids(diagram)$defined))
})

test_that("a subgraph id skips a node id that already starts with file_", {
  workflow <- subgraph_workflow(c("file_load", "use"), c("/p/load.R", "/p/use.R"))

  diagram <- put_diagram(workflow, show_source_info = TRUE,
                         source_info_style = "subgraph", output = "raw")

  expect_equal(subgraph_ids_of(diagram), c("file_load_2", "file_use"))
})

test_that("files with the same name in two folders get two subgraphs (#46)", {
  workflow <- subgraph_workflow(c("r_step", "py_step", "other"),
                                c("/p/R/a.R", "/p/py/a.py", "/p/x/a.R"))

  diagram <- put_diagram(workflow, show_source_info = TRUE,
                         source_info_style = "subgraph", output = "raw")

  expect_equal(subgraph_ids_of(diagram), c("file_a", "file_a_2", "file_a_3"))
  # a.R appears twice, so both labels show the folder; a.py is unique
  expect_match(diagram, 'subgraph file_a ["R/a.R"]', fixed = TRUE)
  expect_match(diagram, 'subgraph file_a_2 ["a.py"]', fixed = TRUE)
  expect_match(diagram, 'subgraph file_a_3 ["x/a.R"]', fixed = TRUE)
})

test_that("subgraphs fall back to file_name without a file_path column", {
  workflow <- subgraph_workflow(c("load", "use"), c("load.R", "use.R"))
  workflow$file_path <- NULL

  diagram <- put_diagram(workflow, show_source_info = TRUE,
                         source_info_style = "subgraph", output = "raw")

  expect_equal(subgraph_ids_of(diagram), c("file_load", "file_use"))
})

test_that("edge labels are quoted and escaped like node labels (#45)", {
  expect_equal(make_edge("a", "b", "./raw data (v2).csv", show_label = TRUE),
               '    a -->|"./raw data (v2).csv"| b')
  expect_equal(make_edge("a", "b", 'say "hi" | bye', show_label = TRUE),
               '    a -->|"say #quot;hi#quot; #124; bye"| b')
  expect_equal(make_edge("a", "b", "x.csv", show_label = FALSE), "    a --> b")
})

test_that("the title is a quoted YAML string (#45)", {
  expect_equal(yaml_quote("ETL: stage 1"), '"ETL: stage 1"')
  expect_equal(yaml_quote('Say "hi"'), '"Say \\"hi\\""')
  expect_equal(yaml_quote("C:\\data"), '"C:\\\\data"')
  expect_equal(yaml_quote("two\nlines"), '"two lines"')
  expect_equal(yaml_quote("tab\there\001bell"), '"tab here bell"')

  workflow <- data.frame(id = "a", label = "A", file_name = "a.R", stringsAsFactors = FALSE)
  diagram <- put_diagram(workflow, title = "ETL: stage 1 # first", output = "raw",
                         mermaid_config = "none")
  expect_match(diagram, '^---\ntitle: "ETL: stage 1 # first"\n---\nflowchart TD')
})

test_that("put_diagram() writes the classic Mermaid configuration by default (#54)", {
  workflow <- data.frame(id = "a", label = "A", file_name = "a.R", stringsAsFactors = FALSE)
  classic_block <- paste(
    "---", "config:", '  layout: "dagre"', '  look: "classic"', "  flowchart:",
    "    wrappingWidth: 200", "    minNodeWidth: 0", "---", "flowchart TD",
    sep = "\n"
  )
  expect_true(startsWith(put_diagram(workflow, output = "raw"), classic_block))
  # The title shares the frontmatter
  expect_true(startsWith(
    put_diagram(workflow, output = "raw", title = "ETL"),
    paste0('---\ntitle: "ETL"\nconfig:\n  layout: "dagre"')
  ))
  # "none" gives the old output, without frontmatter
  expect_true(startsWith(put_diagram(workflow, output = "raw", mermaid_config = "none"),
                         "flowchart TD\n"))
  # The classic block never sets a theme, which would override the host's
  expect_false(grepl("theme", put_diagram(workflow, output = "raw"), fixed = TRUE))
})

test_that("put_diagram() writes a named list as the Mermaid configuration (#54)", {
  workflow <- data.frame(id = "a", label = "A", file_name = "a.R", stringsAsFactors = FALSE)
  diagram <- put_diagram(workflow, output = "raw", mermaid_config = list(
    look = "neo", flowchart = list(curve = "basis", htmlLabels = TRUE, wrappingWidth = 150)
  ))
  expect_true(startsWith(diagram, paste(
    "---", "config:", '  look: "neo"', "  flowchart:", '    curve: "basis"',
    "    htmlLabels: true", "    wrappingWidth: 150", "---", sep = "\n"
  )))
  # A theme is left out with a warning
  expect_warning(
    themed <- put_diagram(workflow, output = "raw", mermaid_config = list(theme = "dark", look = "neo")),
    "'theme' is left out"
  )
  expect_false(grepl("theme", themed, fixed = TRUE))
  # Only the theme: no configuration is left
  expect_warning(only_theme <- put_diagram(workflow, output = "raw", mermaid_config = list(theme = "dark")))
  expect_true(startsWith(only_theme, "flowchart TD"))
  expect_true(startsWith(put_diagram(workflow, output = "raw", mermaid_config = list()), "flowchart TD"))
})

test_that("put_diagram() writes accTitle and accDescr for screen readers (#50)", {
  workflow <- data.frame(
    id = c("a", "b"), label = c("A", "B"), file_name = c("a.R", "b.R"),
    input = c(NA, "x.csv"), output = c("x.csv", "y.csv"), stringsAsFactors = FALSE
  )
  diagram <- put_diagram(workflow, output = "raw", mermaid_config = "none", title = "Sales")
  expect_match(diagram, 'flowchart TD\n    accTitle: Sales\n    accDescr: Workflow with 2 steps and 2 data files.\n',
               fixed = TRUE)
  # Without a title only the summary; singular forms; no files
  single <- put_diagram(workflow[1, ], output = "raw", mermaid_config = "none")
  expect_match(single, "flowchart TD\n    accDescr: Workflow with 1 step and 1 data file.\n", fixed = TRUE)
  expect_false(grepl("accTitle", single, fixed = TRUE))
  no_files <- data.frame(id = "a", label = "A", file_name = "a.R", stringsAsFactors = FALSE)
  expect_match(put_diagram(no_files, output = "raw"), "accDescr: Workflow with 1 step.\n", fixed = TRUE)
  # accessibility = FALSE leaves both out
  expect_false(grepl("acc(Title|Descr)", put_diagram(workflow, output = "raw", title = "T",
                                                      accessibility = FALSE)))
})

test_that("the accTitle text is escaped like a label, but keeps quotes (#50)", {
  workflow <- data.frame(id = "a", label = "A", file_name = "a.R", stringsAsFactors = FALSE)
  title_line <- function(title) {
    code_lines <- strsplit(put_diagram(workflow, output = "raw", title = title), "\n", fixed = TRUE)[[1]]
    grep("^    accTitle: ", code_lines, value = TRUE)
  }
  expect_equal(title_line('Say "hi" | ok'), '    accTitle: Say "hi" | ok')
  expect_equal(title_line("Step #35; and C#"), "    accTitle: Step #35;35; and C#")
  expect_equal(title_line("Set direction LR"), "    accTitle: Set direction#32;LR")
  expect_equal(title_line('Lifestyle:#quot;x'), "    accTitle: Lifestyle#58;#35;quot;x")
  # Control characters become spaces; a blank title gives no accTitle
  expect_equal(title_line("tab\there\001bell"), "    accTitle: tab here bell")
  expect_length(title_line("   "), 0)
  # "<" would go through DOMPurify (it warns, for the drawn title, #98),
  # "%%{" would start a directive
  expect_warning(less_than_line <- title_line("Input < 5 & ok"), 'title contains "<"', fixed = TRUE)
  expect_equal(less_than_line, "    accTitle: Input #60; 5 & ok")
  expect_equal(title_line("50%%{x: y"), "    accTitle: 50#37;%{x: y")
  expect_equal(title_line("50%% done"), "    accTitle: 50%% done")
  # The colon escape runs last, so that it sees the ";" of "#60;"
  expect_warning(colon_line <- title_line("style a:<b"), 'title contains "<"', fixed = TRUE)
  expect_equal(colon_line, "    accTitle: style a#58;#60;b")
})

test_that("accDescr counts unique steps and data files only (#50)", {
  workflow <- data.frame(
    id = c("a", "a", "b", "c"), label = c("A", "A2", "B", "C"),
    file_name = c("a.R", "a2.R", "utils.R", "c.R"),
    input = c(NA, NA, NA, "utils.R, x.csv, y.internal"),
    output = c("x.csv", "x.csv", "utils.R", "y.internal"),
    stringsAsFactors = FALSE
  )
  diagram <- suppressWarnings(put_diagram(workflow, output = "raw"))
  # Three ids; utils.R is a script and y.internal a variable, so one file
  expect_match(diagram, "accDescr: Workflow with 3 steps and 1 data file.", fixed = TRUE)
})

test_that("put_diagram() checks title and accessibility (#50)", {
  workflow <- data.frame(id = "a", label = "A", file_name = "a.R", stringsAsFactors = FALSE)
  expect_error(put_diagram(workflow, output = "raw", title = c("A", "B")),
               "title must be a single string")
  expect_error(put_diagram(workflow, output = "raw", title = NA), "title must be a single string")
  # A number is written as text, as before
  expect_match(put_diagram(workflow, output = "raw", title = 2026), 'title: "2026"', fixed = TRUE)
  for (bad_value in list(NA, 1, "yes", NULL, c(TRUE, FALSE))) {
    expect_error(put_diagram(workflow, output = "raw", accessibility = bad_value),
                 "accessibility must be TRUE or FALSE")
  }
})

test_that("put_diagram() warns about a < in the title (#98)", {
  workflow <- data.frame(id = "a", label = "A", file_name = "a.R", stringsAsFactors = FALSE)
  # Mermaid's DOMPurify step garbles the drawn title, whatever the escape
  expect_warning(put_diagram(workflow, output = "raw", title = "Input < 5 MB"),
                 'The title contains "<"', fixed = TRUE)
  expect_warning(put_diagram(workflow, output = "raw", title = "<draft> Report",
                             accessibility = FALSE),
                 'The title contains "<"', fixed = TRUE)
  # The frontmatter title is written as given: Mermaid shows "&", ">",
  # "%%{" and entities in it as written
  expect_no_warning(diagram <- put_diagram(workflow, output = "raw", mermaid_config = "none",
                                           title = "A & B > C at 50%%{x: #35;"))
  expect_match(diagram, '^---\ntitle: "A & B > C at 50%%\\{x: #35;"\n---\n')
})

test_that("a decision node with the id accDescr keeps its shape (#50)", {
  workflow <- data.frame(id = "accDescr", label = "Decide", node_type = "decision",
                         file_name = "a.R", stringsAsFactors = FALSE)
  expect_match(put_diagram(workflow, output = "raw"), 'node_accDescr{"Decide"}', fixed = TRUE)
})

test_that("put_diagram() rejects a mermaid_config it cannot write (#54)", {
  workflow <- data.frame(id = "a", label = "A", file_name = "a.R", stringsAsFactors = FALSE)
  for (bad_config in list("neo", 3, c("classic", "none"), list(1), list("a b" = 1))) {
    expect_error(put_diagram(workflow, output = "raw", mermaid_config = bad_config),
                 "mermaid_config must be")
  }
  expect_error(put_diagram(workflow, output = "raw", mermaid_config = list(look = c("a", "b"))),
               "the value of 'look'")
  expect_error(put_diagram(workflow, output = "raw", mermaid_config = list(look = NA)),
               "the value of 'look'")
  # Mermaid rejects a key given twice, and reads Inf as a string
  expect_error(put_diagram(workflow, output = "raw",
                           mermaid_config = list(look = "neo", look = "classic")),
               "'look' is given more than once")
  expect_error(put_diagram(workflow, output = "raw",
                           mermaid_config = list(flowchart = list(wrappingWidth = Inf))),
               "the value of 'wrappingWidth'")
  # An empty nested list writes nothing
  expect_true(startsWith(
    put_diagram(workflow, output = "raw", mermaid_config = list(look = "neo", flowchart = list())),
    '---\nconfig:\n  look: "neo"\n---'
  ))
})

test_that("a # that starts an entity is escaped, a plain # is not (#45)", {
  expect_equal(sanitize_mermaid_label("Step #35; done"), '"Step #35;35; done"')
  expect_equal(sanitize_mermaid_label("say #quot;hi"), '"say #35;quot;hi"')
  # A plain # stays: escaping it would show "&#35;" with htmlLabels off
  expect_equal(sanitize_mermaid_label("C# code, item #1"), '"C# code, item #1"')
  # The # escape runs first, so putior's own entities stay intact
  expect_equal(sanitize_mermaid_label('a "b" | #1'), '"a #quot;b#quot; #124; #1"')
})

test_that("words that Mermaid reads as a direction statement are escaped (#89)", {
  expect_equal(sanitize_mermaid_label("Set direction LR here"), '"Set direction#32;LR here"')
  for (direction in c("TB", "BT", "RL", "LR", "TD")) {
    expect_equal(sanitize_mermaid_label(paste("direction", direction)),
                 paste0('"direction#32;', direction, '"'))
  }
  # Mermaid's rule has no word boundaries
  expect_equal(sanitize_mermaid_label("redirection TBD"), '"redirection#32;TBD"')
  # Only the first whitespace character is escaped, as the entity of itself
  expect_equal(sanitize_mermaid_label("direction  LR"), '"direction#32; LR"')
  expect_equal(sanitize_mermaid_label("direction\tLR"), '"direction#9;LR"')
  expect_equal(sanitize_mermaid_label("direction\u00a0LR"), '"direction#160;LR"')
  expect_equal(sanitize_mermaid_label("direction LR, then direction TB"),
               '"direction#32;LR, then direction#32;TB"')
  # The rule is case-sensitive and needs whitespace
  expect_equal(sanitize_mermaid_label("Direction LR"), '"Direction LR"')
  expect_equal(sanitize_mermaid_label("direction lr"), '"direction lr"')
  expect_equal(sanitize_mermaid_label("directionLR"), '"directionLR"')
})

test_that("colons that let Mermaid cut an entity short are escaped (#89)", {
  expect_equal(sanitize_mermaid_label('style:"bold"'), '"style#58;#quot;bold#quot;"')
  expect_equal(sanitize_mermaid_label('Lifestyle:"x"'), '"Lifestyle#58;#quot;x#quot;"')
  expect_equal(sanitize_mermaid_label('classDef a:"x"'), '"classDef a#58;#quot;x#quot;"')
  # "style" can come from the node id, so the colon is escaped without it
  expect_equal(sanitize_mermaid_label('Note:"x"'), '"Note#58;#quot;x#quot;"')
  expect_equal(sanitize_mermaid_label('a:b:"c"'), '"a#58;b#58;#quot;c#quot;"')
  expect_equal(sanitize_mermaid_label("key:a|b"), '"key#58;a#124;b"')
  # A colon without a # and a ; after it in the same word stays
  expect_equal(sanitize_mermaid_label("Step 1: load"), '"Step 1: load"')
  expect_equal(sanitize_mermaid_label('Note: "x"'), '"Note: #quot;x#quot;"')
  expect_equal(sanitize_mermaid_label("Rank:#1 of 3"), '"Rank:#1 of 3"')
  expect_equal(sanitize_mermaid_label("a|b:c"), '"a#124;b:c"')
})

test_that("colons are escaped only after style or classDef on the line (#89)", {
  # With the text in front of the label, only colons that Mermaid's rule can
  # reach are escaped; without it, all of them
  expect_equal(sanitize_mermaid_label('Note:"x"', line_start = "plain"), '"Note:#quot;x#quot;"')
  expect_equal(sanitize_mermaid_label('Note:"x"', line_start = "lifestyle"),
               '"Note#58;#quot;x#quot;"')
  expect_equal(sanitize_mermaid_label("key:a|b", line_start = "classDef_step"), '"key#58;a#124;b"')
  # The word must come before the colon
  expect_equal(sanitize_mermaid_label('a:"x" style:"y"', line_start = "a"),
               '"a:#quot;x#quot; style#58;#quot;y#quot;"')
  # The id and the label are not one word
  expect_equal(sanitize_mermaid_label('le:"v"', line_start = "sty"), '"le:#quot;v#quot;"')
  # The colon escape sees the entity that the direction escape writes
  expect_equal(sanitize_mermaid_label("style:direction LR", line_start = "a"),
               '"style#58;direction#32;LR"')
})

test_that("an edge to an id ending in direction ends with a semicolon (#89)", {
  # Mermaid's \s+ spans line breaks, so "... wind_direction" followed by a
  # line starting with "LR_prep" read as one direction statement
  expect_equal(make_edge("LR_prep", "wind_direction"), "    LR_prep --> wind_direction;")
  expect_equal(make_edge("a", "direction", "f.csv", show_label = TRUE),
               '    a -->|"f.csv"| direction;')
  expect_equal(make_edge("wind_direction", "b"), "    wind_direction --> b")
  expect_equal(make_edge("a", "Direction"), "    a --> Direction")

  # That ";" can complete Mermaid's colon rule, which would strip it again
  edge_line <- make_edge("lifestyle", "wind_direction", "k:#1.csv", show_label = TRUE)
  expect_equal(edge_line, '    lifestyle -->|"k#58;#1.csv"| wind_direction;')
  expect_false(grepl("(style|classDef).*:\\S*#.*;", edge_line))
  # Without the ";" the colon stays
  expect_equal(make_edge("lifestyle", "b", "k:#1.csv", show_label = TRUE),
               '    lifestyle -->|"k:#1.csv"| b')
})

test_that("no diagram line matches the Mermaid rules that eat labels (#89)", {
  workflow <- data.frame(
    id = c("lifestyle", "classDef_step", "plot", "LR_prep", "wind_direction", "report"),
    label = c('Note:"x"', 'Filter:"a|b"', "Set direction LR", 'k:"v"', "Wind", "Report"),
    file_name = c("style:a.R", "direction TB.R", "plot.R", "prep.R", "wind.R", "report.R"),
    file_path = c("x/style:a.R", "x/direction TB.R", "y/plot.R", "prep.R", "wind.R", "report.R"),
    input = c(NA, "direction RL.csv", 'k:"v".csv', NA, "w.csv", "w.csv"),
    output = c("direction RL.csv", 'k:"v".csv', NA, "w.csv", NA, NA),
    stringsAsFactors = FALSE
  )
  diagrams <- list(
    put_diagram(workflow, output = "raw", show_files = TRUE),
    put_diagram(workflow, output = "raw", show_artifacts = TRUE),
    put_diagram(workflow, output = "raw", show_source_info = TRUE),
    put_diagram(workflow, output = "raw", show_source_info = TRUE,
                source_info_style = "subgraph", node_labels = "both")
  )
  for (diagram in diagrams) {
    code_lines <- strsplit(diagram, "\n", fixed = TRUE)[[1]]
    # Mermaid's lexer rule (its \\s+ spans line breaks) and the two lines of
    # its encodeEntities()
    expect_false(grepl("direction\\s+(TB|BT|RL|LR|TD)", diagram))
    expect_false(any(grepl("(style|classDef).*:\\S*#.*;", code_lines)))
  }
  expect_match(diagrams[[1]], 'lifestyle["Note#58;#quot;x#quot;"]', fixed = TRUE)
  # Without style or classDef on the line, the colon stays
  expect_match(diagrams[[1]], 'LR_prep["k:#quot;v#quot;"]', fixed = TRUE)
  expect_match(diagrams[[1]], '|"direction#32;RL.csv"|', fixed = TRUE)
  expect_match(diagrams[[4]], '["direction#32;TB.R"]', fixed = TRUE)
})

test_that("the start of a Mermaid directive in a label is escaped (#98)", {
  # Mermaid removes "%%{...}%%" from the whole diagram text before parsing
  expect_equal(sanitize_mermaid_label("Budget 50%%{x: draft"), '"Budget 50#37;%{x: draft"')
  expect_equal(sanitize_mermaid_label("Up 5%%%{y"), '"Up 5%#37;%{y"')
  expect_equal(sanitize_mermaid_label("%%{a}%% and %%{b"), '"#37;%{a}%% and #37;%{b"')
  # Without "%%{" nothing changes
  expect_equal(sanitize_mermaid_label("Only %{z} at 50%% }%%"), '"Only %{z} at 50%% }%%"')
  # The colon escape runs after it and sees the ";" of "#37;"
  expect_equal(sanitize_mermaid_label("style:50%%{x", line_start = "a"), '"style#58;50#37;%{x"')
  expect_equal(sanitize_mermaid_label("Note:50%%{x", line_start = "plain"), '"Note:50#37;%{x"')

  # Node, edge and subgraph labels and click tooltips all get it
  workflow <- data.frame(
    id = c("make", "use"), label = c("Budget 50%%{x: draft", "Use"),
    file_name = c("50%%{x.R", "use.R"), file_path = c("50%%{x.R", "use.R"),
    input = c(NA, "50%%{y.csv"), output = c("50%%{y.csv", NA), stringsAsFactors = FALSE
  )
  diagram <- put_diagram(workflow, output = "raw", show_files = TRUE, show_source_info = TRUE,
                         source_info_style = "subgraph", enable_clicks = TRUE)
  expect_false(grepl("%%{", diagram, fixed = TRUE))
  expect_match(diagram, 'make["Budget 50#37;%{x: draft"]', fixed = TRUE)
  expect_match(diagram, '|"50#37;%{y.csv"|', fixed = TRUE)
  expect_match(diagram, '["50#37;%{x.R"]', fixed = TRUE)
  expect_match(diagram, '"Open 50#37;%{x.R', fixed = TRUE)
})

test_that("U+2028 and U+2029 are written as spaces (#104)", {
  # Mermaid's comment regex treats them as line ends, so "%%" after one
  # removed the rest of the line
  expect_equal(sanitize_mermaid_label("a\u2028%% b"), '"a %% b"')
  expect_equal(sanitize_mermaid_label("a\u2029%% b"), '"a %% b"')
  expect_equal(yaml_quote("T\u2028%% u"), '"T %% u"')
  expect_equal(click_tooltip("a\u2029b.R"), "Open a b.R")
  # Empty input stays empty
  expect_identical(replace_line_separators(character(0)), character(0))
  expect_equal(yaml_quote(character(0)), '""')
  # Encoding marks are kept, and other non-ASCII text is left alone
  expect_identical(Encoding(sanitize_mermaid_label("caf\u00e9\u2028x")), "UTF-8")
  expect_equal(yaml_quote("caf\u00e9 \u00fcber"), "\"caf\u00e9 \u00fcber\"")

  # base R's basename() cannot translate these file names in a C locale
  skip_if_not(l10n_info()[["UTF-8"]], "needs a UTF-8 locale")
  workflow <- data.frame(
    id = c("a", "b"), label = c("a\u2028%% b", "B"),
    file_name = c("a\u2028x.R", "b.R"), file_path = c("a\u2028x.R", "b.R"),
    input = c(NA, "x\u2029y.csv"), output = c("x\u2029y.csv", NA), stringsAsFactors = FALSE
  )
  diagram <- put_diagram(workflow, output = "raw", title = "T\u2028u", show_files = TRUE,
                         show_source_info = TRUE, source_info_style = "subgraph",
                         enable_clicks = TRUE)
  expect_false(grepl("[\u2028\u2029]", diagram))
  expect_match(diagram, 'a["a %% b"]', fixed = TRUE)
  expect_match(diagram, "accTitle: T u", fixed = TRUE)
})

test_that("put_diagram() warns about a < that starts an HTML tag in a label (#102)", {
  label_code <- function(label) {
    paste0('flowchart TD\n    a[', sanitize_mermaid_label(label), ']')
  }
  # A "<" before a letter that starts no intended tag
  for (label in c("a<b and c>d", "<draft> Report", "n<threshold", "x </foo> y", "<bold>", "ok a<b",
                  "a<!b c> d", "a<!-- c --> d", "a<?b c> d", "a </ b c> d", "a</5 c> d")) {
    expect_length(find_html_in_labels(label_code(label)), 1)
  }
  # Intended tags, with attribute values; "<" before a space or a digit; "&lt;"
  for (label in c("<b>x</b>", "a<br/>b", "a<BR />b", "<span style='color:red'>x</span>",
                  "<sub>2</sub> <sup>3</sup> <code>c</code> <em>e</em> <strong>s</strong> <i>i</i>",
                  "x < 5", "x<5", "a &lt;b", "x <- y", "a<=b")) {
    expect_length(find_html_in_labels(label_code(label)), 0)
  }
  # Entities are decoded for the message
  expect_equal(decode_label_entities('say #quot;hi#quot; #124; #35;35; <x>'), 'say "hi" | #35; <x>')

  # Drawn labels only: node, edge and subgraph labels, not the title, accTitle
  # or a file name that is not drawn
  workflow <- data.frame(
    id = c("a", "b"), label = c("Filter n<threshold", "B"), file_name = c("a<b.R", "b.R"),
    input = c(NA, "x<y.csv"), output = c("x<y.csv", NA), stringsAsFactors = FALSE
  )
  edge_warning <- tryCatch(put_diagram(workflow, output = "raw", show_files = TRUE),
                           warning = conditionMessage)
  expect_match(edge_warning, '2 labels contain a "<" before a letter', fixed = TRUE)
  expect_match(edge_warning, '"Filter n<threshold", "x<y.csv"', fixed = TRUE)
  expect_no_warning(put_diagram(workflow[2, ], output = "raw", show_source_info = TRUE,
                                source_info_style = "subgraph"))
  subgraph_warning <- tryCatch(put_diagram(workflow, output = "raw", show_source_info = TRUE,
                                           source_info_style = "subgraph"),
                               warning = conditionMessage)
  expect_match(subgraph_warning, '"a<b.R", "Filter n<threshold"', fixed = TRUE)
  # putior's own <br/> (show_source_info) and a title with a lone quote
  plain <- data.frame(id = "a", label = "A", file_name = "a.R", stringsAsFactors = FALSE)
  expect_no_warning(put_diagram(plain, output = "raw", show_source_info = TRUE,
                                title = 'Say "hi on a 5" screen'))
  # A "<" in the title gives only the title warning (#98), not this one too
  title_warnings <- character()
  withCallingHandlers(
    put_diagram(plain, output = "raw", title = "a<b c"),
    warning = function(warning_condition) {
      title_warnings <<- c(title_warnings, conditionMessage(warning_condition))
      invokeRestart("muffleWarning")
    }
  )
  expect_length(title_warnings, 1)
  expect_match(title_warnings, "The title contains", fixed = TRUE)
  # A label drawn twice is listed once
  twice <- data.frame(id = c("a", "b"), label = c("same <x>", "same <x>"),
                      file_name = "a.R", stringsAsFactors = FALSE)
  expect_warning(put_diagram(twice, output = "raw"), "^A label contains")
})

test_that("direction = \"TB\" is accepted (#79)", {
  workflow <- data.frame(id = "a", label = "A", file_name = "a.R", stringsAsFactors = FALSE)

  expect_match(put_diagram(workflow, direction = "TB", output = "raw"), "flowchart TB", fixed = TRUE)
  expect_error(put_diagram(workflow, direction = "XY", output = "raw"))
})

test_that("make_unique_ids() suffixes repeats without taking another id", {
  expect_equal(make_unique_ids(c("a", "b", "a", "a_2", "a")), c("a", "b", "a_3", "a_2", "a_4"))
  expect_equal(make_unique_ids(character()), character())
})

test_that("put_auto() gives files with the same derived id distinct ids (#46)", {
  auto_dir <- tempfile("putior_auto_ids_")
  dir.create(file.path(auto_dir, "x"), recursive = TRUE)
  dir.create(file.path(auto_dir, "y"))
  on.exit(unlink(auto_dir, recursive = TRUE), add = TRUE)
  writeLines('d <- read.csv("in.csv")', file.path(auto_dir, "a-b.R"))
  writeLines('d <- read.csv("in.csv")', file.path(auto_dir, "a_b.R"))
  writeLines('d <- read.csv("in.csv")', file.path(auto_dir, "x", "load.R"))
  writeLines('d <- read.csv("in.csv")', file.path(auto_dir, "y", "load.R"))

  workflow <- put_auto(auto_dir)

  expect_equal(nrow(workflow), 4)
  expect_false(anyDuplicated(workflow$id) > 0)
  expect_setequal(workflow$id, c("a_b", "a_b_2", "load", "load_2"))

  diagram <- put_diagram(workflow, show_source_info = TRUE,
                         source_info_style = "subgraph", output = "raw")
  expect_equal(length(unique(diagram_ids(diagram)$defined)), 4)
})

test_that("put_generate() suggests different ids for files with the same name", {
  generate_dir <- tempfile("putior_generate_ids_")
  dir.create(file.path(generate_dir, "x"), recursive = TRUE)
  dir.create(file.path(generate_dir, "y"))
  on.exit(unlink(generate_dir, recursive = TRUE), add = TRUE)
  writeLines('d <- read.csv("in.csv")', file.path(generate_dir, "x", "load.R"))
  writeLines('d <- read.csv("in.csv")', file.path(generate_dir, "y", "load.R"))

  annotations <- paste(put_generate(generate_dir, output = "raw", style = "single"),
                       collapse = "\n")

  expect_match(annotations, 'id:"load"', fixed = TRUE)
  expect_match(annotations, 'id:"load_2"', fixed = TRUE)
})

test_that("labels show as much folder as it takes to tell files apart", {
  workflow <- subgraph_workflow(c("one", "two", "three"),
                                c("/p/a/x/load.R", "/p/b/x/load.R", "/p/c/run.R"))

  diagram <- put_diagram(workflow, show_source_info = TRUE,
                         source_info_style = "subgraph", output = "raw")

  expect_match(diagram, '["a/x/load.R"]', fixed = TRUE)
  expect_match(diagram, '["b/x/load.R"]', fixed = TRUE)
  expect_match(diagram, '["run.R"]', fixed = TRUE)
})

test_that("make_unique_ids() can compare ids in their Mermaid form", {
  expect_equal(make_unique_ids(c("a__b", "a_b"), key = sanitize_node_id), c("a__b", "a_b_2"))
  expect_equal(make_unique_ids(c("end", "node_end"), key = sanitize_node_id), c("end", "node_end_2"))
  expect_equal(make_unique_ids(c("a__b", "a_b")), c("a__b", "a_b"))
})

test_that("put_auto() ids stay distinct after Mermaid sanitizing", {
  auto_dir <- tempfile("putior_auto_mermaid_ids_")
  dir.create(auto_dir)
  on.exit(unlink(auto_dir, recursive = TRUE), add = TRUE)
  for (file_name in c("a--b.R", "a_b.R", "end.R", "node_end.R")) {
    writeLines('d <- read.csv("in.csv")', file.path(auto_dir, file_name))
  }

  workflow <- put_auto(auto_dir)
  mermaid_ids <- vapply(workflow$id, sanitize_node_id, character(1))

  expect_false(anyDuplicated(mermaid_ids) > 0)
  expect_no_warning(put_diagram(workflow, output = "raw"))
})
