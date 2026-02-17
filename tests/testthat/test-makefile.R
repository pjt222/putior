# tests/testthat/test-makefile.R
# Tests for Makefile support in putior

# --- Registry tests ---

test_that("get_comment_prefix returns '#' for makefile", {
  expect_equal(get_comment_prefix("makefile"), "#")
})

test_that("ext_to_language returns 'makefile' for makefile", {
  expect_equal(ext_to_language("makefile"), "makefile")
})

test_that("makefile appears in supported extensions", {
  exts <- get_supported_extensions()
  expect_true("makefile" %in% exts)
})

test_that("makefile appears in supported languages", {
  langs <- list_supported_languages()
  expect_true("makefile" %in% langs)
})

test_that("makefile appears in detection-only languages", {
  langs <- list_supported_languages(detection_only = TRUE)
  expect_true("makefile" %in% langs)
})

# --- .FILENAME_MAP tests ---

test_that(".FILENAME_MAP contains Makefile and GNUmakefile", {
  expect_true("Makefile" %in% names(.FILENAME_MAP))
  expect_equal(.FILENAME_MAP[["Makefile"]], "makefile")
  expect_true("GNUmakefile" %in% names(.FILENAME_MAP))
  expect_equal(.FILENAME_MAP[["GNUmakefile"]], "makefile")
})

# --- resolve_language_from_file tests ---

test_that("resolve_language_from_file handles Makefile", {
  resolved <- resolve_language_from_file("/some/path/Makefile")
  expect_equal(resolved$language, "makefile")
  expect_equal(resolved$ext, "makefile")
  expect_equal(resolved$comment_prefix, "#")
})

test_that("resolve_language_from_file handles GNUmakefile", {
  resolved <- resolve_language_from_file("/project/GNUmakefile")
  expect_equal(resolved$language, "makefile")
  expect_equal(resolved$ext, "makefile")
  expect_equal(resolved$comment_prefix, "#")
})

test_that("resolve_language_from_file handles .makefile extension", {
  resolved <- resolve_language_from_file("build.makefile")
  expect_equal(resolved$language, "makefile")
  expect_equal(resolved$ext, "makefile")
  expect_equal(resolved$comment_prefix, "#")
})

# --- build_file_pattern tests ---

test_that("build_file_pattern matches Makefile and GNUmakefile basenames", {
  pattern <- build_file_pattern()
  expect_true(grepl(pattern, "Makefile"))
  expect_true(grepl(pattern, "GNUmakefile"))
  expect_true(grepl(pattern, "build.makefile"))
})

test_that("build_file_pattern detection_only matches Makefile", {
  pattern <- build_file_pattern(detection_only = TRUE)
  expect_true(grepl(pattern, "Makefile"))
  expect_true(grepl(pattern, "GNUmakefile"))
})

# --- Annotation parsing tests ---

test_that("put() finds annotations in a Makefile", {
  tmp_dir <- file.path(tempdir(), "makefile_put_test")
  dir.create(tmp_dir, showWarnings = FALSE)
  makefile_path <- file.path(tmp_dir, "Makefile")

  writeLines(c(
    '# put id:"build", label:"Build Project", output:"app.bin"',
    "all: app.bin",
    "",
    '# put id:"clean", label:"Clean Artifacts"',
    "clean:",
    "\trm -f app.bin"
  ), makefile_path)

  on.exit(unlink(tmp_dir, recursive = TRUE), add = TRUE)

  workflow <- put(tmp_dir)
  expect_s3_class(workflow, "putior_workflow")
  expect_equal(nrow(workflow), 2)
  expect_equal(workflow$id[1], "build")
  expect_equal(workflow$id[2], "clean")
  expect_equal(workflow$file_name[1], "Makefile")
  expect_equal(workflow$file_type[1], "makefile")
})

test_that("put() works on a single Makefile path", {
  tmp_dir <- tempdir()
  makefile_path <- file.path(tmp_dir, "Makefile")

  writeLines(c(
    '# put id:"single", label:"Single File Test"',
    "all: test"
  ), makefile_path)

  on.exit(unlink(makefile_path), add = TRUE)

  workflow <- put(makefile_path)
  expect_s3_class(workflow, "putior_workflow")
  expect_equal(nrow(workflow), 1)
  expect_equal(workflow$id[1], "single")
})

