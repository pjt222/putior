# Tests for the exclude parameter across all scanning functions

# =============================================================================
# filter_excluded_files() utility
# =============================================================================

test_that("filter_excluded_files returns all files when exclude is NULL", {
  files <- c("a.R", "b.R", "c.R")
  expect_equal(filter_excluded_files(files, NULL), files)
})

test_that("filter_excluded_files returns all files when exclude is empty", {
  files <- c("a.R", "b.R", "c.R")
  expect_equal(filter_excluded_files(files, character(0)), files)
})

test_that("filter_excluded_files returns empty when files is empty", {
  expect_equal(filter_excluded_files(character(0), "pattern"), character(0))
})

test_that("filter_excluded_files excludes matching files", {
  files <- c("/src/main.R", "/src/helper.R", "/src/meta_pipeline.R")
  result <- filter_excluded_files(files, "meta_pipeline")
  expect_equal(result, c("/src/main.R", "/src/helper.R"))
})

test_that("filter_excluded_files supports multiple patterns", {
  files <- c("/src/main.R", "/src/helper.R", "/test/test-main.R", "/src/deprecated.R")
  result <- filter_excluded_files(files, c("test-", "deprecated"))
  expect_equal(result, c("/src/main.R", "/src/helper.R"))
})

test_that("filter_excluded_files supports regex patterns", {
  files <- c("/src/load.R", "/src/process.R", "/src/load_v2.R")
  result <- filter_excluded_files(files, "load.*\\.R$")
  expect_equal(result, "/src/process.R")
})

test_that("filter_excluded_files supports comma-separated string", {
  files <- c("/src/main.R", "/src/helper.R", "/test/test-main.R")
  result <- filter_excluded_files(files, "test-, helper")
  expect_equal(result, "/src/main.R")
})

test_that("filter_excluded_files handles directory patterns", {
  files <- c("/src/main.R", "/vendor/lib.R", "/src/util.R")
  result <- filter_excluded_files(files, "/vendor/")
  expect_equal(result, c("/src/main.R", "/src/util.R"))
})

test_that("filter_excluded_files errors on non-character exclude", {
  expect_error(
    filter_excluded_files(c("a.R"), 42),
    "must be a character vector"
  )
})

test_that("filter_excluded_files handles empty-string-only exclude", {
  files <- c("a.R", "b.R")
  expect_equal(filter_excluded_files(files, ""), files)
})

# =============================================================================
# put() with exclude
# =============================================================================

test_that("put() exclude parameter filters files", {
  dir <- tempdir()
  sub_dir <- file.path(dir, "exclude_test_put")
  dir.create(sub_dir, showWarnings = FALSE)
  on.exit(unlink(sub_dir, recursive = TRUE), add = TRUE)

  writeLines('# put id:"a", label:"A"', file.path(sub_dir, "main.R"))
  writeLines('# put id:"b", label:"B"', file.path(sub_dir, "meta.R"))

  # Without exclude: both found
  wf_all <- put(sub_dir, validate = FALSE)
  expect_equal(nrow(wf_all), 2)

  # With exclude: meta.R excluded

  wf_filtered <- put(sub_dir, exclude = "meta\\.R$", validate = FALSE)
  expect_equal(nrow(wf_filtered), 1)
  expect_equal(wf_filtered$file_name, "main.R")
})

test_that("put() exclude with multiple patterns", {
  dir <- tempdir()
  sub_dir <- file.path(dir, "exclude_test_multi")
  dir.create(sub_dir, showWarnings = FALSE)
  on.exit(unlink(sub_dir, recursive = TRUE), add = TRUE)

  writeLines('# put id:"a", label:"A"', file.path(sub_dir, "main.R"))
  writeLines('# put id:"b", label:"B"', file.path(sub_dir, "meta.R"))
  writeLines('# put id:"c", label:"C"', file.path(sub_dir, "deprecated.R"))

  wf <- put(sub_dir, exclude = c("meta", "deprecated"), validate = FALSE)
  expect_equal(nrow(wf), 1)
  expect_equal(wf$file_name, "main.R")
})

