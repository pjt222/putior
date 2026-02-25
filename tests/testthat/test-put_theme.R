# Tests for put_theme() custom theme palette API

# =============================================================================
# put_theme() constructor
# =============================================================================

test_that("put_theme() returns putior_theme class", {
  theme <- put_theme()
  expect_s3_class(theme, "putior_theme")
  expect_true(inherits(theme, "list"))
})

test_that("put_theme() default has all node types", {
  theme <- put_theme()
  expected_types <- c("input", "process", "output", "decision", "artifact", "start", "end")
  expect_true(all(expected_types %in% names(theme)))
})

test_that("put_theme() default inherits from light theme", {
  theme <- put_theme()
  light <- get_theme_colors("light")
  expect_equal(unclass(theme), light)
})

test_that("put_theme() can use different base themes", {
  for (base in c("dark", "github", "viridis", "minimal")) {
    theme <- put_theme(base = base)
    base_colors <- get_theme_colors(base)
    expect_equal(unclass(theme), base_colors)
  }
})

test_that("put_theme() errors on invalid base theme", {
  expect_error(put_theme(base = "nonexistent"), "Invalid base theme")
})

# =============================================================================
# Partial overrides
# =============================================================================

test_that("put_theme() applies partial input override", {
  theme <- put_theme(
    input = c(fill = "#112233", stroke = "#445566", color = "#ffffff")
  )
  expect_match(theme$input, "fill:#112233")
  expect_match(theme$input, "stroke:#445566")
  expect_match(theme$input, "color:#ffffff")
  # Other types should still be light defaults
  light <- get_theme_colors("light")
  expect_equal(theme$process, light$process)
  expect_equal(theme$output, light$output)
})

test_that("put_theme() applies multiple overrides", {
  theme <- put_theme(
    input = c(fill = "#aaaaaa", stroke = "#bbbbbb", color = "#000000"),
    output = c(fill = "#cccccc", stroke = "#dddddd", color = "#111111")
  )
  expect_match(theme$input, "fill:#aaaaaa")
  expect_match(theme$output, "fill:#cccccc")
  # Unspecified types still inherit
  light <- get_theme_colors("light")
  expect_equal(theme$decision, light$decision)
})

test_that("put_theme() overrides on dark base", {
  theme <- put_theme(base = "dark",
    process = c(fill = "#ff0000", stroke = "#00ff00", color = "#0000ff")
  )
  dark <- get_theme_colors("dark")
  expect_match(theme$process, "fill:#ff0000")
  expect_equal(theme$input, dark$input)
})

test_that("put_theme() can override all 7 node types", {
  cols <- c(fill = "#111111", stroke = "#222222", color = "#333333")
  theme <- put_theme(
    input = cols, process = cols, output = cols,
    decision = cols, artifact = cols, start = cols, end = cols
  )
  for (nt in names(theme)) {
    expect_match(theme[[nt]], "fill:#111111")
  }
})

# =============================================================================
# Color validation
# =============================================================================

test_that("is_valid_hex_color() accepts valid colors", {
  expect_true(is_valid_hex_color("#fff"))
  expect_true(is_valid_hex_color("#FFF"))
  expect_true(is_valid_hex_color("#aabbcc"))
  expect_true(is_valid_hex_color("#AABBCC"))
  expect_true(is_valid_hex_color("#aabbccdd"))
})

test_that("is_valid_hex_color() rejects invalid colors", {
  expect_false(is_valid_hex_color("red"))
  expect_false(is_valid_hex_color("#gg0000"))
  expect_false(is_valid_hex_color("aabbcc"))
  expect_false(is_valid_hex_color("#12345"))
  expect_false(is_valid_hex_color(42))
  expect_false(is_valid_hex_color(NULL))
})

test_that("put_theme() errors on invalid hex color", {
  expect_error(
    put_theme(input = c(fill = "red", stroke = "#000000", color = "#ffffff")),
    "Invalid hex color"
  )
  expect_error(
    put_theme(output = c(fill = "#000000", stroke = "not-hex", color = "#ffffff")),
    "Invalid hex color"
  )
})

test_that("put_theme() errors on unnamed vector override", {
  expect_error(
    put_theme(input = c("#111111", "#222222", "#333333")),
    "named character vector"
  )
})

test_that("put_theme() errors on non-character override", {
  expect_error(
    put_theme(input = list(fill = "#111111")),
    "named character vector"
  )
})

test_that("put_theme() errors on unknown keys", {
  expect_error(
    put_theme(input = c(fill = "#111111", background = "#222222")),
    "Unknown key"
  )
})