test_that("put() finds .makefile extension files", {
  tmp_dir <- file.path(tempdir(), "makefile_ext_test")
  dir.create(tmp_dir, showWarnings = FALSE)
  makefile_path <- file.path(tmp_dir, "build.makefile")

  writeLines(c(
    '# put id:"ext_test", label:"Extension Test"',
    "all: build"
  ), makefile_path)

  on.exit(unlink(tmp_dir, recursive = TRUE), add = TRUE)

  workflow <- put(tmp_dir)
  expect_s3_class(workflow, "putior_workflow")
  expect_gte(nrow(workflow), 1)
  ext_row <- workflow[workflow$id == "ext_test", ]
  expect_equal(nrow(ext_row), 1)
  expect_equal(ext_row$file_type, "makefile")
})

# --- Auto-detection tests ---

test_that("put_auto() detects Makefile patterns", {
  tmp_dir <- file.path(tempdir(), "makefile_auto_test")
  dir.create(tmp_dir, showWarnings = FALSE)
  makefile_path <- file.path(tmp_dir, "Makefile")

  writeLines(c(
    "SOURCES := $(wildcard src/*.c)",
    "",
    "all: app.bin",
    "\tgcc -o app.bin $(SOURCES)",
    "",
    "install: app.bin",
    "\tinstall -m 755 app.bin /usr/local/bin/",
    "",
    "clean:",
    "\trm -f app.bin"
  ), makefile_path)

  on.exit(unlink(tmp_dir, recursive = TRUE), add = TRUE)

  workflow <- put_auto(tmp_dir)
  expect_s3_class(workflow, "putior_workflow")
  expect_equal(nrow(workflow), 1)
  expect_equal(workflow$file_name[1], "Makefile")
  expect_equal(workflow$file_type[1], "makefile")
  expect_equal(workflow$id[1], "makefile")
  expect_equal(workflow$label[1], "Makefile")
})

test_that("put_auto() works on a single Makefile path", {
  tmp_dir <- tempdir()
  makefile_path <- file.path(tmp_dir, "Makefile")

  writeLines(c(
    "include config.mk",
    "all: build",
    "\techo done > build.log"
  ), makefile_path)

  on.exit(unlink(makefile_path), add = TRUE)

  workflow <- put_auto(makefile_path)
  expect_s3_class(workflow, "putior_workflow")
  expect_equal(nrow(workflow), 1)
})

# --- Detection patterns tests ---

test_that("Makefile detection patterns exist and are valid", {
  patterns <- get_detection_patterns("makefile")

  expect_true(is.list(patterns))
  expect_true("input" %in% names(patterns))
  expect_true("output" %in% names(patterns))
  expect_true("dependency" %in% names(patterns))

  expect_equal(length(patterns$input), 4)
  expect_equal(length(patterns$output), 3)
  expect_equal(length(patterns$dependency), 3)
})

test_that("Makefile input patterns match expected constructs", {
  patterns <- get_detection_patterns("makefile", type = "input")

  funcs <- vapply(patterns, function(p) p$func, character(1))
  expect_true("include" %in% funcs)
  expect_true("$(wildcard)" %in% funcs)
  expect_true("$(shell cat)" %in% funcs)
})

test_that("Makefile output patterns match expected constructs", {
  patterns <- get_detection_patterns("makefile", type = "output")

  funcs <- vapply(patterns, function(p) p$func, character(1))
  expect_true("target rule" %in% funcs)
  expect_true("> (output redirect)" %in% funcs)
  expect_true("install" %in% funcs)
})

test_that("Makefile dependency patterns match expected constructs", {
  patterns <- get_detection_patterns("makefile", type = "dependency")

  funcs <- vapply(patterns, function(p) p$func, character(1))
  expect_true("include" %in% funcs)
  expect_true("$(shell)" %in% funcs)
  expect_true("backtick command" %in% funcs)
})

test_that("Makefile pattern regexes compile without error", {
  patterns <- get_detection_patterns("makefile")

  for (category in names(patterns)) {
    for (pattern_def in patterns[[category]]) {
      expect_no_error(
        grepl(pattern_def$regex, "test line", perl = TRUE)
      )
    }
  }
})

test_that("Makefile patterns match realistic content", {
  patterns <- get_detection_patterns("makefile")

  # Input patterns
  include_regex <- patterns$input[[1]]$regex
  expect_true(grepl(include_regex, "include config.mk"))
  expect_true(grepl(include_regex, "-include optional.mk"))

  wildcard_regex <- patterns$input[[2]]$regex
  expect_true(grepl(wildcard_regex, "SOURCES := $(wildcard src/*.c)"))

  # Output patterns
  target_regex <- patterns$output[[1]]$regex
  expect_true(grepl(target_regex, "all: main.o utils.o"))
  expect_true(grepl(target_regex, "app.bin: main.c"))
  expect_true(grepl(target_regex, "clean:"))

  redirect_regex <- patterns$output[[2]]$regex
  expect_true(grepl(redirect_regex, "\techo done > build.log"))

  # Dependency patterns
  shell_regex <- patterns$dependency[[2]]$regex
  expect_true(grepl(shell_regex, "FILES := $(shell find . -name '*.c')"))

  backtick_regex <- patterns$dependency[[3]]$regex
  expect_true(grepl(backtick_regex, "DATE := `date +%Y-%m-%d`"))
})

