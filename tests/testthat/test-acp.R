# Tests for ACP Server functionality
# These tests verify the ACP endpoint handlers, message parsing, and agent manifest

# =============================================================================
# Agent Manifest Tests
# =============================================================================

# Let the server scan a folder for one test (#111); returns a function that
# restores the previous root
set_acp_root <- function(root) {
  acp_state <- putior:::.acp_state
  previous_root <- acp_state$root
  acp_state$root <- root
  function() acp_state$root <- previous_root
}

# Require a token for one test (#111); returns a restore function
set_acp_token <- function(token) {
  acp_state <- putior:::.acp_state
  previous_token <- acp_state$token
  acp_state$token <- token
  function() acp_state$token <- previous_token
}

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

  expected_ops <- c("scan", "diagram", "auto", "generate", "merge", "help", "guide")
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

test_that("detect_operation identifies guide operation", {
  expect_equal(putior:::detect_operation("show me the guide"), "guide")
  expect_equal(putior:::detect_operation("what are your skills"), "guide")
  expect_equal(putior:::detect_operation("what capabilities do you have"), "guide")
  expect_equal(putior:::detect_operation("what can you do"), "guide")
})

test_that("detect_operation defaults to scan for unknown input", {
  expect_equal(putior:::detect_operation("do something"), "scan")
  expect_equal(putior:::detect_operation(""), "scan")
})

test_that("extract_parameters extracts path from quoted string", {
  params <- putior:::extract_parameters('scan "./R/" for annotations')
  expect_equal(params$path, "./R/")
})

test_that("extract_parameters extracts unquoted paths without the space before them", {
  expect_equal(putior:::extract_parameters("scan ./R/")$path, "./R/")
  expect_equal(putior:::extract_parameters("generate diagram for ./R/ please")$path, "./R/")
  expect_equal(putior:::extract_parameters("scan /tmp/x")$path, "/tmp/x")
  expect_equal(putior:::extract_parameters("./R/ only")$path, "./R/")
  # So that sanitize_acp_path() can reject them
  expect_equal(putior:::extract_parameters("scan ../secret")$path, "../secret")
  expect_null(putior:::extract_parameters("scan everything")$path)
})

test_that("ACP requests name paths in every common form (#109)", {
  path_root <- file.path(tempdir(), "acp_paths")
  dir.create(file.path(path_root, "R"), recursive = TRUE, showWarnings = FALSE)
  on.exit(unlink(path_root, recursive = TRUE), add = TRUE)
  old_wd <- setwd(path_root)
  on.exit(setwd(old_wd), add = TRUE, after = FALSE)
  expected_paths <- list(
    "scan D:/dev/p/putior/R for annotations" = "D:/dev/p/putior/R",
    "generate a diagram for D:/dev/p/putior/R" = "D:/dev/p/putior/R",
    "scan C:\\Users\\me\\project" = "C:\\Users\\me\\project",
    "scan ~/project" = "~/project",
    "scan R/" = "R/",
    "scan (./R/), please" = "./R/",
    "scan ./R/(old)" = "./R/(old)",
    "Hi . scan ./R/ please" = "./R/",
    "Can you scan ./R?" = "./R",
    "scan ./R." = "./R",
    "Let's scan './R/'" = "./R/",
    "scan `./R/`" = "./R/",
    "scan \"D:/my project/R\"" = "D:/my project/R",
    # A quoted value that starts like a path before an unquoted one
    "scan \"D:/my project/R\" and ./R/" = "D:/my project/R",
    "scan the package code (./R/)." = "./R/",
    "scan D:/dev/p/putior/R)." = "D:/dev/p/putior/R",
    "scan '/'" = "/",
    "scan ..\\secret" = "..\\secret",
    # An unquoted path wins over a quoted word that is not one
    "generate a diagram for ./R/ using the 'dark' theme" = "./R/",
    "scan for 'put' annotations in ./R/" = "./R/",
    "diagram titled \"ETL pipeline\" for ./R/" = "./R/",
    "generate a diagram for ./R/ like \"https://github.com/pjt222/putior\"" = "./R/",
    "scan ./R/ and show 'and/or' edges" = "./R/",
    # A quoted value that exists before one that does not
    "scan 'nope' or 'R'" = "R",
    "scan source \"./R/\"" = "./R/",
    # A lone "/" or "~" in prose is not the root
    "scan R / Python files in ./src" = "./src",
    "scan ~ 5 files in ./R/" = "./R/",
    # A quoted value that is no path gives an error later, not a scan of "."
    "scan 'nope'" = "nope"
  )
  for (request in names(expected_paths)) {
    expect_equal(putior:::extract_path(request), expected_paths[[request]], label = request)
  }
  # Plain words, prose with a slash, URLs, bare roots and parameter values
  for (request in c("scan src", "scan R files and/or tests", "fetch https://x.org/a", "scan /",
                    "scan ~", "scan D:/", "scan .", "scan R \\ Python files", "scan //",
                    "scan /.", "scan ~/.", "scan D:/.", "scan /./", "scan D:\\.\\",
                    "generate a diagram with the theme set to 'dark'", "direction 'LR' please")) {
    expect_null(putior:::extract_path(request), label = request)
  }
})

