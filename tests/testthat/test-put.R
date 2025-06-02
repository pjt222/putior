# Test suite for putior package
library(testthat)
library(putior)

# Helper function to create temporary files for testing
create_test_file <- function(content, filename, dir) {
  filepath <- file.path(dir, filename)
  writeLines(content, filepath)
  return(filepath)
}

# Test basic functionality
test_that("put() handles basic directory scanning", {
  temp_dir <- tempdir()
  test_dir <- file.path(temp_dir, "putior_test_basic")
  dir.create(test_dir, showWarnings = FALSE)
  on.exit(unlink(test_dir, recursive = TRUE))

  # Create test files
  r_content <- c(
    "# Test R file",
    "#put name:\"test_r\", label:\"Test R Node\", node_type:\"process\"",
    "x <- 1"
  )

  py_content <- c(
    "# Test Python file",
    "#put name:\"test_py\", label:\"Test Python Node\", node_type:\"input\"",
    "x = 1"
  )

  create_test_file(r_content, "test.R", test_dir)
  create_test_file(py_content, "test.py", test_dir)

  # Test the function
  result <- put(test_dir)

  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 2)
  expect_true(all(c("file_name", "file_type", "name", "label", "node_type") %in% names(result)))
  expect_equal(sort(result$name), c("test_py", "test_r"))
  expect_equal(sort(result$file_type), c("py", "r"))
})

test_that("put() handles single file processing", {
  temp_dir <- tempdir()
  test_dir <- file.path(temp_dir, "putior_test_single")
  dir.create(test_dir, showWarnings = FALSE)
  on.exit(unlink(test_dir, recursive = TRUE))

  content <- c(
    "# Single file test",
    "#put name:\"single\", label:\"Single Node\", output:\"result.csv\"",
    "write.csv(data, 'result.csv')"
  )

  filepath <- create_test_file(content, "single.R", test_dir)

  # Test single file processing
  result <- put(filepath)

  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 1)
  expect_equal(result$name, "single")
  expect_equal(result$output, "result.csv")
})

test_that("put() handles recursive directory scanning", {
  temp_dir <- tempdir()
  test_dir <- file.path(temp_dir, "putior_test_recursive")
  subdir <- file.path(test_dir, "subdir")
  dir.create(test_dir, showWarnings = FALSE)
  dir.create(subdir, showWarnings = FALSE)
  on.exit(unlink(test_dir, recursive = TRUE))

  # Create files in main directory
  create_test_file(c("#put name:\"main\", label:\"Main\""), "main.R", test_dir)

  # Create files in subdirectory
  create_test_file(c("#put name:\"sub\", label:\"Sub\""), "sub.py", subdir)

  # Test non-recursive (should find 1)
  result_non_recursive <- put(test_dir, recursive = FALSE)
  expect_equal(nrow(result_non_recursive), 1)

  # Test recursive (should find 2)
  result_recursive <- put(test_dir, recursive = TRUE)
  expect_equal(nrow(result_recursive), 2)
  expect_true(all(c("main", "sub") %in% result_recursive$name))
})

test_that("put() includes line numbers when requested", {
  temp_dir <- tempdir()
  test_dir <- file.path(temp_dir, "putior_test_lines")
  dir.create(test_dir, showWarnings = FALSE)
  on.exit(unlink(test_dir, recursive = TRUE))

  content <- c(
    "# Line 1",
    "#put name:\"first\", label:\"First\"", # Line 2
    "# Line 3",
    "#put name:\"second\", label:\"Second\"" # Line 4
  )

  create_test_file(content, "test.R", test_dir)

  # Without line numbers
  result_no_lines <- put(test_dir, include_line_numbers = FALSE)
  expect_false("line_number" %in% names(result_no_lines))

  # With line numbers
  result_with_lines <- put(test_dir, include_line_numbers = TRUE)
  expect_true("line_number" %in% names(result_with_lines))
  expect_equal(result_with_lines$line_number, c(2, 4))
})

