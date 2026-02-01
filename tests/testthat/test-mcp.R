# Tests for MCP Server functionality
# These tests verify the MCP tool definitions and server setup

# Test putior_mcp_tools function
test_that("putior_mcp_tools returns correct number of tools", {
  skip_if_not_installed("ellmer")

  tools <- putior_mcp_tools()

  # Should have 16 tools (excluding run_sandbox by default)
  expect_equal(length(tools), 16)
})

test_that("putior_mcp_tools includes all expected tool names", {
  skip_if_not_installed("ellmer")

  tools <- putior_mcp_tools()
  tool_names <- names(tools)

  expected_tools <- c(
    # Core workflow functions
    "put",
    "put_diagram",
    "put_auto",
    "put_generate",
    "put_merge",

    # Reference/discovery functions
    "get_comment_prefix",
    "get_supported_extensions",
    "list_supported_languages",
    "get_detection_patterns",
    "get_diagram_themes",
    "putior_skills",
    "putior_help",
    "set_putior_log_level",

    # Utility functions
    "is_valid_put_annotation",
    "split_file_list",
    "ext_to_language"
  )

  for (tool_name in expected_tools) {
    expect_true(
      tool_name %in% tool_names,
      info = paste("Expected tool", tool_name, "to be present")
    )
  }
})

test_that("putior_mcp_tools exclude parameter works", {
  skip_if_not_installed("ellmer")

  # Exclude additional tools
  tools <- putior_mcp_tools(exclude = c("run_sandbox", "put_diagram", "put_auto"))
  tool_names <- names(tools)

  expect_false("put_diagram" %in% tool_names)
  expect_false("put_auto" %in% tool_names)
  expect_true("put" %in% tool_names)
})

test_that("putior_mcp_tools include parameter works", {
  skip_if_not_installed("ellmer")

  # Include only specific tools
  tools <- putior_mcp_tools(include = c("put", "put_diagram"))
  tool_names <- names(tools)

  expect_equal(length(tools), 2)
  expect_true("put" %in% tool_names)
  expect_true("put_diagram" %in% tool_names)
  expect_false("put_auto" %in% tool_names)
})

test_that("tool definitions have required fields", {
  skip_if_not_installed("ellmer")

  tools <- putior_mcp_tools()

  for (tool_name in names(tools)) {
    tool <- tools[[tool_name]]

    # Each tool should have a name (using S7 @ accessor)
    expect_true(
      !is.null(tool@name),
      info = paste("Tool", tool_name, "should have a name")
    )

    # Each tool should have a description
    expect_true(
      !is.null(tool@description) && nchar(tool@description) > 0,
      info = paste("Tool", tool_name, "should have a description")
    )
  }
})

test_that("putior_mcp_tools fails gracefully without ellmer", {
  # This test verifies the error message when ellmer is not available
  # We can't actually unload ellmer in a test, so we check the error handling
  # exists in the code by inspecting the function

  # The function should check for ellmer and provide helpful error message
  fn_body <- body(putior_mcp_tools)
  fn_text <- paste(deparse(fn_body), collapse = "\n")

  expect_true(grepl("ellmer", fn_text))
  expect_true(grepl("requireNamespace", fn_text))
})

test_that("putior_mcp_server fails gracefully without dependencies",
{
  # This test verifies the error messages when mcptools/ellmer are not available
  # We check that the function has proper error handling

  fn_body <- body(putior_mcp_server)
  fn_text <- paste(deparse(fn_body), collapse = "\n")

  # Should check for mcptools
  expect_true(grepl("mcptools", fn_text))
  # Should check for ellmer
  expect_true(grepl("ellmer", fn_text))
  # Should use requireNamespace
  expect_true(grepl("requireNamespace", fn_text))
})

# Test that individual tool maker functions work
test_that("make_tool_put creates valid tool definition", {
  skip_if_not_installed("ellmer")

  tool <- putior:::make_tool_put()

  expect_equal(tool@name, "put")
  expect_true(nchar(tool@description) > 50)
})