test_that("a long request is cut at a word, and brackets cost little (#109)", {
  # A path that the cut would split is dropped, not shortened to a parent
  filler <- strrep("x", 9985)
  expect_null(putior:::extract_path(paste(filler, "scan D:/dev/p/putior/R")))
  expect_equal(putior:::extract_path(paste("scan ./R/", filler, "D:/x")), "./R/")
  expect_equal(putior:::extract_path(paste0("./R/", strrep(")", 9990))), "./R/")
  # Timing varies too much on CRAN's machines
  skip_on_cran()
  timing <- system.time(putior:::extract_path(paste0("./R/", strrep(")", 9990))))
  expect_lt(timing[["elapsed"]], 2)
})

test_that("curly quotes and non-ASCII words around a path work (#109)", {
  # The strings need a UTF-8 locale to exist in R
  skip_if_not(l10n_info()[["UTF-8"]], "needs a UTF-8 locale")
  for (request in c("scan \u2018./R/\u2019", "scan \u201c./R/\u201d", "caf\u00e9's './R/'")) {
    expect_equal(putior:::extract_path(request), "./R/", label = request)
  }
})

test_that("a scan without a path says that it read the working directory (#109)", {
  # An empty working directory: the scans read "." recursively
  empty_dir <- file.path(tempdir(), "acp_no_path")
  dir.create(empty_dir, showWarnings = FALSE)
  on.exit(unlink(empty_dir, recursive = TRUE), add = TRUE)
  old_wd <- setwd(empty_dir)
  on.exit(setwd(old_wd), add = TRUE, after = FALSE)
  for (request in c("scan for annotations", "auto-detect the workflow",
                    "generate annotation suggestions", "merge annotations")) {
    body <- list(input = list(list(role = "user", parts = list(list(
      content = request, content_type = "text/plain"
    )))))
    expect_no_warning(parts <- putior:::acp_create_run_handler(body)$output[[1]]$parts)
    expect_match(parts[[length(parts)]]$content, "No path was found in the request", fixed = TRUE,
                 label = request)
  }
})