# =============================================================================
# print method
# =============================================================================

test_that("print.putior_theme() produces output", {
  theme <- put_theme()
  output <- capture.output(print(theme))
  expect_true(length(output) > 0)
  expect_true(any(grepl("putior custom theme", output)))
  expect_true(any(grepl("input", output)))
  expect_true(any(grepl("process", output)))
})

# =============================================================================
# Integration with put_diagram()
# =============================================================================

test_that("put_diagram() accepts palette parameter", {
  dir <- tempdir()
  sub_dir <- file.path(dir, "theme_test")
  dir.create(sub_dir, showWarnings = FALSE)
  on.exit(unlink(sub_dir, recursive = TRUE), add = TRUE)

  writeLines('# put id:"a", label:"Step A", node_type:"input"', file.path(sub_dir, "main.R"))
  writeLines('# put id:"b", label:"Step B", node_type:"output", input:"main.R"', file.path(sub_dir, "out.R"))

  workflow <- put(sub_dir, validate = FALSE)
  my_theme <- put_theme(input = c(fill = "#264653", stroke = "#2a9d8f", color = "#ffffff"))

  result <- put_diagram(workflow, output = "raw", palette = my_theme)
  expect_true(nchar(result) > 0)
  # Custom color should appear in styling
  expect_true(grepl("#264653", result))
})

test_that("put_diagram() palette overrides theme", {
  dir <- tempdir()
  sub_dir <- file.path(dir, "theme_override_test")
  dir.create(sub_dir, showWarnings = FALSE)
  on.exit(unlink(sub_dir, recursive = TRUE), add = TRUE)

  writeLines('# put id:"x", label:"X", node_type:"input"', file.path(sub_dir, "test.R"))
  workflow <- put(sub_dir, validate = FALSE)

  custom <- put_theme(base = "dark",
    input = c(fill = "#abcdef", stroke = "#fedcba", color = "#000000"))

  # theme="github" should be overridden by palette
  result <- put_diagram(workflow, output = "raw", theme = "github", palette = custom)
  expect_true(grepl("#abcdef", result))
})

test_that("put_diagram() errors on invalid palette type", {
  dir <- tempdir()
  sub_dir <- file.path(dir, "theme_invalid_test")
  dir.create(sub_dir, showWarnings = FALSE)
  on.exit(unlink(sub_dir, recursive = TRUE), add = TRUE)

  writeLines('# put id:"x", label:"X"', file.path(sub_dir, "test.R"))
  workflow <- put(sub_dir, validate = FALSE)

  expect_error(
    put_diagram(workflow, output = "raw", palette = list(input = "fill:#fff")),
    "putior_theme"
  )
})

test_that("put_diagram() palette=NULL uses theme normally", {
  dir <- tempdir()
  sub_dir <- file.path(dir, "theme_null_test")
  dir.create(sub_dir, showWarnings = FALSE)
  on.exit(unlink(sub_dir, recursive = TRUE), add = TRUE)

  writeLines('# put id:"x", label:"X", node_type:"input"', file.path(sub_dir, "test.R"))
  workflow <- put(sub_dir, validate = FALSE)

  result <- put_diagram(workflow, output = "raw", theme = "dark", palette = NULL)
  # Should contain dark theme colors
  dark_colors <- get_theme_colors("dark")
  # Extract the fill color from the dark input style
  fill_match <- regmatches(dark_colors$input, regexpr("fill:[^,]+", dark_colors$input))
  expect_true(grepl(fill_match, result))
})

# =============================================================================
# Edge cases
# =============================================================================

test_that("put_theme() with only fill specified", {
  theme <- put_theme(input = c(fill = "#aabbcc"))
  expect_match(theme$input, "fill:#aabbcc")
  expect_match(theme$input, "stroke-width:2px")
})

test_that("put_theme() with only color specified", {
  theme <- put_theme(input = c(color = "#ffffff"))
  expect_match(theme$input, "color:#ffffff")
  expect_match(theme$input, "stroke-width:2px")
})

test_that("put_theme() with 3-digit hex colors", {
  theme <- put_theme(input = c(fill = "#abc", stroke = "#def", color = "#000"))
  expect_match(theme$input, "fill:#abc")
})

test_that("put_theme() with 8-digit hex colors (with alpha)", {
  theme <- put_theme(input = c(fill = "#aabbccdd", stroke = "#11223344", color = "#ffffff"))
  expect_match(theme$input, "fill:#aabbccdd")
})
