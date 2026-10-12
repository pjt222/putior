# Tests for logging functionality

test_that("set_putior_log_level validates input", {
  # Test invalid level
  expect_error(
    set_putior_log_level("INVALID"),
    "Invalid log level"
  )

  # Test valid levels
  for (level in c("DEBUG", "INFO", "WARN", "ERROR")) {
    expect_silent(set_putior_log_level(level))
    expect_equal(getOption("putior.log_level"), level)
  }

  # Test case insensitivity
  set_putior_log_level("debug")
  expect_equal(getOption("putior.log_level"), "DEBUG")

  # Reset to default
  set_putior_log_level("WARN")
})

test_that("set_putior_log_level returns previous level", {
  # Set initial level
  set_putior_log_level("WARN")

  # Change and capture return value
  old_level <- set_putior_log_level("DEBUG")
  expect_equal(old_level, "WARN")

  # Change again
  old_level <- set_putior_log_level("INFO")
  expect_equal(old_level, "DEBUG")

  # Reset to default
  set_putior_log_level("WARN")
})

test_that("putior_log respects log level threshold", {
  skip_if_not_installed("logger", minimum_version = "0.3.0")

  # logger writes to stderr, which capture.output(type = "message") captures.
  set_putior_log_level("DEBUG")
  logged <- utils::capture.output({
    putior_log("DEBUG", "Test debug message")
    putior_log("INFO", "Test info message")
    putior_log("WARN", "Test warn message")
    putior_log("ERROR", "Test error message")
  }, type = "message")
  expect_length(logged, 4)

  set_putior_log_level("ERROR")
  logged <- utils::capture.output({
    putior_log("DEBUG", "Should not log")
    putior_log("INFO", "Should not log")
    putior_log("WARN", "Should not log")
  }, type = "message")
  expect_length(logged, 0)

  # Reset to default
  set_putior_log_level("WARN")
})

test_that("putior_log works without logger package", {
  # Mock the requireNamespace to return FALSE
  local_mocked_bindings(
    requireNamespace = function(...) FALSE,
    .package = "base"
  )

  # Should silently return NULL
  result <- putior_log("INFO", "Test message")
  expect_null(result)
})

test_that("has_logger returns correct value", {
  # This will depend on whether logger is installed
  result <- has_logger()
  expect_type(result, "logical")

  if (requireNamespace("logger", quietly = TRUE)) {
    expect_true(result)
  } else {
    expect_false(result)
  }
})

test_that("with_log_level temporarily changes level", {
  # Set initial level
  set_putior_log_level("WARN")
  expect_equal(getOption("putior.log_level"), "WARN")

  # Use with_log_level
  restore_fn <- with_log_level("DEBUG")
  expect_equal(getOption("putior.log_level"), "DEBUG")

  # Call restore function
  restore_fn()
  expect_equal(getOption("putior.log_level"), "WARN")
})

test_that("with_log_level handles NULL level", {
  set_putior_log_level("WARN")
  original_level <- getOption("putior.log_level")

  # NULL should not change the level
  restore_fn <- with_log_level(NULL)
  expect_equal(getOption("putior.log_level"), original_level)

  # Restore function should be a no-op
  restore_fn()
  expect_equal(getOption("putior.log_level"), original_level)
})

test_that("put function accepts log_level parameter", {
  # Create a temporary test file with PUT annotation
  tmp_dir <- tempdir()
  test_file <- file.path(tmp_dir, "test_logging.R")
  writeLines(c(
    '#put id:"test", label:"Test Node"',
    "x <- 1"
  ), test_file)

  # Should work with log_level parameter
  expect_silent({
    result <- put(test_file, log_level = "ERROR")
  })
  expect_equal(nrow(result), 1)

  # Clean up
  unlink(test_file)
})

