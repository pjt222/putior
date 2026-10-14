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
  skip_if_not_installed("mcptools", "1.0.0")
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

  # Without warnings one item; with warnings a second one, as text, not an
  # error, and not as structured content
  expect_length(diagram_response$result$content, 1)
  warned_response <- call_tool("put_diagram", list(path = project_dir, title = "a<b"))
  expect_length(warned_response$result$content, 2)
  expect_false(isTRUE(warned_response$result$isError))
  expect_null(warned_response$result$structuredContent)
  expect_identical(warned_response$result$content[[1]]$text,
                   suppressWarnings(put_diagram(put(project_dir), output = "raw", title = "a<b")))
  expect_match(warned_response$result$content[[2]]$text, "^\n%% putior warnings \\(1\\)")
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
  # Every argument a client sends as null gets its default
  null_arguments <- function(wrapper) {
    argument_names <- setdiff(names(formals(wrapper)), "path")
    stats::setNames(rep(list(NULL), length(argument_names)), argument_names)
  }
  expect_identical(do.call(mcp_put_diagram, c(list(project_dir), null_arguments(mcp_put_diagram))),
                   mcp_put_diagram(project_dir))
  for (wrapper in list(mcp_put, mcp_put_auto, mcp_put_generate, mcp_put_merge)) {
    expect_identical(do.call(wrapper, c(list(project_dir), null_arguments(wrapper))),
                     wrapper(project_dir))
  }
  expect_identical(mcp_list_supported_languages(NULL), list_supported_languages())
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

test_that("MCP tools return R's warnings as a second item", {
  skip_if_not_installed("ellmer")
  skip_if_not_installed("jsonlite")
  warn_dir <- file.path(tempdir(), "putior_mcp_warn")
  unlink(warn_dir, recursive = TRUE)
  dir.create(warn_dir)
  on.exit(unlink(warn_dir, recursive = TRUE), add = TRUE)
  writeLines(c('# put id:"a", label:"A", node_type:"unknown_type", output:"x.csv"',
               '# put id:"b", label:"Keep n<threshold", input:"x.csv"'),
             file.path(warn_dir, "a.R"))
  tools <- putior_mcp_tools()

  # The scan tools: the JSON as before, then the warnings; nothing escapes
  expect_no_warning(nodes_reply <- tools$put(path = warn_dir))
  expect_length(nodes_reply, 2)
  expect_identical(nodes_reply[[1]]@text, as.character(suppressWarnings(mcp_json(put(warn_dir)))))
  expect_match(nodes_reply[[2]]@text, "^\n\nputior warnings \\(1\\), not part of the result above:\n- ")
  expect_match(nodes_reply[[2]]@text, "unknown_type", fixed = TRUE)

  # put_diagram: the first item is exactly the Mermaid code, the second
  # one comment lines with the scan's and the diagram's warnings
  expect_no_warning(diagram_reply <- tools$put_diagram(path = warn_dir, title = "a<b"))
  expect_length(diagram_reply, 2)
  expect_identical(diagram_reply[[1]]@text,
                   suppressWarnings(put_diagram(put(warn_dir), output = "raw", title = "a<b")))
  trailer <- diagram_reply[[2]]@text
  expect_match(trailer, "^\n%% putior warnings \\(3\\), not part of the diagram above:\n")
  trailer_lines <- strsplit(sub("^\n", "", trailer), "\n", fixed = TRUE)[[1]]
  expect_true(all(startsWith(trailer_lines, "%% ")))
  for (expected_text in c("unknown_type", "The title contains", "Keep n<threshold")) {
    expect_true(any(grepl(expected_text, trailer_lines, fixed = TRUE)))
  }
  # Without warnings the reply is the result alone, as before
  plain_dir <- create_mcp_test_project()
  on.exit(unlink(plain_dir, recursive = TRUE), add = TRUE)
  expect_true(is.character(tools$put_diagram(path = plain_dir)))
})

