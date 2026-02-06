# Tests for ACP Server functionality
# These tests verify the ACP endpoint handlers, message parsing, and agent manifest

# =============================================================================
# Agent Manifest Tests
# =============================================================================

test_that("putior_acp_manifest returns correct structure", {
  manifest <- putior_acp_manifest()

  expect_true(is.list(manifest))
  expect_equal(manifest$name, "putior")
  expect_true(nchar(manifest$description) > 50)
  expect_true(is.list(manifest$metadata))
})

test_that("putior_acp_manifest contains required metadata", {
  manifest <- putior_acp_manifest()

  expect_true("version" %in% names(manifest$metadata))
  expect_true("capabilities" %in% names(manifest$metadata))
  expect_true("supported_languages" %in% names(manifest$metadata))
  expect_true("operations" %in% names(manifest$metadata))
})

test_that("putior_acp_manifest version matches package version", {
  manifest <- putior_acp_manifest()

  expect_equal(
    manifest$metadata$version,
    as.character(packageVersion("putior"))
  )
})

test_that("putior_acp_manifest includes expected capabilities", {
  manifest <- putior_acp_manifest()
  capabilities <- manifest$metadata$capabilities

  expect_true("scan" %in% capabilities)
  expect_true("diagram" %in% capabilities)
  expect_true("auto-detect" %in% capabilities)
  expect_true("generate" %in% capabilities)
})

test_that("putior_acp_manifest includes expected operations", {
  manifest <- putior_acp_manifest()
  operations <- names(manifest$metadata$operations)

  expected_ops <- c("scan", "diagram", "auto", "generate", "merge", "help", "skills")
  for (op in expected_ops) {
    expect_true(
      op %in% operations,
      info = paste("Expected operation", op, "to be present")
    )
  }
})

# =============================================================================
# Message Parsing Tests
# =============================================================================

test_that("extract_text_content extracts from ACP message format", {
  input <- list(
    list(
      role = "user",
      parts = list(
        list(content = "scan ./R/", content_type = "text/plain")
      )
    )
  )

  content <- putior:::extract_text_content(input)
  expect_equal(content, "scan ./R/")
})

test_that("extract_text_content handles multiple parts", {
  input <- list(
    list(
      role = "user",
      parts = list(
        list(content = "scan", content_type = "text/plain"),
        list(content = "./R/", content_type = "text/plain")
      )
    )
  )

  content <- putior:::extract_text_content(input)
  expect_equal(content, "scan ./R/")
})

test_that("extract_text_content handles empty input", {
  expect_equal(putior:::extract_text_content(NULL), "")
  expect_equal(putior:::extract_text_content(list()), "")
})

test_that("detect_operation identifies scan operation", {
  expect_equal(putior:::detect_operation("scan ./R/ for annotations"), "scan")
  expect_equal(putior:::detect_operation("extract PUT annotations"), "scan")
  expect_equal(putior:::detect_operation("find annotation in files"), "scan")
})

test_that("detect_operation identifies diagram operation", {
  expect_equal(putior:::detect_operation("generate a diagram"), "diagram")
  expect_equal(putior:::detect_operation("visualize workflow"), "diagram")
  expect_equal(putior:::detect_operation("create flowchart"), "diagram")
  expect_equal(putior:::detect_operation("make mermaid diagram"), "diagram")
})

test_that("detect_operation identifies auto operation", {
  expect_equal(putior:::detect_operation("auto-detect workflow"), "auto")
  expect_equal(putior:::detect_operation("autodetect from code"), "auto")
  expect_equal(putior:::detect_operation("use put_auto"), "auto")
})

test_that("detect_operation identifies generate operation", {
  expect_equal(putior:::detect_operation("generate annotation suggestions"), "generate")
  expect_equal(putior:::detect_operation("suggest annotations"), "generate")
})

test_that("detect_operation identifies merge operation", {
  expect_equal(putior:::detect_operation("merge annotations"), "merge")
  expect_equal(putior:::detect_operation("combine manual and auto"), "merge")
})

test_that("detect_operation identifies help operation", {
  expect_equal(putior:::detect_operation("help with syntax"), "help")
  expect_equal(putior:::detect_operation("how to use putior"), "help")
  expect_equal(putior:::detect_operation("usage information"), "help")
})

