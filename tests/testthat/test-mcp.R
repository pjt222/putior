# Tests for MCP Server functionality
# These tests verify the MCP tool definitions and server setup

# Test putior_mcp_tools function
test_that("putior_mcp_tools returns correct number of tools", {
  skip_if_not_installed("ellmer")

  tools <- putior_mcp_tools()

  # Should have at least 16 tools (excluding run_sandbox by default)
  expect_gte(length(tools), 16)
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
    "putior_guide",
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

test_that("make_tool_putior_guide creates valid tool definition", {
  skip_if_not_installed("ellmer")

  tool <- putior:::make_tool_putior_guide()

  expect_equal(tool@name, "putior_guide")
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
  expect_true(length(detection_langs) == 18)
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
  # Colorblind-safe viridis family themes
  expect_true("viridis" %in% names(themes))
  expect_true("magma" %in% names(themes))
  expect_true("plasma" %in% names(themes))
  expect_true("cividis" %in% names(themes))
})

# =============================================================================
# Tool results as an MCP client receives them (#65)
# =============================================================================

create_mcp_test_project <- function() {
  project_dir <- file.path(tempdir(), "putior_mcp_tools_test")
  unlink(project_dir, recursive = TRUE)
  dir.create(project_dir)
  writeLines(c(
    '# put id:"extract", label:"Extract", output:"raw.csv"',
    'data <- read.csv("source.csv")',
    '# put id:"clean", label:"Clean", input:"raw.csv", output:"clean.csv"',
    'write.csv(data, "clean.csv")'
  ), file.path(project_dir, "etl.R"))
  project_dir
}

test_that("MCP tools return text and print nothing", {
  skip_if_not_installed("ellmer")
  skip_if_not_installed("jsonlite")
  project_dir <- create_mcp_test_project()
  on.exit(unlink(project_dir, recursive = TRUE), add = TRUE)
  tools <- putior_mcp_tools()

  # set_putior_log_level is left out because it changes a global option.
  tool_arguments <- list(
    put = list(path = project_dir),
    put_diagram = list(path = project_dir),
    put_auto = list(path = project_dir),
    put_generate = list(path = project_dir),
    put_merge = list(path = project_dir),
    get_comment_prefix = list(ext = "sql"),
    get_supported_extensions = list(),
    list_supported_languages = list(),
    get_detection_patterns = list(language = "r", type = "input"),
    get_diagram_themes = list(),
    putior_guide = list(topic = "syntax"),
    putior_help = list(),
    is_valid_put_annotation = list(line = '# put id:"a", label:"A"'),
    split_file_list = list(file_string = "a.csv, b.csv"),
    ext_to_language = list(ext = "py")
  )
  expect_setequal(names(tool_arguments), setdiff(names(tools), "set_putior_log_level"))

  for (tool_name in names(tool_arguments)) {
    # With the stdio transport, anything printed lands in the JSON-RPC stream.
    printed <- utils::capture.output(
      result <- do.call(tools[[tool_name]], tool_arguments[[tool_name]])
    )
    expect_equal(length(printed), 0, info = tool_name)
    expect_true(is.atomic(result) && length(result) > 0, info = tool_name)
  }
})

test_that("MCP data tools return JSON with field names", {
  skip_if_not_installed("ellmer")
  skip_if_not_installed("jsonlite")
  project_dir <- create_mcp_test_project()
  on.exit(unlink(project_dir, recursive = TRUE), add = TRUE)
  tools <- putior_mcp_tools()

  nodes <- jsonlite::fromJSON(tools$put(path = project_dir))
  expect_true(is.data.frame(nodes))
  expect_setequal(nodes$id, c("extract", "clean"))
  expect_true(all(c("file_name", "label", "input", "output") %in% names(nodes)))

  for (tool_name in c("put_auto", "put_merge")) {
    detected <- jsonlite::fromJSON(tools[[tool_name]](path = project_dir))
    expect_true(is.data.frame(detected), info = tool_name)
    expect_true("id" %in% names(detected), info = tool_name)
  }

  patterns <- jsonlite::fromJSON(tools$get_detection_patterns(language = "r", type = "input"))
  expect_true(all(c("regex", "func", "description") %in% names(patterns)))

  themes <- jsonlite::fromJSON(tools$get_diagram_themes())
  expect_true(all(c("light", "dark", "github") %in% names(themes)))
})

test_that("MCP put_diagram tool takes a path and returns Mermaid code", {
  skip_if_not_installed("ellmer")
  project_dir <- create_mcp_test_project()
  on.exit(unlink(project_dir, recursive = TRUE), add = TRUE)
  tools <- putior_mcp_tools()

  expect_true("path" %in% names(tools$put_diagram@arguments@properties))
  code <- tools$put_diagram(path = project_dir, direction = "LR")
  expect_match(code, "flowchart LR", fixed = TRUE)
  expect_match(code, 'extract["Extract"]', fixed = TRUE)
  expect_match(code, 'clean["Clean"]', fixed = TRUE)
})

test_that("MCP tools expose no arguments that write files or the clipboard", {
  skip_if_not_installed("ellmer")
  tools <- putior_mcp_tools()

  for (tool_name in names(tools)) {
    argument_names <- names(tools[[tool_name]]@arguments@properties)
    expect_false(
      any(c("output", "file", "insert") %in% argument_names),
      info = tool_name
    )
  }
})

test_that("MCP results reach the client as JSON text through mcptools", {
  # Uses an mcptools internal (the server's tools/call handler); keep it off CRAN.
  skip_on_cran()
  skip_if_not_installed("mcptools")
  skip_if_not_installed("jsonlite")
  project_dir <- create_mcp_test_project()
  on.exit(unlink(project_dir, recursive = TRUE), add = TRUE)
  tools <- putior_mcp_tools()
  execute_tool_call <- utils::getFromNamespace("execute_tool_call", "mcptools")

  call_tool <- function(tool_name, arguments) {
    execute_tool_call(list(
      id = 1L, protocolVersion = "2025-06-18",
      params = list(name = tool_name, arguments = arguments),
      tool = tools[[tool_name]]
    ))
  }

  put_response <- call_tool("put", list(path = project_dir))
  nodes <- jsonlite::fromJSON(put_response$result$content[[1]]$text)
  expect_setequal(nodes$id, c("extract", "clean"))

  diagram_response <- call_tool("put_diagram", list(path = project_dir))
  expect_null(diagram_response$error)
  expect_match(diagram_response$result$content[[1]]$text, "flowchart TD", fixed = TRUE)

  help_response <- call_tool("putior_help", list())
  expect_match(help_response$result$content[[1]]$text, "putior Quick Reference", fixed = TRUE)
})

test_that("ellmer accepts MCP tool results without a deprecation warning", {
  # Uses an ellmer internal (the function that warns); keep it off CRAN.
  skip_on_cran()
  skip_if_not_installed("ellmer", minimum_version = "0.5.0")
  skip_if_not_installed("jsonlite")
  normalize_tool_result <- tryCatch(
    utils::getFromNamespace("normalize_tool_result", "ellmer"),
    error = function(e) NULL
  )
  skip_if(is.null(normalize_tool_result), "ellmer has no normalize_tool_result()")
  project_dir <- create_mcp_test_project()
  on.exit(unlink(project_dir, recursive = TRUE), add = TRUE)
  old_options <- options(lifecycle_verbosity = "warning")
  on.exit(options(old_options), add = TRUE)
  tools <- putior_mcp_tools()

  expect_no_warning(normalize_tool_result(tools$put(path = project_dir)))
  expect_no_warning(normalize_tool_result(tools$get_detection_patterns(language = "r")))
})

test_that("GUIDE.md version matches the package version", {
  guide_lines <- readLines(system.file("GUIDE.md", package = "putior"), n = 20)
  version_line <- grep("^version:", guide_lines, value = TRUE)

  expect_length(version_line, 1)
  expect_equal(
    sub("^version:\\s*", "", version_line),
    as.character(utils::packageVersion("putior"))
  )
})

test_that("MCP put_diagram passes its arguments through unchanged", {
  skip_if_not_installed("ellmer")
  project_dir <- create_mcp_test_project()
  on.exit(unlink(project_dir, recursive = TRUE), add = TRUE)
  tools <- putior_mcp_tools()

  # The tool must give exactly what put() + put_diagram() give directly.
  expect_identical(
    tools$put_diagram(path = project_dir, theme = "dark", direction = "LR",
                      show_artifacts = TRUE, title = "ETL"),
    put_diagram(put(project_dir), output = "raw", theme = "dark",
                direction = "LR", show_artifacts = TRUE, title = "ETL")
  )
  # The Mermaid configuration in the frontmatter (#54)
  expect_identical(
    tools$put_diagram(path = project_dir, mermaid_config = "none"),
    put_diagram(put(project_dir), output = "raw", mermaid_config = "none")
  )
  expect_true(startsWith(tools$put_diagram(path = project_dir), "---\nconfig:"))
  # Direct edges next to artifact paths (#55)
  expect_identical(
    tools$put_diagram(path = project_dir, show_artifacts = TRUE, artifact_edges = "both"),
    put_diagram(put(project_dir), output = "raw", show_artifacts = TRUE, artifact_edges = "both")
  )
  # Accessibility metadata (#50)
  expect_identical(
    tools$put_diagram(path = project_dir, accessibility = FALSE),
    put_diagram(put(project_dir), output = "raw", accessibility = FALSE)
  )
  expect_match(tools$put_diagram(path = project_dir), "accDescr: Workflow with 2 steps", fixed = TRUE)
  # Click links need line numbers, which the tool asks put() for.
  expect_identical(
    tools$put_diagram(path = project_dir, enable_clicks = TRUE, click_protocol = "file"),
    put_diagram(put(project_dir, include_line_numbers = TRUE), output = "raw",
                enable_clicks = TRUE, click_protocol = "file")
  )
})

test_that("MCP put passes include_line_numbers through", {
  skip_if_not_installed("ellmer")
  skip_if_not_installed("jsonlite")
  project_dir <- create_mcp_test_project()
  on.exit(unlink(project_dir, recursive = TRUE), add = TRUE)
  tools <- putior_mcp_tools()

  nodes <- jsonlite::fromJSON(tools$put(path = project_dir, include_line_numbers = TRUE))

  expect_equal(nodes$line_number, c(1L, 3L))
})

test_that("MCP set_putior_log_level and ext_to_language return readable text", {
  skip_if_not_installed("ellmer")
  tools <- putior_mcp_tools()
  old_level <- getOption("putior.log_level", "WARN")
  on.exit(set_putior_log_level(old_level), add = TRUE)
  set_putior_log_level("WARN")

  expect_equal(tools$set_putior_log_level(level = "INFO"), "Log level set to INFO (was WARN)")
  expect_equal(tools$ext_to_language(ext = "py"), "python")
  expect_match(tools$ext_to_language(ext = "xyz"), "No language is registered", fixed = TRUE)
})

# Empty results and the put_diagram source argument (#73)

test_that("MCP scan tools report why a scan found no files", {
  skip_if_not_installed("ellmer")
  empty_dir <- file.path(tempdir(), "putior_mcp_empty")
  unlink(empty_dir, recursive = TRUE)
  dir.create(empty_dir)
  on.exit(unlink(empty_dir, recursive = TRUE), add = TRUE)
  project_dir <- create_mcp_test_project()
  on.exit(unlink(project_dir, recursive = TRUE), add = TRUE)
  tools <- putior_mcp_tools()

  for (tool_name in c("put", "put_auto", "put_merge", "put_generate", "put_diagram")) {
    expect_error(tools[[tool_name]](path = empty_dir), "No files matching pattern",
                 label = tool_name)
    # A pattern that matches no file names the pattern
    expect_error(tools[[tool_name]](path = project_dir, pattern = "\\.py$"),
                 "No files matching pattern '\\.py$'", fixed = TRUE, label = tool_name)
  }
  # put_merge() runs put() and put_auto(), which both warn; report it once
  merge_error <- tryCatch(tools$put_merge(path = empty_dir), error = conditionMessage)
  expect_equal(lengths(regmatches(merge_error, gregexpr("No files matching", merge_error))), 1L)
})

test_that("MCP put returns [] for files without annotations", {
  skip_if_not_installed("ellmer")
  plain_dir <- file.path(tempdir(), "putior_mcp_plain")
  unlink(plain_dir, recursive = TRUE)
  dir.create(plain_dir)
  on.exit(unlink(plain_dir, recursive = TRUE), add = TRUE)
  writeLines('data <- read.csv("in.csv")', file.path(plain_dir, "load.R"))
  tools <- putior_mcp_tools()

  expect_equal(as.character(tools$put(path = plain_dir)), "[]")
  # put_diagram names the cause and the way out
  expect_error(tools$put_diagram(path = plain_dir), 'source = "auto"', fixed = TRUE)
  expect_match(tools$put_diagram(path = plain_dir, source = "auto"), '["load"]', fixed = TRUE)
})

test_that("MCP put_diagram draws put_auto() and put_merge() results", {
  skip_if_not_installed("ellmer")
  project_dir <- create_mcp_test_project()
  on.exit(unlink(project_dir, recursive = TRUE), add = TRUE)
  tools <- putior_mcp_tools()

  expect_true(all(c("source", "merge_strategy") %in%
                    names(tools$put_diagram@arguments@properties)))
  expect_identical(
    tools$put_diagram(path = project_dir, source = "annotations", direction = "LR"),
    put_diagram(put(project_dir), output = "raw", direction = "LR")
  )
  expect_identical(
    tools$put_diagram(path = project_dir, source = "auto", show_artifacts = TRUE),
    put_diagram(put_auto(project_dir), output = "raw", show_artifacts = TRUE)
  )
  # Click links get line numbers from every source
  expect_identical(
    tools$put_diagram(path = project_dir, source = "auto", enable_clicks = TRUE),
    put_diagram(put_auto(project_dir, include_line_numbers = TRUE), output = "raw",
                enable_clicks = TRUE)
  )
  expect_error(mcp_put_diagram(project_dir, source = "files"), 'source must be "annotations"')
  # Clients may send null for arguments they leave out
  expect_identical(mcp_put_diagram(project_dir, source = NULL), tools$put_diagram(path = project_dir))
  expect_identical(
    mcp_put_diagram(project_dir, enable_clicks = TRUE, click_protocol = NULL),
    tools$put_diagram(path = project_dir, enable_clicks = TRUE)
  )
  # The tool offers the protocols put_diagram() accepts (#101)
  click_argument <- putior_mcp_tools(include = "put_diagram")[[1]]@arguments@properties$click_protocol
  expect_identical(click_argument@values, .VALID_CLICK_PROTOCOLS)
})

test_that("MCP put_diagram draws each merge strategy", {
  skip_if_not_installed("ellmer")
  # One annotated file and one unannotated file: the annotations,
  # manual_priority and supplement give three different diagrams (union
  # equals supplement here)
  merge_dir <- file.path(tempdir(), "putior_mcp_merge_test")
  unlink(merge_dir, recursive = TRUE)
  dir.create(merge_dir)
  on.exit(unlink(merge_dir, recursive = TRUE), add = TRUE)
  writeLines(c('# put id:"load", label:"Load"', 'd <- read.csv("in.csv")',
               'write.csv(d, "out.csv")'), file.path(merge_dir, "load.R"))
  writeLines(c('d <- read.csv("out.csv")', 'saveRDS(d, "final.rds")'),
             file.path(merge_dir, "report.R"))
  tools <- putior_mcp_tools()

  strategies <- c("manual_priority", "supplement", "union")
  diagrams <- lapply(strategies, function(strategy) {
    tools$put_diagram(path = merge_dir, source = "merge", merge_strategy = strategy)
  })
  for (strategy_index in seq_along(strategies)) {
    expect_identical(
      diagrams[[strategy_index]],
      put_diagram(put_merge(merge_dir, merge_strategy = strategies[strategy_index]), output = "raw"),
      label = strategies[strategy_index]
    )
  }
  expect_false(identical(diagrams[[1]], tools$put_diagram(path = merge_dir)))
  expect_false(identical(diagrams[[1]], diagrams[[2]]))
  expect_false(identical(diagrams[[1]], diagrams[[3]]))
  # null strategy means the default, also for the put_merge tool
  expect_identical(mcp_put_diagram(merge_dir, source = "merge", merge_strategy = NULL), diagrams[[1]])
  expect_identical(tools$put_merge(path = merge_dir, merge_strategy = NULL),
                   tools$put_merge(path = merge_dir))
})

test_that("MCP put_diagram names the cause for each source", {
  skip_if_not_installed("ellmer")
  text_dir <- file.path(tempdir(), "putior_mcp_text_only")
  unlink(text_dir, recursive = TRUE)
  dir.create(text_dir)
  on.exit(unlink(text_dir, recursive = TRUE), add = TRUE)
  writeLines("Some notes", file.path(text_dir, "notes.txt"))
  tools <- putior_mcp_tools()

  # put() reads any file the pattern matches; put_auto() only languages
  # with auto-detection, so .txt files give no nodes and no warning
  expect_error(tools$put_diagram(path = text_dir, pattern = "\\.txt$"),
               'use source = "auto"', fixed = TRUE)
  for (source in c("auto", "merge")) {
    diagram_error <- tryCatch(
      tools$put_diagram(path = text_dir, pattern = "\\.txt$", source = source),
      error = conditionMessage
    )
    expect_match(diagram_error, "put_auto() found no file to analyze", fixed = TRUE, label = source)
    expect_no_match(diagram_error, 'use source = "auto"', fixed = TRUE)
  }
})

test_that("mcp_scan() drops only repeated warnings", {
  scan_with_warnings <- function() {
    warning("A\nhint")
    warning("A")        # the first line of the warning above
    warning("B\nx")
    warning("B\ny")     # same first line, different text
    warning("B\nx")     # an exact repeat
    data.frame()
  }
  scan_error <- tryCatch(mcp_scan(scan_with_warnings()), error = conditionMessage)
  expect_equal(scan_error, "The scan found nothing.\nA\nhint\nB\nx\nB\ny")
})

test_that("MCP scans still raise warnings when they find something", {
  skip_if_not_installed("ellmer")
  warn_dir <- file.path(tempdir(), "putior_mcp_warn")
  unlink(warn_dir, recursive = TRUE)
  dir.create(warn_dir)
  on.exit(unlink(warn_dir, recursive = TRUE), add = TRUE)
  writeLines('# put id:"a", label:"A", node_type:"unknown_type"', file.path(warn_dir, "a.R"))
  tools <- putior_mcp_tools()

  expect_warning(nodes_json <- tools$put(path = warn_dir), "node_type")
  expect_match(as.character(nodes_json), '"id":"a"', fixed = TRUE)
})