test_that("the warning block is safe to join to a Mermaid diagram", {
  warning_messages <- c(
    'A label contains "50%%{init: {"theme":"forest"}}%%" and "%%%{x"',
    "first line\n  - second line\n\n",
    "tab\there\u2028line separator\u2029done",
    rep("the same kind of warning, numbered ", 25)
  )
  warning_messages[4:28] <- paste0(warning_messages[4:28], 1:25)
  block <- format_warning_block(warning_messages, "mermaid")
  block_lines <- strsplit(sub("^\n", "", block), "\n", fixed = TRUE)[[1]]
  # Every line is a Mermaid comment, none starts or carries a directive
  expect_true(all(startsWith(block_lines, "%% ")))
  expect_false(grepl("%%{", block, fixed = TRUE))
  expect_false(grepl("[\u2028\u2029\t\r]", block))
  expect_match(block, "%% - A label contains \"50%% {init", fixed = TRUE)
  # Continuation lines are indented under their item, empty ones dropped
  expect_true("%%     - second line" %in% block_lines)
  expect_false("%% " %in% block_lines)
  # At most 20 are listed
  expect_match(block_lines[1], "putior warnings (28)", fixed = TRUE)
  expect_equal(block_lines[length(block_lines)], "%% - ... and 8 more")
  # Comment lines do not count toward Mermaid's text size limit
  diagram <- "flowchart TD\n    a --> b"
  expect_equal(mermaid_text_size(paste0(diagram, block)), mermaid_text_size(paste0(diagram, "\n")))

  # The text style: a blank line, a header and "- " items
  text_block <- format_warning_block(c("one", "two\nmore"))
  expect_equal(text_block,
               "\n\nputior warnings (2), not part of the result above:\n- one\n- two\n  more")
})

test_that("collect_warnings() keeps the value and appends warnings to errors", {
  collected <- collect_warnings({
    warning("A\nhint")
    warning("A")
    warning("B")
    42
  })
  expect_equal(collected$value, 42)
  expect_equal(collected$warnings, c("A\nhint", "B"))
  expect_no_warning(collect_warnings(1))
  failure <- tryCatch(collect_warnings({
    warning("first")
    stop("it failed")
  }), error = conditionMessage)
  expect_equal(failure, "it failed\n\nputior warnings (1), raised before the error:\n- first")
})

test_that("every MCP tool that can warn returns its warnings", {
  skip_if_not_installed("ellmer")
  skip_if_not_installed("jsonlite")
  project_dir <- create_mcp_test_project()
  on.exit(unlink(project_dir, recursive = TRUE), add = TRUE)
  tools <- putior_mcp_tools()
  # Each scan warns once and returns a small result
  warned_workflow <- function(...) {
    warning("scan warning")
    data.frame(id = "a", label = "A", stringsAsFactors = FALSE)
  }
  local_mocked_bindings(
    put_auto = warned_workflow,
    put_merge = warned_workflow,
    put_generate = function(...) {
      warning("scan warning")
      "# put id:\"a\""
    }
  )
  replies <- list(
    put_auto = tools$put_auto(path = project_dir),
    put_merge = tools$put_merge(path = project_dir),
    put_generate = tools$put_generate(path = project_dir),
    putior_guide = tools$putior_guide(topic = "no_such_topic")
  )
  for (tool_name in names(replies)) {
    expect_length(replies[[tool_name]], 2)
    expect_match(replies[[tool_name]][[2]]@text, "putior warnings (1)", fixed = TRUE,
                 label = tool_name)
  }
  expect_match(replies$put_generate[[1]]@text, '# put id:"a"', fixed = TRUE)
})

test_that("a warning with invalid UTF-8 is listed with its bytes", {
  bad_text <- rawToChar(as.raw(c(0x61, 0xff, 0x62)))
  Encoding(bad_text) <- "UTF-8"
  expect_no_warning(block <- format_warning_block(bad_text))
  expect_match(block, "- a<ff>b", fixed = TRUE)
})

test_that("long warnings are cut in the block", {
  block <- format_warning_block(strrep("x", 1500))
  expect_match(block, paste0("- ", strrep("x", 1000), " ... (500 more characters)"), fixed = TRUE)
})

test_that("putior_mcp_server() asks for mcptools 1.0.0 or later", {
  skip_if_not_installed("mcptools")
  local_mocked_bindings(packageVersion = function(pkg, ...) package_version("0.2.1"),
                        .package = "utils")
  # Without the check the test fails instead of starting a server that reads stdin
  local_mocked_bindings(mcp_server = function(...) stop("reached mcp_server"),
                        .package = "mcptools")
  expect_error(putior_mcp_server(), "needs mcptools 1.0.0 or later", fixed = TRUE)
})

test_that("putior_mcp_server() serves only putior's tools", {
  skip_if_not_installed("mcptools", "1.0.0")
  skip_if_not_installed("ellmer")
  server_arguments <- NULL
  local_mocked_bindings(
    mcp_server = function(...) server_arguments <<- list(...),
    .package = "mcptools"
  )
  putior_mcp_server()
  expect_false(server_arguments$session_tools)
  expect_length(server_arguments$tools, 16)
})