# Test annotation parsing
test_that("parse_put_annotation() handles various formats", {
  # Basic format
  result1 <- parse_put_annotation('#put name:"test", label:"Test Label"')
  expect_equal(result1$name, "test")
  expect_equal(result1$label, "Test Label")

  # With spaces
  result2 <- parse_put_annotation('# put name:"test2", node_type:"process"')
  expect_equal(result2$name, "test2")
  expect_equal(result2$node_type, "process")

  # With pipe separator
  result3 <- parse_put_annotation('#put| name:"test3", input:"data.csv"')
  expect_equal(result3$name, "test3")
  expect_equal(result3$input, "data.csv")

  # Single quotes
  result4 <- parse_put_annotation("#put name:'test4', label:'Single Quotes'")
  expect_equal(result4$name, "test4")
  expect_equal(result4$label, "Single Quotes")

  # Mixed quotes
  result5 <- parse_put_annotation('#put name:"test5", label:\'Mixed Quotes\'')
  expect_equal(result5$name, "test5")
  expect_equal(result5$label, "Mixed Quotes")
})

test_that("parse_put_annotation() handles edge cases", {
  # Empty annotation
  expect_null(parse_put_annotation("#put"))
  expect_null(parse_put_annotation("# put "))

  # Invalid syntax
  expect_null(parse_put_annotation("#put invalid"))
  expect_null(parse_put_annotation("#put name:noQuotes"))

  # Extra spaces
  result <- parse_put_annotation('#put  name : "test" , label : "Test"  ')
  expect_equal(result$name, "test")
  expect_equal(result$label, "Test")

  # Empty values
  result_empty <- parse_put_annotation('#put name:"", label:"Not Empty"')
  expect_equal(result_empty$name, "")
  expect_equal(result_empty$label, "Not Empty")
})

test_that("parse_put_annotation() handles commas in values", {
  # Comma inside quotes should be preserved
  result <- parse_put_annotation('#put name:"test", label:"Label, with comma"')
  expect_equal(result$name, "test")
  expect_equal(result$label, "Label, with comma")

  # Multiple commas
  result2 <- parse_put_annotation('#put name:"test", description:"A, B, and C", type:"complex"')
  expect_equal(result2$description, "A, B, and C")
  expect_equal(length(result2), 3)
})

# Test validation functionality
test_that("put() validation works correctly", {
  temp_dir <- tempdir()
  test_dir <- file.path(temp_dir, "putior_test_validation")
  dir.create(test_dir, showWarnings = FALSE)
  on.exit(unlink(test_dir, recursive = TRUE))

  # Create file with validation issues
  content_with_issues <- c(
    "#put label:\"No Name\"", # Missing name
    "#put name:\"test\", node_type:\"invalid_type\"", # Invalid node type
    "#put name:\"test2\", input:\"noextension\"", # File without extension
    "#put name:\"good\", label:\"Good Annotation\", node_type:\"process\"" # Valid
  )

  create_test_file(content_with_issues, "test.R", test_dir)

  # Test with validation enabled (should give warnings)
  expect_warning({
    result_with_validation <- put(test_dir, validate = TRUE)
  })

  # Should still return results for valid annotations
  expect_gte(nrow(result_with_validation), 1)

  # Test with validation disabled (should not give warnings)
  expect_silent({
    result_no_validation <- put(test_dir, validate = FALSE)
  })
})

test_that("is_valid_put_annotation() correctly identifies valid annotations", {
  # Valid annotations
  expect_true(is_valid_put_annotation('#put name:"test", label:"Test"'))
  expect_true(is_valid_put_annotation('# put name:"test"'))
  expect_true(is_valid_put_annotation('#put| name:"test", type:"process"'))

  # Invalid annotations
  expect_false(is_valid_put_annotation("#put"))
  expect_false(is_valid_put_annotation("#put invalid"))
  expect_false(is_valid_put_annotation("#put name:noQuotes"))
  expect_false(is_valid_put_annotation("not a put annotation"))
})

