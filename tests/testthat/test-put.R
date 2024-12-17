library(testthat)

# Test environment setup helper
create_test_files <- function(dir) {
  # R test file with various annotation formats
  r_content <- c(
    "# Sample R script",
    "#put name:\"node1\", label:\"Start\", node_type:\"process\"",
    "print('hello')",
    "# put name:\"node2\", label:\"Middle\", node_color:\"blue\"",
    "#put| name:\"node3\", label:\"End\""
  )
  writeLines(r_content, file.path(dir, "sample.R"))
  
  # Python test file with custom properties
  py_content <- c(
    "# Sample Python script",
    "#put name:\"py_node1\", label:\"Input\", node_type:\"input\"",
    "print('hello')",
    "# put name:\"py_node2\", label:\"Process\", node_comment:\"Important step\"",
    "#put| name:\"py_node3\", label:\"Output\""
  )
  writeLines(py_content, file.path(dir, "sample.py"))
}

test_that("put function processes R files correctly", {
  test_dir <- tempfile("putior_test_")
  dir.create(test_dir)
  on.exit(unlink(test_dir, recursive = TRUE))
  
  create_test_files(test_dir)
  result <- put(test_dir, pattern = "\\.R$")
  
  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 3)
  expect_true(all(c("file_name", "file_type", "name", "label") %in% names(result)))
  expect_equal(result$file_type, rep("r", 3))
  expect_equal(result$name, c("node1", "node2", "node3"))
  expect_true("node_type" %in% names(result))
  expect_true("node_color" %in% names(result))
})

test_that("put function processes Python files correctly", {
  test_dir <- tempfile("putior_test_")
  dir.create(test_dir)
  on.exit(unlink(test_dir, recursive = TRUE))
  
  create_test_files(test_dir)
  result <- put(test_dir, pattern = "\\.py$")
  
  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 3)
  expect_equal(result$file_type, rep("py", 3))
  expect_equal(result$name, c("py_node1", "py_node2", "py_node3"))
  expect_true("node_type" %in% names(result))
  expect_true("node_comment" %in% names(result))
})

test_that("put function handles polyglot file processing", {
  test_dir <- tempfile("putior_test_")
  dir.create(test_dir)
  on.exit(unlink(test_dir, recursive = TRUE))
  
  create_test_files(test_dir)
  result <- put(test_dir)
  
  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 6)
  expect_equal(sum(result$file_type == "r"), 3)
  expect_equal(sum(result$file_type == "py"), 3)
})

test_that("put function handles custom properties correctly", {
  test_dir <- tempfile("putior_test_")
  dir.create(test_dir)
  on.exit(unlink(test_dir, recursive = TRUE))
  
  create_test_files(test_dir)
  result <- put(test_dir)
  
  expect_true(all(c("node_type", "node_color", "node_comment") %in% names(result)))
  expect_equal(sum(!is.na(result$node_type)), 2)
  expect_equal(sum(!is.na(result$node_color)), 1)
  expect_equal(sum(!is.na(result$node_comment)), 1)
})

test_that("put function handles directory errors appropriately", {
  expect_error(put("nonexistent_directory"), "Directory does not exist")
  
  test_dir <- tempfile("putior_test_empty_")
  dir.create(test_dir)
  on.exit(unlink(test_dir, recursive = TRUE))
  
  expect_warning(result <- put(test_dir), "No R or Python files found")
  expect_equal(nrow(result), 0)
  expect_true(all(c("file_name", "file_type") %in% names(result)))
})

test_that("put function processes various annotation formats", {
  test_dir <- tempfile("putior_test_")
  dir.create(test_dir)
  on.exit(unlink(test_dir, recursive = TRUE))
  
  formats <- c(
    "#put name:\"test1\", label:\"standard\"",
    "# put name:\"test2\", label:\"spaced\"",
    "#put| name:\"test3\", label:\"piped\""
  )
  writeLines(formats, file.path(test_dir, "formats.R"))
  
  result <- put(test_dir)
  expect_equal(nrow(result), 3)
  expect_equal(result$name, c("test1", "test2", "test3"))
})