test_that("make_tool_put_diagram creates valid tool definition", {
  skip_if_not_installed("ellmer")

  tool <- putior:::make_tool_put_diagram()

  expect_equal(tool@name, "put_diagram")
  expect_true(nchar(tool@description) > 50)
})

test_that("make_tool_put_auto creates valid tool definition", {
  skip_if_not_installed("ellmer")

  tool <- putior:::make_tool_put_auto()

  expect_equal(tool@name, "put_auto")
  expect_true(nchar(tool@description) > 50)
})

test_that("make_tool_get_comment_prefix creates valid tool definition", {
  skip_if_not_installed("ellmer")

  tool <- putior:::make_tool_get_comment_prefix()

  expect_equal(tool@name, "get_comment_prefix")
  expect_true(nchar(tool@description) > 20)
})

test_that("make_tool_putior_skills creates valid tool definition", {
  skip_if_not_installed("ellmer")

  tool <- putior:::make_tool_putior_skills()

  expect_equal(tool@name, "putior_skills")
  expect_true(nchar(tool@description) > 50)
})

# Test that core functions work correctly (integration tests)
test_that("put function works correctly for MCP integration", {
  # Create a temporary file with PUT annotation
  tmp_dir <- tempdir()
  tmp_file <- file.path(tmp_dir, "test_mcp.R")

  writeLines(c(
    '#put id:"test", label:"Test Node"',
    'x <- 1'
  ), tmp_file)

  on.exit(unlink(tmp_file))

  # Test that put() works as expected
  result <- put(tmp_file)

  expect_true(is.data.frame(result))
  expect_true("id" %in% names(result))
  expect_equal(result$id[1], "test")
})

test_that("get_comment_prefix works correctly for MCP integration", {
  expect_equal(get_comment_prefix("r"), "#")
  expect_equal(get_comment_prefix("sql"), "--")
  expect_equal(get_comment_prefix("js"), "//")
  expect_equal(get_comment_prefix("m"), "%")
})

test_that("list_supported_languages works correctly for MCP integration", {
  # All languages
  all_langs <- list_supported_languages()
  expect_true(length(all_langs) > 15)
  expect_true("r" %in% all_langs)
  expect_true("python" %in% all_langs)

  # Detection only
  detection_langs <- list_supported_languages(detection_only = TRUE)
  expect_true(length(detection_langs) == 15)
  expect_true("r" %in% detection_langs)
  expect_true("javascript" %in% detection_langs)
})

test_that("is_valid_put_annotation works correctly for MCP integration", {
  expect_true(is_valid_put_annotation('#put id:"test", label:"Test"'))
  expect_true(is_valid_put_annotation('--put id:"query", label:"SQL Query"'))
  expect_true(is_valid_put_annotation('//put id:"handler", label:"JS Handler"'))
  expect_false(is_valid_put_annotation('#put invalid syntax'))
})

test_that("split_file_list works correctly for MCP integration", {
  result <- split_file_list("file1.csv, file2.csv, file3.csv")
  expect_equal(length(result), 3)
  expect_equal(result[1], "file1.csv")
  expect_equal(result[2], "file2.csv")
  expect_equal(result[3], "file3.csv")
})

test_that("ext_to_language works correctly for MCP integration", {
  expect_equal(ext_to_language("r"), "r")
  expect_equal(ext_to_language("py"), "python")
  expect_equal(ext_to_language("js"), "javascript")
  expect_equal(ext_to_language("sql"), "sql")
  expect_null(ext_to_language("xyz"))
})

test_that("get_diagram_themes works correctly for MCP integration", {
  themes <- get_diagram_themes()

  expect_true(is.list(themes))
  expect_true("light" %in% names(themes))
  expect_true("dark" %in% names(themes))
  expect_true("github" %in% names(themes))
})