test_that("detect_operation identifies skills operation", {
  expect_equal(putior:::detect_operation("what are your skills"), "skills")
  expect_equal(putior:::detect_operation("what capabilities do you have"), "skills")
  expect_equal(putior:::detect_operation("what can you do"), "skills")
})

test_that("detect_operation defaults to scan for unknown input", {
  expect_equal(putior:::detect_operation("do something"), "scan")
  expect_equal(putior:::detect_operation(""), "scan")
})

test_that("extract_parameters extracts path from quoted string", {
  params <- putior:::extract_parameters('scan "./R/" for annotations')
  expect_equal(params$path, "./R/")
})

test_that("extract_parameters extracts path from single quotes", {
  params <- putior:::extract_parameters("scan './R/' for annotations")
  expect_equal(params$path, "./R/")
})

test_that("extract_parameters extracts theme", {
  params <- putior:::extract_parameters("generate diagram with theme=github")
  expect_equal(params$theme, "github")

  params2 <- putior:::extract_parameters("use theme: dark")
  expect_equal(params2$theme, "dark")
})

test_that("extract_parameters extracts direction", {
  params <- putior:::extract_parameters("direction=LR")
  expect_equal(params$direction, "LR")
})

test_that("extract_parameters extracts recursive flag", {
  params <- putior:::extract_parameters("scan recursively")
  expect_true(params$recursive)

  params2 <- putior:::extract_parameters("recursive search")
  expect_true(params2$recursive)
})

test_that("extract_parameters extracts artifacts flag", {
  params <- putior:::extract_parameters("show artifacts")
  expect_true(params$show_artifacts)
})

test_that("parse_acp_message combines extraction and detection", {
  input <- list(
    list(
      role = "user",
      parts = list(
        list(content = "scan './R/' recursively", content_type = "text/plain")
      )
    )
  )

  parsed <- putior:::parse_acp_message(input)

  expect_equal(parsed$operation, "scan")
  expect_equal(parsed$params$path, "./R/")
  expect_true(parsed$params$recursive)
  expect_true(nchar(parsed$raw_content) > 0)
})

# =============================================================================
# Output Formatting Tests
# =============================================================================

test_that("format_result_as_text handles data frames", {
  df <- data.frame(
    id = c("node1", "node2"),
    label = c("First Node", "Second Node"),
    input = c("", "data.csv"),
    output = c("data.csv", ""),
    stringsAsFactors = FALSE
  )

  result <- putior:::format_result_as_text(df)

  expect_true(is.character(result))
  expect_true(grepl("node1", result))
  expect_true(grepl("node2", result))
  expect_true(grepl("First Node", result))
  expect_true(grepl("2 workflow node", result))
})

test_that("format_result_as_text handles empty data frames", {
  df <- data.frame(
    id = character(0),
    label = character(0),
    stringsAsFactors = FALSE
  )

  result <- putior:::format_result_as_text(df)
  expect_equal(result, "No annotations found.")
})

test_that("format_result_as_text handles character vectors", {
  result <- putior:::format_result_as_text(c("line 1", "line 2"))
  expect_equal(result, "line 1\nline 2")
})

test_that("format_result_as_text handles single strings", {
  result <- putior:::format_result_as_text("hello world")
  expect_equal(result, "hello world")
})

test_that("format_acp_output produces valid ACP message format", {
  output <- putior:::format_acp_output("test result")

  expect_true(is.list(output))
  expect_equal(length(output), 1)
  expect_equal(output[[1]]$role, "assistant")
  expect_true(is.list(output[[1]]$parts))
  expect_equal(output[[1]]$parts[[1]]$content, "test result")
  expect_equal(output[[1]]$parts[[1]]$content_type, "text/plain")
})

# =============================================================================
# Run Storage Tests
# =============================================================================

test_that("generate_run_id produces unique IDs", {
  id1 <- putior:::generate_run_id()
  id2 <- putior:::generate_run_id()

  expect_true(is.character(id1))
  expect_true(nchar(id1) > 0)
  expect_false(id1 == id2)
})