# =============================================================================
# The server over HTTP: scan root, token and trusted hosts (#111)
# =============================================================================

# Mock mcptools::mcp_server() to record what putior set up for it
record_mcp_server_setup <- function(env = parent.frame()) {
  recorded <- new.env()
  local_mocked_bindings(
    mcp_server = function(...) {
      recorded$arguments <- list(...)
      recorded$root <- .mcp_state$root
      recorded$secret <- getOption("mcptools.http_shared_secret")
      recorded$trusted_hosts <- getOption("mcptools.http_trusted_hosts")
      if (!is.null(recorded$check)) recorded$statuses <- recorded$check()
    },
    .package = "mcptools", .env = env
  )
  recorded
}

test_that("putior_mcp_server() over HTTP sets a root, secret and trusted hosts (#111)", {
  skip_if_not_installed("mcptools", "1.0.0")
  skip_if_not_installed("ellmer")
  root <- file.path(tempdir(), "mcp_http_root")
  dir.create(root, showWarnings = FALSE)
  on.exit(unlink(root, recursive = TRUE), add = TRUE)
  old_options <- options(mcptools.http_shared_secret = "theirs",
                         mcptools.http_trusted_hosts = "theirs")
  on.exit(options(old_options), add = TRUE)
  recorded <- record_mcp_server_setup()

  # Over stdio nothing changes
  putior_mcp_server()
  expect_null(recorded$root)
  expect_identical(recorded$secret, "theirs")

  # Without a token: the loopback names, with and without the port, next to
  # the hosts already trusted; a secret set for mcptools stays in force
  putior_mcp_server(type = "http", port = 8123, root = root)
  expect_identical(recorded$root, normalizePath(root, winslash = "/"))
  expect_identical(recorded$secret, "theirs")
  expect_setequal(recorded$trusted_hosts, c(
    "theirs", "127.0.0.1:8123", "localhost:8123", "[::1]:8123", "127.0.0.1", "localhost", "[::1]"
  ))
  # Another loopback address and IPv6 are written as clients send them
  putior_mcp_server(type = "http", host = "127.0.0.2", port = 8123, root = root)
  expect_true("127.0.0.2:8123" %in% recorded$trusted_hosts)
  putior_mcp_server(type = "http", host = "::1", port = 8123, root = root)
  expect_true("[::1]:8123" %in% recorded$trusted_hosts)
  # Restored when the server stops
  expect_null(.mcp_state$root)
  expect_identical(getOption("mcptools.http_shared_secret"), "theirs")
  expect_identical(getOption("mcptools.http_trusted_hosts"), "theirs")

  # With a token: every request must send it; trusted hosts stay as set
  token <- "0123456789abcdef0123"
  expect_warning(
    putior_mcp_server(type = "http", host = "0.0.0.0", port = 8123, root = root, token = token),
    "0.0.0.0", fixed = TRUE
  )
  expect_identical(recorded$secret, token)
  expect_identical(recorded$trusted_hosts, "theirs")
  expect_identical(getOption("mcptools.http_shared_secret"), "theirs")
})

test_that("putior_mcp_server() over HTTP refuses an unsafe setup (#111)", {
  skip_if_not_installed("mcptools", "1.0.0")
  skip_if_not_installed("ellmer")
  recorded <- record_mcp_server_setup()
  for (host in c("0.0.0.0", "192.168.1.5", "example.org")) {
    expect_error(putior_mcp_server(type = "http", host = host), "needs a token",
                 fixed = TRUE, label = host)
  }
  for (token in list("short", "0123456789 abcdef0123", NA_character_, 1234567890123456)) {
    expect_error(putior_mcp_server(type = "http", token = token), "at least 16 characters",
                 fixed = TRUE)
  }
  expect_error(putior_mcp_server(type = "http", root = file.path(tempdir(), "no_such_root")),
               "'root' must be an existing folder", fixed = TRUE)
  expect_null(recorded$arguments)
  expect_null(.mcp_state$root)
})

