# Test suite for put_generate() and put_merge() functions
library(testthat)
library(putior)

# Tests for put_generate()
test_that("put_generate() generates annotation output", {
  temp_dir <- tempdir()
  test_dir <- file.path(temp_dir, "putior_test_generate")
  dir.create(test_dir, showWarnings = FALSE)
  on.exit(unlink(test_dir, recursive = TRUE))

  r_content <- c(
    "data <- read.csv('input.csv')",
    "write.csv(data, 'output.csv')"
  )
  create_test_file(r_content, "process.R", test_dir)

  # Capture output
  result <- put_generate(test_dir, output = "console")

  expect_type(result, "character")
  expect_true(length(result) > 0)
})

test_that("put_generate() produces valid PUT annotation syntax", {
  temp_dir <- tempdir()
  test_dir <- file.path(temp_dir, "putior_test_generate_syntax")
  dir.create(test_dir, showWarnings = FALSE)
  on.exit(unlink(test_dir, recursive = TRUE))

  r_content <- c("data <- read.csv('input.csv')")
  create_test_file(r_content, "load.R", test_dir)

  result <- put_generate(test_dir, output = "console")

  # Check annotation contains expected parts
  combined <- paste(result, collapse = "\n")
  expect_true(grepl("#put", combined))
  expect_true(grepl('id:"', combined))
  expect_true(grepl('label:"', combined))
})

test_that("put_generate() supports single-line style", {
  temp_dir <- tempdir()
  test_dir <- file.path(temp_dir, "putior_test_generate_single")
  dir.create(test_dir, showWarnings = FALSE)
  on.exit(unlink(test_dir, recursive = TRUE))

  r_content <- c("data <- read.csv('input.csv')")
  create_test_file(r_content, "load.R", test_dir)

  result <- put_generate(test_dir, output = "console", style = "single")

  combined <- paste(result, collapse = "\n")
  # Single line should not have backslash continuations
  expect_false(grepl("\\\\\n", combined))
})

test_that("put_generate() supports multiline style", {
  temp_dir <- tempdir()
  test_dir <- file.path(temp_dir, "putior_test_generate_multi")
  dir.create(test_dir, showWarnings = FALSE)
  on.exit(unlink(test_dir, recursive = TRUE))

  r_content <- c(
    "data <- read.csv('input.csv')",
    "write.csv(data, 'output.csv')"
  )
  create_test_file(r_content, "process.R", test_dir)

  result <- put_generate(test_dir, output = "console", style = "multiline")

  combined <- paste(result, collapse = "\n")
  # Multiline should have backslash continuations
  expect_true(grepl("\\\\", combined))
})

test_that("put_generate() handles empty directory", {
  temp_dir <- tempdir()
  test_dir <- file.path(temp_dir, "putior_test_generate_empty")
  dir.create(test_dir, showWarnings = FALSE)
  on.exit(unlink(test_dir, recursive = TRUE))

  expect_warning(result <- put_generate(test_dir), "No files matching")
  expect_equal(length(result), 0)
})

test_that("put_generate() handles non-existent path", {
  expect_error(put_generate("/path/that/does/not/exist"), "Path does not exist")
})

test_that("put_generate() validates output parameter", {
  temp_dir <- tempdir()
  test_dir <- file.path(temp_dir, "putior_test_generate_invalid")
  dir.create(test_dir, showWarnings = FALSE)
  on.exit(unlink(test_dir, recursive = TRUE))

  create_test_file(c("x <- 1"), "test.R", test_dir)

  expect_error(
    put_generate(test_dir, output = "invalid"),
    "Invalid output"
  )
})

test_that("put_generate() validates style parameter", {
  temp_dir <- tempdir()
  test_dir <- file.path(temp_dir, "putior_test_generate_style")
  dir.create(test_dir, showWarnings = FALSE)
  on.exit(unlink(test_dir, recursive = TRUE))

  create_test_file(c("x <- 1"), "test.R", test_dir)

  expect_error(
    put_generate(test_dir, style = "invalid"),
    "Invalid style"
  )
})