test_that("store_run and get_run_by_id work correctly", {
  run_id <- "test_run_123"
  run_data <- list(
    run_id = run_id,
    status = "completed",
    output = "test output"
  )

  putior:::store_run(run_id, run_data)
  retrieved <- putior:::get_run_by_id(run_id)

  expect_equal(retrieved$run_id, run_id)
  expect_equal(retrieved$status, "completed")
})

test_that("get_run_by_id returns NULL for non-existent run", {
  result <- putior:::get_run_by_id("non_existent_run_id_xyz")
  expect_null(result)
})

# =============================================================================
# Endpoint Handler Tests
# =============================================================================

test_that("acp_list_agents_handler returns agent list", {
  result <- putior:::acp_list_agents_handler()

  expect_true(is.list(result))
  expect_true("agents" %in% names(result))
  expect_equal(length(result$agents), 1)
  expect_equal(result$agents[[1]]$name, "putior")
})

test_that("acp_create_run_handler processes scan request", {
  body <- list(
    input = list(
      list(
        role = "user",
        parts = list(
          list(content = "help with annotations", content_type = "text/plain")
        )
      )
    ),
    session_id = "test_session"
  )

  result <- putior:::acp_create_run_handler(body)

  expect_true("run_id" %in% names(result))
  expect_equal(result$agent_name, "putior")
  expect_equal(result$session_id, "test_session")
  expect_equal(result$status, "completed")
  expect_true("output" %in% names(result))
})

test_that("acp_create_run_handler stores run for later retrieval", {
  body <- list(
    input = list(
      list(
        role = "user",
        parts = list(
          list(content = "what are your skills", content_type = "text/plain")
        )
      )
    )
  )

  result <- putior:::acp_create_run_handler(body)
  run_id <- result$run_id

  # Should be retrievable
  retrieved <- putior:::get_run_by_id(run_id)
  expect_equal(retrieved$run_id, run_id)
  expect_equal(retrieved$status, "completed")
})

# =============================================================================
# Execute Request Tests
# =============================================================================

test_that("execute_acp_request handles help operation", {
  input <- list(
    list(
      role = "user",
      parts = list(
        list(content = "help with annotations", content_type = "text/plain")
      )
    )
  )

  result <- putior:::execute_acp_request(input)

  expect_true(is.character(result))
  expect_true(nchar(result) > 0)
})

test_that("execute_acp_request handles skills operation", {
  input <- list(
    list(
      role = "user",
      parts = list(
        list(content = "what are your skills", content_type = "text/plain")
      )
    )
  )

  result <- putior:::execute_acp_request(input)

  expect_true(is.character(result))
  expect_true(nchar(result) > 100) # Skills doc is substantial
})

test_that("execute_acp_request handles scan operation with temp file", {
  # Create temp file with annotation
  tmp_dir <- tempdir()
  tmp_file <- file.path(tmp_dir, "test_acp_scan.R")

  writeLines(c(
    '#put id:"test_node", label:"Test Node"',
    'x <- 1'
  ), tmp_file)

  on.exit(unlink(tmp_file))

  input <- list(
    list(
      role = "user",
      parts = list(
        list(
          content = paste0('scan "', tmp_file, '"'),
          content_type = "text/plain"
        )
      )
    )
  )

  result <- putior:::execute_acp_request(input)

  expect_true(is.data.frame(result))
  expect_true("id" %in% names(result))
  expect_equal(result$id[1], "test_node")
})

test_that("execute_acp_request handles errors gracefully", {
  input <- list(
    list(
      role = "user",
      parts = list(
        list(
          content = 'scan "/nonexistent/path/that/does/not/exist"',
          content_type = "text/plain"
        )
      )
    )
  )

  result <- putior:::execute_acp_request(input)

  # Should return error message, not throw
  expect_true(is.character(result) || is.data.frame(result))
})

# =============================================================================
# Server Function Tests
# =============================================================================

test_that("putior_acp_server fails gracefully without plumber2", {
  # Check that the function has proper error handling
  fn_body <- body(putior_acp_server)
  fn_text <- paste(deparse(fn_body), collapse = "\n")

  # Should check for plumber2
  expect_true(grepl("plumber2", fn_text))
  # Should use requireNamespace
  expect_true(grepl("requireNamespace", fn_text))
})

