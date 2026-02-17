# tests/testthat/test-dockerfile.R
# Tests for Dockerfile support in putior

# --- Registry tests ---

test_that("get_comment_prefix returns '#' for dockerfile", {

  expect_equal(get_comment_prefix("dockerfile"), "#")
})

test_that("ext_to_language returns 'dockerfile' for dockerfile", {
  expect_equal(ext_to_language("dockerfile"), "dockerfile")
})

test_that("dockerfile appears in supported extensions", {
  exts <- get_supported_extensions()
  expect_true("dockerfile" %in% exts)
})

test_that("dockerfile appears in supported languages", {
  langs <- list_supported_languages()
  expect_true("dockerfile" %in% langs)
})

test_that("dockerfile appears in detection-only languages", {
  langs <- list_supported_languages(detection_only = TRUE)
  expect_true("dockerfile" %in% langs)
})

# --- .FILENAME_MAP tests ---

test_that(".FILENAME_MAP contains Dockerfile", {
  expect_true("Dockerfile" %in% names(.FILENAME_MAP))
  expect_equal(.FILENAME_MAP[["Dockerfile"]], "dockerfile")
})

# --- resolve_language_from_file tests ---

test_that("resolve_language_from_file handles Dockerfile", {
  resolved <- resolve_language_from_file("/some/path/Dockerfile")
  expect_equal(resolved$language, "dockerfile")
  expect_equal(resolved$ext, "dockerfile")
  expect_equal(resolved$comment_prefix, "#")
})

test_that("resolve_language_from_file still works for normal extensions", {
  resolved <- resolve_language_from_file("script.R")
  expect_equal(resolved$language, "r")
  expect_equal(resolved$ext, "r")
  expect_equal(resolved$comment_prefix, "#")

  resolved_py <- resolve_language_from_file("analysis.py")
  expect_equal(resolved_py$language, "python")
  expect_equal(resolved_py$ext, "py")
})

test_that("resolve_language_from_file returns NULL language for unknown extensionless files", {
  resolved <- resolve_language_from_file("/path/to/README")
  expect_null(resolved$language)
  expect_equal(resolved$ext, "")
  expect_equal(resolved$comment_prefix, "#")
})

test_that("resolve_language_from_file handles app.dockerfile extension", {
  resolved <- resolve_language_from_file("app.dockerfile")
  expect_equal(resolved$language, "dockerfile")
  expect_equal(resolved$ext, "dockerfile")
  expect_equal(resolved$comment_prefix, "#")
})

# --- build_file_pattern tests ---

test_that("build_file_pattern matches Dockerfile basename", {
  pattern <- build_file_pattern()
  expect_true(grepl(pattern, "Dockerfile"))
  expect_true(grepl(pattern, "app.dockerfile"))
  expect_true(grepl(pattern, "script.R"))
})

test_that("build_file_pattern detection_only matches Dockerfile", {
  pattern <- build_file_pattern(detection_only = TRUE)
  expect_true(grepl(pattern, "Dockerfile"))
})

test_that("build_file_pattern does not match random extensionless files", {
  pattern <- build_file_pattern()
  expect_false(grepl(pattern, "README"))
  expect_false(grepl(pattern, "LICENSE"))
})

# --- Annotation parsing tests ---

test_that("put() finds annotations in a Dockerfile", {
  tmp_dir <- tempdir()
  dockerfile_path <- file.path(tmp_dir, "Dockerfile")

  writeLines(c(
    '# put id:"base", label:"Base Image", output:"base.img"',
    "FROM rocker/r-ver:4.5.2",
    '# put id:"deps", label:"Install Deps", input:"base.img"',
    "RUN apt-get update"
  ), dockerfile_path)

  on.exit(unlink(dockerfile_path), add = TRUE)

  workflow <- put(tmp_dir)
  expect_s3_class(workflow, "putior_workflow")
  expect_equal(nrow(workflow), 2)
  expect_equal(workflow$id[1], "base")
  expect_equal(workflow$id[2], "deps")
  expect_equal(workflow$file_name[1], "Dockerfile")
  expect_equal(workflow$file_type[1], "dockerfile")
})

test_that("put() works on a single Dockerfile path", {
  tmp_dir <- tempdir()
  dockerfile_path <- file.path(tmp_dir, "Dockerfile")

  writeLines(c(
    '# put id:"single", label:"Single File Test"',
    "FROM ubuntu:22.04"
  ), dockerfile_path)

  on.exit(unlink(dockerfile_path), add = TRUE)

  workflow <- put(dockerfile_path)
  expect_s3_class(workflow, "putior_workflow")
  expect_equal(nrow(workflow), 1)
  expect_equal(workflow$id[1], "single")
})

