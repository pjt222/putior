# Test suite for run_sandbox()
library(testthat)
library(putior)

test_that("run_sandbox() app directory exists in installed package", {
  app_dir <- system.file("shiny", "putior-sandbox", package = "putior")
  expect_true(nzchar(app_dir))
  expect_true(dir.exists(app_dir))
})

test_that("run_sandbox() app directory contains app.R", {
  app_dir <- system.file("shiny", "putior-sandbox", package = "putior")
  expect_true(file.exists(file.path(app_dir, "app.R")))
})

test_that("run_sandbox() is an exported function", {
  expect_true(is.function(putior::run_sandbox))
})

test_that("run_sandbox() takes no required arguments", {
  args <- formals(putior::run_sandbox)
  expect_equal(length(args), 0)
})

# Evaluate selected top-level assignments from the sandbox app.R without
# running the app, so these tests need neither shiny nor a browser.
load_sandbox_definitions <- function(object_names) {
  app_file <- system.file("shiny", "putior-sandbox", "app.R", package = "putior")
  app_expressions <- parse(app_file, keep.source = FALSE)
  sandbox_env <- new.env(parent = baseenv())
  for (app_expression in app_expressions) {
    is_wanted_assignment <- is.call(app_expression) &&
      identical(app_expression[[1]], as.name("<-")) &&
      is.name(app_expression[[2]]) &&
      as.character(app_expression[[2]]) %in% object_names
    if (is_wanted_assignment) {
      eval(app_expression, sandbox_env)
    }
  }
  sandbox_env
}

file_field <- function(files, field_name) {
  vapply(files, function(file_entry) file_entry[[field_name]], character(1))
}

test_that("sandbox parser is defined at the top level of app.R", {
  sandbox_env <- load_sandbox_definitions("parse_code_to_files")
  expect_true(is.function(sandbox_env$parse_code_to_files))
})

test_that("sandbox parser keeps every file of the default multi-file example", {
  sandbox_env <- load_sandbox_definitions(
    c("parse_code_to_files", "sample_multi_file")
  )
  files <- sandbox_env$parse_code_to_files(sandbox_env$sample_multi_file)

  expect_equal(
    file_field(files, "name"),
    c("01_fetch.R", "02_clean.R", "03_analyze.R", "04_report.R")
  )
  file_contents <- file_field(files, "content")
  expect_match(file_contents[1], 'label:"Fetch Data"', fixed = TRUE)
  expect_match(file_contents[2], 'label:"Clean Data"', fixed = TRUE)
  expect_match(file_contents[3], 'label:"Analyze"', fixed = TRUE)
  expect_match(file_contents[4], 'label:"Generate Report"', fixed = TRUE)
})

test_that("sandbox parser ignores text before the first marker", {
  sandbox_env <- load_sandbox_definitions("parse_code_to_files")
  code <- paste0(
    "# preamble\n",
    "# ===== File: a.R =====\nfirst\n",
    "# ===== File: b.R =====\nsecond\n"
  )
  files <- sandbox_env$parse_code_to_files(code)

  expect_equal(file_field(files, "name"), c("a.R", "b.R"))
  expect_equal(file_field(files, "content"), c("first", "second"))
})

test_that("sandbox parser keeps files aligned around empty files", {
  sandbox_env <- load_sandbox_definitions("parse_code_to_files")
  code <- paste0(
    "# ===== File: a.R =====\n",
    "# ===== File: b.R =====\nsecond\n",
    "# ===== File: c.R ====="
  )
  files <- sandbox_env$parse_code_to_files(code)

  expect_equal(file_field(files, "name"), c("a.R", "b.R", "c.R"))
  expect_equal(file_field(files, "content"), c("", "second", ""))
})

test_that("sandbox parser treats code without markers as one script", {
  sandbox_env <- load_sandbox_definitions("parse_code_to_files")
  code <- "# put label:\"Only Step\"\nx <- 1\n"
  files <- sandbox_env$parse_code_to_files(code)

  expect_length(files, 1)
  expect_equal(files[[1]]$name, "script.R")
  expect_equal(files[[1]]$content, code)
})