test_that("mcptools refuses requests that the setup does not allow (#111)", {
  # Uses mcptools internals, so only off CRAN
  skip_on_cran()
  skip_if_not_installed("mcptools", "1.0.0")
  skip_if_not_installed("ellmer")
  root <- file.path(tempdir(), "mcp_http_requests")
  dir.create(root, showWarnings = FALSE)
  on.exit(unlink(root, recursive = TRUE), add = TRUE)
  # Without mcptools settings of the session's: they would add to putior's
  old_options <- options(mcptools.http_shared_secret = NULL,
                         mcptools.http_trusted_hosts = NULL,
                         plumber2.sharedSecret = NULL)
  on.exit(options(old_options), add = TRUE)
  old_trusted_hosts <- Sys.getenv("MCPTOOLS_HTTP_TRUSTED_HOSTS", NA)
  Sys.unsetenv("MCPTOOLS_HTTP_TRUSTED_HOSTS")
  if (!is.na(old_trusted_hosts)) {
    on.exit(Sys.setenv(MCPTOOLS_HTTP_TRUSTED_HOSTS = old_trusted_hosts), add = TRUE)
  }
  recorded <- record_mcp_server_setup()
  # DELETE passes every check and then gets 405, so 405 means "allowed"
  request_status <- function(headers) {
    request <- c(list(REQUEST_METHOD = "DELETE"), headers)
    mcptools:::handle_http_request(request)$status
  }
  recorded$check <- function() {
    c(
      loopback = request_status(list(HTTP_HOST = "127.0.0.1:8123")),
      localhost = request_status(list(HTTP_HOST = "localhost:8123")),
      rebinding = request_status(list(HTTP_HOST = "attacker.example:8123")),
      no_host = request_status(list()),
      other_origin = request_status(list(HTTP_HOST = "127.0.0.1:8123",
                                         HTTP_ORIGIN = "http://attacker.example")),
      no_secret = request_status(list(HTTP_HOST = "server.lan:8123")),
      wrong_secret = request_status(list(HTTP_HOST = "server.lan:8123",
                                         HTTP_PLUMBER_SHARED_SECRET = "wrong")),
      right_secret = request_status(list(HTTP_HOST = "server.lan:8123",
                                         HTTP_PLUMBER_SHARED_SECRET = "0123456789abcdef0123"))
    )
  }

  putior_mcp_server(type = "http", port = 8123, root = root)
  expect_equal(recorded$statuses[c("loopback", "localhost")], c(loopback = 405, localhost = 405))
  expect_equal(recorded$statuses[c("rebinding", "no_host", "other_origin", "no_secret")],
               c(rebinding = 403, no_host = 403, other_origin = 403, no_secret = 403))

  suppressWarnings(putior_mcp_server(type = "http", host = "0.0.0.0", port = 8123,
                                     root = root, token = "0123456789abcdef0123"))
  expect_equal(recorded$statuses[c("no_secret", "wrong_secret", "right_secret")],
               c(no_secret = 403, wrong_secret = 403, right_secret = 405))
})

test_that("MCP tools over HTTP scan only inside the root (#111)", {
  skip_if_not_installed("ellmer")
  skip_if_not_installed("jsonlite")
  project_dir <- create_mcp_test_project()
  outside_dir <- file.path(tempdir(), "putior_mcp_outside")
  dir.create(outside_dir, showWarnings = FALSE)
  writeLines('# put id:"secret_step", label:"Secret"', file.path(outside_dir, "other.R"))
  on.exit(unlink(c(project_dir, outside_dir), recursive = TRUE), add = TRUE)
  tools <- putior_mcp_tools()

  # Over stdio (no root) any folder can be scanned
  expect_match(tools$put(path = outside_dir), "secret_step", fixed = TRUE)

  .mcp_state$root <- normalizePath(project_dir, winslash = "/")
  on.exit(.mcp_state$root <- NULL, add = TRUE)
  # A relative path is taken from the root; replies show the root as <root>
  scan_reply <- tools$put(path = ".")
  expect_match(scan_reply, "extract", fixed = TRUE)
  expect_match(scan_reply, "<root>/etl.R", fixed = TRUE)
  expect_false(grepl(.mcp_state$root, scan_reply, fixed = TRUE))
  dir.create(file.path(project_dir, "empty"), showWarnings = FALSE)
  expect_error(tools$put_diagram(path = "empty"), "found in: <root>/empty", fixed = TRUE)
  # Click links would name the files by their path on the server
  expect_error(tools$put_diagram(path = ".", enable_clicks = TRUE),
               "enable_clicks is not available over HTTP", fixed = TRUE)
  # Anything but FALSE, as a client may send another value
  expect_error(mcp_put_diagram(path = ".", enable_clicks = "yes"),
               "enable_clicks is not available over HTTP", fixed = TRUE)
  expect_match(tools$put(path = "etl.R"), "clean", fixed = TRUE)
  expect_match(tools$put_diagram(path = "."), "flowchart", fixed = TRUE)
  # Outside the root: an error naming the root as <root>, for every scanning tool
  outside_path <- normalizePath(outside_dir, winslash = "/")
  scans <- list(
    put = function() tools$put(path = outside_path),
    put_diagram = function() tools$put_diagram(path = outside_path),
    put_auto = function() tools$put_auto(path = outside_path),
    put_generate = function() tools$put_generate(path = outside_path),
    put_merge = function() tools$put_merge(path = outside_path)
  )
  for (tool_name in names(scans)) {
    expect_error(scans[[tool_name]](), "outside the folder this server scans", fixed = TRUE,
                 label = tool_name)
  }
  expect_error(tools$put(path = "../putior_mcp_outside"),
               "Path rejected: directory traversal", fixed = TRUE)
})

