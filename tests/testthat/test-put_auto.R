# Test suite for put_auto() and related functions
library(testthat)
library(putior)

# Helper function to create temporary files for testing
create_test_file <- function(content, filename, dir) {
  filepath <- file.path(dir, filename)
  writeLines(content, filepath)
  return(filepath)
}

# Tests for put_auto()
test_that("put_auto() detects R file inputs", {
  temp_dir <- tempdir()
  test_dir <- file.path(temp_dir, "putior_test_auto_input")
  dir.create(test_dir, showWarnings = FALSE)
  on.exit(unlink(test_dir, recursive = TRUE))

  r_content <- c(
    "# Load data",
    "data <- read.csv('input_data.csv')",
    "config <- readRDS('config.rds')",
    "more_data <- read_csv('more_data.csv')"
  )

  create_test_file(r_content, "analysis.R", test_dir)

  result <- put_auto(test_dir)

  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 1)
  expect_equal(result$file_name, "analysis.R")

  # Check inputs were detected (at least some)
  expect_false(is.na(result$input))
  inputs <- strsplit(result$input, ",")[[1]]
  expect_true(any(grepl("csv|rds", inputs, ignore.case = TRUE)))
})

test_that("put_auto() detects R file outputs", {
  temp_dir <- tempdir()
  test_dir <- file.path(temp_dir, "putior_test_auto_output")
  dir.create(test_dir, showWarnings = FALSE)
  on.exit(unlink(test_dir, recursive = TRUE))

  r_content <- c(
    "# Save results",
    "write.csv(data, 'output.csv')",
    "saveRDS(model, 'model.rds')",
    "ggsave('plot.png')"
  )

  create_test_file(r_content, "export.R", test_dir)

  result <- put_auto(test_dir)

  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 1)

  # Check outputs were detected
  expect_false(is.na(result$output))
  outputs <- strsplit(result$output, ",")[[1]]
  expect_true(length(outputs) >= 1)
})

test_that("put_auto() handles files with both inputs and outputs", {
  temp_dir <- tempdir()
  test_dir <- file.path(temp_dir, "putior_test_auto_both")
  dir.create(test_dir, showWarnings = FALSE)
  on.exit(unlink(test_dir, recursive = TRUE))

  r_content <- c(
    "# Transform data",
    "data <- read.csv('input.csv')",
    "processed <- transform(data)",
    "write.csv(processed, 'output.csv')"
  )

  create_test_file(r_content, "transform.R", test_dir)

  result <- put_auto(test_dir)

  expect_equal(nrow(result), 1)
  expect_equal(result$node_type, "process")  # Has both input and output

  # Verify inputs and outputs
  expect_false(is.na(result$input))
  expect_false(is.na(result$output))
})

test_that("put_auto() generates appropriate node IDs", {
  temp_dir <- tempdir()
  test_dir <- file.path(temp_dir, "putior_test_auto_id")
  dir.create(test_dir, showWarnings = FALSE)
  on.exit(unlink(test_dir, recursive = TRUE))

  r_content <- c("x <- 1")
  create_test_file(r_content, "my-analysis-script.R", test_dir)

  result <- put_auto(test_dir)

  # Check ID is sanitized
  expect_true(!is.na(result$id))
  expect_false(grepl("-", result$id))  # Hyphens should be replaced
  expect_equal(result$id, "my_analysis_script")
})

test_that("put_auto() handles multiple files", {
  temp_dir <- tempdir()
  test_dir <- file.path(temp_dir, "putior_test_auto_multi")
  dir.create(test_dir, showWarnings = FALSE)
  on.exit(unlink(test_dir, recursive = TRUE))

  create_test_file(c("data <- read.csv('data.csv')"), "load.R", test_dir)
  create_test_file(c("write.csv(result, 'result.csv')"), "save.R", test_dir)

  result <- put_auto(test_dir)

  expect_equal(nrow(result), 2)
  expect_true(all(c("load", "save") %in% result$id))
})

test_that("put_auto() handles empty directory", {
  temp_dir <- tempdir()
  test_dir <- file.path(temp_dir, "putior_test_auto_empty")
  dir.create(test_dir, showWarnings = FALSE)
  on.exit(unlink(test_dir, recursive = TRUE))

  expect_warning(result <- put_auto(test_dir), "No files matching")
  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 0)
})

test_that("put_auto() handles non-existent path", {
  nonexistent_path <- file.path(tempdir(), "nonexistent", "path", "that", "does", "not", "exist")
  expect_error(put_auto(nonexistent_path), "Path does not exist")
})

test_that("put_auto() handles single file", {
  temp_dir <- tempdir()
  test_dir <- file.path(temp_dir, "putior_test_auto_single")
  dir.create(test_dir, showWarnings = FALSE)
  on.exit(unlink(test_dir, recursive = TRUE))

  filepath <- create_test_file(
    c("data <- read.csv('test.csv')"),
    "single.R",
    test_dir
  )

  result <- put_auto(filepath)

  expect_equal(nrow(result), 1)
  expect_equal(result$file_name, "single.R")
})

test_that("put_auto() respects detect_inputs parameter", {
  temp_dir <- tempdir()
  test_dir <- file.path(temp_dir, "putior_test_auto_noinput")
  dir.create(test_dir, showWarnings = FALSE)
  on.exit(unlink(test_dir, recursive = TRUE))

  r_content <- c(
    "data <- read.csv('input.csv')",
    "write.csv(data, 'output.csv')"
  )
  create_test_file(r_content, "test.R", test_dir)

  result <- put_auto(test_dir, detect_inputs = FALSE)

  # Input should be NA since detection is disabled
  expect_true(is.na(result$input))
})