# --- Validation tests ---

test_that("validate_annotation accepts Makefile as valid file reference", {
  properties <- list(
    id = "build",
    label = "Build",
    input = "Makefile",
    output = "app.bin"
  )
  issues <- validate_annotation(properties, "# put ...")
  extension_issues <- grep("missing extension.*Makefile", issues, value = TRUE)
  expect_equal(length(extension_issues), 0)
})

test_that("validate_annotation accepts GNUmakefile as valid file reference", {
  properties <- list(
    id = "build",
    label = "Build",
    input = "GNUmakefile"
  )
  issues <- validate_annotation(properties, "# put ...")
  extension_issues <- grep("missing extension.*GNUmakefile", issues, value = TRUE)
  expect_equal(length(extension_issues), 0)
})

# --- is_likely_file_path tests ---

test_that("is_likely_file_path recognizes Makefile", {
  expect_true(is_likely_file_path("Makefile"))
  expect_true(is_likely_file_path("GNUmakefile"))
})

# --- Multiline annotation in Makefile ---

test_that("put() handles multiline annotations in Makefile", {
  tmp_dir <- tempdir()
  makefile_path <- file.path(tmp_dir, "Makefile")

  writeLines(c(
    '# put id:"compile", label:"Compile Sources", \\',
    '#    input:"src/main.c", \\',
    '#    output:"app.bin"',
    "app.bin: src/main.c",
    "\tgcc -o app.bin src/main.c"
  ), makefile_path)

  on.exit(unlink(makefile_path), add = TRUE)

  workflow <- put(makefile_path)
  expect_equal(nrow(workflow), 1)
  expect_equal(workflow$id[1], "compile")
  expect_equal(workflow$label[1], "Compile Sources")
  expect_equal(workflow$input[1], "src/main.c")
  expect_equal(workflow$output[1], "app.bin")
})

# --- Directory scan with mixed files ---

test_that("put() finds Makefile alongside .R files in directory scan", {
  tmp_dir <- file.path(tempdir(), "makefile_mixed_test")
  dir.create(tmp_dir, showWarnings = FALSE)

  writeLines(c(
    '# put id:"r_step", label:"R Script"',
    "x <- 1"
  ), file.path(tmp_dir, "script.R"))

  writeLines(c(
    '# put id:"make_step", label:"Build Target"',
    "all: build"
  ), file.path(tmp_dir, "Makefile"))

  on.exit(unlink(tmp_dir, recursive = TRUE), add = TRUE)

  workflow <- put(tmp_dir)
  expect_equal(nrow(workflow), 2)
  expect_true("r_step" %in% workflow$id)
  expect_true("make_step" %in% workflow$id)
})

# --- put_generate tests ---

test_that("put_generate works on Makefile", {
  tmp_dir <- file.path(tempdir(), "makefile_generate_test")
  dir.create(tmp_dir, showWarnings = FALSE)
  makefile_path <- file.path(tmp_dir, "Makefile")

  writeLines(c(
    "include config.mk",
    "all: app.bin",
    "\tgcc -o app.bin main.c"
  ), makefile_path)

  on.exit(unlink(tmp_dir, recursive = TRUE), add = TRUE)

  annotations <- put_generate(makefile_path, output = "raw")
  expect_true(length(annotations) > 0)
  expect_true(any(grepl("^#", annotations)))
})

# --- put_merge tests ---

test_that("put_merge works with Makefile", {
  tmp_dir <- file.path(tempdir(), "makefile_merge_test")
  dir.create(tmp_dir, showWarnings = FALSE)
  makefile_path <- file.path(tmp_dir, "Makefile")

  writeLines(c(
    '# put id:"build", label:"Build Project"',
    "include config.mk",
    "all: app.bin",
    "\tgcc -o app.bin main.c"
  ), makefile_path)

  on.exit(unlink(tmp_dir, recursive = TRUE), add = TRUE)

  workflow <- put_merge(tmp_dir)
  expect_s3_class(workflow, "putior_workflow")
  expect_gte(nrow(workflow), 1)
})