# Tests for put_merge()
test_that("put_merge() combines manual and auto-detected annotations", {
  temp_dir <- tempdir()
  test_dir <- file.path(temp_dir, "putior_test_merge")
  dir.create(test_dir, showWarnings = FALSE)
  on.exit(unlink(test_dir, recursive = TRUE))

  # File with manual annotation
  r_content_manual <- c(
    '#put id:"manual_node", label:"Manual Node", node_type:"process"',
    "data <- read.csv('input.csv')"
  )
  create_test_file(r_content_manual, "manual.R", test_dir)

  # File without annotation (will be auto-detected)
  r_content_auto <- c(
    "data <- read.csv('auto_input.csv')",
    "write.csv(data, 'auto_output.csv')"
  )
  create_test_file(r_content_auto, "auto.R", test_dir)

  result <- put_merge(test_dir)

  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 2)

  # Check manual annotation is preserved
  manual_row <- result[result$id == "manual_node", ]
  expect_equal(nrow(manual_row), 1)
  expect_equal(manual_row$label, "Manual Node")
})

test_that("put_merge() uses manual_priority strategy correctly", {
  temp_dir <- tempdir()
  test_dir <- file.path(temp_dir, "putior_test_merge_priority")
  dir.create(test_dir, showWarnings = FALSE)
  on.exit(unlink(test_dir, recursive = TRUE))

  # File with manual annotation that differs from auto-detected
  r_content <- c(
    '#put id:"custom_id", label:"Custom Label", input:"manual_input.csv"',
    "data <- read.csv('auto_input.csv')"  # Different from manual annotation
  )
  create_test_file(r_content, "test.R", test_dir)

  result <- put_merge(test_dir, merge_strategy = "manual_priority")

  # Manual annotation should take priority
  expect_equal(result$id[1], "custom_id")
  expect_equal(result$input[1], "manual_input.csv")
})

test_that("put_merge() uses supplement strategy correctly", {
  temp_dir <- tempdir()
  test_dir <- file.path(temp_dir, "putior_test_merge_supplement")
  dir.create(test_dir, showWarnings = FALSE)
  on.exit(unlink(test_dir, recursive = TRUE))

  # File with manual annotation missing input
  r_content <- c(
    '#put id:"partial", label:"Partial Annotation"',
    "data <- read.csv('detected_input.csv')"
  )
  create_test_file(r_content, "test.R", test_dir)

  result <- put_merge(test_dir, merge_strategy = "supplement")

  # Should have manual id/label but supplemented input
  partial_row <- result[result$id == "partial", ]
  expect_equal(partial_row$label, "Partial Annotation")
  # Input should be supplemented from auto-detection
  expect_false(is.na(partial_row$input))
})

test_that("put_merge() uses union strategy correctly", {
  temp_dir <- tempdir()
  test_dir <- file.path(temp_dir, "putior_test_merge_union")
  dir.create(test_dir, showWarnings = FALSE)
  on.exit(unlink(test_dir, recursive = TRUE))

  # File with manual annotation specifying one input
  r_content <- c(
    '#put id:"union_test", label:"Union Test", input:"manual.csv"',
    "data <- read.csv('auto.csv')"  # Additional input
  )
  create_test_file(r_content, "test.R", test_dir)

  result <- put_merge(test_dir, merge_strategy = "union")

  union_row <- result[result$id == "union_test", ]
  inputs <- strsplit(union_row$input, ",")[[1]]
  # Should contain both manual and auto-detected inputs
  expect_true("manual.csv" %in% inputs || any(grepl("manual", inputs)))
})

test_that("put_merge() validates merge_strategy parameter", {
  temp_dir <- tempdir()
  test_dir <- file.path(temp_dir, "putior_test_merge_invalid")
  dir.create(test_dir, showWarnings = FALSE)
  on.exit(unlink(test_dir, recursive = TRUE))

  create_test_file(c("x <- 1"), "test.R", test_dir)

  expect_error(
    put_merge(test_dir, merge_strategy = "invalid"),
    "Invalid merge_strategy"
  )
})

test_that("put_merge() handles only manual annotations", {
  temp_dir <- tempdir()
  test_dir <- file.path(temp_dir, "putior_test_merge_manual_only")
  dir.create(test_dir, showWarnings = FALSE)
  on.exit(unlink(test_dir, recursive = TRUE))

  r_content <- c(
    '#put id:"manual", label:"Manual Only"',
    "x <- 1"  # No detectable I/O
  )
  create_test_file(r_content, "test.R", test_dir)

  result <- put_merge(test_dir)

  expect_equal(nrow(result), 1)
  expect_equal(result$id, "manual")
})