test_that("a drive-relative .. path is rejected, and help needs no path", {
  expect_error(putior:::sanitize_acp_path("D:..\\x"), "directory traversal")
  expect_error(putior:::sanitize_acp_path("D:../x"), "directory traversal")
  expect_error(validate_path_arg("D:..\\x", "test"), "traversal")
  body <- list(input = list(list(role = "user", parts = list(list(
    content = "help with annotation syntax for D:/x/../y", content_type = "text/plain"
  )))))
  parts <- putior:::acp_create_run_handler(body)$output[[1]]$parts
  expect_false(grepl("rejected", parts[[1]]$content, fixed = TRUE))
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

  # TB is Mermaid's synonym of TD (#79)
  expect_equal(putior:::extract_parameters("direction: tb")$direction, "TB")
  # Only a whole word counts as a direction
  expect_null(putior:::extract_parameters("direction TBD")$direction)
  expect_null(putior:::extract_parameters("direction rlx")$direction)
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

test_that("fallback_run_id gives unique IDs without using the RNG (#67)", {
  had_seed <- exists(".Random.seed", envir = globalenv())
  seed_before <- if (had_seed) get(".Random.seed", envir = globalenv())

  # Many calls within the same second must still differ.
  ids <- vapply(seq_len(200), function(i) putior:::fallback_run_id(), character(1))

  expect_false(anyDuplicated(ids) > 0)
  expect_match(ids, "^run_[0-9]{14}_[0-9]+$")
  expect_identical(exists(".Random.seed", envir = globalenv()), had_seed)
  if (had_seed) {
    expect_identical(get(".Random.seed", envir = globalenv()), seed_before)
  }
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
          list(content = "show me the guide", content_type = "text/plain")
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

test_that("execute_acp_request handles guide operation", {
  input <- list(
    list(
      role = "user",
      parts = list(
        list(content = "show me the guide", content_type = "text/plain")
      )
    )
  )

  result <- putior:::execute_acp_request(input)

  expect_true(is.character(result))
  expect_true(nchar(result) > 100) # Guide doc is substantial
})

test_that("execute_acp_request handles 'skills' alias for guide operation", {
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
  expect_true(nchar(result) > 100)
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
  restore_root <- set_acp_root(tmp_dir)
  on.exit(restore_root(), add = TRUE)

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
          list(content = "show me the guide", content_type = "text/plain")
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

test_that("sanitize_acp_path rejects directory traversal with an error", {
  # Before, it warned (only in the server log) and scanned "." instead
  for (path in c("../secret", "foo/../bar", "../../etc/passwd", "foo/..", "..\\secret",
                 "foo\\..\\bar")) {
    expect_error(putior:::sanitize_acp_path(path), "directory traversal")
  }
})

test_that("sanitize_acp_path rejects control characters with an error", {
  # Construct strings with control chars at runtime to avoid null bytes in source
  null_path <- paste0("file", rawToChar(as.raw(0x01)), "name")
  for (path in c(null_path, "file\nname", "file\tname")) {
    expect_error(putior:::sanitize_acp_path(path), "control characters")
  }
})

test_that("a rejected path ends the run with an error, not a scan of '.'", {
  for (text in c("scan ../secret", "scan '../secret' for annotations")) {
    body <- list(input = list(list(role = "user",
                                   parts = list(list(content = text, content_type = "text/plain")))))
    parts <- putior:::acp_create_run_handler(body)$output[[1]]$parts
    expect_match(parts[[1]]$content, "^Error: Path rejected: directory traversal")
  }
})

test_that("ACP runs return R's warnings as a second part", {
  warn_dir <- file.path(tempdir(), "putior_acp_warn")
  unlink(warn_dir, recursive = TRUE)
  dir.create(warn_dir)
  on.exit(unlink(warn_dir, recursive = TRUE), add = TRUE)
  restore_root <- set_acp_root(warn_dir)
  on.exit(restore_root(), add = TRUE)
  writeLines('# put id:"a", label:"A", node_type:"oops"', file.path(warn_dir, "a.R"))
  body <- list(input = list(list(role = "user", parts = list(list(
    content = paste0("scan '", warn_dir, "' for annotations"), content_type = "text/plain"
  )))))
  expect_no_warning(result <- putior:::acp_create_run_handler(body))
  parts <- result$output[[1]]$parts
  expect_length(parts, 2)
  expect_match(parts[[1]]$content, "Found 1 workflow node", fixed = TRUE)
  expect_match(parts[[2]]$content, "^putior warnings \\(1\\), not part of the result above:\n- ")
  expect_match(parts[[2]]$content, "oops", fixed = TRUE)
  expect_equal(parts[[2]]$content_type, "text/plain")

  # A workflow without an input column is listed, not an error
  expect_false(grepl("Input:", parts[[1]]$content, fixed = TRUE))
  expect_match(putior:::format_result_as_text(data.frame(id = "a", label = "A")),
               "Node 1: a\n  Label: A", fixed = TRUE)

  # Without warnings one part, as before
  expect_length(putior:::format_acp_output("result"), 1)
  expect_length(putior:::format_acp_output("result")[[1]]$parts, 1)
})

test_that("sanitize_acp_path handles NULL, empty, and invalid input", {
  expect_equal(putior:::sanitize_acp_path(NULL), ".")
  expect_equal(putior:::sanitize_acp_path(""), ".")
  expect_equal(putior:::sanitize_acp_path(123), ".")
  expect_equal(putior:::sanitize_acp_path(c("a", "b")), ".")
})

# =============================================================================
# Run Retrieval Tests
# =============================================================================

test_that("get_run_by_id returns NULL for non-existent run", {
  result <- putior:::get_run_by_id("nonexistent_run_id_12345")
  expect_null(result)
})

test_that("store_run and get_run_by_id round-trip works", {
  run_id <- paste0("test_run_", sample(10000:99999, 1))
  run_data <- list(status = "completed", output = "test output")

  putior:::store_run(run_id, run_data)
  result <- putior:::get_run_by_id(run_id)

  expect_equal(result$status, "completed")
  expect_equal(result$output, "test output")
})

test_that("acp_get_run_handler returns 404 for missing run", {
  # Create a mock response object
  mock_response <- new.env(parent = emptyenv())
  mock_response$status <- 200L

  result <- putior:::acp_get_run_handler("nonexistent_id", response = mock_response)

  expect_equal(mock_response$status, 404L)
  expect_equal(result$error, "Run not found")
  expect_equal(result$run_id, "nonexistent_id")
})

test_that("acp_get_run_handler returns run data for existing run", {
  # Store a test run
  run_id <- paste0("test_handler_", sample(10000:99999, 1))
  run_data <- list(
    id = run_id,
    status = "completed",
    output = list(list(parts = list(list(content = "test"))))
  )
  putior:::store_run(run_id, run_data)

  # Create a mock response object
  mock_response <- new.env(parent = emptyenv())
  mock_response$status <- 200L

  result <- putior:::acp_get_run_handler(run_id, response = mock_response)

  # Status should remain 200 (not changed to 404)
  expect_equal(mock_response$status, 200L)
  expect_equal(result$id, run_id)
  expect_equal(result$status, "completed")
})

test_that("store_run evicts oldest entries when over capacity", {
  # Save original max and set a small limit for testing
  original_max <- putior:::.ACP_MAX_RUNS
  on.exit({
    # Clean up all test runs and restore constant
    run_ids <- ls(envir = putior:::.acp_runs)
    test_ids <- run_ids[grepl("^evict_test_", run_ids)]
    if (length(test_ids) > 0) rm(list = test_ids, envir = putior:::.acp_runs)
  })

  # Use unlockBinding to temporarily change the constant
  env <- asNamespace("putior")
  unlockBinding(".ACP_MAX_RUNS", env)
  assign(".ACP_MAX_RUNS", 5L, envir = env)

  # Store 7 runs (should evict 2 oldest)
  for (i in 1:7) {
    putior:::store_run(
      paste0("evict_test_", i),
      list(status = "completed", result = i)
    )
    Sys.sleep(0.01)  # Ensure distinct timestamps
  }

  # Restore original max
  assign(".ACP_MAX_RUNS", original_max, envir = env)
  lockBinding(".ACP_MAX_RUNS", env)

  # Oldest 2 should be evicted
  expect_null(putior:::get_run_by_id("evict_test_1"))
  expect_null(putior:::get_run_by_id("evict_test_2"))

  # Newest 5 should remain
  for (i in 3:7) {
    expect_false(is.null(putior:::get_run_by_id(paste0("evict_test_", i))))
  }
})

# =============================================================================
# The server over HTTP (#113)
# =============================================================================

# Start the ACP API on a free local port; returns a function that sends
# real requests to it, and stop() to end the server
start_acp_server <- function() {
  api <- putior:::acp_api()
  port <- NA_integer_
  for (candidate in sample(30000:39999, 20)) {
    started <- tryCatch({
      plumber2::api_run(api, host = "127.0.0.1", port = candidate, block = FALSE,
                        showcase = FALSE, silent = TRUE)
      TRUE
    }, error = function(e) FALSE)
    if (started) {
      port <- candidate
      break
    }
  }
  if (is.na(port)) skip("no free port for the ACP server")
  request <- function(path, body = NULL, headers = character(),
                      content_type = "application/json") {
    handle <- curl::new_handle()
    header_lines <- headers
    if (!is.null(body)) {
      curl::handle_setopt(handle, postfields = body)
      # An empty value makes curl send no Content-Type at all
      header_lines <- c(header_lines, paste0("Content-Type: ", content_type))
    }
    if (length(header_lines) > 0) curl::handle_setopt(handle, httpheader = header_lines)
    done <- FALSE
    result <- NULL
    curl::curl_fetch_multi(
      paste0("http://127.0.0.1:", port, path), handle = handle,
      done = function(response) { result <<- response; done <<- TRUE },
      fail = function(message) { result <<- message; done <<- TRUE }
    )
    deadline <- Sys.time() + 30
    while (!done && Sys.time() < deadline) {
      later::run_now(0.05)
      curl::multi_run(timeout = 0.05, poll = TRUE)
    }
    if (!is.list(result)) stop("request failed: ", paste(result, collapse = " "))
    text <- rawToChar(result$content)
    list(status = result$status_code,
         json = if (nzchar(text) && jsonlite::validate(text)) {
           jsonlite::fromJSON(text, simplifyVector = FALSE)
         })
  }
  list(request = request, stop = function() plumber2::api_stop(api))
}

test_that("the ACP server answers real HTTP requests (#113)", {
  skip_on_cran()
  skip_if_not_installed("plumber2")
  skip_if_not_installed("curl")
  skip_if_not_installed("later")
  skip_if_not_installed("jsonlite")
  server <- start_acp_server()
  on.exit(server$stop(), add = TRUE)
  request <- server$request

  agents <- request("/agents")
  expect_equal(agents$status, 200L)
  # Scalars are unboxed for ACP clients
  expect_identical(agents$json$agents[[1]]$name, "putior")

  # The parser turns this body into a data frame; it used to fail with 500
  run <- request("/runs", '{"input":[{"role":"user","parts":[{"content":"help"}]}]}')
  expect_equal(run$status, 200L)
  expect_identical(run$json$status, "completed")
  expect_null(run$json$session_id)
  expect_match(run$json$output[[1]]$parts[[1]]$content, "putior", fixed = TRUE)

  stored <- request(paste0("/runs/", run$json$run_id))
  expect_equal(stored$status, 200L)
  expect_identical(stored$json$run_id, run$json$run_id)
  expect_equal(request("/runs/no_such_run")$status, 404L)
})

test_that("acp_records() turns a parsed data frame into records (#113)", {
  parsed <- jsonlite::fromJSON('{"input":[{"role":"user","parts":[{"content":"scan ./R/"}]}]}')
  expect_true(is.data.frame(parsed$input))
  expect_equal(putior:::extract_text_content(parsed$input), "scan ./R/")
  plain <- list(list(role = "user", parts = list(list(content = "a"), list(content = "b"))))
  expect_equal(putior:::extract_text_content(plain), "a b")
})

# =============================================================================
# Scan root, token and run ids (#111)
# =============================================================================

test_that("requests may scan only inside the server's root folder (#111)", {
  root <- file.path(tempdir(), "acp_root")
  sibling <- file.path(tempdir(), "acp_root2")
  dir.create(file.path(root, "R"), recursive = TRUE, showWarnings = FALSE)
  dir.create(sibling, showWarnings = FALSE)
  on.exit(unlink(c(root, sibling), recursive = TRUE), add = TRUE)
  restore_root <- set_acp_root(root)
  on.exit(restore_root(), add = TRUE)
  normalized_root <- normalizePath(root, winslash = "/")

  # Inside: relative paths are taken from the root, absolute ones must lie in it
  expect_equal(putior:::confine_acp_path("R"), paste0(normalized_root, "/R"))
  expect_equal(putior:::confine_acp_path(paste0(normalized_root, "/R")), paste0(normalized_root, "/R"))
  expect_equal(putior:::confine_acp_path(normalized_root), normalized_root)
  expect_equal(putior:::confine_acp_path("not_there_yet"), paste0(normalized_root, "/not_there_yet"))
  # Outside: another folder, a sibling whose name starts like the root, home
  for (path in c(normalizePath(tempdir(), winslash = "/"), normalizePath(sibling, winslash = "/"),
                 "~", "/")) {
    expect_error(putior:::confine_acp_path(path), "outside the folder this server scans",
                 label = path)
  }
  # Through a request: an error message, not a scan
  body <- list(input = list(list(role = "user", parts = list(list(
    content = paste0("scan '", normalizePath(sibling, winslash = "/"), "'"),
    content_type = "text/plain"
  )))))
  parts <- putior:::acp_create_run_handler(body)$output[[1]]$parts
  expect_match(parts[[1]]$content, "^Error: Path rejected: outside the folder")
})

test_that("a link out of the root does not get out (#111)", {
  skip_on_os("windows")
  root <- file.path(tempdir(), "acp_link_root")
  outside <- file.path(tempdir(), "acp_link_target")
  dir.create(root, showWarnings = FALSE)
  dir.create(outside, showWarnings = FALSE)
  on.exit(unlink(c(root, outside), recursive = TRUE), add = TRUE)
  skip_if_not(file.symlink(outside, file.path(root, "link")), "cannot make a link")
  restore_root <- set_acp_root(root)
  on.exit(restore_root(), add = TRUE)
  expect_error(putior:::confine_acp_path("link"), "outside the folder this server scans")
})

test_that("a scan without a path reads the root folder (#111)", {
  root <- file.path(tempdir(), "acp_default_root")
  dir.create(root, showWarnings = FALSE)
  on.exit(unlink(root, recursive = TRUE), add = TRUE)
  writeLines('# put id:"in_root", label:"In root"', file.path(root, "a.R"))
  restore_root <- set_acp_root(root)
  on.exit(restore_root(), add = TRUE)
  body <- list(input = list(list(role = "user", parts = list(list(
    content = "scan for annotations", content_type = "text/plain"
  )))))
  parts <- putior:::acp_create_run_handler(body)$output[[1]]$parts
  expect_match(parts[[1]]$content, "Node 1: in_root", fixed = TRUE)
  expect_match(parts[[2]]$content, "server's root folder was scanned", fixed = TRUE)
})

test_that("with a token, requests need it (#111)", {
  restore_token <- set_acp_token("0123456789abcdef-secret")
  on.exit(restore_token(), add = TRUE)
  fake_request <- function(header) list(get_header = function(name) header)
  expect_true(putior:::acp_authorized(fake_request("Bearer 0123456789abcdef-secret")))
  expect_false(putior:::acp_authorized(fake_request("Bearer wrong")))
  expect_false(putior:::acp_authorized(fake_request(NULL)))
  expect_false(putior:::acp_authorized(NULL))
  response <- new.env()
  response$set_header <- function(name, value) response$header <- c(name, value)
  result <- putior:::acp_create_run_handler(list(input = list()), request = fake_request(NULL),
                                            response = response)
  expect_equal(response$status, 401L)
  expect_equal(response$header, c("WWW-Authenticate", "Bearer"))
  expect_match(result$error, "Unauthorized", fixed = TRUE)
  # Without a token, a request needs none
  restore_token()
  expect_true(putior:::acp_authorized(fake_request(NULL)))
})

test_that("putior_acp_server() checks root and token, and needs a token off loopback (#111)", {
  skip_if_not_installed("plumber2")
  local_mocked_bindings(api_run = function(...) "ran", .package = "plumber2")
  quietly <- function(code) suppressMessages(code)
  expect_error(quietly(putior_acp_server(root = file.path(tempdir(), "no_such_folder"))),
               "'root' must be an existing folder")
  expect_error(quietly(putior_acp_server(token = "short")), "at least 16 characters")
  expect_error(quietly(putior_acp_server(host = "0.0.0.0")), "needs a token")
  expect_error(quietly(putior_acp_server(host = "192.168.1.5")), "needs a token")
  expect_warning(quietly(putior_acp_server(host = "0.0.0.0", token = strrep("x", 20))),
                 "requests need the token")
  expect_no_warning(quietly(putior_acp_server(host = "localhost")))
  # The settings apply only while the server runs
  expect_null(putior:::.acp_state$root)
  expect_null(putior:::.acp_state$token)
})

test_that("run ids are not guessable, and leave the RNG alone (#111, #67)", {
  skip_if_not_installed("openssl")
  had_seed <- exists(".Random.seed", envir = globalenv())
  seed_before <- if (had_seed) get(".Random.seed", envir = globalenv())
  ids <- vapply(seq_len(50), function(i) putior:::generate_run_id(), character(1))
  expect_match(ids, "^run_[0-9a-f]{32}$")
  expect_false(anyDuplicated(ids) > 0)
  expect_identical(exists(".Random.seed", envir = globalenv()), had_seed)
  if (had_seed) expect_identical(get(".Random.seed", envir = globalenv()), seed_before)
})

test_that("a server with a token rejects requests without it over HTTP (#111)", {
  skip_on_cran()
  skip_if_not_installed("plumber2")
  skip_if_not_installed("curl")
  skip_if_not_installed("later")
  skip_if_not_installed("jsonlite")
  token <- "0123456789abcdef-secret"
  restore_token <- set_acp_token(token)
  on.exit(restore_token(), add = TRUE)
  server <- start_acp_server()
  on.exit(server$stop(), add = TRUE)
  body <- '{"input":[{"role":"user","parts":[{"content":"help"}]}]}'
  expect_equal(server$request("/agents")$status, 200L)
  expect_equal(server$request("/runs", body)$status, 401L)
  expect_equal(server$request("/runs", body, "Authorization: Bearer wrong")$status, 401L)
  run <- server$request("/runs", body, paste("Authorization: Bearer", token))
  expect_equal(run$status, 200L)
  expect_equal(server$request(paste0("/runs/", run$json$run_id))$status, 401L)
  expect_equal(server$request(paste0("/runs/", run$json$run_id),
                              headers = paste("Authorization: Bearer", token))$status, 200L)
})

test_that("a scan skips files that links inside the root lead outside to (#111)", {
  root <- file.path(tempdir(), "acp_links_root")
  outside <- file.path(tempdir(), "acp_links_outside")
  dir.create(root, showWarnings = FALSE)
  dir.create(outside, showWarnings = FALSE)
  on.exit(unlink(c(root, outside), recursive = TRUE), add = TRUE)
  writeLines('# put id:"inside", label:"Inside"', file.path(root, "ok.R"))
  writeLines('# put id:"secret", label:"OUTSIDE SECRET"', file.path(outside, "leak.R"))
  # A link name with regular expression metacharacters, as the exclude
  # patterns must escape them
  link_name <- "l(i)n[k]+$"
  linked <- if (.Platform$OS.type == "windows") {
    Sys.junction(outside, file.path(root, link_name))
  } else {
    file.symlink(outside, file.path(root, link_name)) &&
      file.symlink(file.path(outside, "leak.R"), file.path(root, "filelink.R"))
  }
  skip_if_not(isTRUE(linked), "cannot make links")
  restore_root <- set_acp_root(root)
  on.exit(restore_root(), add = TRUE)
  for (request in c("scan for annotations", "auto-detect the workflow", "merge annotations",
                    "generate annotation suggestions", "generate a diagram for ./")) {
    body <- list(input = list(list(role = "user", parts = list(list(
      content = request, content_type = "text/plain"
    )))))
    parts <- putior:::acp_create_run_handler(body)$output[[1]]$parts
    all_text <- paste(vapply(parts, function(part) part$content, ""), collapse = "\n")
    expect_false(grepl("OUTSIDE SECRET|leak\\.R|secret", all_text), label = request)
    expect_match(all_text, "lead outside the server's root folder", fixed = TRUE, label = request)
  }
  # The files inside the root are still scanned (on Linux, the first link
  # once hid every file)
  body <- list(input = list(list(role = "user", parts = list(list(
    content = "scan for annotations", content_type = "text/plain"
  )))))
  parts <- putior:::acp_create_run_handler(body)$output[[1]]$parts
  expect_match(parts[[1]]$content, "Node 1: inside", fixed = TRUE)
  normalized_root <- normalizePath(root, winslash = "/")
  patterns <- suppressWarnings(putior:::acp_outside_excludes(normalized_root))
  expect_false("^(/|$)" %in% patterns)
  expect_true(paste0(normalized_root, "/ok.R") %in%
                putior:::filter_excluded_files(list.files(normalized_root, full.names = TRUE,
                                                          recursive = TRUE), patterns))
})

test_that("network and device paths are rejected before any file access (#111)", {
  for (path in c("\\\\server\\share\\x", "//server/share/x", "\\\\?\\C:\\x", "\\\\.\\pipe\\x")) {
    expect_error(putior:::sanitize_acp_path(path), "network and device paths", label = path)
  }
  expect_null(putior:::extract_path("scan \\\\10.255.255.2\\share\\x please"))
  body <- list(input = list(list(role = "user", parts = list(list(
    content = "scan '//10.255.255.1/share/x'", content_type = "text/plain"
  )))))
  parts <- putior:::acp_create_run_handler(body)$output[[1]]$parts
  expect_match(parts[[1]]$content, "network and device paths", fixed = TRUE)
})

test_that("paths are recognized and resolved relative to the root (#111)", {
  root <- file.path(tempdir(), "acp_relative_root")
  dir.create(file.path(root, "proj"), recursive = TRUE, showWarnings = FALSE)
  on.exit(unlink(root, recursive = TRUE), add = TRUE)
  writeLines('# put id:"p", label:"P"', file.path(root, "proj", "p.R"))
  restore_root <- set_acp_root(root)
  on.exit(restore_root(), add = TRUE)
  # The working directory is elsewhere; the word exists only under the root
  expect_false(file.exists("proj/p.R"))
  expect_equal(putior:::extract_path("scan proj/p.R"), "proj/p.R")
  # Messages name the root as <root>, not its absolute path
  body <- list(input = list(list(role = "user", parts = list(list(
    content = "scan ./nothere", content_type = "text/plain"
  )))))
  parts <- putior:::acp_create_run_handler(body)$output[[1]]$parts
  expect_match(parts[[1]]$content, "<root>", fixed = TRUE)
  expect_false(grepl(normalizePath(root, winslash = "/"), parts[[1]]$content, fixed = TRUE))
})

test_that("only real loopback hosts run without a token, and tokens have no spaces (#111)", {
  skip_if_not_installed("plumber2")
  local_mocked_bindings(api_run = function(...) "ran", .package = "plumber2")
  quietly <- function(code) suppressMessages(code)
  for (host in c("127.0.0.1.evil.example", "127.attacker.com", "localhost.evil")) {
    expect_error(quietly(putior_acp_server(host = host)), "needs a token", label = host)
  }
  for (host in c("127.0.0.1", "127.1.2.3", "LOCALHOST", "::1")) {
    expect_no_error(quietly(putior_acp_server(host = host)))
  }
  expect_error(quietly(putior_acp_server(token = strrep(" ", 20))), "at least 16 characters")
  expect_error(quietly(putior_acp_server(token = "0123456789 abcdef")), "without spaces")
})

test_that("the Bearer scheme is case-insensitive, the token is not (#111)", {
  restore_token <- set_acp_token("0123456789abcdef-secret")
  on.exit(restore_token(), add = TRUE)
  fake_request <- function(header) list(get_header = function(name) header)
  expect_true(putior:::acp_authorized(fake_request("bearer 0123456789abcdef-secret")))
  expect_true(putior:::acp_authorized(fake_request("BEARER 0123456789abcdef-secret")))
  expect_false(putior:::acp_authorized(fake_request("Bearer 0123456789ABCDEF-SECRET")))
  expect_false(putior:::acp_authorized(fake_request("Basic 0123456789abcdef-secret")))
})

test_that("folder matching is case-sensitive except on Windows (#111)", {
  skip_on_os("windows")
  expect_false(putior:::is_inside_folder("/a/Root/x", "/a/root"))
  expect_true(putior:::is_inside_folder("/a/root/x", "/a/root"))
})

test_that("the server refuses foreign hosts, other content types and odd bodies (#111)", {
  skip_on_cran()
  skip_if_not_installed("plumber2")
  skip_if_not_installed("curl")
  skip_if_not_installed("later")
  skip_if_not_installed("jsonlite")
  server <- start_acp_server()
  on.exit(server$stop(), add = TRUE)
  body <- '{"input":[{"role":"user","parts":[{"content":"help"}]}]}'
  # DNS rebinding: a name of the attacker's that resolves to 127.0.0.1
  expect_equal(server$request("/agents", headers = "Host: evil.example")$status, 403L)
  expect_equal(server$request("/runs", body, "Host: evil.example:8080")$status, 403L)
  expect_equal(server$request("/runs", body, "Host: localhost")$status, 200L)
  # A cross-site form or text post
  expect_equal(server$request("/runs", body, content_type = "text/plain")$status, 415L)
  expect_equal(server$request("/runs", body, content_type = "")$status, 415L)
  # Bodies that are not an object with an input array
  expect_equal(server$request("/runs", '"abc"')$status, 400L)
  expect_equal(server$request("/runs", '{"input":"scan"}')$status, 400L)
  # Large bodies are not read
  big_body <- paste0('{"input":[{"role":"user","parts":[{"content":"',
                     strrep("x", 2e6), '"}]}]}')
  expect_equal(server$request("/runs", big_body)$status, 413L)
})

test_that("a link to a large outside tree does not stall the scan (#111)", {
  skip_on_cran()
  root <- file.path(tempdir(), "acp_big_root")
  outside <- file.path(tempdir(), "acp_big_outside")
  dir.create(root, showWarnings = FALSE)
  dir.create(outside, showWarnings = FALSE)
  on.exit(unlink(c(root, outside), recursive = TRUE), add = TRUE)
  writeLines('# put id:"inside", label:"Inside"', file.path(root, "ok.R"))
  invisible(file.create(file.path(outside, sprintf("f%04d.R", seq_len(2000)))))
  linked <- if (.Platform$OS.type == "windows") {
    Sys.junction(outside, file.path(root, "cache"))
  } else {
    file.symlink(outside, file.path(root, "cache"))
  }
  skip_if_not(isTRUE(linked), "cannot make links")
  restore_root <- set_acp_root(root)
  on.exit(restore_root(), add = TRUE)
  normalized_root <- normalizePath(root, winslash = "/")
  # One pattern for the link, not one per file
  expect_warning(patterns <- putior:::acp_outside_excludes(normalized_root), "2000 files")
  expect_length(patterns, 2)
  timing <- system.time(suppressWarnings(
    put(normalized_root, exclude = patterns)
  ))
  expect_lt(timing[["elapsed"]], 20)
})

test_that("the root is redacted only where it ends at a path boundary (#111)", {
  root <- file.path(tempdir(), "acp_redact")
  dir.create(root, showWarnings = FALSE)
  on.exit(unlink(root, recursive = TRUE), add = TRUE)
  restore_root <- set_acp_root(root)
  on.exit(restore_root(), add = TRUE)
  normalized_root <- normalizePath(root, winslash = "/")
  expect_equal(putior:::redact_acp_root(paste0("Path does not exist: '", normalized_root, "/x'")),
               "Path does not exist: '<root>/x'")
  sibling <- paste0(normalized_root, "tra/secret.R")
  expect_equal(putior:::redact_acp_root(sibling), sibling)
  # A file system root would be every path's start: left alone
  restore_root()
  restore_root <- set_acp_root("/")
  expect_equal(putior:::redact_acp_root("Found /etc/x and a/b"), "Found /etc/x and a/b")

  # Followed by punctuation, and percent-encoded in a URL (a root with a space)
  root_with_space <- "/srv/my root"
  for (text in c("in (/srv/my root).", "at /srv/my root: x", "[/srv/my root]",
                 "a,/srv/my root,b", "dir=/srv/my root;", "{/srv/my root}")) {
    expect_false(grepl(root_with_space, putior:::redact_acp_root(text, root_with_space), fixed = TRUE),
                 label = text)
  }
  expect_equal(putior:::redact_acp_root("vscode://file/srv/my%20root/a.R:1", root_with_space),
               "vscode://file<root>/a.R:1")
  # With backslashes, as Windows messages write it
  expect_equal(putior:::redact_acp_root("see D:\\my root\\a.R.", "D:/my root"),
               "see <root>\\a.R.")
  # A longer name is another file or folder
  for (text in c("/srv/my root.txt", "/srv/my rootxtra/a", "/srv/my root-2", "/srv/my root%20b")) {
    expect_equal(putior:::redact_acp_root(text, root_with_space), text, label = text)
  }
})

test_that("a scan with too many links out of the root is refused (#111)", {
  skip_on_os("windows")
  root <- file.path(tempdir(), "acp_many_links")
  outside <- file.path(tempdir(), "acp_many_links_outside")
  dir.create(root, showWarnings = FALSE)
  dir.create(outside, showWarnings = FALSE)
  on.exit(unlink(c(root, outside), recursive = TRUE), add = TRUE)
  targets <- file.path(outside, sprintf("t%03d.R", seq_len(210)))
  invisible(file.create(targets))
  linked <- all(file.symlink(targets, file.path(root, basename(targets))))
  skip_if_not(linked, "cannot make links")
  restore_root <- set_acp_root(root)
  on.exit(restore_root(), add = TRUE)
  expect_error(putior:::acp_outside_excludes(normalizePath(root, winslash = "/")),
               "more than 200 links")
})