test_that("put() exclude=NULL (default) includes all files", {
  dir <- tempdir()
  sub_dir <- file.path(dir, "exclude_test_null")
  dir.create(sub_dir, showWarnings = FALSE)
  on.exit(unlink(sub_dir, recursive = TRUE), add = TRUE)

  writeLines('# put id:"a", label:"A"', file.path(sub_dir, "one.R"))
  writeLines('# put id:"b", label:"B"', file.path(sub_dir, "two.R"))

  wf <- put(sub_dir, exclude = NULL, validate = FALSE)
  expect_equal(nrow(wf), 2)
})

# =============================================================================
# put_auto() with exclude
# =============================================================================

test_that("put_auto() exclude parameter filters files", {
  dir <- tempdir()
  sub_dir <- file.path(dir, "exclude_test_auto")
  dir.create(sub_dir, showWarnings = FALSE)
  on.exit(unlink(sub_dir, recursive = TRUE), add = TRUE)

  writeLines('data <- read.csv("input.csv")', file.path(sub_dir, "main.R"))
  writeLines('x <- 1', file.path(sub_dir, "meta.R"))

  wf_all <- put_auto(sub_dir)
  expect_gte(nrow(wf_all), 2)

  wf_filtered <- put_auto(sub_dir, exclude = "meta\\.R$")
  expect_equal(nrow(wf_filtered), 1)
  expect_equal(wf_filtered$file_name, "main.R")
})

# =============================================================================
# put_generate() with exclude
# =============================================================================

test_that("put_generate() exclude parameter filters files", {
  dir <- tempdir()
  sub_dir <- file.path(dir, "exclude_test_gen")
  dir.create(sub_dir, showWarnings = FALSE)
  on.exit(unlink(sub_dir, recursive = TRUE), add = TRUE)

  writeLines('data <- read.csv("input.csv")', file.path(sub_dir, "main.R"))
  writeLines('x <- 1', file.path(sub_dir, "skip.R"))

  result_all <- put_generate(sub_dir, output = "raw")
  result_filtered <- put_generate(sub_dir, output = "raw", exclude = "skip\\.R$")

  expect_gte(length(result_all), length(result_filtered))
})

# =============================================================================
# put_merge() with exclude
# =============================================================================

test_that("put_merge() exclude parameter filters files", {
  dir <- tempdir()
  sub_dir <- file.path(dir, "exclude_test_merge")
  dir.create(sub_dir, showWarnings = FALSE)
  on.exit(unlink(sub_dir, recursive = TRUE), add = TRUE)

  writeLines(c(
    '# put id:"a", label:"Main", output:"out.csv"',
    'data <- read.csv("in.csv")'
  ), file.path(sub_dir, "main.R"))
  writeLines('# put id:"b", label:"Skip"', file.path(sub_dir, "skip.R"))

  wf_all <- put_merge(sub_dir)
  wf_filtered <- put_merge(sub_dir, exclude = "skip\\.R$")

  expect_gt(nrow(wf_all), nrow(wf_filtered))
})

# =============================================================================
# Edge cases
# =============================================================================

test_that("exclude on single-file path still works", {
  dir <- tempdir()
  file_path <- file.path(dir, "single_exclude_test.R")
  writeLines('# put id:"x", label:"X"', file_path)
  on.exit(unlink(file_path), add = TRUE)

  # Exclude matches the single file — should get empty result
  expect_warning(
    wf <- put(file_path, exclude = "single_exclude", validate = FALSE),
    "No files matching"
  )
  expect_equal(nrow(wf), 0)
})

test_that("exclude interacts correctly with pattern", {
  dir <- tempdir()
  sub_dir <- file.path(dir, "exclude_pattern_test")
  dir.create(sub_dir, showWarnings = FALSE)
  on.exit(unlink(sub_dir, recursive = TRUE), add = TRUE)

  writeLines('# put id:"a", label:"A"', file.path(sub_dir, "one.R"))
  writeLines('# put id:"b", label:"B"', file.path(sub_dir, "two.R"))
  writeLines('# put id:"c", label:"C"', file.path(sub_dir, "three.py"))

  # pattern limits to R files, exclude further removes "two"
  wf <- put(sub_dir, pattern = "\\.R$", exclude = "two", validate = FALSE)
  expect_equal(nrow(wf), 1)
  expect_equal(wf$file_name, "one.R")
})
