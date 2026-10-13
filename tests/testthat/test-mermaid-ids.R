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
    "'a_b' and 'a-b' both become 'a_b'"
  )

  expect_equal(result$mermaid_id, c("a_b", "a_b_2", "load_data"))
})

test_that("assign_mermaid_ids() gives rows with the same raw id one Mermaid id", {
  workflow <- data.frame(id = c("load", "load", "use"), stringsAsFactors = FALSE)

  expect_no_warning(result <- assign_mermaid_ids(workflow))

  expect_equal(result$mermaid_id, c("load", "load", "use"))
})

test_that("assign_mermaid_ids() suffixes skip ids that other nodes need", {
  workflow <- data.frame(id = c("a-b", "a_b", "a_b_2"), stringsAsFactors = FALSE)

  result <- suppressWarnings(assign_mermaid_ids(workflow))

  expect_equal(result$mermaid_id, c("a_b", "a_b_3", "a_b_2"))
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
    "both become 'a_b'"
  )
  ids <- diagram_ids(diagram)

  expect_equal(sort(ids$defined), c("a_b", "a_b_2"))
  expect_match(diagram, "a_b --> a_b_2", fixed = TRUE)
  expect_match(diagram, "class a_b_2 processStyle", fixed = TRUE)
  expect_match(diagram, "click a_b_2 ", fixed = TRUE)
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