# Test error handling
test_that("put() handles errors gracefully", {
  # Non-existent directory
  expect_error(put("/path/that/does/not/exist"), "Path does not exist")

  # Invalid path type
  expect_error(put(123), "'path' must be a single character string")
  expect_error(put(c("path1", "path2")), "'path' must be a single character string")

  # Empty directory
  temp_dir <- tempdir()
  empty_dir <- file.path(temp_dir, "empty_test_dir")
  dir.create(empty_dir, showWarnings = FALSE)
  on.exit(unlink(empty_dir, recursive = TRUE))

  expect_warning(
    {
      result <- put(empty_dir)
    },
    "No files matching pattern"
  )

  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 0)
})

test_that("put() handles different file extensions", {
  temp_dir <- tempdir()
  test_dir <- file.path(temp_dir, "putior_test_extensions")
  dir.create(test_dir, showWarnings = FALSE)
  on.exit(unlink(test_dir, recursive = TRUE))

  # Create files with different extensions
  # Note: The default pattern is "\\.(R|r|py|sql|sh|jl)$"
  # but we need to check which extensions are actually supported
  extensions <- c("R", "py", "sql", "sh", "jl") # Removed lowercase "r" to avoid duplicates

  for (ext in extensions) {
    content <- paste0("#put name:\"test_", ext, "\", label:\"Test ", ext, "\"")
    create_test_file(content, paste0("test.", ext), test_dir)
  }

  result <- put(test_dir)
  expect_equal(nrow(result), length(extensions))

  # Check that the expected file types are present
  expected_types <- c("r", "py", "sql", "sh", "jl") # tolower() is applied to file extensions
  expect_true(all(expected_types %in% result$file_type))
})

test_that("put() preserves custom properties", {
  temp_dir <- tempdir()
  test_dir <- file.path(temp_dir, "putior_test_custom")
  dir.create(test_dir, showWarnings = FALSE)
  on.exit(unlink(test_dir, recursive = TRUE))

  content <- c(
    '#put name:"custom", label:"Custom Node", color:"blue", priority:"high", duration:"5min"'
  )

  create_test_file(content, "custom.R", test_dir)

  result <- put(test_dir)
  expect_equal(result$color, "blue")
  expect_equal(result$priority, "high")
  expect_equal(result$duration, "5min")
})

# Performance and stress tests
test_that("put() handles multiple annotations efficiently", {
  temp_dir <- tempdir()
  test_dir <- file.path(temp_dir, "putior_test_many")
  dir.create(test_dir, showWarnings = FALSE)
  on.exit(unlink(test_dir, recursive = TRUE))

  # Create file with many annotations
  many_annotations <- character()
  for (i in 1:50) {
    many_annotations <- c(
      many_annotations,
      paste0('#put name:"node', i, '", label:"Node ', i, '", step:', i)
    )
  }

  create_test_file(many_annotations, "many.R", test_dir)

  # Should complete reasonably quickly
  start_time <- Sys.time()
  result <- put(test_dir)
  end_time <- Sys.time()

  expect_equal(nrow(result), 50)
  expect_lt(as.numeric(end_time - start_time), 5) # Should take less than 5 seconds
})

test_that("put() column ordering is consistent", {
  temp_dir <- tempdir()
  test_dir <- file.path(temp_dir, "putior_test_columns")
  dir.create(test_dir, showWarnings = FALSE)
  on.exit(unlink(test_dir, recursive = TRUE))

  content <- c(
    '#put zebra:"z", alpha:"a", name:"test", beta:"b"'
  )

  create_test_file(content, "test.R", test_dir)

  result <- put(test_dir)

  # Standard columns should come first
  expect_true(which(names(result) == "file_name") < which(names(result) == "alpha"))
  expect_true(which(names(result) == "file_type") < which(names(result) == "alpha"))

  # Custom columns should be alphabetically ordered
  custom_cols <- names(result)[!names(result) %in% c("file_name", "file_path", "file_type")]
  expect_equal(custom_cols, sort(custom_cols))
})