test_that("putior_acp_server accepts host and port parameters", {
  # Check function signature
  args <- formals(putior_acp_server)

  expect_true("host" %in% names(args))
  expect_true("port" %in% names(args))
  expect_equal(args$host, "127.0.0.1")
  expect_equal(args$port, 8080L)
})

# =============================================================================
# Integration Tests
# =============================================================================

test_that("full ACP workflow: manifest -> run -> retrieve", {
  # 1. Get manifest
  manifest <- putior_acp_manifest()
  expect_equal(manifest$name, "putior")

  # 2. Create a run
  body <- list(
    input = list(
      list(
        role = "user",
        parts = list(
          list(content = "help", content_type = "text/plain")
        )
      )
    ),
    session_id = "integration_test"
  )

  run_result <- putior:::acp_create_run_handler(body)
  expect_equal(run_result$status, "completed")

  # 3. Retrieve the run
  run_id <- run_result$run_id
  retrieved <- putior:::get_run_by_id(run_id)
  expect_equal(retrieved$run_id, run_id)
  expect_equal(retrieved$agent_name, "putior")
})

test_that("ACP output format is valid", {
  body <- list(
    input = list(
      list(
        role = "user",
        parts = list(
          list(content = "what are your skills", content_type = "text/plain")
        )
      )
    )
  )

  result <- putior:::acp_create_run_handler(body)

  # Verify output structure
  output <- result$output
  expect_true(is.list(output))
  expect_equal(length(output), 1)
  expect_equal(output[[1]]$role, "assistant")
  expect_true(is.list(output[[1]]$parts))
  expect_equal(output[[1]]$parts[[1]]$content_type, "text/plain")
  expect_true(is.character(output[[1]]$parts[[1]]$content))
})

# =============================================================================
# Path Sanitization Tests
# =============================================================================

test_that("sanitize_acp_path allows normal relative paths", {
  expect_equal(putior:::sanitize_acp_path("./R/"), "./R/")
  expect_equal(putior:::sanitize_acp_path("src/main.R"), "src/main.R")
  expect_equal(putior:::sanitize_acp_path("script.R"), "script.R")
  expect_equal(putior:::sanitize_acp_path("."), ".")
})

test_that("sanitize_acp_path allows absolute paths", {
  expect_equal(putior:::sanitize_acp_path("/home/user/project"), "/home/user/project")
  expect_equal(putior:::sanitize_acp_path("C:/Users/project"), "C:/Users/project")
})

test_that("sanitize_acp_path rejects directory traversal", {
  expect_warning(result <- putior:::sanitize_acp_path("../secret"), "directory traversal")
  expect_equal(result, ".")

  expect_warning(result <- putior:::sanitize_acp_path("foo/../bar"), "directory traversal")
  expect_equal(result, ".")

  expect_warning(result <- putior:::sanitize_acp_path("../../etc/passwd"), "directory traversal")
  expect_equal(result, ".")

  expect_warning(result <- putior:::sanitize_acp_path("foo/.."), "directory traversal")
  expect_equal(result, ".")
})

test_that("sanitize_acp_path rejects backslash directory traversal", {
  expect_warning(result <- putior:::sanitize_acp_path("..\\secret"), "directory traversal")
  expect_equal(result, ".")

  expect_warning(result <- putior:::sanitize_acp_path("foo\\..\\bar"), "directory traversal")
  expect_equal(result, ".")
})

test_that("sanitize_acp_path rejects control characters", {
  # Construct strings with control chars at runtime to avoid null bytes in source
  null_path <- paste0("file", rawToChar(as.raw(0x01)), "name")
  expect_warning(result <- putior:::sanitize_acp_path(null_path), "control characters")
  expect_equal(result, ".")

  expect_warning(result <- putior:::sanitize_acp_path("file\nname"), "control characters")
  expect_equal(result, ".")

  expect_warning(result <- putior:::sanitize_acp_path("file\tname"), "control characters")
  expect_equal(result, ".")
})

test_that("sanitize_acp_path handles NULL, empty, and invalid input", {
  expect_equal(putior:::sanitize_acp_path(NULL), ".")
  expect_equal(putior:::sanitize_acp_path(""), ".")
  expect_equal(putior:::sanitize_acp_path(123), ".")
  expect_equal(putior:::sanitize_acp_path(c("a", "b")), ".")
})