test_that("mcp_confine_scan() adds the excludes for links out of the root (#111)", {
  root <- file.path(tempdir(), "mcp_confine_root")
  dir.create(root, showWarnings = FALSE)
  on.exit(unlink(root, recursive = TRUE), add = TRUE)
  normalized_root <- normalizePath(root, winslash = "/")
  # Over stdio, path and exclude stay as given
  expect_identical(mcp_confine_scan("R", TRUE, "a,b"), list(path = "R", exclude = "a,b"))

  .mcp_state$root <- normalized_root
  on.exit(.mcp_state$root <- NULL, add = TRUE)
  local_mocked_bindings(acp_outside_excludes = function(...) "^outside/")
  # A comma-separated exclude is split, since put() splits only a single one
  expect_identical(mcp_confine_scan(".", TRUE, "a, b"),
                   list(path = normalized_root, exclude = c("a", "b", "^outside/")))
  expect_identical(mcp_confine_scan(".", TRUE, NULL)$exclude, "^outside/")
  local_mocked_bindings(acp_outside_excludes = function(...) NULL)
  expect_identical(mcp_confine_scan(".", TRUE, "a,b")$exclude, "a,b")
})

test_that("MCP warnings over HTTP show the root as <root> (#111)", {
  skip_if_not_installed("ellmer")
  skip_if_not_installed("jsonlite")
  root <- file.path(tempdir(), "mcp warn root")
  dir.create(root, showWarnings = FALSE)
  on.exit(unlink(root, recursive = TRUE), add = TRUE)
  normalized_root <- normalizePath(root, winslash = "/")
  .mcp_state$root <- normalized_root
  on.exit(.mcp_state$root <- NULL, add = TRUE)
  local_mocked_bindings(put = function(...) {
    warning("Cannot read ", normalized_root, "/a.R (", normalized_root, ")")
    data.frame(id = "a", label = "A", stringsAsFactors = FALSE)
  })
  reply <- putior_mcp_tools()$put(path = ".")
  expect_length(reply, 2)
  expect_match(reply[[2]]@text, "Cannot read <root>/a.R (<root>)", fixed = TRUE)
  expect_false(grepl(normalized_root, reply[[2]]@text, fixed = TRUE))
})

test_that("the MCP server over HTTP does not start if mcptools ignores its settings (#111)", {
  skip_if_not_installed("mcptools", "1.0.0")
  skip_if_not_installed("ellmer")
  # The installed mcptools enforces them
  expect_no_error(mcp_check_http_security())

  recorded <- record_mcp_server_setup()
  old_options <- options(mcptools.http_shared_secret = "theirs",
                         mcptools.http_trusted_hosts = "theirs")
  on.exit(options(old_options), add = TRUE)
  # A version that serves every request, or whose handler has changed
  for (handler in list(function(request) list(status = 405L),
                       function(request) stop("no such field"),
                       function(request) list(status = 403L))) {
    local_mocked_bindings(handle_http_request = handler, .package = "mcptools")
    expect_error(putior_mcp_server(type = "http", port = 8123),
                 "did not refuse putior's test requests", fixed = TRUE)
    expect_null(recorded$arguments)
    expect_null(.mcp_state$root)
    expect_identical(getOption("mcptools.http_shared_secret"), "theirs")
    expect_identical(getOption("mcptools.http_trusted_hosts"), "theirs")
  }
  # Over stdio mcptools checks nothing, so the check is not made
  putior_mcp_server()
  expect_false(is.null(recorded$arguments))
})