test_that("put_merge() handles only auto-detected annotations", {
  temp_dir <- tempdir()
  test_dir <- file.path(temp_dir, "putior_test_merge_auto_only")
  dir.create(test_dir, showWarnings = FALSE)
  on.exit(unlink(test_dir, recursive = TRUE))

  # No PUT annotations, only detectable code
  r_content <- c(
    "data <- read.csv('input.csv')",
    "write.csv(data, 'output.csv')"
  )
  create_test_file(r_content, "test.R", test_dir)

  result <- put_merge(test_dir)

  expect_equal(nrow(result), 1)
  expect_true(result$auto_detected)
})

test_that("put_merge() handles empty directory", {
  temp_dir <- tempdir()
  test_dir <- file.path(temp_dir, "putior_test_merge_empty")
  dir.create(test_dir, showWarnings = FALSE)
  on.exit(unlink(test_dir, recursive = TRUE))

  expect_warning(result <- put_merge(test_dir))
  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 0)
})

# Tests for get_detection_patterns()
test_that("get_detection_patterns() returns patterns for R", {
  patterns <- get_detection_patterns("r")

  expect_type(patterns, "list")
  expect_true("input" %in% names(patterns))
  expect_true("output" %in% names(patterns))
  expect_true("dependency" %in% names(patterns))

  # Check input patterns include common functions
  input_funcs <- sapply(patterns$input, function(p) p$func)
  expect_true("read.csv" %in% input_funcs)
  expect_true("readRDS" %in% input_funcs)
})

test_that("get_detection_patterns() returns patterns for Python", {
  patterns <- get_detection_patterns("python")

  expect_type(patterns, "list")

  # Check Python patterns include pandas
  input_funcs <- sapply(patterns$input, function(p) p$func)
  expect_true(any(grepl("pd.read_csv|pandas", input_funcs)))
})

test_that("get_detection_patterns() filters by type", {
  input_patterns <- get_detection_patterns("r", type = "input")

  # Should return list of patterns, not a list with input/output/dependency
  expect_type(input_patterns, "list")
  # Each element should have regex and func
  expect_true(all(sapply(input_patterns, function(p) "regex" %in% names(p))))
})

test_that("get_detection_patterns() validates language", {
  expect_error(
    get_detection_patterns("invalid_language"),
    "Unsupported language"
  )
})

test_that("get_detection_patterns() validates type", {
  expect_error(
    get_detection_patterns("r", type = "invalid_type"),
    "Invalid pattern type"
  )
})

# Tests for list_supported_languages()
test_that("list_supported_languages() returns expected languages", {
  languages <- list_supported_languages()

  expect_type(languages, "character")
  expect_true("r" %in% languages)
  expect_true("python" %in% languages)
  expect_true("sql" %in% languages)
  expect_true("shell" %in% languages)
  expect_true("julia" %in% languages)
})

# Integration test: full workflow with put_auto
test_that("put_auto() to put_diagram() integration works", {
  temp_dir <- tempdir()
  test_dir <- file.path(temp_dir, "putior_test_integration")
  dir.create(test_dir, showWarnings = FALSE)
  on.exit(unlink(test_dir, recursive = TRUE))

  # Create a mini pipeline
  create_test_file(
    c("raw_data <- read.csv('raw.csv')", "write.csv(raw_data, 'clean.csv')"),
    "01_clean.R",
    test_dir
  )
  create_test_file(
    c("clean <- read.csv('clean.csv')", "write.csv(analysis, 'results.csv')"),
    "02_analyze.R",
    test_dir
  )
  create_test_file(
    c("results <- read.csv('results.csv')", "ggsave('report.png')"),
    "03_report.R",
    test_dir
  )

  # Auto-detect workflow
  workflow <- put_auto(test_dir)

  expect_equal(nrow(workflow), 3)

  # Generate diagram
  diagram <- put_diagram(workflow, output = "raw")

  expect_type(diagram, "character")
  expect_true(grepl("flowchart", diagram))
  expect_true(grepl("01_clean", diagram))
})