test_that("put_auto() respects detect_outputs parameter", {
  temp_dir <- tempdir()
  test_dir <- file.path(temp_dir, "putior_test_auto_nooutput")
  dir.create(test_dir, showWarnings = FALSE)
  on.exit(unlink(test_dir, recursive = TRUE))

  r_content <- c(
    "data <- read.csv('input.csv')",
    "write.csv(data, 'output.csv')"
  )
  create_test_file(r_content, "test.R", test_dir)

  result <- put_auto(test_dir, detect_outputs = FALSE)

  # Output should be file name (default) since detection is disabled
  expect_equal(result$output, "test.R")
})

test_that("put_auto() includes line numbers when requested", {
  temp_dir <- tempdir()
  test_dir <- file.path(temp_dir, "putior_test_auto_lines")
  dir.create(test_dir, showWarnings = FALSE)
  on.exit(unlink(test_dir, recursive = TRUE))

  create_test_file(c("x <- 1"), "test.R", test_dir)

  result_no_lines <- put_auto(test_dir, include_line_numbers = FALSE)
  expect_false("line_number" %in% names(result_no_lines))

  result_with_lines <- put_auto(test_dir, include_line_numbers = TRUE)
  expect_true("line_number" %in% names(result_with_lines))
})

test_that("put_auto() sets auto_detected flag", {
  temp_dir <- tempdir()
  test_dir <- file.path(temp_dir, "putior_test_auto_flag")
  dir.create(test_dir, showWarnings = FALSE)
  on.exit(unlink(test_dir, recursive = TRUE))

  create_test_file(c("x <- 1"), "test.R", test_dir)

  result <- put_auto(test_dir)

  expect_true("auto_detected" %in% names(result))
  expect_true(result$auto_detected[1])
})

# Tests for Python file detection
test_that("put_auto() detects Python file I/O", {
  temp_dir <- tempdir()
  test_dir <- file.path(temp_dir, "putior_test_auto_python")
  dir.create(test_dir, showWarnings = FALSE)
  on.exit(unlink(test_dir, recursive = TRUE))

  py_content <- c(
    "import pandas as pd",
    "df = pd.read_csv('data.csv')",
    "df.to_csv('output.csv')"
  )

  create_test_file(py_content, "analysis.py", test_dir)

  result <- put_auto(test_dir)

  expect_equal(nrow(result), 1)
  expect_equal(result$file_type, "py")
  expect_equal(result$node_type, "process")  # Has both input and output
})

# Tests for put_auto() result format compatibility
test_that("put_auto() result is compatible with put_diagram()", {
  temp_dir <- tempdir()
  test_dir <- file.path(temp_dir, "putior_test_auto_compat")
  dir.create(test_dir, showWarnings = FALSE)
  on.exit(unlink(test_dir, recursive = TRUE))

  r_content <- c(
    "data <- read.csv('input.csv')",
    "write.csv(data, 'output.csv')"
  )
  create_test_file(r_content, "process.R", test_dir)

  result <- put_auto(test_dir)

  # Check required columns for put_diagram
  expect_true("id" %in% names(result))
  expect_true("file_name" %in% names(result))

  # This should not error
  expect_silent({
    diagram <- put_diagram(result, output = "raw")
  })
})

# Tests for recursive scanning
test_that("put_auto() handles recursive scanning", {
  temp_dir <- tempdir()
  test_dir <- file.path(temp_dir, "putior_test_auto_recursive")
  subdir <- file.path(test_dir, "subdir")
  dir.create(test_dir, showWarnings = FALSE)
  dir.create(subdir, showWarnings = FALSE)
  on.exit(unlink(test_dir, recursive = TRUE))

  create_test_file(c("x <- 1"), "main.R", test_dir)
  create_test_file(c("y <- 2"), "sub.R", subdir)

  result_non_recursive <- put_auto(test_dir, recursive = FALSE)
  expect_equal(nrow(result_non_recursive), 1)

  result_recursive <- put_auto(test_dir, recursive = TRUE)
  expect_equal(nrow(result_recursive), 2)
})

# Tests for infer_node_type
test_that("infer_node_type() correctly identifies node types", {
  # Input node (no inputs, has outputs)
  expect_equal(
    putior:::infer_node_type(character(), c("output.csv")),
    "input"
  )

  # Output node (has inputs, no outputs)
  expect_equal(
    putior:::infer_node_type(c("input.csv"), character()),
    "output"
  )

  # Process node (has both)
  expect_equal(
    putior:::infer_node_type(c("input.csv"), c("output.csv")),
    "process"
  )

  # Default to process
  expect_equal(
    putior:::infer_node_type(character(), character()),
    "process"
  )
})

# Tests for is_likely_file_path
test_that("is_likely_file_path() correctly identifies file paths", {
  # Valid file paths
  expect_true(putior:::is_likely_file_path("data.csv"))
  expect_true(putior:::is_likely_file_path("path/to/file.txt"))
  expect_true(putior:::is_likely_file_path("../data/input.json"))

  # Invalid paths
  expect_false(putior:::is_likely_file_path(""))
  expect_false(putior:::is_likely_file_path(NULL))
  expect_false(putior:::is_likely_file_path("TRUE"))
  expect_false(putior:::is_likely_file_path("NA"))
  expect_false(putior:::is_likely_file_path("https://example.com/data.csv"))
})

# Tests for ext_to_language
test_that("ext_to_language() maps extensions correctly", {
  expect_equal(putior:::ext_to_language("r"), "r")
  expect_equal(putior:::ext_to_language("R"), "r")
  expect_equal(putior:::ext_to_language("py"), "python")
  expect_equal(putior:::ext_to_language("sql"), "sql")
  expect_equal(putior:::ext_to_language("sh"), "shell")
  expect_equal(putior:::ext_to_language("jl"), "julia")
  expect_null(putior:::ext_to_language("xyz"))
})