test_that("put_auto function accepts log_level parameter", {
  # Create a temporary test file
  tmp_dir <- tempdir()
  test_file <- file.path(tmp_dir, "test_auto_logging.R")
  writeLines(c(
    'data <- read.csv("input.csv")',
    'write.csv(data, "output.csv")'
  ), test_file)

  # Should work with log_level parameter
  expect_silent({
    result <- put_auto(test_file, log_level = "ERROR")
  })
  expect_equal(nrow(result), 1)

  # Clean up
  unlink(test_file)
})

test_that("put_diagram function accepts log_level parameter", {
  # Create a simple workflow
  workflow <- data.frame(
    id = c("node1", "node2"),
    label = c("Node 1", "Node 2"),
    file_name = c("file1.R", "file2.R"),
    node_type = c("input", "output"),
    input = c(NA, "data.csv"),
    output = c("data.csv", NA),
    stringsAsFactors = FALSE
  )

  # Should work with log_level parameter
  expect_silent({
    result <- put_diagram(workflow, output = "raw", log_level = "ERROR")
  })
  expect_type(result, "character")
})

test_that("log_level parameter overrides global option", {
  set_putior_log_level("WARN")

  # Create test file
  tmp_dir <- tempdir()
  test_file <- file.path(tmp_dir, "test_override.R")
  writeLines('#put id:"test", label:"Test"', test_file)

  # Call with DEBUG level - global should still be WARN after call
  utils::capture.output(invisible(put(test_file, log_level = "DEBUG")), type = "message")
  expect_equal(getOption("putior.log_level"), "WARN")

  # Clean up
  unlink(test_file)
})

test_that("putior writes log lines at the requested level (#70)", {
  skip_if_not_installed("logger", minimum_version = "0.3.0")
  set_putior_log_level("WARN")
  on.exit(set_putior_log_level("WARN"), add = TRUE)
  test_dir <- file.path(tempdir(), "putior_test_logging_output")
  dir.create(test_dir, showWarnings = FALSE)
  on.exit(unlink(test_dir, recursive = TRUE), add = TRUE)
  writeLines('# put id:"load", label:"Load", output:"data.csv"', file.path(test_dir, "load.R"))

  # logger writes to stderr, which type = "message" captures. Match the
  # messages, not the level prefix: under GitHub Actions logger switches to
  # layout_gha(), which writes "::debug::<message>" instead of "DEBUG [...]".
  logged <- utils::capture.output(invisible(put(test_dir, log_level = "DEBUG")), type = "message")
  expect_true(any(grepl("Starting PUT annotation scan", logged, fixed = TRUE)))  # INFO
  expect_true(any(grepl("Processing file: load.R", logged, fixed = TRUE)))       # DEBUG

  # The per-call level is restored afterwards, so the default stays quiet.
  expect_equal(getOption("putior.log_level"), "WARN")
  quiet <- utils::capture.output(invisible(put(test_dir)), type = "message")
  expect_length(quiet, 0)
})

test_that("the putior.log_level option alone controls logging (#70)", {
  skip_if_not_installed("logger", minimum_version = "0.3.0")
  old_options <- options(putior.log_level = "debug")
  on.exit(options(old_options), add = TRUE)

  # Set directly, in lowercase, without set_putior_log_level().
  logged <- utils::capture.output(putior_log("DEBUG", "option-only message"), type = "message")

  expect_true(any(grepl("option-only message", logged, fixed = TRUE)))
})

test_that("an invalid per-call log_level is an error, not a crash (#70)", {
  test_dir <- file.path(tempdir(), "putior_test_logging_invalid")
  dir.create(test_dir, showWarnings = FALSE)
  on.exit(unlink(test_dir, recursive = TRUE), add = TRUE)
  writeLines('# put id:"load", label:"Load", output:"data.csv"', file.path(test_dir, "load.R"))
  set_putior_log_level("WARN")

  expect_error(put(test_dir, log_level = "VERBOSE"), "Invalid log_level")
  expect_equal(getOption("putior.log_level"), "WARN")
  expect_no_error(put(test_dir, log_level = "info"))
})