test_that("put() finds .dockerfile extension files", {
  tmp_dir <- tempdir()
  dockerfile_path <- file.path(tmp_dir, "app.dockerfile")

  writeLines(c(
    '# put id:"app", label:"App Build"',
    "FROM node:18"
  ), dockerfile_path)

  on.exit(unlink(dockerfile_path), add = TRUE)

  workflow <- put(tmp_dir)
  expect_s3_class(workflow, "putior_workflow")
  expect_gte(nrow(workflow), 1)
  app_row <- workflow[workflow$id == "app", ]
  expect_equal(nrow(app_row), 1)
  expect_equal(app_row$file_type, "dockerfile")
})

# --- Auto-detection tests ---

test_that("put_auto() detects Dockerfile patterns", {
  tmp_dir <- file.path(tempdir(), "docker_auto_test")
  dir.create(tmp_dir, showWarnings = FALSE)
  dockerfile_path <- file.path(tmp_dir, "Dockerfile")

  writeLines(c(
    "FROM rocker/r-ver:4.5.2",
    'COPY requirements.txt /app/',
    'RUN pip install -r requirements.txt',
    'EXPOSE 8080',
    'CMD ["R", "-e", "shiny::runApp()"]'
  ), dockerfile_path)

  on.exit(unlink(tmp_dir, recursive = TRUE), add = TRUE)

  workflow <- put_auto(tmp_dir)
  expect_s3_class(workflow, "putior_workflow")
  expect_equal(nrow(workflow), 1)
  expect_equal(workflow$file_name[1], "Dockerfile")
  expect_equal(workflow$file_type[1], "dockerfile")
  expect_equal(workflow$id[1], "dockerfile")
  expect_equal(workflow$label[1], "Dockerfile")
})

test_that("put_auto() works on a single Dockerfile path", {
  tmp_dir <- tempdir()
  dockerfile_path <- file.path(tmp_dir, "Dockerfile")

  writeLines(c(
    "FROM ubuntu:22.04",
    "RUN apt-get update",
    "EXPOSE 3000"
  ), dockerfile_path)

  on.exit(unlink(dockerfile_path), add = TRUE)

  workflow <- put_auto(dockerfile_path)
  expect_s3_class(workflow, "putior_workflow")
  expect_equal(nrow(workflow), 1)
})

# --- Detection patterns tests ---

test_that("Dockerfile detection patterns exist and are valid", {
  patterns <- get_detection_patterns("dockerfile")

  expect_true(is.list(patterns))
  expect_true("input" %in% names(patterns))
  expect_true("output" %in% names(patterns))
  expect_true("dependency" %in% names(patterns))

  expect_equal(length(patterns$input), 4)
  expect_equal(length(patterns$output), 4)
  expect_equal(length(patterns$dependency), 5)
})

test_that("Dockerfile input patterns match expected directives", {
  patterns <- get_detection_patterns("dockerfile", type = "input")

  funcs <- vapply(patterns, function(p) p$func, character(1))
  expect_true("FROM" %in% funcs)
  expect_true("COPY" %in% funcs)
  expect_true("ADD" %in% funcs)
  expect_true("COPY --from" %in% funcs)
})

test_that("Dockerfile output patterns match expected directives", {
  patterns <- get_detection_patterns("dockerfile", type = "output")

  funcs <- vapply(patterns, function(p) p$func, character(1))
  expect_true("EXPOSE" %in% funcs)
  expect_true("VOLUME" %in% funcs)
  expect_true("ENTRYPOINT" %in% funcs)
  expect_true("CMD" %in% funcs)
})

test_that("Dockerfile dependency patterns match expected directives", {
  patterns <- get_detection_patterns("dockerfile", type = "dependency")

  funcs <- vapply(patterns, function(p) p$func, character(1))
  expect_true("RUN pip install" %in% funcs)
  expect_true("RUN npm install" %in% funcs)
  expect_true("RUN apt-get install" %in% funcs)
  expect_true("RUN R -e" %in% funcs)
  expect_true("RUN" %in% funcs)
})

test_that("Dockerfile pattern regexes compile without error", {
  patterns <- get_detection_patterns("dockerfile")

  for (category in names(patterns)) {
    for (pattern_def in patterns[[category]]) {
      expect_no_error(
        grepl(pattern_def$regex, "test line", perl = TRUE)
      )
    }
  }
})

test_that("Dockerfile patterns match realistic content", {
  patterns <- get_detection_patterns("dockerfile")

  # Test input patterns
  from_patterns <- patterns$input
  from_regex <- from_patterns[[1]]$regex
  expect_true(grepl(from_regex, "FROM rocker/r-ver:4.5.2"))
  expect_true(grepl(from_regex, "FROM ubuntu:22.04 AS builder"))

  copy_regex <- from_patterns[[2]]$regex
  expect_true(grepl(copy_regex, "COPY . /app"))
  expect_true(grepl(copy_regex, "COPY requirements.txt /app/"))

  # Test output patterns
  expose_regex <- patterns$output[[1]]$regex
  expect_true(grepl(expose_regex, "EXPOSE 8080"))
  expect_true(grepl(expose_regex, "EXPOSE 3000 8080"))

  cmd_regex <- patterns$output[[4]]$regex
  expect_true(grepl(cmd_regex, 'CMD ["R", "-e", "shiny::runApp()"]'))

  # Test dependency patterns
  pip_regex <- patterns$dependency[[1]]$regex
  expect_true(grepl(pip_regex, "RUN pip install pandas numpy"))
  expect_true(grepl(pip_regex, "RUN pip install -r requirements.txt"))

  apt_regex <- patterns$dependency[[3]]$regex
  expect_true(grepl(apt_regex, "RUN apt-get install -y curl wget"))
})

