# Test suite for putior package
library(testthat)
library(putior)

# Test basic functionality
test_that("put() handles basic directory scanning", {
  temp_dir <- tempdir()
  test_dir <- file.path(temp_dir, "putior_test_basic")
  dir.create(test_dir, showWarnings = FALSE)
  on.exit(unlink(test_dir, recursive = TRUE))

  # Create test files
  r_content <- c(
    "# Test R file",
    "#put id:\"test_r\", label:\"Test R Node\", node_type:\"process\"",
    "x <- 1"
  )

  py_content <- c(
    "# Test Python file",
    "#put id:\"test_py\", label:\"Test Python Node\", node_type:\"input\"",
    "x = 1"
  )

  create_test_file(r_content, "test.R", test_dir)
  create_test_file(py_content, "test.py", test_dir)

  # Test the function
  result <- put(test_dir)

  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 2)
  expect_true(all(c("file_name", "file_type", "id", "label", "node_type") %in% names(result)))
  expect_equal(sort(result$id), c("test_py", "test_r"))
  expect_equal(sort(result$file_type), c("py", "r"))
})

test_that("put() handles single file processing", {
  temp_dir <- tempdir()
  test_dir <- file.path(temp_dir, "putior_test_single")
  dir.create(test_dir, showWarnings = FALSE)
  on.exit(unlink(test_dir, recursive = TRUE))

  content <- c(
    "# Single file test",
    "#put id:\"single\", label:\"Single Node\", output:\"result.csv\"",
    "write.csv(data, 'result.csv')"
  )

  filepath <- create_test_file(content, "single.R", test_dir)

  # Test single file processing
  result <- put(filepath)

  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 1)
  expect_equal(result$id, "single")
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
  create_test_file(c("#put id:\"main\", label:\"Main\""), "main.R", test_dir)

  # Create files in subdirectory
  create_test_file(c("#put id:\"sub\", label:\"Sub\""), "sub.py", subdir)

  # Test non-recursive (should find 1)
  result_non_recursive <- put(test_dir, recursive = FALSE)
  expect_equal(nrow(result_non_recursive), 1)

  # Test recursive (should find 2)
  result_recursive <- put(test_dir, recursive = TRUE)
  expect_equal(nrow(result_recursive), 2)
  expect_true(all(c("main", "sub") %in% result_recursive$id))
})

test_that("put() includes line numbers when requested", {
  temp_dir <- tempdir()
  test_dir <- file.path(temp_dir, "putior_test_lines")
  dir.create(test_dir, showWarnings = FALSE)
  on.exit(unlink(test_dir, recursive = TRUE))

  content <- c(
    "# Line 1",
    "#put id:\"first\", label:\"First\"", # Line 2
    "# Line 3",
    "#put id:\"second\", label:\"Second\"" # Line 4
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
  result1 <- parse_put_annotation('#put id:"test", label:"Test Label"')
  expect_equal(result1$id, "test")
  expect_equal(result1$label, "Test Label")

  # With spaces
  result2 <- parse_put_annotation('# put id:"test2", node_type:"process"')
  expect_equal(result2$id, "test2")
  expect_equal(result2$node_type, "process")

  # With pipe separator
  result3 <- parse_put_annotation('#put| id:"test3", input:"data.csv"')
  expect_equal(result3$id, "test3")
  expect_equal(result3$input, "data.csv")

  # Single quotes
  result4 <- parse_put_annotation("#put id:'test4', label:'Single Quotes'")
  expect_equal(result4$id, "test4")
  expect_equal(result4$label, "Single Quotes")

  # Mixed quotes
  result5 <- parse_put_annotation('#put id:"test5", label:\'Mixed Quotes\'')
  expect_equal(result5$id, "test5")
  expect_equal(result5$label, "Mixed Quotes")
})

test_that("parse_put_annotation() handles edge cases", {
  # Empty annotation
  expect_null(parse_put_annotation("#put"))
  expect_null(parse_put_annotation("# put "))

  # Invalid syntax
  expect_null(parse_put_annotation("#put invalid"))
  expect_null(parse_put_annotation("#put no quotes"))

  # Not a PUT annotation
  expect_null(parse_put_annotation("# Regular comment"))
  expect_null(parse_put_annotation("puts something"))
})

test_that("put() handles files with no annotations", {
  temp_dir <- tempdir()
  test_dir <- file.path(temp_dir, "putior_test_no_annotations")
  dir.create(test_dir, showWarnings = FALSE)
  on.exit(unlink(test_dir, recursive = TRUE))

  # Create file without PUT annotations
  content <- c(
    "# Regular R file",
    "x <- 1:10",
    "mean(x)"
  )

  create_test_file(content, "no_annotations.R", test_dir)

  result <- put(test_dir)
  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 0)
})