test_that("default multi-file example yields all four workflow nodes", {
  sandbox_env <- load_sandbox_definitions(
    c("parse_code_to_files", "sample_multi_file")
  )
  files <- sandbox_env$parse_code_to_files(sandbox_env$sample_multi_file)

  # Mirror the app's server: write the simulated files, then scan them.
  sandbox_dir <- tempfile("putior_sandbox_test_")
  dir.create(sandbox_dir)
  on.exit(unlink(sandbox_dir, recursive = TRUE), add = TRUE)
  for (file_entry in files) {
    writeLines(file_entry$content, file.path(sandbox_dir, basename(file_entry$name)))
  }
  workflow <- put(sandbox_dir, validate = FALSE)

  expect_equal(nrow(workflow), 4)
  expect_setequal(
    workflow$label,
    c("Fetch Data", "Clean Data", "Analyze", "Generate Report")
  )
})

test_that("sandbox renders once on load and does not re-render while idle", {
  # Relies on swapping a method on shiny's MockShinySession, which is shiny
  # internals; keep it off CRAN so a shiny change cannot break CRAN checks.
  skip_on_cran()
  skip_if_not_installed("shiny")

  app_file <- system.file("shiny", "putior-sandbox", "app.R", package = "putior")
  app_env <- new.env()
  sys.source(app_file, envir = app_env)
  render_counter <- new.env()
  render_counter$count <- 0

  shiny::testServer(app_env$server, {
    unlockBinding("sendCustomMessage", session)
    session$sendCustomMessage <- function(type, message) {
      if (identical(type, "renderMermaid")) {
        render_counter$count <- render_counter$count + 1
      }
      invisible(NULL)
    }

    session$setInputs(
      template = "multi", code = app_env$sample_multi_file,
      direction = "TD", theme = "github", show_artifacts = FALSE,
      show_files = FALSE, style_nodes = TRUE, show_boundaries = TRUE
    )
    session$elapse(1000)
    expect_equal(render_counter$count, 1)

    # Idle: the old invalidateLater(500) loop re-rendered twice per second.
    session$elapse(10000)
    expect_equal(render_counter$count, 1)

    # A settings change still updates the preview, once.
    session$setInputs(direction = "LR")
    session$elapse(1000)
    expect_equal(render_counter$count, 2)
  })
})

test_that("sandbox status shows why a diagram could not be drawn (#58)", {
  skip_on_cran()
  skip_if_not_installed("shiny")

  app_file <- system.file("shiny", "putior-sandbox", "app.R", package = "putior")
  app_env <- new.env()
  sys.source(app_file, envir = app_env)
  # The server finds put_diagram() through app_env first, so this stand-in
  # makes every diagram fail the way a real error would.
  app_env$put_diagram <- function(...) {
    stop("stand-in diagram failure", call. = FALSE)
  }

  shiny::testServer(app_env$server, {
    session$setInputs(
      template = "multi", code = app_env$sample_multi_file,
      direction = "TD", theme = "github", show_artifacts = FALSE,
      show_files = FALSE, style_nodes = TRUE, show_boundaries = TRUE
    )

    expect_match(output$status, "Found 4 workflow node(s)", fixed = TRUE)
    expect_match(output$status, "stand-in diagram failure", fixed = TRUE)
    expect_null(mermaid_code())
  })
})

test_that("sandbox status has no error when the diagram is drawn", {
  skip_on_cran()
  skip_if_not_installed("shiny")

  app_file <- system.file("shiny", "putior-sandbox", "app.R", package = "putior")
  app_env <- new.env()
  sys.source(app_file, envir = app_env)

  shiny::testServer(app_env$server, {
    session$setInputs(
      template = "multi", code = app_env$sample_multi_file,
      direction = "TD", theme = "github", show_artifacts = FALSE,
      show_files = FALSE, style_nodes = TRUE, show_boundaries = TRUE
    )

    expect_equal(output$status, "Found 4 workflow node(s)")
    expect_match(mermaid_code(), "flowchart TD", fixed = TRUE)
  })
})