# --- Validation tests ---

test_that("validate_annotation accepts Dockerfile as valid file reference", {
  properties <- list(
    id = "build",
    label = "Build Docker",
    input = "Dockerfile",
    output = "image.tar"
  )
  issues <- validate_annotation(properties, "# put ...")
  # "Dockerfile" should not trigger "missing extension" warning
  extension_issues <- grep("missing extension.*Dockerfile", issues, value = TRUE)
  expect_equal(length(extension_issues), 0)
})

test_that("validate_annotation still flags unknown extensionless references", {
  properties <- list(
    id = "test",
    label = "Test",
    input = "somefile",
    output = "result.csv"
  )
  issues <- validate_annotation(properties, "# put ...")
  expect_true(any(grepl("missing extension.*somefile", issues)))
})

test_that("validate_annotation handles comma-separated refs with Dockerfile", {
  properties <- list(
    id = "build",
    label = "Build",
    input = "Dockerfile,config.yaml"
  )
  issues <- validate_annotation(properties, "# put ...")
  # Neither should trigger missing extension
  expect_equal(length(grep("missing extension", issues)), 0)
})

# --- is_likely_file_path tests ---

test_that("is_likely_file_path recognizes Dockerfile", {
  expect_true(is_likely_file_path("Dockerfile"))
})

# --- Multiline annotation in Dockerfile ---

test_that("put() handles multiline annotations in Dockerfile", {
  tmp_dir <- tempdir()
  dockerfile_path <- file.path(tmp_dir, "Dockerfile")

  writeLines(c(
    '# put id:"build", label:"Build Image", \\',
    '#    input:"requirements.txt", \\',
    '#    output:"app.tar"',
    "FROM python:3.11",
    "COPY requirements.txt .",
    "RUN pip install -r requirements.txt"
  ), dockerfile_path)

  on.exit(unlink(dockerfile_path), add = TRUE)

  workflow <- put(dockerfile_path)
  expect_equal(nrow(workflow), 1)
  expect_equal(workflow$id[1], "build")
  expect_equal(workflow$label[1], "Build Image")
  expect_equal(workflow$input[1], "requirements.txt")
  expect_equal(workflow$output[1], "app.tar")
})

# --- Directory scan with mixed files ---

test_that("put() finds Dockerfile alongside .R files in directory scan", {
  tmp_dir <- file.path(tempdir(), "mixed_scan_test")
  dir.create(tmp_dir, showWarnings = FALSE)

  writeLines(c(
    '# put id:"r_step", label:"R Script"',
    "x <- 1"
  ), file.path(tmp_dir, "script.R"))

  writeLines(c(
    '# put id:"docker_step", label:"Docker Build"',
    "FROM rocker/r-ver:4.5.2"
  ), file.path(tmp_dir, "Dockerfile"))

  on.exit(unlink(tmp_dir, recursive = TRUE), add = TRUE)

  workflow <- put(tmp_dir)
  expect_equal(nrow(workflow), 2)
  expect_true("r_step" %in% workflow$id)
  expect_true("docker_step" %in% workflow$id)
})

# --- put_generate tests ---

test_that("put_generate works on Dockerfile", {
  tmp_dir <- file.path(tempdir(), "docker_generate_test")
  dir.create(tmp_dir, showWarnings = FALSE)
  dockerfile_path <- file.path(tmp_dir, "Dockerfile")

  writeLines(c(
    "FROM rocker/r-ver:4.5.2",
    "COPY . /app",
    "EXPOSE 8080"
  ), dockerfile_path)

  on.exit(unlink(tmp_dir, recursive = TRUE), add = TRUE)

  annotations <- put_generate(dockerfile_path, output = "raw")
  expect_true(length(annotations) > 0)
  # Should use # comment prefix
  expect_true(any(grepl("^#", annotations)))
})

# --- put_merge tests ---

test_that("put_merge works with Dockerfile", {
  tmp_dir <- file.path(tempdir(), "docker_merge_test")
  dir.create(tmp_dir, showWarnings = FALSE)
  dockerfile_path <- file.path(tmp_dir, "Dockerfile")

  writeLines(c(
    '# put id:"build", label:"Build Image"',
    "FROM rocker/r-ver:4.5.2",
    "COPY . /app",
    "EXPOSE 8080"
  ), dockerfile_path)

  on.exit(unlink(tmp_dir, recursive = TRUE), add = TRUE)

  workflow <- put_merge(tmp_dir)
  expect_s3_class(workflow, "putior_workflow")
  expect_gte(nrow(workflow), 1)
})