test_that("put() validation works correctly", {
  temp_dir <- tempdir()
  test_dir <- file.path(temp_dir, "putior_test_validation")
  dir.create(test_dir, showWarnings = FALSE)
  on.exit(unlink(test_dir, recursive = TRUE))

  # Create file with validation issues
  content_with_issues <- c(
    "#put label:\"No ID\"", # Missing id
    "#put id:\"test\", node_type:\"invalid_type\"", # Invalid node type
    "#put id:\"test2\", input:\"noextension\"", # File without extension
    "#put id:\"good\", label:\"Good Annotation\", node_type:\"process\"" # Valid
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
  expect_true(is_valid_put_annotation('#put id:"test", label:"Test"'))
  expect_true(is_valid_put_annotation('# put id:"test"'))
  expect_true(is_valid_put_annotation('#put| id:"test", type:"process"'))

  # Invalid annotations
  expect_false(is_valid_put_annotation("#put"))
  expect_false(is_valid_put_annotation("#put invalid"))
  expect_false(is_valid_put_annotation("#put id:noQuotes"))
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
  # Each file type needs its appropriate comment prefix
  extensions <- c("R", "py", "sql", "sh", "jl") # Removed lowercase "r" to avoid duplicates

  for (ext in extensions) {
    # Use the appropriate comment prefix for each file type
    prefix <- get_comment_prefix(ext)
    content <- paste0(prefix, "put id:\"test_", ext, "\", label:\"Test ", ext, "\"")
    create_test_file(content, paste0("test.", ext), test_dir)
  }

  result <- put(test_dir)
  expect_equal(nrow(result), length(extensions))
  expect_true(all(tolower(extensions) %in% result$file_type))
})

test_that("put() preserves custom properties", {
  temp_dir <- tempdir()
  test_dir <- file.path(temp_dir, "putior_test_custom")
  dir.create(test_dir, showWarnings = FALSE)
  on.exit(unlink(test_dir, recursive = TRUE))

  content <- c(
    '#put id:"custom", label:"Custom Node", color:"blue", priority:"high", duration:"5min"'
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
      paste0('#put id:"node', i, '", label:"Node ', i, '", step:', i)
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
    '#put zebra:"z", alpha:"a", id:"test", beta:"b"'
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

test_that("put() detects duplicate IDs", {
  temp_dir <- tempdir()
  test_dir <- file.path(temp_dir, "putior_test_duplicates")
  dir.create(test_dir, showWarnings = FALSE)
  on.exit(unlink(test_dir, recursive = TRUE))

  content <- c(
    '#put id:"test_dup", label:"First Duplicate"',
    '#put id:"test_dup", label:"Second Duplicate"',
    '#put id:"unique_node", label:"Unique Node"'
  )

  create_test_file(content, "test.R", test_dir)

  # Should warn about duplicate IDs
  expect_warning({
    result <- put(test_dir, validate = TRUE)
  }, "Duplicate node IDs found: test_dup")

  # Should still return all nodes
  expect_equal(nrow(result), 3)
})

test_that("put() defaults output to file_name when missing", {
  temp_dir <- tempdir()
  test_dir <- file.path(temp_dir, "putior_test_output_default")
  dir.create(test_dir, showWarnings = FALSE)
  on.exit(unlink(test_dir, recursive = TRUE))

  # Create file where output is not specified
  content <- c(
    '#put label:"Process Step", node_type:"process", input:"data.csv"',
    '# No output specified - should default to file name'
  )

  create_test_file(content, "process_script.R", test_dir)
  
  result <- put(test_dir)
  
  # Check that output was defaulted to the file name
  expect_equal(nrow(result), 1)
  expect_equal(result$output, "process_script.R")
  expect_equal(result$file_name, "process_script.R")
})

# Tests for multiline annotations
test_that("put() handles multiline annotations correctly", {
  temp_dir <- tempdir()
  test_dir <- file.path(temp_dir, "putior_test_multiline")
  dir.create(test_dir, showWarnings = FALSE)
  on.exit(unlink(test_dir, recursive = TRUE))
  
  # Test file with multiline annotations
  multiline_content <- c(
    "#put id:\"multi1\", label:\"Multiline Test\", \\",
    "#    input:\"file1.csv,file2.csv,file3.csv\", \\",
    "#    output:\"result.csv\"",
    "",
    "# Some R code here",
    "",
    "#put id:\"multi2\", \\",
    "#    label:\"Complex Process\", \\",
    "#    node_type:\"process\", \\",
    "#    input:\"data1.csv,data2.csv,data3.csv,data4.csv,data5.csv\", \\",
    "#    output:\"processed_data.csv\"",
    "",
    "# More code",
    "",
    "# Single line annotation for comparison",
    "#put id:\"single\", label:\"Single Line\", input:\"test.csv\""
  )
  
  test_file <- create_test_file(multiline_content, "multiline_test.R", test_dir)
  
  # Extract annotations
  result <- put(test_dir)
  
  # Should find 3 annotations
  expect_equal(nrow(result), 3)
  
  # Check first multiline annotation
  multi1 <- result[result$id == "multi1", ]
  expect_equal(multi1$label, "Multiline Test")
  expect_equal(multi1$input, "file1.csv,file2.csv,file3.csv")
  expect_equal(multi1$output, "result.csv")
  
  # Check second multiline annotation
  multi2 <- result[result$id == "multi2", ]
  expect_equal(multi2$label, "Complex Process")
  expect_equal(multi2$node_type, "process")
  expect_equal(multi2$input, "data1.csv,data2.csv,data3.csv,data4.csv,data5.csv")
  expect_equal(multi2$output, "processed_data.csv")
  
  # Check single line annotation still works
  single <- result[result$id == "single", ]
  expect_equal(single$label, "Single Line")
  expect_equal(single$input, "test.csv")
})

test_that("put() handles edge cases in multiline annotations", {
  temp_dir <- tempdir()
  test_dir <- file.path(temp_dir, "putior_test_multiline_edge")
  dir.create(test_dir, showWarnings = FALSE)
  on.exit(unlink(test_dir, recursive = TRUE))
  
  # Test edge cases
  edge_case_content <- c(
    "# Multiline with trailing backslash but no continuation",
    "#put id:\"edge1\", label:\"Edge Case 1\" \\",
    "",
    "# Next annotation immediately after multiline",
    "#put id:\"edge2\", label:\"Edge Case 2\" \\",
    "#put id:\"edge3\", label:\"This is separate\"",
    "",
    "# Multiline with empty continuation lines",
    "#put id:\"edge4\", label:\"With Empty Lines\", \\",
    "#",
    "#    input:\"test.csv\"",
    "",
    "# Backslash at end of file",
    "#put id:\"edge5\", label:\"End of File\" \\"
  )
  
  test_file <- create_test_file(edge_case_content, "edge_cases.R", test_dir)
  
  # Extract annotations
  result <- put(test_dir)
  
  # Should find all annotations (at least 4)
  expect_gte(nrow(result), 4)
  
  # Check that edge cases are handled
  edge1 <- result[result$id == "edge1", ]
  expect_equal(edge1$label, "Edge Case 1")
  
  edge3 <- result[result$id == "edge3", ]
  expect_equal(edge3$label, "This is separate")
  
  edge4 <- result[result$id == "edge4", ]
  expect_equal(edge4$label, "With Empty Lines")
  expect_equal(edge4$input, "test.csv")
})

test_that("put() preserves line numbers with multiline annotations", {
  temp_dir <- tempdir()
  test_dir <- file.path(temp_dir, "putior_test_multiline_lines")
  dir.create(test_dir, showWarnings = FALSE)
  on.exit(unlink(test_dir, recursive = TRUE))
  
  content <- c(
    "# Line 1",
    "#put id:\"first\", label:\"First\" \\",  # Line 2
    "#    input:\"test.csv\"",              # Line 3
    "",
    "# Line 5",
    "#put id:\"second\", label:\"Second\""   # Line 6
  )
  
  test_file <- create_test_file(content, "line_test.R", test_dir)
  
  # Extract with line numbers
  result <- put(test_dir, include_line_numbers = TRUE)
  
  # Check line numbers point to start of annotation
  first <- result[result$id == "first", ]
  expect_equal(first$line_number, 2)
  
  second <- result[result$id == "second", ]
  expect_equal(second$line_number, 6)
})

test_that("put() handles different multiline syntax variations", {
  temp_dir <- tempdir()
  test_dir <- file.path(temp_dir, "putior_test_multiline_syntax")
  dir.create(test_dir, showWarnings = FALSE)
  on.exit(unlink(test_dir, recursive = TRUE))
  
  # Test different syntax variations
  syntax_content <- c(
    "# Standard multiline with spaces",
    "#put id:\"style1\", label:\"Style 1\" \\",
    "#    input:\"file1.csv\"",
    "",
    "# Multiline with pipe separator",
    "#put| id:\"style2\", label:\"Style 2\" \\",
    "#     input:\"file2.csv\"",
    "",
    "# Multiline with colon separator",
    "#put: id:\"style3\", label:\"Style 3\" \\",
    "#     input:\"file3.csv\"",
    "",
    "# Backslash with trailing spaces",
    "#put id:\"style4\", label:\"Style 4\"  \\   ",
    "#    input:\"file4.csv\""
  )
  
  test_file <- create_test_file(syntax_content, "syntax_test.R", test_dir)
  
  # Extract annotations
  result <- put(test_dir)
  
  # Should find 4 annotations
  expect_equal(nrow(result), 4)
  
  # Verify all styles work
  for (i in 1:4) {
    style <- result[result$id == paste0("style", i), ]
    expect_equal(style$label, paste("Style", i))
    expect_equal(style$input, paste0("file", i, ".csv"))
  }
})

# =============================================================================
# S3 Class Tests (putior_workflow)
# =============================================================================

test_that("put() returns a putior_workflow object", {
  test_dir <- tempfile("putior_s3_test_")
  dir.create(test_dir)
  on.exit(unlink(test_dir, recursive = TRUE))

  create_test_file(c('# put label:"Step 1", output:"data.csv"'), "test.R", test_dir)
  result <- put(test_dir)

  expect_s3_class(result, "putior_workflow")
  expect_s3_class(result, "data.frame")
})

test_that("print.putior_workflow shows header with counts", {
  test_dir <- tempfile("putior_print_test_")
  dir.create(test_dir)
  on.exit(unlink(test_dir, recursive = TRUE))

  create_test_file(c(
    '# put label:"Load", node_type:"input", output:"data.csv"',
    '# put label:"Process", node_type:"process", input:"data.csv"'
  ), "test.R", test_dir)
  result <- put(test_dir)

  output <- capture.output(print(result))
  expect_true(any(grepl("putior workflow:", output)))
  expect_true(any(grepl("2 node", output)))
  expect_true(any(grepl("1 file", output)))
  expect_true(any(grepl("Node types:", output)))
})

test_that("print.putior_workflow handles empty workflow", {
  empty_wf <- putior:::as_putior_workflow(putior:::empty_result_df())
  output <- capture.output(print(empty_wf))
  expect_true(any(grepl("0 nodes", output)))
})

test_that("summary.putior_workflow returns structured list", {
  test_dir <- tempfile("putior_summary_test_")
  dir.create(test_dir)
  on.exit(unlink(test_dir, recursive = TRUE))

  create_test_file(c(
    '# put label:"Load", node_type:"input", output:"data.csv"',
    '# put label:"Save", node_type:"output", input:"data.csv"'
  ), "test.R", test_dir)
  result <- put(test_dir)

  output <- capture.output(summ <- summary(result))
  expect_true(any(grepl("putior workflow summary", output)))
  expect_true(any(grepl("Nodes: 2", output)))
  expect_equal(summ$n_nodes, 2)
  expect_equal(summ$n_files, 1)
  expect_true(!is.null(summ$node_types))
})

# Tests for sanitize_mermaid_label
test_that("sanitize_mermaid_label wraps labels in quotes", {
  result <- putior:::sanitize_mermaid_label("Simple Label")
  expect_equal(result, '"Simple Label"')
})

test_that("sanitize_mermaid_label escapes internal quotes", {
  result <- putior:::sanitize_mermaid_label('Say "hello"')
  expect_equal(result, '"Say #quot;hello#quot;"')
})

test_that("sanitize_mermaid_label handles empty/NA/NULL", {
  expect_equal(putior:::sanitize_mermaid_label(""), "")
  expect_true(is.na(putior:::sanitize_mermaid_label(NA)))
  expect_null(putior:::sanitize_mermaid_label(NULL))
})

test_that("sanitize_mermaid_label handles special Mermaid characters", {
  # Brackets, braces, parens are safe inside quotes
  result <- putior:::sanitize_mermaid_label("data [v2] (final)")
  expect_equal(result, '"data [v2] (final)"')
})

test_that("put_diagram handles labels with special characters", {
  temp_dir <- tempdir()
  test_dir <- file.path(temp_dir, "putior_test_special_chars")
  dir.create(test_dir, showWarnings = FALSE)
  on.exit(unlink(test_dir, recursive = TRUE))

  create_test_file(c(
    '# put id:"node1", label:"Load [v2] Data", node_type:"process"'
  ), "test.R", test_dir)
  workflow <- put(test_dir)
  diagram <- put_diagram(workflow, output = "raw")

  # Should not error and should contain the label
  expect_true(grepl("Load", diagram))
})